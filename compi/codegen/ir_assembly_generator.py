from __future__ import annotations

from symbol_table import SymbolTable

from .ir_lowering import IRLoweringBackend


class IRAssemblyGenerator(IRLoweringBackend):
    """Public facade for generating Craft21 assembly from optimized IR."""

    def __init__(self, symbol_table: SymbolTable):
        super().__init__(symbol_table)
