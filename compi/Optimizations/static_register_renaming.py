from __future__ import annotations

import re
from typing import Any

from IR.instructions import (
    IRAssign,
    IRBinOp,
    IRCall,
    IRInstruction,
    IRJumpIfFalse,
    IRLabel,
    IRReturn,
    IRUnaryOp,
)
from registers import TEMP_REGISTERS

from .common import IROptimizationStats


class IRStaticRegisterRenamer:
    def __init__(self, stats: IROptimizationStats) -> None:
        self.stats = stats
        self._counter = 0
        self._mapping: dict[str, str] = {}
        self._registers = [register.asm() for register in TEMP_REGISTERS]

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        return [self._rename_instruction(instr) for instr in instructions]

    def _rename_instruction(self, instr: IRInstruction) -> IRInstruction:
        if isinstance(instr, IRLabel):
            self._mapping.clear()
            return instr
        if isinstance(instr, IRBinOp):
            left = self._rename_operand(instr.left)
            right = self._rename_operand(instr.right)
            result = self._fresh_static_register(instr.result)
            self._mapping[instr.result] = result
            return IRBinOp(instr.op, left, right, result)
        if isinstance(instr, IRUnaryOp):
            operand = self._rename_operand(instr.operand)
            result = self._fresh_static_register(instr.result)
            self._mapping[instr.result] = result
            return IRUnaryOp(instr.op, operand, result)
        if isinstance(instr, IRAssign):
            return IRAssign(
                self._rename_operand(instr.source),
                self._rename_target(instr.result),
            )
        if isinstance(instr, IRJumpIfFalse):
            return IRJumpIfFalse(self._rename_operand(instr.condition), instr.label)
        if isinstance(instr, IRReturn):
            return IRReturn(self._rename_operand(instr.value))
        if isinstance(instr, IRCall):
            args = [self._rename_operand(arg) for arg in instr.args]
            result = self._fresh_static_register(instr.result) if instr.result else None
            if instr.result and result:
                self._mapping[instr.result] = result
            return IRCall(instr.func_name, args, result)
        return instr

    def _rename_operand(self, operand: Any) -> Any:
        if isinstance(operand, str):
            return self._mapping.get(operand, operand)
        return operand

    def _rename_target(self, target: str) -> str:
        if "[" in target or "." in target:
            return target
        if re.fullmatch(r"t\d+", target):
            renamed = self._fresh_static_register(target)
            self._mapping[target] = renamed
            return renamed
        return target

    def _fresh_static_register(self, original: str) -> str:
        if not self._registers:
            return original
        renamed = self._registers[self._counter % len(self._registers)]
        self._counter += 1
        self.stats.static_registers_renamed += 1
        return renamed
