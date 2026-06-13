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
import time
import webbrowser
from pathlib import Path

ARQUI = Path(__file__).resolve().parent.parent
SIM_VVP = ARQUI / "sim" / "build" / "tb_topG_bench.vvp"

# Sim sin cache (top_no_cash + memoria realista). Se compila como binario
# aparte; no hay colision de modulos (old/ usa nombres con sufijo).
SIM_VVP_NOCACHE = ARQUI / "sim" / "build" / "tb_top_no_cash_bench.vvp"
NO_CACHE_TB = ARQUI / "tb" / "old" / "tb_top_no_cash.sv"
NO_CACHE_CSV = ARQUI / "outputs" / "reports" / "results_no_cash.csv"

# mismos directorios de fuentes que el Makefile (sin make: funciona igual
# desde PowerShell, cmd o bash, y compila UNA sola vez para toda la suite).
# Incluye rtl/TOP/old para que el sim sin cache encuentre top_no_cash; en el
# sim con cache esos modulos quedan como codigo muerto (no se instancian).
SRC_DIRS = ["rtl", "rtl/async_fifo", "rtl/IF", "rtl/DE", "rtl/MEM",
            "rtl/utils", "rtl/TOP", "rtl/TOP/old"]


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


def compile_no_cache():
    """Compila el sim sin cache (top_no_cash + memoria realista) con las mismas
    fuentes + el tb old. No hay colision de modulos. True si compilo."""
    srcs = []
    for d in SRC_DIRS:
        srcs.extend(sorted((ARQUI / d).glob("*.sv")))
    srcs.append(NO_CACHE_TB)

    cmd = ["iverilog", "-g2012", "-o", str(SIM_VVP_NOCACHE)] + [str(s) for s in srcs]
    print(f"[BUILD] iverilog sin-cache ({len(srcs)} fuentes)")
    proc = subprocess.run(cmd, cwd=ARQUI, capture_output=True, text=True)
    if proc.returncode != 0:
        print("[ERROR] fallo la compilacion sin-cache:")
        print("\n".join((proc.stdout + proc.stderr).strip().splitlines()[-8:]))
        return False
    return True

# Rutas de programas y del compilador propio (compi).
PROG = ARQUI / "programs"
SRC = PROG / "src"
COMPILER = ARQUI.parent / "compi" / "main.py"
COMPI_OUT = ARQUI.parent / "compi" / "output" / "bin_output"

# Registro de benchmarks. Los de cache (con fuente .craft) se corren en dos
# niveles de optimizacion del compilador: O0 (sin optimizar) y O1. El HALT_PC
# se calcula en runtime escaneando la instruccion freeze (00600000) del .hex,
# asi sigue valido aunque se recompile y cambie el layout. x11 es el mismo en
# O0 y O1 (la optimizacion preserva el resultado): sirve de oraculo.
BENCHMARKS = [
    {"name": "while loop x<5", "rom": "program.hex", "x11": None,    "max": 20000},
    {"name": "bench_seq",    "src": "bench_seq",    "x11": "7F80",  "max": 300000, "opts": ["O0", "O1"]},
    {"name": "bench_stride", "src": "bench_stride", "x11": "F80",   "max": 300000, "opts": ["O0", "O1"]},
    {"name": "bench_random", "src": "bench_random", "x11": "1C110", "max": 600000, "opts": ["O0", "O1"]},
    {"name": "bench_mmul",   "src": "bench_mmul",   "x11": "3F00",  "max": 600000, "opts": ["O0", "O1"]},
]


def rom_name(base, opt):
    """O0 -> base.hex ; O1 -> base.O1.hex (igual que nombra el compilador)."""
    return f"{base}.hex" if opt == "O0" else f"{base}.{opt}.hex"


def expand_runs(todo):
    """Expande el registro a corridas concretas: cada benchmark con fuente
    genera una corrida por nivel de optimizacion."""
    runs = []
    for b in todo:
        if "src" not in b:
            runs.append({"name": b["name"], "rom": b["rom"], "x11": b.get("x11"),
                         "max": b["max"], "base": None, "opt": None})
        else:
            for opt in b.get("opts", ["O0"]):
                runs.append({"name": f'{b["name"]} ({opt})',
                             "rom": rom_name(b["src"], opt), "x11": b.get("x11"),
                             "max": b["max"], "base": b["name"], "opt": opt})
    return runs


def freeze_halt(rom_path):
    """HALT_PC (hex) = indice de la instruccion freeze (00600000) por 4."""
    try:
        words = [l.strip() for l in rom_path.read_text().splitlines() if l.strip()]
    except OSError:
        return None
    for i, w in enumerate(words):
        if w.lower() == "00600000":
            return f"{i * 4:X}"
    return None


def code_size_bytes(rom):
    """Tamano de codigo = (# palabras del .hex) x 4 bytes."""
    try:
        n = sum(1 for l in rom.read_text().splitlines() if l.strip())
    except OSError:
        return None
    return n * 4


# sidecar con las metricas que solo se conocen al compilar (--compile)
COMPILE_STATS_COLS = ["base", "opt", "Compile_ms", "Opt_Unrolled",
                      "Opt_DCE_Removed", "Opt_Reordered", "Opt_Renamed"]
COMPILE_STATS_CSV = ARQUI / "outputs" / "reports" / "compile_stats.csv"


def parse_opt_stats(stdout, compile_ms):
    """Extrae del stdout del compilador los contadores de optimizacion
    (formato IROptimizationStats.summary()). Solo O1/O2/O3 imprimen la linea;
    en O0 los contadores quedan en 0, pero el tiempo siempre se registra."""
    def field(name):
        m = re.search(rf"{name}=(\d+)", stdout)
        return int(m.group(1)) if m else 0
    return {
        "Compile_ms":      f"{compile_ms:.0f}",
        "Opt_Unrolled":    field("unrolled"),
        "Opt_DCE_Removed": field("dce_removed"),
        "Opt_Reordered":   field("reordered_ir"),
        "Opt_Renamed":     field("renamed_static_registers"),
    }


def save_compile_stats(stats):
    """Persiste {(base,opt): {...}} al sidecar para que las columnas del
    compilador aparezcan tambien en corridas sin --compile."""
    COMPILE_STATS_CSV.parent.mkdir(parents=True, exist_ok=True)
    with open(COMPILE_STATS_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COMPILE_STATS_COLS)
        w.writeheader()
        for (base, opt), d in sorted(stats.items()):
            row = {"base": base, "opt": opt}
            row.update(d)
            w.writerow(row)
    print(f"[STATS] {COMPILE_STATS_CSV}")


def load_compile_stats():
    """Lee el sidecar -> {(base,opt): {Compile_ms, Opt_*}}. {} si no existe."""
    stats = {}
    if not COMPILE_STATS_CSV.exists():
        return stats
    try:
        with open(COMPILE_STATS_CSV, newline="", encoding="utf-8") as f:
            for r in csv.DictReader(f):
                stats[(r["base"], r["opt"])] = {
                    k: r.get(k, "") for k in COMPILE_STATS_COLS[2:]}
    except (OSError, KeyError):
        pass
    return stats


def compile_programs():
    """Recompila los ROM de los benchmarks desde su fuente .craft con el
    compilador propio (O0 y O1) y los copia a programs/. Esto es lo que 'mete
    el compilador' en la suite; sin --compile se usan los .hex versionados."""
    import shutil
    ok = True
    stats = {}   # (base, opt) -> metricas del compilador (tiempo + transformaciones)
    for b in BENCHMARKS:
        if "src" not in b:
            continue
        for opt in b.get("opts", ["O0"]):
            src = SRC / f'{b["src"]}.craft'
            cmd = [sys.executable, str(COMPILER), "-r", "-b", f"-{opt}", str(src)]
            t0 = time.perf_counter()
            proc = subprocess.run(cmd, cwd=COMPILER.parent.parent,
                                  capture_output=True, text=True)
            ms = (time.perf_counter() - t0) * 1000.0
            stem = b["src"] if opt == "O0" else f'{b["src"]}.{opt}'
            out = COMPI_OUT / f"{stem}.hex"
            if proc.returncode == 0 and out.exists():
                shutil.copy(out, PROG / rom_name(b["src"], opt))
                stats[(b["name"], opt)] = parse_opt_stats(proc.stdout, ms)
                print(f"[COMPILE] {rom_name(b['src'], opt)}  ({ms:.0f} ms)")
            else:
                print(f"[ERROR] no compilo {b['src']} {opt}")
                ok = False
    save_compile_stats(stats)
    return ok, stats

CSV_COLS = [
    "Test Ejecutado", "Ciclos", "Instr", "CPI",
    "Stalls_Mem", "Stalls_Control",
    "L1_Reads", "L1_Writes", "L1_Read_Hits", "L1_Read_Misses",
    "L1_Write_Hits", "L1_Write_Misses", "L1_Hit_Rate", "L1_Miss_Rate",
    "L2_Accesses", "L2_Reads", "L2_Writes", "L2_Hits", "L2_Misses",
    "L2_Hit_Rate", "L2_Miss_Rate",
    "Memory_Accesses", "Mem_Transfer_Cycles", "BW_Util",
    # derivadas (spec 5.1/5.2) + del compilador (spec 6); se anexan al final
    "IPC", "AMAT", "Code_Size_Bytes",
    "Compile_ms", "Opt_Unrolled", "Opt_DCE_Removed", "Opt_Reordered", "Opt_Renamed",
]

# campo del [METRICS] -> columna CSV
FIELD_MAP = {
    "cycles": "Ciclos", "instr": "Instr", "cpi": "CPI",
    "stall_mem_cyc": "Stalls_Mem", "ctrl_stalls": "Stalls_Control",
    "l1_reads": "L1_Reads", "l1_writes": "L1_Writes",
    "l1_rd_hits": "L1_Read_Hits", "l1_rd_miss": "L1_Read_Misses",
    "l1_wr_hits": "L1_Write_Hits", "l1_wr_miss": "L1_Write_Misses",
    "l1_hit_rate": "L1_Hit_Rate", "l1_miss_rate": "L1_Miss_Rate",
    "l2_acc": "L2_Accesses", "l2_reads": "L2_Reads", "l2_writes": "L2_Writes",
    "l2_hits": "L2_Hits", "l2_miss": "L2_Misses",
    "l2_hit_rate": "L2_Hit_Rate", "l2_miss_rate": "L2_Miss_Rate",
    "mem_acc": "Memory_Accesses", "mem_xfer_cyc": "Mem_Transfer_Cycles",
    "bw_util": "BW_Util",
}


def run_benchmark(run):
    """Corre una corrida ya expandida (programa + nivel) y devuelve
    (fila_dict | None, status_str). El HALT_PC se calcula del .hex."""
    rom_path = PROG / run["rom"]
    halt = freeze_halt(rom_path)
    if halt is None:
        print(f"[FAIL] {run['name']}: sin freeze en {run['rom']}")
        return None, "SIN HALT"
    safe_name = re.sub(r"[^A-Za-z0-9_-]", "_", run["name"])
    cmd = [
        "vvp", str(SIM_VVP),
        f"+TEST_NAME={safe_name}",
        f"+HALT_PC={halt}",
        f"+MAX_CYCLES={run['max']}",
        f"+FILE_ROM=programs/{run['rom']}",
        "+FILE_RAM=programs/data.hex",
    ]
    if run["x11"]:
        cmd.append(f"+EXPECT_X11={run['x11']}")
    print(f"[RUN ] {run['name']}  ({run['rom']})")
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
    print(f"[{'OK  ' if status == 'OK' else 'FAIL'}] {run['name']}: {status}")
    if row is not None:
        row["Test Ejecutado"] = run["name"]
        row["_status"] = status
        row["_base"] = run["base"]
        row["_opt"] = run["opt"]
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


# La latencia realista sin cache infla mucho los ciclos: se sube el techo.
NO_CACHE_MAX_MULT = 40
NO_CACHE_MAX_FLOOR = 2_000_000


def run_no_cache(run):
    """Corre el programa (O0) en el sim sin cache. Misma ROM y mismo HALT_PC
    que la corrida con cache (apples-to-apples). Devuelve la fila
    {Test Ejecutado, Ciclos, Instr, CPI, Stalls_Mem} o None."""
    rom_path = PROG / run["rom"]
    halt = freeze_halt(rom_path)
    if halt is None:
        print(f"[FAIL] sin-cache {run['name']}: sin freeze en {run['rom']}")
        return None
    max_cyc = max(run["max"] * NO_CACHE_MAX_MULT, NO_CACHE_MAX_FLOOR)
    safe_name = re.sub(r"[^A-Za-z0-9_-]", "_", run["name"])
    cmd = [
        "vvp", str(SIM_VVP_NOCACHE),
        f"+TEST_NAME={safe_name}",
        f"+HALT_PC={halt}",
        f"+MAX_CYCLES={max_cyc}",
        f"+FILE_ROM=programs/{run['rom']}",
        "+FILE_RAM=programs/data.hex",
    ]
    if run["x11"]:
        cmd.append(f"+EXPECT_X11={run['x11']}")
    print(f"[RUN ] sin-cache {run['name']}  ({run['rom']})")
    proc = subprocess.run(cmd, cwd=ARQUI, capture_output=True, text=True)
    out = proc.stdout + proc.stderr
    row = parse_metrics(out)   # mismo FIELD_MAP: Ciclos/Instr/CPI/Stalls_Mem
    if row is None:
        tail = "\n".join(out.strip().splitlines()[-4:])
        print(f"[FAIL] sin-cache {run['name']}: sin [METRICS]\n{tail}")
        return None
    row["Test Ejecutado"] = run["name"]
    return row


def run_no_cache_pass(todo, with_cache_rows):
    """Compila el sim sin cache una vez, corre cada programa O0, acumula filas y
    escribe results_no_cash.csv. Devuelve {nombre: {Ciclos, CPI}} para el HTML.
    Tolerante a fallos: si no compila/corre, devuelve {} y el reporte usa solo
    el modelo analitico de trafico."""
    if not compile_no_cache():
        print("[WARN] sin-cache no compilo; el reporte usara solo el modelo analitico")
        return {}
    # solo el baseline O0 (los .hex O1 viven en la seccion del compilador)
    o0_runs = [r for r in expand_runs(todo) if r["opt"] in (None, "O0")]
    # ciclos con cache por nombre, para el chequeo de sanidad sin >= con
    cyc_con = {r.get("Test Ejecutado"): _fnum(r.get("Ciclos")) for r in with_cache_rows}
    nc_rows = []
    for run in o0_runs:
        row = run_no_cache(run)
        if row is None:
            continue
        sin = _fnum(row.get("Ciclos"))
        con = cyc_con.get(run["name"])
        if sin is not None and con is not None and sin < con:
            print(f"[WARN] sin-cache {run['name']}: ciclos sin ({sin:.0f}) < con "
                  f"({con:.0f}) -> revisar HALT_PC/contadores")
        nc_rows.append(row)
    if nc_rows:
        write_csv(nc_rows, NO_CACHE_CSV)
    return load_no_cache()


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


def _ipc(r):
    """IPC = Instrucciones / Ciclos (la metrica que nombra el spec)."""
    cyc, instr = _fnum(r.get("Ciclos")), _fnum(r.get("Instr"))
    return instr / cyc if (cyc and instr is not None and cyc > 0) else None


def _amat(miss_l1, miss_l2):
    """AMAT = hitL1 + missL1*(hitL2 + missL2*penal_mem), con hitL1=1, hitL2=8,
    penalidad a memoria=25. miss_l1/miss_l2 en fraccion (0-1)."""
    return 1.0 + miss_l1 * (8.0 + miss_l2 * 25.0)


def _amat_row(r):
    """AMAT por benchmark a partir de sus miss rates (en %)."""
    m1, m2 = _fnum(r.get("L1_Miss_Rate")), _fnum(r.get("L2_Miss_Rate"))
    if m1 is None or m2 is None:
        return None
    return _amat(m1 / 100.0, m2 / 100.0)


def enrich_row(row, run, stats):
    """Agrega las metricas derivadas (IPC, AMAT, tamano de codigo) y las del
    compilador (desde el sidecar o la captura de --compile) a una fila."""
    ipc = _ipc(row)
    if ipc is not None:
        row["IPC"] = f"{ipc:.4f}"
    amat = _amat_row(row)
    if amat is not None:
        row["AMAT"] = f"{amat:.2f}"
    cs = code_size_bytes(PROG / run["rom"])
    if cs is not None:
        row["Code_Size_Bytes"] = cs
    st = stats.get((run.get("base"), run.get("opt"))) if run.get("base") else None
    if st:
        row.update(st)


def _card(title, big, sub):
    return (f'<div class="card"><div class="ct">{title}</div>'
            f'<div class="cb">{big}</div><div class="cs">{sub}</div></div>')


def cache_effect_section(base_rows, no_cache):
    """Comparacion REAL de ciclos con vs sin cache: el MISMO programa (O0,
    misma ROM, mismo HALT_PC) corrido en 'top' (jerarquia L1/L2) y en
    'top_no_cash' (memoria realista, sin cache). Aceleracion = ciclos_sin /
    ciclos_con. Si no hay datos sin cache, la seccion se auto-oculta."""
    data = _sorted_rows(base_rows)
    body, any_real = "", False
    for r in data:
        name = r["Test Ejecutado"]
        ref = no_cache.get(name)
        con = _fnum(r.get("Ciclos"))
        sin = _fnum(ref.get("Ciclos")) if ref else None
        cpi_con = _fnum(r.get("CPI"))
        cpi_sin = _fnum(ref.get("CPI")) if ref else None
        if sin and con and con > 0:
            sp = sin / con
            any_real = True
            spcol = heat_color(min(sp, 5.0) / 5.0 * 100.0)
            sp_html = (f'<td style="background:{spcol};color:#fff">'
                       f'<b>{sp:.2f}&times;</b></td>')
        else:
            sp_html = "<td>&mdash;</td>"
        body += (f'<tr><td>{name}</td>'
                 f'<td>{_num(sin)}</td><td>{_num(con)}</td>'
                 f'{sp_html}'
                 f'<td>{_num(cpi_sin, 2)}</td><td>{_num(cpi_con, 2)}</td></tr>\n')
    if not any_real:
        return ""   # sin corrida real sin cache -> no mostrar (queda el modelo 5.3)
    return f"""
<section><h2>Aceleraci&oacute;n del cach&eacute;: ciclos con vs sin cach&eacute; (medido)</h2>
<p class="nota">Mismo programa (O0), misma ROM, mismo punto de parada.
 <b>Sin cach&eacute;</b> = el procesador con memoria realista
 (<code>top_no_cash</code>: divisor de reloj 100&rarr;50&nbsp;MHz + burst de 8,
 ~22 ciclos por acceso a RAM). <b>Con cach&eacute;</b> = la jerarqu&iacute;a L1/L2.
 La <b>Aceleraci&oacute;n</b> es cu&aacute;ntas veces menos ciclos tarda el programa
 gracias al cach&eacute; (ciclos sin / ciclos con). Esto es la medida directa del
 efecto de la memoria; el bloque 5.3 muestra el otro eje (tr&aacute;fico al bus).</p>
<table><thead><tr>
 <th>Programa</th><th>Ciclos sin cach&eacute;</th><th>Ciclos con cach&eacute;</th>
 <th>Aceleraci&oacute;n</th><th>CPI sin</th><th>CPI con</th>
</tr></thead><tbody>{body}</tbody></table>
</section>
"""


def formulas_section():
    return """
<section><h2>F&oacute;rmulas</h2>
<div class="formulas">
<div class="f"><b>IPC</b><pre>Instrucciones / Ciclos</pre></div>
<div class="f"><b>CPI</b><pre>Ciclos / Instrucciones  (= 1/IPC)</pre></div>
<div class="f"><b>AMAT</b><pre>1 + missL1 x (8 + missL2 x 25)
hit L1=1, hit L2=8, mem=25 ciclos</pre></div>
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


def causal_chain(rows):
    """Vista integrada: por benchmark (del mas rapido al mas lento) la cadena
    L1 aciertos -> espera de memoria -> CPI, en tabla. Mas verde (aciertos) y
    menos rojo (espera) = menor CPI."""
    data = [r for r in rows if _fnum(r.get("CPI")) is not None]
    if not data:
        return ""
    data = sorted(data, key=lambda r: _fnum(r.get("CPI")))
    body = ""
    for r in data:
        hit = r.get("L1_Hit_Rate")
        stall = _stall_pct(r)
        body += (
            f'<tr><td>{r["Test Ejecutado"]}</td>'
            f'<td style="background:{heat_color(hit)};color:#fff">{_num(hit, 1, "%")}</td>'
            f'<td style="background:{heat_color(stall, invert=True)}">{_num(stall, 1, "%")}</td>'
            f'<td>{_num(r.get("CPI"), 2)}</td></tr>\n')
    return f"""
<section><h2>Cadena causal: localidad &rarr; aciertos &rarr; esperas &rarr; CPI</h2>
<p class="nota">Del m&aacute;s r&aacute;pido (arriba) al m&aacute;s lento (abajo).
 M&aacute;s aciertos en L1 (verde) y menos espera de memoria (rojo) &rarr; menor CPI.
 Es la misma cadena para todos: el patr&oacute;n de acceso manda.</p>
<table><thead><tr>
 <th>Benchmark</th><th>L1 aciertos</th><th>Espera mem</th><th>CPI</th>
</tr></thead><tbody>{body}</tbody></table>
</section>
"""


def _num(v, dec=0, suffix=""):
    """Formatea un valor numerico de la fila; '&mdash;' si no es numero."""
    f = _fnum(v)
    if f is None:
        return "&mdash;"
    return (f"{f:.{dec}f}" if dec else f"{int(f):,}") + suffix


def compiler_section(rows):
    """Compara cada benchmark en O0 vs O1: cuanto acelera el compilador y como
    afecta al cache. El resultado (x11) valida cada corrida; una O1 que rompe
    el resultado se marca y no cuenta como aceleracion."""
    bases = {}
    for r in rows:
        if r.get("_base") and r.get("_opt"):
            bases.setdefault(r["_base"], {})[r["_opt"]] = r
    pairs = sorted((b, v) for b, v in bases.items() if "O0" in v and "O1" in v)
    if not pairs:
        return ""
    # tabla A: efecto en rendimiento
    perf = ""
    for base, v in pairs:
        o0, o1 = v["O0"], v["O1"]
        broke = o1.get("_status", "OK") != "OK" or _fnum(o1.get("Ciclos")) is None
        c0, c1 = _fnum(o0.get("Ciclos")), _fnum(o1.get("Ciclos"))
        speed = f"{c0 / c1:.2f}&times;" if (c0 and c1 and not broke) else "&mdash;"
        name = base + (' <span class="bad">&#10007; resultado incorrecto</span>'
                       if broke else "")
        perf += (
            f"<tr><td>{name}</td>"
            f"<td>{_num(o0.get('Ciclos'))}</td><td>{_num(o1.get('Ciclos'))}</td>"
            f"<td>{speed}</td>"
            f"<td>{_num(o0.get('IPC'), 3)}</td><td>{_num(o1.get('IPC'), 3)}</td>"
            f"<td>{_num(o0.get('CPI'), 2)}</td><td>{_num(o1.get('CPI'), 2)}</td>"
            f"<td>{_num(o0.get('L1_Hit_Rate'), 1, '%')}</td>"
            f"<td>{_num(o1.get('L1_Hit_Rate'), 1, '%')}</td></tr>\n")
    # tabla B: transformaciones del compilador + costo (spec seccion 6)
    transf = ""
    for base, v in pairs:
        o0, o1 = v["O0"], v["O1"]
        transf += (
            f"<tr><td>{base}</td>"
            f"<td>{_num(o0.get('Instr'))}</td><td>{_num(o1.get('Instr'))}</td>"
            f"<td>{_num(o0.get('Code_Size_Bytes'))}</td>"
            f"<td>{_num(o1.get('Code_Size_Bytes'))}</td>"
            f"<td>{_num(o0.get('Ciclos'))}</td><td>{_num(o1.get('Ciclos'))}</td>"
            f"<td>{_num(o1.get('Compile_ms'))}</td>"
            f"<td>{_num(o1.get('Opt_Unrolled'))}</td>"
            f"<td>{_num(o1.get('Opt_DCE_Removed'))}</td>"
            f"<td>{_num(o1.get('Opt_Reordered'))}</td>"
            f"<td>{_num(o1.get('Opt_Renamed'))}</td></tr>\n")
    return f"""
<section><h2>Efecto del compilador (O0 &rarr; O1)</h2>
<p class="nota"><b>O0</b> = el programa compilado <b>sin optimizar</b>;
 <b>O1</b> = el mismo programa <b>optimizado</b> por el compilador (desenrolla
 bucles y renombra registros). Se comparan los dos para ver cu&aacute;nto ayuda el
 compilador. Cada corrida se valida con el resultado esperado en <code>x11</code>.</p>
<h3>Rendimiento &mdash; qu&eacute; tan r&aacute;pido corre</h3>
<p class="nota"><b>Acelera</b> = veces m&aacute;s r&aacute;pido (Ciclos O0 / Ciclos O1).
 O1 baja los ciclos, pero a veces baja el hit rate de L1: al eliminar las
 instrucciones baratas del control del bucle, los fallos obligatorios de
 cach&eacute; quedan como mayor fracci&oacute;n.
 <span class="bad">&#10007; resultado incorrecto</span> significa que la versi&oacute;n
 O1 dio un valor distinto al esperado en x11: la optimizaci&oacute;n rompi&oacute; ese
 programa (es un bug del compilador, no del cach&eacute;), por eso no se mide su
 aceleraci&oacute;n.</p>
<table><thead><tr>
 <th>Benchmark</th><th>Ciclos O0</th><th>Ciclos O1</th><th>Acelera</th>
 <th>IPC O0</th><th>IPC O1</th><th>CPI O0</th><th>CPI O1</th>
 <th>L1 Hit O0</th><th>L1 Hit O1</th>
</tr></thead><tbody>{perf}</tbody></table>
<h3>Transformaciones del compilador y costo (Secci&oacute;n 6 del enunciado)</h3>
<table><thead><tr>
 <th>Benchmark</th><th>Instr O0</th><th>Instr O1</th>
 <th>C&oacute;digo O0 (B)</th><th>C&oacute;digo O1 (B)</th>
 <th>Ciclos O0</th><th>Ciclos O1</th><th>Compilaci&oacute;n (ms)</th>
 <th>Unrolled</th><th>DCE</th><th>Reord.</th><th>Renamed</th>
</tr></thead><tbody>{transf}</tbody></table>
<p class="nota">C&oacute;digo en bytes = #instrucciones &times; 4. Unrolled/DCE/Reord./Renamed:
 instrucciones desenrolladas / eliminadas / reordenadas / renombradas por el
 compilador (de su salida). Vac&iacute;o (&mdash;) si no se corri&oacute; con <code>--compile</code>.</p>
</section>
"""


def _sorted_rows(rows):
    """Filas con datos, ordenadas del mejor CPI (mas rapido) al peor."""
    return sorted([r for r in rows if _fnum(r.get("CPI")) is not None],
                  key=lambda r: _fnum(r.get("CPI")))


def processor_section(rows):
    """5.1 Metricas del procesador (Cuadro 1 del enunciado)."""
    body = ""
    for r in _sorted_rows(rows):
        body += (f'<tr><td>{r.get("Test Ejecutado", "")}</td>'
                 f'<td>{_num(r.get("Ciclos"))}</td>'
                 f'<td>{_num(r.get("Instr"))}</td>'
                 f'<td>{_num(r.get("IPC"), 3)}</td>'
                 f'<td>{_num(r.get("CPI"), 2)}</td>'
                 f'<td>{_num(r.get("Stalls_Mem"))}</td>'
                 f'<td>{_num(r.get("Stalls_Control"))}</td></tr>\n')
    return f"""
<section><h2>5.1 M&eacute;tricas del procesador</h2>
<p class="nota">IPC = Instrucciones/Ciclos (mayor es mejor); CPI = 1/IPC (menor es
 mejor, base de la narrativa). Stalls MEM = ciclos perdidos en la etapa MEM
 (loads/stores); Stalls control = ciclos de fetch perdidos por branch tomado.</p>
<table><thead><tr>
 <th>Benchmark</th><th>Ciclos</th><th>Instr</th><th>IPC</th><th>CPI</th>
 <th>Stalls MEM</th><th>Stalls control</th>
</tr></thead><tbody>{body}</tbody></table>
</section>
"""


def cache_section(rows):
    """5.2 Metricas de la jerarquia de cache (Cuadro 2): conteos crudos + tasas
    + AMAT por benchmark, y un AMAT global con los miss rates promediados."""
    data = _sorted_rows(rows)
    body = ""
    for r in data:
        l1h, l1m = r.get("L1_Hit_Rate"), r.get("L1_Miss_Rate")
        l2h, l2m = r.get("L2_Hit_Rate"), r.get("L2_Miss_Rate")
        body += (
            f'<tr><td>{r.get("Test Ejecutado", "")}</td>'
            f'<td>{_num(r.get("L1_Reads"))}</td><td>{_num(r.get("L1_Writes"))}</td>'
            f'<td>{_num(r.get("L1_Read_Hits"))}</td><td>{_num(r.get("L1_Read_Misses"))}</td>'
            f'<td>{_num(r.get("L1_Write_Hits"))}</td><td>{_num(r.get("L1_Write_Misses"))}</td>'
            f'<td style="background:{heat_color(l1h)};color:#fff">{_num(l1h, 2)}</td>'
            f'<td>{_num(l1m, 2)}</td>'
            f'<td>{_num(r.get("L2_Reads"))}</td><td>{_num(r.get("L2_Writes"))}</td>'
            f'<td>{_num(r.get("L2_Accesses"))}</td><td>{_num(r.get("L2_Hits"))}</td>'
            f'<td>{_num(r.get("L2_Misses"))}</td>'
            f'<td style="background:{heat_color(l2h)};color:#fff">{_num(l2h, 2)}</td>'
            f'<td>{_num(l2m, 2)}</td>'
            f'<td>{_num(_amat_row(r), 2)}</td></tr>\n')
    m1 = [_fnum(r.get("L1_Miss_Rate")) for r in data]
    m2 = [_fnum(r.get("L2_Miss_Rate")) for r in data]
    m1 = [x for x in m1 if x is not None]
    m2 = [x for x in m2 if x is not None]
    amat_g = ""
    if m1 and m2:
        a1, a2 = sum(m1) / len(m1), sum(m2) / len(m2)
        g = _amat(a1 / 100.0, a2 / 100.0)
        amat_g = (f'<p class="nota"><b>AMAT global</b> (miss rates promediados: '
                  f'L1 {a1:.2f}%, L2 {a2:.2f}%) = <b>{g:.2f} ciclos</b>.</p>')
    return f"""
<section><h2>5.2 M&eacute;tricas de la jerarqu&iacute;a de cach&eacute;</h2>
<p class="nota">Los conteos crudos (los datos que se usaron) junto a las tasas.
 AMAT por benchmark = 1 + missL1&middot;(8 + missL2&middot;25).</p>
<div class="tablewrap"><table class="metrics"><thead>
<tr><th rowspan="2">Benchmark</th><th colspan="8" class="grp">L1-D</th>
 <th colspan="7" class="grp">L2</th><th rowspan="2">AMAT</th></tr>
<tr><th>Reads</th><th>Writes</th><th>R-Hit</th><th>R-Miss</th><th>W-Hit</th>
 <th>W-Miss</th><th>Hit%</th><th>Miss%</th>
 <th>Reads</th><th>Writes</th><th>Acc</th><th>Hits</th><th>Miss</th><th>Hit%</th><th>Miss%</th></tr>
</thead><tbody>{body}</tbody></table></div>
{amat_g}
</section>
"""


def memory_section(rows):
    """5.3 Metricas de memoria principal + trafico con vs sin cache."""
    data = _sorted_rows(rows)
    body = ""
    for r in data:
        body += (f'<tr><td>{r.get("Test Ejecutado", "")}</td>'
                 f'<td>{_num(r.get("Memory_Accesses"))}</td>'
                 f'<td>{_num(r.get("Mem_Transfer_Cycles"))}</td>'
                 f'<td>{_num(r.get("BW_Util"), 2)}</td></tr>\n')
    # Trafico al bus: sin cache (modelo) cada acceso del programa baja a RAM
    # = L1 Reads + Writes; con cache solo Memory_Accesses (misses + write-through).
    traffic = ""
    for r in data:
        rd, wr = _fnum(r.get("L1_Reads")), _fnum(r.get("L1_Writes"))
        acc, instr = _fnum(r.get("Memory_Accesses")), _fnum(r.get("Instr"))
        nocache = (rd + wr) if (rd is not None and wr is not None) else None
        red = f"{nocache / acc:.1f}&times;" if (nocache and acc) else "&mdash;"
        api_no = f"{nocache / instr:.3f}" if (nocache is not None and instr) else "&mdash;"
        api_si = f"{acc / instr:.3f}" if (acc is not None and instr) else "&mdash;"
        traffic += (f'<tr><td>{r.get("Test Ejecutado", "")}</td>'
                    f'<td>{_num(nocache)}</td><td>{_num(acc)}</td>'
                    f'<td><b>{red}</b></td><td>{api_no}</td><td>{api_si}</td></tr>\n')
    return f"""
<section><h2>5.3 M&eacute;tricas de memoria principal</h2>
<p class="nota">Accesos = misses de lectura de L2 + stores drenados (write-through).
 BW = fracci&oacute;n del <b>ancho de banda te&oacute;rico m&aacute;ximo</b> del bus
 (0.5 palabras/ciclo: memoria a 50 MHz, burst de 8) usada con cach&eacute;.</p>
<table><thead><tr>
 <th>Benchmark</th><th>Accesos a memoria</th><th>Ciclos de transferencia</th>
 <th>BW %</th>
</tr></thead><tbody>{body}</tbody></table>

<h3>Tr&aacute;fico al bus de memoria: con vs sin cach&eacute;</h3>
<p class="nota"><b>Sin cach&eacute;</b> (modelo anal&iacute;tico): cada acceso del programa
 baja a RAM &rarr; L1 Reads + Writes. <b>Con cach&eacute;</b>: solo lo que falla
 (Memory_Accesses). La <b>Reducci&oacute;n</b> es cu&aacute;ntas veces menos tr&aacute;fico
 pone el cach&eacute; en el bus. <i>Acc/instr</i> = transacciones a memoria por
 instrucci&oacute;n.</p>
<table><thead><tr>
 <th>Benchmark</th><th>Sin cach&eacute; (ops a RAM)</th><th>Con cach&eacute; (accesos)</th>
 <th>Reducci&oacute;n</th><th>Acc/instr sin</th><th>Acc/instr con</th>
</tr></thead><tbody>{traffic}</tbody></table>
</section>
"""


def render_html(rows, path, no_cache):
    # Las tablas 5.1/5.2/5.3 usan el baseline sin optimizar (O0); las variantes
    # O1 viven en la seccion del compilador y en el CSV completo.
    base_rows = [r for r in rows if r.get("_opt") in (None, "O0")]

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>Benchmarks - rendimiento de cache</title>
<style>
 body {{ font-family: system-ui, sans-serif; margin: 24px; color: #222; max-width: 1000px; }}
 h1 {{ font-size: 1.4em; }}  h2 {{ font-size: 1.05em; margin: 20px 0 6px; }}
 h3 {{ font-size: 0.92em; margin: 12px 0 4px; color: #334; }}
 table {{ border-collapse: collapse; font-size: 0.86em; }}
 table.metrics {{ font-size: 0.78em; }}
 th, td {{ border: 1px solid #ccc; padding: 4px 8px; text-align: right; }}
 th {{ background: #f0f0f0; }}  td:first-child, th:first-child {{ text-align: left; }}
 th.grp {{ background: #e2e8f0; text-align: center; }}
 .tablewrap {{ overflow-x: auto; }}
 code {{ background: #f0f0f0; padding: 1px 4px; border-radius: 3px; }}
 .nota {{ font-size: 0.85em; color: #555; }}
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
 .bad {{ color: #b00; font-size: 0.8em; font-weight: 600; }}
</style></head><body>
<h1>Benchmarks del procesador &mdash; rendimiento de la jerarqu&iacute;a de cach&eacute;</h1>
{cache_effect_section(base_rows, no_cache)}
{processor_section(base_rows)}
{cache_section(base_rows)}
{memory_section(base_rows)}
{causal_chain(base_rows)}
{compiler_section(rows)}
{formulas_section()}
</body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"[HTML] {path}")


def main():
    ap = argparse.ArgumentParser(description="Corre benchmarks y genera CSV + HTML")
    ap.add_argument("--only", help="correr solo el benchmark con este nombre")
    ap.add_argument("--list", action="store_true", help="listar benchmarks")
    ap.add_argument("--no-open", action="store_true", help="no abrir el HTML")
    ap.add_argument("--compile", action="store_true",
                    help="recompilar los ROM desde .craft con el compilador (O0 y O1)")
    ap.add_argument("--no-nocache", action="store_true",
                    help="omitir la pasada SIN cache (top_no_cash); itera mas rapido")
    args = ap.parse_args()

    if args.list:
        for b in BENCHMARKS:
            opts = "/".join(b["opts"]) if "src" in b else "pre-construido"
            print(f"  {b['name']:20s} {opts}")
        return 0

    todo = [b for b in BENCHMARKS if not args.only or b["name"] == args.only]
    if not todo:
        print(f"No existe el benchmark '{args.only}'. Usa --list.")
        return 1

    if args.compile:
        ok, stats = compile_programs()
        if not ok:
            return 1
    else:
        stats = load_compile_stats()   # del sidecar de una corrida previa con --compile

    if not build_sim():
        return 1

    rows, failures = [], 0
    for run in expand_runs(todo):
        row, status = run_benchmark(run)
        if row is None:
            rows.append({"Test Ejecutado": run["name"], "_status": status,
                         "_base": run["base"], "_opt": run["opt"]})
            failures += 1
        else:
            enrich_row(row, run, stats)
            rows.append(row)
            if status != "OK":
                failures += 1

    reports = ARQUI / "outputs" / "reports"
    reports.mkdir(parents=True, exist_ok=True)
    write_csv(rows, reports / "results.csv")

    # Pasada SIN cache (top_no_cash + memoria realista): ciclos reales por
    # programa para la comparacion con vs sin cache. Lenta -> se puede omitir.
    if args.no_nocache:
        no_cache = load_no_cache()   # usa results_no_cash.csv previo si existe
    else:
        no_cache = run_no_cache_pass(todo, rows)

    html_path = reports / "results.html"
    render_html(rows, html_path, no_cache)

    if not args.no_open:
        webbrowser.open(html_path.as_uri())

    print(f"\n{len(rows) - failures}/{len(rows)} benchmarks OK")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
