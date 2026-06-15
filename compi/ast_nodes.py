from __future__ import annotations

from dataclasses import dataclass, field, fields, is_dataclass
from typing import Any


class ASTNode:
    """
    Base comun para los nodos del AST.

    Cada nodo guarda linea y columna para poder reportar errores o conectar
    fases futuras con el codigo fuente original.
    """

    line: int
    column: int


@dataclass
class TypeNode(ASTNode):
    name: str
    line: int
    column: int
    base_type: TypeNode | None = None
    size: int | None = None

    def describe(self) -> str:
        if self.name == "pointer" and self.base_type is not None:
            return f"pointer[{self.base_type.describe()}]"
        if self.name == "chest" and self.base_type is not None:
            return f"chest[{self.base_type.describe()}, {self.size}]"
        return self.name


@dataclass
class Parameter(ASTNode):
    name: str
    type: TypeNode
    line: int
    column: int


@dataclass
class Program(ASTNode):
    declarations: list[ASTNode]
    line: int = 1
    column: int = 1
    pragmas: list[str] = field(default_factory=list)


@dataclass
class ImportDeclaration(ASTNode):
    module: str
    alias: str
    line: int
    column: int


@dataclass
class FunctionDeclaration(ASTNode):
    name: str
    return_type: TypeNode
    parameters: list[Parameter]
    body: Block
    line: int
    column: int
    pragmas: list[str] = field(default_factory=list)


@dataclass
class Block(ASTNode):
    statements: list[ASTNode]
    line: int
    column: int


@dataclass
class VariableDeclaration(ASTNode):
    name: str
    type: TypeNode
    initializer: ASTNode | None
    line: int
    column: int


@dataclass
class Assignment(ASTNode):
    target: ASTNode
    value: ASTNode
    line: int
    column: int


@dataclass
class IfStatement(ASTNode):
    condition: ASTNode
    then_branch: Block
    else_branch: Block | None
    line: int
    column: int


@dataclass
class WhileStatement(ASTNode):
    condition: ASTNode
    body: Block
    line: int
    column: int


@dataclass
class ForStatement(ASTNode):
    initializer: ASTNode | None
    condition: ASTNode | None
    increment: ASTNode | None
    body: Block
    line: int
    column: int


@dataclass
class ReturnStatement(ASTNode):
    value: ASTNode | None
    line: int
    column: int


@dataclass
class ExpressionStatement(ASTNode):
    expression: ASTNode
    line: int
    column: int


@dataclass
class VaultInstruction(ASTNode):
    keyword: str
    operands: list[str]
    line: int
    column: int


@dataclass
class EnderPortalStatement(ASTNode):
    password: ASTNode
    body: Block | None
    line: int
    column: int


@dataclass
class ChangePasswordInstruction(ASTNode):
    value: ASTNode
    line: int
    column: int


@dataclass
class Identifier(ASTNode):
    name: str
    line: int
    column: int


@dataclass
class Literal(ASTNode):
    value: Any
    literal_type: str
    line: int
    column: int


@dataclass
class ArrayLiteral(ASTNode):
    elements: list[ASTNode]
    line: int
    column: int


@dataclass
class UnaryExpression(ASTNode):
    operator: str
    operand: ASTNode
    line: int
    column: int


@dataclass
class BinaryExpression(ASTNode):
    left: ASTNode
    operator: str
    right: ASTNode
    line: int
    column: int


@dataclass
class CallExpression(ASTNode):
    name: str
    arguments: list[ASTNode]
    line: int
    column: int
    module_alias: str | None = None


@dataclass
class IndexExpression(ASTNode):
    target: ASTNode
    index: ASTNode
    line: int
    column: int


@dataclass
class MemberExpression(ASTNode):
    target: ASTNode
    member: str
    line: int
    column: int


def format_ast(node: ASTNode) -> str:
    """
    Devuelve una version legible del AST como arbol ASCII.
    """
    lines: list[str] = []
    lines.append("AST")
    lines.append("===")
    _format_tree(node, lines, prefix="", label=None, is_last=True, is_root=True)
    return "\n".join(lines)


def _format_tree(
    value: Any,
    lines: list[str],
    *,
    prefix: str,
    label: str | None,
    is_last: bool,
    is_root: bool = False,
) -> None:
    connector = "" if is_root else ("`- " if is_last else "+- ")
    node_prefix = "" if is_root else prefix + connector
    child_prefix = prefix if is_root else prefix + ("   " if is_last else "|  ")

    if isinstance(value, TypeNode):
        lines.append(f"{node_prefix}{_label_prefix(label)}Type {value.describe()} @ {value.line}:{value.column}")
        return

    if isinstance(value, ASTNode) and is_dataclass(value):
        lines.append(f"{node_prefix}{_label_prefix(label)}{value.__class__.__name__}{_node_summary(value)}")

        children = []
        for item in fields(value):
            if item.name in {"line", "column"} or item.name in _summary_fields(value):
                continue
            children.append((item.name, getattr(value, item.name)))

        for index, (child_label, child) in enumerate(children):
            _format_tree(
                child,
                lines,
                prefix=child_prefix,
                label=child_label,
                is_last=index == len(children) - 1,
            )
        return

    if isinstance(value, list):
        if not value:
            lines.append(f"{node_prefix}{_label_prefix(label)}[]")
            return

        lines.append(f"{node_prefix}{_label_prefix(label)}list ({len(value)} items)")
        for index, item in enumerate(value):
            _format_tree(
                item,
                lines,
                prefix=child_prefix,
                label=f"[{index}]",
                is_last=index == len(value) - 1,
            )
        return

    if value is None:
        lines.append(f"{node_prefix}{_label_prefix(label)}None")
        return

    lines.append(f"{node_prefix}{_label_prefix(label)}{value!r}")


def _label_prefix(label: str | None) -> str:
    return f"{label}: " if label else ""


def _summary_fields(node: ASTNode) -> set[str]:
    if isinstance(node, ImportDeclaration):
        return {"module", "alias"}
    if isinstance(node, Program):
        return {"pragmas"}
    if isinstance(node, FunctionDeclaration):
        return {"name", "pragmas"}
    if isinstance(node, Parameter):
        return {"name"}
    if isinstance(node, VariableDeclaration):
        return {"name"}
    if isinstance(node, VaultInstruction):
        return {"keyword", "operands"}
    if isinstance(node, EnderPortalStatement):
        return set()
    if isinstance(node, ChangePasswordInstruction):
        return set()
    if isinstance(node, Identifier):
        return {"name"}
    if isinstance(node, Literal):
        return {"value", "literal_type"}
    if isinstance(node, UnaryExpression):
        return {"operator"}
    if isinstance(node, BinaryExpression):
        return {"operator"}
    if isinstance(node, CallExpression):
        return {"name", "module_alias"}
    if isinstance(node, MemberExpression):
        return {"member"}
    return set()


def _node_summary(node: ASTNode) -> str:
    location = f" @ {node.line}:{node.column}"

    if isinstance(node, ImportDeclaration):
        return f"(module={node.module!r}, alias={node.alias!r}){location}"
    if isinstance(node, Program):
        pragmas = f"(pragmas={node.pragmas!r})" if node.pragmas else ""
        return f"{pragmas}{location}"
    if isinstance(node, FunctionDeclaration):
        pragmas = f", pragmas={node.pragmas!r}" if node.pragmas else ""
        return f"(name={node.name!r}{pragmas}){location}"
    if isinstance(node, Parameter):
        return f"(name={node.name!r}){location}"
    if isinstance(node, VariableDeclaration):
        return f"(name={node.name!r}){location}"
    if isinstance(node, VaultInstruction):
        return f"(keyword={node.keyword!r}, operands={node.operands!r}){location}"
    if isinstance(node, Identifier):
        return f"(name={node.name!r}){location}"
    if isinstance(node, Literal):
        return (
            f"(type={node.literal_type!r}, value={node.value!r})"
            f"{location}"
        )
    if isinstance(node, UnaryExpression):
        return f"(operator={node.operator!r}){location}"
    if isinstance(node, BinaryExpression):
        return f"(operator={node.operator!r}){location}"
    if isinstance(node, CallExpression):
        qualified = (
            f"{node.module_alias}.{node.name}"
            if node.module_alias is not None
            else node.name
        )
        return f"(name={qualified!r}){location}"
    if isinstance(node, MemberExpression):
        return f"(member={node.member!r}){location}"

    return location
