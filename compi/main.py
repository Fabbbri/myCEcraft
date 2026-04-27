from pathlib import Path
import sys

from ast_nodes import format_ast
from lexer import Lexer, LexerError
from parser import ParseError, Parser
from semantic import SemanticAnalyzer, SemanticError
from codegen.binary import BinaryEncoder, EncodingError
from codegen.generator import AssemblyGenerator
from codegen.errors import CodegenError
from codegen.resolver import LabelResolver, ResolutionError


def main() -> int:
    args = sys.argv[1:]

    show_tokens = False
    show_ast = False
    show_symbols = False
    show_asm = False
    show_resolved = False
    show_binary = False
    input_file = None
    output_file = None
    
    index = 0
    while index < len(args):
        arg = args[index]

        if arg in {"--tokens", "-l"}:
            show_tokens = True
        elif arg in {"--ast", "-t"}:
            show_ast = True
        elif arg in {"--asm", "-s"}:
            show_asm = True
        elif arg in {"--resolve", "-r"}:
            show_resolved = True
        elif arg in {"--binary", "-b"}:
            show_binary = True
        elif arg in {"--output", "-o"}:
            if index + 1 >= len(args):
                print("Error: -o requiere un archivo de salida")
                return 2
            output_file = args[index + 1]
            show_binary = True
            index += 1
        elif arg in {"--symbols", "-m"}:
            show_symbols = True
        elif input_file is None:
            input_file = arg
        else:
            print(f"Error: argumento no reconocido '{arg}'")
            return 2

        index += 1

    if input_file is None:
        print(
            "Uso: python main.py [--tokens] [-t|--ast] [-m|--symbols] "
            "[-s|--asm] [-r|--resolve] [-b|--binary] [-o archivo.bin] <archivo.craft>"
        )
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

        if show_asm or show_resolved or show_binary:
            generator = AssemblyGenerator(symbol_table)
            assembly_code = generator.generate(ast)

            asm_path = input_path.with_suffix(".asm")
            if show_asm or show_resolved:
                asm_path.write_text(assembly_code, encoding="utf-8")
                print(f"Ensamblador generado: {asm_path}")

            if show_resolved or show_binary:
                resolver = LabelResolver()
                resolved = resolver.resolve(assembly_code)

                resolved_path = input_path.with_suffix(".resolved.asm")
                if show_resolved:
                    resolved_path.write_text(resolved.assembly, encoding="utf-8")
                    print(f"Referencias resueltas: {resolved_path}")

                if show_binary:
                    encoder = BinaryEncoder()
                    binary = encoder.encode(resolved.assembly)

                    bin_path = Path(output_file) if output_file else input_path.with_suffix(".bin")
                    hex_path = bin_path.with_suffix(".hex")
                    data_hex_path = bin_path.with_name(f"{bin_path.stem}.data.hex")
                    listing_path = bin_path.with_suffix(".lst")

                    hex_path.write_text(binary.hex_text, encoding="utf-8")
                    bin_path.write_bytes(binary.binary)
                    listing_path.write_text(binary.listing_text, encoding="utf-8")

                    if binary.data_binary:
                        data_hex_path.write_text(binary.data_hex_text, encoding="utf-8")

                    print(f"Codigo hexadecimal de instrucciones generado: {hex_path}")
                    if binary.data_binary:
                        print(f"Codigo hexadecimal de datos generado: {data_hex_path}")
                    print(f"Codigo binario generado: {bin_path}")
                    print(f"Listado generado: {listing_path}")

        if show_symbols:
            print(symbol_table.dump())
        elif (
            not show_tokens
            and not show_ast
            and not show_asm
            and not show_resolved
            and not show_binary
        ):
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
    except CodegenError as error:
        print(error)
        return 1
    except ResolutionError as error:
        print(error)
        return 1
    except EncodingError as error:
        print(error)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
