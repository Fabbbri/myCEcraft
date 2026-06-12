import sys
import re
from pathlib import Path

from PySide6.QtCore import QRegularExpression, QRect, Qt, QSize, Signal, QTimer
from PySide6.QtGui import (
    QColor,
    QFont,
    QIcon,
    QIntValidator,
    QPainter,
    QPen,
    QPixmap,
    QSyntaxHighlighter,
    QTextCharFormat,
    QTextCursor,
)
from PySide6.QtWidgets import (
    QApplication,
    QFileDialog,
    QFrame,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QMainWindow,
    QMenu,
    QPushButton,
    QSplitter,
    QTabBar,
    QTabWidget,
    QTextEdit,
    QToolButton,
    QPlainTextEdit,
    QVBoxLayout,
    QWidget,
)

from compiler_runner import CompilerRunner
from ll1_syntax import Diagnostic, LL1SyntaxService
from simulation_runner import SimulationRunner
from theme import APP_QSS
from workspace import Workspace


APP_TITLE = "Craft Studio"
IDE_DIR = Path(__file__).resolve().parent
REPO_ROOT = IDE_DIR.parent.parent
LOGO_PATH = IDE_DIR / "CS.png"
READY_OUTPUT_TEXT = "Listo para compilar."
NO_PROBLEMS_TEXT = "No hay errores ni advertencias."
PROBLEM_OUTPUT_MARKER = "Revise la pestana Problemas."
ERROR_DEMO_FILE = "ide_error_demo.craft"
ERROR_DEMO_CASES = [
    (
        "Numero invalido",
        """@EnterCraftWorld
craft:int main(){
    x:int = 0;

    while (x < 5awd){
        x = x + 1;
    }

    return x;
}
""",
    ),
    (
        "Falta punto y coma y llave",
        """@EnterCraftWorld
craft:int main(){
    x:int = 0;

    while (x < 5){
        x = x + 1;
    }

    return x
""",
    ),
    (
        "Tipo desconocido y llave faltante",
        """@EnterCraftWorld
craft:int main(){
    x:intadaw = 0;

    while (x < 5){
        x = x + 1;
    }

    return x;
""",
    ),
    (
        "Return incompleto",
        """@EnterCraftWorld
craft:int main(){
    return
}
""",
    ),
    (
        "Parentesis faltante",
        """@EnterCraftWorld
craft:int main(){
    x:int = 0;

    while (x < 5{
        x = x + 1;
    }

    return x;
}
""",
    ),
    (
        "Variable no declarada",
        """@EnterCraftWorld
craft:int main(){
    return y;
}
""",
    ),
    (
        "Aridad incorrecta",
        """@EnterCraftWorld
craft:int suma(a:int, b:int){
    return a + b;
}

craft:int main(){
    return summon:suma(1);
}
""",
    ),
    (
        "Programa valido",
        """@EnterCraftWorld
craft:int main(){
    x:int = 0;

    while (x < 5){
        x = x + 1;
    }

    return x;
}
""",
    ),
]


def make_close_icon(color: str) -> QIcon:
    pixmap = QPixmap(14, 14)
    pixmap.fill(Qt.transparent)

    painter = QPainter(pixmap)
    painter.setRenderHint(QPainter.Antialiasing)
    pen = QPen(QColor(color), 1.6)
    pen.setCapStyle(Qt.RoundCap)
    painter.setPen(pen)
    painter.drawLine(4, 4, 10, 10)
    painter.drawLine(10, 4, 4, 10)
    painter.end()

    return QIcon(pixmap)


def make_problem_badge_icon(count: int) -> QIcon:
    pixmap = QPixmap(20, 20)
    pixmap.fill(Qt.transparent)

    painter = QPainter(pixmap)
    painter.setRenderHint(QPainter.Antialiasing)
    painter.setBrush(QColor("#F14C4C"))
    painter.setPen(Qt.NoPen)
    painter.drawEllipse(1, 1, 18, 18)

    painter.setPen(QColor("#FFFFFF"))
    font = QFont("Inter", 8)
    font.setBold(True)
    painter.setFont(font)
    painter.drawText(pixmap.rect(), Qt.AlignCenter, "9+" if count > 9 else str(count))
    painter.end()

    return QIcon(pixmap)


class LineNumberArea(QWidget):
    def __init__(self, editor: "CodeEditor") -> None:
        super().__init__(editor)
        self.editor = editor

    def sizeHint(self) -> QSize:
        return QSize(self.editor.line_number_area_width(), 0)

    def paintEvent(self, event) -> None:
        self.editor.line_number_area_paint_event(event)


class CraftHighlighter(QSyntaxHighlighter):
    COMMENT_BLOCK_STATE = 1

    def __init__(self, document) -> None:
        super().__init__(document)
        self.rules = self._build_rules()
        self.block_comment_format = self._format("#6A9955", italic=True)

    def _format(
        self,
        color: str,
        bold: bool = False,
        italic: bool = False,
    ) -> QTextCharFormat:
        text_format = QTextCharFormat()
        text_format.setForeground(QColor(color))
        if bold:
            text_format.setFontWeight(QFont.Bold)
        if italic:
            text_format.setFontItalic(True)
        return text_format

    def _build_rules(self) -> list[tuple[QRegularExpression, QTextCharFormat]]:
        keyword_format = self._format("#C586C0")
        type_format = self._format("#4EC9B0")
        pragma_format = self._format("#D7BA7D", bold=True)
        string_format = self._format("#CE9178")
        number_format = self._format("#B5CEA8")
        comment_format = self._format("#6A9955", italic=True)
        function_format = self._format("#DCDCAA")
        alias_format = self._format("#9CDCFE")
        operator_format = self._format("#D4D4D4")

        keywords = [
            "as",
            "craft",
            "else",
            "for",
            "if",
            "invoke",
            "return",
            "summon",
            "while",
        ]
        types = [
            "char",
            "chest",
            "ender",
            "int",
            "pointer",
            "uint16",
            "uint32",
            "void",
        ]

        return [
            (QRegularExpression(r"\b(" + "|".join(keywords) + r")\b"), keyword_format),
            (QRegularExpression(r"\b(" + "|".join(types) + r")\b"), type_format),
            (QRegularExpression(r"@[A-Za-z_][A-Za-z0-9_]*\b"), pragma_format),
            (QRegularExpression(r'"([^"\\]|\\.)*"'), string_format),
            (QRegularExpression(r"\b0[xX][0-9A-Fa-f]+\b|\b\d+\b"), number_format),
            (
                QRegularExpression(
                    r"\b(?!if\b|while\b|for\b|return\b|summon\b|craft\b)"
                    r"[A-Za-z_][A-Za-z0-9_]*(?=\s*\()"
                ),
                function_format,
            ),
            (QRegularExpression(r"(?<=summon:)[A-Za-z_][A-Za-z0-9_]*(?=\.)"), alias_format),
            (QRegularExpression(r"<\+4|>\+5|==|!=|<=|>=|<<|>>"), operator_format),
            (QRegularExpression(r"//[^\n]*"), comment_format),
        ]

    def highlightBlock(self, text: str) -> None:
        for pattern, text_format in self.rules:
            match_iterator = pattern.globalMatch(text)
            while match_iterator.hasNext():
                match = match_iterator.next()
                self.setFormat(match.capturedStart(), match.capturedLength(), text_format)

        self.setCurrentBlockState(0)
        self._highlight_block_comments(text)

    def _highlight_block_comments(self, text: str) -> None:
        start = 0
        if self.previousBlockState() != self.COMMENT_BLOCK_STATE:
            start = text.find("/*")

        while start >= 0:
            end = text.find("*/", start + 2)
            if end == -1:
                self.setCurrentBlockState(self.COMMENT_BLOCK_STATE)
                length = len(text) - start
            else:
                length = end - start + 2

            self.setFormat(start, length, self.block_comment_format)

            if end == -1:
                break
            start = text.find("/*", start + length)


class CodeEditor(QPlainTextEdit):
    completion_requested = Signal()
    INDENT = "    "

    def __init__(self) -> None:
        super().__init__()
        self.auto_fix_on_enter = None
        self.line_number_area = LineNumberArea(self)
        self.highlighter = CraftHighlighter(self.document())

        self.blockCountChanged.connect(self.update_line_number_area_width)
        self.updateRequest.connect(self.update_line_number_area)

        self.setObjectName("CodeEditor")
        self.setLineWrapMode(QPlainTextEdit.NoWrap)
        self.setFont(QFont("Cascadia Mono", 11))
        self.document().setDocumentMargin(14)
        self.setTabStopDistance(self.fontMetrics().horizontalAdvance(" ") * len(self.INDENT))
        self.update_line_number_area_width()

    def keyPressEvent(self, event) -> None:
        if event.key() == Qt.Key_Space and event.modifiers() & Qt.ControlModifier:
            self.completion_requested.emit()
            event.accept()
            return
        if event.key() == Qt.Key_Tab:
            self._indent_selection()
            event.accept()
            return
        if event.key() == Qt.Key_Backtab:
            self._unindent_selection()
            event.accept()
            return
        if event.key() in {Qt.Key_Return, Qt.Key_Enter}:
            if self.auto_fix_on_enter is not None and self.auto_fix_on_enter(self):
                event.accept()
                return
        super().keyPressEvent(event)

    def _selected_block_range(self) -> tuple[int, int]:
        cursor = self.textCursor()
        start = cursor.selectionStart()
        end = cursor.selectionEnd()
        document = self.document()
        start_block = document.findBlock(start).blockNumber()
        end_block = document.findBlock(end).blockNumber()

        end_at_block_start = end == document.findBlock(end).position()
        if cursor.hasSelection() and end_at_block_start and end_block > start_block:
            end_block -= 1

        return start_block, end_block

    def _indent_selection(self) -> None:
        cursor = self.textCursor()
        if not cursor.hasSelection():
            cursor.insertText(self.INDENT)
            return

        start_block, end_block = self._selected_block_range()
        cursor.beginEditBlock()
        for block_number in range(start_block, end_block + 1):
            block = self.document().findBlockByNumber(block_number)
            line_cursor = QTextCursor(block)
            line_cursor.insertText(self.INDENT)
        cursor.endEditBlock()

    def _unindent_selection(self) -> None:
        cursor = self.textCursor()
        start_block, end_block = self._selected_block_range()

        cursor.beginEditBlock()
        for block_number in range(start_block, end_block + 1):
            block = self.document().findBlockByNumber(block_number)
            text = block.text()
            remove_count = 0
            if text.startswith("\t"):
                remove_count = 1
            else:
                remove_count = len(text) - len(text.lstrip(" "))
                remove_count = min(remove_count, len(self.INDENT))

            if remove_count == 0:
                continue

            line_cursor = QTextCursor(block)
            line_cursor.setPosition(block.position() + remove_count, QTextCursor.KeepAnchor)
            line_cursor.removeSelectedText()
        cursor.endEditBlock()

    def line_number_area_width(self) -> int:
        digits = len(str(max(1, self.blockCount())))
        return max(48, 18 + self.fontMetrics().horizontalAdvance("9") * digits)

    def update_line_number_area_width(self) -> None:
        self.setViewportMargins(self.line_number_area_width(), 0, 0, 0)

    def update_line_number_area(self, rect: QRect, dy: int) -> None:
        if dy:
            self.line_number_area.scroll(0, dy)
        else:
            self.line_number_area.update(
                0,
                rect.y(),
                self.line_number_area.width(),
                rect.height(),
            )

        if rect.contains(self.viewport().rect()):
            self.update_line_number_area_width()

    def resizeEvent(self, event) -> None:
        super().resizeEvent(event)
        contents = self.contentsRect()
        self.line_number_area.setGeometry(
            QRect(
                contents.left(),
                contents.top(),
                self.line_number_area_width(),
                contents.height(),
            )
        )

    def line_number_area_paint_event(self, event) -> None:
        painter = QPainter(self.line_number_area)
        painter.fillRect(event.rect(), QColor("#1E1E1E"))
        painter.setPen(QColor("#3C3C3C"))
        painter.drawLine(
            self.line_number_area.width() - 1,
            event.rect().top(),
            self.line_number_area.width() - 1,
            event.rect().bottom(),
        )
        painter.setPen(QColor("#858585"))
        painter.setFont(self.font())

        block = self.firstVisibleBlock()
        block_number = block.blockNumber()
        top = int(self.blockBoundingGeometry(block).translated(self.contentOffset()).top())
        bottom = top + int(self.blockBoundingRect(block).height())
        line_height = self.fontMetrics().height()

        while block.isValid() and top <= event.rect().bottom():
            if block.isVisible() and bottom >= event.rect().top():
                painter.drawText(
                    0,
                    top,
                    self.line_number_area.width() - 12,
                    line_height,
                    Qt.AlignRight,
                    str(block_number + 1),
                )

            block = block.next()
            top = bottom
            if block.isValid():
                bottom = top + int(self.blockBoundingRect(block).height())
            block_number += 1


class NewFileNameEdit(QLineEdit):
    cancel_requested = Signal()

    def keyPressEvent(self, event) -> None:
        if event.key() == Qt.Key_Escape:
            self.cancel_requested.emit()
            return
        super().keyPressEvent(event)


class MainWindow(QMainWindow):
    def __init__(self) -> None:
        super().__init__()
        self.workspace = Workspace(REPO_ROOT)
        self.compiler = CompilerRunner(REPO_ROOT)
        self.simulator = SimulationRunner(REPO_ROOT)
        self.syntax_service = LL1SyntaxService()
        self.open_editors: dict[Path, CodeEditor] = {}
        self.editor_paths: dict[CodeEditor, Path] = {}
        self.editor_diagnostics: dict[CodeEditor, list[Diagnostic]] = {}
        self.error_demo_timer = QTimer(self)
        self.error_demo_timer.setInterval(2600)
        self.error_demo_timer.timeout.connect(self._advance_error_demo)
        self.error_demo_index = 0
        self.error_demo_path: Path | None = None
        self._loading_editor = False
        self.current_optimization_label = "Sin optimizaciones"
        self.current_unroll_label = "Automatico"
        self.current_compile_options = {
            "loop_unrolling": False,
            "rename_registers": False,
            "eliminate_dead_code": False,
            "reorder_instructions": False,
        }
        self.current_artifact_tag: str | None = None
        self.pending_run = False
        self.active_compile_path: Path | None = None

        self.setWindowTitle(APP_TITLE)
        self.setMinimumSize(QSize(1100, 720))
        self._build_ui()
        self._connect_compiler()
        self._connect_simulator()
        self._populate_file_list()
        self._open_initial_file()
        self.showMaximized()

    def _build_ui(self) -> None:
        root = QWidget()
        root.setObjectName("AppRoot")
        root_layout = QVBoxLayout(root)
        root_layout.setContentsMargins(12, 12, 12, 10)
        root_layout.setSpacing(10)

        root_layout.addWidget(self._build_top_bar())
        root_layout.addWidget(self._build_body())
        root_layout.addWidget(self._build_status_bar())

        self.setCentralWidget(root)
        self._build_completion_popup()

    def _build_completion_popup(self) -> None:
        self.completion_popup = QListWidget(self)
        self.completion_popup.setObjectName("CompletionPopup")
        self.completion_popup.setWindowFlags(Qt.Popup | Qt.FramelessWindowHint)
        self.completion_popup.setFocusPolicy(Qt.StrongFocus)
        self.completion_popup.itemClicked.connect(self._insert_completion_from_item)
        self.completion_popup.itemActivated.connect(self._insert_completion_from_item)
        self.completion_popup.hide()

    def _build_top_bar(self) -> QWidget:
        bar = QFrame()
        bar.setObjectName("TopBar")
        layout = QHBoxLayout(bar)
        layout.setContentsMargins(12, 7, 10, 7)
        layout.setSpacing(10)

        mark = QLabel()
        mark.setObjectName("BrandMark")
        mark.setAlignment(Qt.AlignCenter)
        logo = QPixmap(str(LOGO_PATH))
        if not logo.isNull():
            mark.setPixmap(
                logo.scaled(
                    QSize(28, 28),
                    Qt.KeepAspectRatio,
                    Qt.SmoothTransformation,
                )
            )
        else:
            mark.setText("CS")
        layout.addWidget(mark)

        title_group = QWidget()
        title_layout = QVBoxLayout(title_group)
        title_layout.setContentsMargins(0, 0, 0, 0)
        title_layout.setSpacing(0)

        title = QLabel(APP_TITLE)
        title.setObjectName("AppTitle")
        title_layout.addWidget(title)
        layout.addWidget(title_group)

        layout.addStretch(1)

        actions = [
            ("Abrir carpeta", self.open_folder_dialog),
            ("Abrir archivo", self.open_file_dialog),
            ("Guardar", self.save_current_file),
            ("Demo errores", self.toggle_error_demo),
            ("Artefactos", self.show_artifacts_tab),
        ]

        for label, handler in actions:
            button = QToolButton()
            button.setObjectName("TopIconButton")
            button.setText(label)
            button.setToolTip(label)
            button.setCursor(Qt.PointingHandCursor)
            button.clicked.connect(handler)
            layout.addWidget(button)
            if label == "Demo errores":
                self.error_demo_button = button

        unroll_label = QLabel("Loop unrolling")
        unroll_label.setObjectName("TopControlLabel")
        layout.addWidget(unroll_label)
        self.unroll_factor_input = QLineEdit()
        self.unroll_factor_input.setObjectName("TopNumberInput")
        self.unroll_factor_input.setPlaceholderText("Auto")
        self.unroll_factor_input.setValidator(QIntValidator(1, 64, self))
        self.unroll_factor_input.setToolTip(
            "Factor entre 1 y 64. Vacio usa seleccion automatica."
        )
        self.unroll_factor_input.setMaximumWidth(72)
        layout.addWidget(self.unroll_factor_input)

        self.compile_button = QPushButton("Compilar")
        self.compile_button.setObjectName("PrimaryButton")
        self.compile_button.setCursor(Qt.PointingHandCursor)
        compile_menu = QMenu(self.compile_button)
        for label, tag, options in (
            ("Sin optimizaciones", None, {}),
            (
                "O1",
                "O1",
                {
                    "loop_unrolling": True,
                    "rename_registers": True,
                },
            ),
            (
                "O2",
                "O2",
                {
                    "eliminate_dead_code": True,
                    "reorder_instructions": True,
                },
            ),
            (
                "O3",
                "O3",
                {
                    "loop_unrolling": True,
                    "rename_registers": True,
                    "eliminate_dead_code": True,
                    "reorder_instructions": True,
                },
            ),
        ):
            action = compile_menu.addAction(label)
            action.triggered.connect(
                lambda _checked=False, name=label, artifact=tag, selected=options:
                    self.compile_with_options(name, artifact, selected)
            )
        compile_menu.addSeparator()
        for label, tag, options in (
            ("Solo Loop unrolling", "unroll", {"loop_unrolling": True}),
            ("Solo Renombramiento", "rename", {"rename_registers": True}),
            ("Solo DCE", "dce", {"eliminate_dead_code": True}),
            ("Solo Reordenamiento", "reorder", {"reorder_instructions": True}),
        ):
            action = compile_menu.addAction(label)
            action.triggered.connect(
                lambda _checked=False, name=label, artifact=tag, selected=options:
                    self.compile_with_options(name, artifact, selected)
            )
        self.compile_button.setMenu(compile_menu)
        layout.addWidget(self.compile_button)

        self.run_button = QPushButton("Ejecutar O0")
        self.run_button.setObjectName("PrimaryButton")
        self.run_button.setToolTip(
            "Compila el archivo activo y lo ejecuta en tb_general_dump"
        )
        self.run_button.setCursor(Qt.PointingHandCursor)
        self.run_button.clicked.connect(self.run_current_file)
        layout.addWidget(self.run_button)

        bar.setFixedHeight(52)
        return bar

    def _build_body(self) -> QWidget:
        splitter = QSplitter(Qt.Horizontal)
        splitter.setObjectName("MainSplitter")
        splitter.setChildrenCollapsible(False)

        splitter.addWidget(self._build_sidebar())
        splitter.addWidget(self._build_editor_stack())
        splitter.setStretchFactor(0, 0)
        splitter.setStretchFactor(1, 1)
        splitter.setSizes([245, 895])

        container = QWidget()
        layout = QVBoxLayout(container)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(splitter)
        return container

    def _build_sidebar(self) -> QWidget:
        panel = QFrame()
        panel.setObjectName("Sidebar")
        panel.setFixedWidth(245)
        layout = QVBoxLayout(panel)
        layout.setContentsMargins(12, 12, 12, 12)
        layout.setSpacing(10)

        header = QWidget()
        header_layout = QHBoxLayout(header)
        header_layout.setContentsMargins(0, 0, 0, 0)
        header_layout.setSpacing(8)

        title = QLabel("EXPLORADOR")
        title.setObjectName("SectionTitle")
        header_layout.addWidget(title)
        header_layout.addStretch(1)

        new_file = QToolButton()
        new_file.setObjectName("TinyIconButton")
        new_file.setText("+")
        new_file.setToolTip("Nuevo archivo")
        new_file.setCursor(Qt.PointingHandCursor)
        new_file.clicked.connect(self.create_new_file)
        header_layout.addWidget(new_file)
        layout.addWidget(header)

        workspace_row = QFrame()
        workspace_row.setObjectName("WorkspaceRow")
        workspace_layout = QHBoxLayout(workspace_row)
        workspace_layout.setContentsMargins(0, 0, 0, 0)
        workspace_layout.setSpacing(8)

        workspace_icon = QLabel("▾")
        workspace_icon.setObjectName("WorkspaceIcon")
        workspace_layout.addWidget(workspace_icon)

        self.workspace_label = QLabel(self.workspace.relative_label(self.workspace.source_root))
        self.workspace_label.setObjectName("WorkspaceLabel")
        workspace_layout.addWidget(self.workspace_label)
        workspace_layout.addStretch(1)
        layout.addWidget(workspace_row)

        self.new_file_input = NewFileNameEdit()
        self.new_file_input.setObjectName("InlineFileInput")
        self.new_file_input.setPlaceholderText("nuevo.craft")
        self.new_file_input.hide()
        self.new_file_input.returnPressed.connect(self._confirm_new_file)
        self.new_file_input.cancel_requested.connect(self._cancel_new_file)
        layout.addWidget(self.new_file_input)

        self.file_list = QListWidget()
        self.file_list.setObjectName("FileList")
        self.file_list.setFrameShape(QFrame.NoFrame)
        self.file_list.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.file_list.itemActivated.connect(self._open_file_from_item)
        self.file_list.itemClicked.connect(self._open_file_from_item)
        layout.addWidget(self.file_list, 1)

        self.sidebar_status = QLabel("Workspace listo")
        self.sidebar_status.setObjectName("SidebarHint")
        layout.addWidget(self.sidebar_status)

        return panel

    def _build_editor_stack(self) -> QWidget:
        container = QFrame()
        container.setObjectName("EditorContainer")
        layout = QVBoxLayout(container)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        self.editor_tabs = QTabWidget()
        self.editor_tabs.setObjectName("EditorTabs")
        self.editor_tabs.currentChanged.connect(self._handle_current_tab_changed)

        self.output_tabs = QTabWidget()
        self.output_tabs.setObjectName("OutputTabs")
        self.output_tabs.tabBar().setIconSize(QSize(20, 20))
        self.output_panel = self._build_output_panel(READY_OUTPUT_TEXT)
        self.problems_panel = self._build_output_panel(NO_PROBLEMS_TEXT)
        self.artifacts_panel = self._build_output_panel("Sin artefactos generados aun.")
        self.output_tabs.addTab(self.output_panel, "Salida")
        self.output_tabs.addTab(self.problems_panel, "Problemas")
        self.output_tabs.addTab(self.artifacts_panel, "Artefactos")
        self._update_problem_tab_badge(0)

        splitter = QSplitter(Qt.Vertical)
        splitter.setObjectName("EditorSplitter")
        splitter.setChildrenCollapsible(False)
        splitter.addWidget(self.editor_tabs)
        splitter.addWidget(self.output_tabs)
        splitter.setStretchFactor(0, 3)
        splitter.setStretchFactor(1, 1)
        splitter.setSizes([520, 190])

        layout.addWidget(splitter)
        return container

    def _build_editor(self) -> CodeEditor:
        editor = CodeEditor()
        editor.auto_fix_on_enter = self._auto_fix_on_enter
        editor.textChanged.connect(lambda current=editor: self._handle_editor_text_changed(current))
        editor.completion_requested.connect(
            lambda current=editor: self.show_completion_popup(current)
        )
        return editor

    def _build_output_panel(self, placeholder: str) -> QTextEdit:
        output = QTextEdit()
        output.setObjectName("OutputPanel")
        output.setReadOnly(True)
        output.setPlainText(placeholder)
        output.setFont(QFont("Cascadia Mono", 10))
        return output

    def _connect_compiler(self) -> None:
        self.compiler.started.connect(self._handle_compile_started)
        self.compiler.output_ready.connect(self._append_compiler_output)
        self.compiler.error_ready.connect(self._append_compiler_error)
        self.compiler.finished.connect(self._handle_compile_finished)

    def _connect_simulator(self) -> None:
        self.simulator.started.connect(self._handle_simulation_started)
        self.simulator.output_ready.connect(self._append_simulation_output)
        self.simulator.finished.connect(self._handle_simulation_finished)

    def _populate_file_list(self) -> None:
        self.file_list.clear()
        self.workspace_label.setText(self.workspace.relative_label(self.workspace.source_root))
        for path in self.workspace.list_craft_files():
            item = QListWidgetItem(self.workspace.display_name(path), self.file_list)
            item.setData(Qt.UserRole, str(path))

        if self.file_list.count() == 0:
            self.sidebar_status.setText("No hay archivos .craft")
        else:
            self.sidebar_status.setText(f"{self.file_list.count()} archivos .craft")

    def _open_initial_file(self) -> None:
        preferred = self.workspace.source_root / "demo.craft"
        if preferred.is_file():
            self.open_file(preferred)
            self._select_file_in_sidebar(preferred)
            return

        if self.file_list.count() > 0:
            self.file_list.setCurrentRow(0)
            self._open_file_from_item(self.file_list.item(0))

    def open_folder_dialog(self) -> None:
        folder_text = QFileDialog.getExistingDirectory(
            self,
            "Abrir carpeta",
            str(self.workspace.source_root),
        )
        if folder_text:
            self.open_folder(Path(folder_text))

    def open_folder(self, folder: Path) -> None:
        self.workspace.open_folder(folder)
        self._populate_file_list()
        self._set_state(f"Carpeta abierta: {self.workspace.relative_label(folder)}")

        if self.file_list.count() > 0:
            self.file_list.setCurrentRow(0)
            self._open_file_from_item(self.file_list.item(0))
        else:
            self.sidebar_status.setText("No hay archivos .craft")

    def create_new_file(self) -> None:
        self.new_file_input.setText("nuevo.craft")
        self.new_file_input.show()
        self.new_file_input.setFocus()
        self.new_file_input.selectAll()

    def _confirm_new_file(self) -> None:
        name = self.new_file_input.text()
        try:
            path = self.workspace.create_file(name)
        except (FileExistsError, OSError, ValueError) as error:
            self._set_problem_text(str(error))
            self._set_state("No se pudo crear el archivo")
            return

        self._cancel_new_file()
        self._populate_file_list()
        self.open_file(path)
        self._select_file_in_sidebar(path)
        self._set_state(f"Creado {path.name}")

    def _cancel_new_file(self) -> None:
        self.new_file_input.clear()
        self.new_file_input.hide()

    def _open_file_from_item(self, item: QListWidgetItem) -> None:
        path_text = item.data(Qt.UserRole)
        if path_text:
            self.open_file(Path(path_text))

    def open_file_dialog(self) -> None:
        path_text, _ = QFileDialog.getOpenFileName(
            self,
            "Abrir archivo Craft",
            str(self.workspace.source_root),
            "Craft files (*.craft);;Todos los archivos (*)",
        )
        if path_text:
            self.open_file(Path(path_text))

    def open_file(self, path: Path) -> None:
        path = path.resolve()
        if path in self.open_editors:
            self.editor_tabs.setCurrentWidget(self.open_editors[path])
            self._select_file_in_sidebar(path)
            return

        try:
            content = self.workspace.read_text(path)
        except OSError as error:
            self._set_problem_text(f"No se pudo abrir {path}:\n{error}")
            self._set_state("Error al abrir archivo")
            return

        editor = self._build_editor()
        self._loading_editor = True
        editor.setPlainText(content)
        editor.document().setModified(False)
        self._loading_editor = False
        editor.cursorPositionChanged.connect(self._update_cursor_position)

        self.open_editors[path] = editor
        self.editor_paths[editor] = path
        index = self.editor_tabs.addTab(editor, path.name)
        self.editor_tabs.tabBar().setTabButton(
            index,
            QTabBar.RightSide,
            self._build_tab_close_button(editor),
        )
        self.editor_tabs.setCurrentIndex(index)
        self._select_file_in_sidebar(path)
        self._set_state(f"Abierto {path.name}")
        self._validate_editor(editor)

    def save_current_file(self) -> bool:
        editor = self.current_editor()
        if editor is None:
            self._set_state("No hay archivo activo")
            return False

        path = self.editor_paths[editor]
        try:
            self.workspace.write_text(path, editor.toPlainText())
        except OSError as error:
            self._set_problem_text(f"No se pudo guardar {path}:\n{error}")
            self._set_state("Error al guardar")
            return False

        editor.document().setModified(False)
        self._update_tab_title(editor)
        self._set_state(f"Guardado {path.name}")
        return True

    def compile_with_options(
        self,
        optimization_label: str,
        artifact_tag: str | None,
        options: dict[str, bool],
    ) -> None:
        self.current_compile_options = {
            "loop_unrolling": False,
            "rename_registers": False,
            "eliminate_dead_code": False,
            "reorder_instructions": False,
        }
        self.current_compile_options.update(options)
        self.current_artifact_tag = artifact_tag
        self.current_optimization_label = optimization_label
        run_label = "O0" if optimization_label == "Sin optimizaciones" else optimization_label
        self.run_button.setText(f"Ejecutar {run_label}")
        self.compile_current_file()

    def compile_current_file(
        self,
    ) -> bool:
        editor = self.current_editor()
        if editor is None:
            self._set_state("No hay archivo activo")
            return False

        if self.compiler.is_running() or self.simulator.is_running():
            self._set_state("Compilacion o simulacion en curso")
            return False

        if editor.document().isModified() and not self.save_current_file():
            return False

        path = self.editor_paths[editor]
        self.output_panel.clear()
        self.problems_panel.setPlainText(NO_PROBLEMS_TEXT)
        self._set_problem_count(0)
        self.artifacts_panel.setPlainText("Compilando...")
        self.output_tabs.setCurrentWidget(self.output_panel)
        options = self.current_compile_options
        unroll_text = self.unroll_factor_input.text().strip()
        unroll_factor = int(unroll_text) if unroll_text else None
        if unroll_factor is not None and not 1 <= unroll_factor <= 64:
            self._set_state("El factor de loop unrolling debe estar entre 1 y 64")
            self.unroll_factor_input.setFocus()
            self.unroll_factor_input.selectAll()
            return False
        if options["loop_unrolling"]:
            self.current_unroll_label = (
                "Automatico" if unroll_factor is None else str(unroll_factor)
            )
        else:
            self.current_unroll_label = "Desactivado"
        self.active_compile_path = path
        self.compiler.compile(
            path,
            loop_unrolling=options["loop_unrolling"],
            unroll_factor=unroll_factor,
            rename_registers=options["rename_registers"],
            eliminate_dead_code=options["eliminate_dead_code"],
            reorder_instructions=options["reorder_instructions"],
            artifact_tag=self.current_artifact_tag,
        )
        return True

    def run_current_file(self) -> None:
        self.pending_run = True
        started = self.compile_current_file()
        if not started:
            self.pending_run = False

    def close_editor(self, editor: CodeEditor) -> None:
        index = self.editor_tabs.indexOf(editor)
        if index == -1:
            return
        self.close_editor_at_index(index)

    def close_editor_at_index(self, index: int) -> None:
        widget = self.editor_tabs.widget(index)
        if not isinstance(widget, CodeEditor):
            return

        path = self.editor_paths.pop(widget, None)
        if path is not None:
            self.open_editors.pop(path, None)
        self.editor_diagnostics.pop(widget, None)

        self.editor_tabs.removeTab(index)
        widget.deleteLater()
        self._handle_current_tab_changed(self.editor_tabs.currentIndex())

    def _build_tab_close_button(self, editor: CodeEditor) -> QWidget:
        container = QWidget()
        container.setObjectName("TabCloseContainer")
        container.setFixedSize(28, 22)
        layout = QHBoxLayout(container)
        layout.setContentsMargins(0, 2, 10, 2)
        layout.setSpacing(0)

        button = QToolButton()
        button.setObjectName("TabCloseButton")
        button.setIcon(make_close_icon("#AFAFAF"))
        button.setIconSize(QSize(12, 12))
        button.setFixedSize(16, 16)
        button.setToolTip("")
        button.setCursor(Qt.PointingHandCursor)
        button.clicked.connect(lambda _checked=False, current=editor: self.close_editor(current))
        layout.addWidget(button, 0, Qt.AlignLeft | Qt.AlignVCenter)
        return container

    def current_editor(self) -> CodeEditor | None:
        widget = self.editor_tabs.currentWidget()
        if isinstance(widget, CodeEditor):
            return widget
        return None

    def show_artifacts_tab(self) -> None:
        self.output_tabs.setCurrentWidget(self.artifacts_panel)

    def toggle_error_demo(self) -> None:
        if self.error_demo_timer.isActive():
            self.error_demo_timer.stop()
            self.error_demo_button.setText("Demo errores")
            self.error_demo_button.setToolTip("Demo errores")
            self._set_state("Demo de errores detenido")
            return

        try:
            self._open_error_demo_file()
        except OSError as error:
            self._set_problem_text(f"No se pudo preparar la demo de errores:\n{error}")
            return

        self.error_demo_index = 0
        self.error_demo_button.setText("Detener demo")
        self.error_demo_button.setToolTip("Detener demo de errores")
        self._apply_error_demo_case()
        self.error_demo_timer.start()

    def _open_error_demo_file(self) -> None:
        path = (self.workspace.source_root / ERROR_DEMO_FILE).resolve()
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.exists():
            path.write_text(ERROR_DEMO_CASES[0][1], encoding="utf-8")

        self.error_demo_path = path
        self._populate_file_list()
        self.open_file(path)
        self._select_file_in_sidebar(path)

    def _advance_error_demo(self) -> None:
        self.error_demo_index = (self.error_demo_index + 1) % len(ERROR_DEMO_CASES)
        self._apply_error_demo_case()

    def _apply_error_demo_case(self) -> None:
        if self.error_demo_path is None:
            return

        editor = self.open_editors.get(self.error_demo_path)
        if editor is None:
            self.open_file(self.error_demo_path)
            editor = self.open_editors.get(self.error_demo_path)
            if editor is None:
                return

        title, source = ERROR_DEMO_CASES[self.error_demo_index]
        self._loading_editor = True
        editor.setPlainText(source)
        editor.document().setModified(False)
        self._loading_editor = False
        self._validate_editor(editor)
        self._update_tab_title(editor)
        self.editor_tabs.setCurrentWidget(editor)
        self.output_tabs.setCurrentWidget(self.problems_panel)
        self._set_state(f"Demo errores: {title}")

    def show_completion_popup(self, editor: CodeEditor) -> None:
        cursor = editor.textCursor()
        suggestions = self.syntax_service.complete(editor.toPlainText(), cursor.position())

        if not suggestions:
            self._set_state("Sin sugerencias disponibles")
            return

        self.completion_popup.clear()
        for suggestion in suggestions:
            item = QListWidgetItem(suggestion.label, self.completion_popup)
            item.setData(Qt.UserRole, suggestion.insert_text)
            if suggestion.detail:
                item.setToolTip(suggestion.detail)

        self.completion_popup.setCurrentRow(0)
        self.completion_popup.setFixedWidth(320)
        visible_rows = min(8, self.completion_popup.count())
        row_height = max(24, self.completion_popup.sizeHintForRow(0))
        self.completion_popup.setFixedHeight((visible_rows * row_height) + 8)

        cursor_rect = editor.cursorRect()
        global_pos = editor.mapToGlobal(cursor_rect.bottomLeft())
        self.completion_popup.move(global_pos)
        self.completion_popup.show()
        self.completion_popup.raise_()
        self.completion_popup.setFocus()

    def _insert_completion_from_item(self, item: QListWidgetItem) -> None:
        editor = self.current_editor()
        if editor is None:
            return

        insert_text = item.data(Qt.UserRole)
        if not insert_text:
            return

        cursor = editor.textCursor()
        prefix_start = self._completion_prefix_start(editor.toPlainText(), cursor.position())
        if prefix_start < cursor.position():
            prefix = editor.toPlainText()[prefix_start : cursor.position()]
            if insert_text.lower().startswith(prefix.lower()):
                cursor.setPosition(prefix_start, QTextCursor.KeepAnchor)
        cursor.insertText(insert_text)
        editor.setTextCursor(cursor)
        self.completion_popup.hide()
        editor.setFocus()

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

    def _auto_fix_on_enter(self, editor: CodeEditor) -> bool:
        if self._auto_indent_after_opening_brace(editor):
            return True

        cursor = editor.textCursor()
        suggestions = self._structural_suggestions_at_cursor(editor)
        fix = self._first_structural_fix(suggestions)
        if fix is None:
            return False
        if fix == "}" and self._line_should_end_statement_before_closing(editor):
            fix = ";"

        if fix == ";":
            if not self._should_auto_insert_semicolon(editor):
                return False
            cursor.insertText(fix)
        elif fix == "}":
            if self._should_auto_insert_closing_brace(editor):
                indent = self._closing_brace_indent(editor)
                block_start = cursor.block().position()
                cursor.setPosition(block_start, QTextCursor.KeepAnchor)
                cursor.insertText(indent + fix)
            elif self._should_auto_append_closing_brace(editor):
                indent = self._closing_brace_indent(editor)
                cursor.insertText(f"\n{indent}{fix}")
            else:
                return False
        else:
            cursor.insertText(fix)

        editor.setTextCursor(cursor)
        self._set_state(f"Correccion automatica: {fix}")
        return True

    def _auto_indent_after_opening_brace(self, editor: CodeEditor) -> bool:
        cursor = editor.textCursor()
        if cursor.hasSelection():
            return False

        line_before_cursor = cursor.block().text()[: cursor.positionInBlock()]
        if not line_before_cursor.rstrip().endswith("{"):
            return False

        current_indent = self._current_line_indent(editor)
        inner_indent = current_indent + CodeEditor.INDENT
        line_after_cursor = cursor.block().text()[cursor.positionInBlock() :]

        if line_after_cursor.lstrip().startswith("}"):
            cursor.insertText(f"\n{inner_indent}\n{current_indent}")
            cursor.movePosition(QTextCursor.Up)
            cursor.movePosition(QTextCursor.EndOfLine)
        else:
            cursor.insertText(f"\n{inner_indent}")

        editor.setTextCursor(cursor)
        self._set_state("Indentacion automatica")
        return True

    def _structural_suggestions_at_cursor(self, editor: CodeEditor):
        cursor_position = editor.textCursor().position()
        source_before_cursor = editor.toPlainText()[:cursor_position]
        diagnostics, suggestions = self.syntax_service.analyze(
            source_before_cursor,
            include_semantic=False,
        )
        if self._cursor_at_document_end(editor) and not self._line_needs_semicolon_first(editor, suggestions):
            for diagnostic in reversed(diagnostics):
                if set(diagnostic.expected) & {"}", ")", "]"}:
                    return diagnostic.suggestions
        return suggestions

    def _first_structural_fix(self, suggestions) -> str | None:
        allowed = {";", "}", ")", "]", ":"}
        for suggestion in suggestions:
            if suggestion.insert_text in allowed:
                return suggestion.insert_text
        return None

    def _should_auto_insert_semicolon(self, editor: CodeEditor) -> bool:
        cursor = editor.textCursor()
        before = cursor.block().text()[: cursor.positionInBlock()].rstrip()
        if not before:
            return False
        if before.endswith((";", "{", "}", "(", "[", ":", ",")):
            return False
        return True

    def _line_needs_semicolon_first(self, editor: CodeEditor, suggestions) -> bool:
        if self._first_structural_fix(suggestions) != ";":
            return False
        return self._should_auto_insert_semicolon(editor)

    def _line_should_end_statement_before_closing(self, editor: CodeEditor) -> bool:
        cursor = editor.textCursor()
        before = cursor.block().text()[: cursor.positionInBlock()].rstrip()
        if not before:
            return False
        if before.endswith((";", "{", "}", "(", "[", ":", ",")):
            return False
        if before == "return":
            return False
        return True

    def _should_auto_insert_closing_brace(self, editor: CodeEditor) -> bool:
        if not self._cursor_at_line_start(editor):
            return False

        source = editor.toPlainText()
        cursor_position = editor.textCursor().position()
        opening_offset = self._find_unclosed_opening(source, cursor_position, "{", "}")
        if opening_offset is None:
            return False

        previous_line = self._previous_non_empty_line(editor)
        if previous_line is None:
            return False
        if previous_line.rstrip().endswith("}"):
            return False

        current_indent = len(self._current_line_indent(editor))
        opening_indent = self._line_indent_at_offset(source, opening_offset)
        return current_indent <= opening_indent + len(CodeEditor.INDENT)

    def _should_auto_append_closing_brace(self, editor: CodeEditor) -> bool:
        if not self._cursor_at_document_end(editor):
            return False

        source = editor.toPlainText()
        cursor_position = editor.textCursor().position()
        if self._find_unclosed_opening(source, cursor_position, "{", "}") is None:
            return False

        current_line = editor.textCursor().block().text()[: editor.textCursor().positionInBlock()]
        stripped = current_line.rstrip()
        return bool(stripped) and stripped.endswith((";", "}"))

    def _cursor_at_document_end(self, editor: CodeEditor) -> bool:
        return editor.textCursor().position() == len(editor.toPlainText())

    def _previous_non_empty_line(self, editor: CodeEditor) -> str | None:
        block = editor.textCursor().block().previous()
        while block.isValid():
            text = block.text()
            if text.strip():
                return text
            block = block.previous()
        return None

    def _current_line_indent(self, editor: CodeEditor) -> str:
        text = editor.textCursor().block().text()
        return text[: len(text) - len(text.lstrip(" "))]

    def _cursor_at_line_start(self, editor: CodeEditor) -> bool:
        cursor = editor.textCursor()
        return cursor.positionInBlock() == 0 or cursor.block().text()[: cursor.positionInBlock()].strip() == ""

    def _closing_brace_indent(self, editor: CodeEditor) -> str:
        source = editor.toPlainText()
        opening_offset = self._find_unclosed_opening(
            source,
            editor.textCursor().position(),
            "{",
            "}",
        )
        if opening_offset is not None:
            return " " * self._line_indent_at_offset(source, opening_offset)

        current_indent = self._current_line_indent(editor)
        if len(current_indent) >= len(CodeEditor.INDENT):
            return current_indent[: -len(CodeEditor.INDENT)]
        return ""

    def _line_indent_at_offset(self, source: str, offset: int) -> int:
        line_start = source.rfind("\n", 0, offset) + 1
        indent = 0
        while line_start + indent < len(source) and source[line_start + indent] == " ":
            indent += 1
        return indent

    def _handle_current_tab_changed(self, _index: int) -> None:
        editor = self.current_editor()
        if editor is None:
            self.status_position.setText("Ln 1, Col 1")
            return

        path = self.editor_paths.get(editor)
        if path is not None:
            self._select_file_in_sidebar(path)
            self._set_state(path.name)
        self._update_cursor_position()
        diagnostics = self.editor_diagnostics.get(editor, [])
        if diagnostics:
            _, suggestions = self.syntax_service.analyze(editor.toPlainText())
            self._set_problem_count(len(diagnostics))
            self._show_syntax_problems(diagnostics, suggestions)
        elif self.problems_panel.toPlainText().startswith("IDE:"):
            self._set_problem_count(0)
            self.problems_panel.setPlainText(NO_PROBLEMS_TEXT)

    def _select_file_in_sidebar(self, path: Path) -> None:
        resolved = str(path.resolve())
        for row in range(self.file_list.count()):
            item = self.file_list.item(row)
            item_path = item.data(Qt.UserRole)
            if item_path and str(Path(item_path).resolve()) == resolved:
                self.file_list.setCurrentRow(row)
                return

    def _handle_editor_text_changed(self, editor: CodeEditor) -> None:
        if self._loading_editor:
            return
        self._update_tab_title(editor)
        self._validate_editor(editor)

    def _validate_editor(self, editor: CodeEditor) -> None:
        diagnostics, suggestions = self.syntax_service.analyze(editor.toPlainText())
        self.editor_diagnostics[editor] = diagnostics
        self._apply_diagnostics(editor, diagnostics)

        if editor is not self.current_editor():
            return

        if diagnostics:
            self._set_problem_count(len(diagnostics))
            self._show_syntax_problems(diagnostics, suggestions)
        else:
            self._set_problem_count(0)
            if self.problems_panel.toPlainText().startswith("IDE:"):
                self.problems_panel.setPlainText(NO_PROBLEMS_TEXT)

    def _apply_diagnostics(self, editor: CodeEditor, diagnostics: list[Diagnostic]) -> None:
        selections = []
        for diagnostic in diagnostics[:8]:
            selection = QTextEdit.ExtraSelection()
            selection.cursor = self._cursor_for_diagnostic(editor, diagnostic)
            text_format = QTextCharFormat()
            text_format.setForeground(QColor("#F14C4C"))
            text_format.setUnderlineColor(QColor("#F14C4C"))
            text_format.setUnderlineStyle(QTextCharFormat.SpellCheckUnderline)
            text_format.setToolTip(diagnostic.message)
            selection.format = text_format
            selections.append(selection)

        editor.setExtraSelections(selections)

    def _cursor_for_diagnostic(self, editor: CodeEditor, diagnostic: Diagnostic) -> QTextCursor:
        related_cursor = self._cursor_for_related_syntax_error(editor, diagnostic)
        if related_cursor is not None:
            return related_cursor

        document = editor.document()
        block = document.findBlockByNumber(max(0, diagnostic.line - 1))
        cursor = QTextCursor(block)
        start = block.position() + max(0, diagnostic.column - 1)
        end = min(start + diagnostic.length, block.position() + block.length() - 1)
        cursor.setPosition(start)
        cursor.setPosition(max(start + 1, end), QTextCursor.KeepAnchor)
        return cursor

    def _cursor_for_related_syntax_error(
        self,
        editor: CodeEditor,
        diagnostic: Diagnostic,
    ) -> QTextCursor | None:
        expected = set(diagnostic.expected)
        source = editor.toPlainText()
        error_offset = self._offset_for_diagnostic(editor, diagnostic)

        if "}" in expected:
            opening_offset = self._find_block_opening_before_outdented_line(
                source,
                error_offset,
            )
            if opening_offset is None:
                opening_offset = self._find_unclosed_opening(source, error_offset, "{", "}")
            if opening_offset is not None:
                return self._cursor_for_offset(editor, opening_offset, 1)

        if ")" in expected:
            current_char = source[error_offset] if error_offset < len(source) else ""
            if "fin de archivo" in diagnostic.message or current_char in {"", "\n", "\r"}:
                opening_offset = self._find_unclosed_opening(source, error_offset, "(", ")")
                if opening_offset is not None:
                    return self._cursor_for_offset(editor, opening_offset, 1)

        if ";" in expected:
            statement_end = self._find_previous_statement_end(source, error_offset)
            if statement_end is not None:
                return self._cursor_for_offset(editor, statement_end, 1)

        return None

    def _offset_for_diagnostic(self, editor: CodeEditor, diagnostic: Diagnostic) -> int:
        block = editor.document().findBlockByNumber(max(0, diagnostic.line - 1))
        if not block.isValid():
            return len(editor.toPlainText())
        return min(
            len(editor.toPlainText()),
            block.position() + max(0, diagnostic.column - 1),
        )

    def _cursor_for_offset(self, editor: CodeEditor, offset: int, length: int) -> QTextCursor:
        cursor = QTextCursor(editor.document())
        cursor.setPosition(max(0, min(offset, len(editor.toPlainText()))))
        cursor.setPosition(
            max(0, min(offset + length, len(editor.toPlainText()))),
            QTextCursor.KeepAnchor,
        )
        return cursor

    def _find_unclosed_opening(
        self,
        source: str,
        limit: int,
        opening: str,
        closing: str,
    ) -> int | None:
        stack = []
        for index, char in enumerate(source[:limit]):
            if char == opening:
                stack.append(index)
            elif char == closing and stack:
                stack.pop()
        if not stack:
            return None
        return stack[-1]

    def _find_block_opening_before_outdented_line(
        self,
        source: str,
        limit: int,
    ) -> int | None:
        stack: list[tuple[int, int, int]] = []
        offset = 0

        for line in source[:limit].splitlines(keepends=True):
            raw_line = line.rstrip("\r\n")
            stripped = raw_line.lstrip(" ")
            indent = len(raw_line) - len(stripped)

            if stripped and not stripped.startswith("}"):
                while stack and indent <= stack[-1][1] and offset > stack[-1][2]:
                    return stack[-1][0]

            for column, char in enumerate(raw_line):
                absolute = offset + column
                if char == "{":
                    stack.append((absolute, indent, offset))
                elif char == "}" and stack:
                    stack.pop()

            offset += len(line)

        return None

    def _find_previous_statement_end(self, source: str, limit: int) -> int | None:
        index = min(limit, len(source)) - 1
        while index >= 0 and source[index].isspace():
            index -= 1
        if index < 0:
            return None
        if source[index] in {"}", ")"}:
            return index
        return index

    def _show_syntax_problems(
        self,
        diagnostics: list[Diagnostic],
        suggestions,
    ) -> None:
        lines = ["IDE: diagnostico del compilador"]
        for diagnostic in diagnostics:
            lines.append(f"Linea {diagnostic.line}, columna {diagnostic.column}: {diagnostic.message}")
            if diagnostic.expected:
                lines.append("Esperado: " + ", ".join(diagnostic.expected))

        if suggestions:
            lines.append("")
            lines.append("Sugerencias:")
            for suggestion in suggestions:
                lines.append(f"- {suggestion.label}")

        self.problems_panel.setPlainText("\n".join(lines))
        self._update_output_problem_hint(len(diagnostics))

    def _set_problem_count(self, count: int) -> None:
        label = "problema" if count == 1 else "problemas"
        self.status_problems.setText(f"{count} {label}")
        self._update_problem_tab_badge(count)
        if count == 0:
            self._clear_output_problem_hint()

    def _update_problem_tab_badge(self, count: int) -> None:
        index = self.output_tabs.indexOf(self.problems_panel)
        if index == -1:
            return

        if count <= 0:
            self.output_tabs.setTabText(index, "Problemas")
            self.output_tabs.setTabIcon(index, QIcon())
            return

        self.output_tabs.setTabText(index, "Problemas")
        self.output_tabs.setTabIcon(index, make_problem_badge_icon(count))

    def _update_output_problem_hint(self, count: int) -> None:
        current = self.output_panel.toPlainText().strip()
        if current and current != READY_OUTPUT_TEXT and PROBLEM_OUTPUT_MARKER not in current:
            return

        label = "problema" if count == 1 else "problemas"
        self.output_panel.setPlainText(
            f"Hay {count} {label} en el editor. {PROBLEM_OUTPUT_MARKER}"
        )

    def _clear_output_problem_hint(self) -> None:
        if PROBLEM_OUTPUT_MARKER in self.output_panel.toPlainText():
            self.output_panel.setPlainText(READY_OUTPUT_TEXT)

    def _update_tab_title(self, editor: CodeEditor) -> None:
        path = self.editor_paths.get(editor)
        if path is None:
            return

        index = self.editor_tabs.indexOf(editor)
        if index == -1:
            return

        suffix = " *" if editor.document().isModified() else ""
        self.editor_tabs.setTabText(index, f"{path.name}{suffix}")

    def _update_cursor_position(self) -> None:
        editor = self.current_editor()
        if editor is None:
            return

        cursor = editor.textCursor()
        self.status_position.setText(
            f"Ln {cursor.blockNumber() + 1}, Col {cursor.positionInBlock() + 1}"
        )

    def _handle_compile_started(self) -> None:
        self._set_execution_controls_enabled(False)
        status = (
            f"Compilando: {self.current_optimization_label}, "
            f"unroll {self.current_unroll_label}"
        )
        self._set_state(status)
        self.sidebar_status.setText(status)

    def _append_compiler_output(self, text: str) -> None:
        self.output_panel.moveCursor(QTextCursor.End)
        self.output_panel.insertPlainText(text)

    def _append_compiler_error(self, text: str) -> None:
        if self.problems_panel.toPlainText() == NO_PROBLEMS_TEXT:
            self.problems_panel.clear()
        self.problems_panel.moveCursor(QTextCursor.End)
        self.problems_panel.insertPlainText(text)
        self._set_problem_count(1)
        self.output_tabs.setCurrentWidget(self.problems_panel)

    def _handle_compile_finished(self, exit_code: int) -> None:
        path = self.active_compile_path

        if exit_code == 0:
            self._set_problem_count(0)
            status = (
                f"Compilado correctamente: {self.current_optimization_label}, "
                f"unroll {self.current_unroll_label}"
            )
            self.sidebar_status.setText(status)
            self._set_state(status)

            if self.pending_run:
                hex_path = self.compiler.generated_hex_path
                if hex_path is None:
                    self.pending_run = False
                    self._set_problem_text(
                        "La compilacion termino correctamente, pero no se pudo "
                        "determinar la ruta del archivo .hex generado."
                    )
                    self.sidebar_status.setText("No se pudo iniciar la simulacion")
                    self._set_state("No se pudo iniciar la simulacion")
                    self._set_execution_controls_enabled(True)
                else:
                    self.output_panel.moveCursor(QTextCursor.End)
                    self.output_panel.insertPlainText(
                        "\n"
                        "============================================================\n"
                        f"  EJECUTANDO EN RTL: {hex_path.name}\n"
                        "============================================================\n"
                    )
                    self.simulator.run(hex_path)
            else:
                self._set_execution_controls_enabled(True)
        else:
            self.pending_run = False
            if self.problems_panel.toPlainText() == NO_PROBLEMS_TEXT:
                details = self.output_panel.toPlainText().strip()
                self.problems_panel.setPlainText(details or "El compilador termino con errores.")
            self._set_problem_count(1)
            self.sidebar_status.setText("Error de compilacion")
            self._set_state("Error de compilacion")
            self.output_tabs.setCurrentWidget(self.problems_panel)
            self._set_execution_controls_enabled(True)

        if path is not None:
            self._refresh_artifacts(path)
        self.active_compile_path = None

    def _handle_simulation_started(self) -> None:
        self._set_execution_controls_enabled(False)
        self.output_tabs.setCurrentWidget(self.output_panel)
        status = f"Ejecutando: {self.current_optimization_label}"
        self.sidebar_status.setText(status)
        self._set_state(status)

    def _append_simulation_output(self, text: str) -> None:
        self.output_panel.moveCursor(QTextCursor.End)
        self.output_panel.insertPlainText(text)

    def _handle_simulation_finished(self, exit_code: int) -> None:
        self.pending_run = False
        self._set_execution_controls_enabled(True)

        failed = (
            exit_code != 0
            or "[ERROR] Test abortado" in self.simulator.output_text
        )
        if failed:
            status = f"Simulacion terminada con error ({exit_code})"
            self._set_problem_text(
                "La simulacion no termino correctamente. "
                "Revise la pestana Salida para ver el diagnostico del testbench."
            )
            self.output_tabs.setCurrentWidget(self.output_panel)
        else:
            match = re.search(
                r"\[METRICS\]\s+cycles=(\d+)\|instr=(\d+)\|cpi=([0-9.]+)",
                self.simulator.output_text,
            )
            if match:
                status = (
                    f"Simulacion finalizada: ciclos={match.group(1)}, "
                    f"instr={match.group(2)}, CPI={match.group(3)}"
                )
            else:
                status = "Simulacion finalizada correctamente"
            self._set_problem_count(0)

        self.sidebar_status.setText(status)
        self._set_state(status)

    def _set_execution_controls_enabled(self, enabled: bool) -> None:
        self.compile_button.setEnabled(enabled)
        self.run_button.setEnabled(enabled)
        self.unroll_factor_input.setEnabled(enabled)

    def _refresh_artifacts(self, source_path: Path) -> None:
        artifacts = self.workspace.artifact_paths_for(source_path)
        if not artifacts:
            self.artifacts_panel.setPlainText("No se encontraron artefactos para el archivo activo.")
            return

        lines = [self.workspace.relative_label(path) for path in artifacts]
        self.artifacts_panel.setPlainText("\n".join(lines))

    def _set_problem_text(self, text: str) -> None:
        self.problems_panel.setPlainText(text)
        self.output_tabs.setCurrentWidget(self.problems_panel)
        self._set_problem_count(1)

    def _set_state(self, text: str) -> None:
        self.status_state.setText(text)

    def _build_status_bar(self) -> QWidget:
        bar = QFrame()
        bar.setObjectName("StatusBar")
        layout = QHBoxLayout(bar)
        layout.setContentsMargins(10, 0, 10, 0)
        layout.setSpacing(14)

        self.status_language = QLabel("Craft")
        self.status_encoding = QLabel("UTF-8")
        self.status_position = QLabel("Ln 1, Col 1")
        self.status_problems = QLabel("0 problemas")
        self.status_state = QLabel("Listo")

        items = [
            self.status_language,
            self.status_encoding,
            self.status_position,
            self.status_problems,
            self.status_state,
        ]

        for index, label in enumerate(items):
            label.setObjectName("StatusItemPrimary" if index == 0 else "StatusItem")
            layout.addWidget(label)

        layout.addStretch(1)

        branch = QLabel("main")
        branch.setObjectName("StatusItem")
        layout.addWidget(branch)

        bar.setFixedHeight(26)
        return bar


def main() -> int:
    app = QApplication(sys.argv)
    app.setStyleSheet(APP_QSS)
    window = MainWindow()
    window.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
