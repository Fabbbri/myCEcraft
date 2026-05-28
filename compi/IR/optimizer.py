from __future__ import annotations

from dataclasses import dataclass
import re
from typing import Any

from IR.instructions import (
    IRAssign,
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

AUTO_UNROLL_FACTOR = 0
MAX_AUTO_UNROLL_FACTOR = min(8, len(TEMP_REGISTERS))


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
            f"renamed_static_registers={self.static_registers_renamed}"
            f"{selected}"
        )


def optimize_ir(
    instructions: list[IRInstruction],
    *,
    unroll_factor: int,
    rename_static_registers: bool,
) -> tuple[list[IRInstruction], IROptimizationStats]:
    stats = IROptimizationStats(
        unroll_factor=unroll_factor if unroll_factor == AUTO_UNROLL_FACTOR else max(1, unroll_factor),
        selected_unroll_factors=[],
    )
    optimized = _IRLoopUnroller(stats.unroll_factor, stats).run(instructions)
    if rename_static_registers:
        optimized = _IRStaticRegisterRenamer(stats).run(optimized)
    return optimized, stats


class _IRLoopUnroller:
    def __init__(self, factor: int, stats: IROptimizationStats) -> None:
        self.factor = factor
        self.stats = stats
        self._next_temp = 0

    def run(self, instructions: list[IRInstruction]) -> list[IRInstruction]:
        if self.factor == 1:
            return list(instructions)

        self._next_temp = self._first_available_temp(instructions)
        output: list[IRInstruction] = []
        constants: dict[str, int] = {}
        index = 0

        while index < len(instructions):
            match = self._match_counted_loop(instructions, index, constants)
            if match is None:
                instr = instructions[index]
                output.append(instr)
                self._update_constants(instr, constants)
                index += 1
                continue

            self.stats.loops_seen += 1
            replacement = self._unroll_match(match)
            if replacement is None:
                self.stats.loops_skipped += 1
                output.extend(instructions[index : match.end_index + 1])
            else:
                output.extend(replacement)
            constants.clear()
            index = match.end_index + 1

        return output

    def _match_counted_loop(
        self,
        instructions: list[IRInstruction],
        index: int,
        constants: dict[str, int],
    ) -> "_LoopMatch | None":
        if index + 4 >= len(instructions) or not isinstance(instructions[index], IRLabel):
            return None

        start_label = instructions[index]
        condition = instructions[index + 1]
        branch = instructions[index + 2]
        if (
            not isinstance(condition, IRBinOp)
            or condition.op not in {"<", "<="}
            or not isinstance(condition.left, str)
            or not isinstance(condition.right, int)
            or not isinstance(branch, IRJumpIfFalse)
            or branch.condition != condition.result
        ):
            return None

        variable = condition.left
        start_value = constants.get(variable)
        if start_value is None:
            return None

        jump_index = self._find_back_jump(instructions, index + 3, start_label.name)
        if jump_index is None or jump_index + 1 >= len(instructions):
            return None

        end_label = instructions[jump_index + 1]
        if not isinstance(end_label, IRLabel) or end_label.name != branch.label:
            return None

        body = instructions[index + 3 : jump_index]
        increment = self._match_increment(body, variable)
        if increment is None:
            return None

        step, body_without_increment = increment
        if step <= 0 or self._has_unroll_barrier(body_without_increment):
            return None

        limit = condition.right + (1 if condition.op == "<=" else 0)
        iterations = max(0, (limit - start_value + step - 1) // step)
        if iterations <= 0:
            return None

        return _LoopMatch(
            start_index=index,
            end_index=jump_index + 1,
            start_label=start_label,
            condition=condition,
            branch=branch,
            body=body_without_increment,
            jump=instructions[jump_index],
            end_label=end_label,
            variable=variable,
            start_value=start_value,
            limit=limit,
            step=step,
            iterations=iterations,
        )

    def _find_back_jump(
        self,
        instructions: list[IRInstruction],
        start: int,
        label: str,
    ) -> int | None:
        for index in range(start, len(instructions)):
            instr = instructions[index]
            if isinstance(instr, IRJump) and instr.label == label:
                return index
            if isinstance(instr, IRLabel):
                return None
        return None

    def _match_increment(
        self,
        body: list[IRInstruction],
        variable: str,
    ) -> tuple[int, list[IRInstruction]] | None:
        if len(body) < 2:
            return None

        op = body[-2]
        assign = body[-1]
        if (
            not isinstance(op, IRBinOp)
            or op.op not in {"+", "-"}
            or op.left != variable
            or not isinstance(op.right, int)
            or not isinstance(assign, IRAssign)
            or assign.result != variable
            or assign.source != op.result
        ):
            return None

        step = op.right if op.op == "+" else -op.right
        return step, body[:-2]

    def _has_unroll_barrier(self, body: list[IRInstruction]) -> bool:
        return any(
            isinstance(
                instr,
                (IRCall, IRJump, IRJumpIfFalse, IRLabel, IRReturn, IRVaultInstruction),
            )
            for instr in body
        )

    def _unroll_match(self, match: "_LoopMatch") -> list[IRInstruction] | None:
        factor = self._select_factor(match)
        if factor <= 1:
            return None

        if match.iterations < factor:
            raise IROptimizationError(
                "loop unrolling: el factor "
                f"{factor} es mayor que las {match.iterations} "
                f"iteraciones conocidas del loop '{match.start_label.name}'"
            )

        unrolled_iterations = match.iterations - (match.iterations % factor)
        main_limit = match.start_value + (unrolled_iterations * match.step)
        remainder_start = match.start_value + (unrolled_iterations * match.step)

        result: list[IRInstruction] = [
            match.start_label,
            IRBinOp(
                match.condition.op,
                match.variable,
                main_limit,
                self._fresh_like(match.condition.result),
            ),
        ]
        condition_temp = result[-1].result
        result.append(IRJumpIfFalse(condition_temp, match.end_label.name))

        for copy_index in range(factor):
            result.extend(
                self._clone_body(
                    match.body,
                    variable=match.variable,
                    offset=copy_index * match.step,
                    constant=None,
                )
            )

        result.extend(self._increment(match.variable, match.step * factor))
        result.append(match.jump)
        result.append(match.end_label)

        for value in range(remainder_start, match.limit, match.step):
            result.extend(
                self._clone_body(
                    match.body,
                    variable=match.variable,
                    offset=0,
                    constant=value,
                )
            )

        self.stats.loops_unrolled += 1
        self.stats.duplicated_instructions += len(match.body) * (factor - 1)
        if self.stats.selected_unroll_factors is not None:
            self.stats.selected_unroll_factors.append(factor)
        return result

    def _select_factor(self, match: "_LoopMatch") -> int:
        if self.factor != AUTO_UNROLL_FACTOR:
            return self.factor

        body_size = len(match.body)
        max_factor = min(MAX_AUTO_UNROLL_FACTOR, match.iterations)
        if max_factor < 2:
            return 1

        if body_size <= 2 and match.iterations >= 16 and max_factor >= 8:
            return 8
        if body_size <= 6 and match.iterations >= 8 and max_factor >= 4:
            return 4
        return 2

    def _clone_body(
        self,
        body: list[IRInstruction],
        *,
        variable: str,
        offset: int,
        constant: int | None,
    ) -> list[IRInstruction]:
        temp_map: dict[str, str] = {}
        return [
            self._clone_instruction(instr, variable, offset, constant, temp_map)
            for instr in body
        ]

    def _clone_instruction(
        self,
        instr: IRInstruction,
        variable: str,
        offset: int,
        constant: int | None,
        temp_map: dict[str, str],
    ) -> IRInstruction:
        if isinstance(instr, IRBinOp):
            result = self._fresh_like(instr.result)
            temp_map[instr.result] = result
            return IRBinOp(
                instr.op,
                self._replace_operand(instr.left, variable, offset, constant, temp_map),
                self._replace_operand(instr.right, variable, offset, constant, temp_map),
                result,
            )
        if isinstance(instr, IRUnaryOp):
            result = self._fresh_like(instr.result)
            temp_map[instr.result] = result
            return IRUnaryOp(
                instr.op,
                self._replace_operand(instr.operand, variable, offset, constant, temp_map),
                result,
            )
        if isinstance(instr, IRAssign):
            result = self._replace_operand(instr.result, variable, offset, constant, temp_map)
            if isinstance(instr.result, str) and self._is_temp(instr.result):
                result = self._fresh_like(instr.result)
                temp_map[instr.result] = result
            return IRAssign(
                self._replace_operand(instr.source, variable, offset, constant, temp_map),
                result,
            )
        return instr

    def _replace_operand(
        self,
        operand: Any,
        variable: str,
        offset: int,
        constant: int | None,
        temp_map: dict[str, str],
    ) -> Any:
        if not isinstance(operand, str):
            return operand
        if operand in temp_map:
            return temp_map[operand]
        if operand == variable:
            if constant is not None:
                return constant
            if offset == 0:
                return variable
            return f"({variable} + {offset})"
        if constant is not None:
            return re.sub(rf"\b{re.escape(variable)}\b", str(constant), operand)
        if offset != 0:
            return re.sub(
                rf"\b{re.escape(variable)}\b",
                f"({variable} + {offset})",
                operand,
            )
        return operand

    def _increment(self, variable: str, step: int) -> list[IRInstruction]:
        temp = self._fresh_temp()
        return [
            IRBinOp("+", variable, step, temp),
            IRAssign(temp, variable),
        ]

    def _fresh_like(self, value: str) -> str:
        if self._is_temp(value):
            return self._fresh_temp()
        return value

    def _fresh_temp(self) -> str:
        temp = f"t{self._next_temp}"
        self._next_temp += 1
        return temp

    def _first_available_temp(self, instructions: list[IRInstruction]) -> int:
        highest = -1
        for instr in instructions:
            for value in vars(instr).values():
                if isinstance(value, str) and self._is_temp(value):
                    highest = max(highest, int(value[1:]))
        return highest + 1

    def _is_temp(self, value: str) -> bool:
        return bool(re.fullmatch(r"t\d+", value))

    def _update_constants(self, instr: IRInstruction, constants: dict[str, int]) -> None:
        if isinstance(instr, IRAssign) and isinstance(instr.source, int):
            constants[instr.result] = instr.source
            return
        if isinstance(instr, IRAssign):
            constants.pop(instr.result, None)
        elif isinstance(instr, (IRJump, IRJumpIfFalse, IRLabel, IRReturn)):
            constants.clear()


@dataclass
class _LoopMatch:
    start_index: int
    end_index: int
    start_label: IRLabel
    condition: IRBinOp
    branch: IRJumpIfFalse
    body: list[IRInstruction]
    jump: IRJump
    end_label: IRLabel
    variable: str
    start_value: int
    limit: int
    step: int
    iterations: int


class _IRStaticRegisterRenamer:
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
