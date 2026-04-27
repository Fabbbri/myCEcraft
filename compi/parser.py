from __future__ import annotations

import ast as py_ast
from difflib import get_close_matches

from ast_nodes import (
    ArrayLiteral,
    Assignment,
    ASTNode,
    BinaryExpression,
    Block,
    CallExpression,
    ChangePasswordInstruction,
    EnderPortalStatement,
    ExpressionStatement,
    ForStatement,
    FunctionDeclaration,
    Identifier,
    IfStatement,
    ImportDeclaration,
    IndexExpression,
    Literal,
    MemberExpression,
    Parameter,
    Program,
    ReturnStatement,
    TypeNode,
    UnaryExpression,
    VariableDeclaration,
    VaultInstruction,
    WhileStatement,
)
from tokens import Token, TokenType


class ParseError(Exception):
    """
    Error sintactico con ubicacion en el archivo fuente.
    """

    def __init__(self, message: str, token: Token, filename: str = "<input>"):
        full_message = (
            f"Error sintactico en {filename}, linea {token.line}, "
            f"columna {token.column}: {message}"
        )
        super().__init__(full_message)
        self.token = token
        self.filename = filename


class Parser:
    """
    Parser descendente recursivo para el lenguaje myCEcraft.
    """

    TYPE_TOKENS = {
        TokenType.TYPE_INT,
        TokenType.TYPE_UINT32,
        TokenType.TYPE_UINT16,
        TokenType.TYPE_CHAR,
        TokenType.TYPE_VOID,
        TokenType.TYPE_POINTER,
        TokenType.TYPE_CHEST,
        TokenType.TYPE_ENDER,
    }

    ASSIGNABLE_NODES = (Identifier, IndexExpression, MemberExpression)
    RESERVED_WORDS = {
        "if",
        "else",
        "while",
        "for",
        "return",
        "craft",
        "summon",
        "invoke",
        "as",
        "ender",
        "enderopen",
        "enderclose",
        "enderload",
        "enderstore",
        "enderkey",
        "enderlow",
        "enderhigh",
        "enderPortal",
        "changePassword",
        "close",
        "endChange",
        "endchange",
        "enderchange",
    }
    VAULT_KEYWORDS = {
        TokenType.KW_ENDEROPEN,
        TokenType.KW_ENDERCLOSE,
        TokenType.KW_ENDERLOAD,
        TokenType.KW_ENDERSTORE,
        TokenType.KW_ENDERKEY,
        TokenType.KW_ENDERLOW,
        TokenType.KW_ENDERHIGH,
        TokenType.KW_CLOSE,
    }

    def __init__(self, tokens: list[Token], filename: str = "<input>"):
        self.tokens = tokens
        self.filename = filename
        self.current = 0
        self._last_suspicious_dedent: tuple[Token, str] | None = None

    def parse(self) -> Program:
        declarations: list[ASTNode] = []
        pending_pragmas: list[str] = []
        program_pragmas: list[str] = []
        first_token = self._peek()

        while not self._is_at_end():
            if self._match(TokenType.PRAGMA_ENTER_CRAFT_WORLD):
                pragma = self._previous()
                if pragma.lexeme in program_pragmas:
                    raise self._error(
                        pragma,
                        f"el pragma '{pragma.lexeme}' solo puede aparecer una vez",
                    )
                program_pragmas.append(pragma.lexeme)
                continue

            if self._match(TokenType.PRAGMA_INLINE):
                pending_pragmas.append(self._previous().lexeme)
                continue

            if self._check(TokenType.KW_CRAFT):
                declarations.append(self._function_declaration(pending_pragmas))
                pending_pragmas = []
                continue

            if pending_pragmas:
                pragma = pending_pragmas[-1]
                raise self._error(
                    self._peek(),
                    f"el pragma '{pragma}' solo puede aplicarse a una funcion craft",
                )

            declarations.append(self._declaration_or_statement())

        if "@EnterCraftWorld" not in program_pragmas:
            raise self._error(
                first_token,
                "el archivo debe incluir el pragma '@EnterCraftWorld'",
            )

        return Program(declarations=declarations, pragmas=program_pragmas)

    def _declaration_or_statement(self) -> ASTNode:
        self._check_common_keyword_typo()

        if self._check(TokenType.KW_INVOKE):
            return self._import_declaration()

        if self._is_variable_declaration_start():
            return self._variable_declaration(require_semicolon=True)

        return self._statement()

    def _check_common_keyword_typo(self) -> None:
        token = self._peek()
        if token.type != TokenType.IDENT:
            return

        if token.lexeme == "inline" and self._peek_next().type == TokenType.KW_CRAFT:
            raise self._error(
                token,
                "pragma invalido 'inline', se esperaba '@inline'",
            )

        suggestion = self._keyword_suggestion(token.lexeme)
        if suggestion is None:
            return

        next_token = self._peek_next()
        if suggestion == "invoke" and next_token.type == TokenType.STRING_LITERAL:
            raise self._error(
                token,
                f"palabra reservada desconocida '{token.lexeme}', quiso decir 'invoke'",
            )

        if suggestion == "craft" and next_token.type == TokenType.COLON:
            raise self._error(
                token,
                f"palabra reservada desconocida '{token.lexeme}', quiso decir 'craft'",
            )

        if suggestion in {"if", "while", "for"} and next_token.type == TokenType.LPAREN:
            raise self._error(
                token,
                f"palabra reservada desconocida '{token.lexeme}', quiso decir '{suggestion}'",
            )

    def _keyword_suggestion(self, lexeme: str) -> str | None:
        matches = get_close_matches(lexeme, self.RESERVED_WORDS, n=1, cutoff=0.75)
        if not matches:
            return None
        return matches[0]

    def _function_declaration(self, pragmas: list[str]) -> FunctionDeclaration:
        start = self._consume(TokenType.KW_CRAFT, "se esperaba 'craft'")
        self._consume(TokenType.COLON, "se esperaba ':' despues de 'craft'")
        return_type = self._type()
        name = self._consume(TokenType.IDENT, "se esperaba el nombre de la funcion")

        self._consume(TokenType.LPAREN, "se esperaba '(' despues del nombre de la funcion")
        parameters = self._parameters()
        self._consume(TokenType.RPAREN, "se esperaba ')' despues de los parametros")

        body = self._block(f"la funcion '{name.lexeme}'")
        return FunctionDeclaration(
            name=name.lexeme,
            return_type=return_type,
            parameters=parameters,
            body=body,
            line=start.line,
            column=start.column,
            pragmas=list(pragmas),
        )

    def _parameters(self) -> list[Parameter]:
        parameters: list[Parameter] = []

        if self._check(TokenType.RPAREN):
            return parameters

        while True:
            name = self._consume(TokenType.IDENT, "se esperaba el nombre del parametro")
            self._consume(TokenType.COLON, "se esperaba ':' despues del parametro")
            param_type = self._type()
            parameters.append(
                Parameter(
                    name=name.lexeme,
                    type=param_type,
                    line=name.line,
                    column=name.column,
                )
            )

            if not self._match(TokenType.COMMA):
                break

        return parameters

    def _import_declaration(self) -> ImportDeclaration:
        start = self._consume(TokenType.KW_INVOKE, "se esperaba 'invoke'")
        module = self._consume(
            TokenType.STRING_LITERAL,
            "se esperaba una cadena con el nombre del modulo",
        )
        self._consume(TokenType.KW_AS, "se esperaba 'as' despues del modulo")
        alias = self._consume(TokenType.IDENT, "se esperaba el alias del modulo")
        if not self._match(TokenType.SEMICOLON):
            raise self._error_at(
                start,
                "se esperaba ';' despues del invoke",
            )

        return ImportDeclaration(
            module=self._string_value(module.lexeme),
            alias=alias.lexeme,
            line=start.line,
            column=start.column,
        )

    def _variable_declaration(self, require_semicolon: bool) -> VariableDeclaration:
        name = self._consume(TokenType.IDENT, "se esperaba el nombre de la variable")
        self._consume(TokenType.COLON, "se esperaba ':' despues del identificador")
        var_type = self._type()

        initializer: ASTNode | None = None
        if self._match(TokenType.ASSIGN):
            initializer = self._expression()

        if require_semicolon:
            self._consume_statement_semicolon("se esperaba ';' despues de la declaracion")

        return VariableDeclaration(
            name=name.lexeme,
            type=var_type,
            initializer=initializer,
            line=name.line,
            column=name.column,
        )

    def _statement(self) -> ASTNode:
        if self._check(TokenType.KW_ELSE):
            raise self._error(
                self._peek(),
                "se encontro 'else' dentro de un bloque; probablemente falta '}' antes de 'else'",
            )
        if self._check(TokenType.LBRACE):
            return self._block()
        if self._check(TokenType.KW_IF):
            return self._if_statement()
        if self._check(TokenType.KW_WHILE):
            return self._while_statement()
        if self._check(TokenType.KW_FOR):
            return self._for_statement()
        if self._check(TokenType.KW_RETURN):
            return self._return_statement()
        if self._check(TokenType.KW_ENDERPORTAL):
            return self._ender_portal_statement()
        if self._check(TokenType.KW_CHANGEPASSWORD):
            raise self._error(
                self._peek(),
                "'changePassword' fue renombrado a 'enderchange'",
            )
        if self._check(TokenType.KW_ENDERCHANGE):
            return self._ender_change_instruction()
        if self._check(TokenType.KW_ENDCHANGE):
            if self._peek().lexeme == "endChange":
                raise self._error(
                    self._peek(),
                    "'endChange' fue renombrado a 'endchange'",
                )
            raise self._error(
                self._peek(),
                "'endchange' solo puede cerrar un bloque enderPortal",
            )
        if self._peek().type in self.VAULT_KEYWORDS:
            return self._vault_instruction()

        return self._expression_statement()

    def _ender_portal_statement(self) -> EnderPortalStatement:
        start = self._consume(TokenType.KW_ENDERPORTAL, "se esperaba 'enderPortal'")
        self._consume(TokenType.LPAREN, "se esperaba '(' despues de 'enderPortal'")
        password = self._assignment_or_expression()
        self._consume(TokenType.RPAREN, "se esperaba ')' despues de la clave del portal")

        body = None
        if self._match(TokenType.COLON):
            statements: list[ASTNode] = []

            while True:
                if self._is_at_end() or self._check(TokenType.RBRACE):
                    raise self._error(
                        self._peek(),
                        "se esperaba 'endchange' para cerrar el bloque enderPortal",
                    )

                if self._check(TokenType.KW_ENDCHANGE):
                    if self._peek().lexeme == "endChange":
                        raise self._error(
                            self._peek(),
                            "'endChange' fue renombrado a 'endchange'",
                        )
                    self._advance()
                    self._match(TokenType.SEMICOLON)
                    break

                statements.append(self._declaration_or_statement())

            body = Block(statements=statements, line=start.line, column=start.column)
        else:
            self._consume_statement_semicolon(
                "se esperaba ';' o ':' despues de enderPortal(...)"
            )

        return EnderPortalStatement(
            password=password,
            body=body,
            line=start.line,
            column=start.column,
        )

    def _ender_change_instruction(self) -> ChangePasswordInstruction:
        start = self._consume(
            TokenType.KW_ENDERCHANGE,
            "se esperaba 'enderchange'",
        )
        self._consume(TokenType.LPAREN, "se esperaba '(' despues de 'enderchange'")
        value = self._assignment_or_expression()
        self._consume(TokenType.RPAREN, "se esperaba ')' despues del valor")
        self._consume_optional_high_level_semicolon()
        return ChangePasswordInstruction(value=value, line=start.line, column=start.column)

    def _vault_instruction(self) -> VaultInstruction:
        start = self._advance()
        operands: list[str] = []
        current: list[str] = []
        depth = 0

        if start.type in {TokenType.KW_CLOSE, TokenType.KW_ENDERCLOSE}:
            self._match(TokenType.SEMICOLON)
            return VaultInstruction(
                keyword=start.lexeme,
                operands=[],
                line=start.line,
                column=start.column,
            )

        while not self._check(TokenType.SEMICOLON) and not self._is_at_end():
            token = self._peek()

            if token.type == TokenType.COMMA and depth == 0:
                operands.append("".join(current).strip())
                current = []
                self._advance()
                continue

            if token.type in {TokenType.LPAREN, TokenType.LBRACKET}:
                depth += 1
            elif token.type in {TokenType.RPAREN, TokenType.RBRACKET}:
                depth -= 1
                if depth < 0:
                    raise self._error(token, "delimitador de operando ender desbalanceado")

            current.append(token.lexeme)
            self._advance()

        if depth != 0:
            raise self._error(start, "operando ender con delimitadores sin cerrar")

        if current:
            operands.append("".join(current).strip())

        self._consume_statement_semicolon("se esperaba ';' despues de la instruccion ender")
        return VaultInstruction(
            keyword=start.lexeme,
            operands=operands,
            line=start.line,
            column=start.column,
        )

    def _consume_optional_high_level_semicolon(self) -> None:
        if self._match(TokenType.SEMICOLON):
            return

        if (
            self._check(TokenType.KW_ENDCHANGE)
            or self._check(TokenType.KW_ENDERCHANGE)
            or self._check(TokenType.KW_CLOSE)
            or self._check(TokenType.KW_ENDERCLOSE)
        ):
            return

        if self._check(TokenType.KW_CHANGEPASSWORD) or self._check(TokenType.KW_ENDERPORTAL):
            return

        self._consume_statement_semicolon("se esperaba ';' despues de la instruccion")

    def _block(self, context: str = "bloque") -> Block:
        start = self._consume(TokenType.LBRACE, "se esperaba '{' para iniciar el bloque")
        statements: list[ASTNode] = []

        while not self._check(TokenType.RBRACE) and not self._is_at_end():
            self._note_suspicious_dedent(statements, context)
            statements.append(self._declaration_or_statement())

        if self._is_at_end():
            hint = ""
            if self._last_suspicious_dedent is not None:
                token, dedent_context = self._last_suspicious_dedent
                hint = (
                    f"; pista: revise si falta '}}' antes de '{token.lexeme}' "
                    f"en linea {token.line}, columna {token.column} "
                    f"en {dedent_context}"
                )
            raise self._error(
                self._peek(),
                f"se esperaba '}}' para cerrar {context} iniciado en linea {start.line}, columna {start.column}{hint}",
            )

        self._consume(TokenType.RBRACE, "se esperaba '}' para cerrar el bloque")
        return Block(statements=statements, line=start.line, column=start.column)

    def _note_suspicious_dedent(
        self,
        statements: list[ASTNode],
        context: str,
    ) -> None:
        if not statements:
            return

        token = self._peek()
        first_statement = statements[0]

        if token.line <= first_statement.line:
            return

        if token.column < first_statement.column and self._last_suspicious_dedent is None:
            self._last_suspicious_dedent = (token, context)

    def _if_statement(self) -> IfStatement:
        start = self._consume(TokenType.KW_IF, "se esperaba 'if'")
        self._consume(TokenType.LPAREN, "se esperaba '(' despues de 'if'")
        condition = self._expression()
        self._consume(TokenType.RPAREN, "se esperaba ')' despues de la condicion")
        then_branch = self._block("el bloque if")

        else_branch = None
        if self._match(TokenType.KW_ELSE):
            if self._check(TokenType.KW_IF):
                nested_if = self._if_statement()
                else_branch = Block(
                    statements=[nested_if],
                    line=nested_if.line,
                    column=nested_if.column,
                )
            else:
                else_branch = self._block("el bloque else")

        return IfStatement(
            condition=condition,
            then_branch=then_branch,
            else_branch=else_branch,
            line=start.line,
            column=start.column,
        )

    def _while_statement(self) -> WhileStatement:
        start = self._consume(TokenType.KW_WHILE, "se esperaba 'while'")
        self._consume(TokenType.LPAREN, "se esperaba '(' despues de 'while'")
        condition = self._expression()
        self._consume(TokenType.RPAREN, "se esperaba ')' despues de la condicion")
        body = self._block("el bloque while")

        return WhileStatement(
            condition=condition,
            body=body,
            line=start.line,
            column=start.column,
        )

    def _for_statement(self) -> ForStatement:
        start = self._consume(TokenType.KW_FOR, "se esperaba 'for'")
        self._consume(TokenType.LPAREN, "se esperaba '(' despues de 'for'")

        initializer: ASTNode | None = None
        if self._match(TokenType.SEMICOLON):
            initializer = None
        elif self._is_variable_declaration_start():
            initializer = self._variable_declaration(require_semicolon=False)
            self._consume(TokenType.SEMICOLON, "se esperaba ';' despues del inicio del for")
        else:
            initializer = self._assignment_or_expression()
            self._consume(TokenType.SEMICOLON, "se esperaba ';' despues del inicio del for")

        condition: ASTNode | None = None
        if not self._check(TokenType.SEMICOLON):
            condition = self._expression()
        self._consume(TokenType.SEMICOLON, "se esperaba ';' despues de la condicion del for")

        increment: ASTNode | None = None
        if not self._check(TokenType.RPAREN):
            increment = self._assignment_or_expression()
        self._consume(TokenType.RPAREN, "se esperaba ')' despues del for")

        body = self._block("el bloque for")
        return ForStatement(
            initializer=initializer,
            condition=condition,
            increment=increment,
            body=body,
            line=start.line,
            column=start.column,
        )

    def _return_statement(self) -> ReturnStatement:
        start = self._consume(TokenType.KW_RETURN, "se esperaba 'return'")

        value = None
        if not self._check(TokenType.SEMICOLON):
            value = self._expression()

        self._consume_statement_semicolon("se esperaba ';' despues de return")
        return ReturnStatement(value=value, line=start.line, column=start.column)

    def _expression_statement(self) -> ASTNode:
        expression = self._assignment_or_expression()
        self._consume_statement_semicolon("se esperaba ';' despues de la instruccion")

        if isinstance(expression, Assignment):
            return expression

        return ExpressionStatement(
            expression=expression,
            line=expression.line,
            column=expression.column,
        )

    def _assignment_or_expression(self) -> ASTNode:
        expression = self._expression()

        if self._match(TokenType.ASSIGN):
            equals = self._previous()
            if not isinstance(expression, self.ASSIGNABLE_NODES):
                raise self._error(equals, "el lado izquierdo no es asignable")

            value = self._assignment_or_expression()
            return Assignment(
                target=expression,
                value=value,
                line=expression.line,
                column=expression.column,
            )

        return expression

    def _expression(self) -> ASTNode:
        return self._bit_or()

    def _bit_or(self) -> ASTNode:
        expression = self._bit_xor()

        while self._match(TokenType.BIT_OR):
            operator = self._previous()
            right = self._bit_xor()
            expression = self._binary(expression, operator, right)

        return expression

    def _bit_xor(self) -> ASTNode:
        expression = self._bit_and()

        while self._match(TokenType.BIT_XOR):
            operator = self._previous()
            right = self._bit_and()
            expression = self._binary(expression, operator, right)

        return expression

    def _bit_and(self) -> ASTNode:
        expression = self._equality()

        while self._match(TokenType.BIT_AND):
            operator = self._previous()
            right = self._equality()
            expression = self._binary(expression, operator, right)

        return expression

    def _equality(self) -> ASTNode:
        expression = self._comparison()

        while self._match(TokenType.EQ, TokenType.NEQ):
            operator = self._previous()
            right = self._comparison()
            expression = self._binary(expression, operator, right)

        return expression

    def _comparison(self) -> ASTNode:
        expression = self._shift()

        while self._match(TokenType.LT, TokenType.GT, TokenType.LE, TokenType.GE):
            operator = self._previous()
            right = self._shift()
            expression = self._binary(expression, operator, right)

        return expression

    def _shift(self) -> ASTNode:
        expression = self._term()

        while self._match(
            TokenType.SHIFT_LEFT,
            TokenType.SHIFT_RIGHT,
            TokenType.SPECIAL_LPLUS4,
            TokenType.SPECIAL_RPLUS5,
        ):
            operator = self._previous()
            right = self._term()
            expression = self._binary(expression, operator, right)

        return expression

    def _term(self) -> ASTNode:
        expression = self._factor()

        while self._match(TokenType.PLUS, TokenType.MINUS):
            operator = self._previous()
            right = self._factor()
            expression = self._binary(expression, operator, right)

        return expression

    def _factor(self) -> ASTNode:
        expression = self._unary()

        while self._match(TokenType.STAR, TokenType.SLASH):
            operator = self._previous()
            right = self._unary()
            expression = self._binary(expression, operator, right)

        return expression

    def _unary(self) -> ASTNode:
        if self._match(TokenType.MINUS, TokenType.BIT_NOT):
            operator = self._previous()
            operand = self._unary()
            return UnaryExpression(
                operator=operator.lexeme,
                operand=operand,
                line=operator.line,
                column=operator.column,
            )

        return self._postfix()

    def _postfix(self) -> ASTNode:
        expression = self._primary()

        while True:
            if self._match(TokenType.LBRACKET):
                bracket = self._previous()
                index = self._expression()
                self._consume(TokenType.RBRACKET, "se esperaba ']' despues del indice")
                expression = IndexExpression(
                    target=expression,
                    index=index,
                    line=bracket.line,
                    column=bracket.column,
                )
                continue

            if self._match(TokenType.DOT):
                dot = self._previous()
                member = self._consume(
                    TokenType.IDENT,
                    "se esperaba un identificador despues de '.'",
                )
                expression = MemberExpression(
                    target=expression,
                    member=member.lexeme,
                    line=dot.line,
                    column=dot.column,
                )
                continue

            break

        return expression

    def _primary(self) -> ASTNode:
        if self._match(TokenType.INT_LITERAL):
            token = self._previous()
            return Literal(
                value=int(token.lexeme),
                literal_type="int",
                line=token.line,
                column=token.column,
            )

        if self._match(TokenType.HEX_LITERAL):
            token = self._previous()
            return Literal(
                value=int(token.lexeme, 16),
                literal_type="hex",
                line=token.line,
                column=token.column,
            )

        if self._match(TokenType.STRING_LITERAL):
            token = self._previous()
            return Literal(
                value=self._string_value(token.lexeme),
                literal_type="string",
                line=token.line,
                column=token.column,
            )

        if self._match(TokenType.IDENT):
            token = self._previous()
            return Identifier(name=token.lexeme, line=token.line, column=token.column)

        if self._check(TokenType.KW_SUMMON):
            return self._call_expression()

        if self._match(TokenType.LPAREN):
            expression = self._assignment_or_expression()
            self._consume(TokenType.RPAREN, "se esperaba ')' despues de la expresion")
            return expression

        if self._check(TokenType.LBRACKET):
            return self._array_literal()

        raise self._error(self._peek(), "se esperaba una expresion")

    def _call_expression(self) -> CallExpression:
        start = self._consume(TokenType.KW_SUMMON, "se esperaba 'summon'")
        self._consume(TokenType.COLON, "se esperaba ':' despues de 'summon'")

        first_name = self._consume(
            TokenType.IDENT,
            "se esperaba el nombre de la funcion",
        )

        module_alias = None
        function_name = first_name.lexeme
        if self._match(TokenType.DOT):
            module_alias = first_name.lexeme
            function_name = self._consume(
                TokenType.IDENT,
                "se esperaba el nombre de la funcion despues de '.'",
            ).lexeme

        self._consume(TokenType.LPAREN, "se esperaba '(' en la llamada")
        arguments = self._arguments()
        self._consume(TokenType.RPAREN, "se esperaba ')' despues de los argumentos")

        return CallExpression(
            module_alias=module_alias,
            name=function_name,
            arguments=arguments,
            line=start.line,
            column=start.column,
        )

    def _arguments(self) -> list[ASTNode]:
        arguments: list[ASTNode] = []

        if self._check(TokenType.RPAREN):
            return arguments

        while True:
            arguments.append(self._assignment_or_expression())
            if not self._match(TokenType.COMMA):
                break

        return arguments

    def _array_literal(self) -> ArrayLiteral:
        start = self._consume(TokenType.LBRACKET, "se esperaba '['")
        elements: list[ASTNode] = []

        if not self._check(TokenType.RBRACKET):
            while True:
                elements.append(self._assignment_or_expression())
                if not self._match(TokenType.COMMA):
                    break

        self._consume(TokenType.RBRACKET, "se esperaba ']' despues del arreglo")
        return ArrayLiteral(elements=elements, line=start.line, column=start.column)

    def _type(self) -> TypeNode:
        token = self._peek()
        if token.type not in self.TYPE_TOKENS:
            raise self._error(token, "se esperaba un tipo")

        token = self._advance()
        name = token.lexeme

        if token.type == TokenType.TYPE_POINTER:
            base_type = None
            if self._match(TokenType.LBRACKET):
                base_type = self._type()
                self._consume(TokenType.RBRACKET, "se esperaba ']' despues del tipo pointer")
            return TypeNode(
                name=name,
                base_type=base_type,
                line=token.line,
                column=token.column,
            )

        if token.type == TokenType.TYPE_CHEST:
            self._consume(TokenType.LBRACKET, "se esperaba '[' despues de 'chest'")
            element_type = self._type()
            self._consume(TokenType.COMMA, "se esperaba ',' en el tipo chest")
            size = self._consume(
                TokenType.INT_LITERAL,
                "se esperaba el tamano entero del chest",
            )
            self._consume(TokenType.RBRACKET, "se esperaba ']' despues del tipo chest")
            return TypeNode(
                name=name,
                base_type=element_type,
                size=int(size.lexeme),
                line=token.line,
                column=token.column,
            )

        return TypeNode(name=name, line=token.line, column=token.column)

    def _binary(self, left: ASTNode, operator: Token, right: ASTNode) -> BinaryExpression:
        return BinaryExpression(
            left=left,
            operator=operator.lexeme,
            right=right,
            line=operator.line,
            column=operator.column,
        )

    def _is_variable_declaration_start(self) -> bool:
        return self._check(TokenType.IDENT) and self._check_next(TokenType.COLON)

    def _string_value(self, lexeme: str) -> str:
        return py_ast.literal_eval(lexeme)

    def _match(self, *types: TokenType) -> bool:
        for token_type in types:
            if self._check(token_type):
                self._advance()
                return True
        return False

    def _consume(self, token_type: TokenType, message: str) -> Token:
        if self._check(token_type):
            return self._advance()
        raise self._error(self._peek(), message)

    def _consume_statement_semicolon(self, message: str) -> None:
        if self._match(TokenType.SEMICOLON):
            return

        hint = self._special_operator_hint()
        if hint is not None:
            raise self._error(self._peek(), hint)

        raise self._error(self._peek(), message)

    def _special_operator_hint(self) -> str | None:
        previous = self._previous()
        current = self._peek()

        if current.type not in {TokenType.IDENT, TokenType.KW_SUMMON, TokenType.LPAREN}:
            return None

        if previous.type == TokenType.INT_LITERAL and previous.lexeme == "4":
            return (
                "operador especial incompleto: se encontro '+4' seguido de otra "
                "expresion; quiso decir '<+4'"
            )

        if previous.type == TokenType.INT_LITERAL and previous.lexeme == "5":
            return (
                "operador especial incompleto: se encontro '+5' seguido de otra "
                "expresion; quiso decir '>+5'"
            )

        return None

    def _check(self, token_type: TokenType) -> bool:
        if self._is_at_end():
            return token_type == TokenType.EOF
        return self._peek().type == token_type

    def _check_next(self, token_type: TokenType) -> bool:
        if self.current + 1 >= len(self.tokens):
            return False
        return self.tokens[self.current + 1].type == token_type

    def _peek_next(self) -> Token:
        if self.current + 1 >= len(self.tokens):
            return self.tokens[-1]
        return self.tokens[self.current + 1]

    def _advance(self) -> Token:
        if not self._is_at_end():
            self.current += 1
        return self._previous()

    def _is_at_end(self) -> bool:
        return self._peek().type == TokenType.EOF

    def _peek(self) -> Token:
        return self.tokens[self.current]

    def _previous(self) -> Token:
        return self.tokens[self.current - 1]

    def _error(self, token: Token, message: str) -> ParseError:
        return ParseError(message, token, self.filename)

    def _error_at(self, token: Token, message: str) -> ParseError:
        return ParseError(message, token, self.filename)
