from dataclasses import dataclass
from typing import Any, Optional


@dataclass
class IRInstruction:
    """Clase base para todas las instrucciones de 3 direcciones."""
    pass


@dataclass
class IRBinOp(IRInstruction):
    """
    Operación binaria: result = left op right
    Ejemplo: t1 = a + b
    """
    op: str
    left: str
    right: str
    result: str


@dataclass
class IRUnaryOp(IRInstruction):
    """
    Operación unaria: result = op operand
    Ejemplo: t1 = -a
    """
    op: str
    operand: str
    result: str


@dataclass
class IRAssign(IRInstruction):
    """
    Asignación simple: result = source
    Ejemplo: x = t1  o  x = 5
    """
    source: Any  # Puede ser un string (variable/temporal) o un valor literal (int)
    result: str


@dataclass
class IRLabel(IRInstruction):
    """
    Representa una etiqueta para saltos.
    Ejemplo: L1:
    """
    name: str


@dataclass
class IRJump(IRInstruction):
    """
    Salto incondicional: goto label
    """
    label: str


@dataclass
class IRJumpIfFalse(IRInstruction):
    """
    Salto condicional: ifFalse condition goto label
    Ejemplo: ifFalse t1 goto L2
    """
    condition: str
    label: str


@dataclass
class IRCall(IRInstruction):
    """
    Llamada a función: result = call func_name, args
    Ejemplo: t1 = call max, [a, b]
    """
    func_name: str
    args: list[str]
    result: Optional[str]  # Puede ser None si la función es void


@dataclass
class IRReturn(IRInstruction):
    """
    Retorno de función: return value
    Ejemplo: return t1
    """
    value: Optional[str]

