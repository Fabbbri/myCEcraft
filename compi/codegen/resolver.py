from __future__ import annotations

import re
from dataclasses import dataclass


class ResolutionError(Exception):
    """
    Error durante la fase 5: calculo de saltos y resolucion de referencias.
    """


@dataclass(frozen=True)
class LabelReference:
    line_index: int
    pc: int
    mnemonic: str
    label: str
    target_pc: int
    offset: int


@dataclass(frozen=True)
class ResolutionResult:
    assembly: str
    labels: dict[str, int]
    references: list[LabelReference]


class LabelResolver:
    """
    Fase 5: resuelve etiquetas de texto a desplazamientos relativos.

    El codegen de fase 4 ya anota cada instruccion real con `pc=0x....`.
    Esta fase hace dos pasadas:
    1. registra cada etiqueta del segmento .text con el PC de la siguiente
       instruccion;
    2. sustituye referencias simbolicas en saltos por offsets en bytes.
    """

    CONTROL_TRANSFER = {"jal", "beq", "bne", "blt", "bge", "portalv"}

    BRANCH_RANGE = (-16_384, 16_380)
    JUMP_RANGE = (-524_288, 524_284)

    PC_RE = re.compile(r"\bpc=0x(?P<pc>[0-9a-fA-F]+)\b")
    LABEL_RE = re.compile(r"^\s*(?P<label>[A-Za-z_.$][\w.$]*):")
    INSTRUCTION_RE = re.compile(
        r"^(?P<indent>\s*)(?P<mnemonic>[A-Za-z_][\w]*)\s+(?P<operands>.*?)(?P<trailing>\s*)$"
    )

    def resolve(self, assembly: str) -> ResolutionResult:
        lines = assembly.splitlines()
        labels = self._collect_labels(lines)
        resolved_lines, references = self._resolve_references(lines, labels)
        output = self._with_resolution_header(resolved_lines, labels, references)
        return ResolutionResult(
            assembly="\n".join(output),
            labels=labels,
            references=references,
        )

    def _collect_labels(self, lines: list[str]) -> dict[str, int]:
        labels: dict[str, int] = {}
        current_pc = 0
        in_text = False

        for line in lines:
            stripped = line.strip()

            if stripped == ".text":
                in_text = True
                continue

            label = self._parse_label(line)
            if in_text and label is not None:
                if label in labels:
                    raise ResolutionError(f"etiqueta duplicada: {label}")
                labels[label] = current_pc
                continue

            if stripped.startswith(".") and stripped != ".text":
                in_text = False
                continue

            if not in_text:
                continue

            pc = self._parse_pc(line)
            if pc is not None:
                current_pc = pc + 4

        return labels

    def _resolve_references(
        self,
        lines: list[str],
        labels: dict[str, int],
    ) -> tuple[list[str], list[LabelReference]]:
        resolved: list[str] = []
        references: list[LabelReference] = []
        in_text = False

        for index, line in enumerate(lines):
            stripped = line.strip()

            if stripped == ".text":
                in_text = True
                resolved.append(line)
                continue

            if self._parse_label(line) is None and stripped.startswith(".") and stripped != ".text":
                in_text = False
                resolved.append(line)
                continue

            if not in_text:
                resolved.append(line)
                continue

            replacement = self._resolve_line(index, line, labels)
            resolved.append(replacement[0])

            if replacement[1] is not None:
                references.append(replacement[1])

        return resolved, references

    def _resolve_line(
        self,
        line_index: int,
        line: str,
        labels: dict[str, int],
    ) -> tuple[str, LabelReference | None]:
        pc = self._parse_pc(line)
        if pc is None:
            return line, None

        code, separator, comment = line.partition(";")
        match = self.INSTRUCTION_RE.match(code)
        if match is None:
            return line, None

        mnemonic = match.group("mnemonic")
        if mnemonic not in self.CONTROL_TRANSFER:
            return line, None

        operands = [operand.strip() for operand in match.group("operands").split(",")]
        if not operands:
            return line, None

        label = operands[-1]
        if not self._is_symbolic_reference(label):
            return line, None

        if label not in labels:
            raise ResolutionError(
                f"referencia a etiqueta no definida en linea {line_index + 1}: {label}"
            )

        target_pc = labels[label]
        offset = target_pc - pc
        self._validate_offset(mnemonic, offset, label, line_index)

        operands[-1] = str(offset)
        new_code = (
            f"{match.group('indent')}{mnemonic} "
            f"{', '.join(operands)}{match.group('trailing')}"
        )

        new_comment_parts = []
        if separator:
            new_comment_parts.append(comment.strip())
        new_comment_parts.append(f"target={label}")
        new_comment_parts.append(f"addr=0x{target_pc:04X}")

        reference = LabelReference(
            line_index=line_index,
            pc=pc,
            mnemonic=mnemonic,
            label=label,
            target_pc=target_pc,
            offset=offset,
        )

        return f"{new_code:<55} ; {' ; '.join(new_comment_parts)}", reference

    def _validate_offset(
        self,
        mnemonic: str,
        offset: int,
        label: str,
        line_index: int,
    ) -> None:
        if offset % 4 != 0:
            raise ResolutionError(
                f"salto no alineado a 4 bytes en linea {line_index + 1}: {label}"
            )

        lower, upper = self.JUMP_RANGE if mnemonic == "jal" else self.BRANCH_RANGE
        if not lower <= offset <= upper:
            raise ResolutionError(
                f"offset fuera de rango para {mnemonic} en linea {line_index + 1}: "
                f"{offset} hacia {label}"
            )

    def _with_resolution_header(
        self,
        lines: list[str],
        labels: dict[str, int],
        references: list[LabelReference],
    ) -> list[str]:
        header = [
            "; ==================================================",
            "; Fase 5 - saltos y referencias resueltas",
            "; Convencion: offset relativo en bytes = target_pc - current_pc",
            "; ==================================================",
            "",
            "; Tabla de etiquetas",
        ]

        if labels:
            for label, pc in sorted(labels.items(), key=lambda item: item[1]):
                header.append(f";   {label} = 0x{pc:04X}")
        else:
            header.append(";   <sin etiquetas>")

        header.extend(["", "; Referencias resueltas"])

        if references:
            for ref in references:
                header.append(
                    f";   pc=0x{ref.pc:04X} {ref.mnemonic} -> {ref.label} "
                    f"(addr=0x{ref.target_pc:04X}, offset={ref.offset})"
                )
        else:
            header.append(";   <sin referencias>")

        header.append("")
        return header + lines

    def _parse_pc(self, line: str) -> int | None:
        match = self.PC_RE.search(line)
        if match is None:
            return None
        return int(match.group("pc"), 16)

    def _parse_label(self, line: str) -> str | None:
        match = self.LABEL_RE.match(line)
        if match is None:
            return None
        return match.group("label")

    def _is_symbolic_reference(self, value: str) -> bool:
        if not value:
            return False

        try:
            int(value, 0)
            return False
        except ValueError:
            return True
