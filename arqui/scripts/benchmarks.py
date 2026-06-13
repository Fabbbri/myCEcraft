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
P2_SRC = ARQUI.parent / "compi" / "Defensa" / "P2"

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
    {"name": "bench_seq",    "src": "bench_seq",    "x11": "7F80",  "max": 300000, "opts": ["O0", "O1", "O2", "O3"]},
    {"name": "bench_stride", "src": "bench_stride", "x11": "F80",   "max": 300000, "opts": ["O0", "O1", "O2", "O3"]},
    {"name": "bench_random", "src": "bench_random", "x11": "1C110", "max": 600000, "opts": ["O0", "O1", "O2", "O3"]},
    {"name": "bench_mmul",   "src": "bench_mmul",   "x11": "3F00",  "max": 600000, "opts": ["O0", "O1", "O2", "O3"]},
]


# ──────────────────────────────────────────────────────────────────────────────
# Benchmarks de Defensa P2: 12 programas agrupados por optimizacion objetivo.
# Cada programa se corre con O0 (baseline) y con su flag especifico activado.
# El flag especifico se pasa directamente al compilador (--unroll, --rename-registers,
# --dce, --reorder); el nivel resultante lo determina el compilador.
# x11 = resultado esperado (hexadecimal sin '0x'), extraido de los comentarios.
# ──────────────────────────────────────────────────────────────────────────────
P2_OPT_FLAG = {
    "unroll":  "--unroll",
    "rename":  "--rename-registers",
    "dce":     "--dce",
    "reorder": "--reorder",
}

P2_BENCHMARKS = [
    # ── grupo unroll ──────────────────────────────────────────────────────────
    {"group": "unroll",  "file": "01_unroll_for_limite_literal",     "x11": "1C",  "max": 100000,
     "label": "unroll_for_cte",      "desc": "FOR N=8 literal, 2 acumuladores; unroller elimina 6 de cada 8 saltos (suma=28)"},
    {"group": "unroll",  "file": "02_unroll_while_limite_variable",  "x11": "F",   "max": 100000,
     "label": "unroll_while_varN",   "desc": "WHILE con limite en variable N=6; unroller propaga la constante y aplica factor 2 (suma=15)"},
    {"group": "unroll",  "file": "03_unroll_for_factor_grande",      "x11": "1F0", "max": 200000,
     "label": "unroll_for_grande",   "desc": "FOR N=32 literal, factor auto 8; 32 iter -> 4 bloques, saltos /8 (suma=496)"},
    # ── grupo rename ──────────────────────────────────────────────────────────
    {"group": "rename",  "file": "04_rename_waw_secuencial",         "x11": "42",  "max": 100000,
     "label": "rename_for_WAW",      "desc": "WAW: 'a' reescrita 3 veces; rename asigna registros fisicos distintos a t0,t1,t2 (suma=66)"},
    {"group": "rename",  "file": "05_rename_war_if_else",            "x11": "36",  "max": 100000,
     "label": "rename_if_WAR",       "desc": "WAR: 'lim' leida en condicion y sobreescrita en else; rename crea versiones SSA (total=54)"},
    {"group": "rename",  "file": "06_rename_waw_war_funcion",        "x11": "42",  "max": 100000,
     "label": "rename_func_mixto",   "desc": "WAW+WAR en funcion con if/else; rename crea versiones independientes por rama (total=66)"},
    # ── grupo dce ────────────────────────────────────────────────────────────
    {"group": "dce",     "file": "07_dce_ramas_muertas_if",          "x11": "5",   "max": 50000,
     "label": "dce_if_muerto",       "desc": "IF/ELSE con ambas ramas calculando valores muertos; DCE elimina todo excepto el summon (estado=5)"},
    {"group": "dce",     "file": "08_dce_muerto_en_funcion_y_main",  "x11": "7",   "max": 50000,
     "label": "dce_func_y_main",     "desc": "Cadena muerta dentro de funcion + cadena muerta en main entre dos summons (acum=7)"},
    {"group": "dce",     "file": "09_dce_cadenas_pre_post_llamada",  "x11": "6",   "max": 50000,
     "label": "dce_cadenas_post",    "desc": "Cadenas muertas antes y despues de summon; retorno de llamada alimenta cadena muerta (ctr=6)"},
    # ── grupo reorder ────────────────────────────────────────────────────────
    {"group": "reorder", "file": "10_reorder_1load_uso_inmediato",   "x11": "24",  "max": 100000,
     "label": "reorder_1load_if",    "desc": "1 load global con uso inmediato; scheduler mueve w1,w2,w3 entre lw y uso (total=36)"},
    {"group": "reorder", "file": "11_reorder_2loads_uso_inmediato",  "x11": "41",  "max": 100000,
     "label": "reorder_2loads",      "desc": "2 loads globales con uso inmediato; scheduler llena stall de cada lw con trabajo independiente (total=65)"},
    {"group": "reorder", "file": "12_reorder_3loads_uso_inmediato",  "x11": "1B",  "max": 100000,
     "label": "reorder_3loads_if",   "desc": "3 loads globales con uso inmediato; scheduler intercala trabajo independiente entre cada lw y su uso (total=27)"},
]

# Niveles que se corren para cada programa P2: O0 baseline + flag especifico
P2_VARIANTS = ["O0", "opt"]   # "opt" = flag especifico del grupo


def p2_rom_name(label, variant):
    """Nombre del .hex para un benchmark P2."""
    return f"p2_{label}.{variant}.hex"


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
COMPILE_STATS_CSV    = ARQUI / "outputs" / "reports" / "compile_stats.csv"
P2_COMPILE_STATS_CSV = ARQUI / "outputs" / "reports" / "compile_stats_p2.csv"


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


def save_p2_compile_stats(stats):
    """Persiste {(label, variant): {...}} al sidecar P2."""
    P2_COMPILE_STATS_CSV.parent.mkdir(parents=True, exist_ok=True)
    with open(P2_COMPILE_STATS_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COMPILE_STATS_COLS)
        w.writeheader()
        for (label, variant), d in sorted(stats.items()):
            row = {"base": label, "opt": variant}
            row.update(d)
            w.writerow(row)
    print(f"[STATS] {P2_COMPILE_STATS_CSV}")


def load_p2_compile_stats():
    """Lee el sidecar P2 -> {(label, variant): {Compile_ms, Opt_*}}."""
    stats = {}
    if not P2_COMPILE_STATS_CSV.exists():
        return stats
    try:
        with open(P2_COMPILE_STATS_CSV, newline="", encoding="utf-8") as f:
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


def compile_p2_programs():
    """Compila los 12 programas de Defensa/P2 en dos variantes cada uno:
    O0 (baseline sin ninguna opt) y la flag especifica de su grupo
    (--unroll, --rename-registers, --dce o --reorder).
    Los .hex se guardan en programs/ con nombre p2_{label}.{variant}.hex."""
    import shutil
    ok = True
    stats = {}   # (label, variant) -> metricas del compilador
    for b in P2_BENCHMARKS:
        src = P2_SRC / f'{b["file"]}.craft'
        flag = P2_OPT_FLAG[b["group"]]
        for variant, extra_flags in [("O0", ["-O0"]), ("opt", [flag])]:
            cmd = [sys.executable, str(COMPILER), "-r", "-b"] + extra_flags + [str(src)]
            t0 = time.perf_counter()
            proc = subprocess.run(cmd, cwd=COMPILER.parent.parent,
                                  capture_output=True, text=True)
            ms = (time.perf_counter() - t0) * 1000.0
            # El compilador genera el hex con el nombre del stem del archivo fuente.
            # Para O0 -> {file}.hex; para flags individuales el compilador usa el
            # nivel resultante (ej. --unroll => nivel 1 => {file}.O1.hex).
            # Buscamos cualquier .hex generado con ese stem en COMPI_OUT.
            stem = b["file"]
            dest = PROG / p2_rom_name(b["label"], variant)
            if proc.returncode == 0:
                # Encuentra el .hex generado (puede ser {stem}.hex o {stem}.O1.hex etc.)
                # Excluye los .data.hex para ordenar solo los hex de instrucciones
                candidates = sorted(
                    [p for p in COMPI_OUT.glob(f"{stem}*.hex") if not p.name.endswith(".data.hex")],
                    key=lambda p: len(p.name))
                if candidates:
                    shutil.copy(candidates[0], dest)
                    # Copia el .data.hex (RAM de globales) si existe
                    data_candidates = list(COMPI_OUT.glob(f"{stem}*.data.hex"))
                    data_dest = PROG / p2_rom_name(b["label"], variant).replace(".hex", ".data.hex")
                    if data_candidates:
                        shutil.copy(data_candidates[0], data_dest)
                    elif data_dest.exists():
                        data_dest.unlink()
                    stats[(b["label"], variant)] = parse_opt_stats(proc.stdout, ms)
                    print(f"[P2] {dest.name}  ({ms:.0f} ms)")
                    # Limpia los artefactos del compilador para no mezclar corridas
                    for c in COMPI_OUT.glob(f"{stem}*"):
                        c.unlink(missing_ok=True)
                else:
                    print(f"[ERROR] no encontro hex para {stem} ({variant})")
                    ok = False
            else:
                tail = "\n".join((proc.stdout + proc.stderr).strip().splitlines()[-4:])
                print(f"[ERROR] no compilo {b['file']} ({variant}):\n{tail}")
                ok = False
    save_p2_compile_stats(stats)
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


def run_p2_benchmarks(p2_stats):
    """Corre los 12 benchmarks de Defensa/P2 (O0 + variante opt) y devuelve
    una lista de dicts con los resultados, listos para pasar a p2_section."""
    results = []
    for b in P2_BENCHMARKS:
        entry = {"label": b["label"], "group": b["group"],
                 "desc": b["desc"], "x11": b["x11"],
                 "variants": {}}
        for variant in P2_VARIANTS:
            rom = p2_rom_name(b["label"], variant)
            rom_path = PROG / rom
            if not rom_path.exists():
                entry["variants"][variant] = None
                continue
            halt = freeze_halt(rom_path)
            if halt is None:
                print(f"[P2][FAIL] {b['label']} ({variant}): sin freeze")
                entry["variants"][variant] = {"_status": "SIN HALT"}
                continue
            safe_name = re.sub(r"[^A-Za-z0-9_-]", "_",
                               f"p2_{b['label']}_{variant}")
            data_rom = rom.replace(".hex", ".data.hex")
            data_rom_path = PROG / data_rom
            ram_arg = f"programs/{data_rom}" if data_rom_path.exists() else "programs/data.hex"
            cmd = [
                "vvp", str(SIM_VVP),
                f"+TEST_NAME={safe_name}",
                f"+HALT_PC={halt}",
                f"+MAX_CYCLES={b['max']}",
                f"+FILE_ROM=programs/{rom}",
                f"+FILE_RAM={ram_arg}",
            ]
            if b["x11"]:
                cmd.append(f"+EXPECT_X11={b['x11']}")
            print(f"[P2] {b['label']} ({variant})")
            proc = subprocess.run(cmd, cwd=ARQUI, capture_output=True, text=True)
            out = proc.stdout + proc.stderr
            row = parse_metrics(out)
            if row is None:
                status = "TIMEOUT/ERROR"
                tail = "\n".join(out.strip().splitlines()[-3:])
                print(f"       {tail}")
            elif "[FAIL]" in out:
                status = "FAIL"
            else:
                status = "OK"
            print(f"[{'OK  ' if status == 'OK' else 'FAIL'}] {b['label']} ({variant}): {status}")
            if row is not None:
                row["_status"] = status
                ipc = _ipc(row)
                if ipc is not None:
                    row["IPC"] = f"{ipc:.4f}"
                amat = _amat_row(row)
                if amat is not None:
                    row["AMAT"] = f"{amat:.2f}"
                cs = code_size_bytes(rom_path)
                if cs is not None:
                    row["Code_Size_Bytes"] = cs
                st = p2_stats.get((b["label"], variant))
                if st:
                    row.update(st)
            entry["variants"][variant] = row
        results.append(entry)
    return results


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


_OPT_LEVEL_META = {
    "O0": {"color": "#6c757d", "label": "O0", "desc": "Sin optimizar (baseline)"},
    "O1": {"color": "#3b5bdb", "label": "O1", "desc": "Unroll + Rename"},
    "O2": {"color": "#0ca678", "label": "O2", "desc": "DCE + Reorder"},
    "O3": {"color": "#e67700", "label": "O3", "desc": "Todas las optimizaciones"},
}

_OPT_TRANSF_META = [
    ("Opt_Unrolled",    "Unroll",  "#3b5bdb"),
    ("Opt_Renamed",     "Rename",  "#0ca678"),
    ("Opt_DCE_Removed", "DCE",     "#e67700"),
    ("Opt_Reordered",   "Reorder", "#862e9c"),
]


def _opt_badge(o):
    """Chip coloreado para un nivel de optimizacion."""
    m = _OPT_LEVEL_META.get(o, {})
    c = m.get("color", "#999")
    return (f'<span class="optbadge" style="background:{c}1a;color:{c};'
            f'border:1px solid {c}55">{o}</span>')


def _speed_badge_opt(sp, broke, o):
    """Badge de speedup igual al de P2 pero con el color del nivel."""
    if broke:
        return f'<span class="p2badge p2fail">&#10007; {o}</span>'
    if sp is None:
        return '<span class="p2badge p2na">&mdash;</span>'
    if sp >= 1.05:
        pct = int(round((sp - 1) * 100))
        return f'<span class="p2badge p2up">+{pct}% &#9650;</span>'
    if sp <= 0.96:
        pct = int(round((1 - sp) * 100))
        return f'<span class="p2badge p2down">-{pct}% &#9660;</span>'
    return f'<span class="p2badge p2flat">{sp:.2f}&times; &#9644;</span>'


def compiler_section(rows):
    """Compara cada benchmark en todos los niveles de optimizacion (O0..O3).
    El resultado (x11) valida cada corrida; un nivel que rompe el resultado
    se marca y no cuenta como aceleracion."""
    bases = {}
    for r in rows:
        if r.get("_base") and r.get("_opt"):
            bases.setdefault(r["_base"], {})[r["_opt"]] = r
    all_opts = sorted({opt for v in bases.values() for opt in v},
                      key=lambda o: int(o[1:]) if o[1:].isdigit() else 99)
    pairs = sorted((b, v) for b, v in bases.items() if "O0" in v)
    if not pairs:
        return ""

    non_base = [o for o in all_opts if o != "O0"]

    # ── Leyenda de niveles ────────────────────────────────────────────────────
    legend_chips = "".join(
        f'{_opt_badge(o)} <span class="clvldesc">{_OPT_LEVEL_META.get(o,{}).get("desc","")}</span>'
        for o in all_opts)

    # ── TABLA A: Rendimiento ──────────────────────────────────────────────────
    # cabecera fila 1: grupos por nivel
    hdr1_a = f'<th rowspan="2" class="cname">Benchmark</th>'
    for o in all_opts:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        span = 3  # Ciclos + IPC + CPI
        hdr1_a += (f'<th colspan="{span}" class="p2hgroup" '
                   f'style="background:{c}18;color:{c};border-bottom:2px solid {c}">'
                   f'{_opt_badge(o)}</th>')
    # columna speedup por nivel no-base
    for o in non_base:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        hdr1_a += (f'<th rowspan="2" class="p2hgroup" '
                   f'style="background:{c}18;color:{c};border-bottom:2px solid {c}">'
                   f'Speedup<br>{_opt_badge(o)}</th>')

    hdr2_a = "".join(
        "<th>Ciclos</th><th>IPC</th><th>CPI</th>" for _ in all_opts)

    perf = ""
    for base, v in pairs:
        o0 = v.get("O0", {})
        c0 = _fnum(o0.get("Ciclos"))
        # marca si algun nivel rompio
        bad_levels = [o for o in non_base
                      if v.get(o, {}).get("_status", "OK") != "OK"
                      and _fnum(v.get(o, {}).get("Ciclos")) is not None]
        name_cell = base
        if bad_levels:
            marks = " ".join(f'<span class="bad">&#10007;{o}</span>' for o in bad_levels)
            name_cell = f"{base} {marks}"

        cells_by_level = ""
        for o in all_opts:
            ox = v.get(o, {})
            cx = _fnum(ox.get("Ciclos"))
            # delta de ciclos vs O0 para niveles no-base
            if o == "O0" or c0 is None or cx is None:
                cyc_cell = f"<td>{_num(ox.get('Ciclos'))}</td>"
            else:
                diff = cx - c0
                sign = "+" if diff > 0 else ""
                cls = "p2green" if diff < 0 else ("p2red" if diff > 0 else "p2zero")
                cyc_cell = (f'<td class="{cls}">{_num(ox.get("Ciclos"))}'
                            f'<span class="p2delta"> ({sign}{int(diff)})</span></td>')
            cells_by_level += (
                cyc_cell
                + f"<td>{_num(ox.get('IPC'), 3)}</td>"
                + f"<td>{_num(ox.get('CPI'), 2)}</td>"
            )

        speed_cells = ""
        for o in non_base:
            ox = v.get(o, {})
            broke = ox.get("_status", "OK") != "OK" or _fnum(ox.get("Ciclos")) is None
            cx = _fnum(ox.get("Ciclos"))
            sp = (c0 / cx) if (c0 and cx and not broke) else None
            speed_cells += f"<td class='p2speedcell'>{_speed_badge_opt(sp, broke, o)}</td>"

        perf += (f"<tr><td class='cname'>{name_cell}</td>"
                 f"{cells_by_level}{speed_cells}</tr>\n")

    # ── TABLA B: Transformaciones ─────────────────────────────────────────────
    # cabecera fila 1: Instr / Cod (B) agrupados por nivel; luego bloque transf por nivel
    hdr1_b = '<th rowspan="2" class="cname">Benchmark</th>'
    for o in all_opts:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        hdr1_b += (f'<th colspan="2" class="p2hgroup" '
                   f'style="background:{c}18;color:{c};border-bottom:2px solid {c}">'
                   f'{_opt_badge(o)}</th>')
    for o in non_base:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        hdr1_b += (f'<th colspan="4" class="p2hgroup" '
                   f'style="background:{c}18;color:{c};border-bottom:2px solid {c}">'
                   f'Transformaciones {_opt_badge(o)}</th>')

    hdr2_b = "".join("<th>Instr</th><th>Cod&nbsp;(B)</th>" for _ in all_opts)
    # sub-cabeceras de transformaciones con chip de color
    for _ in non_base:
        for _, tlabel, tc in _OPT_TRANSF_META:
            hdr2_b += (f'<th class="p2tsub" style="background:{tc}18;color:{tc}">'
                       f'{tlabel}</th>')

    transf = ""
    for base, v in pairs:
        o0 = v.get("O0", {})
        cells_instr_code = ""
        for o in all_opts:
            ox = v.get(o, {})
            instr0 = _fnum(o0.get("Instr"))
            instrx = _fnum(ox.get("Instr"))
            if o == "O0" or instr0 is None or instrx is None:
                ic = f"<td>{_num(ox.get('Instr'))}</td>"
            else:
                diff = instrx - instr0
                sign = "+" if diff > 0 else ""
                cls = "p2green" if diff < 0 else ("p2red" if diff > 0 else "p2zero")
                ic = (f'<td class="{cls}">{_num(ox.get("Instr"))}'
                      f'<span class="p2delta"> ({sign}{int(diff)})</span></td>')
            cells_instr_code += ic + f"<td>{_num(ox.get('Code_Size_Bytes'))}</td>"

        cells_transf = ""
        for o in non_base:
            ox = v.get(o, {})
            for tkey, tlabel, tc in _OPT_TRANSF_META:
                val = _num(ox.get(tkey))
                nonzero = _fnum(ox.get(tkey)) not in (None, 0.0)
                style = f' style="background:{tc}18;font-weight:600;color:{tc}"' if nonzero else ""
                cells_transf += f"<td{style}>{val}</td>"

        transf += (f"<tr><td class='cname'>{base}</td>"
                   f"{cells_instr_code}{cells_transf}</tr>\n")

    levels_str = " &rarr; ".join(_opt_badge(o) for o in all_opts)
    return f"""
<section id="compiler">
<h2>Efecto del compilador</h2>
<div class="clvlrow">{legend_chips}</div>
<p class="nota">Cada corrida se valida con el resultado esperado en <code>x11</code>.
 Los deltas entre par&eacute;ntesis en <em>Ciclos</em> e <em>Instr</em> son la diferencia
 absoluta respecto a O0 (negativo = menos = mejor).
 <span class="p2badge p2fail" style="font-size:0.8em">&#10007; Ox</span>
 = la optimizaci&oacute;n rompi&oacute; el resultado (bug del compilador).</p>

<h3>Tabla A &mdash; Rendimiento por nivel</h3>
<p class="nota"><b>Speedup</b> = Ciclos O0 / Ciclos Ox. Verde &gt;5%, gris marginal, rojo regresiona.</p>
<div class="tablewrap"><table class="p2table"><thead>
 <tr>{hdr1_a}</tr>
 <tr>{hdr2_a}</tr>
</thead><tbody>{perf}</tbody></table></div>

<h3>Tabla B &mdash; Instrucciones, tama&ntilde;o de c&oacute;digo y transformaciones aplicadas</h3>
<p class="nota">Unroll/Rename/DCE/Reorder = n&uacute;mero de instrucciones afectadas por cada
 transformaci&oacute;n. Celdas coloreadas = la optimizaci&oacute;n actuo en ese benchmark.
 Vac&iacute;o (&mdash;) si no se corri&oacute; con <code>--compile</code>.</p>
<div class="tablewrap"><table class="p2table"><thead>
 <tr>{hdr1_b}</tr>
 <tr>{hdr2_b}</tr>
</thead><tbody>{transf}</tbody></table></div>
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


_P2_GROUP_META = {
    "unroll":  {"color": "#3b5bdb", "label": "Desenrollado de bucles",
                "flag": "--unroll",
                "desc": "El compilador replica el cuerpo del loop (factor auto hasta 8) para reducir "
                        "los saltos de control. Mejora visible en Instr/Ciclos cuando N es constante "
                        "y el cuerpo tiene m&aacute;s de una operaci&oacute;n."},
    "rename":  {"color": "#0ca678", "label": "Renombrado de registros",
                "flag": "--rename-registers",
                "desc": "Asigna pistas de registro f&iacute;sico distintas a cada versi&oacute;n de un temporal "
                        "(WAW/WAR). Rompe dependencias falsas en loops densos, permitiendo al backend "
                        "usar m&aacute;s registros en paralelo y reducir spills al stack."},
    "dce":     {"color": "#e67700", "label": "Eliminación de código muerto",
                "flag": "--dce",
                "desc": "Elimina cadenas de instrucciones cuyos resultados nunca alcanzan un "
                        "<code>return</code> ni una llamada con efecto (summon). Cuantas m&aacute;s "
                        "instrucciones muertas haya, mayor la reducci&oacute;n de Instr y Ciclos."},
    "reorder": {"color": "#862e9c", "label": "Reordenamiento de instrucciones",
                "flag": "--reorder",
                "desc": "Mueve instrucciones independientes justo despu&eacute;s de un load para "
                        "rellenar los ciclos de latencia de memoria. El scheduler actua dentro "
                        "de segmentos sin barreras (calls, branches); segmentos &ge;3 instrucciones."},
}


def _p2_speedup_badge(sp, broke):
    """Genera el badge de speedup con color semantico."""
    if broke:
        return '<span class="p2badge p2fail">&#10007; FAIL</span>'
    if sp is None:
        return '<span class="p2badge p2na">&mdash;</span>'
    if sp >= 1.05:
        pct = int(round((sp - 1) * 100))
        return f'<span class="p2badge p2up">+{pct}% &#9650;</span>'
    if sp <= 0.96:
        pct = int(round((1 - sp) * 100))
        return f'<span class="p2badge p2down">-{pct}% &#9660;</span>'
    return f'<span class="p2badge p2flat">{sp:.2f}&times; &#9644;</span>'


def _p2_delta(v0, vopt, higher_is_better=False):
    """Genera celda con delta coloreado (verde=mejora, rojo=regresion)."""
    f0, fo = _fnum(v0), _fnum(vopt)
    if f0 is None or fo is None:
        return f"<td>{_num(vopt)}</td>"
    diff = fo - f0
    if diff == 0:
        return f'<td class="p2zero">{_num(vopt)}</td>'
    improved = (diff < 0) if not higher_is_better else (diff > 0)
    cls = "p2green" if improved else "p2red"
    sign = "+" if diff > 0 else ""
    return f'<td class="{cls}">{_num(vopt)} <span class="p2delta">({sign}{int(diff)})</span></td>'


def p2_section(p2_results):
    """Seccion HTML con los 12 benchmarks de Defensa/P2, agrupados por
    optimizacion. Por cada grupo: descripcion, tabla comparativa O0 vs opt,
    y una fila de resumen con el speedup medio."""
    if not p2_results:
        return ""

    groups = {}
    for entry in p2_results:
        groups.setdefault(entry["group"], []).append(entry)

    sections_html = ""
    for group_key, entries in groups.items():
        meta = _P2_GROUP_META.get(group_key, {})
        color  = meta.get("color", "#555")
        glabel = meta.get("label", group_key)
        gflag  = meta.get("flag", "")
        gdesc  = meta.get("desc", "")

        body = ""
        speedups = []
        for e in entries:
            r0   = e["variants"].get("O0")  or {}
            ropt = e["variants"].get("opt") or {}

            c0   = _fnum(r0.get("Ciclos"))
            copt = _fnum(ropt.get("Ciclos"))
            broke = (ropt.get("_status", "OK") != "OK") or copt is None
            sp = (c0 / copt) if (c0 and copt and not broke) else None
            if sp is not None:
                speedups.append(sp)

            badge = _p2_speedup_badge(sp, broke)

            # columnas de transformaciones del compilador (solo opt)
            opt_transf = (
                f"<td>{_num(ropt.get('Opt_Unrolled'))}</td>"
                f"<td>{_num(ropt.get('Opt_DCE_Removed'))}</td>"
                f"<td>{_num(ropt.get('Opt_Reordered'))}</td>"
                f"<td>{_num(ropt.get('Opt_Renamed'))}</td>"
            )

            # transformaciones con resaltado si el valor es > 0
            def _transf_cell(val_str, key, ropt=ropt):
                v = _fnum(ropt.get(key))
                nonzero = v is not None and v > 0
                style = ' class="p2tactive"' if nonzero else ""
                return f"<td{style}>{val_str}</td>"

            body += (
                f"<tr>"
                # nombre + descripcion
                f"<td class='p2namecell'>"
                f"<span class='p2name'>{e['label']}</span>"
                f"<div class='p2desc'>{e['desc']}</div>"
                f"</td>"
                # resultado esperado
                f"<td class='p2x11'>0x{e['x11']}</td>"
                # speedup badge
                f"<td class='p2speedcell'>{badge}</td>"
                # ciclos simulador: O0 y opt con delta
                f"<td>{_num(r0.get('Ciclos'))}</td>"
                f"{_p2_delta(r0.get('Ciclos'), ropt.get('Ciclos'))}"
                # instrucciones: O0 y opt con delta
                f"<td>{_num(r0.get('Instr'))}</td>"
                f"{_p2_delta(r0.get('Instr'), ropt.get('Instr'))}"
                # tamaño de codigo en bytes: O0 y opt con delta
                f"<td>{_num(r0.get('Code_Size_Bytes'))}</td>"
                f"{_p2_delta(r0.get('Code_Size_Bytes'), ropt.get('Code_Size_Bytes'))}"
                # IPC: O0 y opt
                f"<td>{_num(r0.get('IPC'), 3)}</td>"
                f"<td>{_num(ropt.get('IPC'), 3)}</td>"
                # tiempo de compilacion (solo opt)
                f"<td class='p2ms'>{_num(ropt.get('Compile_ms'))} ms</td>"
                # transformaciones del compilador (resaltadas si actuan)
                f"{_transf_cell(_num(ropt.get('Opt_Unrolled')),    'Opt_Unrolled')}"
                f"{_transf_cell(_num(ropt.get('Opt_DCE_Removed')), 'Opt_DCE_Removed')}"
                f"{_transf_cell(_num(ropt.get('Opt_Reordered')),   'Opt_Reordered')}"
                f"{_transf_cell(_num(ropt.get('Opt_Renamed')),     'Opt_Renamed')}"
                f"</tr>\n"
            )

        # fila resumen del grupo
        n = len(entries)
        TOTAL_COLS = 15  # nombre+x11+speedup + 2*3 pares + IPC*2 + ms + 4 transf
        if speedups:
            avg_sp = sum(speedups) / len(speedups)
            ok_count = len(speedups)
            arrow = "&#9650;" if avg_sp >= 1.05 else ("&#9660;" if avg_sp <= 0.96 else "&#9644;")
            pct = (avg_sp - 1) * 100
            sign = "+" if pct >= 0 else ""
            summary = (
                f"<tr class='p2summary'>"
                f"<td colspan='2'><b>Media del grupo ({ok_count}/{n} OK)</b></td>"
                f"<td><b>{sign}{pct:.1f}% {arrow}</b></td>"
                f"<td colspan='{TOTAL_COLS - 3}'></td>"
                f"</tr>\n"
            )
        else:
            summary = ""

        sections_html += f"""
<div class="p2group" style="border-left:4px solid {color}">
 <div class="p2gtitle">
  <span class="p2gicon" style="background:{color}"></span>
  <span style="color:{color};font-weight:700;font-size:1.05em">{glabel}</span>
  &nbsp;<code style="background:{color}1a;color:{color};border:1px solid {color}55">{gflag}</code>
 </div>
 <p class="p2gdesc">{gdesc}</p>
 <div class="tablewrap">
 <table class="p2table"><thead>
  <tr>
   <th rowspan="2" class="p2hname">Programa / Descripci&oacute;n</th>
   <th rowspan="2">x11</th>
   <th rowspan="2">Speedup</th>
   <th colspan="2" class="p2hgroup">Ciclos (simulador)</th>
   <th colspan="2" class="p2hgroup">Instrucciones</th>
   <th colspan="2" class="p2hgroup">Tama&ntilde;o c&oacute;digo (B)</th>
   <th colspan="2" class="p2hgroup">IPC</th>
   <th rowspan="2" class="p2hgroup" style="background:#fff8e6">ms compile</th>
   <th colspan="4" class="p2hgroup" style="background:#f5edff">Transformaciones aplicadas (opt)</th>
  </tr>
  <tr>
   <th>O0</th><th>opt</th>
   <th>O0</th><th>opt</th>
   <th>O0</th><th>opt</th>
   <th>O0</th><th>opt</th>
   <th class="p2tsub">Unroll</th><th class="p2tsub">DCE</th>
   <th class="p2tsub">Reord</th><th class="p2tsub">Rename</th>
  </tr>
 </thead><tbody>{body}{summary}</tbody></table>
 </div>
</div>
"""

    return f"""
<section id="p2">
<h2>Defensa P2 &mdash; optimizaciones individuales del compilador</h2>
<p class="nota">12 programas, uno por transformaci&oacute;n objetivo, comparados con su baseline
 <b>O0</b> (sin optimizar). <b>Speedup</b> = Ciclos O0 / Ciclos opt &mdash; verde si mejora
 &gt;5%, gris si es marginal, rojo si regresiona.
 Los deltas entre par&eacute;ntesis en <em>Ciclos</em> e <em>Instr</em> indican la diferencia
 absoluta respecto a O0 (negativo = menos = mejor).
 <span class="p2badge p2fail" style="font-size:0.8em">&#10007; FAIL</span>
 = el resultado en x11 no coincide con el esperado (bug en el compilador).</p>
{sections_html}
</section>
"""


def render_html(rows, path, no_cache, p2_results=None):
    # Las tablas 5.1/5.2/5.3 usan el baseline sin optimizar (O0); las variantes
    # O1+ viven en la seccion del compilador y en el CSV completo.
    base_rows = [r for r in rows if r.get("_opt") in (None, "O0")]
    p2_html = p2_section(p2_results) if p2_results else ""

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>Benchmarks - rendimiento de cache</title>
<style>
 body {{ font-family: system-ui, sans-serif; margin: 24px; color: #222; max-width: 1100px; }}
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
 /* ── Compiler levels ── */
 .optbadge {{ display:inline-block; padding:1px 7px; border-radius:10px;
              font-size:0.8em; font-weight:700; white-space:nowrap; }}
 .clvlrow  {{ display:flex; flex-wrap:wrap; gap:16px; margin:8px 0 12px;
              align-items:center; }}
 .clvldesc {{ font-size:0.82em; color:#555; }}
 .cname    {{ text-align:left !important; font-weight:600; white-space:nowrap; }}
 /* ── Defensa P2 ── */
 #p2 {{ border-top: 2px solid #d0d7de; margin-top: 32px; padding-top: 8px; }}
 .p2group {{ margin: 20px 0 28px; padding: 14px 16px 10px; border-radius: 6px;
             background: #fafbfc; }}
 .p2gtitle {{ display:flex; align-items:center; gap:10px; margin-bottom:4px; }}
 .p2gicon  {{ width:10px; height:10px; border-radius:50%; flex-shrink:0; }}
 .p2gdesc  {{ font-size:0.83em; color:#555; margin:4px 0 10px; line-height:1.5; }}
 .p2table  {{ font-size:0.84em; width:100%; }}
 .p2hname  {{ text-align:left !important; min-width:200px; max-width:280px; }}
 .p2hgroup {{ text-align:center; background:#e8edf4; }}
 .p2tsub   {{ background:#f0eaff; font-size:0.82em; }}
 .p2namecell {{ text-align:left !important; }}
 .p2name   {{ font-weight:600; font-size:0.88em; display:block; margin-bottom:2px; }}
 .p2desc   {{ font-size:0.76em; color:#666; line-height:1.4; max-width:280px; }}
 .p2x11    {{ font-family:monospace; font-size:0.82em; color:#444; }}
 .p2speedcell {{ text-align:center !important; padding:4px 6px; }}
 .p2badge  {{ display:inline-block; padding:2px 8px; border-radius:12px;
              font-size:0.82em; font-weight:600; white-space:nowrap; }}
 .p2up     {{ background:#d4edda; color:#155724; border:1px solid #c3e6cb; }}
 .p2down   {{ background:#f8d7da; color:#721c24; border:1px solid #f5c6cb; }}
 .p2flat   {{ background:#e2e3e5; color:#383d41; border:1px solid #d6d8db; }}
 .p2fail   {{ background:#f8d7da; color:#721c24; border:1px solid #f5c6cb; }}
 .p2na     {{ background:#e2e3e5; color:#6c757d; border:1px solid #d6d8db; }}
 .p2delta  {{ font-size:0.78em; color:#888; }}
 .p2green  {{ background:#f0fff4; }}
 .p2red    {{ background:#fff5f5; }}
 .p2zero   {{ color:#999; }}
 .p2summary td {{ background:#f0f0f0; font-size:0.82em; border-top:2px solid #ccc; }}
 .p2tactive  {{ font-weight:600; background:#f0eaff; }}
 .p2ms       {{ font-size:0.82em; color:#666; text-align:right; white-space:nowrap; }}
</style></head><body>
<h1>Benchmarks del procesador &mdash; rendimiento de la jerarqu&iacute;a de cach&eacute;</h1>
{cache_effect_section(base_rows, no_cache)}
{processor_section(base_rows)}
{cache_section(base_rows)}
{memory_section(base_rows)}
{causal_chain(base_rows)}
{compiler_section(rows)}
{p2_html}
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
                    help="recompilar los ROM de benchmarks principales (O0..O3)")
    ap.add_argument("--compile-p2", action="store_true",
                    help="compilar los 12 programas de Defensa/P2 (O0 + flag especifico)")
    ap.add_argument("--no-p2", action="store_true",
                    help="omitir la seccion P2 del HTML aunque existan los .hex")
    ap.add_argument("--no-nocache", action="store_true",
                    help="omitir la pasada SIN cache (top_no_cash); itera mas rapido")
    args = ap.parse_args()

    if args.list:
        for b in BENCHMARKS:
            opts = "/".join(b["opts"]) if "src" in b else "pre-construido"
            print(f"  {b['name']:20s} {opts}")
        print("\nDefensa P2:")
        for b in P2_BENCHMARKS:
            print(f"  {b['label']:30s} [{b['group']}]  {b['desc']}")
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
        stats = load_compile_stats()

    if args.compile_p2:
        ok_p2, p2_stats = compile_p2_programs()
        if not ok_p2:
            print("[WARN] algunos programas P2 no compilaron; se incluiran los que si.")
    else:
        p2_stats = load_p2_compile_stats()

    if not build_sim():
        return 1

    # ── benchmarks principales ────────────────────────────────────────────────
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

    # ── benchmarks P2 ────────────────────────────────────────────────────────
    p2_results = None
    if not args.no_p2:
        any_p2_hex = any(
            (PROG / p2_rom_name(b["label"], v)).exists()
            for b in P2_BENCHMARKS for v in P2_VARIANTS
        )
        if any_p2_hex:
            print("\n-- Defensa P2 ------------------------------------------")
            p2_results = run_p2_benchmarks(p2_stats)
        else:
            print("[P2] No hay .hex de P2; usa --compile-p2 para generarlos.")

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
    render_html(rows, html_path, no_cache, p2_results)

    if not args.no_open:
        webbrowser.open(html_path.as_uri())

    print(f"\n{len(rows) - failures}/{len(rows)} benchmarks principales OK")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
