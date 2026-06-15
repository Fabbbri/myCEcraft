from __future__ import annotations

from dataclasses import dataclass

from registers import TEMP_REGISTERS

AUTO_UNROLL_FACTOR = 0
MAX_AUTO_UNROLL_FACTOR = min(8, len(TEMP_REGISTERS))
MAX_MANUAL_UNROLL_FACTOR = 64


class IROptimizationError(Exception):
    pass


@dataclass
class IROptimizationStats:
    unroll_factor: int
    max_auto_unroll_factor: int = MAX_AUTO_UNROLL_FACTOR
    loops_seen: int = 0
    loops_unrolled: int = 0
    loops_skipped: int = 0
    duplicated_instructions: int = 0
    static_registers_renamed: int = 0
    dead_code_eliminated: int = 0
    instructions_reordered: int = 0
    selected_unroll_factors: list[int] | None = None

    def summary(self) -> str:
        factor = (
            f"auto(max={self.max_auto_unroll_factor})"
            if self.unroll_factor == AUTO_UNROLL_FACTOR
            else str(self.unroll_factor)
        )
        selected = ""
        if self.selected_unroll_factors:
            selected = f", selected_factors={self.selected_unroll_factors}"
        return (
            "Optimizaciones IR: "
            f"loop_unrolling factor={factor}, "
            f"loops={self.loops_seen}, "
            f"unrolled={self.loops_unrolled}, "
            f"skipped={self.loops_skipped}, "
            f"duplicated_ir={self.duplicated_instructions}, "
            f"dce_removed={self.dead_code_eliminated}, "
            f"reordered_ir={self.instructions_reordered}, "
            f"renamed_static_registers={self.static_registers_renamed}"
            f"{selected}"
        )
