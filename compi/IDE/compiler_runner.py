import sys
import re
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
        self.generated_hex_path: Path | None = None
        self._stdout = ""
        self.process = QProcess(self)
        self.process.readyReadStandardOutput.connect(self._read_stdout)
        self.process.readyReadStandardError.connect(self._read_stderr)
        self.process.errorOccurred.connect(self._handle_process_error)
        self.process.finished.connect(self._handle_finished)

    def is_running(self) -> bool:
        return self.process.state() != QProcess.NotRunning

    def compile(
        self,
        source_path: Path,
        *,
        loop_unrolling: bool = False,
        unroll_factor: int | None = None,
        rename_registers: bool = False,
        eliminate_dead_code: bool = False,
        reorder_instructions: bool = False,
        artifact_tag: str | None = None,
    ) -> None:
        if self.is_running():
            return

        if unroll_factor is not None and not 1 <= unroll_factor <= 64:
            raise ValueError(
                f"factor de loop unrolling no soportado: {unroll_factor}"
            )

        args = [
            str(self.compiler_path),
            "-m",
            "-r",
            "-b",
            "-i",
            "--cfg",
            "-O0",
        ]
        if loop_unrolling:
            if unroll_factor is None:
                args.append("--unroll")
            else:
                args.extend(["--unroll-factor", str(unroll_factor)])
        if rename_registers:
            args.append("--rename-registers")
        if eliminate_dead_code:
            args.append("--dce")
        if reorder_instructions:
            args.append("--reorder")
        if artifact_tag:
            args.extend(["--artifact-tag", artifact_tag])
        args.append(str(source_path))

        self.generated_hex_path = None
        self._stdout = ""
        self.process.setWorkingDirectory(str(self.repo_root))
        self.started.emit()
        self.process.start(sys.executable, args)

    def _read_stdout(self) -> None:
        text = bytes(self.process.readAllStandardOutput()).decode("utf-8", errors="replace")
        if text:
            self._stdout += text
            self.output_ready.emit(text)

    def _read_stderr(self) -> None:
        text = bytes(self.process.readAllStandardError()).decode("utf-8", errors="replace")
        if text:
            self.error_ready.emit(text)

    def _handle_finished(self, exit_code: int, _exit_status: QProcess.ExitStatus) -> None:
        if exit_code == 0:
            matches = re.findall(
                r"Codigo hexadecimal de instrucciones generado:\s*(.+?\.hex)\s*$",
                self._stdout,
                flags=re.MULTILINE,
            )
            if matches:
                self.generated_hex_path = Path(matches[-1].strip()).resolve()
        self.finished.emit(exit_code)

    def _handle_process_error(self, error: QProcess.ProcessError) -> None:
        self.error_ready.emit(f"No se pudo ejecutar el compilador: {error.name}\n")
