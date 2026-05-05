# myCEcraft

myCEcraft integra dos componentes del proyecto Compilador-Procesador Craft21:

- `arqui/`: implementacion en SystemVerilog de la arquitectura/procesador Craft21.
- `compi/`: compilador del lenguaje Craft hacia ensamblador, hexadecimal y binario para la arquitectura.

La idea general del repositorio es permitir escribir programas `.craft`, compilarlos a instrucciones Craft21 y probarlos en los modulos de arquitectura mediante simulacion con Icarus Verilog.

---

## Arquitectura Craft21 (`arqui/`)

### Proposito

La carpeta `arqui/` contiene la descripcion de hardware del procesador Craft21 en SystemVerilog. Incluye los modulos RTL, testbenches, memorias de programa/datos y scripts de apoyo para simular el comportamiento del procesador y de sus componentes.

El objetivo de esta parte es verificar la ejecucion de instrucciones generadas para Craft21, incluyendo ALU, registros, memoria, unidad de control, pipeline y soporte para instrucciones especiales de la boveda/neather.

### Dependencias

Para compilar y ejecutar las simulaciones se necesita:

- Icarus Verilog, que provee `iverilog` y `vvp`.
- GNU Make, para usar el `Makefile` incluido.
- GTKWave en Linux/Windows o Surfer en macOS, si se quieren abrir formas de onda `.vcd`.
- Un entorno tipo Bash para usar `run.sh` desde la raiz del repositorio. En Windows se puede usar Git Bash, WSL o ejecutar `make` directamente dentro de `arqui/`.

En Debian/Ubuntu:

```bash
sudo apt install -y iverilog gtkwave make
```

### Estructura del repositorio

```text
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
|--compi/
|------ codegen/    # generación de código 
|------ ejemplos/   # archivos .craft
|------ outputs/    # Archivos .hex, .asm, .bin, etc. generador por el compilador
|------ # archivos .py varios del compilador
|-- gitignore
|-- LICENSE
|-- README.md
|-- run.sh
|-- ISA.pdf
|____________________________
```

Modulos importantes en `arqui/rtl/`:

- `top.sv`: modulo superior del procesador.
- `alu.sv`: unidad aritmetico-logica.
- `control_unit.sv`: unidad de control.
- `regfile.sv`: banco de registros.
- `instr_rom.sv`: memoria de instrucciones cargada con `$readmemh`.
- `data_ram.sv`: memoria de datos.
- `pc.sv`, `pc_decoder.sv`, `sumador_pc.sv`: logica asociada al contador de programa.
- `if_id_pipe.sv`, `id_ex_pipe.sv`, `ex_mem_pipe.sv`, `mem_wb_pipe.sv`: registros de pipeline.
- `neather_ram.sv`, `neather_regfile.sv`: soporte para memoria/registros especiales.

Testbenches disponibles en `arqui/tb/` incluyen, entre otros:

- `tb_alu.sv`
- `tb_regfile.sv`
- `tb_control_unit.sv`
- `tb_instr_rom.sv`
- `tb_data_ram.sv`
- `tb_top.sv`
- `tb_top_vault.sv`
- `tb_tea.sv`

En `arqui/scripts/` se incluyen varios scripts de python, como la herramienta para cargar cualquier archivo, un script para compresión de imágenes, un script para volcado de memoria y un script para preparar el tb de `teaimg` para su ejecución. Además, se incluye un README que indica como ejecutar correctamente este tipo de testbenches que usa la herramienta. Al final de este `README.md` se indica la ruta a esta guía de uso.

## Compilacion y ejecucion 

### Compilación y ejecución con Make

Desde la carpeta `arqui/`:

```bash
cd arqui
make run TOP=tb_alu
```

Esto compila todos los archivos de `rtl/` junto con el testbench indicado y ejecuta la simulacion con `vvp`.

Para ejecutar el procesador completo:

```bash
cd arqui
make run TOP=tb_top
```

Para ejecutar todos los testbenches:

```bash
cd arqui
make run-all
```

Para limpiar archivos generados:

```bash
cd arqui
make clean
```

### Compilacion y ejecucion directa con Icarus Verilog

Tambien se puede usar `iverilog` sin `make`.

Ejemplo con `tb_alu`:

```bash
cd arqui
mkdir -p sim/build sim/waves
iverilog -g2012 -o sim/build/tb_alu.vvp rtl/*.sv tb/tb_alu.sv
vvp sim/build/tb_alu.vvp
```

Ejemplo con la ROM de instrucciones:

```bash
cd arqui
mkdir -p sim/build sim/waves
iverilog -g2012 -o sim/build/tb_instr_rom.vvp rtl/*.sv tb/tb_instr_rom.sv
vvp sim/build/tb_instr_rom.vvp
```

Los testbenches generan archivos `.vcd` en `arqui/sim/waves/` cuando incluyen `$dumpfile` y `$dumpvars`.

### Ver formas de onda

Primero se ejecuta la simulacion:

```bash
cd arqui
make run TOP=tb_alu
```

Luego se abre la onda:

```bash
make wave TOP=tb_alu
```

El `Makefile` usa `gtkwave` en Linux y `surfer` en macOS.

### Uso de programas `.hex`

La ROM de instrucciones carga el archivo:

```systemverilog
$readmemh("programs/program.hex", memory);
```

Por eso, para probar un programa especifico se debe colocar su hexadecimal en:

```text
arqui/programs/program.hex
```

Si el programa usa datos globales, tambien se debe preparar:

```text
arqui/programs/data.hex
```

Ejemplo de prueba con un archivo ya incluido:

```bash
cd arqui
cp programs/demo.hex programs/program.hex
make run TOP=tb_instr_rom
```

En PowerShell:

```powershell
Copy-Item arqui/programs/demo.hex arqui/programs/program.hex
cd arqui
make run TOP=tb_instr_rom
```

## Ejecución Rápida

El repositorio incluye `run.sh` para invocar el flujo de arquitectura desde la raiz de forma mucho más eficiente:

```bash
chmod +x run.sh
./run.sh list # para ver algunos de los tb disponibles 
./run.sh run <tb_nombre>
./run.sh wave <tb_nombre>
./run.sh all
./run.sh clean
```

---

## Compilador Craft (`compi/`)

### Proposito

La carpeta `compi/` contiene el compilador del lenguaje Craft. Este compilador toma archivos `.craft`, realiza analisis lexico, sintactico y semantico, genera ensamblador para Craft21, resuelve etiquetas y saltos, y puede producir archivos `.hex`, `.bin` y `.lst`.

Estos artefactos permiten conectar el compilador con la arquitectura: el `.hex` generado se puede cargar en `arqui/programs/program.hex` para simularlo en la ROM.

### Dependencias

Para usar el compilador se necesita:

- Python 3.

Los comandos se ejecutan desde la raiz del repositorio.

### Estructura del codigo

```text
compi/
|-- main.py              # Punto de entrada del compilador
|-- lexer.py             # Analisis lexico
|-- parser.py            # Analisis sintactico
|-- semantic.py          # Analisis semantico
|-- symbol_table.py      # Tabla de simbolos
|-- isa.py               # Definicion/codificacion de instrucciones
|-- registers.py         # Registros de la arquitectura
|-- ast_nodes.py         # Nodos del AST
|-- codegen/             # Generacion de ensamblador, resolucion y binario
|-- ejemplos/            # Programas de prueba .craft
|-- output/              # Artefactos generados
|-- README.md            # Documentacion especifica del compilador
```

Subcarpetas de salida:

```text
compi/output/
|-- expanded/        # Archivos .expanded.craft generados por invoke
|-- asm_unresolved/  # Ensamblador con etiquetas simbolicas
|-- asm_resolved/    # Ensamblador con saltos resueltos
|-- bin_output/      # .bin, .hex, .data.hex y .lst
```

### Ejemplos incluidos

Algunos programas de prueba en `compi/ejemplos/`:

- `demo.craft`
- `factorial.craft`
- `factorial_rec.craft`
- `busqueda_arreglo.craft`
- `ender_demo.craft`
- `enderportal_demo.craft`
- `tea.craft`
- `ejemplo_import.craft`
- `demo_import_nesting.craft`

### Uso basico

Imprimir tokens:

```bash
python3 compi/main.py --tokens compi/ejemplos/demo.craft
```

Imprimir analisis sintactico / AST:

```bash
python3 compi/main.py -t compi/ejemplos/demo.craft
```

Imprimir tabla de simbolos:

```bash
python3 compi/main.py -m compi/ejemplos/demo.craft
```

Generar ensamblador sin resolver y resuelto:

```bash
python3 compi/main.py -r compi/ejemplos/demo.craft
```

Generar ensamblador, binario, hexadecimal y listado:

```bash
python3 compi/main.py -r -b compi/ejemplos/demo.craft
```

Generar binario con nombre de salida explicito:

```bash
python3 compi/main.py compi/ejemplos/demo.craft -o compi/output/bin_output/demo.bin
```

Generar ensamblador y binario:

```bash
python3 compi/main.py -s compi/ejemplos/demo.craft -o compi/output/bin_output/demo.bin
```

Generar binario y mostrar tabla de simbolos con labels resueltas:

```bash
python3 compi/main.py -m -r -b compi/ejemplos/demo.craft
```

En Windows, si `python3` no existe, normalmente se puede intentar con `python`:

```powershell
python compi/main.py -r -b compi/ejemplos/demo.craft
```

### Fases implementadas

El compilador tiene implementadas estas fases:

- Analisis lexico: reconoce keywords, tipos, literales, operadores, delimitadores y comentarios.
- Analisis sintactico: construye un AST para imports, funciones, bloques, condiciones, ciclos, retornos, llamadas y expresiones.
- Analisis semantico: maneja scopes, tabla de simbolos, tipos, memoria preliminar y validaciones basicas.
- Generacion de ensamblador: traduce instrucciones del lenguaje Craft a ensamblador Craft21.
- Resolucion de referencias: calcula direcciones de labels y offsets de salto.
- Generacion binaria: produce imagen `.bin`, instrucciones `.hex`, datos `.data.hex` y listado `.lst`.

---

## Resumen: Guía de Uso y documentación

A continuación, se facilita la ruta a los README.md más importantes del repositorio:

### Guía de Uso

- [`./arqui/scripts/README.md`](./arqui/scripts/README.md): Para testbenches que requieran script (por ejemplo, TEA)

- [`./arqui/README.md`](./arqui/README.md): Para testbenches generales que no requieran script (por ejemplo, factorial)


### Documentación

- [`./arqui/docs/isa.md`](./arqui/docs/isa.md): ISA de la arquitectura Craft21

- [`./arqui/docs/microarchitecture.md`](./arqui/docs/microarchitecture.md): Micro arquitectura diseñada e implementada de Craft21

- [`./arqui/docs/microarch.png`](./arqui/docs/microarch.png): Diagrama de bloques de la organización y microarquitectura de Craft21

- [`./arqui/docs/simulation.md`](./arqui/docs/simulation.md): Resumen de implementación de la simulación de la arquitectura Craft21

