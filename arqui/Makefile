# =========================
# Configuración
# =========================
TOP ?= tb_top   # puedes sobreescribirlo: make run TOP=tb_alu

SRC_DIR = rtl
TB_DIR = tb
SIM_DIR = sim
BUILD_DIR = $(SIM_DIR)/build
WAVE_DIR = $(SIM_DIR)/waves

SRC = $(wildcard $(SRC_DIR)/*.sv)

# Si TOP está definido → usar solo ese TB
# Si no → usar todos
ifeq ($(TOP),all)
    TB = $(wildcard $(TB_DIR)/*.sv)
else
    TB = $(TB_DIR)/$(TOP).sv
endif

OUT = $(BUILD_DIR)/$(TOP).vvp
VCD = $(WAVE_DIR)/$(TOP).vcd

IVERILOG = iverilog
VVP = vvp

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    WAVE_VIEWER = surfer
else
    WAVE_VIEWER = gtkwave
endif

IVERILOG_FLAGS = -g2012

# =========================
# Targets
# =========================

all: run

dirs:
	mkdir -p $(BUILD_DIR) $(WAVE_DIR)

compile: dirs
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(OUT) $(SRC) $(TB)

run: compile
	$(VVP) $(OUT)

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