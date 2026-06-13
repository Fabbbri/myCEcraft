from __future__ import annotations

import ast as pyast
import re
from dataclasses import dataclass
from typing import Any

from IR.instructions import (
    IRAssign,
    IRArrayAssign,
    IRBinOp,
    IRCall,
    IRCommit,
    IRInstruction,
    IRJump,
    IRJumpIfFalse,
    IRLabel,
    IRReturn,
    IRUnaryOp,
    IRVaultInstruction,
)
from IR.ir_analysis import defs, uses
from registers import ARG_REGISTERS, FP, RA, SP, TEMP_REGISTERS, V0, ZERO
from symbol_table import (
    ChestType,
    PointerType,
    PrimitiveName,
    PrimitiveType,
    Scope,
    ScopeKind,
    Symbol,
    SymbolKind,
    SymbolTable,
    Type,
)

from .emit import EmitMixin
from .errors import CodegenError


VIRTUAL_RE = re.compile(
    r"^(?:t\d+|[A-Za-z_][A-Za-z0-9_]*__v\d+)(?:__x(?P<hint>\d+))?$"
)
NAME_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*\b")


@dataclass
class _FunctionIR:
    label: IRLabel
    instructions: list[IRInstruction]


class IRLoweringBackend(EmitMixin):
    """Internal lowering implementation from optimized IR to Craft21 assembly."""

    WORD_SIZE = 4
    INITIAL_STACK_POINTER = 0x7FF0

    def __init__(self, symbol_table: SymbolTable):
        self.symbol_table = symbol_table
        self.lines: list[str] = []
        self._label_counter = 0
        self._free_temps = [register.asm() for register in TEMP_REGISTERS]
        self._used_temps: list[str] = []
        self._function_scope: Scope | None = None
        self._symbols: dict[str, Symbol] = {}
        self._temp_offsets: dict[str, int] = {}
        self._register_assignments: dict[str, str] = {}
        self._register_valid: set[str] = set()
        self._register_dirty: set[str] = set()
        self._function_end_label: str | None = None

    def generate(self, instructions: list[IRInstruction]) -> str:
        self.lines = []
        globals_ir, functions = self._split_module(instructions)
        functions.sort(key=lambda function: function.label.name != "main")

        self._emit("; ==================================================")
        self._emit("; Ensamblador generado directamente desde IR")
        self._emit("; Las optimizaciones IR son la fuente del ejecutable")
        self._emit("; ==================================================")
        self._emit("")

        self._emit_data_section(globals_ir)
        self._emit(".text")
        self._emit("")

        entry = next((function for function in functions if function.label.is_entry_point), None)
        if entry is not None:
            self._emit_enter_craft_world_preamble()

        self._emit_global_vault_initializers(globals_ir)

        for function in functions:
            self._emit_function(function)

        if entry is None:
            self._emit("    ; final de programa")
            self._emit("    freeze")

        return self._with_instruction_addresses("\n".join(self.lines))

    def _split_module(
        self,
        instructions: list[IRInstruction],
    ) -> tuple[list[IRInstruction], list[_FunctionIR]]:
        globals_ir: list[IRInstruction] = []
        functions: list[_FunctionIR] = []
        current: _FunctionIR | None = None

        for instruction in instructions:
            if isinstance(instruction, IRLabel) and instruction.is_function:
                current = _FunctionIR(instruction, [])
                functions.append(current)
                continue
            if current is None:
                globals_ir.append(instruction)
            else:
                current.instructions.append(instruction)

        return globals_ir, functions

    def _emit_data_section(self, globals_ir: list[IRInstruction]) -> None:
        initializers = {
            instruction.result: instruction
            for instruction in globals_ir
            if isinstance(instruction, (IRAssign, IRArrayAssign))
        }
        globals_data = [
            symbol
            for symbol in self.symbol_table.global_scope.symbols.values()
            if symbol.kind == SymbolKind.VARIABLE
            and symbol.memory_info.segment == "DATA"
        ]
        if not globals_data:
            return

        self._emit(".data")
        for symbol in globals_data:
            address = symbol.memory_info.address
            self._emit(f"{symbol.name}: ; addr=0x{address:04X}")
            initializer = initializers.get(symbol.name)
            if isinstance(initializer, IRArrayAssign):
                element_type = (
                    symbol.type.element_type
                    if isinstance(symbol.type, ChestType)
                    else symbol.type
                )
                for element in initializer.elements:
                    if not isinstance(element, int):
                        raise CodegenError(
                            f"inicializador global no constante: {symbol.name}"
                        )
                    self._emit_data_value(element_type, element)
                if isinstance(symbol.type, ChestType):
                    remaining = symbol.type.size - len(initializer.elements)
                    if remaining > 0:
                        self._emit(
                            f"    .space {remaining * self._type_size(symbol.type.element_type)}"
                        )
                continue

            if isinstance(initializer, IRAssign) and isinstance(initializer.source, int):
                self._emit_data_value(symbol.type, initializer.source)
                continue

            self._emit(f"    .space {symbol.memory_info.size_in_bytes or self.WORD_SIZE}")
        self._emit("")

    def _emit_data_value(self, symbol_type: Type | None, value: int) -> None:
        if isinstance(symbol_type, PrimitiveType):
            if symbol_type.name == PrimitiveName.CHAR:
                self._emit(f"    .byte {value & 0xFF}")
                return
            if symbol_type.name == PrimitiveName.UINT16:
                self._emit(f"    .half {value & 0xFFFF}")
                return
        formatted = f"0x{value:X}" if value > 9 else str(value)
        self._emit(f"    .word {formatted}")

    def _emit_enter_craft_world_preamble(self) -> None:
        end_label = self._new_label("enderExit")
        self._emit("    ; @EnterCraftWorld")
        self._emit(f"    portalv x0, x0, {end_label}")
        self._emit("    lwv v0, 0(v0)")
        self._emit("    closev ; cerrar Secure Mode despues del bootstrap")
        self._emit(f"{end_label}:")
        self._emit("")

    def _emit_global_vault_initializers(self, globals_ir: list[IRInstruction]) -> None:
        for instruction in globals_ir:
            if not isinstance(instruction, IRArrayAssign):
                continue
            symbol = self.symbol_table.lookup_global(instruction.result)
            if symbol is None or symbol.memory_info.segment != "VAULT":
                continue
            self._emit_array_initializer(symbol, instruction.elements)
            self._emit("")

    def _emit_function(self, function: _FunctionIR) -> None:
        function_scope = self._function_scope_for(function.label.name)
        if function_scope is None:
            raise CodegenError(f"scope de funcion no encontrado: {function.label.name}")

        self._function_scope = function_scope
        self._symbols = self._collect_symbols(function_scope)
        self._temp_offsets = self._allocate_temp_slots(function.instructions, function_scope)
        self._register_assignments = self._allocate_registers(function.instructions)
        reserved_registers = set(self._register_assignments.values())
        self._free_temps = [
            register.asm()
            for register in TEMP_REGISTERS
            if register.asm() not in reserved_registers
        ]
        self._used_temps = []
        self._register_valid = set()
        self._register_dirty = set()
        self._function_end_label = self._new_label(f"{function.label.name}_end")
        local_size = self._required_local_size(function_scope, self._temp_offsets)
        frame_size = local_size + 8

        self._emit(f"{function.label.name}:")
        if function.label.name == "main":
            self._emit_stack_pointer_bootstrap()
        self._emit("    ; prologue")
        self._emit_add_immediate(SP.asm(), SP.asm(), -frame_size)
        self._emit(f"    sw {RA.asm()}, 0({SP.asm()})")
        self._emit(f"    sw {FP.asm()}, 4({SP.asm()})")
        self._emit_add_immediate(FP.asm(), SP.asm(), frame_size)
        self._emit("")

        self._store_incoming_arguments(function_scope)
        self._emit_ir_instructions(function.instructions)

        self._emit(f"{self._function_end_label}:")
        self._emit("    ; epilogue")
        if function.label.is_entry_point:
            self._emit(f"    lw {FP.asm()}, 4({SP.asm()})")
            self._emit_add_immediate(SP.asm(), SP.asm(), frame_size)
            self._emit("    freeze")
        else:
            self._emit(f"    lw {RA.asm()}, 0({SP.asm()})")
            self._emit(f"    lw {FP.asm()}, 4({SP.asm()})")
            self._emit_add_immediate(SP.asm(), SP.asm(), frame_size)
            self._emit(f"    jalr {RA.asm()}, 0")
        self._emit("")

        self._function_scope = None
        self._symbols = {}
        self._temp_offsets = {}
        self._register_assignments = {}
        self._register_valid = set()
        self._register_dirty = set()
        self._free_temps = [register.asm() for register in TEMP_REGISTERS]
        self._used_temps = []
        self._function_end_label = None

    def _emit_ir_instructions(self, instructions: list[IRInstruction]) -> None:
        index = 0
        while index < len(instructions):
            instruction = instructions[index]
            next_instruction = (
                instructions[index + 1]
                if index + 1 < len(instructions)
                else None
            )

            if (
                isinstance(instruction, (IRBinOp, IRUnaryOp))
                and isinstance(next_instruction, IRAssign)
                and next_instruction.source == instruction.result
                and self._is_simple_name(next_instruction.result)
            ):
                if isinstance(instruction, IRBinOp):
                    self._emit_binop(
                        IRBinOp(
                            instruction.op,
                            instruction.left,
                            instruction.right,
                            next_instruction.result,
                        )
                    )
                else:
                    self._emit_unary(
                        IRUnaryOp(
                            instruction.op,
                            instruction.operand,
                            next_instruction.result,
                        )
                    )
                index += 2
                continue

            if (
                isinstance(instruction, IRBinOp)
                and isinstance(next_instruction, IRJumpIfFalse)
                and next_instruction.condition == instruction.result
            ):
                self._emit_binop(instruction)
                condition = self._load_operand(instruction.result)
                self._emit(
                    f"    beq {condition}, {ZERO.asm()}, {next_instruction.label}"
                )
                self._release_temp(condition)
                index += 2
                continue

            if (
                isinstance(instruction, IRVaultInstruction)
                and instruction.keyword == "enderPortal"
                and index + 1 < len(instructions)
                and isinstance(instructions[index + 1], IRJumpIfFalse)
                and str(instructions[index + 1].condition).startswith("portal(")
            ):
                self._emit_portal(instruction.operands[0], instructions[index + 1].label)
                index += 2
                continue

            self._emit_ir_instruction(instruction)
            index += 1

    def _emit_ir_instruction(self, instruction: IRInstruction) -> None:
        if isinstance(instruction, IRLabel):
            self._emit(f"{instruction.name}:")
            return
        if isinstance(instruction, IRArrayAssign):
            symbol = self._require_symbol(instruction.result)
            self._emit_array_initializer(symbol, instruction.elements)
            return
        if isinstance(instruction, IRAssign):
            self._emit_assign(instruction)
            return
        if isinstance(instruction, IRCommit):
            self._emit_assign(IRAssign(instruction.source, instruction.result))
            return
        if isinstance(instruction, IRBinOp):
            self._emit_binop(instruction)
            return
        if isinstance(instruction, IRUnaryOp):
            self._emit_unary(instruction)
            return
        if isinstance(instruction, IRJump):
            self._emit(f"    jal {ZERO.asm()}, {instruction.label}")
            return
        if isinstance(instruction, IRJumpIfFalse):
            condition = self._load_operand(instruction.condition)
            self._emit(f"    beq {condition}, {ZERO.asm()}, {instruction.label}")
            self._release_temp(condition)
            return
        if isinstance(instruction, IRCall):
            self._emit_call(instruction)
            return
        if isinstance(instruction, IRReturn):
            if instruction.value is not None:
                value = self._load_operand(instruction.value)
                self._emit(f"    add {ARG_REGISTERS[0].asm()}, {value}, {ZERO.asm()}")
                self._release_temp(value)
            if self._function_end_label is None:
                raise CodegenError("return IR fuera de funcion")
            self._emit(f"    jal {ZERO.asm()}, {self._function_end_label}")
            return
        if isinstance(instruction, IRVaultInstruction):
            self._emit_vault_instruction(instruction)
            return
        raise CodegenError(f"instruccion IR no soportada: {type(instruction).__name__}")

    def _emit_assign(self, instruction: IRAssign) -> None:
        target_index = self._parse_index(instruction.result)
        if target_index is not None:
            value = self._load_operand(instruction.source)
            address = self._index_address(target_index)
            self._emit(f"    sw {value}, 0({address})")
            self._release_temp(address)
            self._release_temp(value)
            return

        value = self._load_operand(instruction.source)
        self._store_name(instruction.result, value)
        self._release_temp(value)

    def _emit_binop(self, instruction: IRBinOp) -> None:
        left = self._load_operand(instruction.left)
        right = self._load_operand(instruction.right)
        result = self._acquire_temp(self._register_hint(instruction.result))
        operation = {
            "+": "add",
            "-": "sub",
            "*": "mul",
            "/": "div",
            "^": "xor",
            "&": "and",
            "|": "or",
            "<<": "sll",
            ">>": "srl",
        }.get(instruction.op)

        if operation is not None:
            self._emit(f"    {operation} {result}, {left}, {right}")
        elif instruction.op in {"==", "!=", "<", ">", "<=", ">="}:
            self._emit_comparison(instruction.op, left, right, result)
        elif instruction.op in {"<+4", ">+5"}:
            shift = self._acquire_temp()
            amount = 4 if instruction.op == "<+4" else 5
            mnemonic = "sll" if instruction.op == "<+4" else "srl"
            self._emit_load_immediate(shift, amount)
            self._emit(f"    {mnemonic} {result}, {left}, {shift}")
            self._emit(f"    add {result}, {result}, {right}")
            self._release_temp(shift)
        else:
            raise CodegenError(f"operador IR no soportado: {instruction.op}")

        self._store_name(instruction.result, result)
        self._release_temp(result)
        self._release_temp(right)
        self._release_temp(left)

    def _emit_comparison(self, op: str, left: str, right: str, result: str) -> None:
        true_label = self._new_label("ir_cmp_true")
        end_label = self._new_label("ir_cmp_end")
        self._emit_load_immediate(result, 0)
        if op == "==":
            self._emit(f"    beq {left}, {right}, {true_label}")
        elif op == "!=":
            self._emit(f"    bne {left}, {right}, {true_label}")
        elif op == "<":
            self._emit(f"    blt {left}, {right}, {true_label}")
        elif op == ">":
            self._emit(f"    blt {right}, {left}, {true_label}")
        elif op == "<=":
            self._emit(f"    bge {right}, {left}, {true_label}")
        elif op == ">=":
            self._emit(f"    bge {left}, {right}, {true_label}")
        self._emit(f"    jal {ZERO.asm()}, {end_label}")
        self._emit(f"{true_label}:")
        self._emit_load_immediate(result, 1)
        self._emit(f"{end_label}:")

    def _emit_unary(self, instruction: IRUnaryOp) -> None:
        operand = self._load_operand(instruction.operand)
        result = self._acquire_temp(self._register_hint(instruction.result))
        if instruction.op == "-":
            self._emit(f"    sub {result}, {ZERO.asm()}, {operand}")
        elif instruction.op == "~":
            mask = self._acquire_temp()
            self._emit_load_immediate(mask, -1)
            self._emit(f"    xor {result}, {operand}, {mask}")
            self._release_temp(mask)
        else:
            raise CodegenError(f"operador unario IR no soportado: {instruction.op}")
        self._store_name(instruction.result, result)
        self._release_temp(result)
        self._release_temp(operand)

    def _emit_call(self, instruction: IRCall) -> None:
        if len(instruction.args) > len(ARG_REGISTERS):
            raise CodegenError("demasiados argumentos en llamada IR")
        for index, argument in enumerate(instruction.args):
            target = ARG_REGISTERS[index].asm()
            if isinstance(argument, str):
                symbol = self._lookup_symbol(argument)
            else:
                symbol = None
            if symbol is not None and isinstance(symbol.type, ChestType):
                source = self._chest_base_address(symbol)
            else:
                source = self._load_operand(argument)
            self._emit(f"    add {target}, {source}, {ZERO.asm()}")
            self._release_temp(source)

        self._flush_promoted_values()
        self._emit(f"    jal {RA.asm()}, {instruction.func_name}")
        self._invalidate_promoted_values()
        function_symbol = self.symbol_table.lookup_global(instruction.func_name)
        returns_void = (
            function_symbol is not None
            and isinstance(function_symbol.type, PrimitiveType)
            and function_symbol.type.name == PrimitiveName.VOID
        )
        if instruction.result is not None and not returns_void:
            result = self._acquire_temp(self._register_hint(instruction.result))
            self._emit(f"    add {result}, {ARG_REGISTERS[0].asm()}, {ZERO.asm()}")
            self._store_name(instruction.result, result)
            self._release_temp(result)

    def _emit_vault_instruction(self, instruction: IRVaultInstruction) -> None:
        operands = instruction.operands
        if instruction.keyword == "enderPortal":
            offset = operands[1] if len(operands) > 1 else "0"
            self._emit_portal(operands[0], str(offset))
            return
        if instruction.keyword == "enderchange":
            self._emit_change_password(operands[0])
            return
        if instruction.keyword == "enderopen":
            offset = operands[1] if len(operands) > 1 else "0"
            self._emit(f"    portalv {operands[0]}, {V0.asm()}, {offset} ; enderopen")
            return
        if instruction.keyword == "enderlow":
            self._emit(f"    addi x1, {operands[1]}, {operands[2]} ; enderlow")
            return
        if instruction.keyword == "enderhigh":
            self._emit(f"    addiHIGHv {operands[0]}, x1, {operands[2]} ; enderhigh")
            return
        mnemonic = {
            "enderclose": "closev",
            "enderload": "lwv",
            "enderstore": "swv",
            "enderkey": "changev",
            "close": "closev",
        }.get(instruction.keyword)
        if mnemonic is None:
            raise CodegenError(f"instruccion Vault IR desconocida: {instruction.keyword}")
        suffix = f" {', '.join(operands)}" if operands else ""
        self._emit(f"    {mnemonic}{suffix} ; {instruction.keyword}")

    def _emit_portal(self, password: Any, target: str) -> None:
        password_reg = self._load_operand(password)
        self._emit(f"    portalv {password_reg}, {V0.asm()}, {target} ; enderPortal")
        self._release_temp(password_reg)

    def _emit_change_password(self, value: Any) -> None:
        value_reg = self._load_operand(value)
        mask = self._acquire_temp()
        low = self._acquire_temp()
        shift = self._acquire_temp()
        high = self._acquire_temp()
        self._emit_load_immediate(mask, 0xFFFF)
        self._emit(f"    and {low}, {value_reg}, {mask}")
        self._emit_load_immediate(shift, 16)
        self._emit(f"    srl {high}, {value_reg}, {shift}")
        self._emit(f"    changev v0, {low}, {high} ; enderchange")
        self._emit("    swv v0, 0(v0)")
        for register in (high, shift, low, mask, value_reg):
            self._release_temp(register)

    def _emit_array_initializer(self, symbol: Symbol, elements: list[Any]) -> None:
        if not isinstance(symbol.type, ChestType):
            raise CodegenError(f"{symbol.name} no es chest para inicializacion IR")
        for index, element in enumerate(elements):
            if symbol.memory_info.segment == "VAULT":
                if not isinstance(element, int):
                    raise CodegenError("chest[ender] requiere inicializadores constantes")
                low = element & 0xFFFF
                high = (element >> 16) & 0xFFFF
                offset = (symbol.memory_info.offset or 0) + index * 4
                self._emit(f"    addi x1, v0, {low} ; {symbol.name}[{index}] low")
                self._emit(f"    addiHIGHv v1, x1, {high} ; {symbol.name}[{index}] high")
                self._emit(f"    swv v1, {offset}(v0) ; {symbol.name}[{index}]")
                continue
            value = self._load_operand(element)
            if symbol.memory_info.segment == "STACK":
                offset = (symbol.memory_info.offset or 0) + (
                    index * self._type_size(symbol.type.element_type)
                )
                self._emit(f"    sw {value}, {offset}({FP.asm()}) ; {symbol.name}[{index}]")
            elif symbol.memory_info.segment == "DATA":
                address = self._acquire_temp()
                self._emit_load_immediate(
                    address,
                    (symbol.memory_info.address or 0)
                    + index * self._type_size(symbol.type.element_type),
                )
                self._emit(f"    sw {value}, 0({address}) ; {symbol.name}[{index}]")
                self._release_temp(address)
            self._release_temp(value)

    def _load_operand(self, operand: Any) -> str:
        if isinstance(operand, int):
            register = self._acquire_temp()
            self._emit_load_immediate(register, operand)
            return register
        if not isinstance(operand, str):
            raise CodegenError(f"operando IR invalido: {operand!r}")

        if self._is_simple_name(operand):
            assigned = self._register_assignments.get(operand)
            if assigned is not None:
                if operand not in self._register_valid:
                    self._load_backing_name(operand, assigned)
                    self._register_valid.add(operand)
                return assigned

            symbol = self._lookup_symbol(operand)
            register = self._acquire_temp(self._register_hint(operand))
            if symbol is not None:
                self._load_symbol(symbol, register)
            else:
                offset = self._temp_offsets.get(operand)
                if offset is None:
                    raise CodegenError(f"temporal IR sin almacenamiento: {operand}")
                self._emit(f"    lw {register}, {offset}({FP.asm()}) ; {operand}")
            return register

        try:
            expression = pyast.parse(operand, mode="eval").body
        except SyntaxError as error:
            raise CodegenError(f"expresion IR invalida: {operand}") from error
        return self._load_expression_node(expression)

    def _load_expression_node(self, node: pyast.expr) -> str:
        if isinstance(node, pyast.Constant) and isinstance(node.value, int):
            return self._load_operand(node.value)
        if isinstance(node, pyast.Name):
            return self._load_operand(node.id)
        if isinstance(node, pyast.UnaryOp) and isinstance(node.op, pyast.USub):
            operand = self._load_expression_node(node.operand)
            result = self._acquire_temp()
            self._emit(f"    sub {result}, {ZERO.asm()}, {operand}")
            self._release_temp(operand)
            return result
        if isinstance(node, pyast.BinOp):
            left = self._load_expression_node(node.left)
            right = self._load_expression_node(node.right)
            result = self._acquire_temp()
            mnemonic = {
                pyast.Add: "add",
                pyast.Sub: "sub",
                pyast.Mult: "mul",
            }.get(type(node.op))
            if mnemonic is None:
                raise CodegenError("operacion embebida IR no soportada")
            self._emit(f"    {mnemonic} {result}, {left}, {right}")
            self._release_temp(right)
            self._release_temp(left)
            return result
        if isinstance(node, pyast.Subscript):
            address = self._index_address(node)
            result = self._acquire_temp()
            self._emit(f"    lw {result}, 0({address})")
            self._release_temp(address)
            return result
        raise CodegenError(f"expresion IR no soportada: {pyast.dump(node)}")

    def _parse_index(self, text: str) -> pyast.Subscript | None:
        if "[" not in text:
            return None
        try:
            node = pyast.parse(text, mode="eval").body
        except SyntaxError as error:
            raise CodegenError(f"indice IR invalido: {text}") from error
        if not isinstance(node, pyast.Subscript):
            return None
        return node

    def _index_address(self, node: pyast.Subscript) -> str:
        if not isinstance(node.value, pyast.Name):
            raise CodegenError("solo se indexan nombres de chest en IR")
        symbol = self._require_symbol(node.value.id)
        if not isinstance(symbol.type, ChestType):
            raise CodegenError(f"{symbol.name} no es chest")
        index = self._load_expression_node(node.slice)
        scaled = self._scale_index(index, symbol.type.element_type)
        base = self._chest_base_address(symbol)
        self._emit(f"    add {base}, {base}, {scaled}")
        if scaled != index:
            self._release_temp(scaled)
        self._release_temp(index)
        return base

    def _chest_base_address(self, symbol: Symbol) -> str:
        register = self._acquire_temp()
        if symbol.memory_info.segment == "STACK":
            if symbol.kind == SymbolKind.PARAMETER:
                self._emit(
                    f"    lw {register}, {symbol.memory_info.offset}({FP.asm()}) ; base ref {symbol.name}"
                )
            else:
                self._emit_add_immediate(
                    register,
                    FP.asm(),
                    symbol.memory_info.offset or 0,
                )
            return register
        if symbol.memory_info.segment == "DATA":
            self._emit_load_immediate(register, symbol.memory_info.address or 0)
            return register
        raise CodegenError(f"segmento de chest no soportado: {symbol.name}")

    def _scale_index(self, index: str, element_type: Type) -> str:
        size = self._type_size(element_type)
        if size == 1:
            return index
        result = self._acquire_temp()
        if size == 2:
            self._emit(f"    add {result}, {index}, {index}")
        elif size == 4:
            self._emit(f"    add {result}, {index}, {index}")
            self._emit(f"    add {result}, {result}, {result}")
        else:
            self._emit_load_immediate(result, size)
            self._emit(f"    mul {result}, {index}, {result}")
        return result

    def _store_name(self, name: str, source: str) -> None:
        assigned = self._register_assignments.get(name)
        if assigned is not None:
            if assigned != source:
                self._emit(f"    add {assigned}, {source}, {ZERO.asm()} ; promote {name}")
            self._register_valid.add(name)
            self._register_dirty.add(name)
            return

        symbol = self._lookup_symbol(name)
        if symbol is not None:
            self._store_symbol(symbol, source)
            return
        offset = self._temp_offsets.get(name)
        if offset is None:
            raise CodegenError(f"resultado IR sin almacenamiento: {name}")
        self._emit(f"    sw {source}, {offset}({FP.asm()}) ; {name}")

    def _load_symbol(self, symbol: Symbol, target: str) -> None:
        if symbol.memory_info.segment == "STACK":
            self._emit(f"    lw {target}, {symbol.memory_info.offset}({FP.asm()}) ; {symbol.name}")
            return
        if symbol.memory_info.segment == "DATA":
            address = self._acquire_temp()
            self._emit_load_immediate(address, symbol.memory_info.address or 0)
            self._emit(f"    lw {target}, 0({address}) ; {symbol.name}")
            self._release_temp(address)
            return
        raise CodegenError(f"no se puede cargar simbolo {symbol.name}")

    def _store_symbol(self, symbol: Symbol, source: str) -> None:
        if symbol.memory_info.segment == "STACK":
            self._emit(f"    sw {source}, {symbol.memory_info.offset}({FP.asm()}) ; {symbol.name}")
            return
        if symbol.memory_info.segment == "DATA":
            address = self._acquire_temp()
            self._emit_load_immediate(address, symbol.memory_info.address or 0)
            self._emit(f"    sw {source}, 0({address}) ; {symbol.name}")
            self._release_temp(address)
            return
        raise CodegenError(f"no se puede guardar simbolo {symbol.name}")

    def _store_incoming_arguments(self, function_scope: Scope) -> None:
        parameters = sorted(
            (
                symbol
                for symbol in function_scope.symbols.values()
                if symbol.kind == SymbolKind.PARAMETER
            ),
            key=lambda symbol: int(symbol.metadata.get("position", 0)),
        )
        for index, symbol in enumerate(parameters):
            assigned = self._register_assignments.get(symbol.name)
            if assigned is not None:
                self._emit(
                    f"    add {assigned}, {ARG_REGISTERS[index].asm()}, {ZERO.asm()}"
                    f" ; parametro promovido {symbol.name}"
                )
                self._register_valid.add(symbol.name)
                self._register_dirty.add(symbol.name)
            else:
                self._emit(
                    f"    sw {ARG_REGISTERS[index].asm()}, {symbol.memory_info.offset}({FP.asm()})"
                    f" ; parametro {symbol.name}"
                )
        if parameters:
            self._emit("")

    def _allocate_registers(
        self,
        instructions: list[IRInstruction],
    ) -> dict[str, str]:
        """
        Promocion conservadora por funcion.

        El codigo escalar reserva cuatro temporales. Las funciones con accesos
        indexados o Vault reservan seis porque el calculo de una direccion
        mantiene vivos indice, escala, base y valor simultaneamente.
        """
        scratch_count = 6 if self._needs_addressing_scratch(instructions) else 4
        allocatable = [
            register.asm() for register in TEMP_REGISTERS[:-scratch_count]
        ]
        intervals: dict[str, list[int]] = {}
        frequency: dict[str, int] = {}

        for index, instruction in enumerate(instructions):
            names = defs(instruction) | uses(instruction)
            for name in names:
                if not self._is_register_candidate(name):
                    continue
                frequency[name] = frequency.get(name, 0) + 1
                interval = intervals.setdefault(name, [index, index])
                interval[0] = min(interval[0], index)
                interval[1] = max(interval[1], index)

        assignments: dict[str, str] = {}
        free = list(allocatable)
        ranked = sorted(
            intervals,
            key=lambda name: (
                self._lookup_symbol(name) is None,
                -frequency[name],
                -(intervals[name][1] - intervals[name][0]),
                intervals[name][0],
            ),
        )
        for name in ranked[: len(allocatable)]:
            preferred = self._register_hint(name)
            if preferred in free:
                register = preferred
                free.remove(register)
            else:
                free.sort(key=lambda value: int(value[1:]))
                register = free.pop(0)
            assignments[name] = register

        return assignments

    def _needs_addressing_scratch(
        self,
        instructions: list[IRInstruction],
    ) -> bool:
        for instruction in instructions:
            if isinstance(instruction, IRVaultInstruction):
                return True
            for value in vars(instruction).values():
                values = value if isinstance(value, list) else [value]
                if any(isinstance(item, str) and "[" in item for item in values):
                    return True
        return False

    def _is_register_candidate(self, name: str) -> bool:
        if not self._is_simple_name(name):
            return False
        symbol = self._lookup_symbol(name)
        if symbol is not None:
            return (
                symbol.memory_info.segment == "STACK"
                and not isinstance(symbol.type, ChestType)
            )
        return VIRTUAL_RE.fullmatch(name) is not None

    def _load_backing_name(self, name: str, target: str) -> None:
        symbol = self._lookup_symbol(name)
        if symbol is not None:
            self._load_symbol(symbol, target)
            return
        offset = self._temp_offsets.get(name)
        if offset is None:
            raise CodegenError(f"temporal IR sin respaldo: {name}")
        self._emit(f"    lw {target}, {offset}({FP.asm()}) ; reload {name}")

    def _store_backing_name(self, name: str, source: str) -> None:
        symbol = self._lookup_symbol(name)
        if symbol is not None:
            self._store_symbol(symbol, source)
            return
        offset = self._temp_offsets.get(name)
        if offset is None:
            raise CodegenError(f"temporal IR sin respaldo: {name}")
        self._emit(f"    sw {source}, {offset}({FP.asm()}) ; spill {name}")

    def _flush_promoted_values(self) -> None:
        for name in sorted(self._register_dirty):
            register = self._register_assignments[name]
            self._store_backing_name(name, register)
        self._register_dirty.clear()

    def _invalidate_promoted_values(self) -> None:
        self._register_valid.clear()

    def _allocate_temp_slots(
        self,
        instructions: list[IRInstruction],
        function_scope: Scope,
    ) -> dict[str, int]:
        known = set(self._collect_symbols(function_scope))
        names: list[str] = []
        for instruction in instructions:
            for value in vars(instruction).values():
                values = value if isinstance(value, list) else [value]
                for item in values:
                    if not isinstance(item, str):
                        continue
                    for name in NAME_RE.findall(item):
                        if VIRTUAL_RE.fullmatch(name) and name not in known and name not in names:
                            names.append(name)

        minimum = self._minimum_stack_offset(function_scope)
        offsets: dict[str, int] = {}
        current = minimum
        for name in names:
            current -= self.WORD_SIZE
            offsets[name] = current
        return offsets

    def _required_local_size(self, scope: Scope, offsets: dict[str, int]) -> int:
        minimum = self._minimum_stack_offset(scope)
        if offsets:
            minimum = min(minimum, *offsets.values())
        return self._align(abs(minimum), 4)

    def _minimum_stack_offset(self, scope: Scope) -> int:
        minimum = 0
        stack = [scope]
        while stack:
            current = stack.pop()
            stack.extend(current.children)
            for symbol in current.symbols.values():
                offset = symbol.memory_info.offset
                if symbol.memory_info.segment == "STACK" and offset is not None:
                    minimum = min(minimum, offset)
        return minimum

    def _collect_symbols(self, scope: Scope) -> dict[str, Symbol]:
        # Limitacion conocida: variables con el mismo nombre en scopes hermanos
        # (ramas de if/else) se reducen a un solo simbolo; el primero encontrado
        # gana. Para evitar ambiguedad, usa nombres distintos en cada rama.
        result: dict[str, Symbol] = {}
        stack = [scope]
        while stack:
            current = stack.pop()
            stack.extend(current.children)
            for name, symbol in current.symbols.items():
                if name not in result:
                    result[name] = symbol
        return result

    def _lookup_symbol(self, name: str) -> Symbol | None:
        return self._symbols.get(name) or self.symbol_table.lookup_global(name)

    def _require_symbol(self, name: str) -> Symbol:
        symbol = self._lookup_symbol(name)
        if symbol is None:
            raise CodegenError(f"simbolo IR no encontrado: {name}")
        return symbol

    def _function_scope_for(self, name: str) -> Scope | None:
        for scope in self.symbol_table.all_scopes:
            if scope.kind == ScopeKind.FUNCTION and scope.name.startswith(f"function:{name}"):
                return scope
        return None

    def _emit_stack_pointer_bootstrap(self) -> None:
        self._emit("    ; inicializar stack pointer")
        self._emit(f"    addiHIGH {SP.asm()}, {ZERO.asm()}, 0")
        self._emit(f"    addi {SP.asm()}, {SP.asm()}, 0x{self.INITIAL_STACK_POINTER:04X}")
        self._emit("")

    def _new_label(self, prefix: str) -> str:
        label = f".L_ir_{self._label_counter}_{prefix}"
        self._label_counter += 1
        return label

    def _register_hint(self, name: str) -> str | None:
        match = VIRTUAL_RE.fullmatch(name)
        if match is None or match.group("hint") is None:
            return None
        return f"x{match.group('hint')}"

    def _is_simple_name(self, value: str) -> bool:
        return bool(re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", value))

    def _acquire_temp(self, preferred: str | None = None) -> str:
        if preferred is not None and preferred in self._free_temps:
            self._free_temps.remove(preferred)
            self._used_temps.append(preferred)
            return preferred
        if not self._free_temps:
            raise CodegenError("no hay registros temporales disponibles en backend IR")
        register = self._free_temps.pop(0)
        self._used_temps.append(register)
        return register

    def _release_temp(self, register: str | None) -> None:
        if register is None or register not in self._used_temps:
            return
        self._used_temps.remove(register)
        self._free_temps.append(register)

    def _emit_load_immediate(self, target: str, value: int) -> None:
        if -32768 <= value < 0:
            self._emit(f"    addiSigned {target}, {ZERO.asm()}, {value}")
            return
        if 0 <= value <= 32767:
            self._emit(f"    addi {target}, {ZERO.asm()}, {value}")
            return
        upper = (value >> 16) & 0xFFFF
        lower = value & 0xFFFF
        self._emit(f"    addiHIGH {target}, {ZERO.asm()}, {upper}")
        if lower:
            self._emit(f"    addi {target}, {target}, {lower}")

    def _emit_add_immediate(self, target: str, base: str, value: int) -> None:
        mnemonic = "addiSigned" if value < 0 else "addi"
        self._emit(f"    {mnemonic} {target}, {base}, {value}")

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
        if isinstance(symbol_type, PointerType):
            return 4
        if isinstance(symbol_type, ChestType):
            return self._type_size(symbol_type.element_type) * symbol_type.size
        return 4

    def _align(self, value: int, alignment: int) -> int:
        return ((value + alignment - 1) // alignment) * alignment
