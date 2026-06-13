"""
Visor de archivos .cfg.dot generados por el compilador.
Parsea el formato DOT y renderiza el grafo usando QGraphicsScene sin depender de Graphviz.
"""
import re
from pathlib import Path
from dataclasses import dataclass, field

from PySide6.QtCore import Qt, QRectF, QPointF
from PySide6.QtGui import (
    QColor, QFont, QPen, QBrush, QPainter, QPainterPath, QFontMetrics,
)
from PySide6.QtWidgets import (
    QFrame,
    QGraphicsItem,
    QGraphicsPathItem,
    QGraphicsScene,
    QGraphicsView,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QPushButton,
    QVBoxLayout,
    QWidget,
)


class _ZoomableView(QGraphicsView):
    """QGraphicsView con zoom via rueda del mouse."""

    def wheelEvent(self, event) -> None:
        factor = 1.15 if event.angleDelta().y() > 0 else 1 / 1.15
        self.scale(factor, factor)


# ── Colores del tema ────────────────────────────────────────────────────────
BG_COLOR        = QColor("#1E1E1E")
NODE_BG         = QColor("#2D2D2D")
NODE_BORDER     = QColor("#3C3C3C")
NODE_HEADER_BG  = QColor("#37373F")
TEXT_COLOR      = QColor("#CCCCCC")
HEADER_COLOR    = QColor("#9CDCFE")
EDGE_TRUE       = QColor("#2E8B57")
EDGE_FALSE      = QColor("#B22222")
EDGE_JUMP       = QColor("#4169E1")
EDGE_FALL       = QColor("#888888")
LABEL_COLOR     = QColor("#AAAAAA")

NODE_W          = 240
NODE_PADDING    = 10
LINE_H          = 16
HEADER_H        = 22
H_GAP           = 60
V_GAP           = 80


# ── Parser DOT ──────────────────────────────────────────────────────────────
@dataclass
class DotNode:
    id: str
    label: str = ""


@dataclass
class DotEdge:
    src: str
    dst: str
    label: str = ""
    color: str = "#888888"


def _unquote(s: str) -> str:
    s = s.strip()
    if s.startswith('"') and s.endswith('"'):
        return s[1:-1]
    return s


def parse_dot(text: str) -> tuple[list[DotNode], list[DotEdge]]:
    nodes: dict[str, DotNode] = {}
    edges: list[DotEdge] = []

    # Regex que captura el id del nodo o edge, luego busca atributos en la línea completa.
    # No intentamos capturar el bloque [...] completo porque puede contener ']' dentro
    # de strings (ej: label="A[t7]"). En cambio buscamos cada atributo directamente.
    node_re  = re.compile(r'^\s*"([^"]+)"\s*\[')
    edge_re  = re.compile(r'^\s*"([^"]+)"\s*->\s*"([^"]+)"\s*(?:\[|;)')
    label_re = re.compile(r'label\s*=\s*"((?:[^"\\]|\\.)*)"')
    color_re = re.compile(r'color\s*=\s*"([^"]+)"')

    for raw_line in text.splitlines():
        line = raw_line.strip()

        # ── edge ────────────────────────────────────────────────────────────
        m = edge_re.match(line)
        if m:
            src, dst = m.group(1), m.group(2)
            lbl = label_re.search(line)
            clr = color_re.search(line)
            edges.append(DotEdge(
                src=src, dst=dst,
                label=lbl.group(1) if lbl else "",
                color=clr.group(1) if clr else "#888888",
            ))
            continue

        # ── node ────────────────────────────────────────────────────────────
        m = node_re.match(line)
        if m:
            nid = m.group(1)
            lbl = label_re.search(line)
            raw_label = lbl.group(1) if lbl else nid
            label_text = raw_label.replace("\\l", "\n").replace("\\n", "\n").rstrip("\n")
            nodes[nid] = DotNode(id=nid, label=label_text)

    # Nodos referenciados en edges pero sin declaración explícita
    for e in edges:
        for nid in (e.src, e.dst):
            if nid not in nodes:
                nodes[nid] = DotNode(id=nid, label=nid)

    return list(nodes.values()), edges


# ── Layout: longest-path ranking (ignora back-edges) ────────────────────────
def _detect_back_edges(
    n: int,
    children: list[list[int]],
    roots: list[int],
) -> set[tuple[int, int]]:
    """DFS iterativo para detectar back-edges (aristas a ancestros en el stack)."""
    back: set[tuple[int, int]] = set()
    WHITE, GRAY, BLACK = 0, 1, 2
    color = [WHITE] * n
    for root in roots:
        stack = [(root, iter(children[root]))]
        color[root] = GRAY
        while stack:
            node, it = stack[-1]
            try:
                child = next(it)
                if color[child] == GRAY:
                    back.add((node, child))
                elif color[child] == WHITE:
                    color[child] = GRAY
                    stack.append((child, iter(children[child])))
            except StopIteration:
                color[node] = BLACK
                stack.pop()
    return back


def _layout(nodes: list[DotNode], edges: list[DotEdge]) -> dict[str, QPointF]:
    if not nodes:
        return {}

    id_to_idx = {n.id: i for i, n in enumerate(nodes)}
    n = len(nodes)
    children: list[list[int]] = [[] for _ in range(n)]
    parents:  list[list[int]] = [[] for _ in range(n)]

    for e in edges:
        si = id_to_idx.get(e.src, -1)
        di = id_to_idx.get(e.dst, -1)
        if si != -1 and di != -1:
            children[si].append(di)
            parents[di].append(si)

    # Raíces: nodos sin padres en el grafo original
    roots = [i for i in range(n) if not parents[i]]
    if not roots:
        roots = [0]

    # Detectar back-edges para excluirlos del ranking
    back_edges = _detect_back_edges(n, children, roots)

    # DAG-children: solo aristas que NO son back-edges
    dag_children: list[list[int]] = [[] for _ in range(n)]
    dag_parents:  list[list[int]] = [[] for _ in range(n)]
    for e in edges:
        si = id_to_idx.get(e.src, -1)
        di = id_to_idx.get(e.dst, -1)
        if si != -1 and di != -1 and (si, di) not in back_edges:
            dag_children[si].append(di)
            dag_parents[di].append(si)

    # Longest-path ranking: capa = max(capa del padre + 1) para todos los padres DAG
    # Procesamos en orden topológico (Kahn sobre el DAG)
    in_deg = [len(dag_parents[i]) for i in range(n)]
    topo_queue = [i for i in range(n) if in_deg[i] == 0]
    layer = [0] * n
    head = 0
    while head < len(topo_queue):
        u = topo_queue[head]; head += 1
        for v in dag_children[u]:
            layer[v] = max(layer[v], layer[u] + 1)
            in_deg[v] -= 1
            if in_deg[v] == 0:
                topo_queue.append(v)

    # Nodos no alcanzados (ciclos puros residuales) → capa máxima + 1
    if topo_queue:
        max_layer = max(layer[i] for i in topo_queue)
    else:
        max_layer = 0
    for i in range(n):
        if i not in set(topo_queue):
            layer[i] = max_layer + 1

    # Calcular dimensiones reales de cada nodo
    node_w, node_h = _node_dims_all(nodes)

    # Agrupar por capa
    layers: dict[int, list[int]] = {}
    for i, l in enumerate(layer):
        layers.setdefault(l, []).append(i)

    # Calcular la posición Y acumulada capa por capa usando la altura máxima real
    layer_y: dict[int, float] = {}
    y_cursor = 0.0
    for lvl in sorted(layers):
        layer_y[lvl] = y_cursor
        max_h = max(node_h[idx] for idx in layers[lvl])
        y_cursor += max_h + V_GAP

    positions: dict[str, QPointF] = {}
    for lvl in sorted(layers):
        members = layers[lvl]
        widths = [node_w[idx] for idx in members]
        total_w = sum(widths) + (len(members) - 1) * H_GAP
        start_x = -total_w / 2
        x_cursor = start_x
        y = layer_y[lvl]
        for idx, w in zip(members, widths):
            positions[nodes[idx].id] = QPointF(x_cursor, y)
            x_cursor += w + H_GAP

    return positions


# ── Cálculo de dimensiones reales de nodos ───────────────────────────────────
# Aproximación de ancho de texto en Cascadia Mono 8pt (≈6.5 px/char)
_CHAR_W = 6.5
_MIN_W  = NODE_W  # nunca menor que el ancho base

def _node_dims_all(
    nodes: list[DotNode],
) -> tuple[list[float], list[float]]:
    widths: list[float] = []
    heights: list[float] = []
    for node in nodes:
        lines = node.label.split("\n")
        body = lines[1:] if len(lines) > 1 else []
        h = float(HEADER_H + NODE_PADDING + len(body) * LINE_H + NODE_PADDING)
        max_chars = max((len(l) for l in lines), default=0)
        w = max(max_chars * _CHAR_W + NODE_PADDING * 2, _MIN_W)
        widths.append(w)
        heights.append(h)
    return widths, heights


# ── Ítem nodo ───────────────────────────────────────────────────────────────
class NodeItem(QGraphicsItem):
    def __init__(self, node: DotNode) -> None:
        super().__init__()
        self.node = node
        lines = node.label.split("\n")
        self.header = lines[0] if lines else node.id
        self.body_lines = lines[1:] if len(lines) > 1 else []
        self._h = float(HEADER_H + NODE_PADDING + len(self.body_lines) * LINE_H + NODE_PADDING)
        max_chars = max((len(l) for l in lines), default=0)
        self._w = max(max_chars * _CHAR_W + NODE_PADDING * 2, float(_MIN_W))
        self.setFlag(QGraphicsItem.ItemIsMovable, False)

    def width(self) -> float:
        return self._w

    def height(self) -> float:
        return self._h

    def center_bottom(self) -> QPointF:
        return self.pos() + QPointF(self._w / 2, self._h)

    def center_top(self) -> QPointF:
        return self.pos() + QPointF(self._w / 2, 0)

    def boundingRect(self) -> QRectF:
        return QRectF(0, 0, self._w, self._h)

    def paint(self, painter: QPainter, option, widget=None) -> None:
        painter.setRenderHint(QPainter.Antialiasing)
        w = self._w
        rect = QRectF(0, 0, w, self._h)

        # Sombra suave
        painter.setPen(Qt.NoPen)
        painter.setBrush(QBrush(QColor(0, 0, 0, 60)))
        painter.drawRoundedRect(rect.adjusted(3, 3, 3, 3), 6, 6)

        # Fondo
        painter.setBrush(QBrush(NODE_BG))
        painter.setPen(QPen(NODE_BORDER, 1))
        painter.drawRoundedRect(rect, 6, 6)

        # Header
        painter.setBrush(QBrush(NODE_HEADER_BG))
        painter.setPen(Qt.NoPen)
        clip_path = QPainterPath()
        clip_path.addRect(QRectF(0, 0, w, HEADER_H))
        header_path = QPainterPath()
        header_path.addRoundedRect(QRectF(0, 0, w, HEADER_H + 6), 6, 6)
        painter.setClipPath(clip_path)
        painter.drawPath(header_path)
        painter.setClipping(False)

        # Separador bajo header
        painter.setPen(QPen(NODE_BORDER, 1))
        painter.drawLine(QPointF(0, HEADER_H), QPointF(w, HEADER_H))

        # Texto header
        font_h = QFont("Cascadia Mono", 8)
        font_h.setBold(True)
        painter.setFont(font_h)
        painter.setPen(QPen(HEADER_COLOR))
        painter.drawText(
            QRectF(NODE_PADDING, 0, w - NODE_PADDING * 2, HEADER_H),
            Qt.AlignVCenter | Qt.AlignLeft,
            self.header,
        )

        # Líneas del cuerpo
        font_b = QFont("Cascadia Mono", 8)
        painter.setFont(font_b)
        painter.setPen(QPen(TEXT_COLOR))
        y = HEADER_H + NODE_PADDING
        for line in self.body_lines:
            painter.drawText(
                QRectF(NODE_PADDING, y, w - NODE_PADDING * 2, LINE_H),
                Qt.AlignVCenter | Qt.AlignLeft,
                line,
            )
            y += LINE_H


# ── Ítem arista con flecha ──────────────────────────────────────────────────
import math

ARROW_LEN = 10   # longitud del triángulo de flecha
ARROW_W   = 4    # semiancho del triángulo
CTRL_PULL = 0.45 # fracción de distancia vertical que usan los puntos de control bezier


class EdgeItem(QGraphicsPathItem):

    def __init__(
        self,
        src_item: NodeItem,
        dst_item: NodeItem,
        edge: DotEdge,
        src_offset: float = 0.0,  # desplazamiento x en el punto de salida
        dst_offset: float = 0.0,  # desplazamiento x en el punto de llegada
    ) -> None:
        super().__init__()
        self.src_item   = src_item
        self.dst_item   = dst_item
        self.edge       = edge
        self._src_off   = src_offset
        self._dst_off   = dst_offset
        self._color     = QColor(edge.color)
        self._pen       = QPen(self._color, 1.7)
        self._pen.setCapStyle(Qt.RoundCap)
        self._pen.setJoinStyle(Qt.RoundJoin)
        self.setPen(self._pen)
        self.setBrush(Qt.NoBrush)
        self.setZValue(-1)
        self._line_path  = QPainterPath()
        self._arrow_path = QPainterPath()
        self._label_pos  = QPointF()
        self._build_paths()

    # ── construcción de la curva ────────────────────────────────────────────
    def _build_paths(self) -> None:
        bot = self.src_item.center_bottom()
        p1  = QPointF(bot.x() + self._src_off, bot.y())

        top = self.dst_item.center_top()
        tip = QPointF(top.x() + self._dst_off, top.y())

        dy = tip.y() - p1.y()
        is_back = dy <= 20  # back-edge: el destino está en la misma capa o arriba

        if is_back:
            # Curva que sale por el lado derecho del grafo para no cruzar nodos.
            # La amplitud lateral depende de la distancia vertical.
            lateral = max(abs(dy) * 0.6, NODE_W * 0.9) + abs(self._src_off) * 0.5
            # Sale hacia la derecha desde el lado derecho del src
            src_right = QPointF(
                self.src_item.pos().x() + self.src_item.width() + self._src_off,
                bot.y(),
            )
            dst_right = QPointF(
                self.dst_item.pos().x() + self.dst_item.width() + self._dst_off,
                top.y(),
            )
            far_x = max(src_right.x(), dst_right.x()) + lateral
            c1 = QPointF(far_x, src_right.y())
            c2 = QPointF(far_x, dst_right.y())
            p1  = src_right
            tip_base = dst_right  # la punta llega al borde derecho
            # Para back-edges la flecha apunta hacia la izquierda (entrando por el lado)
            tip = tip_base
        else:
            pull = max(dy * CTRL_PULL, 60)
            c1 = QPointF(p1.x(), p1.y() + pull)
            c2 = QPointF(tip.x(), tip.y() - pull)

        # Calcular punto final de la línea (97% del bezier, deja espacio a la flecha)
        t_stop = 0.97
        lx = _bezier(p1.x(), c1.x(), c2.x(), tip.x(), t_stop)
        ly = _bezier(p1.y(), c1.y(), c2.y(), tip.y(), t_stop)

        path = QPainterPath(p1)
        path.cubicTo(c1, c2, QPointF(lx, ly))
        self._line_path = path

        # ── flecha (tangente real del bezier en t=1) ─────────────────────────
        tx = _bezier_deriv(p1.x(), c1.x(), c2.x(), tip.x(), 1.0)
        ty = _bezier_deriv(p1.y(), c1.y(), c2.y(), tip.y(), 1.0)
        length = math.hypot(tx, ty)
        if length < 1e-6:
            tx, ty = 1.0, 0.0
        else:
            tx /= length
            ty /= length

        bx = tip.x() - tx * ARROW_LEN
        by = tip.y() - ty * ARROW_LEN
        px_l = QPointF(bx - ty * ARROW_W, by + tx * ARROW_W)
        px_r = QPointF(bx + ty * ARROW_W, by - tx * ARROW_W)

        arrow = QPainterPath()
        arrow.moveTo(tip)
        arrow.lineTo(px_l)
        arrow.lineTo(px_r)
        arrow.closeSubpath()
        self._arrow_path = arrow

        mx = _bezier(p1.x(), c1.x(), c2.x(), tip.x(), 0.5)
        my = _bezier(p1.y(), c1.y(), c2.y(), tip.y(), 0.5)
        self._label_pos = QPointF(mx, my)

        combined = QPainterPath(path)
        combined.addPath(arrow)
        self.setPath(combined)

    # ── pintado ─────────────────────────────────────────────────────────────
    def paint(self, painter: QPainter, option, widget=None) -> None:
        painter.setRenderHint(QPainter.Antialiasing)

        painter.setPen(self._pen)
        painter.setBrush(Qt.NoBrush)
        painter.drawPath(self._line_path)

        painter.setPen(Qt.NoPen)
        painter.setBrush(QBrush(self._color))
        painter.drawPath(self._arrow_path)

        if self.edge.label:
            font = QFont("Inter", 7)
            painter.setFont(font)
            painter.setPen(QPen(LABEL_COLOR))
            # Offset perpendicular pequeño para que no tape la línea
            painter.drawText(self._label_pos + QPointF(6, -4), self.edge.label)


# ── helpers bezier ───────────────────────────────────────────────────────────
def _bezier(p0: float, p1: float, p2: float, p3: float, t: float) -> float:
    u = 1 - t
    return u**3 * p0 + 3 * u**2 * t * p1 + 3 * u * t**2 * p2 + t**3 * p3


def _bezier_deriv(p0: float, p1: float, p2: float, p3: float, t: float) -> float:
    """Derivada del bezier cúbico (dirección tangente)."""
    u = 1 - t
    return 3 * (u**2 * (p1 - p0) + 2 * u * t * (p2 - p1) + t**2 * (p3 - p2))


# ── Widget principal ─────────────────────────────────────────────────────────
class CFGViewer(QWidget):
    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self._dot_paths: list[Path] = []
        self._node_items: dict[str, NodeItem] = {}
        self._edge_items: list[EdgeItem] = []
        self._build_ui()

    def _build_ui(self) -> None:
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # ── Escena ──────────────────────────────────────────────────────────
        self.scene = QGraphicsScene()
        self.scene.setBackgroundBrush(QBrush(BG_COLOR))

        self.view = _ZoomableView(self.scene)
        self.view.setRenderHint(QPainter.Antialiasing)
        self.view.setDragMode(QGraphicsView.ScrollHandDrag)
        self.view.setTransformationAnchor(QGraphicsView.AnchorUnderMouse)
        self.view.setResizeAnchor(QGraphicsView.AnchorUnderMouse)
        self.view.setObjectName("CFGView")
        self.view.setStyleSheet("background: #1E1E1E; border: none;")
        layout.addWidget(self.view, 1)

        self._placeholder = QLabel("No hay archivos CFG disponibles.\nCompila primero para generar los diagramas.")
        self._placeholder.setAlignment(Qt.AlignCenter)
        self._placeholder.setObjectName("CFGPlaceholder")
        self._placeholder.setStyleSheet("color: #666; font-size: 13px;")
        layout.addWidget(self._placeholder)
        self._placeholder.hide()

        # ── Overlay flotante con la lista (hijo directo de self) ─────────────
        self._overlay = QFrame(self)
        self._overlay.setObjectName("CFGOverlay")
        ov_layout = QVBoxLayout(self._overlay)
        ov_layout.setContentsMargins(0, 0, 0, 0)
        ov_layout.setSpacing(0)

        list_header = QLabel("ARCHIVOS CFG")
        list_header.setObjectName("CFGListHeader")
        ov_layout.addWidget(list_header)

        self.cfg_list = QListWidget()
        self.cfg_list.setObjectName("CFGList")
        self.cfg_list.setFrameShape(QFrame.NoFrame)
        self.cfg_list.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.cfg_list.itemClicked.connect(self._on_list_clicked)
        ov_layout.addWidget(self.cfg_list, 1)

        fit_btn = QPushButton("Ajustar vista")
        fit_btn.setObjectName("CFGFitButton")
        fit_btn.setCursor(Qt.PointingHandCursor)
        fit_btn.clicked.connect(self._fit_view)
        ov_layout.addWidget(fit_btn)

        self._overlay.raise_()

    def resizeEvent(self, event) -> None:
        super().resizeEvent(event)
        self._reposition_overlay()

    def _reposition_overlay(self) -> None:
        margin = 12
        w = 210
        h = min(300, self.height() - margin * 2)
        self._overlay.setGeometry(margin, margin, w, h)

    def load_paths(self, paths: list[Path]) -> None:
        self._dot_paths = paths
        self.cfg_list.blockSignals(True)
        self.cfg_list.clear()
        for p in paths:
            item = QListWidgetItem(p.name)
            item.setData(Qt.UserRole, p)
            self.cfg_list.addItem(item)
        self.cfg_list.blockSignals(False)

        if paths:
            self._placeholder.hide()
            self.view.show()
            self.cfg_list.setCurrentRow(0)
            self._render_path(paths[0])
        else:
            self._clear_scene()
            self.view.hide()
            self._placeholder.show()

    def _on_list_clicked(self, item: QListWidgetItem) -> None:
        path = item.data(Qt.UserRole)
        if path is not None:
            self._render_path(path)

    def _render_path(self, path: Path) -> None:
        try:
            text = path.read_text(encoding="utf-8")
        except OSError:
            return
        self._render_dot(text)

    def _clear_scene(self) -> None:
        self.scene.clear()
        self._node_items = {}
        self._edge_items = []

    def _render_dot(self, dot_text: str) -> None:
        self._clear_scene()
        nodes, edges = parse_dot(dot_text)
        if not nodes:
            return

        positions = _layout(nodes, edges)

        # Crear ítems de nodo
        for node in nodes:
            pos = positions.get(node.id, QPointF(0, 0))
            item = NodeItem(node)
            item.setPos(pos)
            self.scene.addItem(item)
            self._node_items[node.id] = item

        # Pre-calcular offsets laterales para edges que salen del mismo nodo
        # Agrupamos por src para repartirlos horizontalmente
        from collections import defaultdict
        src_groups: dict[str, list[DotEdge]] = defaultdict(list)
        dst_groups: dict[str, list[DotEdge]] = defaultdict(list)
        for edge in edges:
            if self._node_items.get(edge.src) and self._node_items.get(edge.dst):
                src_groups[edge.src].append(edge)
                dst_groups[edge.dst].append(edge)

        SPREAD = 28  # separación horizontal entre edges del mismo nodo

        def src_offset(edge: DotEdge) -> float:
            grp = src_groups[edge.src]
            if len(grp) == 1:
                return 0.0
            idx = grp.index(edge)
            return (idx - (len(grp) - 1) / 2) * SPREAD

        def dst_offset(edge: DotEdge) -> float:
            grp = dst_groups[edge.dst]
            if len(grp) == 1:
                return 0.0
            idx = grp.index(edge)
            return (idx - (len(grp) - 1) / 2) * SPREAD

        # Crear ítems de arista
        for edge in edges:
            src_item = self._node_items.get(edge.src)
            dst_item = self._node_items.get(edge.dst)
            if src_item and dst_item:
                e_item = EdgeItem(
                    src_item, dst_item, edge,
                    src_offset=src_offset(edge),
                    dst_offset=dst_offset(edge),
                )
                self.scene.addItem(e_item)
                self._edge_items.append(e_item)

        self._fit_view()

    def _fit_view(self) -> None:
        if not self.scene.items():
            return
        # Calcular bounding rect manualmente sumando todos los items
        # (itemsBoundingRect puede recortar curvas que salen fuera del área de nodos)
        rect = self.scene.itemsBoundingRect()
        for item in self.scene.items():
            rect = rect.united(item.boundingRect().translated(item.pos()))
        padded = rect.adjusted(-60, -60, 60, 60)
        self.scene.setSceneRect(padded)
        self.view.fitInView(padded, Qt.KeepAspectRatio)
