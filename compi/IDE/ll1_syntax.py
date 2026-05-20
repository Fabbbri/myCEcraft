from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import sys


COMPI_ROOT = Path(__file__).resolve().parents[1]
if str(COMPI_ROOT) not in sys.path:
    sys.path.insert(0, str(COMPI_ROOT))

from lexer import Lexer, LexerError
from tokens import Token, TokenType


EPSILON = "ε"
EOF = "EOF"


@dataclass(frozen=True)
class Suggestion:
    label: str
    insert_text: str


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

    def analyze(self, source: str) -> tuple[list[Diagnostic], list[Suggestion]]:
        try:
            tokens = Lexer(source, filename="<editor>").tokenize()
        except LexerError as error:
            return [self._diagnostic_from_lexer_error(error)], []

        diagnostic = self._parse(tokens)
        if diagnostic is not None:
            return [diagnostic], list(diagnostic.suggestions)

        return [], self._top_level_suggestions()

    def complete(self, source: str, cursor_position: int) -> list[Suggestion]:
        prefix_start = self._completion_prefix_start(source, cursor_position)
        prefix = source[prefix_start:cursor_position]
        context_source = source[:prefix_start]

        _diagnostics, suggestions = self.analyze(context_source)
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
            message=str(error),
            expected=(),
            suggestions=(),
        )

    def _suggestions_for(self, symbols: list[str]) -> list[Suggestion]:
        suggestions = []
        seen = set()
        for symbol in symbols:
            suggestion = TERMINAL_SUGGESTIONS.get(symbol)
            if suggestion is None or suggestion.label in seen:
                continue
            suggestions.append(suggestion)
            seen.add(suggestion.label)
        return suggestions[:8]

    def _top_level_suggestions(self) -> list[Suggestion]:
        return [
            TERMINAL_SUGGESTIONS["PRAGMA_ENTER_CRAFT_WORLD"],
            TERMINAL_SUGGESTIONS["KW_INVOKE"],
            TERMINAL_SUGGESTIONS["KW_CRAFT"],
        ]

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
    "IDENT": "identificador",
    "STRING_LITERAL": "cadena",
    "INT_LITERAL": "entero",
    "HEX_LITERAL": "hexadecimal",
    "SEMICOLON": ";",
    "COLON": ":",
    "COMMA": ",",
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
    "PRAGMA_ENTER_CRAFT_WORLD": Suggestion("@EnterCraftWorld", "@EnterCraftWorld\n"),
    "PRAGMA_INLINE": Suggestion("@inline", "@inline\n"),
    "KW_CRAFT": Suggestion("craft function", "craft:int main() {\n    return 0;\n}"),
    "KW_INVOKE": Suggestion("invoke", 'invoke "modulo" as alias;'),
    "KW_IF": Suggestion("if", "if () {\n    \n}"),
    "KW_WHILE": Suggestion("while", "while () {\n    \n}"),
    "KW_FOR": Suggestion("for", "for (; ; ) {\n    \n}"),
    "KW_RETURN": Suggestion("return", "return ;"),
    "KW_SUMMON": Suggestion("summon", "summon:funcion()"),
    "IDENT": Suggestion("identificador", "nombre"),
    "TYPE_INT": Suggestion("int", "int"),
    "TYPE_UINT32": Suggestion("uint32", "uint32"),
    "TYPE_UINT16": Suggestion("uint16", "uint16"),
    "TYPE_CHAR": Suggestion("char", "char"),
    "TYPE_VOID": Suggestion("void", "void"),
    "TYPE_POINTER": Suggestion("pointer", "pointer"),
    "TYPE_CHEST": Suggestion("chest", "chest"),
    "SEMICOLON": Suggestion("Insertar ;", ";"),
    "COLON": Suggestion("Insertar :", ":"),
    "RPAREN": Suggestion("Cerrar )", ")"),
    "RBRACE": Suggestion("Cerrar }", "}"),
    "RBRACKET": Suggestion("Cerrar ]", "]"),
    "ASSIGN": Suggestion("=", "="),
}
