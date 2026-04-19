from pathlib import Path
import sys

from lexer import Lexer, LexerError


def main() -> int:
    if len(sys.argv) != 2:
        print("Uso: python main.py <archivo.craft>")
        return 2

    input_path = Path(sys.argv[1])

    if input_path.suffix.lower() != ".craft":
        print(f"Error: el archivo '{input_path}' debe tener extension .craft")
        return 2

    if not input_path.is_file():
        print(f"Error: no se encontro el archivo '{input_path}'")
        return 2

    try:
        source_code = input_path.read_text(encoding="utf-8")
    except OSError as error:
        print(f"Error al leer el archivo '{input_path}': {error}")
        return 2

    try:
        lexer = Lexer(source_code, filename=str(input_path))
        tokens = lexer.tokenize()

        for token in tokens:
            print(token)
    except LexerError as error:
        print(error)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())