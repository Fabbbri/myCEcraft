# =========================
# Variables de Configuración
# =========================
# Puede sobreescribirse. Ej: 
# make run TOP=tb_alu
# make run TOP=tb_topG ROM=factorial.hex RAM=ram_hex.hex

TOP ?= tb_topG
ROM ?= program.hex
RAM ?= data.hex
MAX_CYCLES ?= 20000

SRC_DIR = rtl
TB_DIR = tb
SIM_DIR = sim
BUILD_DIR = $(SIM_DIR)/build
WAVE_DIR = $(SIM_DIR)/waves
OUTPUT_DIR = outputs

# Wildcard busca todos los nombres de archivos de rtl
SRC = \
	$(wildcard $(SRC_DIR)/*.sv) \
	$(wildcard $(SRC_DIR)/async_fifo/*.sv) \
	$(wildcard $(SRC_DIR)/IF/*.sv) \
	$(wildcard $(SRC_DIR)/DE/*.sv) \
	$(wildcard $(SRC_DIR)/MEM/*.sv) \
	$(wildcard $(SRC_DIR)/utils/*.sv) \
	$(wildcard $(SRC_DIR)/TOP/*.sv) \
	$(wildcard $(SRC_DIR)/TOP/old/*.sv) \

# Si TOP está definido: usar solo ese TB
# Si no: usar todos
ifeq ($(TOP),all)
    TB = $(wildcard $(TB_DIR)/*.sv)
else
    TB = $(TB_DIR)/$(TOP).sv
endif



# archivo simulable
OUT = $(BUILD_DIR)/$(TOP).vvp

#archivo wave
VCD = $(WAVE_DIR)/$(TOP).vcd

# Instruccion de compilación
IVERILOG = iverilog

# Instrucción de simulación
VVP = vvp
VVP_FLAGS ?=

# Suite de benchmarks (Python). Ej: make benchmarks BENCH_ARGS=--compile
PYTHON ?= python
BENCH_ARGS ?=

# =========================
# Usar surfer o wave según OS
# =========================

UNAME_S := $(shell uname -s)

# gtkwave incluido con el instalador de Icarus en Windows (si existe)
GTKWAVE_BUNDLED := $(wildcard C:/iverilog/gtkwave/bin/gtkwave.exe)

ifeq ($(UNAME_S),Darwin)
    WAVE_VIEWER = surfer
else ifneq ($(GTKWAVE_BUNDLED),)
    WAVE_VIEWER = $(GTKWAVE_BUNDLED)
else
    WAVE_VIEWER = gtkwave
endif

# Soporte de Verilog 2012
IVERILOG_FLAGS = -g2012

# =========================
# Targets
# =========================

all: run

# Crear los directorios necesarios
dirs:
	mkdir -p $(BUILD_DIR) $(WAVE_DIR) $(OUTPUT_DIR)

# Compilar los directorios según tb
compile: dirs
	mkdir -p $(dir $(OUT)) $(dir $(VCD))
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(OUT) $(SRC) $(TB)

# correr el compilado
run: compile
	$(VVP) $(OUT) $(VVP_FLAGS) +FILE_ROM=programs/$(ROM) +FILE_RAM=programs/$(RAM)

# correr la suite de benchmarks (compila el sim por dentro y genera CSV + HTML).
# Recompila los ROM principales (O0..O3) y los 12 programas de Defensa/P2 desde
# su fuente .craft antes de medir.
# ej: make bench
#     make bench BENCH_ARGS=--no-open   -> no abrir el HTML al terminar
bench:
	-$(PYTHON) scripts/benchmarks.py --compile --compile-p2 $(BENCH_ARGS)

# correr el tb SIN cache (top_no_cash + memoria realista) en un programa.
# El tb vive en tb/old/, por eso tiene target propio (no usa run TOP=...).
# ej: make run-no-cache ROM=program.hex RAM=data.hex
run-no-cache: dirs
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(BUILD_DIR)/tb_top_no_cash.vvp $(SRC) $(TB_DIR)/old/tb_top_no_cash.sv
	$(VVP) $(BUILD_DIR)/tb_top_no_cash.vvp +FILE_ROM=programs/$(ROM) +FILE_RAM=programs/$(RAM)

# igual que run-no-cache pero recibiendo el .hex como argumento posicional:
#   make nocache programa.hex                 # valida contra el oraculo del while
#   make nocache programa.hex X11=7F80        # valida x11 == 0x7F80 (otro programa)
#   make nocache programa.hex MAX_CYCLES=5000000
# - busca el .hex en programs/ si no lleva ruta
# - usa programa.data.hex como RAM si existe, si no programs/data.hex
# - calcula HALT_PC del freeze (00600000)
# - MAX_CYCLES default alto (2M) porque sin cache es lento; override-able
# - SIN X11 el tb valida el resultado del programa por defecto (while x<5:
#   x11=x3=x5=5). Para CUALQUIER otro programa pasa X11=<hex> con su x11 esperado;
#   si no, los [FAIL] de registros son del oraculo, no del programa.
# El 2do goal (programa.hex) se neutraliza con una regla vacia para que make no
# intente "construirlo".
ifeq (nocache,$(firstword $(MAKECMDGOALS)))
  NOCACHE_ARG := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(NOCACHE_ARG):;@:)
endif

nocache: MAX_CYCLES := 2000000
nocache: dirs
	@rom="$(NOCACHE_ARG)"; \
	if [ -z "$$rom" ]; then echo "Uso: make nocache <programa.hex> [X11=<hex>] [MAX_CYCLES=N]"; exit 1; fi; \
	case "$$rom" in */*) ;; *) rom="programs/$$rom";; esac; \
	if [ ! -f "$$rom" ]; then echo "❌ no existe: $$rom"; exit 1; fi; \
	ram="$${rom%.hex}.data.hex"; [ -f "$$ram" ] || ram="programs/data.hex"; \
	halt=$$(awk '{gsub(/[ \t\r]/,"")} $$0=="00600000"{printf "%X",(NR-1)*4; exit}' "$$rom"); \
	if [ -z "$$halt" ]; then echo "⚠️  sin freeze (00600000) en $$rom; HALT_PC=0"; halt=0; fi; \
	x11arg=""; [ -n "$(X11)" ] && x11arg="+EXPECT_X11=$(X11)"; \
	echo "▶️  nocache  ROM=$$rom  RAM=$$ram  HALT_PC=$$halt  MAX_CYCLES=$(MAX_CYCLES)  $(if $(X11),EXPECT_X11=$(X11),oraculo=while)"; \
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(BUILD_DIR)/tb_top_no_cash.vvp $(SRC) $(TB_DIR)/old/tb_top_no_cash.sv && \
	$(VVP) $(BUILD_DIR)/tb_top_no_cash.vvp +FILE_ROM=$$rom +FILE_RAM=$$ram \
		+HALT_PC=$$halt +MAX_CYCLES=$(MAX_CYCLES) +TEST_NAME=$$(basename "$$rom") $$x11arg

# =========================
# Pipeline TEA imagen end-to-end
# =========================
# 1) prepara el .txt como imagen embebida (genera programs/teaimg_input.hex)
# 2) corre el tb sin cache que cifra+descifra en DRAM y vuelca teaimg_salida.hex
# 3) extrae los 1024 bytes descifrados (DRAM[0x8810]) a un .txt legible
# ej: make tea
tea:
	$(PYTHON) scripts/prepare_teaimg.py --input arqui/scripts/examples/epic_1k.txt
	$(MAKE) run TOP=tb_teaimg_loader
	$(PYTHON) scripts/extract_data.py --memory outputs/teaimg_salida.hex --address 0x8810 --size 1024 --output outputs/teaimg_recuperada.txt

# =========================
# Demo de visualizacion (GTKWave)
# =========================
# Genera UNA sola vez el VCD con bench_stride y luego cada vista lo reabre con
# su archivo .gtkw tematico. Asi no se recompila/re-simula 4 veces.

# Compila + simula bench_stride y deja sim/waves/tb_topG.vcd listo.
wave-vcd: dirs
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(BUILD_DIR)/tb_topG.vvp $(SRC) $(TB_DIR)/tb_topG.sv
	$(VVP) $(BUILD_DIR)/tb_topG.vvp +VCD +HALT_PC=E4 +MAX_CYCLES=300000 +FILE_ROM=programs/bench_stride.hex +FILE_RAM=programs/data.hex
	@echo ">> En GTKWave: Ctrl+Shift+F para ver toda la corrida"

# Vista: flujo de instrucciones por etapa (PC, IF/ID, rd por etapa, WB, stalls/flush)
wave-pipeline: wave-vcd
	$(WAVE_VIEWER) sim/waves/tb_topG.vcd sim/gtkwave/tb_topG_pipeline.gtkw

# Vista: ALU + register file (srcA/srcB/alu_result/flags, registros clave, escritura WB)
wave-datapath: wave-vcd
	$(WAVE_VIEWER) sim/waves/tb_topG.vcd sim/gtkwave/tb_topG_datapath.gtkw

# Vista: forwarding y riesgos (forwardA/B, rs/rd por etapa, stalls/flush)
wave-hazard: wave-vcd
	$(WAVE_VIEWER) sim/waves/tb_topG.vcd sim/gtkwave/tb_topG_hazard.gtkw

# Vista: jerarquia de memoria / cache (dirección, load/store, hit/miss L1/L2, burst)
wave-mem: wave-vcd
	$(WAVE_VIEWER) sim/waves/tb_topG.vcd sim/gtkwave/tb_topG_mem.gtkw

# demo lista para defensa: alias historico -> abre la vista de pipeline.
wave-demo: wave-pipeline

# =========================
# Simular un programa y abrir la onda en Surfer
# =========================
# En Linux, Surfer se lanza con entorno limpio (env -i) para evitar el choque de
# libs del snap de VSCode (libpthread de /snap/core20); requiere surfer en
# ~/.local/bin. En macOS ese env -i estorba: borra el PATH donde cargo/brew
# instalan surfer (~/.cargo/bin, /opt/homebrew/bin), asi que se invoca directo.
# SURFER_CHECK valida la disponibilidad del binario tal como lo vera el target.
ifeq ($(UNAME_S),Darwin)
    SURFER = surfer
    SURFER_CHECK = command -v surfer
else
    SURFER = env -i HOME="$(HOME)" DISPLAY="$(DISPLAY)" XAUTHORITY="$(XAUTHORITY)" \
	WAYLAND_DISPLAY="$(WAYLAND_DISPLAY)" XDG_RUNTIME_DIR="$(XDG_RUNTIME_DIR)" \
	PATH="$(HOME)/.local/bin:/usr/bin:/bin" surfer
    SURFER_CHECK = test -x "$(HOME)/.local/bin/surfer"
endif

# Compila tb_topG, corre un programa con +VCD y abre la onda en Surfer.
# HALT_PC se calcula solo: indice de la instruccion freeze (00600000) x4 (hex).
# ej: make surf                    -> corre programs/program.hex
#     make surf ROM=factorial.hex MAX_CYCLES=300000
surf: dirs
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(BUILD_DIR)/tb_topG.vvp $(SRC) $(TB_DIR)/tb_topG.sv
	@halt=$$(awk '{gsub(/[ \t\r]/,"")} $$0=="00600000"{printf "%X",(NR-1)*4; exit}' programs/$(ROM)); \
	if [ -z "$$halt" ]; then echo "⚠️  sin freeze (00600000) en programs/$(ROM); HALT_PC=0"; halt=0; fi; \
	echo "▶️  $(ROM)  HALT_PC=$$halt  MAX_CYCLES=$(MAX_CYCLES)"; \
	$(VVP) $(BUILD_DIR)/tb_topG.vvp +VCD +HALT_PC=$$halt +MAX_CYCLES=$(MAX_CYCLES) \
		+TEST_NAME=$(ROM) +FILE_ROM=programs/$(ROM) +FILE_RAM=programs/$(RAM)
	@if $(SURFER_CHECK) >/dev/null 2>&1; then \
		$(SURFER) -c sim/surfer/topG_overview.surf $(WAVE_DIR)/tb_topG.vcd; \
	else \
		echo "ℹ️  Surfer no encontrado; la simulacion termino OK y la onda quedo en:"; \
		echo "    $(WAVE_DIR)/tb_topG.vcd"; \
		echo "   Instalalo con 'cargo install surfer' o abre el VCD con gtkwave/otro visor."; \
	fi

# iniciar simulacion con waves
wave:
	@if [ ! -f $(VCD) ]; then \
		echo "❌ No existe $(VCD). Ejecuta primero make run TOP=$(TOP)"; \
		exit 1; \
	fi
	$(WAVE_VIEWER) $(VCD)

# Ejecutar TODOS los testbenches
run-all:
	@for tb in $(wildcard $(TB_DIR)/*.sv); do \
		name=$$(basename $$tb .sv); \
		echo "▶️ Ejecutando $$name..."; \
		$(MAKE) run TOP=$$name; \
	done

clean:
	rm -rf $(SIM_DIR)

print:
	@echo "TOP: $(TOP)"
	@echo "TB: $(TB)"

.PHONY: all dirs compile run bench run-no-cache nocache tea wave wave-vcd wave-pipeline wave-datapath wave-hazard wave-mem wave-demo surf run-all clean print