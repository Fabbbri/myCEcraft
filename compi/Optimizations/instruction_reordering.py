from __future__ import annotations

from IR.basic_blocks import BasicBlock, ControlFlowGraph
from IR.instructions import IRAssign, IRInstruction, IRJumpIfFalse, IRLabel

from .common import IROptimizationStats
from IR.ir_analysis import defs, is_memory_read, is_schedulable, uses


class IRInstructionReorderer:
    def __init__(self, stats: IROptimizationStats, global_names: set[str] | None = None) -> None:
        self.stats = stats
        self._global_names: set[str] = global_names or set()

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        if not instructions:
            return []

        cfg = ControlFlowGraph()
        cfg.build_from_ir(instructions)

        # Fase 1: code sinking entre bloques. Hunde cadenas de calculo puras
        # hacia la rama del if donde se usan, para que solo se ejecuten cuando
        # esa rama se toma. Es seguro (preserva la logica) por las condiciones
        # de _select_sinkable.
        self._sink_into_branches(cfg)

        # Fase 2: scheduling local dentro de cada bloque (relleno load-use).
        optimized_blocks: list[list[IRInstruction]] = []
        for block in cfg.blocks:
            optimized_blocks.append(self._schedule_block(block.instructions))

        return [instr for block_instrs in optimized_blocks for instr in block_instrs]

    # ------------------------------------------------------------------
    # Fase 1: code sinking seguro hacia ramas
    # ------------------------------------------------------------------

    def _sink_into_branches(self, cfg: ControlFlowGraph) -> None:
        """
        Hunde calculos puros desde un bloque que termina en `ifFalse` hacia el
        sucesor (rama) donde se usan en exclusiva. Repite hasta punto fijo,
        recomputando vivacidad tras cada movimiento para no usar datos stale.
        """
        while self._sink_one(cfg):
            pass

    def _sink_one(self, cfg: ControlFlowGraph) -> bool:
        live_in, live_out = self._compute_liveness(cfg)
        for block in cfg.blocks:
            if not block.instructions:
                continue
            if not isinstance(block.instructions[-1], IRJumpIfFalse):
                continue
            if len(block.successors) < 2:
                continue
            false_succ, true_succ = block.successors[0], block.successors[1]
            # Se intenta hundir hacia cada rama; la rama receptora debe tener a
            # este bloque como UNICO predecesor, asi el codigo movido corre solo
            # cuando se entra por aca.
            for target, other in ((true_succ, false_succ), (false_succ, true_succ)):
                if target is block or len(target.predecessors) != 1:
                    continue
                if target.predecessors[0] is not block:
                    continue
                sunk = self._select_sinkable(
                    block,
                    target,
                    live_in.get(other, set()),
                    live_out.get(target, set()),
                )
                if sunk:
                    self._apply_sink(block, target, sunk)
                    return True
        return False

    def _select_sinkable(
        self,
        block: BasicBlock,
        target: BasicBlock,
        live_in_other: set[str],
        live_out_target: set[str],
    ) -> set[int]:
        """
        Indices de las instrucciones de `block` que se pueden hundir a `target`.

        Una instruccion `v = ...` es hundible si:
          - es pura (ALU/copia, sin loads ni efectos laterales);
          - `v` NO esta vivo en la otra rama (live_in_other) ni despues del
            target (live_out_target) -> esta confinado al target;
          - toda otra instruccion de `block` que use `v` tambien se hunde
            (la cadena se mueve completa);
          - `v` realmente se necesita en el target (lo usa el target o una
            instruccion ya marcada para hundir).
        """
        body = block.instructions
        target_uses: set[str] = set()
        for instr in target.instructions:
            target_uses |= uses(instr)

        sunk_indices: set[int] = set()
        sunk_uses: set[str] = set()

        for position in reversed(range(len(body))):
            instr = body[position]
            if not self._is_sinkable(instr):
                continue
            defined = defs(instr)
            if not defined:
                continue
            # confinado al target: no usado en la otra rama ni tras el merge
            if defined & live_in_other or defined & live_out_target:
                continue
            # toda otra instruccion de block que use 'defined' debe hundirse
            confined = True
            for other_pos in range(len(body)):
                if other_pos == position or other_pos in sunk_indices:
                    continue
                if defined & uses(body[other_pos]):
                    confined = False
                    break
            if not confined:
                continue
            # debe necesitarse en el target (uso directo o por algo ya hundido)
            if not (defined & target_uses or defined & sunk_uses):
                continue
            sunk_indices.add(position)
            sunk_uses |= uses(instr)

        return sunk_indices

    def _apply_sink(
        self,
        block: BasicBlock,
        target: BasicBlock,
        sunk_indices: set[int],
    ) -> None:
        moved = [block.instructions[position] for position in sorted(sunk_indices)]
        block.instructions = [
            instr
            for index, instr in enumerate(block.instructions)
            if index not in sunk_indices
        ]
        # insertar tras las etiquetas iniciales del target, manteniendo el orden
        insert_at = 0
        while insert_at < len(target.instructions) and isinstance(
            target.instructions[insert_at], IRLabel
        ):
            insert_at += 1
        target.instructions[insert_at:insert_at] = moved
        self.stats.instructions_reordered += len(moved)

    def _is_sinkable(self, instr: IRInstruction) -> bool:
        return (
            is_schedulable(instr)
            and not is_memory_read(instr)
            and not self._is_global_load(instr)
        )

    def _compute_liveness(
        self,
        cfg: ControlFlowGraph,
    ) -> tuple[dict[BasicBlock, set[str]], dict[BasicBlock, set[str]]]:
        use: dict[BasicBlock, set[str]] = {}
        define: dict[BasicBlock, set[str]] = {}
        live_in: dict[BasicBlock, set[str]] = {}
        live_out: dict[BasicBlock, set[str]] = {}
        for block in cfg.blocks:
            block_use, block_def = self._block_use_def(block.instructions)
            use[block] = block_use
            define[block] = block_def
            live_in[block] = set()
            live_out[block] = set()

        changed = True
        while changed:
            changed = False
            for block in reversed(cfg.blocks):
                out_set: set[str] = set()
                for successor in block.successors:
                    out_set |= live_in[successor]
                in_set = use[block] | (out_set - define[block])
                if in_set != live_in[block] or out_set != live_out[block]:
                    live_in[block] = in_set
                    live_out[block] = out_set
                    changed = True

        return live_in, live_out

    def _block_use_def(
        self,
        instructions: list[IRInstruction],
    ) -> tuple[set[str], set[str]]:
        use: set[str] = set()
        define: set[str] = set()
        for instr in instructions:
            for name in uses(instr):
                if name not in define:
                    use.add(name)
            define |= defs(instr)
        return use, define

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

    def _is_global_load(self, instr: IRInstruction) -> bool:
        if not isinstance(instr, IRAssign) or not isinstance(instr.source, str):
            return False
        return instr.source in self._global_names

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
        if not (is_memory_read(previous) or self._is_global_load(previous)):
            return ordered_ready[0]

        load_defs = instr_defs[previous_index]
        for candidate in ordered_ready:
            if not (load_defs & instr_uses[candidate]):
                return candidate
        return ordered_ready[0]
