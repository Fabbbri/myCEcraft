from __future__ import annotations

from dataclasses import dataclass

from IR.basic_blocks import BasicBlock, ControlFlowGraph
from IR.instructions import (
    IRAssign,
    IRBinOp,
    IRInstruction,
    IRUnaryOp,
)

from .common import IROptimizationStats
from IR.ir_analysis import defs, has_side_effect, uses


@dataclass
class _BlockLiveness:
    use: set[str]
    defs: set[str]
    live_in: set[str]
    live_out: set[str]


class IRDeadCodeEliminator:
    def __init__(self, stats: IROptimizationStats) -> None:
        self.stats = stats

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        if not instructions:
            return []

        cfg = ControlFlowGraph()
        cfg.build_from_ir(instructions)
        liveness = self._analyze_liveness(cfg.blocks)

        optimized_blocks: list[list[IRInstruction]] = []
        for block in cfg.blocks:
            optimized_blocks.append(self._eliminate_in_block(block, liveness[block]))

        return [instr for block_instrs in optimized_blocks for instr in block_instrs]

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
        if has_side_effect(instr):
            return False
        return isinstance(instr, (IRAssign, IRBinOp, IRUnaryOp))
