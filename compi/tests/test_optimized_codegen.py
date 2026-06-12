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
from IR.instructions import IRAssign, IRBinOp
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

    def test_static_register_renaming_hints_temporaries_without_versioning_variables(
        self,
    ) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    first:int = 1 + 2;
    second:int = 3 + 4;
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
        )

        defined_names = {
            instruction.result
            for instruction in optimized
            if hasattr(instruction, "result")
            and isinstance(instruction.result, str)
        }
        self.assertTrue(any(re.fullmatch(r"t\d+__x\d+", name) for name in defined_names))
        self.assertFalse(any("__v" in name for name in defined_names))
        self.assertGreater(stats.static_registers_renamed, 0)

        assembly = IRAssemblyGenerator(symbols).generate(optimized)
        resolved = LabelResolver().resolve(assembly)
        binary = BinaryEncoder().encode(resolved.assembly).binary
        self.assertTrue(binary)
        self.assertIn(
            "Las optimizaciones IR son la fuente del ejecutable",
            assembly,
        )
        self.assertRegex(assembly, r"\badd x(?:[3-9]|10),")

    def test_static_register_renaming_handles_computed_array_index(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    values:chest[int, 2] = [4, 9];
    index:int = 0;
    values[index + 1] = values[index + 1] + 1;
    return values[index + 1];
}
"""

        assembly, binary = self._compile_optimized(
            source,
            rename_static_registers=True,
        )

        self.assertTrue(binary)
        self.assertIn("Las optimizaciones IR son la fuente del ejecutable", assembly)

    def test_static_register_renaming_preserves_war_and_waw_names(self) -> None:
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

        writes = [
            instruction
            for instruction in optimized
            if isinstance(instruction, IRAssign) and instruction.result == "a"
        ]
        reads = [
            operand
            for instruction in optimized
            if isinstance(instruction, IRBinOp)
            for operand in (instruction.left, instruction.right)
            if operand == "a"
        ]

        self.assertEqual(2, len(writes))
        self.assertEqual(2, len(reads))
        self.assertFalse(
            any(
                "__v" in value
                for instruction in optimized
                for value in vars(instruction).values()
                if isinstance(value, str)
            )
        )
        self.assertGreaterEqual(stats.static_registers_renamed, 2)

        assembly = IRAssemblyGenerator(symbols).generate(optimized)
        resolved = LabelResolver().resolve(assembly)
        binary = BinaryEncoder().encode(resolved.assembly).binary
        self.assertTrue(binary)

    def test_dce_removes_loop_carried_dead_recurrence(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    i:int = 0;
    total:int = 0;
    dead:int = 7;
    while (i < 8) {
        total = total + i;
        dead = dead * 3 + i;
        i = i + 1;
    }
    return total;
}
"""
        tokens = Lexer(source, filename="<test>").tokenize()
        program = Parser(tokens, filename="<test>").parse()
        SemanticAnalyzer(filename="<test>").analyze(program)
        instructions = IRGenerator().generate(program)
        optimized, stats = optimize_ir(
            instructions,
            unroll_factor=1,
            rename_static_registers=False,
            eliminate_dead_code=True,
        )

        self.assertGreater(stats.dead_code_eliminated, 0)
        self.assertFalse(
            any(
                "dead" in value
                for instruction in optimized
                for value in vars(instruction).values()
                if isinstance(value, str)
            )
        )

    def test_dce_preserves_global_writes(self) -> None:
        source = """
global_value:int = 0;
@EnterCraftWorld
craft:int main() {
    global_value = 9;
    return 1;
}
"""
        tokens = Lexer(source, filename="<test>").tokenize()
        program = Parser(tokens, filename="<test>").parse()
        SemanticAnalyzer(filename="<test>").analyze(program)
        instructions = IRGenerator().generate(program)
        optimized, _ = optimize_ir(
            instructions,
            unroll_factor=1,
            rename_static_registers=False,
            eliminate_dead_code=True,
        )

        writes = [
            instruction
            for instruction in optimized
            if isinstance(instruction, IRAssign)
            and instruction.result == "global_value"
        ]
        self.assertEqual(2, len(writes))

    def test_register_promotion_keeps_scalar_loop_off_the_stack(self) -> None:
        source = """
@EnterCraftWorld
craft:int main() {
    i:int = 0;
    total:int = 0;
    while (i < 8) {
        total = total + i;
        i = i + 1;
    }
    return total;
}
"""
        assembly, binary = self._compile_optimized(source, dce=True)
        load_store_count = len(
            re.findall(r"^\s+(?:lw|sw)\s", assembly, flags=re.MULTILINE)
        )

        self.assertTrue(binary)
        self.assertLessEqual(load_store_count, 4)
        self.assertIn("; promote i", assembly)
        self.assertIn("; promote total", assembly)

    def test_register_promotion_spills_live_values_across_calls(self) -> None:
        source = """
craft:int add_one(value:int) {
    return value + 1;
}

@EnterCraftWorld
craft:int main() {
    base:int = 40;
    result:int = summon:add_one(base);
    return base + result;
}
"""
        assembly, binary = self._compile_optimized(
            source,
            rename_static_registers=True,
            dce=True,
        )

        self.assertTrue(binary)
        main_body = assembly.split("main:", 1)[1].split("add_one:", 1)[0]
        call_offset = main_body.index("jal x1, add_one")
        before_call = main_body[:call_offset]
        after_call = main_body[call_offset:]
        self.assertRegex(before_call, r"\bsw x\d+, -\d+\(x17\) ; base")
        self.assertRegex(after_call, r"\blw x\d+, -\d+\(x17\) ; base")


if __name__ == "__main__":
    unittest.main()
