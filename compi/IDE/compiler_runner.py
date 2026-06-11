import sys
from pathlib import Path

from PySide6.QtCore import QObject, QProcess, Signal


class CompilerRunner(QObject):
    started = Signal()
    output_ready = Signal(str)
    error_ready = Signal(str)
    finished = Signal(int)

    def __init__(self, repo_root: Path) -> None:
        super().__init__()
        self.repo_root = repo_root
        self.compiler_path = repo_root / "compi" / "main.py"
        self.process = QProcess(self)
        self.process.readyReadStandardOutput.connect(self._read_stdout)
        self.process.readyReadStandardError.connect(self._read_stderr)
        self.process.errorOccurred.connect(self._handle_process_error)
        self.process.finished.connect(self._handle_finished)

    def is_running(self) -> bool:
        return self.process.state() != QProcess.NotRunning

    def compile(self, source_path: Path, optimization: str = "-O0") -> None:
        if self.is_running():
            return

        if optimization not in {"-O0", "-O1", "-O2", "-O3"}:
            raise ValueError(f"nivel de optimizacion no soportado: {optimization}")

        args = [
            str(self.compiler_path),
            "-m",
            "-r",
            "-b",
            "-i",
            optimization,
            str(source_path),
        ]
        self.process.setWorkingDirectory(str(self.repo_root))
        self.started.emit()
        self.process.start(sys.executable, args)

    def _read_stdout(self) -> None:
        text = bytes(self.process.readAllStandardOutput()).decode("utf-8", errors="replace")
        if text:
            self.output_ready.emit(text)

    def _read_stderr(self) -> None:
        text = bytes(self.process.readAllStandardError()).decode("utf-8", errors="replace")
        if text:
            self.error_ready.emit(text)

    def _handle_finished(self, exit_code: int, _exit_status: QProcess.ExitStatus) -> None:
        self.finished.emit(exit_code)

    def _handle_process_error(self, error: QProcess.ProcessError) -> None:
        self.error_ready.emit(f"No se pudo ejecutar el compilador: {error.name}\n")
