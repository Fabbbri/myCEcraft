from __future__ import annotations

from ast_nodes import ArrayLiteral, Literal, Program, VariableDeclaration

from symbol_table import ChestType, PrimitiveName, PrimitiveType, Symbol, Type

from .errors import CodegenError


class DataSectionMixin:
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
