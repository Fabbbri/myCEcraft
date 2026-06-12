from __future__ import annotations

import sys
import unittest
from pathlib import Path


COMPI_ROOT = Path(__file__).resolve().parents[1]
IDE_ROOT = COMPI_ROOT / "IDE"
for path in (COMPI_ROOT, IDE_ROOT):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

from lexer import Lexer
from ll1_syntax import EOF, EPSILON, LL1SyntaxService, TERMINAL_SUGGESTIONS
from tokens import TokenType


VALID_PROGRAMS = {
    "basic": """@EnterCraftWorld
craft:int main() {
    return 0;
}""",
    "imports_and_module_call": """@EnterCraftWorld
invoke "math" as math;
craft:int main() {
    summon:math.run(1);
    return 0;
}""",
    "functions_parameters_and_call": """@EnterCraftWorld
craft:int add(a:int, b:int) {
    return a + b;
}
craft:int main() {
    result:int = summon:add(1, 2);
    return result;
}""",
    "types_and_arrays": """@EnterCraftWorld
craft:int main() {
    typed:pointer[int];
    raw:pointer;
    values:chest[int, 3] = [1, 2, 3];
    keys:chest[ender, 4];
    return values[0];
}""",
    "control_flow": """@EnterCraftWorld
craft:int main() {
    x:int = 0;
    if (x == 0) {
        x = 1;
    } else if (x < 2) {
        x = 2;
    } else {
        x = 3;
    }
    while (x < 5) {
        x = x + 1;
    }
    for (i:int = 0; i < 2; i = i + 1) {
        x = x + i;
    }
    return x;
}""",
    "empty_for_sections": """@EnterCraftWorld
craft:int main() {
    for (;;) {
        return 0;
    }
    return 0;
}""",
    "vault_operations": """@EnterCraftWorld
craft:int main() {
    enderopen 1;
    enderopen 1, 2;
    enderload v3, 0(v0);
    enderstore v3, 4(v0);
    enderkey 1, 2;
    enderlow 1, 2, 3;
    enderhigh 1, 2, 3;
    enderclose
    close
    return 0;
}""",
    "ender_portal_forms": """@EnterCraftWorld
craft:int main() {
    enderPortal(1):
        enderchange(2)
        enderclose
    endchange;
    enderPortal(1);
    return 0;
}""",
    "operators": """@EnterCraftWorld
craft:int main() {
    x:int = -1 + 2 * 3 / 1 - 4 << 1 >> 1 ^ 2 & 3 | 4;
    y:int = ~x;
    z:int = x == y;
    return z;
}""",
    "inline_function": """@EnterCraftWorld
@inline
craft:int one() {
    return 1;
}
craft:int main() {
    return summon:one();
}""",
}


class IDELanguageServiceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.service = LL1SyntaxService()

    def _insert_texts(self, source: str) -> list[str]:
        return [
            suggestion.insert_text
            for suggestion in self.service.complete(source, len(source))
        ]

    def _source_fragment(self, source: str, line: int, column: int, length: int) -> str:
        line_text = source.splitlines()[line - 1]
        start = column - 1
        return line_text[start : start + length]

    def test_ll1_table_has_no_conflicting_productions(self) -> None:
        entries: dict[tuple[str, str], tuple[str, ...]] = {}
        conflicts = []

        for nonterminal, productions in self.service.grammar.items():
            for production in productions:
                first = self.service._first_of_sequence(production)
                terminals = first - {EPSILON}
                if EPSILON in first:
                    terminals |= self.service.follow[nonterminal]

                for terminal in terminals:
                    key = (nonterminal, terminal)
                    previous = entries.get(key)
                    if previous is not None and previous != production:
                        conflicts.append((key, previous, production))
                    entries[key] = production

        self.assertEqual(conflicts, [])

    def test_grammar_uses_only_declared_symbols(self) -> None:
        token_names = {token_type.name for token_type in TokenType}
        unknown = set()

        for productions in self.service.grammar.values():
            for production in productions:
                for symbol in production:
                    if (
                        symbol not in self.service.nonterminals
                        and symbol not in token_names
                        and symbol not in {EPSILON, EOF}
                    ):
                        unknown.add(symbol)

        self.assertEqual(unknown, set())

    def test_all_configured_suggestions_are_nonempty(self) -> None:
        for terminal, configured in TERMINAL_SUGGESTIONS.items():
            suggestions = configured if isinstance(configured, tuple) else (configured,)
            with self.subTest(terminal=terminal):
                self.assertTrue(suggestions)
                for suggestion in suggestions:
                    self.assertTrue(suggestion.label)
                    self.assertTrue(suggestion.insert_text)

    def test_representative_valid_programs_have_no_diagnostics(self) -> None:
        for name, source in VALID_PROGRAMS.items():
            with self.subTest(program=name):
                diagnostics, _suggestions = self.service.analyze(source)
                self.assertEqual(diagnostics, [])

    def test_lexical_diagnostics_mark_the_responsible_text(self) -> None:
        cases = {
            "unknown_symbol": (
                "@EnterCraftWorld\n#",
                "#",
                "símbolo no reconocido",
            ),
            "unterminated_string": (
                '@EnterCraftWorld\ninvoke "abc',
                '"abc',
                "cadena sin cerrar",
            ),
            "unterminated_comment": (
                "@EnterCraftWorld\n/* comment",
                "/*",
                "comentario",
            ),
        }

        for name, (source, fragment, message) in cases.items():
            with self.subTest(case=name):
                diagnostics, _suggestions = self.service.analyze(source)
                self.assertEqual(len(diagnostics), 1)
                diagnostic = diagnostics[0]
                self.assertIn(message, diagnostic.message.lower())
                self.assertEqual(
                    self._source_fragment(
                        source,
                        diagnostic.line,
                        diagnostic.column,
                        diagnostic.length,
                    ),
                    fragment,
                )

    def test_syntax_diagnostics_report_expected_constructs_and_spans(self) -> None:
        cases = {
            "missing_pragma": (
                "craft:int main() { return 0; }",
                "craft",
                (),
                "@EnterCraftWorld",
            ),
            "unknown_type": (
                "@EnterCraftWorld\ncraft:int main() { value:banana = 0; return 0; }",
                "banana",
                ("int",),
                "Tipo desconocido",
            ),
            "missing_semicolon": (
                """@EnterCraftWorld
craft:int main() {
    value:int = 0
    return value;
}""",
                None,
                (";",),
                "Falta ';'",
            ),
            "malformed_number": (
                """@EnterCraftWorld
craft:int main() {
    value:int = 5abc;
    return 0;
}""",
                "5abc",
                (),
                "Literal numerico invalido",
            ),
        }

        for name, (source, fragment, expected_subset, message) in cases.items():
            with self.subTest(case=name):
                diagnostics, _suggestions = self.service.analyze(source)
                self.assertTrue(diagnostics)
                diagnostic = diagnostics[0]
                self.assertIn(message, diagnostic.message)
                self.assertTrue(set(expected_subset).issubset(diagnostic.expected))
                if fragment is None:
                    line_text = source.splitlines()[diagnostic.line - 1]
                    self.assertEqual(diagnostic.column, len(line_text) + 1)
                else:
                    self.assertEqual(
                        self._source_fragment(
                            source,
                            diagnostic.line,
                            diagnostic.column,
                            diagnostic.length,
                        ),
                        fragment,
                    )

    def test_unbalanced_delimiters_report_opening_or_unexpected_closer(self) -> None:
        cases = {
            "parenthesis": (
                "@EnterCraftWorld\ncraft:int main() { while (1 { return 0; } }",
                ")",
            ),
            "bracket": (
                "@EnterCraftWorld\ncraft:int main() { values:chest[int, 2] = [1, 2; }",
                "]",
            ),
            "brace": (
                "@EnterCraftWorld\ncraft:int main() { return 0;",
                "}",
            ),
            "unexpected_closer": (
                "@EnterCraftWorld\n}\ncraft:int main() { return 0; }",
                None,
            ),
        }

        for name, (source, expected_closer) in cases.items():
            with self.subTest(case=name):
                diagnostics, _suggestions = self.service.analyze(source)
                self.assertTrue(diagnostics)
                if expected_closer is None:
                    self.assertTrue(
                        any("Delimitador inesperado" in item.message for item in diagnostics)
                    )
                else:
                    self.assertTrue(
                        any(expected_closer in item.expected for item in diagnostics)
                    )

    def test_semantic_diagnostics_mark_the_most_specific_token(self) -> None:
        cases = {
            "undeclared_variable": (
                "@EnterCraftWorld\ncraft:int main() { return missingValue; }",
                "missingValue",
                "no fue declarado",
            ),
            "undeclared_function": (
                "@EnterCraftWorld\ncraft:int main() { return summon:missingFunction(); }",
                "missingFunction",
                "no fue declarada",
            ),
            "wrong_argument_count": (
                """@EnterCraftWorld
craft:int identity(value:int) { return value; }
craft:int main() { return summon:identity(); }""",
                "identity",
                "esperaba 1 argumentos",
            ),
            "duplicate_variable": (
                "@EnterCraftWorld\ncraft:int main() { value:int; value:int; return 0; }",
                "value",
                "ya fue declarado",
            ),
            "missing_return": (
                "@EnterCraftWorld\ncraft:int calculate() { value:int = 0; }",
                "calculate",
                "debe retornar",
            ),
            "invalid_ender_type": (
                "@EnterCraftWorld\ncraft:int main() { value:ender; return 0; }",
                "ender",
                "ender solo puede",
            ),
            "vault_arity": (
                "@EnterCraftWorld\ncraft:int main() { enderload 1; return 0; }",
                "enderload",
                "esperaba 2 operandos",
            ),
        }

        for name, (source, fragment, message) in cases.items():
            with self.subTest(case=name):
                diagnostics, _suggestions = self.service.analyze(source)
                self.assertEqual(len(diagnostics), 1)
                diagnostic = diagnostics[0]
                self.assertIn(message, diagnostic.message)
                self.assertEqual(
                    self._source_fragment(
                        source,
                        diagnostic.line,
                        diagnostic.column,
                        diagnostic.length,
                    ),
                    fragment,
                )

    def test_top_level_and_declaration_completions(self) -> None:
        cases = {
            "empty": ("", {"@EnterCraftWorld\n", "@inline\n", 'invoke "modulo" as alias;'}),
            "pragma_prefix": ("@in", {"@inline\n"}),
            "craft_prefix": ("cra", {"craft:int main() {\n    return 0;\n}"}),
            "return_type": ("@EnterCraftWorld\ncraft:", {"int", "pointer", "chest"}),
            "function_name": ("@EnterCraftWorld\ncraft:int calculate", {"("}),
            "parameter_name": ("@EnterCraftWorld\ncraft:int calculate(value", {":"}),
            "parameter_type": ("@EnterCraftWorld\ncraft:int calculate(value:int", {",", ")"}),
            "import_module": ("@EnterCraftWorld\ninvoke ", {'"texto"'}),
            "import_as": ('@EnterCraftWorld\ninvoke "math" ', {"as "}),
            "import_alias": ('@EnterCraftWorld\ninvoke "math" as math', {";"}),
        }

        for name, (source, expected) in cases.items():
            with self.subTest(case=name):
                self.assertTrue(expected.issubset(self._insert_texts(source)))

    def test_statement_and_expression_completions(self) -> None:
        block = """@EnterCraftWorld
craft:int main() {
    value:int = 0;
    """
        cases = {
            "block": (
                block,
                {"if () {\n    \n}", "while () {\n    \n}", "return ;", "enderopen ", "}"},
                set(),
            ),
            "assignment_value": (
                block + "value = ",
                {"value", "0", "0x0", '"texto"', "summon:"},
                {"}"},
            ),
            "expression_continuation": (
                block + "value = value",
                {"+", "-", "*", "/", "==", ";", "["},
                {"("},
            ),
            "if_condition": (
                block + "if (value",
                {"==", "<", ")", "+"},
                {"}"},
            ),
            "if_body": (
                block + "if (value)",
                {"{"},
                {";"},
            ),
            "for_start": (
                block + "for (",
                {";"},
                {"}"},
            ),
            "for_condition": (
                block + "for (; value",
                {";", "<", "=="},
                {"}"},
            ),
        }

        for name, (source, included, excluded) in cases.items():
            with self.subTest(case=name):
                suggestions = set(self._insert_texts(source))
                self.assertTrue(included.issubset(suggestions))
                self.assertTrue(suggestions.isdisjoint(excluded))

    def test_type_call_portal_and_scope_completions(self) -> None:
        source = """@EnterCraftWorld
invoke "math" as math;
craft:int add(left:int, right:int) {
    return left + right;
}
craft:int main(param:int) {
    outer:int = 0;
    """
        cases = {
            "chest_element": (source + "values:chest[", {"int", "ender"}, {"]"}),
            "chest_size": (source + "values:chest[int,", {"0", "outer", "param"}, {"int"}),
            "pointer_element": (source + "typed:pointer[", {"int", "chest"}, {"]"}),
            "summon_target": (source + "summon:", {"add()", "math."}, {"outer"}),
            "portal_body": (
                source + "enderPortal(1):\n        ",
                {"enderchange()", "enderclose", "close", "endchange"},
                {"if () {\n    \n}"},
            ),
        }

        for name, (completion_source, included, excluded) in cases.items():
            with self.subTest(case=name):
                suggestions = set(self._insert_texts(completion_source))
                self.assertTrue(included.issubset(suggestions))
                self.assertTrue(suggestions.isdisjoint(excluded))

    def test_closed_inner_scope_is_not_suggested(self) -> None:
        source = """@EnterCraftWorld
craft:int main(param:int) {
    outer:int = 0;
    {
        inner:int = 1;
    }
    outer = """

        suggestions = set(self._insert_texts(source))

        self.assertIn("outer", suggestions)
        self.assertIn("param", suggestions)
        self.assertNotIn("inner", suggestions)

    def test_completion_is_stable_at_every_token_boundary(self) -> None:
        for program_name, source in VALID_PROGRAMS.items():
            tokens = Lexer(source, filename=f"<{program_name}>").tokenize()
            line_offsets = [0]
            for index, char in enumerate(source):
                if char == "\n":
                    line_offsets.append(index + 1)

            positions = {0, len(source)}
            for token in tokens:
                if token.type == TokenType.EOF:
                    continue
                start = line_offsets[token.line - 1] + token.column - 1
                positions.add(start)
                positions.add(start + len(token.lexeme))

            for position in sorted(positions):
                with self.subTest(program=program_name, position=position):
                    suggestions = self.service.complete(source, position)
                    keys = [
                        (suggestion.label, suggestion.insert_text)
                        for suggestion in suggestions
                    ]
                    self.assertEqual(len(keys), len(set(keys)))
                    self.assertTrue(
                        all(label and insert_text for label, insert_text in keys)
                    )

    def test_incomplete_editing_states_never_raise(self) -> None:
        fragments = [
            "@",
            "@EnterCraftWorld\ncraft",
            "@EnterCraftWorld\ncraft:",
            "@EnterCraftWorld\ncraft:int main(",
            "@EnterCraftWorld\ncraft:int main() {",
            "@EnterCraftWorld\ncraft:int main() {\nvalue:",
            "@EnterCraftWorld\ncraft:int main() {\nvalue:chest[",
            "@EnterCraftWorld\ncraft:int main() {\nif (",
            "@EnterCraftWorld\ncraft:int main() {\nfor (",
            "@EnterCraftWorld\ncraft:int main() {\nsummon:",
            "@EnterCraftWorld\ncraft:int main() {\nenderPortal(1):",
            '@EnterCraftWorld\ninvoke "module',
            "@EnterCraftWorld\n/*",
        ]

        for source in fragments:
            with self.subTest(source=source):
                diagnostics, suggestions = self.service.analyze(source)
                completions = self.service.complete(source, len(source))
                self.assertIsInstance(diagnostics, list)
                self.assertIsInstance(suggestions, list)
                self.assertIsInstance(completions, list)


if __name__ == "__main__":
    unittest.main()
