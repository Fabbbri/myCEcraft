# =========================
# Variables de Configuración
# =========================
# Puede sobreescribirse. Ej: 
# make run TOP=tb_alu
# make run TOP=tb_topG ROM=factorial.hex RAM=ram_hex.hex

TOP ?= tb_topG 
ROM ?= program.hex
RAM ?= data.hex 

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

ifeq ($(UNAME_S),Darwin)
    WAVE_VIEWER = surfer
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
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(OUT) $(SRC) $(TB)

# correr el compilado
run: compile
	$(VVP) $(OUT) $(VVP_FLAGS) +FILE_ROM=programs/$(ROM) +FILE_RAM=programs/$(RAM)

# correr la suite de benchmarks (compila el sim por dentro y genera CSV + HTML)
# ej: make benchmarks            -> usa los .hex versionados + sidecar
#     make benchmarks BENCH_ARGS=--compile   -> recompila O0/O1 y captura metricas del compilador
benchmarks:
	-$(PYTHON) scripts/benchmarks.py $(BENCH_ARGS)

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

.PHONY: all dirs compile run benchmarks wave run-all clean print