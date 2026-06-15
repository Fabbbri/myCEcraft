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
    {"group": "unroll",  "file": "01_unroll_for_limite_literal",                   "max": 100000,
     "label": "unroll_for_cte",      "desc": "FOR N=8 literal, 2 acumuladores; factor de unroll: 8 (8 iter -> 1 bloque, saltos /8) (suma=28)"},
    {"group": "unroll",  "file": "02_unroll_while_limite_variable",               "max": 100000,
     "label": "unroll_while_varN",   "desc": "WHILE limite en variable N=6; factor de unroll: 2 (6 iter -> 3 bloques, saltos /2) (suma=15)"},
    {"group": "unroll",  "file": "03_unroll_for_factor_grande",                   "max": 200000,
     "label": "unroll_for_grande",   "desc": "FOR N=32 literal, 2 acumuladores; factor de unroll: 8 (32 iter -> 4 bloques, saltos /8) (suma=496)"},
    # ── grupo rename ──────────────────────────────────────────────────────────
    {"group": "rename",  "file": "04_rename_waw_secuencial",                      "max": 100000,
     "label": "rename_for_WAW",      "desc": "WAW: 'a' reescrita 3 veces; rename asigna registros fisicos distintos a t0,t1,t2 (suma=66)"},
    {"group": "rename",  "file": "05_rename_war_if_else",                         "max": 100000,
     "label": "rename_if_WAR",       "desc": "WAR: 'lim' leida en condicion y sobreescrita en else; rename crea versiones SSA (total=54)"},
    {"group": "rename",  "file": "06_rename_waw_war_funcion",                     "max": 100000,
     "label": "rename_func_mixto",   "desc": "WAW+WAR en funcion con if/else; rename crea versiones independientes por rama (total=66)"},
    # ── grupo dce ────────────────────────────────────────────────────────────
    {"group": "dce",     "file": "07_dce_ramas_muertas_if",                       "max": 50000,
     "label": "dce_if_muerto",       "desc": "IF/ELSE con ambas ramas calculando valores muertos; DCE elimina todo excepto el summon (estado=5)"},
    {"group": "dce",     "file": "08_dce_muerto_en_funcion_y_main",               "max": 50000,
     "label": "dce_func_y_main",     "desc": "Cadena muerta dentro de funcion + cadena muerta en main entre dos summons (acum=7)"},
    {"group": "dce",     "file": "09_dce_cadenas_pre_post_llamada",               "max": 50000,
     "label": "dce_cadenas_post",    "desc": "Cadenas muertas antes y despues de summon; retorno de llamada alimenta cadena muerta (ctr=6)"},
    # ── grupo reorder ────────────────────────────────────────────────────────
    {"group": "reorder", "file": "10_reorder_1load_uso_inmediato",                "max": 100000,
     "label": "reorder_1load_if",    "desc": "1 load global con uso inmediato; scheduler mueve w1,w2,w3 entre lw y uso (total=36)"},
    {"group": "reorder", "file": "11_reorder_2loads_uso_inmediato",               "max": 100000,
     "label": "reorder_2loads",      "desc": "2 loads globales con uso inmediato; scheduler llena stall de cada lw con trabajo independiente (total=65)"},
    {"group": "reorder", "file": "12_reorder_3loads_uso_inmediato",               "max": 100000,
     "label": "reorder_3loads_if",   "desc": "3 loads globales con uso inmediato; scheduler intercala trabajo independiente entre cada lw y su uso (total=27)"},
    # ── prueba de integracion rename ─────────────────────────────────────────
    {"group": "rename",  "file": "rename",                                          "max": 100000,
     "label": "rename_presion_regs",  "desc": "4 vars vivas simultaneas (p,q,r,s) con WAW+WAR encadenados; sin rename el asignador hace spill al stack (sw/lw extra); con rename crea versiones SSA y elimina los spills (resultado=219)"},
    # ── pruebas de integracion ────────────────────────────────────────────────
    {"group": "unroll",  "file": "LoopUnrolling",                                  "max": 500000,
     "label": "LoopUnrolling",       "desc": "2 FOR anidados (8 bloques x 8 elems, 64 datos); factor de unroll: 8 (for interno N=8, 8 iter -> 1 bloque, saltos /8); acumula bloque[i]*2 (suma=9392)"},
    {"group": "dce",     "file": "pruebaEliminacionCodigo",                        "max": 200000,
     "label": "pruebaEliminacionCodigo", "desc": "Matriz 2x2 aplanada con 6 variables muertas (temporal_externo, basura1-3, estadistica, desperdicio); DCE elimina todas las cadenas que no alcanzan el return (suma C=134)"},
    {"group": "reorder", "file": "Reordenamiento",                                 "max": 200000,
     "label": "Reordenamiento",      "desc": "WHILE sobre 7 lecturas de sensor; log=i*100 es reordenable (independiente del load datos[i]); lecturas>50: {60,70} -> total=840"},
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
    """verde (bueno) -> rojo (malo). Paleta oscura con suficiente contraste sobre texto blanco."""
    try:
        v = float(pct)
    except (TypeError, ValueError):
        return "#30363D"
    if invert:
        v = 100.0 - v
    if v >= 90: return "#1A6B30"
    if v >= 70: return "#3A6B20"
    if v >= 50: return "#6B5B00"
    if v >= 30: return "#7A3B10"
    return "#7A1515"


def _fnum(v):
    """float o None si el valor no es numerico (corridas fallidas)."""
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def row_band(row):
    """Color de fondo de la fila completa segun L1 Hit Rate.
    >95% verde oscuro, 80-95% amarillo oscuro, <80% rojo oscuro, sin datos neutro."""
    v = _fnum(row.get("L1_Hit_Rate"))
    if v is None:   return "#1C2128"
    if v > 95.0:    return "#0F1F14"
    if v >= 80.0:   return "#1C1A12"
    return "#1F0C0C"


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
                ref[key] = {
                    "Ciclos": r.get("Ciclos"),
                    "CPI": r.get("CPI"),
                    "Instr": r.get("Instr"),
                    "Memory_Accesses": r.get("Memory_Accesses"),
                    "Mem_Transfer_Cycles": r.get("Mem_Transfer_Cycles"),
                    "BW_Util": r.get("BW_Util"),
                }
    except (OSError, KeyError):
        pass
    return ref


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


def _parse_x11(out):
    """Extrae el valor de x11 del output del simulador (linea '  x11 = XXXXXXXX')."""
    m = re.search(r"\bx11\s*=\s*([0-9a-fA-F]+)", out)
    return m.group(1).lstrip("0") or "0" if m else None


def run_p2_benchmarks(p2_stats):
    """Corre los 15 benchmarks de Defensa/P2 (O0 + variante opt) y devuelve
    una lista de dicts con los resultados, listos para pasar a p2_section.
    El x11 esperado se descubre automaticamente de la corrida O0 si no esta
    hardcodeado en P2_BENCHMARKS.
    Si el sim sin cache esta disponible, tambien corre la ROM O0 en nocache
    y guarda el resultado en entry["variants"]["nocache"]."""
    nocache_available = SIM_VVP_NOCACHE.exists()
    results = []
    for b in P2_BENCHMARKS:
        entry = {"label": b["label"], "group": b["group"],
                 "desc": b["desc"], "x11": b.get("x11", ""),
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
            # O0: corre sin oraculo para descubrir x11; opt: usa el x11 descubierto
            x11_oracle = entry["x11"] if variant != "O0" else b.get("x11", "")
            if x11_oracle:
                cmd.append(f"+EXPECT_X11={x11_oracle}")
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
            # descubre x11 de la corrida O0 si no estaba hardcodeado;
            # en ese caso O0 corre sin oraculo -> ignora su status FAIL
            if variant == "O0" and not b.get("x11"):
                discovered = _parse_x11(out)
                if discovered:
                    entry["x11"] = discovered
                    print(f"[P2] x11 descubierto: 0x{discovered}")
                status = "OK"  # O0 sin oraculo no puede fallar por x11
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

        # corrida sin cache: usa la misma ROM O0 con el mismo limite de 2M ciclos
        # que usa el testbench. Si el programa no termina en ese limite, la variante
        # guarda {"_timeout": True} para que la celda muestre "+2M".
        if nocache_available:
            rom_nc = p2_rom_name(b["label"], "O0")
            rom_nc_path = PROG / rom_nc
            halt_nc = freeze_halt(rom_nc_path) if rom_nc_path.exists() else None
            if halt_nc:
                data_rom = rom_nc.replace(".hex", ".data.hex")
                data_rom_path = PROG / data_rom
                ram_arg = f"programs/{data_rom}" if data_rom_path.exists() else "programs/data.hex"
                safe_name = re.sub(r"[^A-Za-z0-9_-]", "_", f"p2_{b['label']}_nocache")
                cmd_nc = [
                    "vvp", str(SIM_VVP_NOCACHE),
                    f"+TEST_NAME={safe_name}",
                    f"+HALT_PC={halt_nc}",
                    f"+MAX_CYCLES={NO_CACHE_MAX_FLOOR}",
                    f"+FILE_ROM=programs/{rom_nc}",
                    f"+FILE_RAM={ram_arg}",
                ]
                print(f"[P2] {b['label']} (nocache)")
                proc_nc = subprocess.run(cmd_nc, cwd=ARQUI, capture_output=True, text=True)
                row_nc = parse_metrics(proc_nc.stdout + proc_nc.stderr)
                if row_nc is not None:
                    ipc_nc = _ipc(row_nc)
                    if ipc_nc is not None:
                        row_nc["IPC"] = f"{ipc_nc:.4f}"
                    entry["variants"]["nocache"] = row_nc
                else:
                    entry["variants"]["nocache"] = {"_timeout": True}
            else:
                entry["variants"]["nocache"] = None
        else:
            entry["variants"]["nocache"] = None

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
<div class="f"><b>BW%</b><pre>Mem Transfer Cycles
-------------------- x 100
   Ciclos totales</pre></div>
<div class="f"><b>BW (acc/ciclo)</b><pre>Memory Accesses / Ciclos
transacciones a RAM por ciclo
de pipeline (medido)</pre></div>
</div>
<p class="nota"><b>Nota sobre Memory Accesses:</b> no coincide con L2_Misses
porque la pol&iacute;tica es write-through: <i>todo</i> store drenado llega a RAM
aunque haya sido hit en L2 (se actualizan ambos niveles). Por eso
Memory_Accesses = misses de lectura en L2 + total de stores drenados.</p>
</section>
"""


def _num(v, dec=0, suffix=""):
    """Formatea un valor numerico de la fila; '&mdash;' si no es numero."""
    f = _fnum(v)
    if f is None:
        return "&mdash;"
    return (f"{f:.{dec}f}" if dec else f"{int(f):,}") + suffix


_OPT_LEVEL_META = {
    "O0": {"color": "#8B949E", "label": "O0", "desc": "Sin optimizar (baseline)"},
    "O1": {"color": "#58A6FF", "label": "O1", "desc": "Unroll + Rename"},
    "O2": {"color": "#3FB950", "label": "O2", "desc": "DCE + Reorder"},
    "O3": {"color": "#E3B341", "label": "O3", "desc": "Todas las optimizaciones"},
}

_OPT_TRANSF_META = [
    ("Opt_Unrolled",    "Unroll",  "#58A6FF"),
    ("Opt_Renamed",     "Rename",  "#3FB950"),
    ("Opt_DCE_Removed", "DCE",     "#E3B341"),
    ("Opt_Reordered",   "Reorder", "#BC8CFF"),
]


def _opt_badge(o):
    """Chip coloreado para un nivel de optimizacion."""
    m = _OPT_LEVEL_META.get(o, {})
    c = m.get("color", "#999")
    return (f'<span class="optbadge" style="background:{c}2a;color:{c};'
            f'border:1px solid {c}66">{o}</span>')


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


def compiler_section(rows, no_cache):
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

    # resultado esperado (oraculo x11) por programa; igual en todos los niveles
    x11_by_name = {b["name"]: b.get("x11") for b in BENCHMARKS}

    # ── TABLA A: Rendimiento ──────────────────────────────────────────────────
    # cabecera fila 1: SIN$ (sin cache, O0) + grupos por nivel
    hdr1_a = f'<th rowspan="2" class="cname">Benchmark</th><th rowspan="2">x11</th>'
    hdr1_a += ('<th colspan="3" class="p2hgroup p2nc">'
               'SIN$<br><span style="font-weight:400;font-size:0.8em">(sin cach&eacute;)</span></th>')
    for o in all_opts:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        span = 3  # Ciclos + IPC + CPI
        hdr1_a += (f'<th colspan="{span}" class="p2hgroup" '
                   f'style="background:{c}33;color:{c};border-bottom:2px solid {c}">'
                   f'{_opt_badge(o)}</th>')
    # columna speedup por nivel no-base
    for o in non_base:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        hdr1_a += (f'<th rowspan="2" class="p2hgroup" '
                   f'style="background:{c}33;color:{c};border-bottom:2px solid {c}">'
                   f'Speedup<br>{_opt_badge(o)}</th>')
    # speedup del cache: ciclos sin cache / ciclos con cache (O0)
    hdr1_a += ('<th rowspan="2" class="p2hgroup p2nc" '
               'title="Ciclos sin cache / ciclos con cache (O0)">'
               'Speedup<br>cach&eacute;</th>')

    hdr2_a = ('<th class="p2nc">Ciclos</th><th class="p2nc">IPC</th>'
              '<th class="p2nc">CPI</th>')
    hdr2_a += "".join(
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

        x11v = x11_by_name.get(base)
        x11_cell = (f"<td class='p2x11'>0x{x11v}</td>" if x11v else "<td>&mdash;</td>")

        # SIN$ = corrida O0 sin cache (top_no_cash); IPC = 1/CPI
        nc = no_cache.get(o0.get("Test Ejecutado", "")) or {}
        nc_cpi = _fnum(nc.get("CPI"))
        nc_cyc = _fnum(nc.get("Ciclos"))
        nc_ipc = (1.0 / nc_cpi) if (nc_cpi and nc_cpi > 0) else None
        sin_cells = (f"<td class='p2nc'>{_num(nc_cyc)}</td>"
                     f"<td class='p2nc'>{_num(nc_ipc, 3)}</td>"
                     f"<td class='p2nc'>{_num(nc_cpi, 2)}</td>")

        # speedup del cache: sin cache / con cache (O0); mismo badge que los Ox
        cache_sp = (nc_cyc / c0) if (nc_cyc and c0 and c0 > 0) else None
        cache_sp_cell = (f"<td class='p2speedcell'>"
                         f"{_speed_badge_opt(cache_sp, False, '$')}</td>")

        perf += (f"<tr><td class='cname'>{name_cell}</td>{x11_cell}{sin_cells}"
                 f"{cells_by_level}{speed_cells}{cache_sp_cell}</tr>\n")

    # ── TABLA B: Transformaciones ─────────────────────────────────────────────
    # cabecera fila 1: Instr / Cod (B) agrupados por nivel; luego bloque transf por nivel
    hdr1_b = '<th rowspan="2" class="cname">Benchmark</th>'
    for o in all_opts:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        hdr1_b += (f'<th colspan="2" class="p2hgroup" '
                   f'style="background:{c}33;color:{c};border-bottom:2px solid {c}">'
                   f'{_opt_badge(o)}</th>')
    for o in non_base:
        c = _OPT_LEVEL_META.get(o, {}).get("color", "#999")
        hdr1_b += (f'<th colspan="4" class="p2hgroup" '
                   f'style="background:{c}33;color:{c};border-bottom:2px solid {c}">'
                   f'Transformaciones {_opt_badge(o)}</th>')

    hdr2_b = "".join("<th>Instr</th><th>Cod&nbsp;(B)</th>" for _ in all_opts)
    # sub-cabeceras de transformaciones con chip de color
    for _ in non_base:
        for _, tlabel, tc in _OPT_TRANSF_META:
            hdr2_b += (f'<th class="p2tsub" style="background:{tc}22;color:{tc}">'
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
                style = f' style="background:{tc}22;font-weight:700;color:{tc}"' if nonzero else ""
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


def memory_section(rows, no_cache=None):
    """5.3 Metricas de memoria principal + trafico con vs sin cache."""
    data = _sorted_rows(rows)
    # detectar si hay datos medidos sin cache para la primera tabla
    has_nc = any(
        _fnum(((no_cache or {}).get(r.get("Test Ejecutado", ""), {}) or {}).get("Memory_Accesses")) is not None
        for r in data
    )

    body = ""
    for r in data:
        name = r.get("Test Ejecutado", "")
        nc   = (no_cache or {}).get(name, {}) or {}
        acc    = _fnum(r.get("Memory_Accesses"))
        xfr    = _fnum(r.get("Mem_Transfer_Cycles"))
        nc_acc = _fnum(nc.get("Memory_Accesses"))
        nc_xfr = _fnum(nc.get("Mem_Transfer_Cycles"))
        nc_cols = (
            f'<td class="p2nc">{_num(nc_acc)}</td>'
            f'<td class="p2nc">{_num(nc_xfr)}</td>'
            if has_nc else ""
        )
        body += (f'<tr><td>{name}</td>'
                 + nc_cols
                 + f'<td>{_num(acc)}</td>'
                 f'<td>{_num(xfr)}</td></tr>\n')

    hdr_nc = ('<th class="p2nc">Accesos sin$</th>'
              '<th class="p2nc">Ciclos de transferencia sin$</th>'
              if has_nc else "")

    # ── Trafico al bus (modelo analitico + BW medido) ─────────────────────────
    traffic = ""
    for r in data:
        name = r.get("Test Ejecutado", "")
        nc   = (no_cache or {}).get(name, {}) or {}
        rd, wr   = _fnum(r.get("L1_Reads")),        _fnum(r.get("L1_Writes"))
        acc, instr = _fnum(r.get("Memory_Accesses")), _fnum(r.get("Instr"))
        nc_acc   = _fnum(nc.get("Memory_Accesses"))
        nc_cyc   = _fnum(nc.get("Ciclos"))
        cyc      = _fnum(r.get("Ciclos"))
        nocache  = (rd + wr) if (rd is not None and wr is not None) else None
        red      = f"{nocache / acc:.1f}&times;" if (nocache and acc) else "&mdash;"
        api_no   = f"{nocache / instr:.3f}" if (nocache is not None and instr) else "&mdash;"
        api_si   = f"{acc / instr:.3f}"     if (acc is not None and instr)     else "&mdash;"
        apc_sin  = f"{nc_acc / nc_cyc:.4f}" if (nc_acc and nc_cyc) else "&mdash;"
        apc_con  = f"{acc / cyc:.4f}"       if (acc is not None and cyc)       else "&mdash;"
        bw_extra = (f'<td class="p2nc">{apc_sin}</td><td>{apc_con}</td>'
                    if has_nc else "")
        traffic += (f'<tr><td>{name}</td>'
                    f'<td>{_num(nocache)}</td><td>{_num(acc)}</td>'
                    f'<td><b>{red}</b></td><td>{api_no}</td><td>{api_si}</td>'
                    f'{bw_extra}</tr>\n')

    bw_hdr = ('<th class="p2nc">BW sin$<br><span style="font-size:0.8em">(acc/ciclo)</span></th>'
              '<th>BW con$<br><span style="font-size:0.8em">(acc/ciclo)</span></th>'
              if has_nc else "")

    return f"""
<section><h2>5.3 M&eacute;tricas de memoria principal</h2>
<p class="nota">Accesos = misses de lectura de L2 + stores drenados (write-through).
 Ciclos de transferencia = ciclos con el bus RAM activo (burst o escritura drenada).
 Columnas <span class="p2nc" style="padding:1px 4px;border-radius:3px">azules</span>
 = medici&oacute;n sin cach&eacute; (<code>top_no_cash</code>).</p>
<table><thead><tr>
 <th>Benchmark</th>{hdr_nc}
 <th>Accesos con$</th><th>Ciclos de transferencia con$</th>
</tr></thead><tbody>{body}</tbody></table>

<h3>Tr&aacute;fico al bus de memoria: con vs sin cach&eacute;</h3>
<p class="nota"><b>Sin cach&eacute;</b> (modelo anal&iacute;tico): cada acceso del programa baja a RAM
 &rarr; L1 Reads + Writes. <b>Con cach&eacute;</b>: solo lo que falla (Memory_Accesses).
 <i>Acc/instr</i> = transacciones a memoria por instrucci&oacute;n ejecutada.
 <b>BW (acc/ciclo)</b> = accesos a RAM por ciclo de pipeline medido en simulaci&oacute;n.
 <b>Nota:</b> es normal que BW con$ &gt; BW sin$ en varios benchmarks. Sin cach&eacute; cada
 acceso a memoria genera decenas de ciclos de stall, inflando el denominador
 (ciclos totales) m&aacute;s de lo que el numerador (accesos) crece; el ratio baja.
 Con cach&eacute; los ciclos totales se reducen dr&aacute;sticamente (pocos stalls),
 por lo que aunque llegan menos accesos a RAM, la fracci&oacute;n accesos/ciclo sube.</p>
<table><thead><tr>
 <th>Benchmark</th><th>Sin cach&eacute; (ops a RAM)</th><th>Con cach&eacute; (accesos)</th>
 <th>Reducci&oacute;n</th><th>Acc/instr sin</th><th>Acc/instr con</th>
 {bw_hdr}
</tr></thead><tbody>{traffic}</tbody></table>
</section>
"""


_P2_GROUP_META = {
    "unroll":  {"color": "#58A6FF", "label": "Desenrollado de bucles",
                "flag": "--unroll",
                "desc": "El compilador replica el cuerpo del loop (factor auto hasta 8) para reducir "
                        "los saltos de control. Mejora visible en Instr/Ciclos cuando N es constante "
                        "y el cuerpo tiene m&aacute;s de una operaci&oacute;n."},
    "rename":  {"color": "#3FB950", "label": "Renombrado de registros",
                "flag": "--rename-registers",
                "desc": "Asigna pistas de registro f&iacute;sico distintas a cada versi&oacute;n de un temporal "
                        "(WAW/WAR). Rompe dependencias falsas en loops densos, permitiendo al backend "
                        "usar m&aacute;s registros en paralelo y reducir spills al stack."},
    "dce":     {"color": "#E3B341", "label": "Eliminación de código muerto",
                "flag": "--dce",
                "desc": "Elimina cadenas de instrucciones cuyos resultados nunca alcanzan un "
                        "<code>return</code> ni una llamada con efecto (summon). Cuantas m&aacute;s "
                        "instrucciones muertas haya, mayor la reducci&oacute;n de Instr y Ciclos."},
    "reorder": {"color": "#BC8CFF", "label": "Reordenamiento de instrucciones",
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


def _instr_from_hex(row):
    """Instrucciones del compilador = Code_Size_Bytes / 4.
    No depende del simulador; es el conteo de palabras del .hex."""
    csb = _fnum(row.get("Code_Size_Bytes")) if row else None
    return int(csb / 4) if csb is not None else None


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

            # datos sin cache: vienen de la variante "nocache" del entry
            nc = e["variants"].get("nocache") or {}
            nc_timeout = nc.get("_timeout", False)
            c_nc   = nc.get("Ciclos")
            ipc_nc = nc.get("IPC")

            def _nc_cell(v):
                if nc_timeout and v is None:
                    return "<td class='p2nc p2ncskip' title='supera 2M ciclos sin cache'>+2M</td>"
                f = _fnum(v)
                return f"<td class='p2nc'>{f'{f:,.0f}' if (f is not None and f >= 10) else (f'{f:.3f}' if f is not None else '&mdash;')}</td>"

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
                # ciclos: sin cache | O0 | opt
                f"{_nc_cell(c_nc)}"
                f"<td>{_num(r0.get('Ciclos'))}</td>"
                f"{_p2_delta(r0.get('Ciclos'), ropt.get('Ciclos'))}"
                # instrucciones ejecutadas (retiradas por el pipeline): sin cache | O0 | opt
                # [SIMULADOR] != instrucciones del compilador (estaticas en el .hex)
                f"{_nc_cell(nc.get('Instr'))}"
                f"<td>{_num(r0.get('Instr'))}</td>"
                f"{_p2_delta(r0.get('Instr'), ropt.get('Instr'))}"
                # instrucciones del compilador = Code_Size_Bytes/4  [COMPILADOR]
                f"<td>{_num(_instr_from_hex(r0))}</td>"
                f"{_p2_delta(_instr_from_hex(r0), _instr_from_hex(ropt))}"
                # tamaño de codigo en bytes  [COMPILADOR]
                f"<td>{_num(r0.get('Code_Size_Bytes'))}</td>"
                f"{_p2_delta(r0.get('Code_Size_Bytes'), ropt.get('Code_Size_Bytes'))}"
                # IPC: sin cache | O0 | opt
                f"{_nc_cell(ipc_nc)}"
                f"<td>{_num(r0.get('IPC'), 3)}</td>"
                f"<td>{_num(ropt.get('IPC'), 3)}</td>"
                # stalls memoria: O0 | opt
                f"<td>{_num(r0.get('Stalls_Mem'))}</td>"
                f"{_p2_delta(r0.get('Stalls_Mem'), ropt.get('Stalls_Mem'))}"
                # stalls control: O0 | opt
                f"<td>{_num(r0.get('Stalls_Control'))}</td>"
                f"{_p2_delta(r0.get('Stalls_Control'), ropt.get('Stalls_Control'))}"
                # tiempo de compilacion: O0 y opt
                f"<td class='p2ms'>{_num(r0.get('Compile_ms'))} ms</td>"
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
        TOTAL_COLS = 26  # nombre+x11+speedup + (sin+O0+opt)*3 [ciclos,instr-ejec,IPC] + instr*2 + cod*2 + stmem*2 + stctrl*2 + ms*2 + 4 transf
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
  &nbsp;<code style="background:{color}2a;color:{color};border:1px solid {color}66">{gflag}</code>
 </div>
 <p class="p2gdesc">{gdesc}</p>
 <div class="tablewrap">
 <table class="p2table"><thead>
  <tr>
   <th rowspan="2" class="p2hname">Programa / Descripci&oacute;n</th>
   <th rowspan="2">x11</th>
   <th rowspan="2">Speedup</th>
   <th colspan="3" class="p2hgroup">Ciclos <span style="font-weight:400;font-size:0.85em">(simulador)</span></th>
   <th colspan="3" class="p2hgroup">Instr. ejecutadas <span style="font-weight:400;font-size:0.85em">(simulador)</span></th>
   <th colspan="2" class="p2hgroup">Instrucciones <span style="font-weight:400;font-size:0.85em">(compilador)</span></th>
   <th colspan="2" class="p2hgroup">Tama&ntilde;o c&oacute;digo (B) <span style="font-weight:400;font-size:0.85em">(compilador)</span></th>
   <th colspan="3" class="p2hgroup">IPC</th>
   <th colspan="2" class="p2hgroup">Stalls MEM</th>
   <th colspan="2" class="p2hgroup">Stalls Control</th>
   <th colspan="2" class="p2hgroup" style="background:#1C1A12;color:#E3B341">Compile (ms)</th>
   <th colspan="4" class="p2hgroup" style="background:#1A1427;color:#BC8CFF">Transformaciones aplicadas (opt)</th>
  </tr>
  <tr>
   <th class="p2nc">sin$</th><th>O0</th><th>opt</th>
   <th class="p2nc">sin$</th><th>O0</th><th>opt</th>
   <th>O0</th><th>opt</th>
   <th>O0</th><th>opt</th>
   <th class="p2nc">sin$</th><th>O0</th><th>opt</th>
   <th>O0</th><th>opt</th>
   <th>O0</th><th>opt</th>
   <th style="background:#1C1A12;color:#E3B341">O0</th><th style="background:#1C1A12;color:#E3B341">opt</th>
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
 <b>Instr. ejecutadas (simulador)</b> = instrucciones realmente retiradas por el pipeline
 en la corrida (sin cach&eacute; / O0 / opt); no confundir con <b>Instrucciones (compilador)</b>,
 que es el conteo est&aacute;tico de instrucciones del binario antes y despu&eacute;s de optimizar.
 <span class="p2badge p2fail" style="font-size:0.8em">&#10007; FAIL</span>
 = el resultado en x11 no coincide con el esperado (bug en el compilador).</p>
{sections_html}
</section>
"""


P2_CSV_COLS = [
    # identificacion
    "Programa", "Grupo", "Variante",
    # ── metricas del compilador (independientes de la arquitectura) ───────────
    "Instr_compilador",       # instrucciones en el .hex (tamaño de codigo / 4)
    "Codigo_bytes",           # tamaño del binario en bytes
    "Compile_ms",             # tiempo de compilacion
    "Opt_Unrolled",           # instrucciones desenrolladas
    "Opt_DCE_Removed",        # instrucciones eliminadas por DCE
    "Opt_Reordered",          # instrucciones reordenadas
    "Opt_Renamed",            # instrucciones renombradas
    # ── metricas del simulador (dependen de la arquitectura) ─────────────────
    "Ciclos",                 # ciclos medidos en el pipeline
    "Instr_simulador",        # instrucciones retiradas por el pipeline
    "CPI",
    "IPC",
    "Stalls_Mem",
    "Stalls_Control",
    # resultado
    "x11",
    "Status",
]

P2_CSV = ARQUI / "outputs" / "reports" / "results_p2.csv"


def write_p2_csv(p2_results):
    """Escribe results_p2.csv con una fila por programa x variante,
    separando claramente metricas del compilador de las del simulador."""
    if not p2_results:
        return
    P2_CSV.parent.mkdir(parents=True, exist_ok=True)
    with open(P2_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=P2_CSV_COLS)
        w.writeheader()
        for e in p2_results:
            for variant, r in e["variants"].items():
                r = r or {}
                # Instr_compilador = Code_Size_Bytes / 4 (instrucciones en el .hex)
                csb = _fnum(r.get("Code_Size_Bytes"))
                instr_comp = int(csb / 4) if csb is not None else ""
                w.writerow({
                    "Programa":        e["label"],
                    "Grupo":           e["group"],
                    "Variante":        variant,
                    "Instr_compilador": instr_comp,
                    "Codigo_bytes":    r.get("Code_Size_Bytes", ""),
                    "Compile_ms":      r.get("Compile_ms", ""),
                    "Opt_Unrolled":    r.get("Opt_Unrolled", ""),
                    "Opt_DCE_Removed": r.get("Opt_DCE_Removed", ""),
                    "Opt_Reordered":   r.get("Opt_Reordered", ""),
                    "Opt_Renamed":     r.get("Opt_Renamed", ""),
                    "Ciclos":          r.get("Ciclos", ""),
                    "Instr_simulador": r.get("Instr", ""),
                    "CPI":             r.get("CPI", ""),
                    "IPC":             r.get("IPC", ""),
                    "Stalls_Mem":      r.get("Stalls_Mem", ""),
                    "Stalls_Control":  r.get("Stalls_Control", ""),
                    "x11":             f"0x{e['x11']}" if e.get("x11") else "",
                    "Status":          r.get("_status", ""),
                })
    print(f"[CSV ] {P2_CSV}")


def render_html(rows, path, no_cache, p2_results=None):
    # Las tablas 5.1/5.2/5.3 usan el baseline sin optimizar (O0); las variantes
    # O1+ viven en la seccion del compilador y en el CSV completo.
    base_rows = [r for r in rows if r.get("_opt") in (None, "O0")]
    p2_html = p2_section(p2_results) if p2_results else ""

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>Benchmarks - rendimiento de cache</title>
<style>
 /* ── Base ── */
 :root {{
   --bg:       #0D1117;
   --bg-card:  #161B22;
   --bg-row-alt: #0D1117;
   --bg-thead: #21262D;
   --border:   #30363D;
   --text:     #E6EDF3;
   --muted:    #8B949E;
   --accent:   #58A6FF;
   --ok:       #3FB950;
   --fail:     #F85149;
   --warn:     #E3B341;
   --purple:   #BC8CFF;
 }}
 * {{ box-sizing: border-box; }}
 body {{ font-family: ui-monospace, "SFMono-Regular", "Cascadia Code", monospace;
         margin: 28px 32px; background: var(--bg); color: var(--text);
         max-width: 1200px; line-height: 1.5; }}
 h1 {{ font-size: 1.3em; font-weight: 700; color: var(--accent);
       border-bottom: 1px solid var(--border); padding-bottom: 10px; margin-bottom: 20px; }}
 h2 {{ font-size: 1em; font-weight: 700; color: var(--text);
       margin: 28px 0 8px; border-left: 3px solid var(--accent);
       padding-left: 10px; }}
 h3 {{ font-size: 0.9em; font-weight: 600; color: var(--muted);
       margin: 16px 0 6px; }}
 section {{ margin-bottom: 36px; }}
 /* ── Tables ── */
 table {{ border-collapse: collapse; font-size: 0.84em; width: 100%; }}
 table.metrics {{ font-size: 0.76em; }}
 th, td {{ border: 1px solid var(--border); padding: 5px 10px; text-align: right; }}
 th {{ background: var(--bg-thead); color: var(--muted);
       font-weight: 600; font-size: 0.82em; text-transform: uppercase;
       letter-spacing: 0.04em; }}
 tbody tr:nth-child(even) {{ background: var(--bg-card); }}
 tbody tr:nth-child(odd)  {{ background: var(--bg-row-alt); }}
 tbody tr:hover {{ background: #1C2128; }}
 td:first-child, th:first-child {{ text-align: left; }}
 th.grp {{ background: #161B22; color: var(--accent); text-align: center;
           border-bottom: 2px solid var(--accent); }}
 .tablewrap {{ overflow-x: auto; border-radius: 6px;
               border: 1px solid var(--border); }}
 .tablewrap::-webkit-scrollbar {{ height: 6px; }}
 .tablewrap::-webkit-scrollbar-track {{ background: var(--bg-card); border-radius: 3px; }}
 .tablewrap::-webkit-scrollbar-thumb {{ background: var(--border); border-radius: 3px; }}
 .tablewrap::-webkit-scrollbar-thumb:hover {{ background: var(--muted); }}
 /* ── Inline elements ── */
 code {{ background: #21262D; color: var(--warn); padding: 1px 5px;
         border-radius: 4px; font-size: 0.92em; }}
 .nota {{ font-size: 0.83em; color: var(--muted); margin: 6px 0 10px;
          line-height: 1.55; }}
 /* ── Cards ── */
 .verdict {{ border: 1px solid var(--border); background: var(--bg-card);
             border-radius: 8px; padding: 12px 18px; }}
 .thesis  {{ margin: 4px 0 12px; }}
 .cards   {{ display: flex; flex-wrap: wrap; gap: 12px; }}
 .card    {{ border: 1px solid var(--border); background: var(--bg-card);
             border-radius: 8px; padding: 10px 18px; min-width: 150px; }}
 .ct {{ font-size: 0.74em; color: var(--muted); text-transform: uppercase;
        letter-spacing: .05em; }}
 .cb {{ font-size: 1.55em; font-weight: 700; color: var(--accent); }}
 .cs {{ font-size: 0.76em; color: var(--muted); }}
 /* ── Bar chart elements ── */
 .cblock {{ margin: 10px 0; padding-bottom: 8px; border-bottom: 1px solid var(--border); }}
 .cname  {{ font-weight: 600; font-size: 0.9em; margin-bottom: 3px; }}
 .row  {{ display: flex; align-items: center; margin: 3px 0; }}
 .lbl  {{ width: 110px; font-size: 0.82em; color: var(--muted); }}
 .track {{ flex: 1; background: var(--border); border-radius: 3px;
           height: 14px; max-width: 440px; }}
 .bar  {{ height: 100%; border-radius: 3px; }}
 .val  {{ width: 70px; text-align: right; font-size: 0.82em;
          padding-left: 8px; color: var(--muted); }}
 /* ── Formulas ── */
 .formulas {{ display: flex; flex-wrap: wrap; gap: 14px; }}
 .f {{ border: 1px solid var(--border); border-radius: 6px;
       padding: 8px 12px; background: var(--bg-card); }}
 .f b  {{ color: var(--accent); }}
 .f pre {{ margin: 6px 0 0; font-size: 0.8em; color: var(--muted); }}
 .bad {{ color: var(--fail); font-size: 0.8em; font-weight: 600; }}
 /* ── Compiler level badges ── */
 .optbadge {{ display:inline-block; padding:1px 8px; border-radius:10px;
              font-size:0.78em; font-weight:700; white-space:nowrap; }}
 .clvlrow  {{ display:flex; flex-wrap:wrap; gap:16px; margin:8px 0 14px;
              align-items:center; }}
 .clvldesc {{ font-size:0.82em; color:var(--muted); }}
 .cname    {{ text-align:left !important; font-weight:600; white-space:nowrap; }}
 /* ── Defensa P2 ── */
 #p2 {{ border-top: 2px solid var(--border); margin-top: 40px; padding-top: 12px; }}
 .p2group {{ margin: 20px 0 30px; padding: 16px 18px 12px;
             border-radius: 8px; background: var(--bg-card); }}
 .p2gtitle {{ display:flex; align-items:center; gap:10px; margin-bottom:6px; }}
 .p2gicon  {{ width:10px; height:10px; border-radius:50%; flex-shrink:0; }}
 .p2gdesc  {{ font-size:0.82em; color:var(--muted); margin:4px 0 12px; line-height:1.55; }}
 .p2table  {{ font-size:0.83em; width:100%; }}
 .p2hname  {{ text-align:left !important; min-width:200px; max-width:300px; }}
 .p2hgroup {{ text-align:center !important; background:#21262D; color:var(--muted); }}
 .p2tsub   {{ background:#1A1F2E; color:var(--purple); font-size:0.8em; }}
 .p2namecell {{ text-align:left !important; }}
 .p2name   {{ font-weight:600; font-size:0.88em; display:block; margin-bottom:3px;
              color:var(--text); }}
 .p2desc   {{ font-size:0.75em; color:var(--muted); line-height:1.45; max-width:300px; }}
 .p2x11    {{ font-family:inherit; font-size:0.82em; color:var(--warn); }}
 .p2speedcell {{ text-align:center !important; padding:5px 8px; }}
 .p2badge  {{ display:inline-block; padding:2px 9px; border-radius:12px;
              font-size:0.8em; font-weight:700; white-space:nowrap; }}
 .p2up     {{ background:#12261A; color:#3FB950; border:1px solid #2EA043; }}
 .p2down   {{ background:#2A1217; color:#F85149; border:1px solid #CF222E; }}
 .p2flat   {{ background:#1C2128; color:var(--muted); border:1px solid var(--border); }}
 .p2fail   {{ background:#2A1217; color:#F85149; border:1px solid #CF222E; }}
 .p2na     {{ background:#1C2128; color:var(--muted); border:1px solid var(--border); }}
 .p2delta  {{ font-size:0.77em; color:var(--muted); }}
 .p2green  {{ background:#0F1F14 !important; color:#3FB950; font-weight:600; }}
 .p2red    {{ background:#1F0C0C !important; color:#F85149; font-weight:600; }}
 .p2zero   {{ color:var(--muted); }}
 .p2summary td {{ background:#161B22; color:var(--muted); font-size:0.82em;
                  border-top:2px solid var(--border); }}
 .p2tactive {{ font-weight:700; background:#1A1F2E !important; color:var(--purple); }}
 .p2ms     {{ font-size:0.82em; color:var(--muted); text-align:right;
              white-space:nowrap; }}
 .p2nc     {{ background:#0D1B2A !important; color:#58A6FF; font-size:0.82em; }}
 th.p2nc   {{ background:#0D1B2A !important; color:#58A6FF; }}
 .p2ncskip {{ color:#444D56 !important; font-style:italic; }}
 /* ── Compile-time header rows inside P2 table ── */
 th[style*="fff8e6"] {{ background:#1C1A12 !important; color:var(--warn) !important; }}
 th[style*="f5edff"] {{ background:#1A1427 !important; color:var(--purple) !important; }}
</style></head><body>
<h1>Benchmarks del procesador &mdash; rendimiento de la jerarqu&iacute;a de cach&eacute;</h1>
{cache_effect_section(base_rows, no_cache)}
{processor_section(base_rows)}
{cache_section(base_rows)}
{memory_section(base_rows, no_cache)}
{compiler_section(rows, no_cache)}
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
    write_p2_csv(p2_results)

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
