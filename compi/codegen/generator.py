from __future__ import annotations

from dataclasses import dataclass

from ast_nodes import ArrayLiteral, FunctionDeclaration, Program, VariableDeclaration

from symbol_table import Scope, ScopeKind, SymbolTable

from registers import FP, RA, SP, TEMP_REGISTERS

from .calls import CallsMixin
from .data_section import DataSectionMixin
from .emit import EmitMixin
from .errors import CodegenError
from .expressions import ExpressionsMixin
from .labels import LabelsMixin
from .memory import MemoryMixin
from .statements import StatementsMixin


@dataclass
class TempRegister:
    name: str


class AssemblyGenerator(
    EmitMixin,
    LabelsMixin,
    DataSectionMixin,
    MemoryMixin,
    ExpressionsMixin,
    CallsMixin,
    StatementsMixin,
):
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

    def _emit_text_section(self, program: Program) -> None:
        self._emit(".text")
        self._emit("")

        self._emit_global_vault_initializers(program)

        functions = [
            declaration
            for declaration in program.declarations
            if isinstance(declaration, FunctionDeclaration)
        ]

        for declaration in sorted(functions, key=lambda function: function.name != "main"):
            self._generate_function(declaration)

    def _emit_global_vault_initializers(self, program: Program) -> None:
        for declaration in program.declarations:
            if not isinstance(declaration, VariableDeclaration):
                continue

            symbol = self._lookup_global_symbol(declaration.name)
            if symbol is None or symbol.memory_info.segment != "VAULT":
                continue

            if not isinstance(declaration.initializer, ArrayLiteral):
                raise CodegenError(
                    "las variables globales chest[ender, N] deben inicializarse con arreglo",
                    declaration,
                )

            self._emit(f"    ; inicializacion vault global {declaration.name}")
            self._generate_variable_declaration(declaration)
            self._emit("")

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
