APP_QSS = """
* {
    font-family: "Inter", "Segoe UI", "Roboto", "Helvetica", "Arial", sans-serif;
    color: #CCCCCC;
}

QMainWindow {
    background: #1E1E1E;
}

#AppRoot {
    background: #1E1E1E;
}

#TopBar {
    background: #252526;
    border: none;
    border-bottom: 1px solid #3C3C3C;
    border-radius: 0;
}

#BrandMark {
    min-width: 34px;
    max-width: 34px;
    min-height: 34px;
    max-height: 34px;
    background: transparent;
    border: none;
    border-radius: 8px;
    color: #FFFFFF;
    font-size: 12px;
    font-weight: 800;
}

#AppTitle {
    color: #F3F3F3;
    font-size: 13px;
    font-weight: 700;
}

#TopIconButton {
    background: #252526;
    border: 1px solid #3C3C3C;
    border-radius: 6px;
    padding: 6px 10px;
    color: #CCCCCC;
    font-size: 12px;
    font-weight: 600;
}

#TopIconButton:hover,
#TinyIconButton:hover {
    background: #3A3D41;
    border: 1px solid #4A4A4A;
}

#TopIconButton:pressed,
#TinyIconButton:pressed {
    background: #1E1E1E;
}

#TinyIconButton {
    background: transparent;
    border: 1px solid transparent;
    border-radius: 5px;
    padding: 2px 7px;
    color: #CCCCCC;
    font-size: 13px;
    font-weight: 700;
}

#PrimaryButton,
#RunButton {
    border-radius: 6px;
    padding: 7px 13px;
    font-size: 12px;
    font-weight: 700;
}

#PrimaryButton {
    background: #3A3D41;
    color: #FFFFFF;
    border: 1px solid #4A4A4A;
}

#PrimaryButton:hover {
    background: #45494E;
    border-color: #5A5A5A;
}

#PrimaryButton:pressed {
    background: #2A2D30;
    border-color: #3C3C3C;
}

#PrimaryButton:disabled {
    background: #2A2D30;
    border-color: #3C3C3C;
    color: #6B6B6B;
}

#TopControlLabel {
    color: #AFAFAF;
    font-size: 11px;
    font-weight: 600;
}

#TopNumberInput {
    min-width: 54px;
    background: #252526;
    color: #CCCCCC;
    border: 1px solid #3C3C3C;
    border-radius: 6px;
    padding: 5px 8px;
    font-size: 11px;
}

#TopNumberInput:hover,
#TopNumberInput:focus {
    border-color: #5A5A5A;
}

QMenu {
    background: #252526;
    border: 1px solid #4A4A4A;
    padding: 4px;
}

QMenu::item {
    padding: 7px 22px;
    border-radius: 4px;
}

QMenu::item:selected {
    background: #3A3D41;
    color: #FFFFFF;
}

#RunButton {
    background: #16825D;
    color: #FFFFFF;
    border: 1px solid #1A9A6E;
}

#RunButton:hover {
    background: #1A9A6E;
    border-color: #25B985;
}

#RunButton:pressed {
    background: #0F6347;
    border-color: #16825D;
}

#RunButton:disabled {
    background: #1E3D30;
    border-color: #2A4A38;
    color: #558064;
}

QSplitter::handle {
    background: transparent;
}

QSplitter::handle:hover {
    background: #3C3C3C;
}

#MainSplitter::handle:horizontal {
    width: 10px;
}

#EditorSplitter::handle:vertical {
    height: 10px;
}

#Sidebar {
    background: #252526;
    border: none;
    border-right: 1px solid #3C3C3C;
    border-radius: 0;
}

#SectionTitle {
    font-size: 10px;
    font-weight: 700;
    color: #BBBBBB;
    letter-spacing: 0px;
}

#WorkspaceRow {
    background: transparent;
    border-bottom: 1px solid #3C3C3C;
    padding: 3px 0 9px 0;
}

#WorkspaceIcon {
    color: #858585;
    font-size: 11px;
}

#WorkspaceLabel {
    background: transparent;
    border: none;
    color: #CCCCCC;
    padding: 0;
    font-size: 12px;
    font-weight: 700;
}

#InlineFileInput {
    background: #3C3C3C;
    border: 1px solid #007FD4;
    border-radius: 2px;
    color: #FFFFFF;
    padding: 5px 8px;
    selection-background-color: #264F78;
    selection-color: #FFFFFF;
    font-size: 12px;
}

#SidebarHint {
    font-size: 11px;
    color: #89D185;
    padding: 2px 0 1px 0;
}

#FileList {
    border: none;
    border-radius: 0;
    padding: 2px 0;
    background: transparent;
    outline: none;
}

#FileList::item {
    padding: 5px 8px;
    border-radius: 6px;
    color: #CCCCCC;
}

#FileList::item:selected {
    background: #37373D;
    color: #FFFFFF;
}

#FileList::item:hover {
    background: #2A2D2E;
    color: #FFFFFF;
}

#FileList QScrollBar:vertical {
    background: transparent;
    width: 7px;
    margin: 4px 0 4px 0;
}

#FileList QScrollBar::handle:vertical {
    background: #424242;
    border-radius: 3px;
    min-height: 28px;
}

#FileList QScrollBar::handle:vertical:hover {
    background: #5A5A5A;
}

#FileList QScrollBar::add-line:vertical,
#FileList QScrollBar::sub-line:vertical,
#FileList QScrollBar::add-page:vertical,
#FileList QScrollBar::sub-page:vertical {
    background: transparent;
    border: none;
    height: 0;
}

#EditorContainer {
    background: transparent;
}

QTabWidget::pane {
    border: 1px solid #3C3C3C;
    border-radius: 0;
    background: #1E1E1E;
    top: -1px;
}

QTabBar::tab {
    background: #2D2D2D;
    color: #858585;
    padding: 8px 8px 8px 14px;
    border-top-left-radius: 4px;
    border-top-right-radius: 4px;
    border: 1px solid transparent;
    border-bottom: none;
    margin-right: 2px;
    font-size: 12px;
}

QTabBar::tab:hover {
    background: #37373D;
    color: #CCCCCC;
    border-color: #3C3C3C;
}

QTabBar::tab:selected {
    background: #1E1E1E;
    color: #FFFFFF;
    border: 1px solid #3C3C3C;
    border-bottom: 1px solid #1E1E1E;
}

#TabCloseContainer {
    background: transparent;
    min-width: 28px;
    max-width: 28px;
    min-height: 22px;
    max-height: 22px;
}

#TabCloseButton {
    background: transparent;
    border: 1px solid transparent;
    border-radius: 4px;
    min-width: 16px;
    max-width: 16px;
    min-height: 16px;
    max-height: 16px;
    padding: 0;
    margin: 0;
}

#TabCloseButton:hover {
    background: #45494E;
    border-color: transparent;
}

#TabCloseButton:pressed {
    background: #50555C;
    border-color: transparent;
}

#CodeEditor {
    background: #1E1E1E;
    color: #D4D4D4;
    border: none;
    padding: 0;
    selection-background-color: #3A3D41;
    selection-color: #FFFFFF;
    font-family: "Cascadia Mono", "JetBrains Mono", "Consolas", monospace;
}

#LL1TableView {
    background: #1E1E1E;
}

#LL1Title {
    color: #FFFFFF;
    font-size: 21px;
    font-weight: 750;
}

#LL1Description {
    color: #AFAFAF;
    font-size: 12px;
    padding-bottom: 2px;
}

#LL1Guide {
    background: #252526;
    color: #CCCCCC;
    border-left: 3px solid #007FD4;
    border-radius: 4px;
    padding: 9px 12px;
    font-size: 11px;
}

#LL1Stat {
    background: #252526;
    color: #DCDCAA;
    border: 1px solid #3C3C3C;
    border-radius: 7px;
    padding: 8px 14px;
    font-family: "Cascadia Mono", "JetBrains Mono", "Consolas", monospace;
    font-size: 11px;
    font-weight: 700;
}

#LL1SearchLabel {
    color: #CCCCCC;
    font-size: 12px;
    font-weight: 700;
}

#LL1SearchInput {
    background: #252526;
    color: #FFFFFF;
    border: 1px solid #3C3C3C;
    border-radius: 6px;
    padding: 7px 10px;
    selection-background-color: #264F78;
    font-size: 12px;
}

#LL1SearchInput:focus {
    border-color: #007FD4;
}

#LL1VisibleCount,
#LL1Legend {
    color: #858585;
    font-size: 11px;
}

#LL1SelectedEntry {
    background: #252526;
    color: #DCDCAA;
    border: 1px solid #3C3C3C;
    border-radius: 5px;
    padding: 7px 10px;
    font-family: "Cascadia Mono", "JetBrains Mono", "Consolas", monospace;
    font-size: 11px;
}

#LL1ParseTable {
    background: #1E1E1E;
    alternate-background-color: #202020;
    color: #D4D4D4;
    border: 1px solid #3C3C3C;
    border-radius: 7px;
    gridline-color: #343434;
    outline: none;
    selection-background-color: #264F78;
    selection-color: #FFFFFF;
    font-family: "Cascadia Mono", "JetBrains Mono", "Consolas", monospace;
    font-size: 10px;
}

#LL1ParseTable::item {
    padding: 6px 9px;
}

#LL1ParseTable::item:selected {
    background: #264F78;
    color: #FFFFFF;
}

#LL1ParseTable QHeaderView::section {
    background: #2D2D2D;
    color: #FFFFFF;
    border-right: 1px solid #3C3C3C;
    border-bottom: 1px solid #4A4A4A;
    padding: 8px 10px;
    font-family: "Inter", "Segoe UI", sans-serif;
    font-size: 11px;
    font-weight: 700;
}

#LL1ParseTable QTableCornerButton::section {
    background: #2D2D2D;
    border: none;
    border-right: 1px solid #3C3C3C;
    border-bottom: 1px solid #4A4A4A;
}

#LL1ParseTable QScrollBar:vertical {
    background: #1E1E1E;
    width: 10px;
    margin: 2px;
}

#LL1ParseTable QScrollBar:horizontal {
    background: #1E1E1E;
    height: 10px;
    margin: 2px;
}

#LL1ParseTable QScrollBar::handle:vertical,
#LL1ParseTable QScrollBar::handle:horizontal {
    background: #424242;
    border-radius: 4px;
    min-height: 32px;
    min-width: 32px;
}

#LL1ParseTable QScrollBar::handle:vertical:hover,
#LL1ParseTable QScrollBar::handle:horizontal:hover {
    background: #5A5A5A;
}

#LL1ParseTable QScrollBar::add-line,
#LL1ParseTable QScrollBar::sub-line,
#LL1ParseTable QScrollBar::add-page,
#LL1ParseTable QScrollBar::sub-page {
    background: transparent;
    border: none;
    width: 0;
    height: 0;
}

#OutputTabs QTabWidget::pane {
    background: #1C1C1C;
    border: 1px solid #3C3C3C;
}

#OutputPanel {
    background: #1C1C1C;
    color: #CCCCCC;
    border: none;
    padding: 13px 14px;
    selection-background-color: #3A3D41;
    font-family: "Cascadia Mono", "JetBrains Mono", "Consolas", monospace;
}

#CodeEditor QScrollBar:vertical,
#OutputPanel QScrollBar:vertical {
    background: #1E1E1E;
    width: 10px;
    margin: 2px 2px 2px 0;
}

#CodeEditor QScrollBar::handle:vertical,
#OutputPanel QScrollBar::handle:vertical {
    background: #424242;
    border-radius: 4px;
    min-height: 32px;
}

#CodeEditor QScrollBar::handle:vertical:hover,
#OutputPanel QScrollBar::handle:vertical:hover {
    background: #5A5A5A;
}

#CodeEditor QScrollBar::add-line:vertical,
#CodeEditor QScrollBar::sub-line:vertical,
#CodeEditor QScrollBar::add-page:vertical,
#CodeEditor QScrollBar::sub-page:vertical,
#OutputPanel QScrollBar::add-line:vertical,
#OutputPanel QScrollBar::sub-line:vertical,
#OutputPanel QScrollBar::add-page:vertical,
#OutputPanel QScrollBar::sub-page:vertical {
    background: transparent;
    border: none;
    height: 0;
}

#CodeEditor QScrollBar:horizontal,
#OutputPanel QScrollBar:horizontal {
    background: #1E1E1E;
    height: 10px;
    margin: 0 2px 2px 2px;
}

#CodeEditor QScrollBar::handle:horizontal,
#OutputPanel QScrollBar::handle:horizontal {
    background: #424242;
    border-radius: 4px;
    min-width: 32px;
}

#CodeEditor QScrollBar::handle:horizontal:hover,
#OutputPanel QScrollBar::handle:horizontal:hover {
    background: #5A5A5A;
}

#CodeEditor QScrollBar::add-line:horizontal,
#CodeEditor QScrollBar::sub-line:horizontal,
#CodeEditor QScrollBar::add-page:horizontal,
#CodeEditor QScrollBar::sub-page:horizontal,
#OutputPanel QScrollBar::add-line:horizontal,
#OutputPanel QScrollBar::sub-line:horizontal,
#OutputPanel QScrollBar::add-page:horizontal,
#OutputPanel QScrollBar::sub-page:horizontal {
    background: transparent;
    border: none;
    width: 0;
}

#CompletionPopup {
    background: #252526;
    border: 1px solid #3C3C3C;
    border-radius: 4px;
    padding: 4px;
    outline: none;
    color: #CCCCCC;
    font-size: 12px;
}

#CompletionPopup::item {
    padding: 6px 8px;
    border-radius: 3px;
    color: #CCCCCC;
}

#CompletionPopup::item:selected {
    background: #37373D;
    color: #FFFFFF;
}

#CompletionPopup QScrollBar:vertical {
    background: transparent;
    width: 7px;
    margin: 3px 0 3px 0;
}

#CompletionPopup QScrollBar::handle:vertical {
    background: #424242;
    border-radius: 3px;
    min-height: 24px;
}

#CompletionPopup QScrollBar::handle:vertical:hover {
    background: #5A5A5A;
}

#CompletionPopup QScrollBar::add-line:vertical,
#CompletionPopup QScrollBar::sub-line:vertical,
#CompletionPopup QScrollBar::add-page:vertical,
#CompletionPopup QScrollBar::sub-page:vertical {
    background: transparent;
    border: none;
    height: 0;
}

#StatusBar {
    background: #252526;
    border: none;
    border-top: 1px solid #3C3C3C;
    border-radius: 0;
}

#StatusItem,
#StatusItemPrimary {
    font-size: 11px;
}

#StatusItem {
    color: #BDBDBD;
}

#StatusItemPrimary {
    color: #FFFFFF;
    font-weight: 750;
}

Minimap {
    background: #1A1A1A;
    border-left: 1px solid #2A2A2A;
}

#CFGOverlay {
    background: rgba(30, 30, 30, 220);
    border: 1px solid #3C3C3C;
    border-radius: 8px;
}

#CFGListHeader {
    background: transparent;
    color: #888888;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 1px;
    padding: 8px 10px 4px 10px;
    border-bottom: 1px solid #3C3C3C;
    border-radius: 0px;
}

#CFGList {
    background: transparent;
    border: none;
    font-size: 11px;
    color: #CCCCCC;
}

#CFGList::item {
    padding: 5px 10px;
    border-bottom: 1px solid #2A2A2A;
}

#CFGList::item:hover {
    background: rgba(255, 255, 255, 15);
}

#CFGList::item:selected {
    background: #37373F;
    color: #FFFFFF;
}

#CFGFitButton {
    background: transparent;
    border: none;
    border-top: 1px solid #3C3C3C;
    border-radius: 0px;
    padding: 6px 10px;
    color: #888888;
    font-size: 11px;
    text-align: left;
}

#CFGFitButton:hover {
    color: #CCCCCC;
    background: rgba(255, 255, 255, 10);
}
"""
