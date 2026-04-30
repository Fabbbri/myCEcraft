from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any
import os
import re

from registers import FP


class SymbolTableError(Exception):
    """
    Excepción base para errores relacionados con la tabla de símbolos.
    """


class ScopeError(SymbolTableError):
    """
    Error relacionado con manejo de ámbitos.
    """


class DuplicateSymbolError(SymbolTableError):
    """
    Error lanzado cuando se intenta redeclarar un símbolo
    dentro del mismo scope.
    """

    def __init__(self, name: str):
        super().__init__(f"El símbolo '{name}' ya fue declarado en este ámbito.")


class SymbolNotFoundError(SymbolTableError):
    """
    Error lanzado cuando no se encuentra un símbolo.
    """

    def __init__(self, name: str):
        super().__init__(f"El símbolo '{name}' no existe en ningún ámbito visible.")


class SymbolKind(Enum):
    """
    Clasifica qué tipo de entidad semántica representa un símbolo.
    """

    VARIABLE = auto()
    FUNCTION = auto()
    PARAMETER = auto()
    MODULE_ALIAS = auto()
    LABEL = auto()


class ScopeKind(Enum):
    """
    Clasifica el tipo de ámbito.
    """

    GLOBAL = auto()
    FUNCTION = auto()
    BLOCK = auto()
    LOOP = auto()
    CONDITIONAL = auto()
    MODULE = auto()


class TypeKind(Enum):
    """
    Clasifica los tipos del lenguaje.
    """

    PRIMITIVE = auto()
    POINTER = auto()
    CHEST = auto()


class PrimitiveName(Enum):
    """
    Tipos primitivos soportados actualmente por el lenguaje.
    """

    INT = "int"
    UINT32 = "uint32"
    UINT16 = "uint16"
    CHAR = "char"
    VOID = "void"
    ENDER = "ender"


@dataclass(frozen=True)
class Type:
    """
    Clase base para los tipos del lenguaje.
    """

    kind: TypeKind

    def describe(self) -> str:
        raise NotImplementedError


@dataclass(frozen=True)
class PrimitiveType(Type):
    """
    Representa un tipo primitivo.
    """

    name: PrimitiveName

    def __init__(self, name: PrimitiveName):
        object.__setattr__(self, "kind", TypeKind.PRIMITIVE)
        object.__setattr__(self, "name", name)

    def describe(self) -> str:
        return self.name.value


@dataclass(frozen=True)
class PointerType(Type):
    """
    Representa pointer o pointer[<tipo_base>].
    """

    base_type: Type | None

    def __init__(self, base_type: Type | None = None):
        object.__setattr__(self, "kind", TypeKind.POINTER)
        object.__setattr__(self, "base_type", base_type)

    def describe(self) -> str:
        if self.base_type is None:
            return "pointer"
        return f"pointer[{self.base_type.describe()}]"


@dataclass(frozen=True)
class ChestType(Type):
    """
    Representa chest[<tipo_base>, <tamaño>].
    """

    element_type: Type
    size: int

    def __init__(self, element_type: Type, size: int):
        if size <= 0:
            raise ValueError("El tamaño de un chest debe ser mayor que 0.")

        object.__setattr__(self, "kind", TypeKind.CHEST)
        object.__setattr__(self, "element_type", element_type)
        object.__setattr__(self, "size", size)

    def describe(self) -> str:
        return f"chest[{self.element_type.describe()}, {self.size}]"


@dataclass
class MemoryInfo:
    """
    Información reservada para fases futuras del compilador.
    Por ahora puede quedar sin resolver.
    """

    segment: str | None = None
    address: int | None = None
    offset: int | None = None
    size_in_bytes: int | None = None
    resolved: bool = False


@dataclass
class Symbol:
    """
    Entrada individual de la tabla de símbolos.
    """

    name: str
    kind: SymbolKind
    type: Type | None
    decl_file: str = "<input>"
    decl_line: int = 0
    decl_column: int = 0
    is_defined: bool = True
    scope_id: int | None = None
    memory_info: MemoryInfo = field(default_factory=MemoryInfo)
    metadata: dict[str, Any] = field(default_factory=dict)

    def short_repr(self) -> str:
        type_repr = self.type.describe() if self.type is not None else "None"
        return (
            f"Symbol(name={self.name!r}, kind={self.kind.name}, "
            f"type={type_repr}, scope_id={self.scope_id})"
        )


@dataclass
class Scope:
    """
    Representa un ámbito. Cada scope conoce su padre, sus hijos y los símbolos
    declarados localmente.
    """

    id: int
    name: str
    kind: ScopeKind
    parent: Scope | None = None
    level: int = 0
    symbols: dict[str, Symbol] = field(default_factory=dict)
    children: list[Scope] = field(default_factory=list)

    def define(self, symbol: Symbol) -> None:
        """
        Declara un símbolo localmente.
        """
        if symbol.name in self.symbols:
            raise DuplicateSymbolError(symbol.name)

        symbol.scope_id = self.id
        self.symbols[symbol.name] = symbol

    def lookup_local(self, name: str) -> Symbol | None:
        """
        Busca un símbolo solamente en el ámbito actual.
        """
        return self.symbols.get(name)

    def lookup(self, name: str) -> Symbol | None:
        """
        Busca un símbolo en este ámbito y luego en la cadena de padres.
        """
        current: Scope | None = self

        while current is not None:
            symbol = current.lookup_local(name)
            if symbol is not None:
                return symbol
            current = current.parent

        return None


class SymbolTable:
    """
    Administrador principal de ámbitos y símbolos.
    """

    def __init__(self) -> None:
        self._next_scope_id = 1

        self.global_scope = Scope(
            id=0,
            name="global",
            kind=ScopeKind.GLOBAL,
            parent=None,
            level=0,
        )

        self.current_scope = self.global_scope
        self.all_scopes: list[Scope] = [self.global_scope]
        self.errors: list[str] = []

    def _generate_scope_id(self) -> int:
        scope_id = self._next_scope_id
        self._next_scope_id += 1
        return scope_id

    def enter_scope(self, name: str, kind: ScopeKind) -> Scope:
        """
        Crea un nuevo scope hijo y lo convierte en el scope actual.
        """
        new_scope = Scope(
            id=self._generate_scope_id(),
            name=name,
            kind=kind,
            parent=self.current_scope,
            level=self.current_scope.level + 1,
        )

        self.current_scope.children.append(new_scope)
        self.all_scopes.append(new_scope)
        self.current_scope = new_scope
        return new_scope

    def exit_scope(self) -> Scope:
        """
        Sale del ámbito actual y regresa al padre.
        """
        if self.current_scope.parent is None:
            raise ScopeError("No se puede salir del ámbito global.")

        previous_scope = self.current_scope
        self.current_scope = self.current_scope.parent
        return previous_scope

    def define(self, symbol: Symbol) -> None:
        """
        Declara un símbolo en el ámbito actual.
        """
        self.current_scope.define(symbol)

    def define_variable(
        self,
        name: str,
        symbol_type: Type,
        decl_file: str = "<input>",
        decl_line: int = 0,
        decl_column: int = 0,
        metadata: dict[str, Any] | None = None,
    ) -> Symbol:
        symbol = Symbol(
            name=name,
            kind=SymbolKind.VARIABLE,
            type=symbol_type,
            decl_file=decl_file,
            decl_line=decl_line,
            decl_column=decl_column,
            metadata=metadata or {},
        )
        self.define(symbol)
        return symbol

    def define_parameter(
        self,
        name: str,
        symbol_type: Type,
        decl_file: str = "<input>",
        decl_line: int = 0,
        decl_column: int = 0,
        metadata: dict[str, Any] | None = None,
    ) -> Symbol:
        symbol = Symbol(
            name=name,
            kind=SymbolKind.PARAMETER,
            type=symbol_type,
            decl_file=decl_file,
            decl_line=decl_line,
            decl_column=decl_column,
            metadata=metadata or {},
        )
        self.define(symbol)
        return symbol

    def define_function(
        self,
        name: str,
        return_type: Type,
        decl_file: str = "<input>",
        decl_line: int = 0,
        decl_column: int = 0,
        is_defined: bool = True,
        parameters: list[Type] | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> Symbol:
        """
        Registra una función. La lista de parámetros aquí puede ser solamente
        la firma semántica, no los símbolos parámetro todavía.
        """
        merged_metadata = {
            "parameters": parameters or [],
            **(metadata or {}),
        }

        symbol = Symbol(
            name=name,
            kind=SymbolKind.FUNCTION,
            type=return_type,
            decl_file=decl_file,
            decl_line=decl_line,
            decl_column=decl_column,
            is_defined=is_defined,
            metadata=merged_metadata,
        )
        self.define(symbol)
        return symbol

    def define_module_alias(
        self,
        alias: str,
        module_name: str,
        decl_file: str = "<input>",
        decl_line: int = 0,
        decl_column: int = 0,
        metadata: dict[str, Any] | None = None,
    ) -> Symbol:
        merged_metadata = {
            "module_name": module_name,
            **(metadata or {}),
        }

        symbol = Symbol(
            name=alias,
            kind=SymbolKind.MODULE_ALIAS,
            type=None,
            decl_file=decl_file,
            decl_line=decl_line,
            decl_column=decl_column,
            metadata=merged_metadata,
        )
        self.define(symbol)
        return symbol

    def define_label(
        self,
        name: str,
        decl_file: str = "<input>",
        decl_line: int = 0,
        decl_column: int = 0,
        metadata: dict[str, Any] | None = None,
    ) -> Symbol:
        symbol = Symbol(
            name=name,
            kind=SymbolKind.LABEL,
            type=None,
            decl_file=decl_file,
            decl_line=decl_line,
            decl_column=decl_column,
            metadata=metadata or {},
        )
        self.define(symbol)
        return symbol

    def lookup_local(self, name: str) -> Symbol | None:
        """
        Busca en el scope actual únicamente.
        """
        return self.current_scope.lookup_local(name)

    def lookup(self, name: str) -> Symbol | None:
        """
        Busca desde el scope actual hacia arriba.
        """
        return self.current_scope.lookup(name)

    def require(self, name: str) -> Symbol:
        """
        Igual que lookup, pero falla si no existe.
        """
        symbol = self.lookup(name)
        if symbol is None:
            raise SymbolNotFoundError(name)
        return symbol

    def lookup_global(self, name: str) -> Symbol | None:
        """
        Busca únicamente en el ámbito global.
        """
        return self.global_scope.lookup_local(name)

    def dump(self) -> str:
        """
        Retorna una representación legible de toda la jerarquía de scopes.
        """
        lines: list[str] = []
        self._dump_scope(self.global_scope, lines)
        return "\n".join(lines)

    def _dump_scope(self, scope: Scope, lines: list[str]) -> None:
        indent = "  " * scope.level
        lines.append(
            f"{indent}Scope(id={scope.id}, name={scope.name!r}, kind={scope.kind.name})"
        )

        if scope.symbols:
            frame_size = self._find_enclosing_frame_size(scope)
            rows = [
                self._format_symbol_row(symbol, frame_size)
                for symbol in scope.symbols.values()
            ]
            header_cells = [
                "name",
                "kind",
                "type",
                "decl",
                "seg",
                "addr",
                "off",
                "size",
                "res",
            ]
            widths = self._column_widths([header_cells, *rows])
            header = self._format_row(header_cells, widths)
            lines.append(f"{indent}  {header}")
            lines.append(f"{indent}  {self._format_row(['-' * w for w in widths], widths)}")
            for row in rows:
                lines.append(f"{indent}  {self._format_row(row, widths)}")

        for child in scope.children:
            self._dump_scope(child, lines)

    def _format_symbol_row(
        self,
        symbol: Symbol,
        frame_size: int | None,
    ) -> list[str]:
        type_repr = symbol.type.describe() if symbol.type is not None else "None"
        decl = f"{self._short_path(symbol.decl_file)}:{symbol.decl_line}:{symbol.decl_column}"
        memory = symbol.memory_info
        segment = memory.segment or "-"
        if memory.segment == "STACK" and memory.offset is not None:
            if frame_size is not None:
                address = f"0x{frame_size + memory.offset:04X}"
            else:
                base = FP.asm()
                address = f"{base}{memory.offset:+}"
        else:
            address = f"0x{memory.address:04X}" if memory.address is not None else "-"

        offset = f"{memory.offset:+}" if memory.offset is not None else "-"
        size = str(memory.size_in_bytes) if memory.size_in_bytes is not None else "-"
        resolved = "yes" if memory.resolved else "no"
        return [
            symbol.name,
            symbol.kind.name,
            type_repr,
            decl,
            segment,
            address,
            offset,
            size,
            resolved,
        ]

    def _column_widths(self, rows: list[list[str]]) -> list[int]:
        widths = [0] * len(rows[0])
        for row in rows:
            for index, value in enumerate(row):
                widths[index] = max(widths[index], len(value))
        return widths

    def _format_row(self, row: list[str], widths: list[int]) -> str:
        return "  ".join(value.ljust(widths[index]) for index, value in enumerate(row))

    def _short_path(self, path: str) -> str:
        if not path:
            return "<input>"
        return os.path.basename(path)

    def _find_enclosing_frame_size(self, scope: Scope) -> int | None:
        current: Scope | None = scope
        while current is not None:
            if current.kind == ScopeKind.FUNCTION:
                max_size = 0

                def visit(node: Scope) -> None:
                    nonlocal max_size
                    for symbol in node.symbols.values():
                        memory = symbol.memory_info
                        if memory.segment != "STACK":
                            continue
                        if memory.offset is None or memory.offset >= 0:
                            continue
                        size = memory.size_in_bytes or 0
                        max_size = max(max_size, abs(memory.offset) + size)
                    for child in node.children:
                        visit(child)

                visit(current)
                aligned = ((max_size + 4 - 1) // 4) * 4
                return aligned + 8
            current = current.parent
        return None

    def _format_memory(self, memory: MemoryInfo) -> str:
        if memory.segment is None:
            return ""

        parts = [f" segment={memory.segment}"]
        if memory.address is not None:
            parts.append(f"addr=0x{memory.address:04X}")
        if memory.offset is not None:
            parts.append(f"offset={memory.offset:+}")
        if memory.size_in_bytes is not None:
            parts.append(f"size={memory.size_in_bytes}")
        if not memory.resolved:
            parts.append("unresolved")

        return " [" + ", ".join(parts) + "]"


# --------------------------------------------------------------------
# Helpers convenientes para construir tipos
# --------------------------------------------------------------------

def int_type() -> PrimitiveType:
    return PrimitiveType(PrimitiveName.INT)


def uint32_type() -> PrimitiveType:
    return PrimitiveType(PrimitiveName.UINT32)


def uint16_type() -> PrimitiveType:
    return PrimitiveType(PrimitiveName.UINT16)


def char_type() -> PrimitiveType:
    return PrimitiveType(PrimitiveName.CHAR)


def void_type() -> PrimitiveType:
    return PrimitiveType(PrimitiveName.VOID)


# --------------------------------------------------------------------
# Ejemplo de uso manual
# --------------------------------------------------------------------

if __name__ == "__main__":
    table = SymbolTable()

    # Globales
    table.define_function(
        name="suma",
        return_type=int_type(),
        decl_file="main.craft",
        decl_line=1,
        decl_column=1,
        parameters=[int_type(), int_type()],
        metadata={"inline": False},
    )

    table.define_module_alias(
        alias="m",
        module_name="matematica",
        decl_file="main.craft",
        decl_line=2,
        decl_column=1,
    )

    table.define_variable(
        name="global_counter",
        symbol_type=uint32_type(),
        decl_file="main.craft",
        decl_line=3,
        decl_column=1,
    )

    # Scope de función
    table.enter_scope("function:suma", ScopeKind.FUNCTION)

    table.define_parameter(
        name="a",
        symbol_type=int_type(),
        decl_file="main.craft",
        decl_line=1,
        decl_column=16,
        metadata={"position": 0},
    )

    table.define_parameter(
        name="b",
        symbol_type=int_type(),
        decl_file="main.craft",
        decl_line=1,
        decl_column=23,
        metadata={"position": 1},
    )

    table.define_variable(
        name="resultado",
        symbol_type=int_type(),
        decl_file="main.craft",
        decl_line=2,
        decl_column=5,
    )

    # Scope interno
    table.enter_scope("block:if", ScopeKind.CONDITIONAL)
    table.define_variable(
        name="temp",
        symbol_type=PointerType(char_type()),
        decl_file="main.craft",
        decl_line=4,
        decl_column=9,
    )
    table.exit_scope()

    table.exit_scope()

    # Simula una asignacion de memoria para pruebas del backend.
    # Convenciones de ejemplo:
    # - Variables globales: segmento DATA desde 0x1000.
    # - Parametros/variables locales: segmento STACK con offsets negativos.
    # - Funciones: segmento TEXT con direccion de entrada.
    size_map = {
        PrimitiveName.INT: 4,
        PrimitiveName.UINT32: 4,
        PrimitiveName.UINT16: 2,
        PrimitiveName.CHAR: 1,
        PrimitiveName.VOID: 0,
        PrimitiveName.ENDER: 4,
    }

    def type_size(t: Type | None) -> int:
        if t is None:
            return 0
        if isinstance(t, PrimitiveType):
            return size_map[t.name]
        if isinstance(t, PointerType):
            return 4
        if isinstance(t, ChestType):
            return type_size(t.element_type) * t.size
        return 0

    next_global_address = 0x1000
    next_text_address = 0x2000

    for symbol in table.global_scope.symbols.values():
        if symbol.kind == SymbolKind.VARIABLE:
            symbol.memory_info.segment = "DATA"
            symbol.memory_info.address = next_global_address
            symbol.memory_info.offset = None
            symbol.memory_info.size_in_bytes = type_size(symbol.type)
            symbol.memory_info.resolved = True
            next_global_address += symbol.memory_info.size_in_bytes or 0
        elif symbol.kind == SymbolKind.FUNCTION:
            symbol.memory_info.segment = "TEXT"
            symbol.memory_info.address = next_text_address
            symbol.memory_info.offset = None
            symbol.memory_info.size_in_bytes = 0
            symbol.memory_info.resolved = True
            next_text_address += 0x20

    for scope in table.all_scopes:
        if scope.kind != ScopeKind.FUNCTION:
            continue

        next_param_offset = 8
        next_local_offset = -4

        for symbol in scope.symbols.values():
            if symbol.kind == SymbolKind.PARAMETER:
                symbol.memory_info.segment = "STACK"
                symbol.memory_info.address = None
                symbol.memory_info.offset = next_param_offset
                symbol.memory_info.size_in_bytes = type_size(symbol.type)
                symbol.memory_info.resolved = True
                next_param_offset += symbol.memory_info.size_in_bytes or 0
            elif symbol.kind == SymbolKind.VARIABLE:
                symbol.memory_info.segment = "STACK"
                symbol.memory_info.address = None
                symbol.memory_info.offset = next_local_offset
                symbol.memory_info.size_in_bytes = type_size(symbol.type)
                symbol.memory_info.resolved = True
                next_local_offset -= symbol.memory_info.size_in_bytes or 0

        for child in scope.children:
            for symbol in child.symbols.values():
                if symbol.kind == SymbolKind.VARIABLE:
                    symbol.memory_info.segment = "STACK"
                    symbol.memory_info.address = None
                    symbol.memory_info.offset = next_local_offset
                    symbol.memory_info.size_in_bytes = type_size(symbol.type)
                    symbol.memory_info.resolved = True
                    next_local_offset -= symbol.memory_info.size_in_bytes or 0

    print(table.dump())

    print("\n=== Memory Map (simulada) ===")
    for scope in table.all_scopes:
        for symbol in scope.symbols.values():
            if not symbol.memory_info.resolved:
                continue
            print(
                f"{symbol.name:14} | kind={symbol.kind.name:10} | "
                f"seg={symbol.memory_info.segment:5} | "
                f"addr={symbol.memory_info.address} | "
                f"off={symbol.memory_info.offset} | "
                f"size={symbol.memory_info.size_in_bytes}"
            )
