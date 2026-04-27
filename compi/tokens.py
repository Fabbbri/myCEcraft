from enum import Enum, auto
from dataclasses import dataclass


class TokenType(Enum):
    """
    Enumeración que define todos los tipos de token que el lexer puede reconocer.

    Cada miembro representa una categoría léxica del lenguaje, por ejemplo:
    palabras reservadas, tipos, literales, operadores, delimitadores, etc.

    Se utiliza `auto()` para que Python asigne automáticamente un valor interno
    único a cada token, evitando numerarlos manualmente.
    """

    # Palabras reservadas del lenguaje
    KW_IF = auto()
    KW_ELSE = auto()
    KW_WHILE = auto()
    KW_FOR = auto()
    KW_RETURN = auto()
    KW_CRAFT = auto()
    KW_SUMMON = auto()
    KW_INVOKE = auto()
    KW_AS = auto()
    KW_ENDEROPEN = auto()
    KW_ENDERCLOSE = auto()
    KW_ENDERLOAD = auto()
    KW_ENDERSTORE = auto()
    KW_ENDERKEY = auto()
    KW_ENDERLOW = auto()
    KW_ENDERHIGH = auto()

    # Tipos de dato definidos en el lenguaje
    TYPE_INT = auto()
    TYPE_UINT32 = auto()
    TYPE_UINT16 = auto()
    TYPE_CHAR = auto()
    TYPE_VOID = auto()
    TYPE_POINTER = auto()
    TYPE_CHEST = auto()
    TYPE_ENDER = auto()

    # Anotaciones o pragmas del compilador
    PRAGMA_INLINE = auto()

    # Identificadores y literales
    IDENT = auto()
    INT_LITERAL = auto()
    HEX_LITERAL = auto()
    STRING_LITERAL = auto()

    # Operadores aritméticos y de desplazamiento
    PLUS = auto()
    MINUS = auto()
    STAR = auto()
    SLASH = auto()
    SHIFT_LEFT = auto()
    SHIFT_RIGHT = auto()

    # Operadores relacionales y de asignación
    EQ = auto()
    NEQ = auto()
    LT = auto()
    GT = auto()
    LE = auto()
    GE = auto()
    ASSIGN = auto()

    # Operadores bit a bit
    BIT_XOR = auto()
    BIT_AND = auto()
    BIT_OR = auto()
    BIT_NOT = auto()

    # Operadores especiales definidos por el lenguaje
    SPECIAL_LPLUS4 = auto()
    SPECIAL_RPLUS5 = auto()

    # Delimitadores y separadores
    SEMICOLON = auto()
    LBRACE = auto()
    RBRACE = auto()
    LPAREN = auto()
    RPAREN = auto()
    LBRACKET = auto()
    RBRACKET = auto()
    COMMA = auto()
    COLON = auto()
    DOT = auto()

    # Token especial que indica fin de archivo o fin de entrada
    EOF = auto()


@dataclass(frozen=True)
class Token:
    """
    Representa un token individual producido por el lexer.

    Atributos:
        type: tipo de token reconocido, según la enumeración TokenType.
        lexeme: texto exacto encontrado en la entrada.
        line: línea en la que inicia el token.
        column: columna en la que inicia el token.

    Se declara como inmutable (`frozen=True`) porque, una vez reconocido,
    un token no debería modificarse.
    """

    type: TokenType
    lexeme: str
    line: int
    column: int
