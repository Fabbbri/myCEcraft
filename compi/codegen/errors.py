from __future__ import annotations

from ast_nodes import ASTNode


class CodegenError(Exception):
    """
    Error de generación de ensamblador.
    """

    def __init__(self, message: str, node: ASTNode | None = None):
        if node is not None:
            message = f"Error de codegen en línea {node.line}, columna {node.column}: {message}"
        super().__init__(message)
        self.node = node
