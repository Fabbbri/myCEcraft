from __future__ import annotations

from IR.instructions import IRInstruction

from .common import AUTO_UNROLL_FACTOR, IROptimizationStats
from .dead_code_elimination import IRDeadCodeEliminator
from .instruction_reordering import IRInstructionReorderer
from .loop_unrolling import IRLoopUnroller
from .static_register_renaming import IRStaticRegisterRenamer


def optimize_ir(
    instructions: list[IRInstruction],
    *,
    unroll_factor: int,
    rename_static_registers: bool,
    eliminate_dead_code: bool = False,
    reorder_instructions: bool = False,
) -> tuple[list[IRInstruction], IROptimizationStats]:
    stats = IROptimizationStats(
        unroll_factor=unroll_factor if unroll_factor == AUTO_UNROLL_FACTOR else max(1, unroll_factor),
        selected_unroll_factors=[],
    )

    optimized = IRLoopUnroller(stats.unroll_factor, stats).run(instructions)
    if eliminate_dead_code:
        optimized = IRDeadCodeEliminator(stats).run(optimized)
    if rename_static_registers:
        optimized = IRStaticRegisterRenamer(stats).run(optimized)
    if reorder_instructions:
        optimized = IRInstructionReorderer(stats).run(optimized)
    return optimized, stats
