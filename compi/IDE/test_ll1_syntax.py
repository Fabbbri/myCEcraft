from pathlib import Path
import sys
import unittest


IDE_DIR = Path(__file__).resolve().parent
if str(IDE_DIR) not in sys.path:
    sys.path.insert(0, str(IDE_DIR))

from ll1_syntax import LL1SyntaxService


class LL1SyntaxServiceTest(unittest.TestCase):
    def setUp(self) -> None:
        self.service = LL1SyntaxService()

    def diagnostics_for(self, source: str):
        diagnostics, suggestions = self.service.analyze(source)
        return diagnostics, suggestions

    def expected_sets(self, diagnostics):
        return [set(diagnostic.expected) for diagnostic in diagnostics]

    def messages_for(self, diagnostics):
        return [diagnostic.message for diagnostic in diagnostics]

    def test_reports_missing_semicolon_and_missing_closing_brace(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = 0;
    return x"""

        diagnostics, suggestions = self.diagnostics_for(source)

        self.assertEqual(2, len(diagnostics))
        self.assertIn({";"}, self.expected_sets(diagnostics))
        self.assertIn({"}"}, self.expected_sets(diagnostics))
        self.assertEqual(";", suggestions[0].insert_text)

    def test_reports_only_missing_closing_brace_when_statement_is_complete(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = 0;
    return x;"""

        diagnostics, suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertEqual(("}",), diagnostics[0].expected)
        self.assertEqual("}", suggestions[0].insert_text)

    def test_reports_unknown_type_and_missing_closing_brace(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:intadaw = 0;
    return x;"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(2, len(diagnostics))
        self.assertIn("Tipo desconocido 'intadaw'", diagnostics[0].message)
        self.assertIn({"}"}, self.expected_sets(diagnostics))

    def test_does_not_autosuggest_semicolon_for_empty_int_return(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    return"""

        diagnostics, suggestions = self.service.analyze(source, include_semantic=False)

        self.assertEqual(2, len(diagnostics))
        self.assertIn("Return incompleto", diagnostics[0].message)
        self.assertEqual(("expresion",), diagnostics[0].expected)
        self.assertEqual([], suggestions)

    def test_allows_semicolon_for_empty_void_return(self) -> None:
        source = """@EnterCraftWorld
craft:void main(){
    return"""

        diagnostics, suggestions = self.service.analyze(source, include_semantic=False)

        self.assertEqual(2, len(diagnostics))
        self.assertIn({";"}, self.expected_sets(diagnostics))
        self.assertIn({"}"}, self.expected_sets(diagnostics))
        self.assertEqual(";", suggestions[0].insert_text)

    def test_reports_missing_parenthesis_and_closing_brace(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = 0;
    while (x < 5{
        x = x + 1;
    }
    return x;"""

        diagnostics, _suggestions = self.service.analyze(source, include_semantic=False)
        expected = self.expected_sets(diagnostics)

        self.assertIn({")"}, expected)
        self.assertIn({"}"}, expected)

    def test_reports_malformed_number_suffix_on_the_whole_literal(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = 0;
    while (x < 5awd){
        x = x + 1;
    }
    return x;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("Literal numerico invalido '5awd'", diagnostics[0].message)
        self.assertEqual(4, diagnostics[0].line)
        self.assertEqual(16, diagnostics[0].column)
        self.assertEqual(4, diagnostics[0].length)

    def test_reports_malformed_hex_suffix(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:uint32 = 0xFFzz;
    return 0;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("Literal numerico invalido '0xFFzz'", diagnostics[0].message)

    def test_reports_missing_semicolon_before_closing_brace(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = 0
}"""

        diagnostics, suggestions = self.service.analyze(source, include_semantic=False)

        self.assertEqual(1, len(diagnostics))
        self.assertEqual((";",), diagnostics[0].expected)
        self.assertEqual(";", suggestions[0].insert_text)

    def test_reports_missing_semicolon_on_previous_line_before_while(self) -> None:
        source = """@EnterCraftWorld
craft:int factorial(n:int){
    resultado:int = 1;
    i:int = 1

    while (i <= n){
        resultado = resultado * i;
        i = i + 1;
    }

    return resultado;
}"""

        diagnostics, suggestions = self.service.analyze(source, include_semantic=False)

        self.assertEqual(1, len(diagnostics))
        self.assertEqual(4, diagnostics[0].line)
        self.assertEqual((";",), diagnostics[0].expected)
        self.assertIn("Falta ';'", diagnostics[0].message)
        self.assertEqual(";", suggestions[0].insert_text)

    def test_reports_unexpected_extra_closing_brace(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    return 0;
}}"""

        diagnostics, _suggestions = self.service.analyze(source, include_semantic=False)

        self.assertTrue(any("Delimitador inesperado '}'" in msg for msg in self.messages_for(diagnostics)))

    def test_reports_missing_chest_bracket(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    datos:chest[int, 4 = [1, 2, 3, 4];
    return 0;
}"""

        diagnostics, _suggestions = self.service.analyze(source, include_semantic=False)

        self.assertIn({"]"}, self.expected_sets(diagnostics))

    def test_reports_missing_pragma(self) -> None:
        source = """craft:int main(){
    return 0;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("@EnterCraftWorld", diagnostics[0].message)

    def test_reports_unterminated_string(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    msg:pointer[char] = "hola;
    return 0;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("cadena sin cerrar", diagnostics[0].message)

    def test_reports_unterminated_block_comment(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    /* comentario
    return 0;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("comentario multilínea sin cerrar", diagnostics[0].message)

    def test_reports_unknown_symbol_semantic_error(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    return y;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("el simbolo 'y' no fue declarado", diagnostics[0].message)

    def test_reports_duplicate_variable_semantic_error(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = 0;
    x:int = 1;
    return x;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("ya fue declarado", diagnostics[0].message)

    def test_reports_incompatible_assignment_semantic_error(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = "hola";
    return x;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("tipo incompatible", diagnostics[0].message)

    def test_reports_wrong_function_arity_semantic_error(self) -> None:
        source = """@EnterCraftWorld
craft:int suma(a:int, b:int){ return a + b; }
craft:int main(){
    return summon:suma(1);
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("esperaba 2 argumentos", diagnostics[0].message)

    def test_reports_ender_used_as_plain_type(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    key:ender = 0;
    return 0;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("ender solo puede usarse", diagnostics[0].message)

    def test_reports_zero_sized_chest(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    datos:chest[int, 0] = [];
    return 0;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("tamaño de un chest debe ser mayor", diagnostics[0].message)

    def test_reports_chest_index_out_of_range(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    datos:chest[int, 2] = [1, 2];
    return datos[2];
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual(1, len(diagnostics))
        self.assertIn("indice fuera de rango", diagnostics[0].message)

    def test_valid_program_has_no_diagnostics(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    x:int = 0;
    while (x < 5){
        x = x + 1;
    }
    return x;
}"""

        diagnostics, _suggestions = self.diagnostics_for(source)

        self.assertEqual([], diagnostics)

    def test_completion_suggests_visible_variable(self) -> None:
        source = """@EnterCraftWorld
craft:int main(){
    contador:int = 0;
    return con
}"""
        cursor_position = source.rindex("con") + len("con")

        suggestions = self.service.complete(source, cursor_position)

        self.assertIn("contador", [suggestion.insert_text for suggestion in suggestions])

    def test_completion_suggests_functions_after_summon(self) -> None:
        source = """@EnterCraftWorld
craft:int suma(a:int, b:int){ return a + b; }
craft:int main(){
    return summon:s
}"""
        cursor_position = source.index("summon:s") + len("summon:s")

        suggestions = self.service.complete(source, cursor_position)

        self.assertIn("suma()", [suggestion.insert_text for suggestion in suggestions])

    def test_completion_suggests_module_alias_after_summon(self) -> None:
        source = """@EnterCraftWorld
invoke "math" as m;
craft:int main(){
    return summon:m
}"""
        cursor_position = source.index("summon:m") + len("summon:m")

        suggestions = self.service.complete(source, cursor_position)

        self.assertIn("m.", [suggestion.insert_text for suggestion in suggestions])


if __name__ == "__main__":
    unittest.main()
