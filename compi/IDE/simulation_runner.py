from pathlib import Path

from PySide6.QtCore import QObject, QProcess, Signal


class SimulationRunner(QObject):
    started = Signal()
    output_ready = Signal(str)
    finished = Signal(int)

    def __init__(self, repo_root: Path) -> None:
        super().__init__()
        self.repo_root = repo_root
        self.run_script = repo_root / "run.sh"
        self.output_text = ""
        self.process = QProcess(self)
        self.process.setProcessChannelMode(QProcess.MergedChannels)
        self.process.readyReadStandardOutput.connect(self._read_output)
        self.process.errorOccurred.connect(self._handle_process_error)
        self.process.finished.connect(self._handle_finished)

    def is_running(self) -> bool:
        return self.process.state() != QProcess.NotRunning

    def run(self, hex_path: Path) -> None:
        if self.is_running():
            return
        if not self.run_script.is_file():
            self.output_ready.emit(
                f"No se encontro el script de simulacion: {self.run_script}\n"
            )
            self.finished.emit(127)
            return
        if not hex_path.is_file():
            self.output_ready.emit(
                f"No se encontro el programa compilado: {hex_path}\n"
            )
            self.finished.emit(2)
            return

        self.output_text = ""
        self.process.setWorkingDirectory(str(self.repo_root))
        self.started.emit()
        self.process.start(
            str(self.run_script),
            ["run", "tb_general_dump", str(hex_path.resolve())],
        )

    def _read_output(self) -> None:
        text = bytes(self.process.readAllStandardOutput()).decode(
            "utf-8",
            errors="replace",
        )
        if text:
            self.output_text += text
            self.output_ready.emit(text)

    def _handle_finished(
        self,
        exit_code: int,
        _exit_status: QProcess.ExitStatus,
    ) -> None:
        self.finished.emit(exit_code)

    def _handle_process_error(self, error: QProcess.ProcessError) -> None:
        self.output_ready.emit(
            f"No se pudo ejecutar la simulacion: {error.name}\n"
        )
