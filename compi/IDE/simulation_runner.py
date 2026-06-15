import re
import shutil
import uuid
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
        self.staging_dir = repo_root / "arqui" / "programs" / ".ide_runs"
        self.bash_path = shutil.which("bash")
        self.output_text = ""
        self._staged_paths: list[Path] = []
        self.process = QProcess(self)
        self.process.setProcessChannelMode(QProcess.MergedChannels)
        self.process.readyReadStandardOutput.connect(self._read_output)
        self.process.errorOccurred.connect(self._handle_process_error)
        self.process.finished.connect(self._handle_finished)

    def is_running(self) -> bool:
        return self.process.state() != QProcess.NotRunning

    def run(
        self,
        hex_path: Path,
        data_hex_path: Path | None = None,
    ) -> None:
        if self.is_running():
            return
        self.output_text = ""
        if not self.run_script.is_file():
            self._emit_output(
                f"No se encontro el script de simulacion: {self.run_script}\n"
            )
            self.finished.emit(127)
            return
        if self.bash_path is None:
            self._emit_output(
                "No se encontro Bash en PATH. Instale Bash o ejecute la IDE "
                "desde Git Bash/WSL.\n"
            )
            self.finished.emit(127)
            return
        if not hex_path.is_file():
            self._emit_output(
                f"No se encontro el programa compilado: {hex_path}\n"
            )
            self.finished.emit(2)
            return
        if data_hex_path is not None and not data_hex_path.is_file():
            self._emit_output(
                f"No se encontro la imagen de datos compilada: {data_hex_path}\n"
            )
            self.finished.emit(2)
            return

        try:
            rom_name, data_name = self._stage_inputs(hex_path, data_hex_path)
        except OSError as error:
            self._emit_output(
                f"No se pudieron preparar los archivos para simulacion: {error}\n"
            )
            self.finished.emit(2)
            return

        self.process.setWorkingDirectory(str(self.repo_root))
        self.started.emit()
        arguments = [
            str(self.run_script),
            "run",
            "tb_general_dump",
            rom_name,
            "+MAX_CYCLES=5000000",
        ]
        if data_name is not None:
            arguments.append(f"+DATA={data_name}")
        self.process.start(
            self.bash_path,
            arguments,
        )

    def diagnostic(self) -> str:
        lines = [line.strip() for line in self.output_text.splitlines()]
        preferred_patterns = (
            r"^\[ERROR\].*$",
            r"^ERROR:.*$",
            r"^.*:\d+:\s*(?:syntax\s+)?error.*$",
            r"^No se pudo ejecutar la simulacion:.*$",
            r"^No se encontro (?:Bash|el script|el programa|la imagen).*$",
            r"^No se pudieron preparar los archivos.*$",
        )
        for pattern in preferred_patterns:
            matches = [
                line
                for line in lines
                if re.search(pattern, line, flags=re.IGNORECASE)
            ]
            if matches:
                return matches[-1]

        make_errors = [
            line
            for line in lines
            if re.search(r"^make(?:\[\d+\])?: \*\*\*.*$", line)
        ]
        if make_errors:
            return make_errors[-1]
        return "La simulacion termino sin confirmar la finalizacion del programa."

    def _stage_inputs(
        self,
        hex_path: Path,
        data_hex_path: Path | None,
    ) -> tuple[str, str | None]:
        self._cleanup_staged_inputs()
        self.staging_dir.mkdir(parents=True, exist_ok=True)
        run_id = uuid.uuid4().hex[:12]

        rom_name = f"ide_{run_id}.hex"
        rom_dest = self.staging_dir / rom_name
        shutil.copy2(hex_path, rom_dest)
        self._staged_paths.append(rom_dest)

        data_name = None
        if data_hex_path is not None:
            data_name = f"ide_{run_id}.data.hex"
            data_dest = self.staging_dir / data_name
            shutil.copy2(data_hex_path, data_dest)
            self._staged_paths.append(data_dest)

        return f"programs/.ide_runs/{rom_name}", (
            f"programs/.ide_runs/{data_name}" if data_name is not None else None
        )

    def _cleanup_staged_inputs(self) -> None:
        for path in self._staged_paths:
            try:
                path.unlink(missing_ok=True)
            except OSError:
                pass
        self._staged_paths.clear()

    def _read_output(self) -> None:
        text = bytes(self.process.readAllStandardOutput()).decode(
            "utf-8",
            errors="replace",
        )
        if text:
            self._emit_output(text)

    def _emit_output(self, text: str) -> None:
        self.output_text += text
        self.output_ready.emit(text)

    def _handle_finished(
        self,
        exit_code: int,
        _exit_status: QProcess.ExitStatus,
    ) -> None:
        self._read_output()
        self._cleanup_staged_inputs()
        self.finished.emit(exit_code)

    def _handle_process_error(self, error: QProcess.ProcessError) -> None:
        text = f"No se pudo ejecutar la simulacion: {error.name}\n"
        self._emit_output(text)
        self._cleanup_staged_inputs()
