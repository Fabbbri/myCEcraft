# Arquitectura Craft21: MyCECraft

Este programa muestra la arquitectura Craft21 para el proyecto Compilador-Procesador MyCECraft. El procesador está realizado en SystemVerilog utilizando IcarusVerilog y GTKWave o Surfer (en ambiente IOS (Apple Silicon)).

## Estructura de la carpeta de arquitectura

```
arqui/
├── rtl/
├── tb/
├── sim/
├── programs/
├── scripts/
├── docs/
├── Makefile
├── run.sh
└── .gitignore
```

### `rtl/` - Hardware (Register Transfer Level)

Contiene todos los módulos del procesador (hardware sintetizable (SystemVerilog))

```
rtl/
├── alu.sv
├── register_file.sv
├── control_unit.sv
├── datapath.sv
├── cpu_top.sv
├── instr_rom.sv
├── data_mem.sv
```

### `tb/` - Testbenches

En esta carpeta se encuentran los módulos de prueba para verificar el funcionamiento de cada módulo de Hardware

```
tb/
├── tb_alu.sv
├── tb_register_file.sv
├── tb_cpu.sv
```

Incluye aspectos como:
- Bloques initial
- $dumpfile y $dumpvars
- Estímulos (inputs)
- Verificación de resultados
- Prints

#### Testbench general de volcado

`tb_general_dump.sv` sirve para ejecutar cualquier programa y guardar el estado
final de memoria sin depender de las pruebas de TEA.

Uso con los archivos por defecto (`programs/program.hex`, `programs/data.hex`,
`programs/neather.hex`):

```bash
./run.sh run tb_general_dump
```

Uso con archivos `.hex` especificos:

```bash
./run.sh run tb_general_dump factorial.hex
```

Tambien puede pasar los plusargs completos si necesita controlar nombres o
archivos de RAM:

```bash
./run.sh run tb_general_dump "+ROM=programs/demo.hex +DATA=programs/data.hex +VAULT=programs/neather.hex +OUT=demo"
```

Uso con un loader MYCE generado por `load_file.py`:

```bash
./run.sh run tb_general_dump "+LOADER=programs/mi_programa_loader.hex +OUT=mi_programa"
```

El volcado queda en:

- `outputs/<OUT>_dram.hex`
- `outputs/<OUT>_vault.hex`
- `outputs/<OUT>_rom.hex`
- `outputs/<OUT>_regs.txt`

Deben contener lo siguiente:

```SystemVerilog
string tb_name = "tb_alu";

initial begin
    $dumpfile($sformatf("sim/waves/%s.vcd", tb_name));
    $dumpvars(0, tb_alu);
end
```

### `sim/` - Archivos de simulación

Contiene todos los archivos generados durante la simulación:

```
sim/
├── build/     # archivos compilados (.vvp)
├── waves/     # dumps de señales (.vcd)
├── gtkwave/   # configuraciones (.gtkw)
```
