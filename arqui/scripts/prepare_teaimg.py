#!/usr/bin/env python3
"""Prepare the TEA image demo for a concrete input image."""

from __future__ import annotations

import argparse
import mimetypes
import subprocess
import sys
from pathlib import Path


MEM_SIZE_BYTES = 64 * 1024
DATA_BASE = 0x8000
IMAGE_BASE = 0x8010
KEY_BYTES = 16
TAIL_BYTES = 20  # block[2] + DELTA + SUM_INIT + IMAGE_WORDS
AUTO_IMAGE_MAX_SIDE = 512
AUTO_IMAGE_MIN_SIDE = 32


def align_up(value: int, alignment: int) -> int:
    return ((value + alignment - 1) // alignment) * alignment


def align_down(value: int, alignment: int) -> int:
    return (value // alignment) * alignment


def max_image_bytes() -> int:
    usable = MEM_SIZE_BYTES - DATA_BASE - KEY_BYTES - TAIL_BYTES
    return align_down(usable // 3, 8)


def zero_initializer(words: int) -> str:
    lines: list[str] = []
    for start in range(0, words, 8):
        count = min(8, words - start)
        suffix = "," if start + count < words else ""
        lines.append("    " + ", ".join("0x0" for _ in range(count)) + suffix)
    return "\n".join(lines)


def teaimg_source(words: int) -> str:
    zeros = zero_initializer(words)
    return f"""@EnterCraftWorld
key:chest[uint32, 4] = [0x0, 0x1, 0x2, 0x3];

image_original:chest[uint32, {words}] = [
{zeros}
];

image_encrypted:chest[uint32, {words}] = [
{zeros}
];

image_decrypted:chest[uint32, {words}] = [
{zeros}
];

block:chest[uint32, 2] = [0x0, 0x0];
DELTA:uint32 = 0x9e3779b9;
SUM_INIT:uint32 = 0xc6ef3720;
IMAGE_WORDS:int = {words};

craft:void tea_encrypt(v:chest[uint32, 2], tea_key:chest[uint32, 4]) {{
    v0:uint32 = v[0];
    v1:uint32 = v[1];
    sum:uint32 = 0;

    for (i:int = 0; i < 32; i = i + 1) {{
        sum = sum + DELTA;

        left0:uint32 = v1 <+4 tea_key[0];
        mid0:uint32 = v1 + sum;
        right0:uint32 = v1 >+5 tea_key[1];
        v0 = v0 + (left0 ^ mid0 ^ right0);

        left1:uint32 = v0 <+4 tea_key[2];
        mid1:uint32 = v0 + sum;
        right1:uint32 = v0 >+5 tea_key[3];
        v1 = v1 + (left1 ^ mid1 ^ right1);
    }}

    v[0] = v0;
    v[1] = v1;
}}

craft:void tea_decrypt(v:chest[uint32, 2], tea_key:chest[uint32, 4]) {{
    v0:uint32 = v[0];
    v1:uint32 = v[1];
    sum:uint32 = SUM_INIT;

    for (i:int = 0; i < 32; i = i + 1) {{
        left1:uint32 = v0 <+4 tea_key[2];
        mid1:uint32 = v0 + sum;
        right1:uint32 = v0 >+5 tea_key[3];
        v1 = v1 - (left1 ^ mid1 ^ right1);

        left0:uint32 = v1 <+4 tea_key[0];
        mid0:uint32 = v1 + sum;
        right0:uint32 = v1 >+5 tea_key[1];
        v0 = v0 - (left0 ^ mid0 ^ right0);

        sum = sum - DELTA;
    }}

    v[0] = v0;
    v[1] = v1;
}}

craft:int main() {{
    for (offset:int = 0; offset < IMAGE_WORDS; offset = offset + 2) {{
        block[0] = image_original[offset];
        block[1] = image_original[offset + 1];

        summon:tea_encrypt(block, key);

        image_encrypted[offset] = block[0];
        image_encrypted[offset + 1] = block[1];
    }}

    for (offset2:int = 0; offset2 < IMAGE_WORDS; offset2 = offset2 + 2) {{
        block[0] = image_encrypted[offset2];
        block[1] = image_encrypted[offset2 + 1];

        summon:tea_decrypt(block, key);

        image_decrypted[offset2] = block[0];
        image_decrypted[offset2 + 1] = block[1];
    }}

    changed:int = 0;
    for (check:int = 0; check < IMAGE_WORDS; check = check + 1) {{
        if (image_decrypted[check] != image_original[check]) {{
            return 1;
        }}

        if (image_encrypted[check] != image_original[check]) {{
            changed = 1;
        }}
    }}

    if (changed == 0) {{
        return 2;
    }}

    return 0;
}}
"""


def write_config(path: Path, source_bytes: int, padded_bytes: int, words: int) -> None:
    path.write_text(
        "\n".join(
            [
                f"`define TEAIMG_IMAGE_BYTES {padded_bytes}",
                f"`define TEAIMG_SOURCE_BYTES {source_bytes}",
                f"`define TEAIMG_IMAGE_WORDS {words}",
                "",
            ]
        ),
        encoding="ascii",
        newline="\n",
    )


def run(command: list[str], cwd: Path) -> None:
    print("+ " + " ".join(command))
    subprocess.run(command, cwd=cwd, check=True)


def is_image_path(path: Path) -> bool:
    mime_type, _ = mimetypes.guess_type(path.name)
    return bool(mime_type and mime_type.startswith("image/"))


def save_image_candidate(image, output_path: Path, quality: int) -> None:
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


def auto_fit_image(input_path: Path, output_path: Path, max_bytes: int) -> Path:
    try:
        from PIL import Image
    except ImportError:
        raise RuntimeError(
            "la imagen no cabe y falta Pillow para reducirla automaticamente; "
            "instale con: python -m pip install pillow"
        )

    with Image.open(input_path) as source:
        source.load()
        side = min(AUTO_IMAGE_MAX_SIDE, max(source.size))
        best_size: int | None = None

        while side >= AUTO_IMAGE_MIN_SIDE:
            candidate = source.copy()
            candidate.thumbnail((side, side))

            qualities = [95, 85, 75, 65, 55, 45, 35, 25]
            if output_path.suffix.lower() == ".png":
                qualities = [95]

            for quality in qualities:
                save_image_candidate(candidate, output_path, quality)
                current_size = output_path.stat().st_size
                best_size = current_size

                if align_up(current_size, 8) <= max_bytes:
                    print("[AUTO] Imagen reducida para que quepa en RAM:")
                    print(f"       original : {input_path} ({input_path.stat().st_size} bytes)")
                    print(f"       reducida : {output_path} ({current_size} bytes)")
                    print(f"       resolucion final: {candidate.size[0]}x{candidate.size[1]}")
                    return output_path

            side = int(side * 0.85)

    raise RuntimeError(
        "no se pudo reducir la imagen hasta el tamano permitido; "
        f"mejor intento: {best_size} bytes, maximo: {max_bytes} bytes"
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Configura teaimg.craft y sus loaders para una imagen concreta."
    )
    parser.add_argument("--input", "-i", required=True, help="imagen a cifrar")
    parser.add_argument(
        "--no-auto-compress",
        action="store_true",
        help="si la imagen no cabe, fallar en vez de reducirla automaticamente",
    )
    parser.add_argument(
        "--skip-build",
        action="store_true",
        help="solo escribe teaimg.craft/config; no compila ni genera loaders",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    input_path = Path(args.input)
    if not input_path.is_absolute():
        input_path = (repo_root / input_path).resolve()

    if not input_path.is_file():
        print(f"Error: no existe la imagen: {input_path}", file=sys.stderr)
        return 2

    source_bytes = input_path.stat().st_size
    padded_bytes = align_up(source_bytes, 8)
    words = padded_bytes // 4
    maximum = max_image_bytes()

    if padded_bytes > maximum:
        if is_image_path(input_path) and not args.no_auto_compress:
            suffix = input_path.suffix.lower()
            output_suffix = suffix if suffix in {".jpg", ".jpeg", ".png"} else ".jpg"
            fitted_path = (
                repo_root
                / "arqui"
                / "outputs"
                / "prepared_inputs"
                / f"{input_path.stem}_teaimg_fit{output_suffix}"
            )
            try:
                input_path = auto_fit_image(input_path, fitted_path, maximum)
            except RuntimeError as error:
                print(f"Error: {error}", file=sys.stderr)
                return 1

            source_bytes = input_path.stat().st_size
            padded_bytes = align_up(source_bytes, 8)
            words = padded_bytes // 4
        else:
            print(
                "Error: la imagen/archivo no cabe con buffers original+cifrado+descifrado.",
                file=sys.stderr,
            )
            print(f"  bytes entrada       : {source_bytes}", file=sys.stderr)
            print(f"  bytes con padding   : {padded_bytes}", file=sys.stderr)
            print(f"  maximo actual       : {maximum}", file=sys.stderr)
            print(
                "Use una entrada mas pequena, aumente la RAM o use una imagen que pueda recomprimirse.",
                file=sys.stderr,
            )
            return 1

    if padded_bytes > maximum:
        print(
            "Error: la imagen/archivo no cabe con buffers original+cifrado+descifrado.",
            file=sys.stderr,
        )
        print(f"  bytes entrada       : {source_bytes}", file=sys.stderr)
        print(f"  bytes con padding   : {padded_bytes}", file=sys.stderr)
        print(f"  maximo actual       : {maximum}", file=sys.stderr)
        return 1

    craft_path = repo_root / "compi" / "ejemplos" / "teaimg.craft"
    config_path = repo_root / "arqui" / "tb" / "teaimg_config.svh"
    craft_path.write_text(teaimg_source(words), encoding="ascii", newline="\n")
    write_config(config_path, source_bytes, padded_bytes, words)

    output_suffix = input_path.suffix if input_path.suffix else ".bin"
    recovered_output = f"arqui/outputs/teaimg_recuperada{output_suffix}"

    print(f"Entrada usada: {input_path}")
    print(f"Bytes reales: {source_bytes}")
    print(f"Bytes TEA/padding: {padded_bytes}")
    print(f"IMAGE_WORDS: {words}")
    print(f"Maximo actual: {maximum} bytes")
    print(f"Craft generado: {craft_path}")
    print(f"Config TB: {config_path}")

    if args.skip_build:
        return 0

    run(
        [
            sys.executable,
            "compi/main.py",
            "--asm",
            "--resolve",
            "--binary",
            "compi/ejemplos/teaimg.craft",
        ],
        repo_root,
    )
    run(
        [
            sys.executable,
            "arqui/scripts/load_file.py",
            "--input",
            "compi/output/bin_output/teaimg.bin",
            "--output",
            "arqui/programs/teaimg_loader.hex",
            "--address",
            "0x0000",
        ],
        repo_root,
    )
    run(
        [
            sys.executable,
            "arqui/scripts/load_file.py",
            "--input",
            str(input_path),
            "--output",
            "arqui/programs/teaimg_input.hex",
            "--address",
            f"0x{IMAGE_BASE:04X}",
        ],
        repo_root,
    )

    print("\nSiguiente paso:")
    print("  ./run.sh run tb_teaimg_loader")
    print("\nExtraer datos descifrados:")
    print(
        "  python arqui/scripts/extract_data.py "
        "--memory arqui/outputs/teaimg_salida.hex "
        f"--address 0x{IMAGE_BASE + padded_bytes * 2:04X} "
        f"--size {source_bytes} "
        f"--output {recovered_output}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
