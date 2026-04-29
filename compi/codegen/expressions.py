from __future__ import annotations

from ast_nodes import (
    ASTNode,
    ArrayLiteral,
    Assignment,
    BinaryExpression,
    CallExpression,
    Identifier,
    IndexExpression,
    Literal,
    UnaryExpression,
)

from registers import ZERO

from .errors import CodegenError


class ExpressionsMixin:
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
