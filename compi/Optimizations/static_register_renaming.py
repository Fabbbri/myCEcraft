from __future__ import annotations

import re
from typing import Any

from IR.basic_blocks import ControlFlowGraph
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
from registers import TEMP_REGISTERS

from .common import IROptimizationStats


TEMP_RE = re.compile(r"t\d+\Z")
SIMPLE_NAME_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")


class IRStaticRegisterRenamer:
    """
    Versiona escrituras escalares dentro de cada bloque basico.

    Cada nueva definicion recibe un nombre virtual distinto y una pista de
    registro fisico. Al salir del bloque, IRCommit conserva el valor visible
    de la variable original sin permitir que el planificador mueva la copia.
    """

    def __init__(self, stats: IROptimizationStats) -> None:
        self.stats = stats
        self._register_counter = 0
        self._version_counters: dict[str, int] = {}
        self._temp_mapping: dict[str, str] = {}
        self._registers = [register.asm() for register in TEMP_REGISTERS]

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        if not instructions:
            return []

        arrays = {
            instruction.result
            for instruction in instructions
            if isinstance(instruction, IRArrayAssign)
        }
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
                output.extend(self._rename_block(block.instructions, arrays))
            else:
                # Global initializers must keep their symbol names for .data.
                output.extend(block.instructions)
        return output

    def _rename_block(
        self,
        instructions: list[IRInstruction],
        arrays: set[str],
    ) -> list[IRInstruction]:
        output: list[IRInstruction] = []
        versions: dict[str, str] = {}

        for instruction in instructions:
            if isinstance(instruction, IRLabel):
                output.append(instruction)
                continue

            if isinstance(instruction, IRBinOp):
                result = self._rename_temp_definition(instruction.result)
                output.append(
                    IRBinOp(
                        instruction.op,
                        self._rename_operand(instruction.left, versions),
                        self._rename_operand(instruction.right, versions),
                        result,
                    )
                )
                continue

            if isinstance(instruction, IRUnaryOp):
                result = self._rename_temp_definition(instruction.result)
                output.append(
                    IRUnaryOp(
                        instruction.op,
                        self._rename_operand(instruction.operand, versions),
                        result,
                    )
                )
                continue

            if isinstance(instruction, IRAssign):
                source = self._rename_operand(instruction.source, versions)
                target = instruction.result

                if TEMP_RE.fullmatch(target):
                    output.append(
                        IRAssign(source, self._rename_temp_definition(target))
                    )
                elif (
                    SIMPLE_NAME_RE.fullmatch(target)
                    and target not in arrays
                ):
                    version = self._new_variable_version(target)
                    versions[target] = version
                    output.append(IRAssign(source, version))
                else:
                    output.append(
                        IRAssign(
                            source,
                            self._rename_operand(target, versions),
                        )
                    )
                continue

            if isinstance(instruction, IRArrayAssign):
                output.extend(self._flush_versions(versions))
                output.append(
                    IRArrayAssign(
                        [
                            self._rename_operand(element, versions)
                            for element in instruction.elements
                        ],
                        instruction.result,
                    )
                )
                continue

            if isinstance(instruction, IRCall):
                output.extend(self._flush_versions(versions))
                result = (
                    self._rename_temp_definition(instruction.result)
                    if instruction.result
                    else None
                )
                output.append(
                    IRCall(
                        instruction.func_name,
                        [
                            self._rename_operand(argument, versions)
                            for argument in instruction.args
                        ],
                        result,
                    )
                )
                continue

            if isinstance(instruction, IRJumpIfFalse):
                output.extend(self._flush_versions(versions))
                output.append(
                    IRJumpIfFalse(
                        self._rename_operand(instruction.condition, versions),
                        instruction.label,
                    )
                )
                continue

            if isinstance(instruction, IRReturn):
                output.extend(self._flush_versions(versions))
                output.append(
                    IRReturn(self._rename_operand(instruction.value, versions))
                )
                continue

            if isinstance(instruction, IRVaultInstruction):
                output.extend(self._flush_versions(versions))
                output.append(
                    IRVaultInstruction(
                        instruction.keyword,
                        [
                            self._rename_operand(operand, versions)
                            for operand in instruction.operands
                        ],
                    )
                )
                continue

            if isinstance(instruction, IRJump):
                output.extend(self._flush_versions(versions))
                output.append(instruction)
                continue

            output.append(instruction)

        output.extend(self._flush_versions(versions))
        return output

    def _flush_versions(self, versions: dict[str, str]) -> list[IRCommit]:
        commits = [
            IRCommit(version, original)
            for original, version in versions.items()
        ]
        versions.clear()
        return commits

    def _rename_operand(
        self,
        operand: Any,
        versions: dict[str, str],
    ) -> Any:
        if not isinstance(operand, str):
            return operand

        mapping = {**self._temp_mapping, **versions}
        if operand in mapping:
            return mapping[operand]
        for original in sorted(mapping, key=len, reverse=True):
            operand = re.sub(
                rf"\b{re.escape(original)}\b",
                mapping[original],
                operand,
            )
        return operand

    def _rename_temp_definition(self, original: str) -> str:
        renamed = self._with_register_hint(original)
        self._temp_mapping[original] = renamed
        return renamed

    def _new_variable_version(self, original: str) -> str:
        version = self._version_counters.get(original, 0) + 1
        self._version_counters[original] = version
        return self._with_register_hint(f"{original}__v{version}")

    def _with_register_hint(self, name: str) -> str:
        if not self._registers:
            return name
        register = self._registers[
            self._register_counter % len(self._registers)
        ]
        self._register_counter += 1
        self.stats.static_registers_renamed += 1
        return f"{name}__{register}"
