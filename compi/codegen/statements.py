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
    Literal,
    ReturnStatement,
    UnaryExpression,
    VariableDeclaration,
    VaultInstruction,
    WhileStatement,
)

from symbol_table import ChestType, PrimitiveName, PrimitiveType, ScopeKind, Symbol

from registers import ARG_REGISTERS, FP, ZERO

from .errors import CodegenError


class StatementsMixin:
    def _semantic_label(self, node: ASTNode, role: str) -> str | None:
        label_map = getattr(node, "_semantic_labels", None)
        if isinstance(label_map, dict):
            value = label_map.get(role)
            if isinstance(value, str) and value:
                return value
        return None

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

        if isinstance(node, VaultInstruction):
            self._generate_vault_instruction(node)
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

    def _generate_vault_instruction(self, node: VaultInstruction) -> None:
        mnemonic_map = {
            "enderopen": "portalv",
            "enderclose": "closev",
            "enderload": "lwv",
            "enderstore": "swv",
            "enderkey": "changev",
            "enderlow": "addiLOWv",
            "enderhigh": "addiHIGHv",
        }

        mnemonic = mnemonic_map.get(node.keyword)
        if mnemonic is None:
            raise CodegenError(f"instruccion de boveda desconocida: {node.keyword}", node)

        operands = list(node.operands)
        if node.keyword == "enderopen" and len(operands) == 2:
            operands.append("0")

        suffix = f" {', '.join(operands)}" if operands else ""
        self._emit(f"    {mnemonic}{suffix} ; {node.keyword}")

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
            if symbol.memory_info.segment == "VAULT":
                value = self._static_ender_value(element)
                offset = index * element_size
                low = value & 0xFFFF
                high = (value >> 16) & 0xFFFF

                self._emit(f"    addiLOWv v1, v0, {low} ; {symbol.name}[{index}] low")
                self._emit(f"    addiHIGHv v1, v1, {high} ; {symbol.name}[{index}] high")
                self._emit(f"    swv v1, {offset}(v0) ; {symbol.name}[{index}]")
                continue

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

    def _static_ender_value(self, node: ASTNode) -> int:
        if isinstance(node, Literal) and node.literal_type in {"int", "hex"}:
            return int(node.value) & 0xFFFFFFFF

        if (
            isinstance(node, UnaryExpression)
            and node.operator == "-"
            and isinstance(node.operand, Literal)
            and node.operand.literal_type in {"int", "hex"}
        ):
            return (-int(node.operand.value)) & 0xFFFFFFFF

        raise CodegenError(
            "los inicializadores de chest[ender, N] deben ser literales numericos",
            node,
        )

    def _is_ender_chest(self, symbol: Symbol) -> bool:
        return (
            isinstance(symbol.type, ChestType)
            and isinstance(symbol.type.element_type, PrimitiveType)
            and symbol.type.element_type.name == PrimitiveName.ENDER
        )

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
        else_label = self._semantic_label(node, "if_else") or self._new_label("if_else")
        end_label = self._semantic_label(node, "if_end") or self._new_label("if_end")

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
        start_label = self._semantic_label(node, "while_start") or self._new_label("while_start")
        end_label = self._semantic_label(node, "while_end") or self._new_label("while_end")

        self._emit("")
        self._emit(f"{start_label}:")
        self._emit_branch_if_false(node.condition, end_label)
        self._generate_block_statements(node.body)
        self._emit(f"    jal {ZERO.asm()}, {start_label}")
        self._emit(f"{end_label}:")
        self._emit("")

    def _generate_for(self, node: ForStatement) -> None:
        start_label = self._semantic_label(node, "for_start") or self._new_label("for_start")
        end_label = self._semantic_label(node, "for_end") or self._new_label("for_end")

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
