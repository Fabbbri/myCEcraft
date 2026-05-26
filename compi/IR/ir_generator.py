from typing import Any
from ast_nodes import (
    ASTNode, Program, FunctionDeclaration, Block, VariableDeclaration,
    IfStatement, WhileStatement, ForStatement, ExpressionStatement,
    ReturnStatement, BinaryExpression, UnaryExpression, Identifier, Literal, CallExpression,
    ArrayLiteral, IndexExpression, ImportDeclaration
)
from IR.instructions import (
    IRInstruction, IRBinOp, IRUnaryOp, IRAssign, IRLabel,
    IRJump, IRJumpIfFalse, IRCall, IRReturn
)

class IRGenerator:
    """Visita el AST y genera código de tres direcciones (IR)."""

    def __init__(self):
        self.instructions: list[IRInstruction] = []
        self._temp_counter = 0
        self._label_counter = 0
        self._loop_end_labels: list[str] = []
        self._loop_start_labels: list[str] = []

    def _new_temp(self) -> str:
        """Genera un nuevo nombre de variable temporal."""
        t = f"t{self._temp_counter}"
        self._temp_counter += 1
        return t

    def _new_label(self, prefix: str = "L") -> str:
        """Genera un nuevo nombre de etiqueta."""
        name = f"{prefix}{self._label_counter}"
        self._label_counter += 1
        return name

    def _emit(self, instr: IRInstruction) -> None:
        """Añade una instrucción a la lista plana."""
        self.instructions.append(instr)

    def generate(self, program: Program) -> list[IRInstruction]:
        self.instructions.clear()
        self.visit(program)
        return self.instructions

    # === Dispatcher Principal ===

    def visit(self, node: ASTNode) -> Any:
        method_name = f"visit_{type(node).__name__}"
        visitor = getattr(self, method_name, self.generic_visit)
        return visitor(node)

    def generic_visit(self, node: ASTNode) -> None:
        """Si no hay un método específico implementado, lanza un error o ignora."""
        raise NotImplementedError(f"No IR visitor for {type(node).__name__}")

    # === Statements y Nodos de Alto Nivel ===

    def visit_Program(self, node: Program) -> None:
        for decl in node.declarations:
            self.visit(decl)

    def visit_ImportDeclaration(self, node: ImportDeclaration) -> None:
        # Los imports son resueltos e inyectados por el expander,
        # así que para el código generado directamente del IR los podemos ignorar
        pass

    def visit_FunctionDeclaration(self, node: FunctionDeclaration) -> None:
        # Etiqueta para marcar el inicio de la función en el IR
        self._emit(IRLabel(node.name))
        self.visit(node.body)

    def visit_VariableDeclaration(self, node: VariableDeclaration) -> None:
        if node.initializer:
            # Evaluamos la expresión inicializadora primero
            val = self.visit(node.initializer)
            self._emit(IRAssign(val, node.name))

    def visit_Assignment(self, node: Any) -> None:
        # node es de tipo Assignment
        val = self.visit(node.value)
        # target puede ser un Identifier o un IndexExpression (array[x])
        if type(node.target).__name__ == "Identifier":
            self._emit(IRAssign(val, node.target.name))
        elif type(node.target).__name__ == "IndexExpression":
            array_val = self.visit(node.target.target)
            index_val = self.visit(node.target.index)
            # pseudo-instrucción IR para set de arrays: array[index] = val
            self._emit(IRAssign(val, f"{array_val}[{index_val}]"))

    def visit_ExpressionStatement(self, node: ExpressionStatement) -> None:
        self.visit(node.expression)

    # === Expresiones (Devuelven adónde se guardó el resultado) ===

    def visit_Literal(self, node: Literal) -> Any:
        return node.value

    def visit_ArrayLiteral(self, node: ArrayLiteral) -> str:
        # Simplificación: Evaluamos cada elemento para que genere sus constantes
        # y retornamos un nombre ficticio para indicar creación de array
        elements = [str(self.visit(el)) for el in node.elements]
        temp = self._new_temp()
        self._emit(IRAssign(f"[{', '.join(elements)}]", temp))
        return temp

    def visit_IndexExpression(self, node: IndexExpression) -> str:
        array_val = self.visit(node.target)
        index_val = self.visit(node.index)
        temp = self._new_temp()
        
        # En IR puro, un acceso a memoria como array[indice] a menudo se convierte 
        # en una instrucción de puntero especial. Aquí usamos una sintaxis clara.
        self._emit(IRAssign(f"{array_val}[{index_val}]", temp))
        return temp

    def visit_Identifier(self, node: Identifier) -> str:
        # Devolvemos el nombre de la variable
        return node.name

    def visit_BinaryExpression(self, node: BinaryExpression) -> str:
        left_val = self.visit(node.left)
        right_val = self.visit(node.right)
        
        # Para operaciones lógicas compuestas, hay casos especiales,
        # pero para simplificar por ahora, lo tratamos como BinOp directo.
        result_temp = self._new_temp()
        
        # En tu lenguaje a veces hay asignación dentro de binop (ej: a = 5)
        if node.operator == "=":
            # Asumimos que left_val es un string (el nombre de la variable)
            self._emit(IRAssign(right_val, str(left_val)))
            return str(left_val)

        self._emit(IRBinOp(node.operator, left_val, right_val, result_temp))
        return result_temp

    def visit_UnaryExpression(self, node: UnaryExpression) -> str:
        operand_val = self.visit(node.operand)
        result_temp = self._new_temp()
        self._emit(IRUnaryOp(node.operator, operand_val, result_temp))
        return result_temp

    # === Estructuras de Control ===

    def visit_Block(self, node: Block) -> None:
        for stmt in node.statements:
            self.visit(stmt)

    def visit_IfStatement(self, node: IfStatement) -> None:
        cond_val = self.visit(node.condition)
        else_label = self._new_label("L_else_")
        end_label = self._new_label("L_end_if_")

        self._emit(IRJumpIfFalse(cond_val, else_label))
        
        self.visit(node.then_branch)
        self._emit(IRJump(end_label))
        
        self._emit(IRLabel(else_label))
        if node.else_branch:
            self.visit(node.else_branch)
            
        self._emit(IRLabel(end_label))

    def visit_WhileStatement(self, node: WhileStatement) -> None:
        start_label = self._new_label("L_while_start_")
        end_label = self._new_label("L_while_end_")
        
        self._emit(IRLabel(start_label))
        cond_val = self.visit(node.condition)
        self._emit(IRJumpIfFalse(cond_val, end_label))
        
        self.visit(node.body)
        self._emit(IRJump(start_label))
        
        self._emit(IRLabel(end_label))

    def visit_ForStatement(self, node: ForStatement) -> None:
        if node.initializer:
            self.visit(node.initializer)
            
        start_label = self._new_label("L_for_start_")
        end_label = self._new_label("L_for_end_")
        
        self._emit(IRLabel(start_label))
        
        if node.condition:
            cond_val = self.visit(node.condition)
            self._emit(IRJumpIfFalse(cond_val, end_label))
            
        self.visit(node.body)
        
        if node.increment:
            self.visit(node.increment)
            
        self._emit(IRJump(start_label))
        self._emit(IRLabel(end_label))

    # === Llamadas y Retornos ===

    def visit_CallExpression(self, node: CallExpression) -> str:
        args = []
        for arg_node in node.arguments:
            args.append(str(self.visit(arg_node)))
            
        result_temp = self._new_temp()
        self._emit(IRCall(node.name, args, result_temp))
        return result_temp

    def visit_ReturnStatement(self, node: ReturnStatement) -> None:
        if node.value:
            val = self.visit(node.value)
            self._emit(IRReturn(val))
        else:
            self._emit(IRReturn(None))
