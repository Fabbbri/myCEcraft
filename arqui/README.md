# Arquitectura Craft21: MyCECraft - Uso General

Este repositorio muestra la arquitectura Craft21 para el proyecto Compilador-Procesador MyCECraft. El procesador está realizado en SystemVerilog utilizando IcarusVerilog y GTKWave o Surfer (en ambiente IOS (Apple Silicon)).

## Estructura de la carpeta de arquitectura

```
MyCECraft/
|--arqui/
|------ docs/       # Documentación técnica requerida de ISA
|------ outputs/    # Conjunto de archivos para comprobación de testbench
|------ programs/   # Archivos .hex usados por las memorias de simulacion
|------ rtl/        # Modulos SystemVerilog sintetizables
|------ scripts/    # Scripts auxiliares como la herramienta para archivos requerida
|------ sim/        # Salidas generadas: .vvp y .vcd
|------ tb/         # Testbenches de los modulos y del procesador
|------ Makefile    # Flujo de compilacion y simulacion
|------ README.md   # Documentacion especifica de arquitectura
```

### `rtl/` - Hardware (Register Transfer Level)

Contiene todos los módulos del procesador (hardware sintetizable (SystemVerilog))

```
rtl/
├── alu.sv
├── control_unit.sv
├── data_ram.sv
├── decode.sv
├── ex_mem_pipe.sv
├── execute.sv
├── id_ex_pipe.sv
├── if_id_pipe.sv
├── immm_extend.sv
├── instr_rom.sv
├── mem_wb_pipe.sv
├── memory.sv
├── mux31_3.sv
├── mux31_2.sv
├── mux31.sv
├── neather_ram.sv
├── neather_regfile.sv
├── orgate5.sv
├── pc_decoder.sv
├── pc.sv
├── regfile.sv
├── secure_mode.sv
├── sum31b.sv
├── sumador_pc.sv
├── top.sv
├── writeback.sv
|___________________
```

### `tb/` - Testbenches

En esta carpeta se encuentran los módulos de prueba para verificar el funcionamiento de cada módulo de Hardware

```
tb/
├── tb_alu.sv
├── tb_control_unit.sv
├── ...
├── tb_general_dump.sv # para testbenches generales
├── tb_teaimg_loader.sv # para TEA con cualquier tipo de archivo solicitado.
```

Incluye aspectos como:
- Bloques initial
- $dumpfile y $dumpvars
- Estímulos (inputs)
- Verificación de resultados
- Prints

En este README se trata con el testbench general. Si desea más información sobre TEA, dirígase a:

- [`/arqui/scripts/README.md`](/arqui/scripts/README.md)

Si desea ver la documentación de la arquitectura, dírigase a:

- [`/arqui/docs`](/arqui/docs)

El cuál presenta opciones tales como:

- [`/arqui/docs/isa.md`](/arqui/docs/isa.md)
- [`/arqui/docs/microarchitecture.md`](/arqui/docs/microarchitecture.md)
- [`/arqui/docs/simulation,md`](/arqui/docs/simulation.md)

## Testbench general de cualquier programa con volcado

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

En `tb_topG` la onda se genera **solo si se pasa `+VCD`** (asi los benchmarks
corren sin escribir VCDs gigantes). Para inspeccionar señales en GTKWave:

```bash
make run TOP=tb_topG ROM=program.hex VVP_FLAGS=+VCD
make wave TOP=tb_topG
```

Detalle del flujo y señales sugeridas en [docs/simulation.md](docs/simulation.md).

### `programs/` - Archivos .hex para ROM y RAM

Contiene .hex necesarios para la ejecución de testbench. Se muestran a continuación:

```
programs/
├── # Archivos default
├── data.hex          # RAM para memoria normal de un tb general
├── neather.hex       # RAM para memoria de bóveda de un tb general
├── teaimg_loader.hex # RAM para el tb de TEA (datos a cifrar)
├── # Archivos program
├── program.hex
├── factorial.hex     # ROM para el tb de factorial
├── teaimg_input.hex  # ROM para el tb de TEA
├── ... # otros archivos de prueba nuevos
```

### `outputs/` - Archivos de comprobación

Contiene todos los archivos generados durante la simulación para comprobar (volcado de memoria, estado final de registros o bien .txt/.png generados por TEA):

```
outputs/
├── <program_name>_dram.hex     # RAM de datos para un programa x
├── <program_name>_regs.txt     # Estado final de registros normales para un programa x
├── <program_name>_rom.hex      # ROM de instrucciones para un programa x
├── <program_name>_vault.hex    # Vault/Neather RAM para un programa x
# Específicos de TEA
├── teaimg_cifrada.hex    
├── teaimg_descifrada.hex  
├── teaimg_original.hex  
├── teaimg_recuperada.<png, txt, ...>
├── teaimg_vault.hex  
├── ... # otros archivos de prueba nuevos
```