#!/usr/bin/env python3
"""Decrypt a TEA-encrypted file by running the teaimg flow in chunks."""

from __future__ import annotations

import argparse
import math
import os
import shutil
import subprocess
import sys
from pathlib import Path

import prepare_teaimg


IMAGE_BASE = prepare_teaimg.IMAGE_BASE
MODE_DECRYPT = prepare_teaimg.MODE_DECRYPT


def parse_positive_int(value: str) -> int:
    try:
        parsed = int(value, 0)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(f"numero invalido: {value!r}") from exc

    if parsed <= 0:
        raise argparse.ArgumentTypeError("debe ser mayor que cero")
    return parsed


def build_parser() -> argparse.ArgumentParser:
    maximum = prepare_teaimg.max_image_bytes(MODE_DECRYPT)
    parser = argparse.ArgumentParser(
        description=(
            "Descifra archivos .enc grandes por bloques usando prepare_teaimg.py "
            "y tb_teaimg_loader."
        )
    )
    parser.add_argument("--input", "-i", required=True, help="archivo .enc de entrada")
    parser.add_argument(
        "--output",
        "-o",
        help="archivo descifrado final (default: arqui/outputs/NOMBRE_descifrado.ext)",
    )
    parser.add_argument(
        "--chunk-size",
        type=parse_positive_int,
        default=maximum,
        help=f"bytes cifrados por bloque, multiplo de 8 (default: {maximum})",
    )
    parser.add_argument(
        "--output-size",
        type=parse_positive_int,
        help=(
            "bytes reales del archivo original; sirve para recortar padding TEA "
            "al final"
        ),
    )
    parser.add_argument(
        "--sim-command",
        help=(
            "comando para correr el testbench desde la raiz del repo; "
            "si se omite, el script prueba run.sh/make/iverilog automaticamente"
        ),
    )
    parser.add_argument(
        "--work-dir",
        default="arqui/outputs/chunks",
        help="carpeta temporal para partes cifradas y descifradas",
    )
    return parser


def repo_root_from_script() -> Path:
    return Path(__file__).resolve().parents[2]


def resolve_repo_path(repo_root: Path, value: str | None, default: Path) -> Path:
    if value is None:
        return default

    path = Path(value)
    if not path.is_absolute():
        path = repo_root / path
    return path.resolve()


def output_path_for_input(repo_root: Path, input_path: Path, output: str | None) -> Path:
    default = repo_root / "arqui" / "outputs" / prepare_teaimg.output_name_for_decrypt(input_path)
    return resolve_repo_path(repo_root, output, default)


def run_checked(command: list[str], cwd: Path) -> None:
    print("+ " + " ".join(command))
    subprocess.run(command, cwd=cwd, check=True)


def run_shell_checked(command: str, cwd: Path) -> None:
    print("+ " + command)
    subprocess.run(command, cwd=cwd, shell=True, check=True)


def simulation_candidates(repo_root: Path) -> list[tuple[list[str], Path]]:
    arqui_root = repo_root / "arqui"
    candidates: list[tuple[list[str], Path]] = []

    if os.name != "nt" and (repo_root / "run.sh").is_file():
        candidates.append((["bash", "run.sh", "run", "tb_teaimg_loader"], repo_root))

    if shutil.which("bash") and (repo_root / "run.sh").is_file():
        candidates.append((["bash", "run.sh", "run", "tb_teaimg_loader"], repo_root))

    if shutil.which("make"):
        candidates.append((["make", "run", "TOP=tb_teaimg_loader"], arqui_root))

    if shutil.which("iverilog") and shutil.which("vvp"):
        rtl_sources = sorted(str(path.relative_to(arqui_root)) for path in (arqui_root / "rtl").glob("*.sv"))
        candidates.append(
            (
                [
                    "iverilog",
                    "-g2012",
                    "-o",
                    "sim/build/tb_teaimg_loader.vvp",
                    *rtl_sources,
                    "tb/tb_teaimg_loader.sv",
                ],
                arqui_root,
            )
        )
        candidates.append((["vvp", "sim/build/tb_teaimg_loader.vvp"], arqui_root))

    return candidates


def run_simulation(repo_root: Path, sim_command: str | None) -> None:
    if sim_command:
        run_shell_checked(sim_command, repo_root)
        return

    candidates = simulation_candidates(repo_root)
    if not candidates:
        raise RuntimeError(
            "no encontre bash/run.sh, make ni iverilog+vvp; use --sim-command"
        )

    last_error: subprocess.CalledProcessError | None = None
    index = 0
    while index < len(candidates):
        command, cwd = candidates[index]

        try:
            if command[0] == "iverilog":
                (cwd / "sim" / "build").mkdir(parents=True, exist_ok=True)
                (cwd / "sim" / "waves").mkdir(parents=True, exist_ok=True)
                (cwd / "outputs").mkdir(parents=True, exist_ok=True)
                run_checked(command, cwd)
                if index + 1 >= len(candidates) or candidates[index + 1][0][0] != "vvp":
                    raise RuntimeError("falta candidato vvp despues de iverilog")
                run_checked(candidates[index + 1][0], candidates[index + 1][1])
                return

            if command[0] == "vvp":
                index += 1
                continue

            run_checked(command, cwd)
            return
        except subprocess.CalledProcessError as error:
            last_error = error
            index += 1

    if last_error is not None:
        raise RuntimeError(
            "no se pudo correr el testbench automaticamente; pruebe --sim-command"
        ) from last_error
    raise RuntimeError("no se pudo correr el testbench")


def write_chunk(input_path: Path, chunk_path: Path, offset: int, size: int) -> int:
    chunk_path.parent.mkdir(parents=True, exist_ok=True)
    with input_path.open("rb") as source:
        source.seek(offset)
        data = source.read(size)

    chunk_path.write_bytes(data)
    return len(data)


def prepare_chunk(repo_root: Path, chunk_path: Path, output_size: int) -> None:
    run_checked(
        [
            sys.executable,
            "arqui/scripts/prepare_teaimg.py",
            "--decrypt",
            "--input",
            str(chunk_path),
            "--output-size",
            str(output_size),
        ],
        repo_root,
    )


def extract_chunk(repo_root: Path, output_path: Path, output_size: int) -> None:
    run_checked(
        [
            sys.executable,
            "arqui/scripts/extract_data.py",
            "--memory",
            "arqui/outputs/teaimg_salida.hex",
            "--address",
            f"0x{IMAGE_BASE:04X}",
            "--size",
            str(output_size),
            "--output",
            str(output_path),
        ],
        repo_root,
    )


def append_file(source_path: Path, target_handle) -> None:
    with source_path.open("rb") as source:
        shutil.copyfileobj(source, target_handle)


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    repo_root = repo_root_from_script()

    input_path = resolve_repo_path(repo_root, args.input, Path(args.input))
    if not input_path.is_file():
        parser.error(f"no existe el archivo de entrada: {input_path}")

    input_size = input_path.stat().st_size
    if input_size == 0:
        parser.error("el archivo de entrada esta vacio")
    if input_size % 8 != 0:
        parser.error("el archivo cifrado debe tener tamano multiplo de 8 bytes")

    maximum = prepare_teaimg.max_image_bytes(MODE_DECRYPT)
    if args.chunk_size % 8 != 0:
        parser.error("--chunk-size debe ser multiplo de 8")
    if args.chunk_size > maximum:
        parser.error(f"--chunk-size excede el maximo actual de {maximum} bytes")
    if args.output_size is not None and args.output_size > input_size:
        parser.error("--output-size no puede ser mayor que el tamano cifrado")

    output_path = output_path_for_input(repo_root, input_path, args.output)
    work_dir = resolve_repo_path(repo_root, args.work_dir, repo_root / "arqui" / "outputs" / "chunks")
    encrypted_dir = work_dir / "encrypted"
    decrypted_dir = work_dir / "decrypted"
    encrypted_dir.mkdir(parents=True, exist_ok=True)
    decrypted_dir.mkdir(parents=True, exist_ok=True)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    chunks = math.ceil(input_size / args.chunk_size)
    final_size = args.output_size if args.output_size is not None else input_size

    print(f"Entrada cifrada: {input_path}")
    print(f"Salida final: {output_path}")
    print(f"Tamano cifrado: {input_size} bytes")
    print(f"Tamano a extraer: {final_size} bytes")
    print(f"Chunk size: {args.chunk_size} bytes")
    print(f"Bloques: {chunks}")

    bytes_remaining = final_size
    with output_path.open("wb") as final_output:
        for index in range(chunks):
            offset = index * args.chunk_size
            encrypted_size = min(args.chunk_size, input_size - offset)
            output_size = min(encrypted_size, bytes_remaining)
            chunk_name = f"{input_path.stem}.part{index:04d}.enc"
            encrypted_chunk = encrypted_dir / chunk_name
            decrypted_chunk = decrypted_dir / f"{input_path.stem}.part{index:04d}.bin"

            if output_size <= 0:
                break

            print("\n" + "=" * 60)
            print(f"Bloque {index + 1}/{chunks}")
            print(f"Offset cifrado: {offset}")
            print(f"Bytes cifrados: {encrypted_size}")
            print(f"Bytes a anexar: {output_size}")

            written = write_chunk(input_path, encrypted_chunk, offset, encrypted_size)
            if written != encrypted_size:
                raise RuntimeError(
                    f"lectura incompleta del bloque {index}: {written}/{encrypted_size}"
                )

            prepare_chunk(repo_root, encrypted_chunk, output_size)
            run_simulation(repo_root, args.sim_command)
            extract_chunk(repo_root, decrypted_chunk, output_size)
            append_file(decrypted_chunk, final_output)
            bytes_remaining -= output_size

    print("\nListo.")
    print(f"Bytes escritos: {output_path.stat().st_size}")
    print(f"Salida: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
