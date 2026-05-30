from pathlib import Path
import sys
import re

from ast_nodes import format_ast
from lexer import Lexer, LexerError
from parser import ParseError, Parser
from semantic import SemanticAnalyzer, SemanticError
from codegen.binary import BinaryEncoder, EncodingError
from codegen.generator import AssemblyGenerator
from codegen.errors import CodegenError
from codegen.resolver import LabelResolver, ResolutionError
from IR.ir_generator import IRGenerator
from IR.basic_blocks import ControlFlowGraph
from IR.craft_preview import write_optimized_craft_preview
from Optimizations import (
    AUTO_UNROLL_FACTOR,
    IROptimizationError,
    MAX_AUTO_UNROLL_FACTOR,
    optimize_ir,
)

DEFAULT_OUTPUT_DIR = Path(__file__).resolve().parent / "output"
DEFAULT_IR_DIR = DEFAULT_OUTPUT_DIR / "ir"
DEFAULT_ASM_DIR = DEFAULT_OUTPUT_DIR / "asm_unresolved"
DEFAULT_ASM_RESOLVED_DIR = DEFAULT_OUTPUT_DIR / "asm_resolved"
DEFAULT_BIN_HEX_DIR = DEFAULT_OUTPUT_DIR / "bin_output"
DEFAULT_AST_DIR = DEFAULT_OUTPUT_DIR / "ast"
DEFAULT_SYMBOLS_DIR = DEFAULT_OUTPUT_DIR / "symbols"
DEFAULT_OPTIMIZED_DIR = DEFAULT_OUTPUT_DIR / "optimized"
EXPANDED_OUTPUT_DIR = DEFAULT_OUTPUT_DIR / "expanded"

INVOKE_PATTERN = re.compile(
    r"^\s*invoke\s+\"([^\"]+)\"\s+as\s+[A-Za-z_][A-Za-z0-9_]*\s*;\s*$",
    re.MULTILINE,
)
ENTER_PRAGMA_PATTERN = re.compile(r"^\s*@EnterCraftWorld\b.*(?:\r?\n)?", re.MULTILINE)


def _strip_enter_pragma(content: str) -> str:
    return ENTER_PRAGMA_PATTERN.sub("", content)


def _write_text_artifact(path: Path, text: str, *, encoding: str = "utf-8") -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    candidates = [path]
    candidates.extend(
        path.with_name(f"{path.stem}.new{index if index else ''}{path.suffix}")
        for index in range(3)
    )

    last_error: PermissionError | None = None
    for candidate in candidates:
        try:
            candidate.write_text(text, encoding=encoding)
            return candidate
        except PermissionError as error:
            last_error = error

    if last_error is not None:
        raise last_error
    return path


def _expand_invokes(source_code: str, input_path: Path) -> tuple[str, Path | None]:
    def resolve_module_path(module_name: str, base_path: Path) -> Path:
        module_path = Path(module_name)
        if module_path.suffix == "":
            module_path = module_path.with_suffix(".craft")

        if not module_path.is_absolute():
            module_path = (base_path.parent / module_path).resolve()

        return module_path

    def expand_source(
        content: str,
        base_path: Path,
        visited: set[Path],
        aliases: list[str],
    ) -> str:
        matches = list(INVOKE_PATTERN.finditer(content))
        if not matches:
            return _strip_enter_pragma(content).rstrip()

        expanded_parts: list[str] = []

        for match in matches:
            module_name = match.group(1)
            alias_match = re.search(r"\bas\s+([A-Za-z_][A-Za-z0-9_]*)", match.group(0))
            if alias_match:
                aliases.append(alias_match.group(1))

            module_path = resolve_module_path(module_name, base_path)

            if module_path in visited:
                continue

            if not module_path.is_file():
                raise FileNotFoundError(
                    f"no se encontro el archivo importado '{module_path}'"
                )

            try:
                module_content = module_path.read_text(encoding="utf-8")
            except OSError as error:
                raise OSError(
                    f"no se pudo leer el archivo importado '{module_path}': {error}"
                ) from error

            visited.add(module_path)
            expanded_parts.append(f"// --- import: {module_path} ---")
            expanded_nested = expand_source(module_content, module_path, visited, aliases)
            if expanded_nested:
                expanded_parts.append(expanded_nested)
            expanded_parts.append("// --- fin import ---")
            expanded_parts.append("")

        source_without_invokes = INVOKE_PATTERN.sub("", content).rstrip()
        expanded_parts.append(_strip_enter_pragma(source_without_invokes).rstrip())

        return "\n".join(part for part in expanded_parts if part != "")

    aliases: list[str] = []
    has_enter = bool(ENTER_PRAGMA_PATTERN.search(source_code))
    expanded_source = expand_source(source_code, input_path, {input_path.resolve()}, aliases)
    if expanded_source == _strip_enter_pragma(source_code).rstrip():
        return source_code, None

    if has_enter:
        expanded_source = f"@EnterCraftWorld\n{expanded_source}"

    expanded_source = expanded_source.rstrip() + "\n"

    for alias in aliases:
        expanded_source = re.sub(
            rf"\bsummon\s*:\s*{re.escape(alias)}\s*\.\s*",
            "summon:",
            expanded_source,
        )

    EXPANDED_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    expanded_path = EXPANDED_OUTPUT_DIR / f"{input_path.stem}.expanded.craft"
    expanded_path.write_text(expanded_source, encoding="utf-8")

    return expanded_source, expanded_path

def _apply_resolved_text_addresses(symbol_table, labels: dict[str, int]) -> None:
    """
    Aplica direcciones del .text ya resueltas (fase 5) sobre la tabla de símbolos.

    Nota: hoy el codegen genera varias labels internas propias (prefijo .L_codegen_)
    que no necesariamente existen como símbolos semánticos. Aun así, las funciones
    sí aparecen como labels (por ejemplo, 'main:'), así que se pueden marcar como
    resueltas aquí.
    """

    for scope in symbol_table.all_scopes:
        for symbol in scope.symbols.values():
            address = labels.get(symbol.name)
            if address is None:
                continue

            if symbol.kind.name not in {"FUNCTION", "LABEL"}:
                continue

            symbol.memory_info.segment = "TEXT"
            symbol.memory_info.address = address
            symbol.memory_info.offset = None
            symbol.memory_info.size_in_bytes = symbol.memory_info.size_in_bytes or 0
            symbol.memory_info.resolved = True



def main() -> int:
    args = sys.argv[1:]

    show_tokens = False
    show_ast = False
    show_ir = False
    show_symbols = False
    show_asm = False
    show_resolved = False
    show_binary = False
    optimize = False
    optimization_level = 0
    rename_static_registers = False
    eliminate_dead_code = False
    reorder_instructions = False
    unroll_factor = 1
    input_file = None
    output_file = None
    
    index = 0
    while index < len(args):
        arg = args[index]

        if arg in {"--tokens", "-l"}:
            show_tokens = True
        elif arg in {"--ast", "-t"}:
            show_ast = True
        elif arg in {"--ir", "-i"}:
            show_ir = True
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
        elif arg in {"--optimize", "-O", "-O1"}:
            optimize = True
            optimization_level = max(optimization_level, 1)
            rename_static_registers = True
            if unroll_factor <= 1:
                unroll_factor = AUTO_UNROLL_FACTOR
        elif arg == "-O0":
            optimize = False
            optimization_level = 0
            rename_static_registers = False
            eliminate_dead_code = False
            reorder_instructions = False
            unroll_factor = 1
        elif arg == "-O2":
            optimize = True
            optimization_level = 2
            rename_static_registers = False
            eliminate_dead_code = True
            reorder_instructions = True
        elif arg == "-O3":
            optimize = True
            optimization_level = 3
            rename_static_registers = True
            eliminate_dead_code = True
            reorder_instructions = True
            if unroll_factor <= 1:
                unroll_factor = AUTO_UNROLL_FACTOR
        elif arg == "--rename-registers":
            rename_static_registers = True
            optimization_level = max(optimization_level, 1)
        elif arg == "--dce":
            optimize = True
            eliminate_dead_code = True
            optimization_level = max(optimization_level, 2)
        elif arg == "--reorder":
            optimize = True
            reorder_instructions = True
            optimization_level = max(optimization_level, 2)
        elif arg == "--unroll-factor":
            if index + 1 >= len(args):
                print("Error: --unroll-factor requiere un numero entero")
                return 2
            try:
                unroll_factor = int(args[index + 1])
            except ValueError:
                print("Error: --unroll-factor requiere un numero entero")
                return 2
            if unroll_factor < 1:
                print("Error: --unroll-factor debe ser mayor o igual a 1")
                return 2
            if unroll_factor > MAX_AUTO_UNROLL_FACTOR:
                print(
                    "Error: --unroll-factor no puede ser mayor que "
                    f"{MAX_AUTO_UNROLL_FACTOR} para la arquitectura Craft21"
                )
                return 2
            optimize = True
            optimization_level = max(optimization_level, 1)
            index += 1
        elif input_file is None:
            input_file = arg
        else:
            print(f"Error: argumento no reconocido '{arg}'")
            return 2

        index += 1

    if input_file is None:
        print(
            "Uso: python main.py [--tokens] [-t|--ast] [-i|--ir] [-m|--symbols] "
            "[-s|--asm] [-r|--resolve] [-b|--binary] [-o archivo.bin] "
            "[-O0|-O1|-O2|-O3] [--unroll-factor N] [--rename-registers] [--dce] [--reorder] <archivo.craft>"
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
        source_code, expanded_path = _expand_invokes(source_code, input_path)
    except (FileNotFoundError, OSError) as error:
        print(f"Error: {error}")
        return 2

    if expanded_path is not None:
        print(f"Archivo con imports expandido: {expanded_path}")
        input_path = expanded_path

    try:
        lexer = Lexer(source_code, filename=str(input_path))
        tokens = lexer.tokenize()

        if show_tokens:
            for token in tokens:
                print(token)

        parser = Parser(tokens, filename=str(input_path))
        ast = parser.parse()

        if show_ast:
            DEFAULT_AST_DIR.mkdir(parents=True, exist_ok=True)
            ast_path = DEFAULT_AST_DIR / f"{input_path.stem}.ast.txt"
            ast_path = _write_text_artifact(ast_path, format_ast(ast) + "\n")
            print(f"AST generado: {ast_path}")

        semantic = SemanticAnalyzer(filename=str(input_path))
        symbol_table = semantic.analyze(ast)

        if show_ir:
            ir_gen = IRGenerator()
            ir_instructions = ir_gen.generate(ast)
            if (
                optimize
                or unroll_factor > 1
                or rename_static_registers
                or eliminate_dead_code
                or reorder_instructions
            ):
                ir_instructions, optimization_stats = optimize_ir(
                    ir_instructions,
                    unroll_factor=unroll_factor,
                    rename_static_registers=rename_static_registers,
                    eliminate_dead_code=eliminate_dead_code,
                    reorder_instructions=reorder_instructions,
                )
                print(f"-O{optimization_level}: {optimization_stats.summary()}")
                if unroll_factor != 1:
                    preview_path = DEFAULT_OPTIMIZED_DIR / f"{input_path.stem}.O{optimization_level}.craft"
                    written_preview = write_optimized_craft_preview(
                        ast,
                        preview_path,
                        unroll_factor=unroll_factor,
                    )
                    if written_preview is not None:
                        print(f"Vista .craft optimizada generada: {written_preview}")
            DEFAULT_IR_DIR.mkdir(parents=True, exist_ok=True)
            ir_path = DEFAULT_IR_DIR / f"{input_path.stem}.ir.txt"
            
            lines = []
            for instr in ir_instructions:
                name = type(instr).__name__
                if name == "IRLabel":
                    lines.append(f"{instr.name}:")
                elif name == "IRJump":
                    lines.append(f"  goto {instr.label}")
                elif name == "IRJumpIfFalse":
                    lines.append(f"  ifFalse {instr.condition} goto {instr.label}")
                elif name == "IRBinOp":
                    lines.append(f"  {instr.result} = {instr.left} {instr.op} {instr.right}")
                elif name == "IRUnaryOp":
                    lines.append(f"  {instr.result} = {instr.op}{instr.operand}")
                elif name == "IRAssign":
                    lines.append(f"  {instr.result} = {instr.source}")
                elif name == "IRCall":
                    args_str = ", ".join(instr.args)
                    if instr.result:
                        lines.append(f"  {instr.result} = call {instr.func_name}({args_str})")
                    else:
                        lines.append(f"  call {instr.func_name}({args_str})")
                elif name == "IRVaultInstruction":
                    operands = ", ".join(instr.operands)
                    suffix = f" {operands}" if operands else ""
                    lines.append(f"  vault {instr.keyword}{suffix}")
                elif name == "IRReturn":
                    lines.append(f"  return {instr.value}")
                else:
                    lines.append(f"  {instr}")
                    
            # Análisis de Bloques Básicos
            cfg = ControlFlowGraph()
            cfg.build_from_ir(ir_instructions)
            lines.append("\n" + cfg.print_blocks())

            ir_path = _write_text_artifact(ir_path, "\n".join(lines) + "\n")
            print(f"Representación Intermedia (IR) generada: {ir_path}")

        if show_asm or show_resolved or show_binary:
            asm_dir = DEFAULT_ASM_DIR
            asm_resolved_dir = DEFAULT_ASM_RESOLVED_DIR
            bin_hex_dir = DEFAULT_BIN_HEX_DIR

            asm_dir.mkdir(parents=True, exist_ok=True)
            asm_resolved_dir.mkdir(parents=True, exist_ok=True)
            bin_hex_dir.mkdir(parents=True, exist_ok=True)

            generator = AssemblyGenerator(symbol_table)
            assembly_code = generator.generate(ast)

            asm_path = asm_dir / f"{input_path.stem}.asm"
            if show_asm or show_resolved:
                asm_path = _write_text_artifact(asm_path, assembly_code)
                print(f"Ensamblador generado: {asm_path}")

            if show_resolved or show_binary:
                resolver = LabelResolver()
                resolved = resolver.resolve(assembly_code)

                if show_symbols:
                    _apply_resolved_text_addresses(symbol_table, resolved.labels)

                resolved_path = asm_resolved_dir / f"{input_path.stem}.resolved.asm"
                if show_resolved:
                    resolved_path = _write_text_artifact(resolved_path, resolved.assembly)
                    print(f"Referencias resueltas: {resolved_path}")

                if show_binary:
                    encoder = BinaryEncoder()
                    binary = encoder.encode(resolved.assembly)

                    bin_path = bin_hex_dir / f"{input_path.stem}.bin"
                    bin_path.parent.mkdir(parents=True, exist_ok=True)
                    hex_path = bin_path.with_suffix(".hex")
                    data_hex_path = bin_path.with_name(f"{bin_path.stem}.data.hex")
                    listing_path = bin_path.with_suffix(".lst")

                    hex_path = _write_text_artifact(hex_path, binary.hex_text)
                    bin_path.write_bytes(binary.binary)
                    listing_path = _write_text_artifact(listing_path, binary.listing_text)

                    if binary.data_binary:
                        data_hex_path = _write_text_artifact(data_hex_path, binary.data_hex_text)

                    print(f"Codigo hexadecimal de instrucciones generado: {hex_path}")
                    if binary.data_binary:
                        print(f"Codigo hexadecimal de datos generado: {data_hex_path}")
                    print(f"Codigo binario generado: {bin_path}")
                    print(f"Listado generado: {listing_path}")

        if show_symbols:
            DEFAULT_SYMBOLS_DIR.mkdir(parents=True, exist_ok=True)
            symbol_sections: list[str] = []

            if show_resolved:
                symbol_sections.append("=== Labels resueltas (.text) ===")
                symbol_sections.extend(
                    f"{label:28} pc=0x{pc:04X}"
                    for label, pc in sorted(resolved.labels.items(), key=lambda item: item[1])
                )
                symbol_sections.append("")

            symbol_sections.append(symbol_table.dump())

            symbols_path = DEFAULT_SYMBOLS_DIR / f"{input_path.stem}.symbols.txt"
            symbols_path = _write_text_artifact(symbols_path, "\n".join(symbol_sections) + "\n")
            print(f"Tabla de simbolos generada: {symbols_path}")
        elif (
            not show_tokens
            and not show_ast
            and not show_ir
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
    except IROptimizationError as error:
        print(f"Error de optimizacion: {error}")
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
