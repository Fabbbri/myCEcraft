#!/usr/bin/env python3
"""Corre los benchmarks del procesador, junta las metricas de cache
en un CSV y genera una vista HTML comparativa.

Uso (desde arqui/):
    python scripts/benchmarks.py              # corre todos
    python scripts/benchmarks.py --only bench_seq
    python scripts/benchmarks.py --list
    python scripts/benchmarks.py --no-open
"""

import argparse
import csv
import re
import subprocess
import sys
import webbrowser
from pathlib import Path

ARQUI = Path(__file__).resolve().parent.parent

# Registro de benchmarks: nombre, rom, halt_pc (PC del freeze), x11 esperado.
# halt_pc se obtiene de la linea del 00600000 en el .hex: (linea-1)*4
BENCHMARKS = [
    {"name": "while loop x<5",  "rom": "program.hex",      "halt": "6C",  "x11": None,   "max": 20000},
    {"name": "bench_seq",       "rom": "bench_seq.hex",    "halt": "E4",  "x11": "7F80", "max": 300000},
    {"name": "bench_stride",    "rom": "bench_stride.hex", "halt": "E4",  "x11": "F80",  "max": 300000},
    {"name": "bench_mmul",      "rom": "bench_mmul.hex",   "halt": "264", "x11": "3F00", "max": 600000},
]

CSV_COLS = [
    "Test Ejecutado", "Ciclos", "Instr", "CPI",
    "L1_Reads", "L1_Writes", "L1_Read_Hits", "L1_Read_Misses",
    "L1_Write_Hits", "L1_Write_Misses", "L1_Hit_Rate", "L1_Miss_Rate",
    "L2_Accesses", "L2_Hits", "L2_Misses", "L2_Hit_Rate", "L2_Miss_Rate",
    "Memory_Accesses",
]

# campo del [METRICS] -> columna CSV
FIELD_MAP = {
    "cycles": "Ciclos", "instr": "Instr", "cpi": "CPI",
    "l1_reads": "L1_Reads", "l1_writes": "L1_Writes",
    "l1_rd_hits": "L1_Read_Hits", "l1_rd_miss": "L1_Read_Misses",
    "l1_wr_hits": "L1_Write_Hits", "l1_wr_miss": "L1_Write_Misses",
    "l1_hit_rate": "L1_Hit_Rate", "l1_miss_rate": "L1_Miss_Rate",
    "l2_acc": "L2_Accesses", "l2_hits": "L2_Hits", "l2_miss": "L2_Misses",
    "l2_hit_rate": "L2_Hit_Rate", "l2_miss_rate": "L2_Miss_Rate",
    "mem_acc": "Memory_Accesses",
}


def run_benchmark(b):
    """Corre una simulacion y devuelve (fila_dict | None, status_str)."""
    safe_name = re.sub(r"[^A-Za-z0-9_-]", "_", b["name"])
    flags = f"+TEST_NAME={safe_name} +HALT_PC={b['halt']} +MAX_CYCLES={b['max']}"
    if b["x11"]:
        flags += f" +EXPECT_X11={b['x11']}"
    cmd = ["make", "run", "TOP=tb_topG", f"ROM={b['rom']}", f"VVP_FLAGS={flags}"]
    print(f"[RUN ] {b['name']}  ({b['rom']})")
    proc = subprocess.run(cmd, cwd=ARQUI, capture_output=True, text=True)
    out = proc.stdout + proc.stderr

    row = parse_metrics(out)
    if row is None:
        status = "TIMEOUT/ERROR"
    elif "[FAIL]" in out:
        status = "FAIL (registros)"
    else:
        status = "OK"
    print(f"[{'OK  ' if status == 'OK' else 'FAIL'}] {b['name']}: {status}")
    if row is not None:
        row["Test Ejecutado"] = b["name"]
        row["_status"] = status
    return row, status


def parse_metrics(out):
    """Extrae la linea [METRICS] k=v|k=v... -> dict con columnas CSV."""
    m = re.search(r"\[METRICS\]\s+(.*)", out)
    if not m:
        return None
    row = {}
    for pair in m.group(1).split("|"):
        if "=" not in pair:
            continue
        k, v = pair.split("=", 1)
        col = FIELD_MAP.get(k.strip())
        if col:
            row[col] = v.strip()
    return row


def write_csv(rows, path):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=CSV_COLS, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow(r)
    print(f"[CSV ] {path}")


def heat_color(pct, invert=False):
    """verde (bueno) -> rojo (malo). invert=True para metricas donde alto=malo."""
    try:
        v = float(pct)
    except (TypeError, ValueError):
        return "#999"
    if invert:
        v = 100.0 - v
    if v >= 90: return "#1a9850"
    if v >= 70: return "#91cf60"
    if v >= 50: return "#fee08b"
    if v >= 30: return "#fc8d59"
    return "#d73027"


def bar_section(title, rows, col, unit=""):
    """Seccion HTML con barras horizontales comparando una metrica."""
    vals = []
    for r in rows:
        try:
            vals.append(float(r.get(col, 0)))
        except ValueError:
            vals.append(0.0)
    top = max(vals) if vals and max(vals) > 0 else 1.0
    items = ""
    for r, v in zip(rows, vals):
        pct = 100.0 * v / top
        label = f"{v:,.2f}" if "." in str(r.get(col, "")) else f"{int(v):,}"
        items += (
            f'<div class="row"><div class="lbl">{r["Test Ejecutado"]}</div>'
            f'<div class="track"><div class="bar" style="width:{pct:.1f}%"></div></div>'
            f'<div class="val">{label}{unit}</div></div>\n'
        )
    return f'<section><h2>{title}</h2>{items}</section>\n'


def render_html(rows, path):
    head_cells = "".join(f"<th>{c}</th>" for c in CSV_COLS + ["Status"])
    body = ""
    for r in rows:
        cells = ""
        for c in CSV_COLS:
            v = r.get(c, "")
            style = ""
            if c in ("L1_Hit_Rate", "L2_Hit_Rate"):
                style = f' style="background:{heat_color(v)};color:#fff"'
            elif c in ("L1_Miss_Rate", "L2_Miss_Rate"):
                style = f' style="background:{heat_color(v, invert=True)};color:#fff"'
            cells += f"<td{style}>{v}</td>"
        cells += f"<td>{r.get('_status', '')}</td>"
        body += f"<tr>{cells}</tr>\n"

    sections = (
        bar_section("Ciclos totales", rows, "Ciclos")
        + bar_section("CPI", rows, "CPI")
        + bar_section("Instrucciones ejecutadas", rows, "Instr")
        + bar_section("L1 Hit Rate", rows, "L1_Hit_Rate", "%")
        + bar_section("L1 Miss Rate", rows, "L1_Miss_Rate", "%")
        + bar_section("L2 Hit Rate", rows, "L2_Hit_Rate", "%")
        + bar_section("L2 Miss Rate", rows, "L2_Miss_Rate", "%")
        + bar_section("Accesos a memoria principal", rows, "Memory_Accesses")
    )

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>Benchmarks - metricas de cache</title>
<style>
 body {{ font-family: system-ui, sans-serif; margin: 24px; color: #222; }}
 h1 {{ font-size: 1.4em; }}  h2 {{ font-size: 1.05em; margin: 18px 0 6px; }}
 table {{ border-collapse: collapse; font-size: 0.82em; }}
 th, td {{ border: 1px solid #ccc; padding: 4px 8px; text-align: right; }}
 th {{ background: #f0f0f0; }}  td:first-child, th:first-child {{ text-align: left; }}
 section {{ max-width: 760px; }}
 .row {{ display: flex; align-items: center; margin: 3px 0; }}
 .lbl {{ width: 150px; font-size: 0.85em; }}
 .track {{ flex: 1; background: #eee; border-radius: 3px; height: 18px; }}
 .bar {{ background: #4575b4; height: 100%; border-radius: 3px; }}
 .val {{ width: 110px; text-align: right; font-size: 0.85em; padding-left: 8px; }}
</style></head><body>
<h1>Benchmarks del procesador &mdash; metricas de cache</h1>
<table><thead><tr>{head_cells}</tr></thead><tbody>{body}</tbody></table>
{sections}
</body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"[HTML] {path}")


def main():
    ap = argparse.ArgumentParser(description="Corre benchmarks y genera CSV + HTML")
    ap.add_argument("--only", help="correr solo el benchmark con este nombre")
    ap.add_argument("--list", action="store_true", help="listar benchmarks")
    ap.add_argument("--no-open", action="store_true", help="no abrir el HTML")
    args = ap.parse_args()

    if args.list:
        for b in BENCHMARKS:
            print(f"  {b['name']:20s} rom={b['rom']}")
        return 0

    todo = [b for b in BENCHMARKS if not args.only or b["name"] == args.only]
    if not todo:
        print(f"No existe el benchmark '{args.only}'. Usa --list.")
        return 1

    rows, failures = [], 0
    for b in todo:
        row, status = run_benchmark(b)
        if row is None:
            rows.append({"Test Ejecutado": b["name"], "_status": status})
            failures += 1
        else:
            rows.append(row)
            if status != "OK":
                failures += 1

    reports = ARQUI / "outputs" / "reports"
    reports.mkdir(parents=True, exist_ok=True)
    write_csv(rows, reports / "results.csv")
    html_path = reports / "results.html"
    render_html(rows, html_path)

    if not args.no_open:
        webbrowser.open(html_path.as_uri())

    print(f"\n{len(rows) - failures}/{len(rows)} benchmarks OK")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
