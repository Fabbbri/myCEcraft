from __future__ import annotations

import re
from typing import Any

from IR.basic_blocks import ControlFlowGraph
from IR.instructions import (
    IRAssign,
    IRArrayAssign,
    IRBinOp,
    IRCall,
    IRInstruction,
    IRJump,
    IRJumpIfFalse,
    IRLabel,
    IRReturn,
    IRUnaryOp,
    IRVaultInstruction,
)
from registers import TEMP_REGISTERS

from .common import IROptimizationStats


TEMP_RE = re.compile(r"t\d+\Z")


class IRStaticRegisterRenamer:
    """
    Agrega pistas de registro fisico a temporales IR.

    Las variables visibles conservan su nombre. La asignacion real y la
    decision de spill pertenecen al backend; crear versiones de cada variable
    aqui obligaba a materializarlas en stack y hacia crecer el codigo.
    """

    def __init__(self, stats: IROptimizationStats) -> None:
        self.stats = stats
        self._register_counter = 0
        self._temp_mapping: dict[str, str] = {}
        self._registers = [register.asm() for register in TEMP_REGISTERS]

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        if not instructions:
            return []

        cfg = ControlFlowGraph()
        cfg.build_from_ir(instructions)

        output: list[IRInstruction] = []
        inside_function = False
        for block in cfg.blocks:
            starts_function = any(
                isinstance(instruction, IRLabel) and instruction.is_function
                for instruction in block.instructions
            )
            if starts_function:
                inside_function = True
                self._temp_mapping.clear()

            if inside_function:
                output.extend(self._rename_block(block.instructions))
            else:
                output.extend(block.instructions)
        return output

    def _rename_block(
        self,
        instructions: list[IRInstruction],
    ) -> list[IRInstruction]:
        output: list[IRInstruction] = []

        for instruction in instructions:
            if isinstance(instruction, IRLabel):
                output.append(instruction)
                continue

            if isinstance(instruction, IRBinOp):
                result = self._rename_temp_definition(instruction.result)
                output.append(
                    IRBinOp(
                        instruction.op,
                        self._rename_operand(instruction.left),
                        self._rename_operand(instruction.right),
                        result,
                    )
                )
                continue

            if isinstance(instruction, IRUnaryOp):
                result = self._rename_temp_definition(instruction.result)
                output.append(
                    IRUnaryOp(
                        instruction.op,
                        self._rename_operand(instruction.operand),
                        result,
                    )
                )
                continue

            if isinstance(instruction, IRAssign):
                source = self._rename_operand(instruction.source)
                target = instruction.result

                if TEMP_RE.fullmatch(target):
                    output.append(
                        IRAssign(source, self._rename_temp_definition(target))
                    )
                else:
                    output.append(IRAssign(source, target))
                continue

            if isinstance(instruction, IRArrayAssign):
                output.append(
                    IRArrayAssign(
                        [
                            self._rename_operand(element)
                            for element in instruction.elements
                        ],
                        instruction.result,
                    )
                )
                continue

            if isinstance(instruction, IRCall):
                result = (
                    self._rename_temp_definition(instruction.result)
                    if instruction.result
                    else None
                )
                output.append(
                    IRCall(
                        instruction.func_name,
                        [
                            self._rename_operand(argument)
                            for argument in instruction.args
                        ],
                        result,
                    )
                )
                continue

            if isinstance(instruction, IRJumpIfFalse):
                output.append(
                    IRJumpIfFalse(
                        self._rename_operand(instruction.condition),
                        instruction.label,
                    )
                )
                continue

            if isinstance(instruction, IRReturn):
                output.append(
                    IRReturn(self._rename_operand(instruction.value))
                )
                continue

            if isinstance(instruction, IRVaultInstruction):
                output.append(
                    IRVaultInstruction(
                        instruction.keyword,
                        [
                            self._rename_operand(operand)
                            for operand in instruction.operands
                        ],
                    )
                )
                continue

            if isinstance(instruction, IRJump):
                output.append(instruction)
                continue

            output.append(instruction)

        return output

    def _rename_operand(
        self,
        operand: Any,
    ) -> Any:
        if not isinstance(operand, str):
            return operand

        if operand in self._temp_mapping:
            return self._temp_mapping[operand]
        for original in sorted(self._temp_mapping, key=len, reverse=True):
            operand = re.sub(
                rf"\b{re.escape(original)}\b",
                self._temp_mapping[original],
                operand,
            )
        return operand

    def _rename_temp_definition(self, original: str) -> str:
        renamed = self._with_register_hint(original)
        self._temp_mapping[original] = renamed
        return renamed

    def _with_register_hint(self, name: str) -> str:
        if not self._registers:
            return name
        register = self._registers[
            self._register_counter % len(self._registers)
        ]
        self._register_counter += 1
        self.stats.static_registers_renamed += 1
        return f"{name}__{register}"
