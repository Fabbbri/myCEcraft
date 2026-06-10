from pathlib import Path


class Workspace:
    def __init__(self, repo_root: Path) -> None:
        self.repo_root = repo_root
        self.compi_root = repo_root / "compi"
        self.source_root = (self.compi_root / "ejemplos").resolve()
        self.output_root = self.compi_root / "output"

    def open_folder(self, folder: Path) -> None:
        self.source_root = folder.resolve()

    def list_craft_files(self) -> list[Path]:
        if not self.source_root.is_dir():
            return []
        return sorted(self.source_root.rglob("*.craft"), key=lambda path: self.display_name(path).lower())

    def relative_label(self, path: Path) -> str:
        try:
            return str(path.relative_to(self.repo_root))
        except ValueError:
            return str(path)

    def display_name(self, path: Path) -> str:
        try:
            return str(path.relative_to(self.source_root))
        except ValueError:
            pass
        return path.name

    def read_text(self, path: Path) -> str:
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        path.write_text(content, encoding="utf-8")

    def create_file(self, name: str) -> Path:
        clean_name = name.strip()
        if not clean_name:
            raise ValueError("el nombre del archivo no puede estar vacio")

        path = Path(clean_name)
        if path.suffix == "":
            path = path.with_suffix(".craft")

        if path.is_absolute() or ".." in path.parts:
            raise ValueError("el archivo debe crearse dentro del workspace")

        target = (self.source_root / path).resolve()
        try:
            target.relative_to(self.source_root)
        except ValueError as error:
            raise ValueError("el archivo debe crearse dentro del workspace") from error

        if target.exists():
            raise FileExistsError(f"ya existe {self.display_name(target)}")

        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(
            "@EnterCraftWorld\n\n"
            "craft:int main() {\n"
            "    return 0;\n"
            "}\n",
            encoding="utf-8",
        )
        return target

    def artifact_paths_for(self, source_path: Path) -> list[Path]:
        stem = source_path.stem
        candidates = [
            self.output_root / "expanded" / f"{stem}.expanded.craft",
            self.output_root / "asm_unresolved" / f"{stem}.asm",
            self.output_root / "asm_resolved" / f"{stem}.resolved.asm",
            self.output_root / "bin_output" / f"{stem}.bin",
            self.output_root / "bin_output" / f"{stem}.hex",
            self.output_root / "bin_output" / f"{stem}.lst",
        ]
        expanded_stem = f"{stem}.expanded"
        candidates.extend(
            [
                self.output_root / "asm_unresolved" / f"{expanded_stem}.asm",
                self.output_root / "asm_resolved" / f"{expanded_stem}.resolved.asm",
                self.output_root / "bin_output" / f"{expanded_stem}.bin",
                self.output_root / "bin_output" / f"{expanded_stem}.hex",
                self.output_root / "bin_output" / f"{expanded_stem}.lst",
            ]
        )
        for base_stem in (stem, expanded_stem):
            for level in range(1, 4):
                optimized_stem = f"{base_stem}.O{level}"
                candidates.extend(
                    [
                        self.output_root / "ir" / f"{optimized_stem}.ir.txt",
                        self.output_root / "asm_unresolved" / f"{optimized_stem}.asm",
                        self.output_root / "asm_resolved" / f"{optimized_stem}.resolved.asm",
                        self.output_root / "bin_output" / f"{optimized_stem}.bin",
                        self.output_root / "bin_output" / f"{optimized_stem}.hex",
                        self.output_root / "bin_output" / f"{optimized_stem}.data.hex",
                        self.output_root / "bin_output" / f"{optimized_stem}.lst",
                        self.output_root / "symbols" / f"{optimized_stem}.symbols.txt",
                    ]
                )
        return [path for path in candidates if path.exists()]
