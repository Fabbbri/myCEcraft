import sys
from pathlib import Path

from PySide6.QtCore import QRegularExpression, QRect, Qt, QSize, Signal
from PySide6.QtGui import (
    QColor,
    QFont,
    QIcon,
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
from theme import APP_QSS
from workspace import Workspace


APP_TITLE = "Craft Studio"
IDE_DIR = Path(__file__).resolve().parent
REPO_ROOT = IDE_DIR.parent.parent
LOGO_PATH = IDE_DIR / "CS.png"


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
    def __init__(self) -> None:
        super().__init__()
        self.line_number_area = LineNumberArea(self)
        self.highlighter = CraftHighlighter(self.document())

        self.blockCountChanged.connect(self.update_line_number_area_width)
        self.updateRequest.connect(self.update_line_number_area)

        self.setObjectName("CodeEditor")
        self.setLineWrapMode(QPlainTextEdit.NoWrap)
        self.setFont(QFont("Cascadia Mono", 11))
        self.document().setDocumentMargin(14)
        self.update_line_number_area_width()

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
        self.open_editors: dict[Path, CodeEditor] = {}
        self.editor_paths: dict[CodeEditor, Path] = {}
        self._loading_editor = False

        self.setWindowTitle(APP_TITLE)
        self.setMinimumSize(QSize(1100, 720))
        self._build_ui()
        self._connect_compiler()
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

        self.compile_button = QPushButton("Compilar")
        self.compile_button.setObjectName("PrimaryButton")
        self.compile_button.setCursor(Qt.PointingHandCursor)
        self.compile_button.clicked.connect(self.compile_current_file)
        layout.addWidget(self.compile_button)

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
        layout.addWidget(self.file_list)
        layout.addStretch(1)

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
        self.output_panel = self._build_output_panel("Listo para compilar.")
        self.problems_panel = self._build_output_panel("No hay errores ni advertencias.")
        self.artifacts_panel = self._build_output_panel("Sin artefactos generados aun.")
        self.output_tabs.addTab(self.output_panel, "Salida")
        self.output_tabs.addTab(self.problems_panel, "Problemas")
        self.output_tabs.addTab(self.artifacts_panel, "Artefactos")

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
        editor.textChanged.connect(lambda current=editor: self._mark_editor_dirty(current))
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

    def save_current_file(self) -> None:
        editor = self.current_editor()
        if editor is None:
            self._set_state("No hay archivo activo")
            return

        path = self.editor_paths[editor]
        try:
            self.workspace.write_text(path, editor.toPlainText())
        except OSError as error:
            self._set_problem_text(f"No se pudo guardar {path}:\n{error}")
            self._set_state("Error al guardar")
            return

        editor.document().setModified(False)
        self._update_tab_title(editor)
        self._set_state(f"Guardado {path.name}")

    def compile_current_file(self) -> None:
        editor = self.current_editor()
        if editor is None:
            self._set_state("No hay archivo activo")
            return

        if self.compiler.is_running():
            self._set_state("Compilacion en curso")
            return

        if editor.document().isModified():
            self.save_current_file()

        path = self.editor_paths[editor]
        self.output_panel.clear()
        self.problems_panel.setPlainText("No hay errores ni advertencias.")
        self.artifacts_panel.setPlainText("Compilando...")
        self.output_tabs.setCurrentWidget(self.output_panel)
        self.compiler.compile(path)

    def close_editor(self, editor: CodeEditor) -> None:
        index = self.editor_tabs.indexOf(editor)
        if index == -1:
            return

        widget = self.editor_tabs.widget(index)
        if not isinstance(widget, CodeEditor):
            return

        path = self.editor_paths.pop(widget, None)
        if path is not None:
            self.open_editors.pop(path, None)

        self.editor_tabs.removeTab(index)
        widget.deleteLater()
        self._handle_current_tab_changed(self.editor_tabs.currentIndex())

    def _build_tab_close_button(self, editor: CodeEditor) -> QWidget:
        container = QWidget()
        container.setObjectName("TabCloseContainer")
        container.setFixedSize(26, 24)
        layout = QHBoxLayout(container)
        layout.setContentsMargins(4, 3, 0, 3)
        layout.setSpacing(0)

        button = QToolButton()
        button.setObjectName("TabCloseButton")
        button.setIcon(make_close_icon("#969696"))
        button.setIconSize(QSize(14, 14))
        button.setToolTip("Cerrar archivo")
        button.setCursor(Qt.PointingHandCursor)
        button.clicked.connect(lambda _checked=False, current=editor: self.close_editor(current))
        layout.addWidget(button, 0, Qt.AlignCenter)
        return container

    def current_editor(self) -> CodeEditor | None:
        widget = self.editor_tabs.currentWidget()
        if isinstance(widget, CodeEditor):
            return widget
        return None

    def show_artifacts_tab(self) -> None:
        self.output_tabs.setCurrentWidget(self.artifacts_panel)

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

    def _select_file_in_sidebar(self, path: Path) -> None:
        resolved = str(path.resolve())
        for row in range(self.file_list.count()):
            item = self.file_list.item(row)
            item_path = item.data(Qt.UserRole)
            if item_path and str(Path(item_path).resolve()) == resolved:
                self.file_list.setCurrentRow(row)
                return

    def _mark_editor_dirty(self, editor: CodeEditor) -> None:
        if self._loading_editor:
            return
        self._update_tab_title(editor)

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
        self.compile_button.setEnabled(False)
        self._set_state("Compilando...")
        self.sidebar_status.setText("Compilando...")

    def _append_compiler_output(self, text: str) -> None:
        self.output_panel.moveCursor(QTextCursor.End)
        self.output_panel.insertPlainText(text)

    def _append_compiler_error(self, text: str) -> None:
        if self.problems_panel.toPlainText() == "No hay errores ni advertencias.":
            self.problems_panel.clear()
        self.problems_panel.moveCursor(QTextCursor.End)
        self.problems_panel.insertPlainText(text)
        self.output_tabs.setCurrentWidget(self.problems_panel)

    def _handle_compile_finished(self, exit_code: int) -> None:
        self.compile_button.setEnabled(True)
        editor = self.current_editor()
        path = self.editor_paths.get(editor) if editor is not None else None

        if exit_code == 0:
            self.status_problems.setText("0 problemas")
            self.sidebar_status.setText("Compilado correctamente")
            self._set_state("Compilado correctamente")
        else:
            if self.problems_panel.toPlainText() == "No hay errores ni advertencias.":
                details = self.output_panel.toPlainText().strip()
                self.problems_panel.setPlainText(details or "El compilador termino con errores.")
            self.status_problems.setText("1 problema")
            self.sidebar_status.setText("Error de compilacion")
            self._set_state("Error de compilacion")
            self.output_tabs.setCurrentWidget(self.problems_panel)

        if path is not None:
            self._refresh_artifacts(path)

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
        self.status_problems.setText("1 problema")

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
