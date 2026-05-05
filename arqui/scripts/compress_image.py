#!/usr/bin/env python3
"""Resize and recompress an image until it fits a target byte size."""

from __future__ import annotations

import argparse
from pathlib import Path


DEFAULT_MAX_BYTES = 10 * 1024


def parse_size(value: str) -> int:
    try:
        size = int(value, 0)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(f"tamano invalido: {value!r}") from exc

    if size <= 0:
        raise argparse.ArgumentTypeError("el tamano debe ser mayor que cero")
    return size


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Reduce una imagen bajando resolucion/calidad hasta que pese menos "
            "que el limite indicado. Pensado para preparar entradas de teaimg."
        )
    )
    parser.add_argument("--input", "-i", required=True, help="imagen de entrada")
    parser.add_argument("--output", "-o", required=True, help="imagen reducida de salida")
    parser.add_argument(
        "--max-bytes",
        "-m",
        type=parse_size,
        default=DEFAULT_MAX_BYTES,
        help="tamano maximo en bytes (default: 10240)",
    )
    parser.add_argument(
        "--max-side",
        type=int,
        default=512,
        help="lado maximo inicial antes de recomprimir (default: 512)",
    )
    parser.add_argument(
        "--min-side",
        type=int,
        default=32,
        help="lado minimo permitido durante reduccion (default: 32)",
    )
    return parser


def save_candidate(image, output_path: Path, quality: int) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)

    suffix = output_path.suffix.lower()
    if suffix in {".jpg", ".jpeg"}:
        if image.mode not in {"RGB", "L"}:
            image = image.convert("RGB")
        image.save(output_path, "JPEG", quality=quality, optimize=True)
        return

    if suffix == ".png":
        image.save(output_path, "PNG", optimize=True)
        return

    if image.mode not in {"RGB", "L"}:
        image = image.convert("RGB")
    image.save(output_path, "JPEG", quality=quality, optimize=True)


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    try:
        from PIL import Image
    except ImportError:
        parser.error("falta Pillow; instale con: python -m pip install pillow")

    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.is_file():
        parser.error(f"no existe la imagen de entrada: {input_path}")
    if args.max_side <= 0:
        parser.error("--max-side debe ser mayor que cero")
    if args.min_side <= 0:
        parser.error("--min-side debe ser mayor que cero")
    if args.min_side > args.max_side:
        parser.error("--min-side no puede ser mayor que --max-side")

    source_size = input_path.stat().st_size
    with Image.open(input_path) as source:
        source.load()
        original_width, original_height = source.size

        side = min(args.max_side, max(original_width, original_height))
        best_size: int | None = None

        while side >= args.min_side:
            candidate = source.copy()
            candidate.thumbnail((side, side))

            qualities = [95, 85, 75, 65, 55, 45, 35, 25]
            if output_path.suffix.lower() == ".png":
                qualities = [95]

            for quality in qualities:
                save_candidate(candidate, output_path, quality)
                current_size = output_path.stat().st_size
                best_size = current_size

                if current_size <= args.max_bytes:
                    print(f"Entrada: {input_path}")
                    print(f"Salida: {output_path}")
                    print(f"Tamano original: {source_size} bytes")
                    print(f"Tamano final: {current_size} bytes")
                    print(f"Resolucion original: {original_width}x{original_height}")
                    print(f"Resolucion final: {candidate.size[0]}x{candidate.size[1]}")
                    print(f"Calidad JPEG: {quality if output_path.suffix.lower() != '.png' else 'N/A'}")
                    return 0

            side = int(side * 0.85)

    parser.error(
        "no se pudo alcanzar el tamano objetivo; "
        f"mejor intento: {best_size} bytes, limite: {args.max_bytes} bytes"
    )
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
