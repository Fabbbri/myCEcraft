from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class InstructionFormat(Enum):
    """
    Formatos de instruccion de Craft21.

    Los registros se dejan fuera de este archivo por ahora porque el mapa de
    registros todavia esta cambiando.
    """

    R = "R"
    I = "I"
    S = "S"
    J = "J"
    B = "B"
    VR = "VR"  # Vault register
    VS = "VS"  # Vault load/store
    IV = "IV"  # Vault immediate


@dataclass(frozen=True)
class InstructionSpec:
    mnemonic: str
    format: InstructionFormat
    opcode: int
    func: int | None = None
    description: str = ""


INSTRUCTIONS: dict[str, InstructionSpec] = {
    # Tipo R: [23:19]=func, [18:14]=rs2, [13:9]=rs1, [8:4]=rd, [3:0]=opcode.
    "add": InstructionSpec("add", InstructionFormat.R, opcode=0b0000, func=0b00000),
    "sub": InstructionSpec("sub", InstructionFormat.R, opcode=0b0000, func=0b00001),
    "sll": InstructionSpec("sll", InstructionFormat.R, opcode=0b0000, func=0b00010),
    "slt": InstructionSpec("slt", InstructionFormat.R, opcode=0b0000, func=0b00011),
    "xor": InstructionSpec("xor", InstructionFormat.R, opcode=0b0000, func=0b00100),
    "srl": InstructionSpec("srl", InstructionFormat.R, opcode=0b0000, func=0b00101),
    "sra": InstructionSpec("sra", InstructionFormat.R, opcode=0b0000, func=0b00110),
    "or": InstructionSpec("or", InstructionFormat.R, opcode=0b0000, func=0b00111),
    "and": InstructionSpec("and", InstructionFormat.R, opcode=0b0000, func=0b01000),
    "mul": InstructionSpec("mul", InstructionFormat.R, opcode=0b0000, func=0b01001),
    "div": InstructionSpec("div", InstructionFormat.R, opcode=0b0000, func=0b01010),
    "sleep": InstructionSpec(
        "sleep",
        InstructionFormat.R,
        opcode=0b0000,
        func=0b01011,
        description="NOP/SLEEP",
    ),
    "freeze": InstructionSpec(
        "freeze",
        InstructionFormat.R,
        opcode=0b0000,
        func=0b01100,
        description="EBREAK/FREEZE",
    ),

    # Tipo I: [31:16]=imm, [15:14]=func, [13:9]=rs1, [8:4]=rd, [3:0]=opcode.
    "addi": InstructionSpec("addi", InstructionFormat.I, opcode=0b0001, func=0b00),
    "addiHIGH": InstructionSpec(
        "addiHIGH",
        InstructionFormat.I,
        opcode=0b0001,
        func=0b01,
        description="Carga/ajusta 16 bits altos",
    ),
    "addiSigned": InstructionSpec(
        "addiSigned",
        InstructionFormat.I,
        opcode=0b0001,
        func=0b10,
        description="Inmediato con signo",
    ),

    # Tipo S normal. Word usa opcode 0010; byte usa opcode 0011.
    "sw": InstructionSpec("sw", InstructionFormat.S, opcode=0b0010, func=0),
    "lw": InstructionSpec("lw", InstructionFormat.S, opcode=0b0010, func=1),
    "sb": InstructionSpec("sb", InstructionFormat.S, opcode=0b0011, func=0),
    "lb": InstructionSpec("lb", InstructionFormat.S, opcode=0b0011, func=1),

    # Tipo J.
    "jal": InstructionSpec("jal", InstructionFormat.J, opcode=0b0100, func=0),
    "jalr": InstructionSpec("jalr", InstructionFormat.J, opcode=0b0100, func=1),

    # Tipo B. portalv activa/usa el flujo de entrada a modo seguro.
    "beq": InstructionSpec("beq", InstructionFormat.B, opcode=0b0110, func=0b00000),
    "bne": InstructionSpec("bne", InstructionFormat.B, opcode=0b0110, func=0b00001),
    "blt": InstructionSpec("blt", InstructionFormat.B, opcode=0b0110, func=0b00010),
    "bge": InstructionSpec("bge", InstructionFormat.B, opcode=0b0110, func=0b00011),
    "portalv": InstructionSpec(
        "portalv",
        InstructionFormat.B,
        opcode=0b0110,
        func=0b00100,
        description="Branch/login para activar Secure Mode",
    ),

    # Tipo VR: instrucciones register-register dentro de la boveda.
    "sllv": InstructionSpec(
        "sllv",
        InstructionFormat.VR,
        opcode=0b1010,
        func=0b00000,
        ),

    "slrv": InstructionSpec(
        "slrv",
        InstructionFormat.VR,
        opcode=0b1010,
        func=0b00001,
    ),

    "changev": InstructionSpec(
        "changev",
        InstructionFormat.VR,
        opcode=0b1011,
        func=0b00000,
        description="Modifica registros/llaves de boveda en Secure Mode",
    ),

    "closev": InstructionSpec(
        "closev",
        InstructionFormat.VR,
        opcode=0b1100,
        func=0b00000,
        description="Cierra Secure Mode y limpia registros de boveda",
    ),

    # Tipo VS: load/store de boveda.
    "swv": InstructionSpec("swv", InstructionFormat.VS, opcode=0b1110, func=0),
    "lwv": InstructionSpec("lwv", InstructionFormat.VS, opcode=0b1110, func=1),

    # Tipo IV: inmediatos para registros de boveda.
    "addiLOWv": InstructionSpec("addiLOWv", InstructionFormat.IV, opcode=0b1111, func=0b00),
    "addiHIGHv": InstructionSpec(
        "addiHIGHv",
        InstructionFormat.IV,
        opcode=0b1111,
        func=0b01,
    ),
}


def get_instruction(mnemonic: str) -> InstructionSpec | None:
    return INSTRUCTIONS.get(mnemonic)


def require_instruction(mnemonic: str) -> InstructionSpec:
    instruction = get_instruction(mnemonic)
    if instruction is None:
        raise ValueError(f"instruccion desconocida: {mnemonic}")
    return instruction

