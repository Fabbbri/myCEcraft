from __future__ import annotations

from symbol_table import Symbol

from registers import ZERO

from .errors import CodegenError


class EmitMixin:
    NOP_AFTER_CONTROL_TRANSFER = True
    CONTROL_TRANSFER_STALL_CYCLES = 2
    NOP_CONTROL_TRANSFER = {
        "beq",
        "bne",
        "blt",
        "bge",
        "portalv",
        "jal",
        "jalr",
    }
    RAW_STALL_CYCLES = 3
    RAW_WRITEBACK = {
        "add",
        "sub",
        "sll",
        "slt",
        "xor",
        "srl",
        "sra",
        "or",
        "and",
        "mul",
        "div",
        "addi",
        "addiHIGH",
        "addiSigned",
        "lw",
        "lb",
        "jal",
        "jalr",
        "sllv",
        "slrv",
        "changev",
        "lwv",
        "addiLOWv",
        "addiHIGHv",
    }

    def _emit(self, line: str) -> None:
        self.lines.append(line)
        if self.NOP_AFTER_CONTROL_TRANSFER and self._needs_control_transfer_nop(line):
            for _ in range(self.CONTROL_TRANSFER_STALL_CYCLES):
                self.lines.append("    sleep ; nop despues de control")
        if self.RAW_STALL_CYCLES and self._needs_raw_stall(line):
            for _ in range(self.RAW_STALL_CYCLES):
                self.lines.append("    sleep ; stall RAW")

    def _needs_control_transfer_nop(self, line: str) -> bool:
        code = line.split(";", 1)[0].strip()
        if not code or code.endswith(":") or code.startswith("."):
            return False

        mnemonic = code.split(None, 1)[0]
        return mnemonic in self.NOP_CONTROL_TRANSFER

    def _needs_raw_stall(self, line: str) -> bool:
        code = line.split(";", 1)[0].strip()
        if not code or code.endswith(":") or code.startswith("."):
            return False

        mnemonic = code.split(None, 1)[0]
        if mnemonic in {"sleep", "freeze"}:
            return False

        if mnemonic in self.NOP_CONTROL_TRANSFER:
            return False

        return mnemonic in self.RAW_WRITEBACK

    def _with_instruction_addresses(self, assembly: str) -> str:
        result: list[str] = []
        instruction_address = 0

        for line in assembly.splitlines():
            stripped = line.strip()

            if self._is_real_instruction(stripped):
                result.append(f"{line:<55} ; pc=0x{instruction_address:04X}")
                instruction_address += 4
            else:
                result.append(line)

        return "\n".join(result)

    def _is_real_instruction(self, stripped: str) -> bool:
        if not stripped:
            return False

        if stripped.startswith(";"):
            return False

        if stripped.startswith("."):
            return False

        if stripped.endswith(":"):
            return False

        mnemonic = stripped.split()[0]

        return mnemonic in {
            "add",
            "sub",
            "sll",
            "slt",
            "xor",
            "srl",
            "sra",
            "or",
            "and",
            "mul",
            "div",
            "sleep",
            "freeze",
            "addi",
            "addiHIGH",
            "addiSigned",
            "sw",
            "lw",
            "sb",
            "lb",
            "jal",
            "jalr",
            "beq",
            "bne",
            "blt",
            "bge",
            "portalv",
            "sllv",
            "slrv",
            "changev",
            "closev",
            "swv",
            "lwv",
            "addiLOWv",
            "addiHIGHv",
        }

    def _emit_load_immediate(self, target_reg: str, value: int) -> None:
        if -32768 <= value <= -1:
            self._emit(f"    addiSigned {target_reg}, {ZERO.asm()}, {value}")
            return

        if 0 <= value <= 32767:
            self._emit(f"    addi {target_reg}, {ZERO.asm()}, {value}")
            return

        upper = (value >> 16) & 0xFFFF
        lower = value & 0xFFFF

        self._emit(f"    addiHIGH {target_reg}, {ZERO.asm()}, {upper}")

        if lower != 0:
            self._emit(f"    addi {target_reg}, {target_reg}, {lower}")

    def _emit_add_immediate(self, target_reg: str, base_reg: str, value: int) -> None:
        if value < 0:
            self._emit(f"    addiSigned {target_reg}, {base_reg}, {value}")
        else:
            self._emit(f"    addi {target_reg}, {base_reg}, {value}")

    def _load_global_address(self, symbol: Symbol, target_reg: str) -> None:
        address = symbol.memory_info.address

        if address is None:
            raise CodegenError(f"símbolo global sin dirección: {symbol.name}")

        self._emit_load_immediate(target_reg, address)
