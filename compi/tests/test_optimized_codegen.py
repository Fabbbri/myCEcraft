from __future__ import annotations

import re
import sys
import unittest
from pathlib import Path


COMPI_ROOT = Path(__file__).resolve().parents[1]
if str(COMPI_ROOT) not in sys.path:
    sys.path.insert(0, str(COMPI_ROOT))

from codegen.binary import BinaryEncoder
from codegen.ir_assembly_generator import IRAssemblyGenerator
from codegen.resolver import LabelResolver
from IR.instructions import IRBinOp, IRCommit
from IR.ir_generator import IRGenerator
from lexer import Lexer
from Optimizations import AUTO_UNROLL_FACTOR, optimize_ir
from parser import Parser
from registers import GENERAL_REGISTERS, VAULT_REGISTERS
from semantic import SemanticAnalyzer


class OptimizedCodegenTests(unittest.TestCase):
    def _compile_optimized(
        self,
        source: str,
        *,
        unroll_factor: int = 1,
        dce: bool = False,
        reorder: bool = False,
        rename_static_registers: bool = False,
    ) -> tuple[str, bytes]:
        tokens = Lexer(source, filename="<test>").tokenize()
        program = Parser(tokens, filename="<test>").parse()
        symbols = SemanticAnalyzer(filename="<test>").analyze(program)
        instructions = IRGenerator().generate(program)
        instructions, _ = optimize_ir(
            instructions,
            unroll_factor=unroll_factor,
            rename_static_registers=rename_static_registers,
            eliminate_dead_code=dce,
            reorder_instructions=reorder,
        )
        assembly = IRAssemblyGenerator(symbols).generate(instructions)
        resolved = LabelResolver().resolve(assembly)
        binary = BinaryEncoder().encode(resolved.assembly).binary
        return assembly, binary

    def test_unrolled_while_keeps_remainder_and_encodes(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    x:int = 0;
    while (x < 5) {
        x = x + 1;
    }
    return x;
}
"""
        normal_assembly, normal_binary = self._compile_optimized(source)
        assembly, binary = self._compile_optimized(
            source,
            unroll_factor=AUTO_UNROLL_FACTOR,
        )

        self.assertTrue(binary)
        self.assertNotEqual(normal_assembly, assembly)
        self.assertNotEqual(normal_binary, binary)
        self.assertIn("addi", assembly)

    def test_manual_unroll_factor_can_exceed_register_count(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    x:int = 0;
    while (x < 20) {
        x = x + 1;
    }
    return x;
}
"""

        assembly, binary = self._compile_optimized(
            source,
            unroll_factor=10,
        )

        self.assertTrue(binary)
        self.assertIn("addi", assembly)

    def test_dce_uses_only_defined_craft21_registers(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    x:int = 1;
    dead:int = x * 99;
    live:int = x + 4;
    return live;
}
"""
        normal_assembly, normal_binary = self._compile_optimized(source)
        assembly, binary = self._compile_optimized(
            source,
            dce=True,
            reorder=True,
        )

        valid_registers = {
            register.name
            for register in [*GENERAL_REGISTERS, *VAULT_REGISTERS]
        }
        used_registers = set(re.findall(r"\b(?:x|v)\d+\b", assembly))

        self.assertTrue(binary)
        self.assertNotEqual(normal_assembly, assembly)
        self.assertLess(len(binary), len(normal_binary))
        self.assertNotIn("dead", assembly)
        self.assertLessEqual(used_registers, valid_registers)

    def test_instruction_reordering_changes_assembly_and_binary(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    values:chest[int, 1] = [5];
    loaded:int = values[0];
    dependent:int = loaded + 1;
    independent:int = 7 + 8;
    return dependent + independent;
}
"""

        normal_assembly, normal_binary = self._compile_optimized(source)
        reordered_assembly, reordered_binary = self._compile_optimized(
            source,
            reorder=True,
        )

        self.assertNotEqual(normal_assembly, reordered_assembly)
        self.assertNotEqual(normal_binary, reordered_binary)

    def test_static_register_renaming_changes_assembly_and_binary(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    first:int = 1 + 2;
    second:int = 3 + 4;
    return first + second;
}
"""

        normal_assembly, normal_binary = self._compile_optimized(source)
        renamed_assembly, renamed_binary = self._compile_optimized(
            source,
            rename_static_registers=True,
        )

        self.assertNotEqual(normal_assembly, renamed_assembly)
        self.assertNotEqual(normal_binary, renamed_binary)
        self.assertIn(
            "Las optimizaciones IR son la fuente del ejecutable",
            renamed_assembly,
        )
        self.assertRegex(renamed_assembly, r"\badd x(?:[4-9]|10),")

    def test_static_register_renaming_handles_computed_array_index(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    values:chest[int, 2] = [4, 9];
    index:int = 0;
    return values[index + 1];
}
"""

        assembly, binary = self._compile_optimized(
            source,
            rename_static_registers=True,
        )

        self.assertTrue(binary)
        self.assertIn("Las optimizaciones IR son la fuente del ejecutable", assembly)

    def test_static_register_renaming_versions_war_and_waw_writes(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    a:int = 1;
    first:int = a + 10;
    a = 2;
    second:int = a + 20;
    return first + second;
}
"""
        tokens = Lexer(source, filename="<test>").tokenize()
        program = Parser(tokens, filename="<test>").parse()
        symbols = SemanticAnalyzer(filename="<test>").analyze(program)
        instructions = IRGenerator().generate(program)
        optimized, stats = optimize_ir(
            instructions,
            unroll_factor=1,
            rename_static_registers=True,
            reorder_instructions=True,
        )

        a_versions = {
            instruction.result
            for instruction in optimized
            if hasattr(instruction, "result")
            and isinstance(instruction.result, str)
            and instruction.result.startswith("a__v")
        }
        a_reads = {
            operand
            for instruction in optimized
            if isinstance(instruction, IRBinOp)
            for operand in (instruction.left, instruction.right)
            if isinstance(operand, str) and operand.startswith("a__v")
        }
        commits = [
            instruction
            for instruction in optimized
            if isinstance(instruction, IRCommit) and instruction.result == "a"
        ]

        self.assertEqual(2, len(a_versions))
        self.assertEqual(a_versions, a_reads)
        self.assertTrue(commits)
        self.assertGreaterEqual(stats.static_registers_renamed, 2)

        assembly = IRAssemblyGenerator(symbols).generate(optimized)
        resolved = LabelResolver().resolve(assembly)
        binary = BinaryEncoder().encode(resolved.assembly).binary
        self.assertTrue(binary)
        self.assertRegex(assembly, r"a__v1__x(?:[3-9]|10)")
        self.assertRegex(assembly, r"a__v2__x(?:[3-9]|10)")


if __name__ == "__main__":
    unittest.main()
