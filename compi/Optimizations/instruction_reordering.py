from __future__ import annotations

from IR.basic_blocks import ControlFlowGraph
from IR.instructions import IRInstruction

from .common import IROptimizationStats
from IR.ir_analysis import defs, is_memory_read, is_schedulable, uses


class IRInstructionReorderer:
    def __init__(self, stats: IROptimizationStats) -> None:
        self.stats = stats

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        if not instructions:
            return []

        cfg = ControlFlowGraph()
        cfg.build_from_ir(instructions)

        optimized_blocks: list[list[IRInstruction]] = []
        for block in cfg.blocks:
            optimized_blocks.append(self._schedule_block(block.instructions))

        return [instr for block_instrs in optimized_blocks for instr in block_instrs]

    def _schedule_block(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        output: list[IRInstruction] = []
        segment: list[IRInstruction] = []

        for instr in instructions:
            if is_schedulable(instr):
                segment.append(instr)
                continue

            output.extend(self._schedule_segment(segment))
            segment.clear()
            output.append(instr)

        output.extend(self._schedule_segment(segment))
        return output

    def _schedule_segment(self, segment: list[IRInstruction]) -> list[IRInstruction]:
        if len(segment) < 3:
            return list(segment)

        successors = {index: set() for index in range(len(segment))}
        predecessors = {index: set() for index in range(len(segment))}

        instr_defs = [defs(instr) for instr in segment]
        instr_uses = [uses(instr) for instr in segment]

        for left_index in range(len(segment)):
            for right_index in range(left_index + 1, len(segment)):
                if self._must_preserve_order(
                    instr_defs[left_index],
                    instr_uses[left_index],
                    instr_defs[right_index],
                    instr_uses[right_index],
                ):
                    successors[left_index].add(right_index)
                    predecessors[right_index].add(left_index)

        ready = {
            index
            for index, required in predecessors.items()
            if not required
        }
        scheduled_indexes: list[int] = []

        while ready:
            selected = self._select_ready_instruction(
                segment,
                ready,
                scheduled_indexes,
                instr_defs,
                instr_uses,
            )
            ready.remove(selected)
            scheduled_indexes.append(selected)

            for successor in successors[selected]:
                predecessors[successor].remove(selected)
                if not predecessors[successor]:
                    ready.add(successor)

        if len(scheduled_indexes) != len(segment):
            return list(segment)

        scheduled = [segment[index] for index in scheduled_indexes]
        self.stats.instructions_reordered += sum(
            1
            for original_index, scheduled_index in enumerate(scheduled_indexes)
            if original_index != scheduled_index
        )
        return scheduled

    def _must_preserve_order(
        self,
        left_defs: set[str],
        left_uses: set[str],
        right_defs: set[str],
        right_uses: set[str],
    ) -> bool:
        raw = left_defs & right_uses
        war = left_uses & right_defs
        waw = left_defs & right_defs
        return bool(raw or war or waw)

    def _select_ready_instruction(
        self,
        segment: list[IRInstruction],
        ready: set[int],
        scheduled_indexes: list[int],
        instr_defs: list[set[str]],
        instr_uses: list[set[str]],
    ) -> int:
        ordered_ready = sorted(ready)
        if not scheduled_indexes:
            return ordered_ready[0]

        previous_index = scheduled_indexes[-1]
        previous = segment[previous_index]
        if not is_memory_read(previous):
            return ordered_ready[0]

        load_defs = instr_defs[previous_index]
        for candidate in ordered_ready:
            if not (load_defs & instr_uses[candidate]):
                return candidate
        return ordered_ready[0]
