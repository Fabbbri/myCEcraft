from lexer import Lexer, LexerError

source_code = """
@inline
craft:int suma(a:int, b:int) {
    return a + b;
}

invoke "math" as m;
x:int = summon:m.suma(3, 5);
"""

try:
    lexer = Lexer(source_code, filename="demo.craft")
    tokens = lexer.tokenize()

    for token in tokens:
        print(token)
except LexerError as error:
    print(error)