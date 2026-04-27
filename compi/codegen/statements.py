from __future__ import annotations

from ast_nodes import (
    ASTNode,
    ArrayLiteral,
    Assignment,
    BinaryExpression,
    Block,
    CallExpression,
    ExpressionStatement,
    ForStatement,
    Identifier,
    IfStatement,
    IndexExpression,
    ReturnStatement,
    VariableDeclaration,
    WhileStatement,
)

from symbol_table import ChestType, ScopeKind, Symbol

from registers import ARG_REGISTERS, FP, ZERO

from .errors import CodegenError


class StatementsMixin:
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
                address_reg = self._acquire_temp()

                base_address = symbol.memory_info.address
                if base_address is None:
                    raise CodegenError(f"chest global sin dirección: {symbol.name}", initializer)

                self._emit_load_immediate(address_reg, base_address + offset)
                self._emit(
                    f"    sw {value_reg}, 0({address_reg}) ; {symbol.name}[{index}]"
                )

                self._release_temp(address_reg)
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
