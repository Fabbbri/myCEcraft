from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import sys


COMPI_ROOT = Path(__file__).resolve().parents[1]
if str(COMPI_ROOT) not in sys.path:
    sys.path.insert(0, str(COMPI_ROOT))

from lexer import Lexer, LexerError
from parser import ParseError, Parser
from semantic import SemanticAnalyzer, SemanticError
from tokens import Token, TokenType


EPSILON = "ε"
EOF = "EOF"
TYPE_TERMINALS = (
    "TYPE_INT",
    "TYPE_UINT32",
    "TYPE_UINT16",
    "TYPE_CHAR",
    "TYPE_VOID",
    "TYPE_POINTER",
    "TYPE_CHEST",
    "TYPE_ENDER",
)


@dataclass(frozen=True)
class Suggestion:
    label: str
    insert_text: str
    detail: str = ""


@dataclass(frozen=True)
class CompletionSymbol:
    name: str
    kind: str
    detail: str = ""


@dataclass(frozen=True)
class Diagnostic:
    line: int
    column: int
    length: int
    message: str
    expected: tuple[str, ...]
    suggestions: tuple[Suggestion, ...]


class LL1SyntaxService:
    START_SYMBOL = "Program"

    def __init__(self) -> None:
        self.grammar = self._build_grammar()
        self.nonterminals = set(self.grammar)
        self.first = self._compute_first_sets()
        self.follow = self._compute_follow_sets()
        self.table = self._build_parse_table()

    def analyze(
        self,
        source: str,
        include_semantic: bool = True,
    ) -> tuple[list[Diagnostic], list[Suggestion]]:
        try:
            tokens = Lexer(source, filename="<editor>").tokenize()
        except LexerError as error:
            return [self._diagnostic_from_lexer_error(error)], []

        diagnostic = self._parse(tokens)
        if diagnostic is not None:
            diagnostic = self._refine_diagnostic(tokens, diagnostic)
            diagnostics = self._merge_diagnostics(
                [diagnostic],
                self._structural_diagnostics(tokens),
            )
            suggestions = diagnostics[0].suggestions if diagnostics else diagnostic.suggestions
            return diagnostics, list(suggestions)

        if include_semantic:
            phase_diagnostic = self._analyze_compiler_phases(tokens)
            if phase_diagnostic is not None:
                diagnostics = self._merge_diagnostics(
                    [phase_diagnostic],
                    self._structural_diagnostics(tokens),
                )
                return diagnostics, []

        diagnostics = self._structural_diagnostics(tokens)
        if diagnostics:
            return diagnostics, list(diagnostics[0].suggestions)

        return [], self._top_level_suggestions()

    def complete(self, source: str, cursor_position: int) -> list[Suggestion]:
        prefix_start = self._completion_prefix_start(source, cursor_position)
        prefix = source[prefix_start:cursor_position]
        context_source = source[:prefix_start]

        _diagnostics, suggestions = self.analyze(
            context_source,
            include_semantic=False,
        )
        suggestions = self._with_semantic_suggestions(source, context_source, suggestions)
        suggestions = self._rank_completion_suggestions(suggestions)

        if prefix:
            prefix_lower = prefix.lower()
            suggestions = [
                suggestion
                for suggestion in suggestions
                if suggestion.label.lower().startswith(prefix_lower)
                or suggestion.insert_text.lower().startswith(prefix_lower)
            ]

        return suggestions

    def _with_semantic_suggestions(
        self,
        full_source: str,
        context_source: str,
        suggestions: list[Suggestion],
    ) -> list[Suggestion]:
        tokens = self._safe_tokenize(context_source)
        if tokens is None:
            return suggestions

        enriched = list(suggestions)
        expected_labels = {suggestion.label for suggestion in suggestions}

        if self._is_summon_target_context(tokens):
            enriched.extend(self._function_completion_suggestions(full_source))
            enriched.extend(self._module_alias_completion_suggestions(full_source))
            return enriched

        if self._is_value_identifier_context(tokens):
            enriched.extend(self._variable_completion_suggestions(tokens))

        return enriched

    def _safe_tokenize(self, source: str) -> list[Token] | None:
        try:
            return Lexer(source, filename="<completion>").tokenize()
        except LexerError:
            return None

    def _is_summon_target_context(self, tokens: list[Token]) -> bool:
        significant = self._significant_tokens(tokens)
        if len(significant) < 2:
            return False
        return (
            significant[-2].type == TokenType.KW_SUMMON
            and significant[-1].type == TokenType.COLON
        )

    def _is_value_identifier_context(self, tokens: list[Token]) -> bool:
        significant = self._significant_tokens(tokens)
        if not significant:
            return False

        previous = significant[-1]
        expression_starters = {
            TokenType.ASSIGN,
            TokenType.KW_RETURN,
            TokenType.LPAREN,
            TokenType.LBRACKET,
            TokenType.COMMA,
            TokenType.PLUS,
            TokenType.MINUS,
            TokenType.STAR,
            TokenType.SLASH,
            TokenType.SHIFT_LEFT,
            TokenType.SHIFT_RIGHT,
            TokenType.EQ,
            TokenType.NEQ,
            TokenType.LT,
            TokenType.GT,
            TokenType.LE,
            TokenType.GE,
            TokenType.BIT_XOR,
            TokenType.BIT_AND,
            TokenType.BIT_OR,
            TokenType.BIT_NOT,
            TokenType.SPECIAL_LPLUS4,
            TokenType.SPECIAL_RPLUS5,
        }

        if previous.type in expression_starters:
            return True

        return previous.type in {
            TokenType.LBRACE,
            TokenType.RBRACE,
            TokenType.SEMICOLON,
        }

    def _significant_tokens(self, tokens: list[Token]) -> list[Token]:
        return [token for token in tokens if token.type != TokenType.EOF]

    def _variable_completion_suggestions(self, tokens: list[Token]) -> list[Suggestion]:
        variables = self._visible_value_symbols(tokens)
        return [
            Suggestion(
                label=f"{symbol.name}    {symbol.detail}",
                insert_text=symbol.name,
                detail=f"{symbol.kind}: {symbol.detail}",
            )
            for symbol in variables
        ]

    def _function_completion_suggestions(self, source: str) -> list[Suggestion]:
        functions = self._declared_functions(source)
        return [
            Suggestion(
                label=f"{function.name}{function.detail}",
                insert_text=f"{function.name}()",
                detail="funcion local",
            )
            for function in functions
        ]

    def _module_alias_completion_suggestions(self, source: str) -> list[Suggestion]:
        aliases = self._declared_module_aliases(source)
        return [
            Suggestion(
                label=f"{alias.name}    modulo {alias.detail}",
                insert_text=f"{alias.name}.",
                detail=f"alias de modulo: {alias.detail}",
            )
            for alias in aliases
        ]

    def _visible_value_symbols(self, tokens: list[Token]) -> list[CompletionSymbol]:
        significant = self._significant_tokens(tokens)
        scopes: list[dict[str, CompletionSymbol]] = [{}]
        pending_parameters: dict[str, CompletionSymbol] | None = None

        index = 0
        while index < len(significant):
            token = significant[index]

            if token.type == TokenType.KW_CRAFT:
                pending_parameters = self._parse_parameter_symbols(significant, index)
                index += 1
                continue

            if token.type == TokenType.LBRACE:
                scopes.append(pending_parameters or {})
                pending_parameters = None
                index += 1
                continue

            if token.type == TokenType.RBRACE:
                if len(scopes) > 1:
                    scopes.pop()
                pending_parameters = None
                index += 1
                continue

            if (
                pending_parameters is None
                and token.type == TokenType.IDENT
                and index + 1 < len(significant)
                and significant[index + 1].type == TokenType.COLON
            ):
                parsed = self._parse_type_at(significant, index + 2)
                if parsed is not None:
                    type_text, next_index = parsed
                    scopes[-1][token.lexeme] = CompletionSymbol(
                        token.lexeme,
                        "variable",
                        type_text,
                    )
                    index = next_index
                    continue

            index += 1

        visible: dict[str, CompletionSymbol] = {}
        for scope in scopes:
            visible.update(scope)
        return list(visible.values())

    def _declared_functions(self, source: str) -> list[CompletionSymbol]:
        tokens = self._safe_tokenize(source)
        if tokens is None:
            return []

        significant = self._significant_tokens(tokens)
        functions: list[CompletionSymbol] = []
        seen = set()
        index = 0
        while index < len(significant):
            token = significant[index]
            if token.type != TokenType.KW_CRAFT:
                index += 1
                continue

            parsed_return = self._parse_type_after_craft(significant, index)
            if parsed_return is None:
                index += 1
                continue

            return_type, name_index = parsed_return
            if name_index >= len(significant) or significant[name_index].type != TokenType.IDENT:
                index += 1
                continue

            name = significant[name_index].lexeme
            params = self._parse_parameter_signature(significant, name_index + 1)
            if name not in seen:
                functions.append(
                    CompletionSymbol(name, "funcion", f"({params}) -> {return_type}")
                )
                seen.add(name)
            index = name_index + 1

        return functions

    def _declared_module_aliases(self, source: str) -> list[CompletionSymbol]:
        tokens = self._safe_tokenize(source)
        if tokens is None:
            return []

        significant = self._significant_tokens(tokens)
        aliases: list[CompletionSymbol] = []
        seen = set()
        for index, token in enumerate(significant):
            if token.type != TokenType.KW_INVOKE:
                continue

            if index + 3 >= len(significant):
                continue
            module = significant[index + 1]
            as_token = significant[index + 2]
            alias = significant[index + 3]
            if (
                module.type == TokenType.STRING_LITERAL
                and as_token.type == TokenType.KW_AS
                and alias.type == TokenType.IDENT
                and alias.lexeme not in seen
            ):
                aliases.append(
                    CompletionSymbol(alias.lexeme, "modulo", module.lexeme.strip('"'))
                )
                seen.add(alias.lexeme)

        return aliases

    def _parse_type_after_craft(
        self,
        tokens: list[Token],
        craft_index: int,
    ) -> tuple[str, int] | None:
        colon_index = craft_index + 1
        if colon_index >= len(tokens) or tokens[colon_index].type != TokenType.COLON:
            return None
        return self._parse_type_at(tokens, colon_index + 1)

    def _parse_parameter_signature(self, tokens: list[Token], start: int) -> str:
        if start >= len(tokens) or tokens[start].type != TokenType.LPAREN:
            return ""

        params = []
        index = start + 1
        while index < len(tokens) and tokens[index].type != TokenType.RPAREN:
            if (
                tokens[index].type == TokenType.IDENT
                and index + 1 < len(tokens)
                and tokens[index + 1].type == TokenType.COLON
            ):
                parsed = self._parse_type_at(tokens, index + 2)
                if parsed is not None:
                    type_text, next_index = parsed
                    params.append(f"{tokens[index].lexeme}:{type_text}")
                    index = next_index
                    continue
            index += 1

        return ", ".join(params)

    def _parse_parameter_symbols(
        self,
        tokens: list[Token],
        craft_index: int,
    ) -> dict[str, CompletionSymbol]:
        parsed_return = self._parse_type_after_craft(tokens, craft_index)
        if parsed_return is None:
            return {}

        _return_type, name_index = parsed_return
        if name_index + 1 >= len(tokens) or tokens[name_index + 1].type != TokenType.LPAREN:
            return {}

        parameters: dict[str, CompletionSymbol] = {}
        index = name_index + 2
        while index < len(tokens) and tokens[index].type != TokenType.RPAREN:
            if (
                tokens[index].type == TokenType.IDENT
                and index + 1 < len(tokens)
                and tokens[index + 1].type == TokenType.COLON
            ):
                parsed = self._parse_type_at(tokens, index + 2)
                if parsed is not None:
                    type_text, next_index = parsed
                    parameters[tokens[index].lexeme] = CompletionSymbol(
                        tokens[index].lexeme,
                        "parametro",
                        type_text,
                    )
                    index = next_index
                    continue
            index += 1

        return parameters

    def _parse_type_at(
        self,
        tokens: list[Token],
        start: int,
    ) -> tuple[str, int] | None:
        if start >= len(tokens):
            return None

        token = tokens[start]
        if token.type in {
            TokenType.TYPE_INT,
            TokenType.TYPE_UINT32,
            TokenType.TYPE_UINT16,
            TokenType.TYPE_CHAR,
            TokenType.TYPE_VOID,
            TokenType.TYPE_ENDER,
        }:
            return token.lexeme, start + 1

        if token.type == TokenType.TYPE_POINTER:
            if start + 1 < len(tokens) and tokens[start + 1].type == TokenType.LBRACKET:
                parsed_base = self._parse_type_at(tokens, start + 2)
                if parsed_base is not None:
                    base_type, next_index = parsed_base
                    if next_index < len(tokens) and tokens[next_index].type == TokenType.RBRACKET:
                        return f"pointer[{base_type}]", next_index + 1
            return "pointer", start + 1

        if token.type == TokenType.TYPE_CHEST:
            if start + 1 >= len(tokens) or tokens[start + 1].type != TokenType.LBRACKET:
                return "chest", start + 1
            parsed_element = self._parse_type_at(tokens, start + 2)
            if parsed_element is None:
                return "chest", start + 1
            element_type, next_index = parsed_element
            if next_index >= len(tokens) or tokens[next_index].type != TokenType.COMMA:
                return f"chest[{element_type}]", next_index
            if next_index + 1 >= len(tokens):
                return f"chest[{element_type}]", next_index + 1
            size = tokens[next_index + 1]
            if size.type not in {TokenType.INT_LITERAL, TokenType.HEX_LITERAL}:
                return f"chest[{element_type}]", next_index + 1
            closing_index = next_index + 2
            if closing_index < len(tokens) and tokens[closing_index].type == TokenType.RBRACKET:
                closing_index += 1
            return f"chest[{element_type}, {size.lexeme}]", closing_index

        return None

    def _completion_prefix_start(self, source: str, cursor_position: int) -> int:
        if cursor_position == 0:
            return cursor_position

        previous = source[cursor_position - 1]
        if not (previous.isalpha() or previous in {"_", "@"}):
            return cursor_position

        index = cursor_position
        while index > 0:
            char = source[index - 1]
            if char.isalnum() or char in {"_", "@"}:
                index -= 1
                continue
            break
        return index

    def _rank_completion_suggestions(self, suggestions: list[Suggestion]) -> list[Suggestion]:
        if not suggestions:
            return []

        concrete = [
            suggestion
            for suggestion in suggestions
            if suggestion.label not in {"identificador"}
        ]
        return concrete or suggestions

    def _parse(self, tokens: list[Token]) -> Diagnostic | None:
        stack = [EOF, self.START_SYMBOL]
        index = 0

        while stack:
            top = stack.pop()
            current = tokens[min(index, len(tokens) - 1)]
            current_symbol = current.type.name

            if top == EPSILON:
                continue

            if top not in self.nonterminals:
                if top == current_symbol:
                    index += 1
                    continue
                return self._diagnostic(current, [top])

            production = self.table.get((top, current_symbol))
            if production is None:
                if EPSILON in self.first[top] and current_symbol in self.follow[top]:
                    continue
                expected = sorted(self._expected_terminals(top))
                return self._diagnostic(current, expected)

            for symbol in reversed(production):
                if symbol != EPSILON:
                    stack.append(symbol)

        return None

    def _diagnostic(self, token: Token, expected: list[str]) -> Diagnostic:
        if "SEMICOLON" in expected and token.type in {TokenType.RBRACE, TokenType.EOF}:
            expected = ["SEMICOLON"]

        labels = tuple(self._label_for(symbol) for symbol in expected)
        expected_text = ", ".join(labels[:6])
        if len(labels) > 6:
            expected_text += ", ..."

        found = "fin de archivo" if token.type == TokenType.EOF else f"'{token.lexeme}'"
        if token.type == TokenType.IDENT and self._expects_type(expected):
            valid_types = ", ".join(self._valid_type_labels())
            message = (
                f"Tipo desconocido '{token.lexeme}'. "
                f"Tipos reconocidos: {valid_types}. "
                "Nota: ender solo puede usarse dentro de chest[ender, N]."
            )
        else:
            message = f"Se encontro {found}; se esperaba {expected_text}."
        return Diagnostic(
            line=token.line,
            column=token.column,
            length=max(1, len(token.lexeme)),
            message=message,
            expected=labels,
            suggestions=tuple(self._suggestions_for(expected)),
        )

    def _diagnostic_from_lexer_error(self, error: LexerError) -> Diagnostic:
        return Diagnostic(
            line=error.line,
            column=error.column,
            length=1,
            message=self._phase_message(error, "Lexico"),
            expected=(),
            suggestions=(),
        )

    def _diagnostic_from_parse_error(self, error: ParseError) -> Diagnostic:
        token = error.token
        return Diagnostic(
            line=token.line,
            column=token.column,
            length=max(1, len(token.lexeme)),
            message=self._phase_message(error, "Sintactico"),
            expected=(),
            suggestions=(),
        )

    def _diagnostic_from_semantic_error(self, error: SemanticError) -> Diagnostic:
        node = error.node
        return Diagnostic(
            line=node.line,
            column=node.column,
            length=1,
            message=self._phase_message(error, "Semantico"),
            expected=(),
            suggestions=(),
        )

    def _analyze_compiler_phases(self, tokens: list[Token]) -> Diagnostic | None:
        try:
            ast = Parser(tokens, filename="<editor>").parse()
            SemanticAnalyzer(filename="<editor>").analyze(ast)
        except ParseError as error:
            return self._diagnostic_from_parse_error(error)
        except SemanticError as error:
            return self._diagnostic_from_semantic_error(error)
        return None

    def _structural_diagnostics(self, tokens: list[Token]) -> list[Diagnostic]:
        opening_to_closing = {
            TokenType.LPAREN: (TokenType.RPAREN, ")"),
            TokenType.LBRACE: (TokenType.RBRACE, "}"),
            TokenType.LBRACKET: (TokenType.RBRACKET, "]"),
        }
        closing_to_opening = {
            TokenType.RPAREN: (TokenType.LPAREN, "("),
            TokenType.RBRACE: (TokenType.LBRACE, "{"),
            TokenType.RBRACKET: (TokenType.LBRACKET, "["),
        }

        stack: list[Token] = []
        diagnostics: list[Diagnostic] = []

        for token in tokens:
            if token.type == TokenType.EOF:
                break

            if token.type in opening_to_closing:
                stack.append(token)
                continue

            if token.type not in closing_to_opening:
                continue

            expected_opening, opening_label = closing_to_opening[token.type]
            if stack and stack[-1].type == expected_opening:
                stack.pop()
                continue

            diagnostics.append(
                Diagnostic(
                    line=token.line,
                    column=token.column,
                    length=max(1, len(token.lexeme)),
                    message=(
                        f"Delimitador inesperado '{token.lexeme}'; "
                        f"no hay un '{opening_label}' abierto que cerrar."
                    ),
                    expected=(),
                    suggestions=(),
                )
            )

        for opening in reversed(stack):
            _closing_type, closing_label = opening_to_closing[opening.type]
            diagnostics.append(
                Diagnostic(
                    line=opening.line,
                    column=opening.column,
                    length=max(1, len(opening.lexeme)),
                    message=(
                        f"Falta cerrar '{closing_label}' para el "
                        f"'{opening.lexeme}' abierto en linea {opening.line}, "
                        f"columna {opening.column}."
                    ),
                    expected=(closing_label,),
                    suggestions=tuple(self._suggestions_for([_closing_type.name])),
                )
            )

        return diagnostics

    def _merge_diagnostics(
        self,
        primary: list[Diagnostic],
        secondary: list[Diagnostic],
    ) -> list[Diagnostic]:
        merged = []
        seen = set()
        has_missing_delimiter = any(
            set(diagnostic.expected) & {")", "]", "}"}
            for diagnostic in secondary
        )

        for diagnostic in [*primary, *secondary]:
            if (
                has_missing_delimiter
                and diagnostic.message.startswith("Se encontro fin de archivo")
                and ";" not in diagnostic.expected
            ):
                continue

            key = (diagnostic.line, diagnostic.column, diagnostic.message)
            if key in seen:
                continue
            merged.append(diagnostic)
            seen.add(key)

        return merged

    def _refine_diagnostic(self, tokens: list[Token], diagnostic: Diagnostic) -> Diagnostic:
        diagnostic = self._refine_malformed_number_diagnostic(tokens, diagnostic)
        diagnostic = self._refine_incomplete_return_diagnostic(tokens, diagnostic)
        diagnostic = self._refine_missing_semicolon_before_statement(tokens, diagnostic)
        return diagnostic

    def _refine_malformed_number_diagnostic(
        self,
        tokens: list[Token],
        diagnostic: Diagnostic,
    ) -> Diagnostic:
        current = self._token_at_diagnostic(tokens, diagnostic)
        if current is None or current.type != TokenType.IDENT:
            return diagnostic

        previous = self._previous_token_before(tokens, diagnostic)
        if previous is None or previous.type not in {TokenType.INT_LITERAL, TokenType.HEX_LITERAL}:
            return diagnostic

        if previous.line != current.line:
            return diagnostic

        expected_column = previous.column + len(previous.lexeme)
        if current.column != expected_column:
            return diagnostic

        bad_literal = previous.lexeme + current.lexeme
        return Diagnostic(
            line=previous.line,
            column=previous.column,
            length=len(bad_literal),
            message=(
                f"Literal numerico invalido '{bad_literal}'. "
                "Un numero no puede contener letras; separe el identificador "
                "con un operador o espacio si esa era la intencion."
            ),
            expected=(),
            suggestions=(),
        )

    def _refine_incomplete_return_diagnostic(
        self,
        tokens: list[Token],
        diagnostic: Diagnostic,
    ) -> Diagnostic:
        if diagnostic.expected != (";",):
            return diagnostic

        previous = self._previous_token_before(tokens, diagnostic)
        if previous is None or previous.type != TokenType.KW_RETURN:
            return diagnostic

        return_type = self._enclosing_function_return_type(tokens, previous)
        if return_type is None or return_type == "void":
            return diagnostic

        return Diagnostic(
            line=previous.line,
            column=previous.column,
            length=len(previous.lexeme),
            message=(
                f"Return incompleto: la funcion actual retorna {return_type}; "
                "escriba una expresion antes de ';'."
            ),
            expected=("expresion",),
            suggestions=(),
        )

    def _refine_missing_semicolon_before_statement(
        self,
        tokens: list[Token],
        diagnostic: Diagnostic,
    ) -> Diagnostic:
        if ";" not in diagnostic.expected:
            return diagnostic

        current = self._token_at_diagnostic(tokens, diagnostic)
        if current is None or current.type == TokenType.EOF:
            return diagnostic

        previous = self._previous_token_before(tokens, diagnostic)
        if previous is None or previous.line == current.line:
            return diagnostic

        if previous.type in {
            TokenType.SEMICOLON,
            TokenType.LBRACE,
            TokenType.RBRACE,
            TokenType.LPAREN,
            TokenType.LBRACKET,
            TokenType.COLON,
            TokenType.COMMA,
        }:
            return diagnostic

        if current.type not in self._statement_start_tokens():
            return diagnostic

        return Diagnostic(
            line=previous.line,
            column=previous.column + len(previous.lexeme),
            length=1,
            message="Falta ';' despues de la instruccion anterior.",
            expected=(";",),
            suggestions=tuple(self._suggestions_for(["SEMICOLON"])),
        )

    def _statement_start_tokens(self) -> set[TokenType]:
        return {
            TokenType.IDENT,
            TokenType.KW_IF,
            TokenType.KW_WHILE,
            TokenType.KW_FOR,
            TokenType.KW_RETURN,
            TokenType.KW_SUMMON,
            TokenType.KW_ENDERPORTAL,
            TokenType.KW_ENDEROPEN,
            TokenType.KW_ENDERCLOSE,
            TokenType.KW_ENDERLOAD,
            TokenType.KW_ENDERSTORE,
            TokenType.KW_ENDERKEY,
            TokenType.KW_ENDERLOW,
            TokenType.KW_ENDERHIGH,
            TokenType.KW_ENDERCHANGE,
            TokenType.KW_CLOSE,
            TokenType.RBRACE,
        }

    def _token_at_diagnostic(
        self,
        tokens: list[Token],
        diagnostic: Diagnostic,
    ) -> Token | None:
        for token in tokens:
            if token.type == TokenType.EOF:
                continue
            if token.line == diagnostic.line and token.column == diagnostic.column:
                return token
        return None

    def _previous_token_before(
        self,
        tokens: list[Token],
        diagnostic: Diagnostic,
    ) -> Token | None:
        previous = None
        for token in tokens:
            if token.type == TokenType.EOF:
                break
            if (token.line, token.column) >= (diagnostic.line, diagnostic.column):
                break
            previous = token
        return previous

    def _enclosing_function_return_type(
        self,
        tokens: list[Token],
        anchor: Token,
    ) -> str | None:
        brace_depth = 0
        pending_return_type: str | None = None
        function_stack: list[tuple[int, str]] = []

        for index, token in enumerate(tokens):
            if token is anchor:
                break

            if token.type == TokenType.KW_CRAFT:
                pending_return_type = self._function_return_type_after_craft(tokens, index)
                continue

            if token.type == TokenType.LBRACE:
                brace_depth += 1
                if pending_return_type is not None:
                    function_stack.append((brace_depth, pending_return_type))
                    pending_return_type = None
                continue

            if token.type == TokenType.RBRACE:
                while function_stack and function_stack[-1][0] == brace_depth:
                    function_stack.pop()
                brace_depth = max(0, brace_depth - 1)

        if not function_stack:
            return None
        return function_stack[-1][1]

    def _function_return_type_after_craft(
        self,
        tokens: list[Token],
        craft_index: int,
    ) -> str | None:
        index = craft_index + 1
        if index >= len(tokens) or tokens[index].type != TokenType.COLON:
            return None

        index += 1
        if index >= len(tokens) or tokens[index].type not in {
            TokenType.TYPE_INT,
            TokenType.TYPE_UINT32,
            TokenType.TYPE_UINT16,
            TokenType.TYPE_CHAR,
            TokenType.TYPE_VOID,
            TokenType.TYPE_POINTER,
            TokenType.TYPE_CHEST,
            TokenType.TYPE_ENDER,
        }:
            return None

        return tokens[index].lexeme

    def _expects_type(self, expected: list[str]) -> bool:
        return bool(set(expected) & set(TYPE_TERMINALS))

    def _valid_type_labels(self) -> tuple[str, ...]:
        return tuple(self._label_for(symbol) for symbol in TYPE_TERMINALS)

    def _phase_message(self, error: Exception, phase: str) -> str:
        message = str(error)
        if ": " in message:
            message = message.split(": ", 1)[1]
        return f"{phase}: {message}"

    def _suggestions_for(self, symbols: list[str]) -> list[Suggestion]:
        suggestions = []
        seen = set()
        for symbol in symbols:
            for suggestion in self._suggestions_for_terminal(symbol):
                if suggestion.label in seen:
                    continue
                suggestions.append(suggestion)
                seen.add(suggestion.label)
        return suggestions

    def _top_level_suggestions(self) -> list[Suggestion]:
        return [
            TERMINAL_SUGGESTIONS["PRAGMA_ENTER_CRAFT_WORLD"],
            TERMINAL_SUGGESTIONS["KW_INVOKE"],
            *self._suggestions_for_terminal("KW_CRAFT"),
        ]

    def _suggestions_for_terminal(self, symbol: str) -> tuple[Suggestion, ...]:
        suggestion = TERMINAL_SUGGESTIONS.get(symbol)
        if suggestion is None:
            return ()
        if isinstance(suggestion, Suggestion):
            return (suggestion,)
        return tuple(suggestion)

    def _expected_terminals(self, nonterminal: str) -> set[str]:
        terminals = set(self.first[nonterminal])
        terminals.discard(EPSILON)
        if EPSILON in self.first[nonterminal]:
            terminals.update(self.follow[nonterminal])
        terminals.discard(EOF)
        return terminals

    def _first_of_sequence(self, sequence: tuple[str, ...]) -> set[str]:
        if not sequence:
            return {EPSILON}

        result = set()
        for symbol in sequence:
            symbol_first = self.first.get(symbol, {symbol})
            result.update(symbol_first - {EPSILON})
            if EPSILON not in symbol_first:
                break
        else:
            result.add(EPSILON)
        return result

    def _compute_first_sets(self) -> dict[str, set[str]]:
        first: dict[str, set[str]] = {nonterminal: set() for nonterminal in self.nonterminals}

        changed = True
        while changed:
            changed = False
            for nonterminal, productions in self.grammar.items():
                for production in productions:
                    before = len(first[nonterminal])
                    first[nonterminal].update(self._first_sequence_with(first, production))
                    changed |= len(first[nonterminal]) != before
        return first

    def _first_sequence_with(
        self,
        first: dict[str, set[str]],
        sequence: tuple[str, ...],
    ) -> set[str]:
        if not sequence:
            return {EPSILON}

        result = set()
        for symbol in sequence:
            symbol_first = first[symbol] if symbol in self.nonterminals else {symbol}
            result.update(symbol_first - {EPSILON})
            if EPSILON not in symbol_first:
                break
        else:
            result.add(EPSILON)
        return result

    def _compute_follow_sets(self) -> dict[str, set[str]]:
        follow = {nonterminal: set() for nonterminal in self.nonterminals}
        follow[self.START_SYMBOL].add(EOF)

        changed = True
        while changed:
            changed = False
            for left, productions in self.grammar.items():
                for production in productions:
                    for index, symbol in enumerate(production):
                        if symbol not in self.nonterminals:
                            continue

                        beta = production[index + 1 :]
                        beta_first = self._first_of_sequence(beta)
                        before = len(follow[symbol])
                        follow[symbol].update(beta_first - {EPSILON})
                        if EPSILON in beta_first or not beta:
                            follow[symbol].update(follow[left])
                        changed |= len(follow[symbol]) != before
        return follow

    def _build_parse_table(self) -> dict[tuple[str, str], tuple[str, ...]]:
        table = {}
        for nonterminal, productions in self.grammar.items():
            for production in productions:
                first = self._first_of_sequence(production)
                for terminal in first - {EPSILON}:
                    table[(nonterminal, terminal)] = production
                if EPSILON in first:
                    for terminal in self.follow[nonterminal]:
                        table.setdefault((nonterminal, terminal), production)
        return table

    def _build_grammar(self) -> dict[str, list[tuple[str, ...]]]:
        type_tokens = (
            "TYPE_INT",
            "TYPE_UINT32",
            "TYPE_UINT16",
            "TYPE_CHAR",
            "TYPE_VOID",
            "TYPE_ENDER",
        )
        vault_keywords = (
            "KW_ENDEROPEN",
            "KW_ENDERCLOSE",
            "KW_ENDERLOAD",
            "KW_ENDERSTORE",
            "KW_ENDERKEY",
            "KW_ENDERLOW",
            "KW_ENDERHIGH",
            "KW_CHANGEPASSWORD",
        )

        grammar: dict[str, list[tuple[str, ...]]] = {
            "Program": [("EnterOpt", "TopItems", "EOF")],
            "EnterOpt": [("PRAGMA_ENTER_CRAFT_WORLD",), (EPSILON,)],
            "TopItems": [("TopItem", "TopItems"), (EPSILON,)],
            "TopItem": [
                ("ImportDecl",),
                ("FunctionDecl",),
                ("PRAGMA_INLINE", "FunctionDecl"),
                ("Statement",),
            ],
            "ImportDecl": [
                ("KW_INVOKE", "STRING_LITERAL", "KW_AS", "IDENT", "SEMICOLON")
            ],
            "FunctionDecl": [
                (
                    "KW_CRAFT",
                    "COLON",
                    "Type",
                    "IDENT",
                    "LPAREN",
                    "ParamsOpt",
                    "RPAREN",
                    "Block",
                )
            ],
            "ParamsOpt": [("Param", "ParamTail"), (EPSILON,)],
            "ParamTail": [("COMMA", "Param", "ParamTail"), (EPSILON,)],
            "Param": [("IDENT", "COLON", "Type")],
            "Type": [
                *[(token,) for token in type_tokens],
                ("TYPE_POINTER", "PointerTypeTail"),
                ("TYPE_CHEST", "LBRACKET", "ChestTypeInner", "COMMA", "Expr", "RBRACKET"),
            ],
            "PointerTypeTail": [("LBRACKET", "Type", "RBRACKET"), (EPSILON,)],
            "ChestTypeInner": [("Type",), ("TYPE_ENDER",)],
            "Block": [("LBRACE", "Statements", "RBRACE")],
            "Statements": [("Statement", "Statements"), (EPSILON,)],
            "Statement": [
                ("Block",),
                ("IfStmt",),
                ("WhileStmt",),
                ("ForStmt",),
                ("ReturnStmt",),
                ("EnderPortalStmt",),
                ("IdentStmt",),
                ("SummonStmt",),
                ("VaultStmt",),
            ],
            "IfStmt": [
                ("KW_IF", "LPAREN", "Expr", "RPAREN", "Block", "ElseOpt")
            ],
            "ElseOpt": [("KW_ELSE", "ElseBody"), (EPSILON,)],
            "ElseBody": [("IfStmt",), ("Block",)],
            "WhileStmt": [("KW_WHILE", "LPAREN", "Expr", "RPAREN", "Block")],
            "ForStmt": [
                (
                    "KW_FOR",
                    "LPAREN",
                    "ForInitOpt",
                    "SEMICOLON",
                    "ExprOpt",
                    "SEMICOLON",
                    "ForUpdateOpt",
                    "RPAREN",
                    "Block",
                )
            ],
            "ForInitOpt": [("IdentStmtNoSemi",), (EPSILON,)],
            "ForUpdateOpt": [("IdentStmtNoSemi",), (EPSILON,)],
            "ReturnStmt": [("KW_RETURN", "ReturnExprOpt", "SEMICOLON")],
            "ReturnExprOpt": [("Expr",), (EPSILON,)],
            "EnderPortalStmt": [
                (
                    "KW_ENDERPORTAL",
                    "LPAREN",
                    "Expr",
                    "RPAREN",
                    "COLON",
                    "PortalStatements",
                    "KW_ENDCHANGE",
                )
            ],
            "PortalStatements": [("PortalStatement", "PortalStatements"), (EPSILON,)],
            "PortalStatement": [
                ("IdentStmt",),
                ("VaultStmt",),
                ("KW_ENDERCHANGE", "LPAREN", "Expr", "RPAREN"),
                ("KW_ENDERCLOSE", "SemiOpt"),
                ("KW_CLOSE", "SemiOpt"),
            ],
            "SemiOpt": [("SEMICOLON",), (EPSILON,)],
            "IdentStmt": [("IdentStmtNoSemi", "SEMICOLON")],
            "IdentStmtNoSemi": [("IDENT", "IdentTail")],
            "IdentTail": [
                ("COLON", "Type", "ASSIGN", "Expr"),
                ("ASSIGN", "Expr"),
                ("LBRACKET", "Expr", "RBRACKET", "ASSIGN", "Expr"),
                ("LPAREN", "ArgsOpt", "RPAREN"),
            ],
            "SummonStmt": [("CallExpr", "SEMICOLON")],
            "VaultStmt": [("VaultKeyword", "VaultArgsOpt", "SEMICOLON")],
            "VaultKeyword": [(token,) for token in vault_keywords],
            "VaultArgsOpt": [("Expr", "VaultArgsTail"), (EPSILON,)],
            "VaultArgsTail": [("COMMA", "Expr", "VaultArgsTail"), (EPSILON,)],
            "ExprOpt": [("Expr",), (EPSILON,)],
            "Expr": [("Prefix", "ExprTail")],
            "ExprTail": [("BinaryOp", "Prefix", "ExprTail"), (EPSILON,)],
            "Prefix": [("UnaryOp", "Prefix"), ("Primary",)],
            "Primary": [("Atom", "Postfixes")],
            "Atom": [
                ("IDENT",),
                ("INT_LITERAL",),
                ("HEX_LITERAL",),
                ("STRING_LITERAL",),
                ("CallExpr",),
                ("LPAREN", "Expr", "RPAREN"),
                ("LBRACKET", "ArgsOpt", "RBRACKET"),
                ("SPECIAL_LPLUS4",),
                ("SPECIAL_RPLUS5",),
            ],
            "Postfixes": [("Postfix", "Postfixes"), (EPSILON,)],
            "Postfix": [
                ("LPAREN", "ArgsOpt", "RPAREN"),
                ("LBRACKET", "Expr", "RBRACKET"),
                ("DOT", "IDENT"),
            ],
            "CallExpr": [("KW_SUMMON", "COLON", "CallTarget", "LPAREN", "ArgsOpt", "RPAREN")],
            "CallTarget": [("IDENT", "CallTargetTail")],
            "CallTargetTail": [("DOT", "IDENT"), (EPSILON,)],
            "ArgsOpt": [("Expr", "ArgsTail"), (EPSILON,)],
            "ArgsTail": [("COMMA", "Expr", "ArgsTail"), (EPSILON,)],
            "BinaryOp": [
                ("PLUS",),
                ("MINUS",),
                ("STAR",),
                ("SLASH",),
                ("SHIFT_LEFT",),
                ("SHIFT_RIGHT",),
                ("EQ",),
                ("NEQ",),
                ("LT",),
                ("GT",),
                ("LE",),
                ("GE",),
                ("BIT_XOR",),
                ("BIT_AND",),
                ("BIT_OR",),
                ("SPECIAL_LPLUS4",),
                ("SPECIAL_RPLUS5",),
            ],
            "UnaryOp": [("MINUS",), ("BIT_NOT",)],
        }
        return grammar

    def _label_for(self, symbol: str) -> str:
        return TERMINAL_LABELS.get(symbol, symbol)


TERMINAL_LABELS = {
    "PRAGMA_ENTER_CRAFT_WORLD": "@EnterCraftWorld",
    "PRAGMA_INLINE": "@inline",
    "KW_CRAFT": "craft",
    "KW_INVOKE": "invoke",
    "KW_AS": "as",
    "KW_SUMMON": "summon",
    "KW_IF": "if",
    "KW_ELSE": "else",
    "KW_WHILE": "while",
    "KW_FOR": "for",
    "KW_RETURN": "return",
    "KW_ENDEROPEN": "enderopen",
    "KW_ENDERCLOSE": "enderclose",
    "KW_ENDERLOAD": "enderload",
    "KW_ENDERSTORE": "enderstore",
    "KW_ENDERKEY": "enderkey",
    "KW_ENDERLOW": "enderlow",
    "KW_ENDERHIGH": "enderhigh",
    "KW_ENDERPORTAL": "enderPortal",
    "KW_CHANGEPASSWORD": "changePassword",
    "KW_CLOSE": "close",
    "KW_ENDCHANGE": "endchange",
    "KW_ENDERCHANGE": "enderchange",
    "IDENT": "identificador",
    "STRING_LITERAL": "cadena",
    "INT_LITERAL": "entero",
    "HEX_LITERAL": "hexadecimal",
    "SEMICOLON": ";",
    "COLON": ":",
    "COMMA": ",",
    "DOT": ".",
    "LPAREN": "(",
    "RPAREN": ")",
    "LBRACE": "{",
    "RBRACE": "}",
    "LBRACKET": "[",
    "RBRACKET": "]",
    "ASSIGN": "=",
    "PLUS": "+",
    "MINUS": "-",
    "STAR": "*",
    "SLASH": "/",
    "EQ": "==",
    "NEQ": "!=",
    "LT": "<",
    "GT": ">",
    "LE": "<=",
    "GE": ">=",
    "SHIFT_LEFT": "<<",
    "SHIFT_RIGHT": ">>",
    "BIT_XOR": "^",
    "BIT_AND": "&",
    "BIT_OR": "|",
    "BIT_NOT": "~",
    "SPECIAL_LPLUS4": "<+4",
    "SPECIAL_RPLUS5": ">+5",
    "TYPE_INT": "int",
    "TYPE_UINT32": "uint32",
    "TYPE_UINT16": "uint16",
    "TYPE_CHAR": "char",
    "TYPE_VOID": "void",
    "TYPE_POINTER": "pointer",
    "TYPE_CHEST": "chest",
    "TYPE_ENDER": "ender",
}


TERMINAL_SUGGESTIONS = {
    "PRAGMA_ENTER_CRAFT_WORLD": Suggestion(
        "@EnterCraftWorld",
        "@EnterCraftWorld\n",
        "pragma requerido al inicio del archivo",
    ),
    "PRAGMA_INLINE": Suggestion("@inline", "@inline\n", "marca la siguiente funcion como inline"),
    "KW_CRAFT": (
        Suggestion("craft function", "craft:int funcion() {\n    return 0;\n}", "plantilla de funcion"),
        Suggestion("craft main", "craft:int main() {\n    return 0;\n}", "punto de entrada"),
    ),
    "KW_INVOKE": Suggestion("invoke", 'invoke "modulo" as alias;', "importa otro archivo Craft"),
    "KW_IF": Suggestion("if block", "if () {\n    \n}", "bloque condicional"),
    "KW_WHILE": Suggestion("while block", "while () {\n    \n}", "ciclo while"),
    "KW_FOR": Suggestion("for loop", "for (; ; ) {\n    \n}", "ciclo for"),
    "KW_RETURN": Suggestion("return", "return ;", "retorna desde la funcion actual"),
    "KW_SUMMON": Suggestion("summon", "summon:", "llamada a funcion"),
    "KW_ENDERPORTAL": Suggestion(
        "enderPortal block",
        "enderPortal():\n    \nendchange",
        "bloque de operaciones de boveda",
    ),
    "IDENT": Suggestion("identificador", "nombre"),
    "TYPE_INT": Suggestion("int", "int", "entero con signo"),
    "TYPE_UINT32": Suggestion("uint32", "uint32", "entero sin signo de 32 bits"),
    "TYPE_UINT16": Suggestion("uint16", "uint16", "entero sin signo de 16 bits"),
    "TYPE_CHAR": Suggestion("char", "char", "caracter / byte"),
    "TYPE_VOID": Suggestion("void", "void", "sin valor de retorno"),
    "TYPE_POINTER": (
        Suggestion("pointer", "pointer", "puntero sin tipo base"),
        Suggestion("pointer[int]", "pointer[int]", "puntero tipado"),
    ),
    "TYPE_CHEST": (
        Suggestion("chest", "chest", "arreglo fijo"),
        Suggestion("chest[int, 4]", "chest[int, 4]", "arreglo fijo de enteros"),
        Suggestion("chest[ender, 4]", "chest[ender, 4]", "boveda de llaves"),
    ),
    "SEMICOLON": Suggestion("Insertar ;", ";"),
    "COLON": Suggestion("Insertar :", ":"),
    "RPAREN": Suggestion("Cerrar )", ")"),
    "RBRACE": Suggestion("Cerrar }", "}"),
    "RBRACKET": Suggestion("Cerrar ]", "]"),
    "ASSIGN": Suggestion("=", "="),
}
