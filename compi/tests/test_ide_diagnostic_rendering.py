from __future__ import annotations

import os
import sys
import unittest
from pathlib import Path


COMPI_ROOT = Path(__file__).resolve().parents[1]
IDE_ROOT = COMPI_ROOT / "IDE"
for path in (COMPI_ROOT, IDE_ROOT):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

try:
    from PySide6.QtCore import Qt
    from PySide6.QtGui import QTextCursor
    from PySide6.QtTest import QTest
    from PySide6.QtWidgets import QApplication, QPlainTextEdit

    from ll1_syntax import LL1SyntaxService
    from main import LL1TableView, MainWindow

    HAS_QT = True
except ImportError:
    HAS_QT = False


@unittest.skipUnless(HAS_QT, "PySide6 is required for IDE rendering tests")
class IDEDiagnosticRenderingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.app = QApplication.instance() or QApplication([])
        cls.service = LL1SyntaxService()

    def setUp(self) -> None:
        self.editor = QPlainTextEdit()

    def tearDown(self) -> None:
        self.editor.deleteLater()

    def _selected_text(self, source: str, diagnostic_index: int = 0) -> str:
        diagnostics, _suggestions = self.service.analyze(source)
        self.assertGreater(len(diagnostics), diagnostic_index)
        self.editor.setPlainText(source)
        cursor = MainWindow._cursor_for_diagnostic(
            _CursorHarness(),
            self.editor,
            diagnostics[diagnostic_index],
        )
        return cursor.selectedText()

    def test_semantic_identifier_is_fully_selected(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    value:int = hola;
    return 0;
}"""

        self.assertEqual(self._selected_text(source), "hola")

    def test_undeclared_function_name_is_selected_instead_of_summon(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    return summon:missingFunction();
}"""

        self.assertEqual(self._selected_text(source), "missingFunction")

    def test_missing_semicolon_marks_previous_token(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    value:int = 0
    return value;
}"""

        self.assertEqual(self._selected_text(source), "0")

    def test_missing_brace_marks_unclosed_opening_brace(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    return 0;"""
        diagnostics, _suggestions = self.service.analyze(source)
        diagnostic_index = next(
            index
            for index, diagnostic in enumerate(diagnostics)
            if "}" in diagnostic.expected
        )

        self.assertEqual(self._selected_text(source, diagnostic_index), "{")

    def test_missing_parenthesis_marks_unclosed_opening_parenthesis(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    while (1
}"""
        diagnostics, _suggestions = self.service.analyze(source)
        diagnostic_index = next(
            index
            for index, diagnostic in enumerate(diagnostics)
            if ")" in diagnostic.expected
        )

        self.assertEqual(self._selected_text(source, diagnostic_index), "(")

    def test_unterminated_string_marks_the_complete_partial_literal(self) -> None:
        source = '@EnterCraftWorld\ninvoke "module'

        self.assertEqual(self._selected_text(source), '"module')


@unittest.skipUnless(HAS_QT, "PySide6 is required for LL(1) table tests")
class LL1TableViewTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.app = QApplication.instance() or QApplication([])
        cls.service = LL1SyntaxService()

    def setUp(self) -> None:
        self.view = LL1TableView(self.service)

    def tearDown(self) -> None:
        self.view.deleteLater()

    def test_table_contains_every_predictive_entry(self) -> None:
        self.assertEqual(
            self.view.table.rowCount(),
            len(self.service.nonterminals),
        )
        self.assertEqual(
            self.view.table.columnCount(),
            len({terminal for _nonterminal, terminal in self.service.table}),
        )
        self.assertIn(
            f"{len(self.service.nonterminals)} filas",
            self.view.visible_count_label.text(),
        )

    def test_table_displays_known_entry_and_production(self) -> None:
        row = self.view.nonterminals.index("Type")
        column = self.view.terminals.index("TYPE_INT")

        self.assertEqual(self.view.table.item(row, column).text(), "int")
        self.assertIn(
            "M[Type, TYPE_INT]",
            self.view.table.item(row, column).toolTip(),
        )

        self.view.table.setCurrentCell(row, column)
        self.assertEqual(
            self.view.selected_entry_label.text(),
            "M[Type, int] = Type -> int",
        )

    def test_epsilon_productions_are_readable(self) -> None:
        productions = {
            self.view.table.item(row, column).text()
            for row in range(self.view.table.rowCount())
            for column in range(self.view.table.columnCount())
        }

        self.assertIn("ε", productions)

    def test_search_filters_across_all_columns(self) -> None:
        self.view.search_input.setText("FunctionDecl")

        visible_rows = [
            row
            for row in range(self.view.table.rowCount())
            if not self.view.table.isRowHidden(row)
        ]

        self.assertTrue(visible_rows)
        self.assertIn(
            self.view.nonterminals.index("FunctionDecl"),
            visible_rows,
        )
        self.assertLess(
            sum(
                not self.view.table.isColumnHidden(column)
                for column in range(self.view.table.columnCount())
            ),
            self.view.table.columnCount(),
        )

    def test_main_window_reuses_a_single_ll1_tab(self) -> None:
        window = MainWindow()
        window.hide()
        try:
            window.show_ll1_table()
            table_view = window.ll1_table_view
            first_index = window.editor_tabs.indexOf(table_view)

            window.show_ll1_table()

            self.assertIs(window.ll1_table_view, table_view)
            self.assertEqual(window.editor_tabs.indexOf(table_view), first_index)
            self.assertIs(window.editor_tabs.currentWidget(), table_view)
        finally:
            window.close()
            window.deleteLater()


@unittest.skipUnless(HAS_QT, "PySide6 is required for editor interaction tests")
class IDEEnterCompletionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.app = QApplication.instance() or QApplication([])

    def setUp(self) -> None:
        self.window = MainWindow()
        self.window.hide()
        self.editor = self.window._build_editor()

    def tearDown(self) -> None:
        self.editor.deleteLater()
        self.window.close()
        self.window.deleteLater()

    def test_main_window_uses_ide_icon(self) -> None:
        self.assertFalse(self.window.windowIcon().isNull())

    def _press_enter_at_end(self, source: str) -> str:
        self.editor.setPlainText(source)
        cursor = self.editor.textCursor()
        cursor.movePosition(QTextCursor.End)
        self.editor.setTextCursor(cursor)

        QTest.keyClick(self.editor, Qt.Key_Return)

        return self.editor.toPlainText()

    def _press_enter_at_marker(self, marked_source: str) -> str:
        marker_position = marked_source.index("|")
        source = marked_source[:marker_position] + marked_source[marker_position + 1 :]
        self.editor.setPlainText(source)
        cursor = self.editor.textCursor()
        cursor.setPosition(marker_position)
        self.editor.setTextCursor(cursor)

        QTest.keyClick(self.editor, Qt.Key_Return)

        return self.editor.toPlainText()

    def test_enter_inserts_required_control_flow_blocks(self) -> None:
        cases = {
            "while": (
                """@EnterCraftWorld
craft:int main() {
    while (x < 5)""",
                """@EnterCraftWorld
craft:int main() {
    while (x < 5) {
        
    }""",
            ),
            "if": (
                """@EnterCraftWorld
craft:int main() {
    if (x < 5)""",
                """@EnterCraftWorld
craft:int main() {
    if (x < 5) {
        
    }""",
            ),
            "for": (
                """@EnterCraftWorld
craft:int main() {
    for (;;)""",
                """@EnterCraftWorld
craft:int main() {
    for (;;) {
        
    }""",
            ),
        }

        for name, (source, expected) in cases.items():
            with self.subTest(statement=name):
                self.assertEqual(self._press_enter_at_end(source), expected)

    def test_enter_inserts_required_function_block(self) -> None:
        source = "@EnterCraftWorld\ncraft:int calculate()   "

        result = self._press_enter_at_end(source)

        self.assertEqual(
            result,
            """@EnterCraftWorld
craft:int calculate() {
    
}""",
        )

    def test_enter_reuses_existing_closing_brace_below_while(self) -> None:
        marked_source = """@EnterCraftWorld
craft:int main() {
    x:int = 0;

    while (x < 5) |
        x = x + 1;
    }

    return x;
}"""

        result = self._press_enter_at_marker(marked_source)

        expected = """@EnterCraftWorld
craft:int main() {
    x:int = 0;

    while (x < 5) {
        x = x + 1;
    }

    return x;
}"""
        self.assertEqual(result, expected)
        self.assertEqual(self.editor.textCursor().block().text().strip(), "x = x + 1;")
        diagnostics, _suggestions = self.window.syntax_service.analyze(result)
        self.assertEqual(diagnostics, [])

    def test_enter_does_not_reuse_outer_function_closing_brace(self) -> None:
        marked_source = """@EnterCraftWorld
craft:int main() {
    while (x < 5) |
}"""

        result = self._press_enter_at_marker(marked_source)

        self.assertEqual(
            result,
            """@EnterCraftWorld
craft:int main() {
    while (x < 5) {
        
    }
}""",
        )

    def test_enter_after_call_inserts_semicolon_not_block(self) -> None:
        source = """@EnterCraftWorld
craft:int main() {
    summon:run()"""

        result = self._press_enter_at_end(source)

        self.assertEqual(result, source + ";")
        self.assertNotIn("summon:run() {", result)


class _CursorHarness:
    _cursor_for_related_syntax_error = MainWindow._cursor_for_related_syntax_error if HAS_QT else None
    _offset_for_diagnostic = MainWindow._offset_for_diagnostic if HAS_QT else None
    _cursor_for_offset = MainWindow._cursor_for_offset if HAS_QT else None
    _find_unclosed_opening = MainWindow._find_unclosed_opening if HAS_QT else None
    _find_block_opening_before_outdented_line = (
        MainWindow._find_block_opening_before_outdented_line if HAS_QT else None
    )
    _find_previous_statement_end = (
        MainWindow._find_previous_statement_end if HAS_QT else None
    )


if __name__ == "__main__":
    unittest.main()
