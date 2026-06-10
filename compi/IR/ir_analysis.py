from __future__ import annotations

import re
from typing import Any

from IR.instructions import (
    IRAssign,
    IRArrayAssign,
    IRBinOp,
    IRCall,
    IRCommit,
    IRInstruction,
    IRJump,
    IRJumpIfFalse,
    IRLabel,
    IRReturn,
    IRUnaryOp,
    IRVaultInstruction,
)

IDENTIFIER_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*\b|\bt\d+\b|\bx\d+\b")
SIMPLE_TARGET_RE = re.compile(r"(?:[A-Za-z_][A-Za-z0-9_]*|t\d+|x\d+)\Z")
IGNORED_NAMES = {"portal"}


def operand_names(operand: Any) -> set[str]:
    if not isinstance(operand, str):
        return set()
    return {
        name
        for name in IDENTIFIER_RE.findall(operand)
        if name not in IGNORED_NAMES
    }


def is_simple_target(target: Any) -> bool:
    return isinstance(target, str) and SIMPLE_TARGET_RE.fullmatch(target) is not None


def defs(instr: IRInstruction) -> set[str]:
    if isinstance(instr, (IRBinOp, IRUnaryOp)):
        return {instr.result} if is_simple_target(instr.result) else set()
    if isinstance(instr, IRAssign):
        return {instr.result} if is_simple_target(instr.result) else set()
    if isinstance(instr, IRCommit):
        return {instr.result} if is_simple_target(instr.result) else set()
    if isinstance(instr, IRArrayAssign):
        return set()
    if isinstance(instr, IRCall) and instr.result:
        return {instr.result} if is_simple_target(instr.result) else set()
    return set()


def uses(instr: IRInstruction) -> set[str]:
    if isinstance(instr, IRBinOp):
        return operand_names(instr.left) | operand_names(instr.right)
    if isinstance(instr, IRUnaryOp):
        return operand_names(instr.operand)
    if isinstance(instr, IRAssign):
        names = operand_names(instr.source)
        if not is_simple_target(instr.result):
            names |= operand_names(instr.result)
        return names
    if isinstance(instr, IRCommit):
        return operand_names(instr.source)
    if isinstance(instr, IRArrayAssign):
        return set().union(*(operand_names(element) for element in instr.elements))
    if isinstance(instr, IRJumpIfFalse):
        return operand_names(instr.condition)
    if isinstance(instr, IRReturn):
        return operand_names(instr.value)
    if isinstance(instr, IRCall):
        return set().union(*(operand_names(arg) for arg in instr.args))
    if isinstance(instr, IRVaultInstruction):
        return set().union(*(operand_names(operand) for operand in instr.operands))
    return set()


def has_side_effect(instr: IRInstruction) -> bool:
    if isinstance(
        instr,
        (
            IRArrayAssign,
            IRCall,
            IRCommit,
            IRVaultInstruction,
            IRReturn,
            IRJump,
            IRJumpIfFalse,
            IRLabel,
        ),
    ):
        return True
    if isinstance(instr, IRAssign):
        return not is_simple_target(instr.result)
    return False


def is_schedulable(instr: IRInstruction) -> bool:
    if has_side_effect(instr):
        return False
    return isinstance(instr, (IRAssign, IRBinOp, IRUnaryOp)) and bool(defs(instr))


def is_memory_read(instr: IRInstruction) -> bool:
    if not isinstance(instr, IRAssign) or not isinstance(instr.source, str):
        return False
    return "[" in instr.source or "." in instr.source
