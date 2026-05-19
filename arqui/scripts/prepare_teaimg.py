#!/usr/bin/env python3
"""Prepare the TEA image demo for a concrete input file."""

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
MODE_ROUNDTRIP = "roundtrip"
MODE_DECRYPT = "decrypt"


def align_up(value: int, alignment: int) -> int:
    return ((value + alignment - 1) // alignment) * alignment


def align_down(value: int, alignment: int) -> int:
    return (value // alignment) * alignment


def buffer_count_for_mode(mode: str) -> int:
    if mode == MODE_DECRYPT:
        return 1
    return 3


def max_image_bytes(mode: str) -> int:
    usable = MEM_SIZE_BYTES - DATA_BASE - KEY_BYTES - TAIL_BYTES
    return align_down(usable // buffer_count_for_mode(mode), 8)


def zero_initializer(words: int) -> str:
    lines: list[str] = []
    for start in range(0, words, 8):
        count = min(8, words - start)
        suffix = "," if start + count < words else ""
        lines.append("    " + ", ".join("0x0" for _ in range(count)) + suffix)
    return "\n".join(lines)


def tea_functions_source(words: int) -> str:
    return f"""block:chest[uint32, 2] = [0x0, 0x0];
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
"""


def teaimg_roundtrip_source(words: int) -> str:
    zeros = zero_initializer(words)
    return f"""@EnterCraftWorld
key:chest[uint32, 4] = [0xdeadbeef, 0xdeadbeef, 0xdeadbeef, 0xdeadbeef];

image_original:chest[uint32, {words}] = [
{zeros}
];

image_encrypted:chest[uint32, {words}] = [
{zeros}
];

image_decrypted:chest[uint32, {words}] = [
{zeros}
];

{tea_functions_source(words)}

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


def teaimg_decrypt_source(words: int) -> str:
    zeros = zero_initializer(words)
    return f"""@EnterCraftWorld
key:chest[uint32, 4] = [0xfaceb00c, 0xbabef00d, 0xabadcafe, 0x0ddc0ded];

image_data:chest[uint32, {words}] = [
{zeros}
];

{tea_functions_source(words)}

craft:int main() {{
    for (offset:int = 0; offset < IMAGE_WORDS; offset = offset + 2) {{
        block[0] = image_data[offset];
        block[1] = image_data[offset + 1];

        summon:tea_decrypt(block, key);

        image_data[offset] = block[0];
        image_data[offset + 1] = block[1];
    }}

    return 0;
}}
"""


def teaimg_source(words: int, mode: str) -> str:
    if mode == MODE_DECRYPT:
        return teaimg_decrypt_source(words)
    return teaimg_roundtrip_source(words)


def write_config(path: Path, source_bytes: int, padded_bytes: int, words: int, mode: str) -> None:
    path.write_text(
        "\n".join(
            [
                f"`define TEAIMG_IMAGE_BYTES {padded_bytes}",
                f"`define TEAIMG_SOURCE_BYTES {source_bytes}",
                f"`define TEAIMG_IMAGE_WORDS {words}",
                f"`define TEAIMG_BUFFER_COUNT {buffer_count_for_mode(mode)}",
                f"`define TEAIMG_DECRYPT_ONLY {1 if mode == MODE_DECRYPT else 0}",
                f'`define TEAIMG_MODE "{mode}"',
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
        description="Configura teaimg.craft y sus loaders para un archivo concreto."
    )
    parser.add_argument("--input", "-i", required=True, help="archivo de entrada")
    parser.add_argument(
        "--mode",
        choices=[MODE_ROUNDTRIP, MODE_DECRYPT],
        default=MODE_ROUNDTRIP,
        help=(
            "roundtrip cifra y descifra la entrada; decrypt solo descifra la entrada "
            "asumiendo que ya viene cifrada con TEA"
        ),
    )
    parser.add_argument(
        "--decrypt",
        action="store_true",
        help="atajo de --mode decrypt",
    )
    parser.add_argument(
        "--output-size",
        type=int,
        help=(
            "bytes reales a extraer al final en modo decrypt; si se omite, "
            "usa el tamano del .enc"
        ),
    )
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


def output_name_for_decrypt(input_path: Path) -> str:
    if input_path.suffix.lower() != ".enc":
        return f"{input_path.stem}_descifrado{input_path.suffix or '.bin'}"

    original_name = input_path.with_suffix("")
    suffix = original_name.suffix or ".bin"
    stem = original_name.stem if original_name.suffix else original_name.name
    return f"{stem}_descifrado{suffix}"


def main() -> int:
    args = build_parser().parse_args()
    mode = MODE_DECRYPT if args.decrypt else args.mode
    if args.output_size is not None and args.output_size < 0:
        print("Error: --output-size no puede ser negativo", file=sys.stderr)
        return 2

    repo_root = Path(__file__).resolve().parents[2]
    input_path = Path(args.input)
    if not input_path.is_absolute():
        input_path = (repo_root / input_path).resolve()

    if not input_path.is_file():
        print(f"Error: no existe el archivo: {input_path}", file=sys.stderr)
        return 2

    source_bytes = input_path.stat().st_size
    if mode == MODE_DECRYPT and args.output_size is not None and args.output_size > source_bytes:
        print(
            "Error: --output-size no puede ser mayor que el tamano de entrada.",
            file=sys.stderr,
        )
        print(f"  output-size : {args.output_size}", file=sys.stderr)
        print(f"  bytes entrada: {source_bytes}", file=sys.stderr)
        return 2

    if mode == MODE_DECRYPT and source_bytes % 8 != 0:
        print(
            "Error: un archivo cifrado con TEA debe tener tamano multiplo de 8 bytes.",
            file=sys.stderr,
        )
        print(f"  bytes entrada: {source_bytes}", file=sys.stderr)
        return 1

    padded_bytes = align_up(source_bytes, 8)
    words = padded_bytes // 4
    maximum = max_image_bytes(mode)

    if padded_bytes > maximum:
        if mode == MODE_ROUNDTRIP and is_image_path(input_path) and not args.no_auto_compress:
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
            buffer_note = (
                "buffer unico descifrado-en-sitio"
                if mode == MODE_DECRYPT
                else "buffers original+cifrado+descifrado"
            )
            print(
                f"Error: el archivo no cabe con {buffer_note}.",
                file=sys.stderr,
            )
            print(f"  bytes entrada       : {source_bytes}", file=sys.stderr)
            print(f"  bytes con padding   : {padded_bytes}", file=sys.stderr)
            print(f"  maximo actual       : {maximum}", file=sys.stderr)
            print(
                "Use una entrada mas pequena o aumente la RAM.",
                file=sys.stderr,
            )
            return 1

    if padded_bytes > maximum:
        buffer_note = (
            "buffer unico descifrado-en-sitio"
            if mode == MODE_DECRYPT
            else "buffers original+cifrado+descifrado"
        )
        print(
            f"Error: el archivo no cabe con {buffer_note}.",
            file=sys.stderr,
        )
        print(f"  bytes entrada       : {source_bytes}", file=sys.stderr)
        print(f"  bytes con padding   : {padded_bytes}", file=sys.stderr)
        print(f"  maximo actual       : {maximum}", file=sys.stderr)
        return 1

    craft_path = repo_root / "compi" / "ejemplos" / "teaimg.craft"
    config_path = repo_root / "arqui" / "tb" / "teaimg_config.svh"
    craft_path.write_text(teaimg_source(words, mode), encoding="ascii", newline="\n")
    write_config(config_path, source_bytes, padded_bytes, words, mode)

    if mode == MODE_DECRYPT:
        extracted_size = args.output_size if args.output_size is not None else source_bytes
        output_address = IMAGE_BASE
        recovered_output = f"arqui/outputs/{output_name_for_decrypt(input_path)}"
    else:
        extracted_size = source_bytes
        output_address = IMAGE_BASE + padded_bytes * 2
        output_suffix = input_path.suffix if input_path.suffix else ".bin"
        recovered_output = f"arqui/outputs/teaimg_recuperada{output_suffix}"

    print(f"Entrada usada: {input_path}")
    print(f"Modo: {mode}")
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
        f"--address 0x{output_address:04X} "
        f"--size {extracted_size} "
        f"--output {recovered_output}"
    )
    if mode == MODE_DECRYPT and args.output_size is None:
        print(
            "  Nota: si el original tenia padding al cifrarse, ajuste --size "
            "o vuelva a preparar con --output-size BYTES_ORIGINALES."
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
