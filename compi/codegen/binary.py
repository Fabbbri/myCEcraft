from __future__ import annotations

import re
from dataclasses import dataclass
from struct import pack

from isa import InstructionFormat, require_instruction
from registers import require_general_register, require_vault_register


class EncodingError(Exception):
    """
    Error durante la fase 6: generacion de codigo binario.
    """


@dataclass(frozen=True)
class EncodedInstruction:
    pc: int
    source: str
    word: int

    @property
    def hex_word(self) -> str:
        return f"{self.word:08X}"


@dataclass(frozen=True)
class DataItem:
    address: int
    size: int
    value: int | None
    source: str
    data: bytes

    @property
    def hex_bytes(self) -> str:
        return self.data.hex().upper()


@dataclass(frozen=True)
class ProgramHeader:
    magic: bytes
    version: int
    header_size: int
    entry_point: int
    text_offset: int
    text_size: int
    data_offset: int
    data_size: int
    text_base: int
    data_base: int
    instruction_count: int
    flags: int = 0

    FORMAT = ">4sHHIIIIIIIII"
    SIZE = 44

    def to_bytes(self) -> bytes:
        return pack(
            self.FORMAT,
            self.magic,
            self.version,
            self.header_size,
            self.entry_point,
            self.text_offset,
            self.text_size,
            self.data_offset,
            self.data_size,
            self.text_base,
            self.data_base,
            self.instruction_count,
            self.flags,
        )


@dataclass(frozen=True)
class BinaryResult:
    instructions: list[EncodedInstruction]
    data_items: list[DataItem]
    header: ProgramHeader

    @property
    def hex_text(self) -> str:
        return "\n".join(instruction.hex_word for instruction in self.instructions) + "\n"

    @property
    def text_binary(self) -> bytes:
        output = bytearray()
        for instruction in self.instructions:
            output.extend(instruction.word.to_bytes(4, byteorder="big", signed=False))
        return bytes(output)

    @property
    def data_binary(self) -> bytes:
        return b"".join(item.data for item in self.data_items)

    @property
    def binary(self) -> bytes:
        return self.header.to_bytes() + self.text_binary + self.data_binary

    @property
    def data_hex_text(self) -> str:
        if not self.data_items:
            return ""
        return "\n".join(f"{byte:02X}" for byte in self.data_binary) + "\n"

    @property
    def listing_text(self) -> str:
        lines = [
            "; ==================================================",
            "; Fase 6 - codigo binario generado",
            "; ==================================================",
            "",
            "; Encabezado MYCE",
            f";   magic             = {self.header.magic.decode('ascii')}",
            f";   version           = {self.header.version}",
            f";   header_size       = {self.header.header_size} bytes",
            f";   entry_point       = 0x{self.header.entry_point:08X}",
            f";   text_offset       = {self.header.text_offset}",
            f";   text_size         = {self.header.text_size} bytes",
            f";   data_offset       = {self.header.data_offset}",
            f";   data_size         = {self.header.data_size} bytes",
            f";   text_base         = 0x{self.header.text_base:08X}",
            f";   data_base         = 0x{self.header.data_base:08X}",
            f";   instruction_count = {self.header.instruction_count}",
            "",
            "; Seccion .text",
        ]

        for instruction in self.instructions:
            lines.append(
                f"0x{instruction.pc:04X}: {instruction.hex_word}    ; {instruction.source}"
            )

        lines.extend(["", "; Seccion .data"])

        if self.data_items:
            for item in self.data_items:
                lines.append(
                    f"0x{item.address:08X}: {item.hex_bytes:<16} ; {item.source}"
                )
        else:
            lines.append("; <sin datos globales>")

        return "\n".join(lines) + "\n"


class BinaryEncoder:
    """
    Fase 6: convierte ensamblador resuelto en palabras binarias de 32 bits.
    """

    PC_RE = re.compile(r"\bpc=0x(?P<pc>[0-9a-fA-F]+)\b")
    DATA_ADDR_RE = re.compile(r"\baddr=0x(?P<addr>[0-9a-fA-F]+)\b")
    MEMORY_RE = re.compile(
        r"^(?P<offset>[+-]?(?:0x[0-9a-fA-F]+|\d+))\((?P<base>[A-Za-z_][\w]*)\)$"
    )

    def encode(self, assembly: str) -> BinaryResult:
        instructions: list[EncodedInstruction] = []
        data_items: list[DataItem] = []
        in_text = False
        in_data = False
        current_data_address: int | None = None

        for line_number, line in enumerate(assembly.splitlines(), start=1):
            stripped = line.strip()

            if stripped == ".data":
                in_data = True
                in_text = False
                continue

            if stripped == ".text":
                in_data = False
                in_text = True
                continue

            if in_data:
                parsed_data = self._parse_data_line(line, current_data_address, line_number)
                if parsed_data is not None:
                    current_data_address = parsed_data[0]
                    if parsed_data[1] is not None:
                        data_items.append(parsed_data[1])
                continue

            if self._is_directive(stripped):
                in_text = stripped == ".text"
                in_data = stripped == ".data"
                continue

            if not in_text:
                continue

            parsed = self._parse_instruction_line(line)
            if parsed is None:
                continue

            pc, source, mnemonic, operands = parsed
            word = self._encode_instruction(mnemonic, operands, line_number)
            instructions.append(EncodedInstruction(pc=pc, source=source, word=word))

        header = self._build_header(instructions, data_items)
        return BinaryResult(instructions=instructions, data_items=data_items, header=header)

    def _build_header(
        self,
        instructions: list[EncodedInstruction],
        data_items: list[DataItem],
    ) -> ProgramHeader:
        text_size = len(instructions) * 4
        data_size = sum(len(item.data) for item in data_items)
        text_offset = ProgramHeader.SIZE
        data_offset = text_offset + text_size
        text_base = instructions[0].pc if instructions else 0
        data_base = data_items[0].address if data_items else 0

        return ProgramHeader(
            magic=b"MYCE",
            version=1,
            header_size=ProgramHeader.SIZE,
            entry_point=text_base,
            text_offset=text_offset,
            text_size=text_size,
            data_offset=data_offset,
            data_size=data_size,
            text_base=text_base,
            data_base=data_base,
            instruction_count=len(instructions),
        )

    def _parse_instruction_line(
        self,
        line: str,
    ) -> tuple[int, str, str, list[str]] | None:
        pc_match = self.PC_RE.search(line)
        if pc_match is None:
            return None

        code = line.split(";", 1)[0].strip()
        if not code or code.endswith(":"):
            return None

        parts = code.split(None, 1)
        mnemonic = parts[0]
        operands = []
        if len(parts) > 1:
            operands = [operand.strip() for operand in parts[1].split(",")]

        return int(pc_match.group("pc"), 16), code, mnemonic, operands

    def _parse_data_line(
        self,
        line: str,
        current_address: int | None,
        line_number: int,
    ) -> tuple[int | None, DataItem | None] | None:
        code = line.split(";", 1)[0].strip()
        if not code:
            return None

        addr_match = self.DATA_ADDR_RE.search(line)
        if code.endswith(":"):
            if addr_match is None:
                raise EncodingError(
                    f"linea {line_number}: etiqueta .data sin direccion addr=0x..."
                )
            address = int(addr_match.group("addr"), 16)
            if current_address is not None:
                if address < current_address:
                    raise EncodingError(
                        f"linea {line_number}: direccion .data retrocede de "
                        f"0x{current_address:08X} a 0x{address:08X}"
                    )
                if address > current_address:
                    gap_size = address - current_address
                    gap = DataItem(
                        current_address,
                        gap_size,
                        None,
                        f".space {gap_size} ; gap hasta 0x{address:08X}",
                        bytes(gap_size),
                    )
                    return address, gap

            return address, None

        if current_address is None:
            raise EncodingError(
                f"linea {line_number}: directiva .data antes de una etiqueta con direccion"
            )

        parts = code.split(None, 1)
        directive = parts[0]
        value_text = parts[1].strip() if len(parts) > 1 else ""

        if directive == ".word":
            value = self._immediate(value_text, line_number)
            data = (value & 0xFFFFFFFF).to_bytes(4, byteorder="little", signed=False)
            item = DataItem(current_address, 4, value, code, data)
            return current_address + 4, item

        if directive == ".half":
            value = self._immediate(value_text, line_number)
            data = (value & 0xFFFF).to_bytes(2, byteorder="little", signed=False)
            item = DataItem(current_address, 2, value, code, data)
            return current_address + 2, item

        if directive == ".byte":
            value = self._immediate(value_text, line_number)
            data = bytes([value & 0xFF])
            item = DataItem(current_address, 1, value, code, data)
            return current_address + 1, item

        if directive == ".space":
            size = self._immediate(value_text, line_number)
            self._check_range(size, 0, 1_000_000, directive, line_number)
            data = bytes(size)
            item = DataItem(current_address, size, None, code, data)
            return current_address + size, item

        raise EncodingError(f"linea {line_number}: directiva .data no soportada: {directive}")

    def _encode_instruction(
        self,
        mnemonic: str,
        operands: list[str],
        line_number: int,
    ) -> int:
        try:
            spec = require_instruction(mnemonic)
        except ValueError as error:
            raise EncodingError(f"linea {line_number}: {error}") from error

        if spec.format == InstructionFormat.R:
            return self._encode_r(mnemonic, operands, line_number)
        if spec.format == InstructionFormat.I:
            return self._encode_i(mnemonic, operands, line_number)
        if spec.format == InstructionFormat.S:
            return self._encode_s(mnemonic, operands, line_number)
        if spec.format == InstructionFormat.J:
            return self._encode_j(mnemonic, operands, line_number)
        if spec.format == InstructionFormat.B:
            return self._encode_b(mnemonic, operands, line_number)
        if spec.format == InstructionFormat.VS:
            return self._encode_vs(mnemonic, operands, line_number)
        if spec.format == InstructionFormat.IV:
            return self._encode_iv(mnemonic, operands, line_number)
        if spec.format == InstructionFormat.VR:
            return self._encode_vr(mnemonic, operands, line_number)

        raise EncodingError(
            f"linea {line_number}: formato {spec.format.value} aun no soportado"
        )

    def _encode_r(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)

        if mnemonic in {"sleep", "freeze"} and not operands:
            rd = rs1 = rs2 = 0
        else:
            self._expect_operands(mnemonic, operands, 3, line_number)
            rd = self._register(operands[0], line_number)
            rs1 = self._register(operands[1], line_number)
            rs2 = self._register(operands[2], line_number)

        return (
            spec.opcode
            | (rd << 4)
            | (rs1 << 9)
            | (rs2 << 14)
            | ((spec.func or 0) << 19)
        )

    def _encode_i(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)
        self._expect_operands(mnemonic, operands, 3, line_number)

        rd = self._register(operands[0], line_number)
        rs1 = self._register(operands[1], line_number)
        immediate = self._immediate(operands[2], line_number)

        if mnemonic == "addiSigned":
            self._check_range(immediate, -32768, 32767, mnemonic, line_number)
        else:
            self._check_range(immediate, 0, 0xFFFF, mnemonic, line_number)

        imm16 = immediate & 0xFFFF
        return (
            spec.opcode
            | (rd << 4)
            | (rs1 << 9)
            | ((spec.func or 0) << 14)
            | (imm16 << 16)
        )

    def _encode_s(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)
        self._expect_operands(mnemonic, operands, 2, line_number)

        value_reg = self._register(operands[0], line_number)
        offset, base_reg = self._memory_operand(operands[1], line_number)
        self._check_range(offset, -4096, 4095, mnemonic, line_number)

        imm13 = offset & 0x1FFF
        imm_low5 = imm13 & 0x1F
        imm_high8 = (imm13 >> 5) & 0xFF

        if mnemonic in {"sw", "sb"}:
            return (
                spec.opcode
                | (imm_low5 << 4)
                | (base_reg << 9)
                | (value_reg << 14)
                | ((spec.func or 0) << 19)
                | (imm_high8 << 20)
            )

        return (
            spec.opcode
            | (value_reg << 4)
            | (base_reg << 9)
            | (imm_low5 << 14)
            | ((spec.func or 0) << 19)
            | (imm_high8 << 20)
        )

    def _encode_j(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)
        self._expect_operands(mnemonic, operands, 2, line_number)

        rd = self._register(operands[0], line_number)
        offset = self._immediate(operands[1], line_number)
        self._check_aligned(offset, mnemonic, line_number)
        self._check_range(offset, -524288, 524284, mnemonic, line_number)

        imm20 = offset & 0xFFFFF
        imm_low5 = (imm20 >> 2) & 0x1F
        imm_mid5 = (imm20 >> 7) & 0x1F
        imm_high8 = (imm20 >> 12) & 0xFF

        return (
            spec.opcode
            | (rd << 4)
            | (imm_low5 << 9)
            | (imm_mid5 << 14)
            | ((spec.func or 0) << 19)
            | (imm_high8 << 20)
        )

    def _encode_b(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)
        self._expect_operands(mnemonic, operands, 3, line_number)

        rs1 = self._register(operands[0], line_number)
        rs2 = self._register(operands[1], line_number)
        offset = self._immediate(operands[2], line_number)
        self._check_aligned(offset, mnemonic, line_number)
        self._check_range(offset, -16384, 16380, mnemonic, line_number)

        imm15 = offset & 0x7FFF
        imm_low5 = (imm15 >> 2) & 0x1F
        imm_high8 = (imm15 >> 7) & 0xFF

        return (
            spec.opcode
            | (imm_low5 << 4)
            | (rs1 << 9)
            | (rs2 << 14)
            | ((spec.func or 0) << 19)
            | (imm_high8 << 24)
        )

    def _encode_vs(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)
        self._expect_operands(mnemonic, operands, 2, line_number)

        value_reg = self._vault_register(operands[0], line_number)
        offset, base_reg = self._vault_memory_operand(operands[1], line_number)
        self._check_range(offset, -4096, 4095, mnemonic, line_number)

        imm13 = offset & 0x1FFF
        imm_low5 = imm13 & 0x1F
        imm_high8 = (imm13 >> 5) & 0xFF

        if mnemonic == "swv":
            return (
                spec.opcode
                | (imm_low5 << 4)
                | (base_reg << 9)
                | (value_reg << 14)
                | ((spec.func or 0) << 19)
                | (imm_high8 << 20)
            )

        return (
            spec.opcode
            | (value_reg << 4)
            | (base_reg << 9)
            | (imm_low5 << 14)
            | ((spec.func or 0) << 19)
            | (imm_high8 << 20)
        )

    def _encode_iv(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)
        self._expect_operands(mnemonic, operands, 3, line_number)

        rd = self._vault_register(operands[0], line_number)
        rs1 = self._vault_register(operands[1], line_number)
        immediate = self._immediate(operands[2], line_number)
        self._check_range(immediate, 0, 0xFFFF, mnemonic, line_number)

        return (
            spec.opcode
            | (rd << 4)
            | (rs1 << 9)
            | ((spec.func or 0) << 14)
            | ((immediate & 0xFFFF) << 16)
        )

    def _encode_vr(self, mnemonic: str, operands: list[str], line_number: int) -> int:
        spec = require_instruction(mnemonic)

        if mnemonic == "closev" and not operands:
            rd = rs1 = rs2 = 0
        elif mnemonic == "changev" and len(operands) == 2:
            rd = self._vault_register(operands[0], line_number)
            rs1 = self._vault_register(operands[1], line_number)
            rs2 = 0
        elif mnemonic == "changev" and len(operands) == 3:
            rd = self._vault_register(operands[0], line_number)
            rs1 = self._register(operands[1], line_number)
            rs2 = self._register(operands[2], line_number)
        else:
            self._expect_operands(mnemonic, operands, 3, line_number)
            rd = self._vault_register(operands[0], line_number)
            rs1 = self._vault_register(operands[1], line_number)
            rs2 = self._vault_register(operands[2], line_number)

        return (
            spec.opcode
            | (rd << 4)
            | (rs1 << 9)
            | (rs2 << 14)
            | ((spec.func or 0) << 19)
        )

    def _expect_operands(
        self,
        mnemonic: str,
        operands: list[str],
        expected: int,
        line_number: int,
    ) -> None:
        if len(operands) != expected:
            raise EncodingError(
                f"linea {line_number}: {mnemonic} esperaba {expected} operandos, "
                f"recibio {len(operands)}"
            )

    def _register(self, value: str, line_number: int) -> int:
        try:
            return require_general_register(value).index
        except ValueError as error:
            raise EncodingError(f"linea {line_number}: {error}") from error

    def _vault_register(self, value: str, line_number: int) -> int:
        try:
            return require_vault_register(value).index
        except ValueError as error:
            raise EncodingError(f"linea {line_number}: {error}") from error

    def _immediate(self, value: str, line_number: int) -> int:
        try:
            return int(value, 0)
        except ValueError as error:
            raise EncodingError(
                f"linea {line_number}: inmediato invalido: {value}"
            ) from error

    def _memory_operand(self, value: str, line_number: int) -> tuple[int, int]:
        match = self.MEMORY_RE.match(value)
        if match is None:
            raise EncodingError(
                f"linea {line_number}: operando de memoria invalido: {value}"
            )

        offset = self._immediate(match.group("offset"), line_number)
        base_reg = self._register(match.group("base"), line_number)
        return offset, base_reg

    def _vault_memory_operand(self, value: str, line_number: int) -> tuple[int, int]:
        match = self.MEMORY_RE.match(value)
        if match is None:
            raise EncodingError(
                f"linea {line_number}: operando de memoria vault invalido: {value}"
            )

        offset = self._immediate(match.group("offset"), line_number)
        base_reg = self._vault_register(match.group("base"), line_number)
        return offset, base_reg

    def _check_range(
        self,
        value: int,
        lower: int,
        upper: int,
        mnemonic: str,
        line_number: int,
    ) -> None:
        if not lower <= value <= upper:
            raise EncodingError(
                f"linea {line_number}: inmediato fuera de rango para {mnemonic}: {value}"
            )

    def _check_aligned(self, value: int, mnemonic: str, line_number: int) -> None:
        if value % 4 != 0:
            raise EncodingError(
                f"linea {line_number}: offset no alineado para {mnemonic}: {value}"
            )

    def _is_directive(self, stripped: str) -> bool:
        if not stripped:
            return False
        if stripped.endswith(":"):
            return False
        return stripped.startswith(".")
