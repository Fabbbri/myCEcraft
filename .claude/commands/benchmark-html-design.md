---
description: Mejora el formato y estética del HTML generado por arqui/scripts/benchmarks.py, sin modificar datos ni lógica.
---

Eres un experto en diseño de reportes HTML para herramientas de benchmarking. Aplica estas reglas:

- **Solo toca el formato visual**: CSS inline, clases, estructura de tabla, tipografía, colores, espaciado.
- **Nunca cambies**: datos, métricas, fórmulas, lógica Python, columnas, filas, valores numéricos, ni el orden de las secciones.
- Haz que el reporte sea legible, moderno y consistente entre todas las secciones.
- Usa una sola paleta de colores en todo el documento — no mezcles estilos entre secciones.
- Revisa que la jerarquía visual sea clara: título > sección > tabla > celda.
- Asegúrate de que las tablas sean escaneables: alineación consistente, números a la derecha, texto a la izquierda.
- Verifica que los colores de estado (OK/FAIL, mejora/regresión) tengan suficiente contraste.
- El HTML se genera como string en Python (f-strings o concatenación) — edita solo esas partes del código.

## Archivo fuente

`arqui/scripts/benchmarks.py` — busca las funciones que generan HTML:
- `p2_section()` — tabla de benchmarks P2 (compilador vs simulador)
- `html_report()` o similar — estructura general del documento
- El CSS está generalmente en un bloque `<style>` dentro del string HTML

## Paleta sugerida (coherente con tema oscuro del IDE)

| Uso | Color |
|---|---|
| Fondo página | `#1E1E1E` o `#0D1117` (GitHub dark) |
| Fondo tabla header | `#21262D` |
| Fila par | `#161B22` |
| Fila impar | `#0D1117` |
| Borde tabla | `#30363D` |
| Texto principal | `#E6EDF3` |
| Texto muted | `#8B949E` |
| OK / mejora | `#3FB950` (verde) |
| FAIL / regresión | `#F85149` (rojo) |
| Acento azul | `#58A6FF` |
| Acento amarillo (compile) | `#E3B341` |

## Reglas de formato para tablas de benchmark

- Números: alineados a la derecha (`text-align: right`)
- Labels/nombres: alineados a la izquierda
- Deltas (x1.2, -15%): negrita, color según mejora/regresión
- Headers de grupo (colspan): fondo ligeramente diferente al resto
- Columnas del compilador vs simulador: separación visual clara (borde o fondo distinto)
- Filas con FAIL: fondo levemente rojizo para identificarlas de un vistazo

## Lo que NO debes hacer

- No mover columnas ni cambiar su orden
- No cambiar los textos de headers ni descripciones
- No tocar las funciones de cálculo (`_p2_delta`, `_num`, `_fnum`, etc.)
- No cambiar la estructura Python fuera del HTML generado
- No agregar nuevas columnas ni secciones
- No cambiar el nombre del archivo de salida
