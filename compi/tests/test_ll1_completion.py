from __future__ import annotations

import sys
import unittest
from pathlib import Path


COMPI_ROOT = Path(__file__).resolve().parents[1]
IDE_ROOT = COMPI_ROOT / "IDE"
for path in (COMPI_ROOT, IDE_ROOT):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

from ll1_syntax import LL1SyntaxService


class LL1CompletionTests(unittest.TestCase):
    def setUp(self) -> None:
        self.service = LL1SyntaxService()

    def _insert_texts(self, source: str) -> list[str]:
        return [
            suggestion.insert_text
            for suggestion in self.service.complete(source, len(source))
        ]

    def test_declaration_colon_suggests_types_inside_open_block(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    x:int = 0;
    y:"""

        suggestions = self._insert_texts(source)

        self.assertIn("int", suggestions)
        self.assertIn("uint32", suggestions)
        self.assertIn("chest", suggestions)
        self.assertNotIn("}", suggestions)

    def test_parameter_colon_suggests_types_inside_open_parenthesis(self) -> None:
        source = "@EnterCraftWorld\ncraft:int suma(x:"

        suggestions = self._insert_texts(source)

        self.assertIn("int", suggestions)
        self.assertIn("pointer", suggestions)
        self.assertNotIn(")", suggestions)

    def test_chest_element_position_suggests_types_before_closing_bracket(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    valores:chest["""

        suggestions = self._insert_texts(source)

        self.assertIn("int", suggestions)
        self.assertIn("ender", suggestions)
        self.assertNotIn("]", suggestions)
        self.assertNotIn("valores", suggestions)

    def test_open_block_keeps_statement_and_closing_suggestions(self) -> None:
        source = "@EnterCraftWorld\ncraft:int main() {\n    "

        suggestions = self._insert_texts(source)

        self.assertIn("return ;", suggestions)
        self.assertIn("if () {\n    \n}", suggestions)
        self.assertIn("}", suggestions)

    def test_completed_expression_offers_valid_postfixes_and_semicolon(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    x:int = 0"""

        suggestions = self._insert_texts(source)

        self.assertIn("[", suggestions)
        self.assertIn(";", suggestions)
        self.assertNotIn("(", suggestions)
        self.assertNotIn("}", suggestions)

    def test_partial_keyword_is_filtered_from_ll1_statement_options(self) -> None:
        source = "@EnterCraftWorld\ncraft:int main() {\n    ret"

        self.assertEqual(self._insert_texts(source), ["return ;"])

    def test_completed_parameter_offers_comma_and_closing_parenthesis(self) -> None:
        source = "@EnterCraftWorld\ncraft:int suma(x:int"

        suggestions = self._insert_texts(source)

        self.assertIn(",", suggestions)
        self.assertIn(")", suggestions)

    def test_completed_declaration_type_advances_to_assignment(self) -> None:
        source = "@EnterCraftWorld\ncraft:int main() {\n    x:int"

        suggestions = self._insert_texts(source)

        self.assertIn("=", suggestions)
        self.assertIn(";", suggestions)

    def test_expression_context_adds_only_ll1_valid_semantic_symbols(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    x:int = 0;
    y:int = """

        suggestions = self._insert_texts(source)

        self.assertIn("x", suggestions)
        self.assertNotIn("int", suggestions)
        self.assertNotIn("}", suggestions)

    def test_call_argument_uses_current_ll1_stack_not_global_follow(self) -> None:
        source = "@EnterCraftWorld\ncraft:int main() {\n    summon:funcion(1"

        suggestions = self._insert_texts(source)

        self.assertIn(",", suggestions)
        self.assertIn(")", suggestions)
        self.assertNotIn(";", suggestions)

    def test_semantic_diagnostic_spans_complete_identifier(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    x:int = 0;
    awdaw:int = 0;
    while (x < 5) {
        x = x + 1;
        awdaw:int = hola;
    }

    return x;
}"""

        diagnostics, _suggestions = self.service.analyze(source)

        self.assertEqual(len(diagnostics), 1)
        self.assertEqual(diagnostics[0].line, 7)
        self.assertEqual(diagnostics[0].column, 21)
        self.assertEqual(diagnostics[0].length, len("hola"))
        self.assertIn("'hola'", diagnostics[0].message)

    def test_missing_semicolon_at_cursor_overrides_expression_operators(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    x:int = 0;
    while (x < 5) {
        x = x + 1 + 1234
    }
    return x;
}"""
        cursor_position = source.index("1234") + len("1234")

        self.assertEqual(
            [
                suggestion.insert_text
                for suggestion in self.service.complete(source, cursor_position)
            ],
            [";"],
        )

    def test_valid_same_line_expression_continuation_keeps_operators(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    x:int = 1 + 2;
    return x;
}"""
        cursor_position = source.index("1 + 2") + len("1")

        suggestions = {
            suggestion.insert_text
            for suggestion in self.service.complete(source, cursor_position)
        }

        self.assertIn("+", suggestions)
        self.assertNotEqual(suggestions, {";"})


if __name__ == "__main__":
    unittest.main()
