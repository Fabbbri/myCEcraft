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
SIM_VVP = ARQUI / "sim" / "build" / "tb_topG_bench.vvp"

# mismos directorios de fuentes que el Makefile (sin make: funciona igual
# desde PowerShell, cmd o bash, y compila UNA sola vez para toda la suite)
SRC_DIRS = ["rtl", "rtl/async_fifo", "rtl/IF", "rtl/DE", "rtl/MEM",
            "rtl/utils", "rtl/TOP"]


def build_sim():
    """Compila el testbench una vez con iverilog. Devuelve True si compilo."""
    for d in ("sim/build", "sim/waves", "outputs/reports"):
        (ARQUI / d).mkdir(parents=True, exist_ok=True)

    srcs = []
    for d in SRC_DIRS:
        srcs.extend(sorted((ARQUI / d).glob("*.sv")))
    srcs.append(ARQUI / "tb" / "tb_topG.sv")

    cmd = ["iverilog", "-g2012", "-o", str(SIM_VVP)] + [str(s) for s in srcs]
    print(f"[BUILD] iverilog ({len(srcs)} fuentes)")
    proc = subprocess.run(cmd, cwd=ARQUI, capture_output=True, text=True)
    if proc.returncode != 0:
        print("[ERROR] fallo la compilacion:")
        print("\n".join((proc.stdout + proc.stderr).strip().splitlines()[-8:]))
        return False
    return True

# Registro de benchmarks: nombre, rom, halt_pc (PC del freeze), x11 esperado.
# halt_pc se obtiene de la linea del 00600000 en el .hex: (linea-1)*4
BENCHMARKS = [
    {"name": "while loop x<5",  "rom": "program.hex",      "halt": "6C",  "x11": None,   "max": 20000},
    {"name": "bench_seq",       "rom": "bench_seq.hex",    "halt": "E4",  "x11": "7F80", "max": 300000},
    {"name": "bench_stride",    "rom": "bench_stride.hex", "halt": "E4",  "x11": "F80",   "max": 300000},
    {"name": "bench_random",    "rom": "bench_random.hex", "halt": "124", "x11": "1C110", "max": 600000},
    {"name": "bench_mmul",      "rom": "bench_mmul.hex",   "halt": "264", "x11": "3F00",  "max": 600000},
]

CSV_COLS = [
    "Test Ejecutado", "Ciclos", "Instr", "CPI",
    "Stalls_Mem", "Stalls_Control",
    "L1_Reads", "L1_Writes", "L1_Read_Hits", "L1_Read_Misses",
    "L1_Write_Hits", "L1_Write_Misses", "L1_Hit_Rate", "L1_Miss_Rate",
    "L2_Accesses", "L2_Hits", "L2_Misses", "L2_Hit_Rate", "L2_Miss_Rate",
    "Memory_Accesses", "Mem_Transfer_Cycles", "BW_Util",
]

# campo del [METRICS] -> columna CSV
FIELD_MAP = {
    "cycles": "Ciclos", "instr": "Instr", "cpi": "CPI",
    "stall_mem_cyc": "Stalls_Mem", "ctrl_stalls": "Stalls_Control",
    "l1_reads": "L1_Reads", "l1_writes": "L1_Writes",
    "l1_rd_hits": "L1_Read_Hits", "l1_rd_miss": "L1_Read_Misses",
    "l1_wr_hits": "L1_Write_Hits", "l1_wr_miss": "L1_Write_Misses",
    "l1_hit_rate": "L1_Hit_Rate", "l1_miss_rate": "L1_Miss_Rate",
    "l2_acc": "L2_Accesses", "l2_hits": "L2_Hits", "l2_miss": "L2_Misses",
    "l2_hit_rate": "L2_Hit_Rate", "l2_miss_rate": "L2_Miss_Rate",
    "mem_acc": "Memory_Accesses", "mem_xfer_cyc": "Mem_Transfer_Cycles",
    "bw_util": "BW_Util",
}


def run_benchmark(b):
    """Corre una simulacion y devuelve (fila_dict | None, status_str)."""
    safe_name = re.sub(r"[^A-Za-z0-9_-]", "_", b["name"])
    cmd = [
        "vvp", str(SIM_VVP),
        f"+TEST_NAME={safe_name}",
        f"+HALT_PC={b['halt']}",
        f"+MAX_CYCLES={b['max']}",
        f"+FILE_ROM=programs/{b['rom']}",
        "+FILE_RAM=programs/data.hex",
    ]
    if b["x11"]:
        cmd.append(f"+EXPECT_X11={b['x11']}")
    print(f"[RUN ] {b['name']}  ({b['rom']})")
    proc = subprocess.run(cmd, cwd=ARQUI, capture_output=True, text=True)
    out = proc.stdout + proc.stderr

    row = parse_metrics(out)
    if row is None:
        status = "TIMEOUT/ERROR"
        # mostrar el final de la salida para diagnosticar
        tail = "\n".join(out.strip().splitlines()[-4:])
        print(f"       ultima salida:\n{tail}")
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


def _fnum(v):
    """float o None si el valor no es numerico (corridas fallidas)."""
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def row_band(row):
    """Color de fondo de la fila completa segun L1 Hit Rate.
    >95% verde, 80-95% amarillo, <80% rojo, sin datos gris."""
    v = _fnum(row.get("L1_Hit_Rate"))
    if v is None:   return "#f0f0f0"
    if v > 95.0:    return "#e3f4e4"
    if v >= 80.0:   return "#fdf6dd"
    return "#fde8e6"


def load_no_cache():
    """Corrida sin cache (iteracion 2) como referencia, si existe.
    Devuelve {nombre: {'Ciclos':.., 'CPI':..}}. El nombre del while puede
    venir con sufijo, se normaliza por prefijo."""
    path = ARQUI / "outputs" / "reports" / "results_no_cash.csv"
    ref = {}
    if not path.exists():
        return ref
    try:
        with open(path, newline="", encoding="utf-8") as f:
            for r in csv.DictReader(f):
                name = r.get("Test Ejecutado", "")
                key = "while loop x<5" if name.startswith("while") else name
                ref[key] = {"Ciclos": r.get("Ciclos"), "CPI": r.get("CPI")}
    except (OSError, KeyError):
        pass
    return ref


def _stall_pct(r):
    """% de ciclos congelado esperando memoria (la 'pared de memoria')."""
    cyc, st = _fnum(r.get("Ciclos")), _fnum(r.get("Stalls_Mem"))
    if cyc and st is not None and cyc > 0:
        return 100.0 * st / cyc
    return None


def _card(title, big, sub):
    return (f'<div class="card"><div class="ct">{title}</div>'
            f'<div class="cb">{big}</div><div class="cs">{sub}</div></div>')


def verdict_section(rows, no_cache):
    """Veredicto: la tesis en una linea + 3 tarjetas con lo esencial
    (mejor CPI, peor CPI, aceleracion del cache vs sin cache)."""
    data = [r for r in rows if _fnum(r.get("CPI")) is not None]
    cards = ""
    if data:
        best = min(data, key=lambda r: _fnum(r.get("CPI")))
        worst = max(data, key=lambda r: _fnum(r.get("CPI")))
        cards += _card("Mejor CPI", f'{_fnum(best.get("CPI")):.2f}',
                       f'{best["Test Ejecutado"]} &mdash; alta localidad')
        cards += _card("Peor CPI", f'{_fnum(worst.get("CPI")):.2f}',
                       f'{worst["Test Ejecutado"]} &mdash; sin localidad espacial')
        for r in data:
            ref = no_cache.get(r["Test Ejecutado"])
            rc, c = (_fnum(ref.get("CPI")) if ref else None), _fnum(r.get("CPI"))
            if rc and c:
                cards += _card("Acelera el cach&eacute;", f"{rc / c:.1f}&times;",
                               f'{r["Test Ejecutado"]}: {rc:.2f} &rarr; {c:.2f} CPI')
                break
    return f"""
<section class="verdict">
 <h2>Veredicto</h2>
 <p class="thesis">El rendimiento lo decide la <b>localidad</b> del acceso a
   memoria: a m&aacute;s aciertos en cach&eacute;, menos esperas y menor CPI.
   Mismo hardware, distinto patr&oacute;n de acceso.</p>
 <div class="cards">{cards}</div>
</section>
"""


def formulas_section():
    return """
<section><h2>F&oacute;rmulas</h2>
<div class="formulas">
<div class="f"><b>CPI</b><pre>Ciclos / Instrucciones</pre></div>
<div class="f"><b>L1 Hit Rate</b><pre>(Hits lectura + Hits escritura)
-------------------------------- x 100
        (Reads + Writes)</pre></div>
<div class="f"><b>L2 Hit Rate</b><pre>   L2 Hits
------------- x 100
 L2 Accesses</pre></div>
<div class="f"><b>Memory Accesses</b><pre>Numero total de accesos a memoria principal</pre></div>
<div class="f"><b>BW Util</b><pre>Mem Transfer Cycles
-------------------- x 100
   Ciclos totales</pre></div>
</div>
<p class="nota"><b>Nota sobre Memory Accesses:</b> no coincide con L2_Misses
porque la pol&iacute;tica es write-through: <i>todo</i> store drenado llega a RAM
aunque haya sido hit en L2 (se actualizan ambos niveles). Por eso
Memory_Accesses = misses de lectura en L2 + total de stores drenados.</p>
</section>
"""


def _chainbar(label, val, top, text, color):
    pct = 100.0 * val / top if top else 0.0
    return (
        f'<div class="row"><div class="lbl">{label}</div>'
        f'<div class="track"><div class="bar" '
        f'style="width:{pct:.1f}%;background:{color}"></div></div>'
        f'<div class="val">{text}</div></div>'
    )


def causal_chain(rows):
    """Vista integrada: por benchmark (ordenado del mas rapido al mas lento)
    muestra la cadena completa L1 aciertos -> espera de memoria -> CPI, con
    barras alineadas. Se lee de un vistazo: mas verde y menos rojo = menor CPI."""
    data = [r for r in rows if _fnum(r.get("CPI")) is not None]
    if not data:
        return ""
    data = sorted(data, key=lambda r: _fnum(r.get("CPI")))
    max_cpi = max(_fnum(r.get("CPI")) for r in data)
    blocks = ""
    for r in data:
        hit = _fnum(r.get("L1_Hit_Rate")) or 0.0
        stall = _stall_pct(r) or 0.0
        cpi = _fnum(r.get("CPI")) or 0.0
        bars = (
            _chainbar("L1 aciertos", hit, 100, f"{hit:.0f}%", "#1a9850")
            + _chainbar("Espera mem", stall, 100, f"{stall:.0f}%", "#d73027")
            + _chainbar("CPI", cpi, max_cpi, f"{cpi:.2f}", "#4575b4")
        )
        blocks += (f'<div class="cblock"><div class="cname">'
                   f'{r["Test Ejecutado"]}</div>{bars}</div>\n')
    return f"""
<section><h2>Cadena causal: localidad &rarr; aciertos &rarr; esperas &rarr; CPI</h2>
<p class="nota">Cada bloque es un benchmark, del m&aacute;s r&aacute;pido (arriba)
 al m&aacute;s lento (abajo). Barra verde larga (aciertos) + roja corta (espera)
 &rarr; CPI bajo. Es la misma cadena causal para todos: el patr&oacute;n de
 acceso manda.</p>
{blocks}
</section>
"""


def render_html(rows, path, no_cache):
    show_status = any(r.get("_status", "OK") != "OK" for r in rows)
    # orden de lectura: del mejor CPI (arriba) al peor; sin datos al final
    display = sorted(rows, key=lambda r: (_fnum(r.get("CPI")) is None,
                                          _fnum(r.get("CPI")) or 0.0))

    # tabla curada: solo las columnas que cuentan la historia.
    # El registro completo (22 columnas) vive en results.csv.
    cols = [("Ciclos", "Ciclos"), ("CPI", "CPI"),
            ("L1_Hit_Rate", "L1 Hit %"), ("L2_Hit_Rate", "L2 Hit %"),
            ("__stall", "Espera mem %"), ("BW_Util", "BW %")]
    head = ("<tr><th>Benchmark</th>"
            + "".join(f"<th>{lbl}</th>" for _, lbl in cols)
            + ("<th>Status</th>" if show_status else "") + "</tr>")

    body = ""
    for r in display:
        cells = f'<td>{r.get("Test Ejecutado", "")}</td>'
        for col, _ in cols:
            if col == "__stall":
                sp = _stall_pct(r)
                cells += f"<td>{sp:.1f}</td>" if sp is not None else "<td>&mdash;</td>"
                continue
            v = r.get(col, "")
            style = ""
            if col in ("L1_Hit_Rate", "L2_Hit_Rate"):
                style = f' style="background:{heat_color(v)};color:#fff"'
            cells += f"<td{style}>{v}</td>"
        if show_status:
            cells += f'<td>{r.get("_status", "")}</td>'
        body += f'<tr style="background:{row_band(r)}">{cells}</tr>\n'

    legend = """
<p class="nota">Color de fila seg&uacute;n L1 Hit Rate:
 <span class="chip" style="background:#e3f4e4">&gt;95% muy bueno</span>
 <span class="chip" style="background:#fdf6dd">80&ndash;95% medio</span>
 <span class="chip" style="background:#fde8e6">&lt;80% malo</span>
 <span class="chip" style="background:#f0f0f0">sin datos</span></p>"""

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>Benchmarks - rendimiento de cache</title>
<style>
 body {{ font-family: system-ui, sans-serif; margin: 24px; color: #222; max-width: 820px; }}
 h1 {{ font-size: 1.4em; }}  h2 {{ font-size: 1.05em; margin: 20px 0 6px; }}
 table {{ border-collapse: collapse; font-size: 0.86em; }}
 th, td {{ border: 1px solid #ccc; padding: 4px 10px; text-align: right; }}
 th {{ background: #f0f0f0; }}  td:first-child, th:first-child {{ text-align: left; }}
 code {{ background: #f0f0f0; padding: 1px 4px; border-radius: 3px; }}
 .nota {{ font-size: 0.85em; color: #555; }}
 .chip {{ padding: 1px 8px; border-radius: 3px; border: 1px solid #ccc; margin-right: 4px; }}
 .verdict {{ border: 1px solid #d7e0ea; background: #f7fafc; border-radius: 6px; padding: 10px 16px; }}
 .thesis {{ margin: 4px 0 12px; }}
 .cards {{ display: flex; flex-wrap: wrap; gap: 12px; }}
 .card {{ border: 1px solid #d7e0ea; background: #fff; border-radius: 6px; padding: 8px 16px; min-width: 150px; }}
 .ct {{ font-size: 0.76em; color: #667; text-transform: uppercase; letter-spacing: .04em; }}
 .cb {{ font-size: 1.6em; font-weight: 600; color: #1f3a5f; }}
 .cs {{ font-size: 0.78em; color: #556; }}
 .cblock {{ margin: 10px 0; padding-bottom: 8px; border-bottom: 1px solid #eee; }}
 .cname {{ font-weight: 600; font-size: 0.9em; margin-bottom: 3px; }}
 .row {{ display: flex; align-items: center; margin: 3px 0; }}
 .lbl {{ width: 110px; font-size: 0.82em; color: #555; }}
 .track {{ flex: 1; background: #eee; border-radius: 3px; height: 16px; max-width: 440px; }}
 .bar {{ height: 100%; border-radius: 3px; }}
 .val {{ width: 70px; text-align: right; font-size: 0.82em; padding-left: 8px; }}
 .formulas {{ display: flex; flex-wrap: wrap; gap: 14px; }}
 .f {{ border: 1px solid #ddd; border-radius: 4px; padding: 6px 10px; }}
 .f pre {{ margin: 4px 0 0; font-size: 0.8em; }}
</style></head><body>
<h1>Benchmarks del procesador &mdash; rendimiento de la jerarqu&iacute;a de cach&eacute;</h1>
{verdict_section(rows, no_cache)}
<h2>Resumen por benchmark</h2>
<p class="nota">Ordenado del m&aacute;s r&aacute;pido al m&aacute;s lento.
 Registro completo (22 columnas) en <code>results.csv</code>.</p>
<table><thead>{head}</thead><tbody>{body}</tbody></table>
{legend}
{causal_chain(rows)}
{formulas_section()}
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

    if not build_sim():
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
    render_html(rows, html_path, load_no_cache())

    if not args.no_open:
        webbrowser.open(html_path.as_uri())

    print(f"\n{len(rows) - failures}/{len(rows)} benchmarks OK")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
