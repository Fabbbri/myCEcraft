from __future__ import annotations

from dataclasses import dataclass
import re
from typing import Any

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

from .common import (
    AUTO_UNROLL_FACTOR,
    IROptimizationError,
    IROptimizationStats,
    MAX_AUTO_UNROLL_FACTOR,
)


class IRLoopUnroller:
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
            or not isinstance(branch, IRJumpIfFalse)
            or branch.condition != condition.result
        ):
            return None

        # El limite puede ser un literal entero o una variable con valor conocido
        if isinstance(condition.right, int):
            limit_value: int | None = condition.right
        elif isinstance(condition.right, str):
            limit_value = constants.get(condition.right)
        else:
            limit_value = None
        if limit_value is None:
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

        limit = limit_value + (1 if condition.op == "<=" else 0)
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
                (
                    IRArrayAssign,
                    IRCall,
                    IRJump,
                    IRJumpIfFalse,
                    IRLabel,
                    IRReturn,
                    IRVaultInstruction,
                ),
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

        # Instrucciones del cuerpo cuyo valor no depende de la variable de
        # induccion producen el mismo resultado en cada copia desenrollada.
        # Se calculan una sola vez (en la primera copia) y se reutilizan en las
        # demas, evitando duplicar aritmetica de direcciones invariante.
        invariant_flags = self._classify_invariants(match.body, match.variable)
        shared_temp_map: dict[str, str] = {}

        for copy_index in range(factor):
            result.extend(
                self._clone_body(
                    match.body,
                    variable=match.variable,
                    offset=copy_index * match.step,
                    constant=None,
                    invariant_flags=invariant_flags,
                    shared_temp_map=shared_temp_map,
                    emit_invariants=(copy_index == 0),
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
            result.extend(self._increment(match.variable, match.step))

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
        invariant_flags: list[bool] | None = None,
        shared_temp_map: dict[str, str] | None = None,
        emit_invariants: bool = True,
    ) -> list[IRInstruction]:
        temp_map: dict[str, str] = {}
        # Sembrar el mapa con los temporales invariantes ya calculados por la
        # primera copia, para que las copias siguientes los reutilicen.
        if shared_temp_map is not None:
            temp_map.update(shared_temp_map)

        cloned: list[IRInstruction] = []
        for position, instr in enumerate(body):
            is_invariant = bool(invariant_flags[position]) if invariant_flags else False

            # En copias posteriores las invariantes ya estan emitidas: se omiten
            # y sus usos se resuelven via temp_map sembrado.
            if is_invariant and not emit_invariants:
                continue

            new_instr = self._clone_instruction(
                instr, variable, offset, constant, temp_map
            )
            cloned.append(new_instr)

            # La primera copia registra el resultado de cada invariante para que
            # las copias siguientes la compartan en lugar de recalcularla.
            if is_invariant and shared_temp_map is not None and emit_invariants:
                original = getattr(instr, "result", None)
                if isinstance(original, str) and original in temp_map:
                    shared_temp_map[original] = temp_map[original]

        return cloned

    def _classify_invariants(
        self, body: list[IRInstruction], variable: str
    ) -> list[bool]:
        """Marca las instrucciones del cuerpo invariantes respecto a `variable`.

        Una instruccion es invariante si produce un temporal y todos sus
        operandos son constantes, nombres definidos fuera del cuerpo, o
        temporales que a su vez son invariantes (cierre transitivo). La variable
        de induccion y cualquier nombre reasignado dentro del cuerpo la hacen
        variante.
        """

        defined_in_body = {
            instr.result
            for instr in body
            if isinstance(getattr(instr, "result", None), str)
        }

        flags: list[bool] = []
        invariant_results: set[str] = set()
        for instr in body:
            result = getattr(instr, "result", None)
            shareable = isinstance(instr, (IRBinOp, IRUnaryOp, IRAssign)) and (
                isinstance(result, str) and self._is_temp(result)
            )

            is_invariant = shareable
            if is_invariant:
                for name in self._operand_names(instr):
                    if name == variable:
                        is_invariant = False
                        break
                    if name in defined_in_body and name not in invariant_results:
                        is_invariant = False
                        break

            flags.append(is_invariant)
            if is_invariant and isinstance(result, str):
                invariant_results.add(result)

        return flags

    def _operand_names(self, instr: IRInstruction) -> set[str]:
        if isinstance(instr, IRBinOp):
            raw: list[Any] = [instr.left, instr.right]
        elif isinstance(instr, IRUnaryOp):
            raw = [instr.operand]
        elif isinstance(instr, IRAssign):
            raw = [instr.source]
        else:
            return set()

        names: set[str] = set()
        for operand in raw:
            if isinstance(operand, str):
                names.update(re.findall(r"[A-Za-z_][A-Za-z0-9_]*", operand))
        return names

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

        # Operando compuesto (p.ej. "bloques[t3]" o "arr[i + 1]"): hay que
        # reescribir los temporales renombrados del cuerpo clonado y la
        # variable de induccion que aparezcan embebidos en la cadena, no solo
        # cuando el operando coincide exacto.
        result = operand
        for old_temp, new_temp in temp_map.items():
            result = re.sub(rf"\b{re.escape(old_temp)}\b", new_temp, result)
        if constant is not None:
            return re.sub(rf"\b{re.escape(variable)}\b", str(constant), result)
        if offset != 0:
            return re.sub(
                rf"\b{re.escape(variable)}\b",
                f"({variable} + {offset})",
                result,
            )
        return result

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
                values = value if isinstance(value, list) else [value]
                for item in values:
                    if isinstance(item, str) and self._is_temp(item):
                        highest = max(highest, int(item[1:]))
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