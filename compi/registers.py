from __future__ import annotations

from dataclasses import dataclass
from enum import Enum, auto


class RegisterClass(Enum):
    GENERAL = auto()
    VAULT = auto()


class SavePolicy(Enum):
    NONE = auto()
    CALLER = auto()
    CALLEE = auto()
    VAULT_CALLER = auto()
    RESERVED = auto()


@dataclass(frozen=True)
class Register:
    """
    Representa un registro físico de la arquitectura Craft21.
    """

    index: int
    name: str
    abi_name: str
    description: str
    register_class: RegisterClass
    save_policy: SavePolicy

    def asm(self) -> str:
        """
        Nombre que se imprimirá en el ensamblador.
        Por ahora usamos el nombre físico: x0, x1, x2...
        """
        return self.name


# ------------------------------------------------------------
# Registros generales Craft21
# ------------------------------------------------------------

X0 = Register(0, "x0", "zero", "Wired zero", RegisterClass.GENERAL, SavePolicy.NONE)
X1 = Register(1, "x1", "ra", "Return address", RegisterClass.GENERAL, SavePolicy.CALLER)
X2 = Register(2, "x2", "sp", "Stack pointer", RegisterClass.GENERAL, SavePolicy.CALLEE)

# Temporales x3-x10 => t0-t7
TEMP_REGISTERS = [
    Register(i, f"x{i}", f"t{i - 3}", "Temporary register", RegisterClass.GENERAL, SavePolicy.CALLER)
    for i in range(3, 11)
]

# Argumentos / valores de retorno
X11 = Register(11, "x11", "a0", "Return value / argument 0", RegisterClass.GENERAL, SavePolicy.CALLER)
X12 = Register(12, "x12", "a1", "Return value / argument 1", RegisterClass.GENERAL, SavePolicy.CALLER)

ARG_REGISTERS = [
    X11,
    X12,
    Register(13, "x13", "a2", "Function argument 2", RegisterClass.GENERAL, SavePolicy.CALLER),
    Register(14, "x14", "a3", "Function argument 3", RegisterClass.GENERAL, SavePolicy.CALLER),
    Register(15, "x15", "a4", "Function argument 4", RegisterClass.GENERAL, SavePolicy.CALLER),
    Register(16, "x16", "a5", "Function argument 5", RegisterClass.GENERAL, SavePolicy.CALLER),
]

X17 = Register(17, "x17", "s0/fp", "Frame pointer", RegisterClass.GENERAL, SavePolicy.CALLEE)

# x18-x19 quedan reservados por ahora.
RESERVED_REGISTERS = [
    Register(18, "x18", "reserved0", "Reserved register", RegisterClass.GENERAL, SavePolicy.RESERVED),
    Register(19, "x19", "reserved1", "Reserved register", RegisterClass.GENERAL, SavePolicy.RESERVED),
]

# Saved registers x20-x31 => s1-s12
SAVED_REGISTERS = [
    Register(i, f"x{i}", f"s{i - 19}", "Saved register", RegisterClass.GENERAL, SavePolicy.CALLEE)
    for i in range(20, 32)
]


GENERAL_REGISTERS = [
    X0,
    X1,
    X2,
    *TEMP_REGISTERS,
    *ARG_REGISTERS,
    X17,
    *RESERVED_REGISTERS,
    *SAVED_REGISTERS,
]


# ------------------------------------------------------------
# Registros Vault Craft21
# ------------------------------------------------------------

V0 = Register(0, "v0", "rpass", "Password container", RegisterClass.VAULT, SavePolicy.VAULT_CALLER)

KEY_REGISTERS = [
    Register(i, f"v{i}", f"key{i - 1}", "Key register", RegisterClass.VAULT, SavePolicy.VAULT_CALLER)
    for i in range(1, 5)
]

EXTRA_VAULT_REGISTERS = [
    Register(i, f"v{i}", f"vault{i}", "Extra vault register", RegisterClass.VAULT, SavePolicy.VAULT_CALLER)
    for i in range(5, 32)
]

VAULT_REGISTERS = [
    V0,
    *KEY_REGISTERS,
    *EXTRA_VAULT_REGISTERS,
]


# ------------------------------------------------------------
# Alias importantes para el generador de ensamblador
# ------------------------------------------------------------

ZERO = X0
RA = X1
SP = X2
FP = X17

RETURN_REGISTERS = [X11, X12]

# Para la primera versión del codegen usaremos estos.
ALLOCATABLE_TEMP_REGISTERS = TEMP_REGISTERS


def get_general_register_by_name(name: str) -> Register | None:
    """
    Busca un registro general por nombre físico o ABI.
    Ejemplos válidos:
    - x3
    - t0
    - a0
    - fp
    """
    for register in GENERAL_REGISTERS:
        if register.name == name or register.abi_name == name:
            return register

        # Caso especial para s0/fp
        if register.abi_name == "s0/fp" and name in {"s0", "fp"}:
            return register

    return None


def require_general_register(name: str) -> Register:
    register = get_general_register_by_name(name)
    if register is None:
        raise ValueError(f"registro general desconocido: {name}")
    return register


def get_vault_register_by_name(name: str) -> Register | None:
    """
    Busca un registro vault por nombre físico o ABI.
    Ejemplos válidos:
    - v0
    - rpass
    - key0
    """
    for register in VAULT_REGISTERS:
        if register.name == name or register.abi_name == name:
            return register

    return None


def require_vault_register(name: str) -> Register:
    register = get_vault_register_by_name(name)
    if register is None:
        raise ValueError(f"registro vault desconocido: {name}")
    return register