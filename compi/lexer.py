import re
from tokens import Token, TokenType


# Diccionario de palabras reservadas del lenguaje.
KEYWORDS = {
    "if": TokenType.KW_IF,
    "else": TokenType.KW_ELSE,
    "while": TokenType.KW_WHILE,
    "for": TokenType.KW_FOR,
    "return": TokenType.KW_RETURN,
    "craft": TokenType.KW_CRAFT,
    "summon": TokenType.KW_SUMMON,
    "invoke": TokenType.KW_INVOKE,
    "as": TokenType.KW_AS,
}

# Diccionario de tipos de dato del lenguaje.
TYPES = {
    "int": TokenType.TYPE_INT,
    "uint32": TokenType.TYPE_UINT32,
    "uint16": TokenType.TYPE_UINT16,
    "char": TokenType.TYPE_CHAR,
    "void": TokenType.TYPE_VOID,
    "pointer": TokenType.TYPE_POINTER,
    "chest": TokenType.TYPE_CHEST,
}


class LexerError(Exception):
    """
    Excepción utilizada para reportar errores léxicos.
    """

    def __init__(self, message: str, line: int, column: int, filename: str = "<input>"):
        full_message = (
            f"Error léxico en {filename}, línea {line}, columna {column}: {message}"
        )
        super().__init__(full_message)
        self.line = line
        self.column = column
        self.filename = filename


class Lexer:
    """
    Analizador léxico encargado de recorrer el texto fuente y
    convertirlo en una secuencia de tokens.
    """

    TOKEN_SPECS = [
        ("WHITESPACE", re.compile(r"[ \t\r\n]+")),
        ("LINE_COMMENT", re.compile(r"//[^\n]*")),
        ("BLOCK_COMMENT", re.compile(r"/\*[\s\S]*?\*/")),

        ("PRAGMA_INLINE", re.compile(r"@inline\b")),

        ("SPECIAL_LPLUS4", re.compile(r"<\+4")),
        ("SPECIAL_RPLUS5", re.compile(r">\+5")),

        ("SHIFT_LEFT", re.compile(r"<<")),
        ("SHIFT_RIGHT", re.compile(r">>")),
        ("EQ", re.compile(r"==")),
        ("NEQ", re.compile(r"!=")),
        ("LE", re.compile(r"<=")),
        ("GE", re.compile(r">=")),

        ("HEX_LITERAL", re.compile(r"0[xX][0-9A-Fa-f]+")),
        ("STRING_LITERAL", re.compile(r'"([^"\\]|\\.)*"')),
        ("INT_LITERAL", re.compile(r"[0-9]+")),

        ("IDENT", re.compile(r"[A-Za-z_][A-Za-z0-9_]*")),

        ("PLUS", re.compile(r"\+")),
        ("MINUS", re.compile(r"-")),
        ("STAR", re.compile(r"\*")),
        ("SLASH", re.compile(r"/")),

        ("LT", re.compile(r"<")),
        ("GT", re.compile(r">")),
        ("ASSIGN", re.compile(r"=")),

        ("BIT_XOR", re.compile(r"\^")),
        ("BIT_AND", re.compile(r"&")),
        ("BIT_OR", re.compile(r"\|")),
        ("BIT_NOT", re.compile(r"~")),

        ("SEMICOLON", re.compile(r";")),
        ("LBRACE", re.compile(r"\{")),
        ("RBRACE", re.compile(r"\}")),
        ("LPAREN", re.compile(r"\(")),
        ("RPAREN", re.compile(r"\)")),
        ("LBRACKET", re.compile(r"\[")),
        ("RBRACKET", re.compile(r"\]")),
        ("COMMA", re.compile(r",")),
        ("COLON", re.compile(r":")),
        ("DOT", re.compile(r"\.")),
    ]

    def __init__(self, source: str, filename: str = "<input>"):
        self.source = source
        self.filename = filename
        self.pos = 0
        self.line = 1
        self.column = 1

    def _is_at_end(self) -> bool:
        return self.pos >= len(self.source)

    def _peek(self, offset: int = 0) -> str:
        index = self.pos + offset
        if index >= len(self.source):
            return ""
        return self.source[index]

    def _advance(self, text: str) -> None:
        self.pos += len(text)

        line_breaks = text.count("\n")
        if line_breaks == 0:
            self.column += len(text)
            return

        self.line += line_breaks
        last_newline = text.rfind("\n")
        self.column = len(text) - last_newline

    def tokenize(self) -> list[Token]:
        tokens = []

        while not self._is_at_end():
            token = self._next_token()
            if token is not None:
                tokens.append(token)

        tokens.append(Token(TokenType.EOF, "", self.line, self.column))
        return tokens

    def _next_token(self) -> Token | None:
        self._check_unterminated_block_comment()
        self._check_unterminated_string()

        for name, pattern in self.TOKEN_SPECS:
            match = pattern.match(self.source, self.pos)
            if not match:
                continue

            lexeme = match.group(0)
            start_line = self.line
            start_column = self.column

            self._advance(lexeme)

            if name in {"WHITESPACE", "LINE_COMMENT", "BLOCK_COMMENT"}:
                return None

            if name == "PRAGMA_INLINE":
                return Token(TokenType.PRAGMA_INLINE, lexeme, start_line, start_column)

            if name == "IDENT":
                token_type = KEYWORDS.get(lexeme) or TYPES.get(lexeme) or TokenType.IDENT
                return Token(token_type, lexeme, start_line, start_column)

            return Token(TokenType[name], lexeme, start_line, start_column)

        current_char = self.source[self.pos]
        raise LexerError(
            message=f"símbolo no reconocido '{current_char}'",
            line=self.line,
            column=self.column,
            filename=self.filename,
        )

    def _check_unterminated_block_comment(self) -> None:
        """
        Detecta comentarios multilínea sin cerrar.
        """
        if self._peek() == "/" and self._peek(1) == "*":
            end = self.source.find("*/", self.pos + 2)
            if end == -1:
                raise LexerError(
                    message="comentario multilínea sin cerrar",
                    line=self.line,
                    column=self.column,
                    filename=self.filename,
                )

    def _check_unterminated_string(self) -> None:
        """
        Detecta cadenas sin cerrar.
        """
        if self._peek() != '"':
            return

        i = self.pos + 1
        escaped = False

        while i < len(self.source):
            ch = self.source[i]

            if escaped:
                escaped = False
                i += 1
                continue

            if ch == "\\":
                escaped = True
                i += 1
                continue

            if ch == '"':
                return

            if ch == "\n":
                raise LexerError(
                    message="cadena sin cerrar",
                    line=self.line,
                    column=self.column,
                    filename=self.filename,
                )

            i += 1

        raise LexerError(
            message="cadena sin cerrar",
            line=self.line,
            column=self.column,
            filename=self.filename,
        )