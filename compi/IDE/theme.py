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
    background: #2D2D2D;
    border: 1px solid #3C3C3C;
    border-radius: 8px;
}

#BrandMark {
    min-width: 34px;
    max-width: 34px;
    min-height: 34px;
    max-height: 34px;
    background: #F3F3F3;
    border: 1px solid #4A4A4A;
    border-radius: 8px;
    color: #1E1E1E;
    font-size: 12px;
    font-weight: 800;
}

#AppTitle {
    color: #F3F3F3;
    font-size: 13px;
    font-weight: 700;
}

#AppSubtitle {
    color: #858585;
    font-size: 10px;
}

#ProjectBadge {
    background: #252526;
    color: #CCCCCC;
    border: 1px solid #3C3C3C;
    border-radius: 6px;
    padding: 5px 10px;
    font-size: 11px;
    font-weight: 600;
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

#RunButton {
    background: #16825D;
    color: #FFFFFF;
    border: 1px solid #1A9A6E;
}

#RunButton:hover {
    background: #1A9A6E;
    border-color: #25B985;
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
    border: 1px solid #3C3C3C;
    border-radius: 8px;
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
    padding: 8px 10px;
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
    border-radius: 8px;
    background: #1E1E1E;
    top: -1px;
}

QTabBar::tab {
    background: #2D2D2D;
    color: #969696;
    padding: 8px 14px;
    border-top-left-radius: 6px;
    border-top-right-radius: 6px;
    border: 1px solid #3C3C3C;
    border-bottom: none;
    margin-right: 3px;
    font-size: 12px;
}

QTabBar::tab:hover {
    background: #37373D;
    color: #CCCCCC;
}

QTabBar::tab:selected {
    background: #1E1E1E;
    color: #FFFFFF;
    border: 1px solid #3C3C3C;
    border-bottom: none;
}

#TabCloseContainer {
    background: transparent;
    min-width: 26px;
    max-width: 26px;
    min-height: 24px;
    max-height: 24px;
}

#TabCloseButton {
    background: transparent;
    border: 1px solid transparent;
    border-radius: 3px;
    min-width: 18px;
    max-width: 18px;
    min-height: 18px;
    max-height: 18px;
    padding: 0;
}

#TabCloseButton:hover {
    background: #3A3D41;
    border-color: #4A4A4A;
}

#TabCloseButton:pressed {
    background: #2A2D2E;
    border-color: #3C3C3C;
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

#OutputPanel {
    background: #1E1E1E;
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
    border: 1px solid #3C3C3C;
    border-radius: 7px;
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
"""
