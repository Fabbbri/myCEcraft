from __future__ import annotations

from copy import deepcopy
from pathlib import Path
from typing import Any

from ast_nodes import (
    ArrayLiteral,
    Assignment,
    ASTNode,
    BinaryExpression,
    Block,
    CallExpression,
    ChangePasswordInstruction,
    EnderPortalStatement,
    ExpressionStatement,
    ForStatement,
    FunctionDeclaration,
    Identifier,
    IfStatement,
    ImportDeclaration,
    IndexExpression,
    Literal,
    MemberExpression,
    Parameter,
    Program,
    ReturnStatement,
    TypeNode,
    UnaryExpression,
    VariableDeclaration,
    VaultInstruction,
    WhileStatement,
)
from registers import TEMP_REGISTERS


AUTO_UNROLL_FACTOR = 0
MAX_AUTO_UNROLL_FACTOR = min(8, len(TEMP_REGISTERS))


def write_optimized_craft_preview(
    program: Program,
    output_path: Path,
    *,
    unroll_factor: int,
) -> Path | None:
    """
    Escribe una vista fuente del loop unrolling.

    La optimizacion real se aplica sobre IR. Esta salida existe solo para
    facilitar la demostracion en clase, porque el IR ya no conserva todos los
    detalles de formato/tipos necesarios para reconstruir el .craft original.
    """

    if unroll_factor == 1:
        return None

    preview = _CraftLoopPreviewUnroller(unroll_factor).run(program)
    if not preview.changed:
        return None

    output_path.parent.mkdir(parents=True, exist_ok=True)
    text = _CraftEmitter().emit(preview.program)

    try:
        output_path.write_text(text, encoding="utf-8")
        return output_path
    except PermissionError:
        if output_path.exists():
            return output_path
        fallback_path = output_path.with_name(f"{output_path.stem}.preview{output_path.suffix}")
        fallback_path.write_text(text, encoding="utf-8")
        return fallback_path


def optimize_craft_program(
    program: Program,
    *,
    unroll_factor: int,
) -> Program:
    if unroll_factor == 1:
        return deepcopy(program)
    return _CraftLoopPreviewUnroller(unroll_factor).run(program).program


def write_craft_program(program: Program, output_path: Path) -> Path:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    return _write_preview_text(output_path, _CraftEmitter().emit(program))


def _write_preview_text(output_path: Path, text: str) -> Path:
    try:
        output_path.write_text(text, encoding="utf-8")
        return output_path
    except PermissionError:
        if output_path.exists():
            return output_path
        fallback_path = output_path.with_name(f"{output_path.stem}.preview{output_path.suffix}")
        fallback_path.write_text(text, encoding="utf-8")
        return fallback_path


class _PreviewResult:
    def __init__(self, program: Program, changed: bool) -> None:
        self.program = program
        self.changed = changed


class _CraftLoopPreviewUnroller:
    def __init__(self, factor: int) -> None:
        self.factor = factor
        self.changed = False

    def run(self, program: Program) -> _PreviewResult:
        return _PreviewResult(self._transform_node(program, {}) or program, self.changed)

    def _transform_node(
        self,
        node: ASTNode,
        constants: dict[str, int],
    ) -> ASTNode | list[ASTNode] | None:
        if isinstance(node, Program):
            declarations: list[ASTNode] = []
            constants.clear()
            for declaration in node.declarations:
                transformed = self._transform_node(declaration, constants)
                declarations.extend(_as_list(transformed))
            return Program(
                declarations=declarations,
                line=node.line,
                column=node.column,
                pragmas=list(node.pragmas),
            )

        if isinstance(node, FunctionDeclaration):
            return FunctionDeclaration(
                name=node.name,
                return_type=deepcopy(node.return_type),
                parameters=deepcopy(node.parameters),
                body=self._transform_block(node.body, {}),
                line=node.line,
                column=node.column,
                pragmas=list(node.pragmas),
            )

        if isinstance(node, Block):
            return self._transform_block(node, constants)

        if isinstance(node, IfStatement):
            constants.clear()
            return IfStatement(
                condition=deepcopy(node.condition),
                then_branch=self._transform_block(node.then_branch, {}),
                else_branch=(
                    self._transform_block(node.else_branch, {})
                    if node.else_branch is not None
                    else None
                ),
                line=node.line,
                column=node.column,
            )

        if isinstance(node, ForStatement):
            replacement = self._try_unroll_for(node)
            if replacement is not None:
                self.changed = True
                constants.clear()
                return replacement
            constants.clear()
            return ForStatement(
                initializer=deepcopy(node.initializer),
                condition=deepcopy(node.condition),
                increment=deepcopy(node.increment),
                body=self._transform_block(node.body, {}),
                line=node.line,
                column=node.column,
            )

        if isinstance(node, WhileStatement):
            replacement = self._try_unroll_while(node, constants)
            if replacement is not None:
                self.changed = True
                constants.clear()
                return replacement
            constants.clear()
            return WhileStatement(
                condition=deepcopy(node.condition),
                body=self._transform_block(node.body, {}),
                line=node.line,
                column=node.column,
            )

        self._update_constants(node, constants)
        return deepcopy(node)

    def _transform_block(self, block: Block, constants: dict[str, int]) -> Block:
        statements: list[ASTNode] = []
        local_constants = dict(constants)

        for statement in block.statements:
            transformed = self._transform_node(statement, local_constants)
            statements.extend(_as_list(transformed))

        return Block(statements=statements, line=block.line, column=block.column)

    def _try_unroll_for(self, node: ForStatement) -> list[ASTNode] | None:
        loop = self._match_for_loop(node)
        if loop is None:
            return None

        return [self._build_for(loop), *self._remainder(loop)]

    def _try_unroll_while(
        self,
        node: WhileStatement,
        constants: dict[str, int],
    ) -> list[ASTNode] | None:
        loop = self._match_while_loop(node, constants)
        if loop is None:
            return None

        return [self._build_while(loop), *self._remainder(loop)]

    def _match_for_loop(self, node: ForStatement) -> "_LoopPreview | None":
        init = node.initializer
        if isinstance(init, VariableDeclaration):
            variable = init.name
            start = _literal_int(init.initializer)
        elif isinstance(init, Assignment) and isinstance(init.target, Identifier):
            variable = init.target.name
            start = _literal_int(init.value)
        else:
            return None

        if start is None:
            return None

        condition = _match_condition(node.condition, variable)
        increment = _match_increment(node.increment, variable)
        if condition is None or increment is None:
            return None

        limit, op = condition
        step = increment
        body = list(node.body.statements)
        if step <= 0 or _has_barrier(body, variable):
            return None

        iterations = _iteration_count(start, limit, step, op)
        factor = self._select_factor(iterations, len(body))
        if iterations <= 0 or factor <= 1:
            return None

        return _LoopPreview(
            variable=variable,
            start=start,
            limit=limit,
            condition_op=op,
            step=step,
            iterations=iterations,
            factor=factor,
            body=body,
            original=node,
        )

    def _match_while_loop(
        self,
        node: WhileStatement,
        constants: dict[str, int],
    ) -> "_LoopPreview | None":
        if not node.body.statements:
            return None

        condition_variable = _condition_variable(node.condition)
        if condition_variable is None:
            return None

        variable = condition_variable
        start = constants.get(variable)
        condition = _match_condition(node.condition, variable)
        increment = _match_increment(node.body.statements[-1], variable)
        if start is None or condition is None or increment is None:
            return None

        limit, op = condition
        step = increment
        body = list(node.body.statements[:-1])
        if step <= 0 or _has_barrier(body, variable):
            return None

        iterations = _iteration_count(start, limit, step, op)
        factor = self._select_factor(iterations, len(body))
        if iterations <= 0 or factor <= 1:
            return None

        return _LoopPreview(
            variable=variable,
            start=start,
            limit=limit,
            condition_op=op,
            step=step,
            iterations=iterations,
            factor=factor,
            body=body,
            original=node,
        )

    def _select_factor(self, iterations: int, body_size: int) -> int:
        if self.factor != AUTO_UNROLL_FACTOR:
            return self.factor if self.factor <= iterations else 1

        max_factor = min(MAX_AUTO_UNROLL_FACTOR, iterations)
        if max_factor < 2:
            return 1
        if body_size <= 2 and iterations >= 16 and max_factor >= 8:
            return 8
        if body_size <= 6 and iterations >= 8 and max_factor >= 4:
            return 4
        return 2

    def _build_for(self, loop: "_LoopPreview") -> ForStatement:
        original = loop.original
        assert isinstance(original, ForStatement)

        main_limit = loop.start + loop.factor * (loop.iterations // loop.factor) * loop.step
        body = self._unrolled_body(loop)
        increment = _increment_assignment(
            loop.variable,
            loop.step * loop.factor,
            line=original.line,
            column=original.column,
        )

        return ForStatement(
            initializer=deepcopy(original.initializer),
            condition=BinaryExpression(
                Identifier(loop.variable, original.line, original.column),
                "<",
                Literal(main_limit, "int", original.line, original.column),
                original.line,
                original.column,
            ),
            increment=increment,
            body=Block(body, original.body.line, original.body.column),
            line=original.line,
            column=original.column,
        )

    def _build_while(self, loop: "_LoopPreview") -> WhileStatement:
        original = loop.original
        assert isinstance(original, WhileStatement)

        main_limit = loop.start + loop.factor * (loop.iterations // loop.factor) * loop.step
        body = self._unrolled_body(loop)
        body.append(
            _increment_assignment(
                loop.variable,
                loop.step * loop.factor,
                line=original.line,
                column=original.column,
            )
        )

        return WhileStatement(
            condition=BinaryExpression(
                Identifier(loop.variable, original.line, original.column),
                "<",
                Literal(main_limit, "int", original.line, original.column),
                original.line,
                original.column,
            ),
            body=Block(body, original.body.line, original.body.column),
            line=original.line,
            column=original.column,
        )

    def _unrolled_body(self, loop: "_LoopPreview") -> list[ASTNode]:
        result: list[ASTNode] = []
        for copy_index in range(loop.factor):
            offset = copy_index * loop.step
            result.extend(_clone_with_index(statement, loop.variable, offset, None) for statement in loop.body)
        return result

    def _remainder(self, loop: "_LoopPreview") -> list[ASTNode]:
        unrolled_iterations = loop.iterations - (loop.iterations % loop.factor)
        remainder_start = loop.start + unrolled_iterations * loop.step
        normalized_limit = loop.limit + (1 if loop.condition_op == "<=" else 0)

        result: list[ASTNode] = []
        for value in range(remainder_start, normalized_limit, loop.step):
            result.extend(_clone_with_index(statement, loop.variable, 0, value) for statement in loop.body)
            result.append(
                _increment_assignment(
                    loop.variable,
                    loop.step,
                    line=loop.original.line,
                    column=loop.original.column,
                )
            )
        return result

    def _update_constants(self, node: ASTNode, constants: dict[str, int]) -> None:
        if isinstance(node, VariableDeclaration):
            value = _literal_int(node.initializer)
            if value is None:
                constants.pop(node.name, None)
            else:
                constants[node.name] = value
            return

        if isinstance(node, Assignment) and isinstance(node.target, Identifier):
            value = _literal_int(node.value)
            if value is None:
                constants.pop(node.target.name, None)
            else:
                constants[node.target.name] = value
            return

        if isinstance(node, (IfStatement, ForStatement, WhileStatement, ReturnStatement)):
            constants.clear()


class _LoopPreview:
    def __init__(
        self,
        *,
        variable: str,
        start: int,
        limit: int,
        condition_op: str,
        step: int,
        iterations: int,
        factor: int,
        body: list[ASTNode],
        original: ASTNode,
    ) -> None:
        self.variable = variable
        self.start = start
        self.limit = limit
        self.condition_op = condition_op
        self.step = step
        self.iterations = iterations
        self.factor = factor
        self.body = body
        self.original = original


def _as_list(value: ASTNode | list[ASTNode] | None) -> list[ASTNode]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def _condition_variable(node: ASTNode | None) -> str | None:
    if isinstance(node, BinaryExpression) and isinstance(node.left, Identifier):
        return node.left.name
    return None


def _match_condition(node: ASTNode | None, variable: str) -> tuple[int, str] | None:
    if (
        isinstance(node, BinaryExpression)
        and node.operator in {"<", "<="}
        and isinstance(node.left, Identifier)
        and node.left.name == variable
    ):
        limit = _literal_int(node.right)
        if limit is not None:
            return limit, node.operator
    return None


def _match_increment(node: ASTNode | None, variable: str) -> int | None:
    if not (
        isinstance(node, Assignment)
        and isinstance(node.target, Identifier)
        and node.target.name == variable
        and isinstance(node.value, BinaryExpression)
        and isinstance(node.value.left, Identifier)
        and node.value.left.name == variable
        and node.value.operator in {"+", "-"}
    ):
        return None

    amount = _literal_int(node.value.right)
    if amount is None:
        return None
    return amount if node.value.operator == "+" else -amount


def _increment_assignment(variable: str, amount: int, *, line: int, column: int) -> Assignment:
    return Assignment(
        Identifier(variable, line, column),
        BinaryExpression(
            Identifier(variable, line, column),
            "+",
            Literal(amount, "int", line, column),
            line,
            column,
        ),
        line,
        column,
    )


def _iteration_count(start: int, limit: int, step: int, op: str) -> int:
    normalized_limit = limit + (1 if op == "<=" else 0)
    return max(0, (normalized_limit - start + step - 1) // step)


def _has_barrier(statements: list[ASTNode], variable: str) -> bool:
    for statement in statements:
        if isinstance(
            statement,
            (IfStatement, ForStatement, WhileStatement, ReturnStatement, VariableDeclaration),
        ):
            return True
        if _contains_call_or_vault(statement):
            return True
        if isinstance(statement, Assignment) and _target_name(statement.target) == variable:
            return True
    return False


def _contains_call_or_vault(node: Any) -> bool:
    if isinstance(node, (CallExpression, VaultInstruction, EnderPortalStatement, ChangePasswordInstruction)):
        return True
    if isinstance(node, ASTNode):
        return any(_contains_call_or_vault(value) for value in vars(node).values())
    if isinstance(node, list):
        return any(_contains_call_or_vault(item) for item in node)
    return False


def _target_name(node: ASTNode) -> str | None:
    if isinstance(node, Identifier):
        return node.name
    return None


def _literal_int(node: ASTNode | None) -> int | None:
    if isinstance(node, Literal) and isinstance(node.value, int):
        return node.value
    return None


def _clone_with_index(
    node: ASTNode,
    variable: str,
    offset: int,
    constant: int | None,
) -> ASTNode:
    cloned = deepcopy(node)
    return _replace_index(cloned, variable, offset, constant)


def _replace_index(
    node: ASTNode,
    variable: str,
    offset: int,
    constant: int | None,
) -> ASTNode:
    if isinstance(node, Identifier) and node.name == variable:
        if constant is not None:
            return Literal(constant, "int", node.line, node.column)
        if offset == 0:
            return node
        return BinaryExpression(
            Identifier(variable, node.line, node.column),
            "+",
            Literal(offset, "int", node.line, node.column),
            node.line,
            node.column,
        )

    for name, value in list(vars(node).items()):
        if name in {"line", "column"}:
            continue
        if isinstance(value, ASTNode):
            setattr(node, name, _replace_index(value, variable, offset, constant))
        elif isinstance(value, list):
            setattr(
                node,
                name,
                [
                    _replace_index(item, variable, offset, constant)
                    if isinstance(item, ASTNode)
                    else item
                    for item in value
                ],
            )
    return node


class _CraftEmitter:
    def emit(self, program: Program) -> str:
        return self._program(program).rstrip() + "\n"

    def _program(self, node: Program) -> str:
        lines: list[str] = []
        lines.extend(node.pragmas)
        if node.pragmas and node.declarations:
            lines.append("")
        for index, declaration in enumerate(node.declarations):
            if index > 0:
                lines.append("")
            lines.extend(self._declaration(declaration, 0))
        return "\n".join(lines)

    def _declaration(self, node: ASTNode, indent: int) -> list[str]:
        if isinstance(node, ImportDeclaration):
            return [f"{_pad(indent)}invoke \"{node.module}\" as {node.alias};"]
        if isinstance(node, FunctionDeclaration):
            pragmas = [f"{_pad(indent)}{pragma}" for pragma in node.pragmas]
            params = ", ".join(self._parameter(parameter) for parameter in node.parameters)
            header = f"{_pad(indent)}craft:{self._type(node.return_type)} {node.name}({params}) "
            return [*pragmas, header + "{", *self._block_body(node.body, indent + 1), f"{_pad(indent)}}}"]
        return self._statement(node, indent)

    def _block_body(self, block: Block, indent: int) -> list[str]:
        lines: list[str] = []
        for statement in block.statements:
            lines.extend(self._statement(statement, indent))
        return lines

    def _statement(self, node: ASTNode, indent: int) -> list[str]:
        pad = _pad(indent)
        if isinstance(node, Block):
            return [f"{pad}{{", *self._block_body(node, indent + 1), f"{pad}}}"]
        if isinstance(node, VariableDeclaration):
            initializer = ""
            if node.initializer is not None:
                initializer = f" = {self._expr(node.initializer)}"
            return [f"{pad}{node.name}:{self._type(node.type)}{initializer};"]
        if isinstance(node, Assignment):
            return [f"{pad}{self._expr(node.target)} = {self._expr(node.value)};"]
        if isinstance(node, ExpressionStatement):
            return [f"{pad}{self._expr(node.expression)};"]
        if isinstance(node, ReturnStatement):
            value = f" {self._expr(node.value)}" if node.value is not None else ""
            return [f"{pad}return{value};"]
        if isinstance(node, WhileStatement):
            return [
                f"{pad}while ({self._expr(node.condition)}) {{",
                *self._block_body(node.body, indent + 1),
                f"{pad}}}",
            ]
        if isinstance(node, ForStatement):
            init = self._for_part(node.initializer)
            condition = self._expr(node.condition) if node.condition is not None else ""
            increment = self._for_part(node.increment)
            return [
                f"{pad}for ({init}; {condition}; {increment}) {{",
                *self._block_body(node.body, indent + 1),
                f"{pad}}}",
            ]
        if isinstance(node, IfStatement):
            lines = [
                f"{pad}if ({self._expr(node.condition)}) {{",
                *self._block_body(node.then_branch, indent + 1),
                f"{pad}}}",
            ]
            if node.else_branch is not None:
                lines[-1] += " else {"
                lines.extend(self._block_body(node.else_branch, indent + 1))
                lines.append(f"{pad}}}")
            return lines
        if isinstance(node, VaultInstruction):
            operands = ", ".join(node.operands)
            suffix = f" {operands}" if operands else ""
            return [f"{pad}{node.keyword}{suffix};"]
        if isinstance(node, EnderPortalStatement):
            if node.body is None:
                return [f"{pad}enderPortal({self._expr(node.password)});"]
            return [
                f"{pad}enderPortal({self._expr(node.password)}):",
                *self._block_body(node.body, indent + 1),
                f"{pad}endchange;",
            ]
        if isinstance(node, ChangePasswordInstruction):
            return [f"{pad}enderchange({self._expr(node.value)});"]
        return [f"{pad}// nodo no emitido: {type(node).__name__}"]

    def _for_part(self, node: ASTNode | None) -> str:
        if node is None:
            return ""
        if isinstance(node, VariableDeclaration):
            initializer = ""
            if node.initializer is not None:
                initializer = f" = {self._expr(node.initializer)}"
            return f"{node.name}:{self._type(node.type)}{initializer}"
        if isinstance(node, Assignment):
            return f"{self._expr(node.target)} = {self._expr(node.value)}"
        return self._expr(node)

    def _parameter(self, node: Parameter) -> str:
        return f"{node.name}:{self._type(node.type)}"

    def _type(self, node: TypeNode) -> str:
        return node.describe()

    def _expr(self, node: ASTNode | None) -> str:
        if node is None:
            return ""
        if isinstance(node, Identifier):
            return node.name
        if isinstance(node, Literal):
            if isinstance(node.value, str):
                return '"' + node.value.replace("\\", "\\\\").replace('"', '\\"') + '"'
            return str(node.value)
        if isinstance(node, ArrayLiteral):
            return "[" + ", ".join(self._expr(element) for element in node.elements) + "]"
        if isinstance(node, UnaryExpression):
            return f"{node.operator}{self._expr(node.operand)}"
        if isinstance(node, BinaryExpression):
            return f"{self._expr_atom(node.left)} {node.operator} {self._expr_atom(node.right)}"
        if isinstance(node, CallExpression):
            prefix = f"{node.module_alias}." if node.module_alias is not None else ""
            args = ", ".join(self._expr(argument) for argument in node.arguments)
            return f"summon:{prefix}{node.name}({args})"
        if isinstance(node, IndexExpression):
            return f"{self._expr_atom(node.target)}[{self._expr(node.index)}]"
        if isinstance(node, MemberExpression):
            return f"{self._expr_atom(node.target)}.{node.member}"
        if isinstance(node, Assignment):
            return f"{self._expr(node.target)} = {self._expr(node.value)}"
        return str(node)

    def _expr_atom(self, node: ASTNode) -> str:
        if isinstance(node, BinaryExpression):
            return f"({self._expr(node)})"
        return self._expr(node)


def _pad(indent: int) -> str:
    return "    " * indent
