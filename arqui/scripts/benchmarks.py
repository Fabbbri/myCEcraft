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


def summary_section(rows):
    """Resumen: totales y promedios sobre las corridas con datos."""
    ok = sum(1 for r in rows if r.get("_status") == "OK")
    with_data = [r for r in rows if _fnum(r.get("CPI")) is not None]

    def avg(col):
        vals = [_fnum(r.get(col)) for r in with_data]
        vals = [v for v in vals if v is not None]
        return f"{sum(vals) / len(vals):.2f}" if vals else "&mdash;"

    return f"""
<section class="resumen"><h2>Resumen</h2>
<ul>
 <li>Benchmarks ejecutados: <b>{len(rows)}</b></li>
 <li>Exitosos: <b>{ok}</b></li>
 <li>Con fallos: <b>{len(rows) - ok}</b></li>
 <li>Promedio L1 Hit Rate: <b>{avg('L1_Hit_Rate')}%</b></li>
 <li>Promedio L2 Hit Rate: <b>{avg('L2_Hit_Rate')}%</b></li>
 <li>Promedio CPI: <b>{avg('CPI')}</b></li>
</ul></section>
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


def scatter_section(rows):
    """Correlacion CPI vs L1 Miss Rate (puntos posicionados con CSS)."""
    pts = []
    for r in rows:
        cpi = _fnum(r.get("CPI"))
        mr = _fnum(r.get("L1_Miss_Rate"))
        if cpi is not None and mr is not None:
            pts.append((r["Test Ejecutado"], cpi, mr))
    if not pts:
        return ""
    import math
    max_cpi = math.ceil(max(p[1] for p in pts)) + 1   # eje X en enteros
    dots = ""
    for name, cpi, mr in pts:
        x = 100.0 * cpi / max_cpi
        y = mr  # 0-100 directo
        dots += (
            f'<div class="dot" style="left:{x:.1f}%;bottom:{y:.1f}%"></div>'
            f'<div class="dotlbl" style="left:{x:.1f}%;bottom:{y:.1f}%">{name}</div>\n'
        )
    xticks = "".join(
        f'<div class="xtick" style="left:{100.0 * i / max_cpi:.1f}%">{i}</div>'
        for i in range(0, max_cpi + 1)
    )
    return f"""
<section><h2>Correlaci&oacute;n: L1 Miss Rate vs CPI</h2>
<p class="nota">A mayor tasa de fallos en cach&eacute;, mayor CPI.</p>
<div class="scatter-wrap">
 <div class="ylab">L1 Miss Rate (%)</div>
 <div class="scatter">{dots}
   <div class="ytick" style="bottom:100%">100</div>
   <div class="ytick" style="bottom:50%">50</div>
   <div class="ytick" style="bottom:0%">0</div>
   {xticks}
 </div>
</div>
<div class="xlab">CPI</div>
</section>
"""


def bar_section(title, rows, col, unit="", fixed_max=None):
    """Seccion HTML con barras horizontales comparando una metrica.
    fixed_max fija la escala (p.ej. 100 para porcentajes); sin el,
    escala relativa al maximo observado."""
    vals = []
    for r in rows:
        try:
            vals.append(float(r.get(col, 0)))
        except ValueError:
            vals.append(0.0)
    top = fixed_max if fixed_max else (max(vals) if vals and max(vals) > 0 else 1.0)
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
    # columna Status solo si hubo algun fallo
    show_status = any(r.get("_status", "OK") != "OK" for r in rows)
    status_th = '<th rowspan="2">Status</th>' if show_status else ""

    # cabecera en dos filas: bloques (CPU / L1 / L2 / Memoria) + metricas
    head = f"""
<tr>
 <th rowspan="2">Benchmark</th>
 <th colspan="5" class="grp">CPU</th>
 <th colspan="8" class="grp">L1</th>
 <th colspan="5" class="grp">L2</th>
 <th colspan="3" class="grp">Memoria</th>
 {status_th}
</tr>
<tr>
 <th>Ciclos</th><th>Instr</th><th>CPI</th><th>St.Mem</th><th>St.Ctl</th>
 <th>Reads</th><th>Writes</th><th>R.Hits</th><th>R.Miss</th>
 <th>W.Hits</th><th>W.Miss</th><th>Hit %</th><th>Miss %</th>
 <th>Acc</th><th>Hits</th><th>Miss</th><th>Hit %</th><th>Miss %</th>
 <th>Acc</th><th>Xfer cy</th><th>BW %</th>
</tr>"""

    body = ""
    for r in rows:
        band = row_band(r)
        cells = f'<td>{r.get("Test Ejecutado", "")}</td>'
        for c in CSV_COLS[1:]:
            v = r.get(c, "")
            style = ""
            if c in ("L1_Hit_Rate", "L2_Hit_Rate"):
                style = f' style="background:{heat_color(v)};color:#fff"'
            elif c in ("L1_Miss_Rate", "L2_Miss_Rate"):
                style = f' style="background:{heat_color(v, invert=True)};color:#fff"'
            cells += f"<td{style}>{v}</td>"
        if show_status:
            cells += f"<td>{r.get('_status', '')}</td>"
        body += f'<tr style="background:{band}">{cells}</tr>\n'

    legend = """
<p class="nota">Color de fila seg&uacute;n L1 Hit Rate:
 <span class="chip" style="background:#e3f4e4">&gt;95% muy bueno</span>
 <span class="chip" style="background:#fdf6dd">80&ndash;95% medio</span>
 <span class="chip" style="background:#fde8e6">&lt;80% malo</span>
 <span class="chip" style="background:#f0f0f0">sin datos</span></p>"""

    sections = (
        bar_section("Ciclos totales", rows, "Ciclos")
        + bar_section("CPI", rows, "CPI")
        + bar_section("Instrucciones ejecutadas", rows, "Instr")
        + bar_section("Stalls por memoria (ciclos)", rows, "Stalls_Mem")
        + bar_section("L1 Hit Rate", rows, "L1_Hit_Rate", "%", fixed_max=100)
        + bar_section("L1 Miss Rate", rows, "L1_Miss_Rate", "%", fixed_max=100)
        + bar_section("L2 Hit Rate", rows, "L2_Hit_Rate", "%", fixed_max=100)
        + bar_section("L2 Miss Rate", rows, "L2_Miss_Rate", "%", fixed_max=100)
        + bar_section("Accesos a memoria principal", rows, "Memory_Accesses")
        + bar_section("Utilizacion de ancho de banda", rows, "BW_Util", "%", fixed_max=100)
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
 th.grp {{ background: #e2e8f0; text-align: center; }}
 section {{ max-width: 760px; }}
 .resumen ul {{ margin: 4px 0; padding-left: 20px; }}
 .resumen li {{ margin: 2px 0; }}
 .nota {{ font-size: 0.85em; color: #555; }}
 .chip {{ padding: 1px 8px; border-radius: 3px; border: 1px solid #ccc; margin-right: 4px; }}
 .formulas {{ display: flex; flex-wrap: wrap; gap: 14px; }}
 .f {{ border: 1px solid #ddd; border-radius: 4px; padding: 6px 10px; }}
 .f pre {{ margin: 4px 0 0; font-size: 0.8em; }}
 .row {{ display: flex; align-items: center; margin: 3px 0; }}
 .lbl {{ width: 150px; font-size: 0.85em; }}
 .track {{ flex: 1; background: #eee; border-radius: 3px; height: 18px; }}
 .bar {{ background: #4575b4; height: 100%; border-radius: 3px; }}
 .val {{ width: 110px; text-align: right; font-size: 0.85em; padding-left: 8px; }}
 .scatter-wrap {{ display: flex; align-items: stretch; }}
 .ylab {{ writing-mode: vertical-rl; transform: rotate(180deg);
          font-size: 0.8em; color: #555; padding-right: 4px; }}
 .scatter {{ position: relative; width: 480px; height: 260px;
             border-left: 2px solid #444; border-bottom: 2px solid #444;
             background: #fafafa; margin: 8px 0 4px 8px; }}
 .dot {{ position: absolute; width: 10px; height: 10px; border-radius: 50%;
         background: #4575b4; transform: translate(-50%, 50%); }}
 .dotlbl {{ position: absolute; font-size: 0.75em; color: #333;
            transform: translate(8px, 50%); white-space: nowrap; }}
 .ytick {{ position: absolute; left: -26px; font-size: 0.72em; color: #777;
           transform: translateY(50%); }}
 .xtick {{ position: absolute; bottom: -18px; font-size: 0.72em; color: #777;
           transform: translateX(-50%); }}
 .xlab {{ font-size: 0.8em; color: #555; margin-left: 40px; margin-top: 14px; }}
</style></head><body>
<h1>Benchmarks del procesador &mdash; metricas de cache</h1>
{summary_section(rows)}
<h2>Tabla de m&eacute;tricas</h2>
<table><thead>{head}</thead><tbody>{body}</tbody></table>
{legend}
{formulas_section()}
{scatter_section(rows)}
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
    render_html(rows, html_path)

    if not args.no_open:
        webbrowser.open(html_path.as_uri())

    print(f"\n{len(rows) - failures}/{len(rows)} benchmarks OK")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
