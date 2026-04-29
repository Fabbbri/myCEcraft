from __future__ import annotations


class LabelsMixin:
    def _new_label(self, prefix: str) -> str:
        label = f".L_codegen_{self._label_counter}_{prefix}"
        self._label_counter += 1
        return label
