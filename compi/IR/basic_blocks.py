from typing import Any, Dict, List
from IR.instructions import (
    IRAssign,
    IRArrayAssign,
    IRBinOp,
    IRCall,
    IRCommit,
    IRInstruction,
    IRJump,
    IRJumpIfFalse,
    IRLabel,
    IRReturn,
    IRUnaryOp,
    IRVaultInstruction,
)

class BasicBlock:
    """
    Un Bloque Básico es una secuencia de instrucciones de 3 direcciones
    con un único punto de entrada (la primera instrucción) 
    y un único punto de salida (la última instrucción: salto, return, o caída libre).
    """
    def __init__(self, name: str):
        self.name = name
        self.instructions: List[IRInstruction] = []
        # Para el Análisis de Flujo de Control (Grafo)
        self.predecessors: List['BasicBlock'] = []
        self.successors: List['BasicBlock'] = []

    def add_instruction(self, instr: IRInstruction):
        self.instructions.append(instr)
        
    def __repr__(self):
        return f"BasicBlock({self.name}, {len(self.instructions)} instrs)"


class ControlFlowGraph:
    """
    Representa el flujo completo del programa organizado por Bloques Básicos.
    """
    def __init__(self):
        self.blocks: List[BasicBlock] = []
        # Diccionario para mapear nombres de funciones o etiquetas a sus bloques
        self.label_to_block: Dict[str, BasicBlock] = {}

    def build_from_ir(self, ir_instructions: List[IRInstruction]):
        self.blocks.clear()
        self.label_to_block.clear()
        
        if not ir_instructions:
            return
            
        # 1. Crear el primer bloque de entrada general para el archivo
        current_block = BasicBlock("B_entry")
        self.blocks.append(current_block)
        
        block_counter = 0
        
        for instr in ir_instructions:
            # Si encontramos una etiqueta, INICIA un bloque básico nuevo.
            if isinstance(instr, IRLabel):
                # Si el bloque actual NO estaba vacío y no había sido cerrado 
                # (caída libre), creamos uno nuevo explícito
                if current_block.instructions:
                    block_counter += 1
                    current_block = BasicBlock(f"B_label_{instr.name}")
                    self.blocks.append(current_block)
                else:
                    # Renombramos el bloque vacío actual
                    current_block.name = f"B_label_{instr.name}"
                
                # Registramos el bloque de esta etiqueta
                self.label_to_block[instr.name] = current_block
                current_block.add_instruction(instr)
                
            # Instrucciones normales
            else:
                current_block.add_instruction(instr)
                
                # Si es una instrucción de TERMINACIÓN (Jump o Return)
                # se CIERRA el bloque básico actual inmediatamente.
                if isinstance(instr, (IRJump, IRJumpIfFalse, IRReturn)):
                    block_counter += 1
                    current_block = BasicBlock(f"B_fallthrough_{block_counter}")
                    self.blocks.append(current_block)
                    
        # Limpieza: Si el último bloque quedó vacío por no tener instrucciones 'fallthrough',
        # lo removemos (esto pasa si el IR termina en un Jump o Return directo).
        if not current_block.instructions:
            self.blocks.remove(current_block)

        # 2. Conectar los Bordes (Control Flow Edges)
        self._connect_cfg_edges()

    def _connect_cfg_edges(self):
        """Conecta sucesores y predecesores para formar el grafo directo."""
        for i, block in enumerate(self.blocks):
            if not block.instructions:
                continue
                
            last_instr = block.instructions[-1]
            
            # Si termina en salto incondicional -> Se conecta a la etiqueta destino.
            if isinstance(last_instr, IRJump):
                dest_block = self.label_to_block.get(last_instr.label)
                if dest_block:
                    block.successors.append(dest_block)
                    dest_block.predecessors.append(block)
                    
            # Si termina en salto condicional -> Se conecta al branch de la etiqueta AND al bloque siguiente.
            elif isinstance(last_instr, IRJumpIfFalse):
                # Primero el destino si es False
                dest_block = self.label_to_block.get(last_instr.label)
                if dest_block:
                    block.successors.append(dest_block)
                    dest_block.predecessors.append(block)
                
                # Luego la "caída lógica" (Next Block en el orden físico) si es True
                if i + 1 < len(self.blocks):
                    next_block = self.blocks[i + 1]
                    block.successors.append(next_block)
                    next_block.predecessors.append(block)

            # Si es Return -> No tiene sucesores, sale de la función actual.
            elif isinstance(last_instr, IRReturn):
                pass
                
            # Si termina en cualquier otra instrucción (ej: una asignación) -> Simplemente cae al bloque siguiente
            else:
                if i + 1 < len(self.blocks):
                    next_block = self.blocks[i + 1]
                    block.successors.append(next_block)
                    next_block.predecessors.append(block)

    def print_blocks(self) -> str:
        """Genera un reporte del grafo y bloques para validación."""
        lines = ["=== Control Flow Graph & Basic Blocks ==="]
        for block in self.blocks:
            lines.append(f"\n[{block.name}]")
            # Mostrar referencias a sucesores
            succs = [s.name for s in block.successors]
            if succs:
                lines.append(f"  -> Sucesores: {', '.join(succs)}")
            for instr in block.instructions:
                lines.append(f"    {self.format_instruction(instr)}")
        return "\n".join(lines)

    @staticmethod
    def format_instruction(instr: IRInstruction) -> str:
        if isinstance(instr, IRLabel):
            return f"{instr.name}:"
        if isinstance(instr, IRJump):
            return f"goto {instr.label}"
        if isinstance(instr, IRJumpIfFalse):
            return f"ifFalse {instr.condition} goto {instr.label}"
        if isinstance(instr, IRBinOp):
            return f"{instr.result} = {instr.left} {instr.op} {instr.right}"
        if isinstance(instr, IRUnaryOp):
            return f"{instr.result} = {instr.op}{instr.operand}"
        if isinstance(instr, IRAssign):
            return f"{instr.result} = {instr.source}"
        if isinstance(instr, IRCommit):
            return f"commit {instr.result} = {instr.source}"
        if isinstance(instr, IRArrayAssign):
            elements = ", ".join(str(element) for element in instr.elements)
            return f"{instr.result} = [{elements}]"
        if isinstance(instr, IRCall):
            arguments = ", ".join(str(argument) for argument in instr.args)
            call = f"call {instr.func_name}({arguments})"
            return f"{instr.result} = {call}" if instr.result else call
        if isinstance(instr, IRVaultInstruction):
            operands = ", ".join(str(operand) for operand in instr.operands)
            suffix = f" {operands}" if operands else ""
            return f"vault {instr.keyword}{suffix}"
        if isinstance(instr, IRReturn):
            return f"return {instr.value}"
        return str(instr)

    def to_dot(self, graph_name: str = "CFG") -> str:
        """Genera un grafo DOT listo para Graphviz."""
        lines = [
            f'digraph "{self._dot_escape(graph_name)}" {{',
            "  rankdir=TB;",
            '  graph [fontname="Helvetica", labelloc="t"];',
            '  node [shape=box, fontname="Courier", style="rounded"];',
            '  edge [fontname="Helvetica"];',
            "",
        ]

        for block in self.blocks:
            instructions = [
                self.format_instruction(instruction)
                for instruction in block.instructions
            ]
            label_lines = [block.name, *instructions]
            label = r"\l".join(
                self._dot_escape(line)
                for line in label_lines
            ) + r"\l"
            lines.append(
                f'  "{self._dot_escape(block.name)}" [label="{label}"];'
            )

        lines.append("")
        for edge in self._edges():
            color = {
                "branch_true": "#2E8B57",
                "branch_false": "#B22222",
                "jump": "#4169E1",
                "fallthrough": "#555555",
            }.get(edge["type"], "#555555")
            lines.append(
                f'  "{self._dot_escape(edge["source"])}" -> '
                f'"{self._dot_escape(edge["target"])}" '
                f'[label="{self._dot_escape(edge["label"])}", color="{color}"];'
            )

        lines.append("}")
        return "\n".join(lines)

    @staticmethod
    def _dot_escape(value: Any) -> str:
        return (
            str(value)
            .replace("\\", "\\\\")
            .replace('"', '\\"')
            .replace("\r", "")
            .replace("\n", r"\n")
        )

    def _edges(self) -> list[dict[str, str]]:
        edges: list[dict[str, str]] = []
        for block_index, block in enumerate(self.blocks):
            if not block.instructions:
                continue
            last = block.instructions[-1]
            for successor_index, successor in enumerate(block.successors):
                edge_type, label = self._edge_kind(
                    block_index,
                    successor_index,
                    last,
                    successor,
                )
                edges.append(
                    {
                        "id": f"e{len(edges)}",
                        "source": block.name,
                        "target": successor.name,
                        "type": edge_type,
                        "label": label,
                    }
                )
        return edges

    def _edge_kind(
        self,
        block_index: int,
        successor_index: int,
        last: IRInstruction,
        successor: BasicBlock,
    ) -> tuple[str, str]:
        if isinstance(last, IRJump):
            return "jump", "jump"
        if isinstance(last, IRJumpIfFalse):
            if successor.name == getattr(
                self.label_to_block.get(last.label),
                "name",
                None,
            ):
                return "branch_false", "false"
            return "branch_true", "true"
        if block_index + 1 < len(self.blocks):
            return "fallthrough", "fallthrough"
        return f"successor_{successor_index}", ""
