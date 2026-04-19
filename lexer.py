import re
from tokens import Token, TokenType

# Diccionario de palabras reservadas del lenguaje.
# Si el lexer reconoce un identificador cuyo lexema aparece aquí,
# entonces no se clasifica como IDENT sino como la keyword correspondiente.
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
# Funciona parecido a KEYWORDS, pero para tipos reservados.
TYPES = {
    "int": TokenType.TYPE_INT,
    "uint32": TokenType.TYPE_UINT32,
    "uint16": TokenType.TYPE_UINT16,
    "char": TokenType.TYPE_CHAR,
    "void": TokenType.TYPE_VOID,
    "pointer": TokenType.TYPE_POINTER,
    "chest": TokenType.TYPE_CHEST,
}


RESERVED_WORDS = tuple(sorted((*KEYWORDS.keys(), *TYPES.keys()), key=len, reverse=True))


class LexerError(Exception):
    """
    Excepción utilizada para reportar errores léxicos.

    Se lanza cuando el lexer encuentra un carácter o secuencia
    que no pertenece al lenguaje.
    """

    def __init__(self, message: str, line: int, column: int, filename: str = "<input>"):
        """
        Inicializa el error léxico con información de ubicación.

        Args:
            message: descripción del error.
            line: línea donde ocurrió el error.
            column: columna donde ocurrió el error.
            filename: nombre del archivo analizado.
        """
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

    # Lista ordenada de patrones léxicos compilados una sola vez.
    # El orden es importante: primero deben ir los patrones más específicos
    # o más largos, para evitar que un token válido se parta incorrectamente.
    TOKEN_SPECS = [
        # Espacios en blanco. Se reconocen para poder ignorarlos después.
        ("WHITESPACE", re.compile(r"[ \t\r\n]+")),

        # Comentario de una sola línea: inicia con // y termina al final de la línea.
        ("LINE_COMMENT", re.compile(r"//[^\n]*")),

        # Comentario multilínea: inicia con /* y termina con */.
        ("BLOCK_COMMENT", re.compile(r"/\*[\s\S]*?\*/")),

        # Pragma definido por el lenguaje.
        ("PRAGMA_INLINE", re.compile(r"@inline\b")),

        # Operadores especiales del lenguaje.
        # Deben ir antes que <, > y + para que no se separen incorrectamente.
        ("SPECIAL_LPLUS4", re.compile(r"<\+4")),
        ("SPECIAL_RPLUS5", re.compile(r">\+5")),

        # Operadores de dos caracteres.
        # Deben evaluarse antes que sus versiones de un solo carácter.
        ("SHIFT_LEFT", re.compile(r"<<")),
        ("SHIFT_RIGHT", re.compile(r">>")),
        ("EQ", re.compile(r"==")),
        ("NEQ", re.compile(r"!=")),
        ("LE", re.compile(r"<=")),
        ("GE", re.compile(r">=")),

        # Literales.
        # El hexadecimal debe ir antes que el entero decimal.
        ("HEX_LITERAL", re.compile(r"0[xX][0-9A-Fa-f]+")),
        ("STRING_LITERAL", re.compile(r'"([^"\\]|\\.)*"')),
        ("INT_LITERAL", re.compile(r"[0-9]+")),

        # Identificadores: luego se revisará si el lexema corresponde
        # a una palabra reservada o a un tipo.
        ("IDENT", re.compile(r"[A-Za-z_][A-Za-z0-9_]*")),

        # Operadores aritméticos de un carácter.
        ("PLUS", re.compile(r"\+")),
        ("MINUS", re.compile(r"-")),
        ("STAR", re.compile(r"\*")),
        ("SLASH", re.compile(r"/")),

        # Operadores relacionales y de asignación de un carácter.
        ("LT", re.compile(r"<")),
        ("GT", re.compile(r">")),
        ("ASSIGN", re.compile(r"=")),

        # Operadores bit a bit.
        ("BIT_XOR", re.compile(r"\^")),
        ("BIT_AND", re.compile(r"&")),
        ("BIT_OR", re.compile(r"\|")),
        ("BIT_NOT", re.compile(r"~")),

        # Delimitadores y separadores.
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
        """
        Inicializa el lexer con el texto fuente de entrada.

        Args:
            source: contenido completo del archivo fuente.
            filename: nombre del archivo, útil para mensajes de error.
        """
        self.source = source
        self.filename = filename

        # Posición actual dentro del texto fuente.
        self.pos = 0

        # Línea y columna actuales, útiles para reportar errores.
        self.line = 1
        self.column = 1

    def _is_at_end(self) -> bool:
        """
        Indica si el lexer ya llegó al final del texto fuente.

        Returns:
            True si no quedan más caracteres por procesar, False en caso contrario.
        """
        return self.pos >= len(self.source)

    def _peek(self) -> str:
        """
        Devuelve el carácter actual sin avanzar la posición.

        Returns:
            El carácter actual, o cadena vacía si ya se llegó al final.
        """
        if self._is_at_end():
            return ""
        return self.source[self.pos]

    def _advance(self, text: str) -> None:
        """
        Avanza la posición actual del lexer según el texto consumido.

        Además, actualiza correctamente la línea y la columna.

        Args:
            text: fragmento de texto que acaba de ser reconocido.
        """
        self.pos += len(text)

        line_breaks = text.count("\n")
        if line_breaks == 0:
            self.column += len(text)
            return

        self.line += line_breaks
        last_newline = text.rfind("\n")
        self.column = len(text) - last_newline

    def tokenize(self) -> list[Token]:
        """
        Recorre todo el texto fuente y devuelve la lista completa de tokens.

        El método solicita tokens uno a uno hasta llegar al final de la entrada.
        Los espacios en blanco y comentarios no se agregan a la salida, ya que
        no son necesarios para el análisis sintáctico.

        Returns:
            Lista de tokens reconocidos, incluyendo un token EOF al final.
        """
        tokens = []

        # Continúa solicitando tokens mientras queden caracteres por procesar.
        while not self._is_at_end():
            token = self._next_token()

            # Algunos patrones, como espacios y comentarios, se reconocen
            # pero se ignoran. En esos casos, _next_token() devolverá None.
            if token is not None:
                tokens.append(token)

        # Al finalizar el recorrido, se agrega un token especial EOF.
        tokens.append(Token(TokenType.EOF, "", self.line, self.column))

        return tokens

    def _next_token(self) -> Token | None:
        """
        Intenta reconocer el siguiente token desde la posición actual.

        Recorre la lista de patrones léxicos en orden. Si alguno coincide
        al inicio del texto restante, consume ese fragmento y devuelve el
        token correspondiente.

        Returns:
            Un objeto Token si se reconoció un token útil.
            None si se reconoció un espacio en blanco o un comentario,
            ya que esos elementos se ignoran.

        Raises:
            LexerError: si ningún patrón coincide con el texto actual.
        """
        # Probar cada patrón en orden.
        for name, pattern in self.TOKEN_SPECS:
            match = pattern.match(self.source, self.pos)

            # Si el patrón no coincide al inicio, se prueba el siguiente.
            if not match:
                continue

            # Texto exacto reconocido por el patrón.
            lexeme = match.group(0)

            # Guardar la ubicación inicial del token antes de avanzar.
            start_line = self.line
            start_column = self.column

            # Consumir el texto reconocido y actualizar posición, línea y columna.
            self._advance(lexeme)

            # Espacios en blanco y comentarios se reconocen, pero no se devuelven
            # como tokens al parser.
            if name in {"WHITESPACE", "LINE_COMMENT", "BLOCK_COMMENT"}:
                return None

            # El pragma @inline tiene un token específico.
            if name == "PRAGMA_INLINE":
                return Token(TokenType.PRAGMA_INLINE, lexeme, start_line, start_column)

            # Si se reconoció un identificador, hay que verificar si en realidad
            # corresponde a una palabra reservada o a un tipo del lenguaje.
            if name == "IDENT":
                # Detecta typos como "craft3" o "invokeke":
                # palabra reservada/tipo seguida de sufijo alfanumerico sin separador.
                for reserved in RESERVED_WORDS:
                    if not lexeme.startswith(reserved) or lexeme == reserved:
                        continue

                    suffix = lexeme[len(reserved):]
                    if suffix and suffix[0] != "_":
                        raise LexerError(
                            message=(
                                f"identificador invalido '{lexeme}': "
                                f"la palabra reservada/tipo '{reserved}' no puede llevar sufijo "
                                "alfanumerico sin separador"
                            ),
                            line=start_line,
                            column=start_column,
                            filename=self.filename,
                        )

                token_type = KEYWORDS.get(lexeme) or TYPES.get(lexeme) or TokenType.IDENT
                return Token(token_type, lexeme, start_line, start_column)

            # Para cualquier otro patrón, el nombre en token_specs coincide con
            # un miembro del enum TokenType.
            return Token(TokenType[name], lexeme, start_line, start_column)

        # Si ningún patrón coincidió, el carácter actual no pertenece al lenguaje.
        current_char = self.source[self.pos]
        raise LexerError(
            message=f"símbolo no reconocido '{current_char}'",
            line=self.line,
            column=self.column,
            filename=self.filename,
        )