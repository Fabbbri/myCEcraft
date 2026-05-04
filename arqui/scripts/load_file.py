#!/usr/bin/env python3
"""Convert any input file into a Verilog $readmemh byte image."""

from __future__ import annotations

import argparse
import mimetypes
from pathlib import Path


MEM_SIZE_BYTES = 64 * 1024


def parse_address(value: str) -> int:
    try:
        address = int(value, 0)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(
            f"direccion invalida: {value!r}; use decimal o hexadecimal, ej. 0x1000"
        ) from exc

    if address < 0:
        raise argparse.ArgumentTypeError("la direccion inicial no puede ser negativa")
    if address >= MEM_SIZE_BYTES:
        raise argparse.ArgumentTypeError(
            f"la direccion inicial debe estar dentro de 64 KB (0x0000..0x{MEM_SIZE_BYTES - 1:04X})"
        )
    return address


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Carga un archivo de cualquier formato a una imagen de memoria "
            "compatible con $readmemh. Cada linea generada representa un byte."
        )
    )
    parser.add_argument("--input", "-i", required=True, help="archivo de entrada")
    parser.add_argument("--output", "-o", required=True, help="archivo .mem/.hex de salida")
    parser.add_argument(
        "--address",
        "-a",
        required=True,
        type=parse_address,
        help="direccion inicial en RAM, por ejemplo 0x1000",
    )
    parser.add_argument(
        "--bytes-per-line",
        type=int,
        default=16,
        help="cantidad de bytes comentados por bloque visual (default: 16)",
    )
    return parser


def write_mem_image(data: bytes, output_path: Path, address: int, bytes_per_line: int) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open("w", encoding="ascii", newline="\n") as handle:
        handle.write("// Archivo generado por arqui/scripts/load_file.py\n")
        handle.write(f"// Direccion inicial: 0x{address:04X}\n")
        handle.write(f"// Tamano: {len(data)} bytes\n")
        handle.write(f"@{address:04X}\n")

        for offset, byte in enumerate(data):
            if bytes_per_line > 0 and offset and offset % bytes_per_line == 0:
                handle.write(f"// +0x{offset:04X}\n")
            handle.write(f"{byte:02X}\n")


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    if args.bytes_per_line <= 0:
        parser.error("--bytes-per-line debe ser mayor que cero")
    if not input_path.is_file():
        parser.error(f"no existe el archivo de entrada: {input_path}")

    data = input_path.read_bytes()
    end_address = args.address + len(data)
    if end_address > MEM_SIZE_BYTES:
        parser.error(
            "el archivo no cabe en la RAM de 64 KB: "
            f"0x{args.address:04X} + {len(data)} bytes excede 0x{MEM_SIZE_BYTES:04X}"
        )

    write_mem_image(data, output_path, args.address, args.bytes_per_line)

    mime_type, _ = mimetypes.guess_type(input_path.name)
    print(f"Archivo: {input_path}")
    print(f"Tipo detectado: {mime_type or 'application/octet-stream'}")
    print(f"Bytes cargados: {len(data)}")
    print(f"Rango RAM: 0x{args.address:04X}..0x{end_address - 1:04X}" if data else "Rango RAM: vacio")
    print(f"Salida: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
