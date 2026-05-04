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

