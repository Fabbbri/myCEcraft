from pathlib import Path
import sys

from ast_nodes import format_ast
from lexer import Lexer, LexerError
from parser import ParseError, Parser
from semantic import SemanticAnalyzer, SemanticError


def main() -> int:
    args = sys.argv[1:]

    show_tokens = False
    show_ast = False
    show_symbols = False
    input_file = None

    for arg in args:
        if arg in {"--tokens", "-l"}:
            show_tokens = True
        elif arg in {"--ast", "-t"}:
            show_ast = True
        elif arg in {"--symbols", "-m"}:
            show_symbols = True
        elif input_file is None:
            input_file = arg
        else:
            print(f"Error: argumento no reconocido '{arg}'")
            return 2

    if input_file is None:
        print("Uso: python main.py [--tokens] [-t|--ast] [-m|--symbols] <archivo.craft>")
        return 2

    input_path = Path(input_file)

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

        if show_tokens:
            for token in tokens:
                print(token)

        parser = Parser(tokens, filename=str(input_path))
        ast = parser.parse()

        if show_ast:
            print(format_ast(ast))

        semantic = SemanticAnalyzer(filename=str(input_path))
        symbol_table = semantic.analyze(ast)

        if show_symbols:
            print(symbol_table.dump())
        elif not show_tokens and not show_ast:
            print(f"Analisis semantico completado: {input_path}")
    except LexerError as error:
        print(error)
        return 1
    except ParseError as error:
        print(error)
        return 1
    except SemanticError as error:
        print(error)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
