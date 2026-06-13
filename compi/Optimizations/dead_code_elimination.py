from __future__ import annotations

from dataclasses import dataclass

from IR.basic_blocks import BasicBlock, ControlFlowGraph
from IR.instructions import (
    IRAssign,
    IRArrayAssign,
    IRBinOp,
    IRCall,
    IRInstruction,
    IRJumpIfFalse,
    IRLabel,
    IRReturn,
    IRUnaryOp,
    IRVaultInstruction,
)

from .common import IROptimizationStats
from IR.ir_analysis import defs, has_side_effect, is_simple_target, uses


@dataclass
class _BlockLiveness:
    use: set[str]
    defs: set[str]
    live_in: set[str]
    live_out: set[str]


class IRDeadCodeEliminator:
    def __init__(self, stats: IROptimizationStats) -> None:
        self.stats = stats
        self._observable_names: set[str] = set()

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        if not instructions:
            return []

        self._observable_names = self._module_definitions(instructions)
        instructions = self._eliminate_unobservable_chains(instructions)
        cfg = ControlFlowGraph()
        cfg.build_from_ir(instructions)
        liveness = self._analyze_liveness(cfg.blocks)

        optimized_blocks: list[list[IRInstruction]] = []
        for block in cfg.blocks:
            optimized_blocks.append(self._eliminate_in_block(block, liveness[block]))

        return [instr for block_instrs in optimized_blocks for instr in block_instrs]

    def _module_definitions(
        self,
        instructions: list[IRInstruction],
    ) -> set[str]:
        observable: set[str] = set()
        for instruction in instructions:
            if isinstance(instruction, IRLabel) and instruction.is_function:
                break
            observable.update(defs(instruction))
        return observable

    def _eliminate_unobservable_chains(
        self,
        instructions: list[IRInstruction],
    ) -> list[IRInstruction]:
        """
        Elimina componentes de dependencias que nunca alcanzan una raiz
        observable. Esto permite quitar recurrencias muertas de loops, que el
        liveness clasico conserva porque cada iteracion usa el valor anterior.
        """
        dependencies: dict[str, set[str]] = {}
        roots: set[str] = set()
        inside_function = False

        for instruction in instructions:
            if isinstance(instruction, IRLabel) and instruction.is_function:
                inside_function = True

            instruction_defs = defs(instruction)
            instruction_uses = uses(instruction)
            for name in instruction_defs:
                dependencies.setdefault(name, set()).update(instruction_uses)

            if not inside_function and instruction_defs:
                roots.update(instruction_defs)
            elif isinstance(
                instruction,
                (
                    IRReturn,
                    IRJumpIfFalse,
                    IRCall,
                    IRVaultInstruction,
                    IRArrayAssign,
                ),
            ):
                roots.update(instruction_uses)
            elif isinstance(instruction, IRAssign) and not is_simple_target(
                instruction.result
            ):
                roots.update(instruction_uses)

        needed = set(roots)
        pending = list(roots)
        while pending:
            name = pending.pop()
            for dependency in dependencies.get(name, set()):
                if dependency not in needed:
                    needed.add(dependency)
                    pending.append(dependency)

        output: list[IRInstruction] = []
        inside_function = False
        for instruction in instructions:
            if isinstance(instruction, IRLabel) and instruction.is_function:
                inside_function = True
            instruction_defs = defs(instruction)
            if (
                inside_function
                and instruction_defs
                and not (instruction_defs & needed)
                and isinstance(instruction, (IRAssign, IRBinOp, IRUnaryOp))
            ):
                self.stats.dead_code_eliminated += 1
                continue
            output.append(instruction)
        return output

    def _analyze_liveness(
        self,
        blocks: list[BasicBlock],
    ) -> dict[BasicBlock, _BlockLiveness]:
        liveness: dict[BasicBlock, _BlockLiveness] = {}
        for block in blocks:
            use_set, defs_set = self._block_use_defs(block.instructions)
            liveness[block] = _BlockLiveness(use_set, defs_set, set(), set())

        changed = True
        while changed:
            changed = False
            for block in reversed(blocks):
                info = liveness[block]
                live_out = set().union(
                    *(liveness[successor].live_in for successor in block.successors)
                )
                live_in = info.use | (live_out - info.defs)
                if live_in != info.live_in or live_out != info.live_out:
                    info.live_in = live_in
                    info.live_out = live_out
                    changed = True

        return liveness

    def _block_use_defs(
        self,
        instructions: list[IRInstruction],
    ) -> tuple[set[str], set[str]]:
        use: set[str] = set()
        defs_set: set[str] = set()

        for instr in instructions:
            instr_uses = uses(instr)
            instr_defs = defs(instr)
            use.update(name for name in instr_uses if name not in defs_set)
            defs_set.update(instr_defs)

        return use, defs_set

    def _eliminate_in_block(
        self,
        block: BasicBlock,
        info: _BlockLiveness,
    ) -> list[IRInstruction]:
        live = set(info.live_out)
        kept_reversed: list[IRInstruction] = []

        for instr in reversed(block.instructions):
            instr_defs = defs(instr)
            instr_uses = uses(instr)

            if self._is_dead_definition(instr, instr_defs, live):
                self.stats.dead_code_eliminated += 1
                continue

            kept_reversed.append(instr)
            live.difference_update(instr_defs)
            live.update(instr_uses)

        kept_reversed.reverse()
        return kept_reversed

    def _is_dead_definition(
        self,
        instr: IRInstruction,
        instr_defs: set[str],
        live: set[str],
    ) -> bool:
        if not instr_defs or instr_defs & live:
            return False
        if instr_defs & self._observable_names:
            return False
        if has_side_effect(instr):
            return False
        return isinstance(instr, (IRAssign, IRBinOp, IRUnaryOp))
