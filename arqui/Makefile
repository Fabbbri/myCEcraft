# =========================
# Configuración
# =========================
TOP = tb_top              # nombre del testbench principal
SRC_DIR = rtl
TB_DIR = tb
BUILD_DIR = build
WAVE_DIR = waves

# Archivos fuente
SRC = $(wildcard $(SRC_DIR)/*.sv)
TB  = $(wildcard $(TB_DIR)/*.sv)

# Salidas
OUT = $(BUILD_DIR)/sim.vvp
VCD = $(WAVE_DIR)/dump.vcd

# Comandos
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Flags (SystemVerilog)
IVERILOG_FLAGS = -g2012

# =========================
# Targets
# =========================

# Default
all: run

# Crear carpetas necesarias
dirs:
	mkdir -p $(BUILD_DIR) $(WAVE_DIR)

# Compilar
compile: dirs
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(OUT) $(SRC) $(TB)

# Ejecutar simulación
run: compile
	$(VVP) $(OUT)

# Abrir GTKWave
wave:
	$(GTKWAVE) $(VCD)

# Limpiar
clean:
	rm -rf $(BUILD_DIR) $(WAVE_DIR)

# Limpiar solo waves
clean-waves:
	rm -rf $(WAVE_DIR)

# Rebuild completo
re: clean all

# =========================
# Debug útil
# =========================
print:
	@echo "SRC: $(SRC)"
	@echo "TB: $(TB)"