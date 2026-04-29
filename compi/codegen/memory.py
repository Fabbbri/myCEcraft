from __future__ import annotations

from ast_nodes import ASTNode, Identifier, IndexExpression, Literal

from symbol_table import (
    ChestType,
    PrimitiveName,
    PrimitiveType,
    Scope,
    ScopeKind,
    Symbol,
    SymbolKind,
    Type,
)

from registers import FP

from .errors import CodegenError


class MemoryMixin:
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
                self._emit_add_immediate(
                    base_reg,
                    FP.asm(),
                    base_offset,
                )
                self._emit(f"    ; base {symbol.name}")

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
                PrimitiveName.ENDER: 4,
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
