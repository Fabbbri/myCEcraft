from __future__ import annotations

from dataclasses import dataclass

from ast_nodes import (
    ArrayLiteral,
    Assignment,
    ASTNode,
    BinaryExpression,
    Block,
    CallExpression,
    ExpressionStatement,
    ForStatement,
    FunctionDeclaration,
    Identifier,
    IfStatement,
    IndexExpression,
    Literal,
    Program,
    ReturnStatement,
    UnaryExpression,
    VariableDeclaration,
    WhileStatement,
)

from symbol_table import (
    ChestType,
    PrimitiveName,
    PrimitiveType,
    Scope,
    ScopeKind,
    Symbol,
    SymbolKind,
    SymbolTable,
    Type,
)

from registers import (
    ARG_REGISTERS,
    FP,
    RA,
    SP,
    TEMP_REGISTERS,
    ZERO,
)


class CodegenError(Exception):
    """
    Error de generación de ensamblador.
    """

    def __init__(self, message: str, node: ASTNode | None = None):
        if node is not None:
            message = f"Error de codegen en línea {node.line}, columna {node.column}: {message}"
        super().__init__(message)
        self.node = node


@dataclass
class TempRegister:
    name: str


class AssemblyGenerator:
    """
    Fase 4: Generador inicial de ensamblador para Craft21.

    Esta primera versión soporta:
    - funciones
    - variables locales y globales simples
    - asignaciones
    - literales enteros y hexadecimales
    - expresiones aritméticas y bit a bit
    - if / else
    - while
    - for
    - return
    - llamadas simples con summon
    """

    WORD_SIZE = 4

    def __init__(self, symbol_table: SymbolTable):
        self.symbol_table = symbol_table
        self.lines: list[str] = []

        self._label_counter = 0
        self._current_function_end_label: str | None = None
        self._current_scope: Scope = symbol_table.global_scope

        self._free_temps = [register.asm() for register in TEMP_REGISTERS]
        self._used_temps: list[str] = []

        self._used_codegen_scope_ids: set[int] = set()

    def generate(self, program: Program) -> str:
        self.lines = []

        self._emit("; ==================================================")
        self._emit("; Ensamblador generado para Craft21")
        self._emit("; Fase 4 - versión inicial")
        self._emit("; ==================================================")
        self._emit("")

        self._emit_data_section(program)
        self._emit_text_section(program)

        return self._with_instruction_addresses("\n".join(self.lines))

    # ------------------------------------------------------------
    # Secciones
    # ------------------------------------------------------------

    def _emit_data_section(self, program: Program) -> None:
        global_vars = [
            declaration
            for declaration in program.declarations
            if isinstance(declaration, VariableDeclaration)
        ]

        if not global_vars:
            return

        self._emit(".data")

        for declaration in global_vars:
            symbol = self._lookup_global_symbol(declaration.name)
            if symbol is None:
                raise CodegenError(
                    f"variable global no encontrada: {declaration.name}",
                    declaration,
                )

            address = symbol.memory_info.address
            address_comment = f" ; addr=0x{address:04X}" if address is not None else ""

            self._emit(f"{declaration.name}:{address_comment}")

            if isinstance(declaration.initializer, ArrayLiteral):
                self._emit_global_array_initializer(symbol, declaration.initializer)
                continue

            if isinstance(declaration.initializer, Literal):
                value = self._static_literal_value(declaration.initializer)
                self._emit_data_value(symbol.type, value)
                continue

            size = symbol.memory_info.size_in_bytes or self.WORD_SIZE
            self._emit(f"    .space {size}")

        self._emit("")

    def _emit_global_array_initializer(
        self,
        symbol: Symbol,
        initializer: ArrayLiteral,
    ) -> None:
        if not isinstance(symbol.type, ChestType):
            raise CodegenError(
                f"solo una variable tipo chest puede inicializarse con arreglo: {symbol.name}",
                initializer,
            )

        if len(initializer.elements) > symbol.type.size:
            raise CodegenError(
                f"demasiados elementos para {symbol.name}: esperaba máximo {symbol.type.size}",
                initializer,
            )

        for element in initializer.elements:
            if not isinstance(element, Literal):
                raise CodegenError(
                    "los inicializadores globales de chest deben ser literales",
                    element,
                )

            value = self._static_literal_value(element)
            self._emit_data_value(symbol.type.element_type, value)

        remaining = symbol.type.size - len(initializer.elements)
        if remaining > 0:
            remaining_bytes = remaining * self._type_size(symbol.type.element_type)
            self._emit(f"    .space {remaining_bytes}")


    def _static_literal_value(self, node: Literal) -> int:
        if node.literal_type not in {"int", "hex"}:
            raise CodegenError(
                "por ahora solo se soportan literales numéricos en .data",
                node,
            )

        return int(node.value)


    def _emit_data_value(self, symbol_type: Type | None, value: int) -> None:
        if isinstance(symbol_type, PrimitiveType):
            if symbol_type.name == PrimitiveName.CHAR:
                self._emit(f"    .byte {value & 0xFF}")
                return

            if symbol_type.name == PrimitiveName.UINT16:
                self._emit(f"    .half {value & 0xFFFF}")
                return

        self._emit(f"    .word {self._format_data_number(value)}")


    def _format_data_number(self, value: int) -> str:
        if value > 9:
            return f"0x{value:X}"
        return str(value)


    def _emit_text_section(self, program: Program) -> None:
        self._emit(".text")
        self._emit("")

        for declaration in program.declarations:
            if isinstance(declaration, FunctionDeclaration):
                self._generate_function(declaration)

    # ------------------------------------------------------------
    # Funciones
    # ------------------------------------------------------------

    def _generate_function(self, node: FunctionDeclaration) -> None:
        previous_scope = self._current_scope
        function_scope = self._find_child_scope(
            parent=self.symbol_table.global_scope,
            kind=ScopeKind.FUNCTION,
            name_prefix=f"function:{node.name}",
        )

        if function_scope is None:
            raise CodegenError(f"scope de función no encontrado: {node.name}", node)

        self._current_scope = function_scope
        self._current_function_end_label = self._new_label(f"{node.name}_end")

        stack_size = self._calculate_stack_size(function_scope)
        frame_size = stack_size + 8

        self._emit(f"{node.name}:")
        self._emit(f"    ; prologue")
        self._emit_add_immediate(SP.asm(), SP.asm(), -frame_size)
        self._emit(f"    sw {RA.asm()}, 0({SP.asm()})")
        self._emit(f"    sw {FP.asm()}, 4({SP.asm()})")
        self._emit_add_immediate(FP.asm(), SP.asm(), frame_size)
        self._emit("")

        self._store_incoming_arguments(node)

        self._generate_block_statements(node.body)

        self._emit(f"{self._current_function_end_label}:")
        self._emit(f"    ; epilogue")
        self._emit(f"    lw {RA.asm()}, 0({SP.asm()})")
        self._emit(f"    lw {FP.asm()}, 4({SP.asm()})")
        self._emit_add_immediate(SP.asm(), SP.asm(), frame_size)
        self._emit(f"    jalr {RA.asm()}, 0")
        self._emit("")

        self._current_function_end_label = None
        self._current_scope = previous_scope

    def _store_incoming_arguments(self, node: FunctionDeclaration) -> None:
        for index, parameter in enumerate(node.parameters):
            if index >= len(ARG_REGISTERS):
                raise CodegenError(
                    "por ahora solo se soportan hasta 6 argumentos en registros",
                    parameter,
                )

            symbol = self._lookup_visible_symbol(parameter.name)
            if symbol is None:
                raise CodegenError(f"parámetro no encontrado: {parameter.name}", parameter)

            offset = symbol.memory_info.offset
            if offset is None:
                raise CodegenError(f"parámetro sin offset de memoria: {parameter.name}", parameter)

            arg_register = ARG_REGISTERS[index].asm()
            self._emit(f"    sw {arg_register}, {offset}({FP.asm()}) ; parámetro {parameter.name}")

        if node.parameters:
            self._emit("")

    # ------------------------------------------------------------
    # Statements
    # ------------------------------------------------------------

    def _generate_block_statements(self, block: Block) -> None:
        for statement in block.statements:
            self._generate_statement(statement)

    def _generate_statement(self, node: ASTNode) -> None:
        if isinstance(node, VariableDeclaration):
            self._generate_variable_declaration(node)
            return

        if isinstance(node, Assignment):
            self._generate_assignment(node)
            return

        if isinstance(node, ExpressionStatement):
            self._generate_expression_statement(node)
            return

        if isinstance(node, ReturnStatement):
            self._generate_return(node)
            return

        if isinstance(node, IfStatement):
            self._generate_if(node)
            return

        if isinstance(node, WhileStatement):
            self._generate_while(node)
            return

        if isinstance(node, ForStatement):
            self._generate_for(node)
            return

        if isinstance(node, Block):
            self._generate_block_statements(node)
            return

        raise CodegenError("statement no soportado por codegen inicial", node)

    def _generate_expression_statement(self, node: ExpressionStatement) -> None:
        """
        Genera una expresión usada como statement.

        Caso importante:
        - summon:funcion_void(...);
        No necesita guardar ni copiar valor de retorno.
        """

        if isinstance(node.expression, CallExpression) and self._call_returns_void(node.expression):
            self._generate_void_call(node.expression)
            return

        reg = self._generate_expression(node.expression)
        self._release_temp(reg)

    def _generate_variable_declaration(self, node: VariableDeclaration) -> None:
        symbol = self._lookup_visible_symbol(node.name)
        if symbol is None:
            raise CodegenError(f"variable no encontrada en tabla de símbolos: {node.name}", node)

        if isinstance(node.initializer, ArrayLiteral):
            self._store_array_initializer(symbol, node.initializer)
            return

        if node.initializer is None:
            reg = self._acquire_temp()
            self._emit(f"    addi {reg}, {ZERO.asm()}, 0")
            self._store_symbol(symbol, reg)
            self._release_temp(reg)
            return

        reg = self._generate_expression(node.initializer)
        self._store_symbol(symbol, reg)
        self._release_temp(reg)

    def _store_array_initializer(self, symbol: Symbol, initializer: ArrayLiteral) -> None:
        if not isinstance(symbol.type, ChestType):
            raise CodegenError(
                f"solo se puede inicializar con arreglo una variable tipo chest: {symbol.name}",
                initializer,
            )

        if len(initializer.elements) > symbol.type.size:
            raise CodegenError(
                f"demasiados elementos para {symbol.name}: esperaba máximo {symbol.type.size}",
                initializer,
            )

        element_size = self._type_size(symbol.type.element_type)

        for index, element in enumerate(initializer.elements):
            value_reg = self._generate_expression(element)
            offset = index * element_size

            if symbol.memory_info.segment == "STACK":
                base_offset = symbol.memory_info.offset
                if base_offset is None:
                    raise CodegenError(f"chest local sin offset: {symbol.name}", initializer)

                self._emit(
                    f"    sw {value_reg}, {base_offset + offset}({FP.asm()}) ; {symbol.name}[{index}]"
                )

            elif symbol.memory_info.segment == "DATA":
                base_address = symbol.memory_info.address
                if base_address is None:
                    raise CodegenError(f"chest global sin dirección: {symbol.name}", initializer)

                self._emit(
                    f"    sw {value_reg}, {base_address + offset}({ZERO.asm()}) ; {symbol.name}[{index}]"
                )

            else:
                raise CodegenError(f"chest sin memoria asignada: {symbol.name}", initializer)

            self._release_temp(value_reg)

    def _generate_assignment(self, node: Assignment) -> None:
        value_reg = self._generate_expression(node.value)

        if isinstance(node.target, Identifier):
            symbol = self._lookup_visible_symbol(node.target.name)
            if symbol is None:
                raise CodegenError(f"variable no encontrada: {node.target.name}", node.target)

            self._store_symbol(symbol, value_reg)
            self._release_temp(value_reg)
            return

        if isinstance(node.target, IndexExpression):
            self._store_index_expression(node.target, value_reg)
            self._release_temp(value_reg)
            return

        raise CodegenError("lado izquierdo no soportado en asignación", node.target)

    def _generate_return(self, node: ReturnStatement) -> None:
        if self._current_function_end_label is None:
            raise CodegenError("return fuera de función", node)

        if node.value is not None:
            value_reg = self._generate_expression(node.value)
            return_reg = ARG_REGISTERS[0].asm()

            if value_reg != return_reg:
                self._emit(f"    add {return_reg}, {value_reg}, {ZERO.asm()}")

            self._release_temp(value_reg)

        self._emit(f"    jal {ZERO.asm()}, {self._current_function_end_label}")

    # ------------------------------------------------------------
    # Control de flujo
    # ------------------------------------------------------------

    def _generate_if(self, node: IfStatement) -> None:
        else_label = self._new_label("if_else")
        end_label = self._new_label("if_end")

        self._emit("")
        self._emit("    ; if")
        self._emit_branch_if_false(node.condition, else_label)

        self._generate_block_statements(node.then_branch)
        self._emit(f"    jal {ZERO.asm()}, {end_label}")

        self._emit(f"{else_label}:")
        if node.else_branch is not None:
            self._generate_block_statements(node.else_branch)

        self._emit(f"{end_label}:")
        self._emit("")

    def _generate_while(self, node: WhileStatement) -> None:
        start_label = self._new_label("while_start")
        end_label = self._new_label("while_end")

        self._emit("")
        self._emit(f"{start_label}:")
        self._emit_branch_if_false(node.condition, end_label)
        self._generate_block_statements(node.body)
        self._emit(f"    jal {ZERO.asm()}, {start_label}")
        self._emit(f"{end_label}:")
        self._emit("")

    def _generate_for(self, node: ForStatement) -> None:
        start_label = self._new_label("for_start")
        end_label = self._new_label("for_end")

        previous_scope = self._current_scope

        for_scope = self._consume_child_scope(
            parent=previous_scope,
            kind=ScopeKind.LOOP,
            name_prefix="for",
        )

        if for_scope is None:
            raise CodegenError("scope de for no encontrado", node)

        self._current_scope = for_scope

        self._emit("")
        self._emit("    ; for")

        if node.initializer is not None:
            self._generate_statement(node.initializer)

        self._emit(f"{start_label}:")

        if node.condition is not None:
            self._emit_branch_if_false(node.condition, end_label)

        self._generate_block_statements(node.body)

        if node.increment is not None:
            self._generate_statement(node.increment)

        self._emit(f"    jal {ZERO.asm()}, {start_label}")
        self._emit(f"{end_label}:")
        self._emit("")

        self._current_scope = previous_scope

    def _emit_branch_if_false(self, condition: ASTNode, false_label: str) -> None:
        if isinstance(condition, BinaryExpression) and condition.operator in {
            "==",
            "!=",
            "<",
            ">",
            "<=",
            ">=",
        }:
            left_reg = self._generate_expression(condition.left)
            right_reg = self._generate_expression(condition.right)

            op = condition.operator

            if op == "==":
                self._emit(f"    bne {left_reg}, {right_reg}, {false_label}")
            elif op == "!=":
                self._emit(f"    beq {left_reg}, {right_reg}, {false_label}")
            elif op == "<":
                self._emit(f"    bge {left_reg}, {right_reg}, {false_label}")
            elif op == ">":
                self._emit(f"    bge {right_reg}, {left_reg}, {false_label}")
            elif op == "<=":
                self._emit(f"    blt {right_reg}, {left_reg}, {false_label}")
            elif op == ">=":
                self._emit(f"    blt {left_reg}, {right_reg}, {false_label}")

            self._release_temp(left_reg)
            self._release_temp(right_reg)
            return

        condition_reg = self._generate_expression(condition)
        self._emit(f"    beq {condition_reg}, {ZERO.asm()}, {false_label}")
        self._release_temp(condition_reg)

    # ------------------------------------------------------------
    # Expresiones
    # ------------------------------------------------------------

    def _generate_expression(self, node: ASTNode) -> str:
        if isinstance(node, Literal):
            return self._generate_literal(node)

        if isinstance(node, Identifier):
            return self._generate_identifier(node)

        if isinstance(node, UnaryExpression):
            return self._generate_unary(node)

        if isinstance(node, BinaryExpression):
            return self._generate_binary(node)

        if isinstance(node, CallExpression):
            return self._generate_call(node)

        if isinstance(node, IndexExpression):
            return self._load_index_expression(node)

        if isinstance(node, Assignment):
            self._generate_assignment(node)
            result = self._acquire_temp()
            self._emit(f"    addi {result}, {ZERO.asm()}, 0 ; resultado dummy de asignación")
            return result

        if isinstance(node, ArrayLiteral):
            raise CodegenError(
                "los literales de arreglo todavía no se generan directamente en ensamblador",
                node,
            )

        raise CodegenError("expresión no soportada por codegen inicial", node)

    def _generate_literal(self, node: Literal) -> str:
        reg = self._acquire_temp()

        if node.literal_type in {"int", "hex"}:
            self._emit_load_immediate(reg, int(node.value))
            return reg

        raise CodegenError("solo se soportan literales numéricos en esta versión", node)

    def _generate_identifier(self, node: Identifier) -> str:
        symbol = self._lookup_visible_symbol(node.name)
        if symbol is None:
            raise CodegenError(f"símbolo no encontrado: {node.name}", node)

        reg = self._acquire_temp()
        self._load_symbol(symbol, reg)
        return reg

    def _generate_unary(self, node: UnaryExpression) -> str:
        operand_reg = self._generate_expression(node.operand)

        if node.operator == "-":
            result_reg = self._acquire_temp()
            self._emit(f"    sub {result_reg}, {ZERO.asm()}, {operand_reg}")
            self._release_temp(operand_reg)
            return result_reg

        if node.operator == "~":
            mask_reg = self._acquire_temp()
            result_reg = self._acquire_temp()

            self._emit_load_immediate(mask_reg, -1)
            self._emit(f"    xor {result_reg}, {operand_reg}, {mask_reg}")

            self._release_temp(mask_reg)
            self._release_temp(operand_reg)
            return result_reg

        raise CodegenError(f"operador unario no soportado: {node.operator}", node)

    def _generate_binary(self, node: BinaryExpression) -> str:
        left_reg = self._generate_expression(node.left)
        right_reg = self._generate_expression(node.right)
        result_reg = self._acquire_temp()

        op = node.operator

        if op == "<+4":
            shift_reg = self._acquire_temp()
            self._emit(f"    addi {shift_reg}, {ZERO.asm()}, 4")
            self._emit(f"    sll {result_reg}, {left_reg}, {shift_reg}")
            self._emit(f"    add {result_reg}, {result_reg}, {right_reg}")
            self._release_temp(shift_reg)
            self._release_temp(left_reg)
            self._release_temp(right_reg)
            return result_reg

        if op == ">+5":
            shift_reg = self._acquire_temp()
            self._emit(f"    addi {shift_reg}, {ZERO.asm()}, 5")
            self._emit(f"    srl {result_reg}, {left_reg}, {shift_reg}")
            self._emit(f"    add {result_reg}, {result_reg}, {right_reg}")
            self._release_temp(shift_reg)
            self._release_temp(left_reg)
            self._release_temp(right_reg)
            return result_reg

        instruction_map = {
            "+": "add",
            "-": "sub",
            "*": "mul",
            "/": "div",
            "^": "xor",
            "&": "and",
            "|": "or",
            "<<": "sll",
            ">>": "srl",
        }

        if op in instruction_map:
            instr = instruction_map[op]
            self._emit(f"    {instr} {result_reg}, {left_reg}, {right_reg}")
        elif op in {"==", "!=", "<", ">", "<=", ">="}:
            self._generate_comparison_value(node, left_reg, right_reg, result_reg)
        else:
            raise CodegenError(f"operador binario no soportado: {op}", node)

        self._release_temp(left_reg)
        self._release_temp(right_reg)
        return result_reg

    def _generate_comparison_value(
        self,
        node: BinaryExpression,
        left_reg: str,
        right_reg: str,
        result_reg: str,
    ) -> None:
        true_label = self._new_label("cmp_true")
        end_label = self._new_label("cmp_end")

        op = node.operator

        self._emit(f"    addi {result_reg}, {ZERO.asm()}, 0")

        if op == "==":
            self._emit(f"    beq {left_reg}, {right_reg}, {true_label}")
        elif op == "!=":
            self._emit(f"    bne {left_reg}, {right_reg}, {true_label}")
        elif op == "<":
            self._emit(f"    blt {left_reg}, {right_reg}, {true_label}")
        elif op == ">":
            self._emit(f"    blt {right_reg}, {left_reg}, {true_label}")
        elif op == "<=":
            false_label = self._new_label("cmp_false")
            self._emit(f"    blt {right_reg}, {left_reg}, {false_label}")
            self._emit(f"    jal {ZERO.asm()}, {true_label}")
            self._emit(f"{false_label}:")
        elif op == ">=":
            false_label = self._new_label("cmp_false")
            self._emit(f"    blt {left_reg}, {right_reg}, {false_label}")
            self._emit(f"    jal {ZERO.asm()}, {true_label}")
            self._emit(f"{false_label}:")

        self._emit(f"    jal {ZERO.asm()}, {end_label}")
        self._emit(f"{true_label}:")
        self._emit(f"    addi {result_reg}, {ZERO.asm()}, 1")
        self._emit(f"{end_label}:")

    def _generate_call(self, node: CallExpression) -> str:
        if len(node.arguments) > len(ARG_REGISTERS):
            raise CodegenError("demasiados argumentos para llamada inicial", node)

        for index, argument in enumerate(node.arguments):
            target_arg_reg = ARG_REGISTERS[index].asm()

            if isinstance(argument, Identifier):
                symbol = self._lookup_visible_symbol(argument.name)

                if symbol is not None and isinstance(symbol.type, ChestType):
                    arg_reg = self._generate_chest_base_address(symbol, argument)
                else:
                    arg_reg = self._generate_expression(argument)
            else:
                arg_reg = self._generate_expression(argument)

            if arg_reg != target_arg_reg:
                self._emit(f"    add {target_arg_reg}, {arg_reg}, {ZERO.asm()}")

            self._release_temp(arg_reg)

        if node.module_alias is not None:
            function_label = f"{node.module_alias}.{node.name}"
            self._emit(f"    ; llamada externa mediante alias {node.module_alias}")
        else:
            function_label = node.name

        self._emit(f"    jal {RA.asm()}, {function_label}")

        if self._call_returns_void(node):
            raise CodegenError(
                "una función void no puede usarse como valor en una expresión",
                node,
            )

        result_reg = self._acquire_temp()
        self._emit(f"    add {result_reg}, {ARG_REGISTERS[0].asm()}, {ZERO.asm()}")
        return result_reg

    def _generate_void_call(self, node: CallExpression) -> None:
        if len(node.arguments) > len(ARG_REGISTERS):
            raise CodegenError("demasiados argumentos para llamada inicial", node)

        for index, argument in enumerate(node.arguments):
            target_arg_reg = ARG_REGISTERS[index].asm()

            if isinstance(argument, Identifier):
                symbol = self._lookup_visible_symbol(argument.name)

                if symbol is not None and isinstance(symbol.type, ChestType):
                    arg_reg = self._generate_chest_base_address(symbol, argument)
                else:
                    arg_reg = self._generate_expression(argument)
            else:
                arg_reg = self._generate_expression(argument)

            if arg_reg != target_arg_reg:
                self._emit(f"    add {target_arg_reg}, {arg_reg}, {ZERO.asm()}")

            self._release_temp(arg_reg)

        if node.module_alias is not None:
            function_label = f"{node.module_alias}.{node.name}"
            self._emit(f"    ; llamada externa mediante alias {node.module_alias}")
        else:
            function_label = node.name

        self._emit(f"    jal {RA.asm()}, {function_label}")

    # ------------------------------------------------------------
    # Carga y almacenamiento
    # ------------------------------------------------------------

    def _load_symbol(self, symbol: Symbol, target_reg: str) -> None:
        memory = symbol.memory_info

        if memory.segment == "DATA":
            address_reg = self._acquire_temp()
            self._load_global_address(symbol, address_reg)
            self._emit(f"    lw {target_reg}, 0({address_reg}) ; {symbol.name}")
            self._release_temp(address_reg)
            return

        if memory.segment == "STACK":
            if memory.offset is None:
                raise CodegenError(f"símbolo sin offset: {symbol.name}")
            self._emit(f"    lw {target_reg}, {memory.offset}({FP.asm()}) ; {symbol.name}")
            return

        raise CodegenError(f"símbolo sin memoria asignada: {symbol.name}")

    def _store_symbol(self, symbol: Symbol, source_reg: str) -> None:
        memory = symbol.memory_info

        if memory.segment == "DATA":
            address_reg = self._acquire_temp()
            self._load_global_address(symbol, address_reg)
            self._emit(f"    sw {source_reg}, 0({address_reg}) ; {symbol.name}")
            self._release_temp(address_reg)
            return

        if memory.segment == "STACK":
            if memory.offset is None:
                raise CodegenError(f"símbolo sin offset: {symbol.name}")
            self._emit(f"    sw {source_reg}, {memory.offset}({FP.asm()}) ; {symbol.name}")
            return

        raise CodegenError(f"símbolo sin memoria asignada: {symbol.name}")

    def _load_index_expression(self, node: IndexExpression) -> str:
        address_reg = self._generate_index_address(node)
        result_reg = self._acquire_temp()

        self._emit(f"    lw {result_reg}, 0({address_reg})")
        self._release_temp(address_reg)

        return result_reg

    def _store_index_expression(self, node: IndexExpression, source_reg: str) -> None:
        address_reg = self._generate_index_address(node)
        self._emit(f"    sw {source_reg}, 0({address_reg})")
        self._release_temp(address_reg)

    def _generate_index_address(self, node: IndexExpression) -> str:
        if not isinstance(node.target, Identifier):
            raise CodegenError("por ahora solo se indexan variables tipo chest", node)

        symbol = self._lookup_visible_symbol(node.target.name)
        if symbol is None:
            raise CodegenError(f"chest no encontrado: {node.target.name}", node)

        if not isinstance(symbol.type, ChestType):
            raise CodegenError(f"'{symbol.name}' no es de tipo chest", node)

        index_reg = self._generate_expression(node.index)
        scaled_index_reg = self._scale_index_register(index_reg, symbol.type.element_type)

        base_reg = self._generate_chest_base_address(symbol, node)

        self._emit(f"    add {base_reg}, {base_reg}, {scaled_index_reg}")

        self._release_temp(index_reg)
        if scaled_index_reg != index_reg:
            self._release_temp(scaled_index_reg)

        return base_reg


    def _generate_chest_base_address(self, symbol: Symbol, node: ASTNode) -> str:
        base_reg = self._acquire_temp()

        if symbol.memory_info.segment == "STACK":
            base_offset = symbol.memory_info.offset
            if base_offset is None:
                raise CodegenError(f"chest local sin offset: {symbol.name}", node)

            if symbol.kind == SymbolKind.PARAMETER:
                self._emit(
                    f"    lw {base_reg}, {base_offset}({FP.asm()}) ; base ref {symbol.name}"
                )
            else:
                self._emit(
                    f"    addi {base_reg}, {FP.asm()}, {base_offset} ; base {symbol.name}"
                )

            return base_reg

        if symbol.memory_info.segment == "DATA":
            base_address = symbol.memory_info.address
            if base_address is None:
                raise CodegenError(f"chest global sin dirección: {symbol.name}", node)

            self._emit_load_immediate(base_reg, base_address)
            self._emit(f"    ; base {symbol.name}")
            return base_reg

        raise CodegenError(f"chest sin memoria asignada: {symbol.name}", node)

    def _scale_index_register(self, index_reg: str, element_type: Type) -> str:
        element_size = self._type_size(element_type)

        if element_size == 1:
            return index_reg

        scaled_reg = self._acquire_temp()

        if element_size == 2:
            self._emit(f"    add {scaled_reg}, {index_reg}, {index_reg}")
            return scaled_reg

        if element_size == 4:
            self._emit(f"    add {scaled_reg}, {index_reg}, {index_reg}")
            self._emit(f"    add {scaled_reg}, {scaled_reg}, {scaled_reg}")
            return scaled_reg

        self._emit_load_immediate(scaled_reg, element_size)
        self._emit(f"    mul {scaled_reg}, {index_reg}, {scaled_reg}")
        return scaled_reg

    def _calculate_index_offset(self, symbol: Symbol, node: IndexExpression) -> int:
        if not isinstance(symbol.type, ChestType):
            raise CodegenError(f"'{symbol.name}' no es de tipo chest", node)

        if not isinstance(node.index, Literal) or node.index.literal_type not in {"int", "hex"}:
            raise CodegenError(
                "esta primera versión de codegen solo soporta índices literales en chest",
                node.index,
            )

        index = int(node.index.value)
        element_size = self._type_size(symbol.type.element_type)

        return index * element_size

    # ------------------------------------------------------------
    # Utilidades
    # ------------------------------------------------------------
    def _call_returns_void(self, node: CallExpression) -> bool:
        if node.module_alias is not None:
            return False

        symbol = self.symbol_table.lookup_global(node.name)
        if symbol is None or symbol.type is None:
            return False

        return (
            isinstance(symbol.type, PrimitiveType)
            and symbol.type.name == PrimitiveName.VOID
        )

    def _load_global_address(self, symbol: Symbol, target_reg: str) -> None:
        address = symbol.memory_info.address

        if address is None:
            raise CodegenError(f"símbolo global sin dirección: {symbol.name}")

        self._emit_load_immediate(target_reg, address)

    def _emit_load_immediate(self, target_reg: str, value: int) -> None:
        if -32768 <= value <= -1:
            self._emit(f"    addiSigned {target_reg}, {ZERO.asm()}, {value}")
            return

        if 0 <= value <= 32767:
            self._emit(f"    addi {target_reg}, {ZERO.asm()}, {value}")
            return

        upper = (value >> 16) & 0xFFFF
        lower = value & 0xFFFF

        self._emit(f"    addiHIGH {target_reg}, {ZERO.asm()}, {upper}")

        if lower != 0:
            self._emit(f"    addi {target_reg}, {target_reg}, {lower}")

    def _emit_add_immediate(self, target_reg: str, base_reg: str, value: int) -> None:
        if value < 0:
            self._emit(f"    addiSigned {target_reg}, {base_reg}, {value}")
        else:
            self._emit(f"    addi {target_reg}, {base_reg}, {value}")

    def _calculate_stack_size(self, function_scope: Scope) -> int:
        max_size = 0

        def visit(scope: Scope) -> None:
            nonlocal max_size

            for symbol in scope.symbols.values():
                if symbol.memory_info.segment != "STACK":
                    continue

                offset = symbol.memory_info.offset
                size = symbol.memory_info.size_in_bytes or 0

                if offset is not None and offset < 0:
                    max_size = max(max_size, abs(offset) + size)

            for child in scope.children:
                visit(child)

        visit(function_scope)

        if max_size == 0:
            return 0

        return self._align(max_size, 4)

    def _type_size(self, symbol_type: Type | None) -> int:
        if symbol_type is None:
            return 0

        if isinstance(symbol_type, PrimitiveType):
            return {
                PrimitiveName.INT: 4,
                PrimitiveName.UINT32: 4,
                PrimitiveName.UINT16: 2,
                PrimitiveName.CHAR: 1,
                PrimitiveName.VOID: 0,
            }[symbol_type.name]

        if isinstance(symbol_type, ChestType):
            return self._type_size(symbol_type.element_type) * symbol_type.size

        return 4

    def _align(self, value: int, alignment: int) -> int:
        return ((value + alignment - 1) // alignment) * alignment

    def _lookup_global_symbol(self, name: str) -> Symbol | None:
        return self.symbol_table.global_scope.lookup_local(name)

    def _lookup_visible_symbol(self, name: str) -> Symbol | None:
        return self._current_scope.lookup(name)

    def _find_child_scope(
        self,
        parent: Scope,
        kind: ScopeKind,
        name_prefix: str,
    ) -> Scope | None:
        for child in parent.children:
            if child.kind == kind and child.name.startswith(name_prefix):
                return child
        return None

    def _acquire_temp(self) -> str:
        if not self._free_temps:
            raise CodegenError("no hay registros temporales disponibles")

        reg = self._free_temps.pop(0)
        self._used_temps.append(reg)
        return reg

    def _release_temp(self, reg: str | None) -> None:
        if reg is None:
            return

        if reg not in self._used_temps:
            return

        self._used_temps.remove(reg)
        self._free_temps.insert(0, reg)

    def _new_label(self, prefix: str) -> str:
        label = f".L_codegen_{self._label_counter}_{prefix}"
        self._label_counter += 1
        return label

    def _emit(self, line: str) -> None:
        self.lines.append(line)

    def _consume_child_scope(
        self,
        parent: Scope,
        kind: ScopeKind,
        name_prefix: str | None = None,
    ) -> Scope | None:
        """
        Busca el siguiente scope hijo disponible para codegen.

        Esto es necesario porque el análisis semántico ya creó scopes
        para for, while, if y else, pero codegen también debe entrar
        a esos scopes para encontrar variables locales como i.
        """
        for child in parent.children:
            if child.id in self._used_codegen_scope_ids:
                continue

            if child.kind != kind:
                continue

            if name_prefix is not None and not child.name.startswith(name_prefix):
                continue

            self._used_codegen_scope_ids.add(child.id)
            return child

        return None
    
    def _with_instruction_addresses(self, assembly: str) -> str:
        result: list[str] = []
        instruction_address = 0

        for line in assembly.splitlines():
            stripped = line.strip()

            if self._is_real_instruction(stripped):
                result.append(f"{line:<55} ; pc=0x{instruction_address:04X}")
                instruction_address += 4
            else:
                result.append(line)

        return "\n".join(result)


    def _is_real_instruction(self, stripped: str) -> bool:
        if not stripped:
            return False

        if stripped.startswith(";"):
            return False

        if stripped.startswith("."):
            return False

        if stripped.endswith(":"):
            return False

        mnemonic = stripped.split()[0]

        return mnemonic in {
            "add",
            "sub",
            "sll",
            "slt",
            "xor",
            "srl",
            "sra",
            "or",
            "and",
            "mul",
            "div",
            "sleep",
            "freeze",
            "addi",
            "addiHIGH",
            "addiSigned",
            "sw",
            "lw",
            "sb",
            "lb",
            "jal",
            "jalr",
            "beq",
            "bne",
            "blt",
            "bge",
            "portalv",
            "sllv",
            "slrv",
            "changev",
            "closev",
            "swv",
            "lwv",
            "addiLOWv",
            "addiHIGHv",
        }