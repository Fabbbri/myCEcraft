from __future__ import annotations

from dataclasses import dataclass

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
    Program,
    ReturnStatement,
    TypeNode,
    UnaryExpression,
    VariableDeclaration,
    VaultInstruction,
    WhileStatement,
)
from symbol_table import (
    ChestType,
    DuplicateSymbolError,
    PointerType,
    PrimitiveName,
    PrimitiveType,
    ScopeKind,
    Symbol,
    SymbolKind,
    SymbolTable,
    Type,
)


class SemanticError(Exception):
    """
    Error semantico con ubicacion en el archivo fuente.
    """

    def __init__(
        self,
        message: str,
        node: ASTNode,
        filename: str = "<input>",
    ):
        full_message = (
            f"Error semantico en {filename}, linea {node.line}, "
            f"columna {node.column}: {message}"
        )
        super().__init__(full_message)
        self.node = node
        self.filename = filename


@dataclass
class FunctionFrame:
    """
    Estado de memoria para una funcion.

    Convencion inicial:
    - parametros: offsets positivos desde sp/fp, empezando en +8
    - variables locales: offsets negativos, creciendo hacia abajo
    """

    next_param_offset: int = 8
    next_local_offset: int = 0
    next_vault_offset: int = 0


class SemanticAnalyzer:
    """
    Fase 3: construye tabla de simbolos, scopes y memoria preliminar.
    """

    STACK_ALIGNMENT = 4
    GLOBAL_DATA_BASE = 0x8000

    def __init__(self, filename: str = "<input>"):
        self.filename = filename
        self.symbols = SymbolTable()
        self._current_function: FunctionDeclaration | None = None
        self._current_frame: FunctionFrame | None = None
        self._next_global_address = self.GLOBAL_DATA_BASE
        self._next_vault_address = 0
        self._next_label_id = 0

    def analyze(self, program: Program) -> SymbolTable:
        self._declare_global_signatures(program)
        self._analyze_global_bodies(program)
        return self.symbols

    def _declare_global_signatures(self, program: Program) -> None:
        for declaration in program.declarations:
            if isinstance(declaration, ImportDeclaration):
                self._define_import(declaration)
            elif isinstance(declaration, FunctionDeclaration):
                self._define_function_signature(declaration)

    def _analyze_global_bodies(self, program: Program) -> None:
        for declaration in program.declarations:
            if isinstance(declaration, VariableDeclaration):
                self._declare_variable(declaration, is_global=True)
            elif isinstance(declaration, FunctionDeclaration):
                self._analyze_function(declaration)
            elif isinstance(declaration, ImportDeclaration):
                continue
            else:
                self._analyze_statement(declaration)

    def _define_import(self, node: ImportDeclaration) -> None:
        try:
            self.symbols.define_module_alias(
                alias=node.alias,
                module_name=node.module,
                decl_file=self.filename,
                decl_line=node.line,
                decl_column=node.column,
            )
        except DuplicateSymbolError as error:
            raise SemanticError(str(error), node, self.filename) from error

    def _define_function_signature(self, node: FunctionDeclaration) -> None:
        return_type = self._type_from_node(node.return_type)
        if self._is_ender_type(return_type):
            raise SemanticError(
                "ender solo puede usarse como elemento de chest[ender, N]",
                node.return_type,
                self.filename,
            )
        parameter_types = [self._type_from_node(param.type) for param in node.parameters]

        try:
            symbol = self.symbols.define_function(
                name=node.name,
                return_type=return_type,
                decl_file=self.filename,
                decl_line=node.line,
                decl_column=node.column,
                parameters=parameter_types,
                metadata={
                    "inline": "@inline" in node.pragmas,
                    "parameter_names": [param.name for param in node.parameters],
                },
            )
        except DuplicateSymbolError as error:
            raise SemanticError(str(error), node, self.filename) from error

        symbol.memory_info.segment = "TEXT"
        symbol.memory_info.address = None
        symbol.memory_info.size_in_bytes = 0
        symbol.memory_info.resolved = False

    def _analyze_function(self, node: FunctionDeclaration) -> None:
        previous_function = self._current_function
        previous_frame = self._current_frame

        self._current_function = node
        self._current_frame = FunctionFrame()
        self.symbols.enter_scope(f"function:{node.name}", ScopeKind.FUNCTION)

        for index, parameter in enumerate(node.parameters):
            self._define_parameter(parameter, index)

        self._analyze_block_statements(node.body)

        return_type = self._type_from_node(node.return_type)
        if not self._is_void(return_type) and not self._block_guarantees_return(node.body):
            raise SemanticError(
                f"la funcion '{node.name}' debe retornar un valor en todos los caminos",
                node,
                self.filename,
            )

        frame = self._current_frame
        function_scope = self.symbols.current_scope
        function_scope.name = (
            f"{function_scope.name} "
            f"(stack_size={abs(frame.next_local_offset) if frame else 0})"
        )

        self.symbols.exit_scope()
        self._current_function = previous_function
        self._current_frame = previous_frame

    def _define_parameter(self, node, index: int) -> None:
        parameter_type = self._type_from_node(node.type)
        if self._is_ender_type(parameter_type):
            raise SemanticError(
                "ender solo puede usarse como elemento de chest[ender, N]",
                node.type,
                self.filename,
            )
        try:
            symbol = self.symbols.define_parameter(
                name=node.name,
                symbol_type=parameter_type,
                decl_file=self.filename,
                decl_line=node.line,
                decl_column=node.column,
                metadata={"position": index},
            )
        except DuplicateSymbolError as error:
            raise SemanticError(str(error), node, self.filename) from error

        self._assign_parameter_memory(symbol)

    def _analyze_block(
        self,
        node: Block,
        name: str,
        kind: ScopeKind,
    ) -> None:
        self.symbols.enter_scope(name, kind)
        self._analyze_block_statements(node)
        self.symbols.exit_scope()

    def _analyze_block_statements(self, node: Block) -> None:
        for statement in node.statements:
            self._analyze_statement(statement)

    def _analyze_statement(self, node: ASTNode) -> Type | None:
        if isinstance(node, VariableDeclaration):
            return self._declare_variable(node, is_global=False)
        if isinstance(node, Assignment):
            return self._analyze_assignment(node)
        if isinstance(node, IfStatement):
            return self._analyze_if(node)
        if isinstance(node, WhileStatement):
            return self._analyze_while(node)
        if isinstance(node, ForStatement):
            return self._analyze_for(node)
        if isinstance(node, ReturnStatement):
            return self._analyze_return(node)
        if isinstance(node, EnderPortalStatement):
            return self._analyze_ender_portal_statement(node)
        if isinstance(node, ChangePasswordInstruction):
            return self._analyze_change_password_instruction(node)
        if isinstance(node, VaultInstruction):
            return self._analyze_vault_instruction(node)
        if isinstance(node, ExpressionStatement):
            return self._infer_expression_type(node.expression)
        if isinstance(node, Block):
            self._analyze_block(node, "block", ScopeKind.BLOCK)
            return None

        return self._infer_expression_type(node)

    def _declare_variable(
        self,
        node: VariableDeclaration,
        is_global: bool,
    ) -> Type:
        variable_type = self._type_from_node(node.type)
        if self._is_ender_type(variable_type):
            raise SemanticError(
                "ender solo puede usarse como elemento de chest[ender, N]",
                node.type,
                self.filename,
            )

        if node.initializer is not None:
            init_type = self._infer_expression_type(node.initializer)
            self._check_assignment_compatible(variable_type, init_type, node)

        try:
            symbol = self.symbols.define_variable(
                name=node.name,
                symbol_type=variable_type,
                decl_file=self.filename,
                decl_line=node.line,
                decl_column=node.column,
            )
        except DuplicateSymbolError as error:
            raise SemanticError(str(error), node, self.filename) from error

        if is_global or self._current_frame is None:
            self._assign_global_memory(symbol)
        else:
            self._assign_local_memory(symbol)

        return variable_type

    def _analyze_assignment(self, node: Assignment) -> Type | None:
        target_type = self._infer_assignment_target_type(node.target)
        value_type = self._infer_expression_type(node.value)
        self._check_assignment_compatible(target_type, value_type, node)
        return target_type

    def _analyze_if(self, node: IfStatement) -> None:
        self._infer_expression_type(node.condition)
        self._define_label(node, "if_else")
        self._define_label(node, "if_end")
        self._analyze_block(node.then_branch, "if", ScopeKind.CONDITIONAL)
        if node.else_branch is not None:
            self._analyze_block(node.else_branch, "else", ScopeKind.CONDITIONAL)

    def _analyze_while(self, node: WhileStatement) -> None:
        self._define_label(node, "while_start")
        self._define_label(node, "while_end")
        self._infer_expression_type(node.condition)
        self._analyze_block(node.body, "while", ScopeKind.LOOP)

    def _analyze_for(self, node: ForStatement) -> None:
        self.symbols.enter_scope("for", ScopeKind.LOOP)
        self._define_label(node, "for_start")
        self._define_label(node, "for_end")

        if node.initializer is not None:
            self._analyze_statement(node.initializer)
        if node.condition is not None:
            self._infer_expression_type(node.condition)
        if node.increment is not None:
            self._analyze_statement(node.increment)

        self._analyze_block_statements(node.body)
        self.symbols.exit_scope()

    def _analyze_return(self, node: ReturnStatement) -> Type | None:
        if self._current_function is None:
            raise SemanticError(
                "'return' solo puede usarse dentro de una funcion",
                node,
                self.filename,
            )

        expected = self._type_from_node(self._current_function.return_type)

        if node.value is None:
            if not self._is_void(expected):
                raise SemanticError(
                    f"la funcion '{self._current_function.name}' debe retornar "
                    f"un valor de tipo {expected.describe()}",
                    node,
                    self.filename,
                )
            return None

        value_type = self._infer_expression_type(node.value)
        self._check_assignment_compatible(expected, value_type, node)
        return value_type

    def _analyze_ender_portal_statement(self, node: EnderPortalStatement) -> None:
        password_type = self._infer_expression_type(node.password)
        if not self._is_unknown(password_type) and not self._is_numeric(password_type):
            raise SemanticError(
                "enderPortal espera una clave numerica",
                node.password,
                self.filename,
            )

        if node.body is not None:
            self._analyze_block(node.body, "enderPortal", ScopeKind.BLOCK)

        return None

    def _analyze_change_password_instruction(self, node: ChangePasswordInstruction) -> None:
        value_type = self._infer_expression_type(node.value)
        if not self._is_unknown(value_type) and not self._is_numeric(value_type):
            raise SemanticError(
                "enderchange espera un valor numerico",
                node.value,
                self.filename,
            )

        return None

    def _infer_assignment_target_type(self, node: ASTNode) -> Type:
        if isinstance(node, Identifier):
            return self._require_value_symbol(node).type or self._unknown_type()
        if isinstance(node, IndexExpression):
            target_type = self._infer_expression_type(node.target)
            index_type = self._infer_expression_type(node.index)
            if not self._is_unknown(index_type) and not self._is_numeric(index_type):
                raise SemanticError(
                    "el indice de un chest debe ser numerico",
                    node.index,
                    self.filename,
                )
            if isinstance(target_type, ChestType):
                literal_index = self._literal_integer_value(node.index)
                if literal_index is not None and not 0 <= literal_index < target_type.size:
                    raise SemanticError(
                        f"indice fuera de rango para {target_type.describe()}",
                        node.index,
                        self.filename,
                    )
                return target_type.element_type
            raise SemanticError(
                "solo se puede indexar una variable de tipo chest",
                node,
                self.filename,
            )
        if isinstance(node, MemberExpression):
            return self._infer_expression_type(node)
        raise SemanticError("el lado izquierdo no es asignable", node, self.filename)

    def _infer_expression_type(self, node: ASTNode) -> Type:
        if isinstance(node, Literal):
            return self._literal_type(node)
        if isinstance(node, Identifier):
            symbol = self._require_value_symbol(node)
            return symbol.type or self._unknown_type()
        if isinstance(node, ArrayLiteral):
            return self._array_literal_type(node)
        if isinstance(node, UnaryExpression):
            return self._infer_expression_type(node.operand)
        if isinstance(node, BinaryExpression):
            return self._binary_type(node)
        if isinstance(node, CallExpression):
            return self._call_type(node)
        if isinstance(node, IndexExpression):
            return self._infer_assignment_target_type(node)
        if isinstance(node, MemberExpression):
            self._infer_expression_type(node.target)
            return self._unknown_type()
        if isinstance(node, Assignment):
            return self._analyze_assignment(node) or self._unknown_type()

        raise SemanticError("expresion no soportada por el analizador semantico", node)

    def _require_value_symbol(self, node: Identifier) -> Symbol:
        symbol = self.symbols.lookup(node.name)
        if symbol is None:
            raise SemanticError(
                f"el simbolo '{node.name}' no fue declarado antes de usarse",
                node,
                self.filename,
            )

        if symbol.kind not in {SymbolKind.VARIABLE, SymbolKind.PARAMETER}:
            raise SemanticError(
                f"el simbolo '{node.name}' no es una variable usable en expresiones",
                node,
                self.filename,
            )

        return symbol

    def _call_type(self, node: CallExpression) -> Type:
        if node.module_alias is not None:
            alias_symbol = self.symbols.lookup(node.module_alias)
            if alias_symbol is None or alias_symbol.kind != SymbolKind.MODULE_ALIAS:
                raise SemanticError(
                    f"el alias de modulo '{node.module_alias}' no fue declarado",
                    node,
                    self.filename,
                )
            for argument in node.arguments:
                self._infer_expression_type(argument)
            return self._unknown_type()

        symbol = self.symbols.lookup_global(node.name)
        if symbol is None or symbol.kind != SymbolKind.FUNCTION:
            raise SemanticError(
                f"la funcion '{node.name}' no fue declarada",
                node,
                self.filename,
            )

        expected_types = symbol.metadata.get("parameters", [])
        if len(expected_types) != len(node.arguments):
            raise SemanticError(
                f"la funcion '{node.name}' esperaba {len(expected_types)} argumentos "
                f"pero recibio {len(node.arguments)}",
                node,
                self.filename,
            )

        for argument, expected_type in zip(node.arguments, expected_types):
            actual_type = self._infer_expression_type(argument)
            self._check_assignment_compatible(expected_type, actual_type, argument)

        return symbol.type or self._unknown_type()

    def _binary_type(self, node: BinaryExpression) -> Type:
        left_type = self._infer_expression_type(node.left)
        right_type = self._infer_expression_type(node.right)

        if node.operator in {"==", "!=", "<", ">", "<=", ">="}:
            if not self._are_comparable(left_type, right_type):
                raise SemanticError(
                    f"operacion invalida: no se puede comparar "
                    f"{left_type.describe()} con {right_type.describe()}",
                    node,
                    self.filename,
                )
            return PrimitiveType(PrimitiveName.INT)

        if not self._is_unknown(left_type) and not self._is_numeric(left_type):
            raise SemanticError(
                f"operacion invalida: el operador '{node.operator}' no acepta "
                f"{left_type.describe()}",
                node.left,
                self.filename,
            )

        if not self._is_unknown(right_type) and not self._is_numeric(right_type):
            raise SemanticError(
                f"operacion invalida: el operador '{node.operator}' no acepta "
                f"{right_type.describe()}",
                node.right,
                self.filename,
            )

        if self._is_unknown(left_type):
            return right_type
        return left_type

    def _array_literal_type(self, node: ArrayLiteral) -> Type:
        if not node.elements:
            return ChestType(PrimitiveType(PrimitiveName.INT), 1)

        first_type = self._infer_expression_type(node.elements[0])
        for element in node.elements[1:]:
            element_type = self._infer_expression_type(element)
            self._check_assignment_compatible(first_type, element_type, element)
        return ChestType(first_type, len(node.elements))

    def _literal_type(self, node: Literal) -> Type:
        if node.literal_type == "string":
            return PointerType(PrimitiveType(PrimitiveName.CHAR))
        if node.literal_type == "hex":
            return PrimitiveType(PrimitiveName.UINT32)
        return PrimitiveType(PrimitiveName.INT)

    def _check_assignment_compatible(
        self,
        expected: Type,
        actual: Type,
        node: ASTNode,
    ) -> None:
        if self._is_unknown(expected) or self._is_unknown(actual):
            return

        if expected.describe() == actual.describe():
            return

        if self._is_numeric(expected) and self._is_numeric(actual):
            return

        if isinstance(expected, ChestType) and isinstance(actual, ChestType):
            if self._is_ender_type(expected.element_type) and self._is_numeric(actual.element_type):
                if actual.size <= expected.size:
                    return

            if expected.element_type.describe() == actual.element_type.describe():
                if actual.size <= expected.size:
                    return

        raise SemanticError(
            f"tipo incompatible: se esperaba {expected.describe()} "
            f"pero se obtuvo {actual.describe()}",
            node,
            self.filename,
        )

    def _are_comparable(self, left_type: Type, right_type: Type) -> bool:
        if self._is_unknown(left_type) or self._is_unknown(right_type):
            return True
        if left_type.describe() == right_type.describe():
            return True
        return self._is_numeric(left_type) and self._is_numeric(right_type)

    def _type_from_node(self, node: TypeNode) -> Type:
        if node.name == "int":
            return PrimitiveType(PrimitiveName.INT)
        if node.name == "uint32":
            return PrimitiveType(PrimitiveName.UINT32)
        if node.name == "uint16":
            return PrimitiveType(PrimitiveName.UINT16)
        if node.name == "char":
            return PrimitiveType(PrimitiveName.CHAR)
        if node.name == "void":
            return PrimitiveType(PrimitiveName.VOID)
        if node.name == "ender":
            return PrimitiveType(PrimitiveName.ENDER)
        if node.name == "pointer":
            base = (
                self._type_from_node(node.base_type)
                if node.base_type is not None
                else None
            )
            return PointerType(base)
        if node.name == "chest":
            if node.base_type is None or node.size is None:
                raise SemanticError("tipo chest incompleto", node, self.filename)
            return ChestType(self._type_from_node(node.base_type), node.size)

        raise SemanticError(f"tipo desconocido '{node.name}'", node, self.filename)

    def _define_label(self, node: ASTNode, role: str) -> Symbol:
        label_name = f".L{self._next_label_id}_{role}"
        self._next_label_id += 1

        label_map = getattr(node, "_semantic_labels", None)
        if not isinstance(label_map, dict):
            label_map = {}
            setattr(node, "_semantic_labels", label_map)
        label_map[role] = label_name

        symbol = self.symbols.define_label(
            name=label_name,
            decl_file=self.filename,
            decl_line=node.line,
            decl_column=node.column,
            metadata={
                "role": role,
                "owner": node.__class__.__name__,
                "address_pending": True,
            },
        )
        symbol.memory_info.segment = "TEXT"
        symbol.memory_info.address = None
        symbol.memory_info.size_in_bytes = 0
        symbol.memory_info.resolved = False
        return symbol

    def _assign_global_memory(self, symbol: Symbol) -> None:
        size = self._align(self._type_size(symbol.type))
        if self._is_ender_chest_type(symbol.type):
            symbol.memory_info.segment = "VAULT"
            symbol.memory_info.address = self._next_vault_address
            symbol.memory_info.offset = self._next_vault_address
            symbol.memory_info.size_in_bytes = size
            symbol.memory_info.resolved = True
            self._next_vault_address += size
            return

        symbol.memory_info.segment = "DATA"
        symbol.memory_info.address = self._next_global_address
        symbol.memory_info.offset = None
        symbol.memory_info.size_in_bytes = size
        symbol.memory_info.resolved = True
        self._next_global_address += size

    def _assign_parameter_memory(self, symbol: Symbol) -> None:
        if self._current_frame is None:
            return

        size = self._align(self._type_size(symbol.type))
        symbol.memory_info.segment = "STACK"
        symbol.memory_info.address = None
        symbol.memory_info.offset = self._current_frame.next_param_offset
        symbol.memory_info.size_in_bytes = size
        symbol.memory_info.resolved = True
        self._current_frame.next_param_offset += size

    def _assign_local_memory(self, symbol: Symbol) -> None:
        if self._current_frame is None:
            return

        size = self._align(self._type_size(symbol.type))
        if self._is_ender_chest_type(symbol.type):
            symbol.memory_info.segment = "VAULT"
            symbol.memory_info.address = self._current_frame.next_vault_offset
            symbol.memory_info.offset = self._current_frame.next_vault_offset
            symbol.memory_info.size_in_bytes = size
            symbol.memory_info.resolved = True
            self._current_frame.next_vault_offset += size
            return

        self._current_frame.next_local_offset -= size
        symbol.memory_info.segment = "STACK"
        symbol.memory_info.address = None
        symbol.memory_info.offset = self._current_frame.next_local_offset
        symbol.memory_info.size_in_bytes = size
        symbol.memory_info.resolved = True

    def _type_size(self, symbol_type: Type | None) -> int:
        if symbol_type is None:
            return 0
        if isinstance(symbol_type, PrimitiveType):
            return {
                PrimitiveName.INT: 4,
                PrimitiveName.UINT32: 4,
                PrimitiveName.UINT16: 2,
                PrimitiveName.CHAR: 1,
                PrimitiveName.VOID: 0,
                PrimitiveName.ENDER: 4,
            }[symbol_type.name]
        if isinstance(symbol_type, PointerType):
            return 4
        if isinstance(symbol_type, ChestType):
            return self._type_size(symbol_type.element_type) * symbol_type.size
        return 0

    def _align(self, size: int) -> int:
        if size == 0:
            return 0
        return ((size + self.STACK_ALIGNMENT - 1) // self.STACK_ALIGNMENT) * self.STACK_ALIGNMENT

    def _is_numeric(self, symbol_type: Type) -> bool:
        return isinstance(symbol_type, PrimitiveType) and symbol_type.name in {
            PrimitiveName.INT,
            PrimitiveName.UINT32,
            PrimitiveName.UINT16,
            PrimitiveName.CHAR,
        }

    def _is_ender_type(self, symbol_type: Type | None) -> bool:
        return (
            isinstance(symbol_type, PrimitiveType)
            and symbol_type.name == PrimitiveName.ENDER
        )

    def _is_ender_chest_type(self, symbol_type: Type | None) -> bool:
        return (
            isinstance(symbol_type, ChestType)
            and self._is_ender_type(symbol_type.element_type)
        )

    def _unknown_type(self) -> Type:
        return PointerType(None)

    def _is_unknown(self, symbol_type: Type) -> bool:
        return isinstance(symbol_type, PointerType) and symbol_type.base_type is None

    def _is_void(self, symbol_type: Type) -> bool:
        return (
            isinstance(symbol_type, PrimitiveType)
            and symbol_type.name == PrimitiveName.VOID
        )

    def _literal_integer_value(self, node: ASTNode) -> int | None:
        if isinstance(node, Literal) and node.literal_type in {"int", "hex"}:
            return int(node.value)
        if (
            isinstance(node, UnaryExpression)
            and node.operator == "-"
            and isinstance(node.operand, Literal)
            and node.operand.literal_type in {"int", "hex"}
        ):
            return -int(node.operand.value)
        return None

    def _analyze_vault_instruction(self, node: VaultInstruction) -> None:
        expected_arity = {
            "enderopen": {1, 2},
            "enderclose": {0},
            "enderload": {2},
            "enderstore": {2},
            "enderkey": {2},
            "enderlow": {3},
            "enderhigh": {3},
            "close": {0},
        }

        allowed = expected_arity.get(node.keyword)
        if allowed is None:
            raise SemanticError(
                f"instruccion de boveda desconocida '{node.keyword}'",
                node,
                self.filename,
            )

        if len(node.operands) not in allowed:
            expected = " o ".join(str(count) for count in sorted(allowed))
            raise SemanticError(
                f"'{node.keyword}' esperaba {expected} operandos "
                f"pero recibio {len(node.operands)}",
                node,
                self.filename,
            )

        return None

    def _block_guarantees_return(self, block: Block) -> bool:
        for statement in block.statements:
            if self._statement_guarantees_return(statement):
                return True
        return False

    def _statement_guarantees_return(self, statement: ASTNode) -> bool:
        if isinstance(statement, ReturnStatement):
            return statement.value is not None
        if isinstance(statement, Block):
            return self._block_guarantees_return(statement)
        if isinstance(statement, IfStatement):
            if statement.else_branch is None:
                return False
            return (
                self._block_guarantees_return(statement.then_branch)
                and self._block_guarantees_return(statement.else_branch)
            )
        return False
