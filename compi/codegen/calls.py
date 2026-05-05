from __future__ import annotations

from ast_nodes import CallExpression, FunctionDeclaration, Identifier

from symbol_table import ChestType, PrimitiveName, PrimitiveType

from registers import ARG_REGISTERS, FP, RA, SP, ZERO

from .errors import CodegenError


class CallsMixin:
    def _generate_call(self, node: CallExpression) -> str:
        if len(node.arguments) > len(ARG_REGISTERS):
            raise CodegenError("demasiados argumentos para llamada inicial", node)

        for index, argument in enumerate(node.arguments):
            target_arg_reg = ARG_REGISTERS[index].asm()

            if isinstance(argument, Identifier):
                symbol = self._lookup_visible_symbol(argument.name)

                if symbol is not None and isinstance(symbol.type, ChestType):
                    arg_reg = self._generate_chest_base_address(symbol, argument)
                else:
                    arg_reg = self._generate_expression(argument)
            else:
                arg_reg = self._generate_expression(argument)

            if arg_reg != target_arg_reg:
                self._emit(f"    add {target_arg_reg}, {arg_reg}, {ZERO.asm()}")

            self._release_temp(arg_reg)

        if node.module_alias is not None:
            function_label = f"{node.module_alias}.{node.name}"
            self._emit(f"    ; llamada externa mediante alias {node.module_alias}")
        else:
            function_label = node.name

        spilled_temps = self._spill_live_temporaries()
        self._emit(f"    jal {RA.asm()}, {function_label}")
        self._restore_live_temporaries(spilled_temps)

        if self._call_returns_void(node):
            raise CodegenError(
                "una función void no puede usarse como valor en una expresión",
                node,
            )

        result_reg = self._acquire_temp()
        self._emit(f"    add {result_reg}, {ARG_REGISTERS[0].asm()}, {ZERO.asm()}")
        return result_reg

    def _generate_void_call(self, node: CallExpression) -> None:
        if len(node.arguments) > len(ARG_REGISTERS):
            raise CodegenError("demasiados argumentos para llamada inicial", node)

        for index, argument in enumerate(node.arguments):
            target_arg_reg = ARG_REGISTERS[index].asm()

            if isinstance(argument, Identifier):
                symbol = self._lookup_visible_symbol(argument.name)

                if symbol is not None and isinstance(symbol.type, ChestType):
                    arg_reg = self._generate_chest_base_address(symbol, argument)
                else:
                    arg_reg = self._generate_expression(argument)
            else:
                arg_reg = self._generate_expression(argument)

            if arg_reg != target_arg_reg:
                self._emit(f"    add {target_arg_reg}, {arg_reg}, {ZERO.asm()}")

            self._release_temp(arg_reg)

        if node.module_alias is not None:
            function_label = f"{node.module_alias}.{node.name}"
            self._emit(f"    ; llamada externa mediante alias {node.module_alias}")
        else:
            function_label = node.name

        spilled_temps = self._spill_live_temporaries()
        self._emit(f"    jal {RA.asm()}, {function_label}")
        self._restore_live_temporaries(spilled_temps)

    def _store_incoming_arguments(self, node: FunctionDeclaration) -> None:
        for index, parameter in enumerate(node.parameters):
            if index >= len(ARG_REGISTERS):
                raise CodegenError(
                    "por ahora solo se soportan hasta 6 argumentos en registros",
                    parameter,
                )

            symbol = self._lookup_visible_symbol(parameter.name)
            if symbol is None:
                raise CodegenError(f"parámetro no encontrado: {parameter.name}", parameter)

            offset = symbol.memory_info.offset
            if offset is None:
                raise CodegenError(f"parámetro sin offset de memoria: {parameter.name}", parameter)

            arg_register = ARG_REGISTERS[index].asm()
            self._emit(f"    sw {arg_register}, {offset}({FP.asm()}) ; parámetro {parameter.name}")

        if node.parameters:
            self._emit("")

    def _call_returns_void(self, node: CallExpression) -> bool:
        if node.module_alias is not None:
            return False

        symbol = self.symbol_table.lookup_global(node.name)
        if symbol is None or symbol.type is None:
            return False

        return (
            isinstance(symbol.type, PrimitiveType)
            and symbol.type.name == PrimitiveName.VOID
        )

    def _spill_live_temporaries(self) -> list[str]:
        live_temps = list(self._used_temps)
        if not live_temps:
            return []

        bytes_needed = len(live_temps) * self.WORD_SIZE
        self._emit(f"    ; guardar temporales vivos antes de llamada")
        self._emit_add_immediate(SP.asm(), SP.asm(), -bytes_needed)
        for index, temp in enumerate(live_temps):
            self._emit(f"    sw {temp}, {index * self.WORD_SIZE}({SP.asm()})")
        return live_temps

    def _restore_live_temporaries(self, live_temps: list[str]) -> None:
        if not live_temps:
            return

        for index, temp in enumerate(live_temps):
            self._emit(f"    lw {temp}, {index * self.WORD_SIZE}({SP.asm()})")
        self._emit_add_immediate(SP.asm(), SP.asm(), len(live_temps) * self.WORD_SIZE)
        self._emit(f"    ; restaurar temporales vivos despues de llamada")
