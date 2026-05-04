#!/usr/bin/env python3
"""Extract a byte range from a Verilog memory dump into a binary file."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


MEM_SIZE_BYTES = 64 * 1024
HEX_TOKEN_RE = re.compile(r"^[0-9a-fA-F]+$")


def parse_address(value: str) -> int:
    try:
        address = int(value, 0)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(
            f"direccion invalida: {value!r}; use decimal o hexadecimal, ej. 0x2000"
        ) from exc

    if address < 0:
        raise argparse.ArgumentTypeError("la direccion no puede ser negativa")
    if address >= MEM_SIZE_BYTES:
        raise argparse.ArgumentTypeError(
            f"la direccion debe estar dentro de 64 KB (0x0000..0x{MEM_SIZE_BYTES - 1:04X})"
        )
    return address


def parse_size(value: str) -> int:
    try:
        size = int(value, 0)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(f"tamano invalido: {value!r}") from exc

    if size < 0:
        raise argparse.ArgumentTypeError("el tamano no puede ser negativo")
    return size


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Extrae bytes desde un dump Verilog .mem/.hex y los guarda como archivo binario."
        )
    )
    parser.add_argument("--memory", "-m", required=True, help="dump de memoria de entrada")
    parser.add_argument("--address", "-a", required=True, type=parse_address, help="direccion inicial")
    parser.add_argument("--size", "-s", required=True, type=parse_size, help="cantidad de bytes a extraer")
    parser.add_argument("--output", "-o", required=True, help="archivo binario de salida")
    return parser


def strip_comment(line: str) -> str:
    return line.split("//", 1)[0].split("#", 1)[0].strip()


def parse_memory_dump(memory_path: Path) -> dict[int, int]:
    memory: dict[int, int] = {}
    cursor = 0

    with memory_path.open("r", encoding="ascii", errors="ignore") as handle:
        for line_number, raw_line in enumerate(handle, start=1):
            line = strip_comment(raw_line)
            if not line:
                continue

            for token in line.replace(",", " ").split():
                if token.startswith("@"):
                    try:
                        cursor = int(token[1:], 16)
                    except ValueError as exc:
                        raise ValueError(
                            f"{memory_path}:{line_number}: directiva de direccion invalida: {token}"
                        ) from exc
                    continue

                normalized = token[2:] if token.lower().startswith("0x") else token
                if not HEX_TOKEN_RE.match(normalized):
                    raise ValueError(f"{memory_path}:{line_number}: token hexadecimal invalido: {token}")
                if len(normalized) % 2:
                    normalized = "0" + normalized

                raw_bytes = bytes.fromhex(normalized)
                if len(raw_bytes) == 1:
                    memory[cursor] = raw_bytes[0]
                    cursor += 1
                else:
                    for byte in reversed(raw_bytes):
                        memory[cursor] = byte
                        cursor += 1

    return memory


def extract(memory: dict[int, int], address: int, size: int) -> bytes:
    end_address = address + size
    if end_address > MEM_SIZE_BYTES:
        raise ValueError(
            f"el rango 0x{address:04X}..0x{end_address - 1:04X} excede la RAM de 64 KB"
        )

    missing = [addr for addr in range(address, end_address) if addr not in memory]
    if missing:
        first = missing[0]
        raise ValueError(
            f"el dump no contiene todos los bytes solicitados; falta 0x{first:04X}"
        )

    return bytes(memory[addr] for addr in range(address, end_address))


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    memory_path = Path(args.memory)
    output_path = Path(args.output)

    if not memory_path.is_file():
        parser.error(f"no existe el dump de memoria: {memory_path}")

    try:
        memory = parse_memory_dump(memory_path)
        data = extract(memory, args.address, args.size)
    except ValueError as exc:
        parser.error(str(exc))

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(data)

    end_address = args.address + args.size
    print(f"Dump: {memory_path}")
    print(f"Bytes extraidos: {len(data)}")
    print(f"Rango RAM: 0x{args.address:04X}..0x{end_address - 1:04X}" if data else "Rango RAM: vacio")
    print(f"Salida: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
