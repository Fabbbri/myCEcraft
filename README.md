# myCEcraft

myCEcraft es un proyecto integrado de compilador y procesador para la
arquitectura Craft21. Permite escribir programas en el lenguaje `.craft`,
compilarlos a código máquina y ejecutarlos sobre un procesador descrito en
SystemVerilog mediante Icarus Verilog.

El repositorio contiene dos componentes principales:

- `compi/`: compilador de Craft, representación intermedia, optimizaciones y
  generación de ensamblador, binario y archivos `.hex`.
- `arqui/`: procesador Craft21, pipeline, jerarquía de memoria L1/L2,
  testbenches, programas y suite de benchmarks.

## Características principales

- Procesador segmentado implementado en SystemVerilog.
- Unidad de riesgos, forwarding y control de stalls y flushes.
- Jerarquía de memoria con cachés L1 y L2.
- Memoria y registros especiales de bóveda (*Neather/Vault*).
- Compilador con análisis léxico, sintáctico y semántico.
- Generación de IR, CFG, ensamblador y código máquina Craft21.
- Optimizaciones O0, O1, O2 y O3:
  - *loop unrolling*;
  - renombrado estático de registros;
  - eliminación de código muerto (DCE);
  - reordenamiento seguro de instrucciones.
- Benchmarks con métricas de ciclos, instrucciones, CPI, IPC, stalls, caché,
  memoria principal y tiempo de compilación.

## Requisitos

### Obligatorios

- Python 3.10 o superior.
- Icarus Verilog, que proporciona `iverilog` y `vvp`.
- GNU Make.
- Bash para ejecutar `run.sh` y algunos ejemplos de terminal.

En Debian o Ubuntu:

```bash
sudo apt update
sudo apt install -y python3 make iverilog
```

Comprobación rápida:

```bash
python3 --version
iverilog -V
vvp -V
make --version
```

El compilador por línea de comandos usa únicamente la biblioteca estándar de
Python.

### Opcionales

- GTKWave para visualizar archivos `.vcd` en Linux o Windows.
- Surfer para visualizar ondas en macOS o Linux.
- PySide6 para ejecutar Craft Studio, la interfaz gráfica del compilador.




En Debian o Ubuntu, GTKWave puede instalarse con:

```bash
sudo apt install -y gtkwave
```

## Inicio rápido

Desde la raíz del repositorio:

```bash
# Compilar un programa Craft.
python3 compi/main.py -r -b compi/ejemplos/demo.craft

# Simular un programa ya disponible en arqui/programs/.
make -C arqui run TOP=tb_topG ROM=demo.hex

# Ejecutar todos los benchmarks y generar el reporte.
make -C arqui bench BENCH_ARGS=--no-open
```

Los artefactos del compilador quedan en `compi/output/`; los ejecutables de
Icarus y las ondas quedan en `arqui/sim/`; los resultados de benchmarks se
guardan en `arqui/outputs/reports/`.

## Estructura del repositorio

```text
myCEcraft/
├── arqui/
│   ├── docs/                 # ISA, microarquitectura, memoria y rendimiento
│   ├── outputs/              # Dumps y reportes producidos por simulación
│   ├── programs/
│   │   ├── src/              # Fuentes de los benchmarks
│   │   └── *.hex             # Imágenes de ROM y RAM
│   ├── rtl/
│   │   ├── DE/               # Decode, control y banco de registros
│   │   ├── IF/               # Fetch, ROM y lógica del PC
│   │   ├── MEM/              # RAM, cachés L1/L2 y controladores
│   │   ├── TOP/              # Pipeline y módulo superior
│   │   ├── async_fifo/       # FIFO asíncrono
│   │   └── utils/            # ALU, multiplexores y utilidades
│   ├── scripts/              # Benchmarks y herramientas para TEA/archivos
│   ├── sim/                  # Binarios .vvp, ondas .vcd y vistas
│   ├── tb/                   # Testbenches
│   └── Makefile
├── compi/
│   ├── codegen/              # Generación y resolución de código
│   ├── Defensa/P2/           # Casos dirigidos de optimización
│   ├── ejemplos/             # Programas Craft de ejemplo
│   ├── IDE/                  # Craft Studio
│   ├── IR/                   # IR, CFG y análisis de instrucciones
│   ├── Optimizations/        # Unroll, rename, DCE y reorder
│   ├── output/               # Artefactos generados
│   ├── tests/                # Pruebas del compilador y del IDE
│   └── main.py               # Punto de entrada del compilador
├── run.sh                    # Atajo para simulaciones
├── ISA.pdf
└── README.md
```

## Compilador Craft

### Compilación básica

El siguiente comando ejecuta el compilador, resuelve etiquetas y genera
ensamblador, binario, hexadecimal y listado:

```bash
python3 compi/main.py -r -b compi/ejemplos/demo.craft
```

Las salidas principales se escriben en:

```text
compi/output/
├── asm_unresolved/           # Ensamblador con etiquetas
├── asm_resolved/             # Ensamblador con saltos resueltos
├── ast/                      # Árbol sintáctico
├── bin_output/               # .bin, .hex, .data.hex y .lst
├── cfg/                      # Grafo de flujo de control en DOT
├── expanded/                 # Fuentes con invoke expandido
├── ir/                       # Representación intermedia
└── symbols/                  # Tablas de símbolos
```

### Opciones frecuentes

```bash
# Mostrar tokens.
python3 compi/main.py --tokens compi/ejemplos/demo.craft

# Generar AST, IR y CFG.
python3 compi/main.py --ast --ir --cfg compi/ejemplos/demo.craft

# Generar tabla de símbolos.
python3 compi/main.py --symbols compi/ejemplos/demo.craft

# Generar ensamblador y código máquina.
python3 compi/main.py --asm --resolve --binary compi/ejemplos/demo.craft

# Especificar el archivo binario de salida.
python3 compi/main.py -r -b compi/ejemplos/demo.craft \
  -o compi/output/bin_output/demo.bin
```

### Niveles de optimización

| Nivel | Transformaciones |
|---|---|
| `-O0` | Sin optimizaciones |
| `-O1` | *Loop unrolling* y renombrado de registros |
| `-O2` | Eliminación de código muerto y reordenamiento |
| `-O3` | Todas las optimizaciones |

Ejemplos:

```bash
python3 compi/main.py -r -b -O0 compi/ejemplos/demo.craft
python3 compi/main.py -r -b -O3 compi/ejemplos/demo.craft

# Ejecutar un pase específico y guardar también el IR.
python3 compi/main.py --ir --reorder --artifact-tag reorder \
  compi/Defensa/P2/Reordenamiento.craft

python3 compi/main.py --ir --dce --artifact-tag dce \
  compi/Defensa/P2/pruebaEliminacionCodigo.craft
```

También están disponibles `--unroll`, `--unroll-factor N`,
`--rename-registers`, `--dce` y `--reorder`.

## Simulación con Icarus Verilog

Todos los comandos de esta sección se ejecutan desde `arqui/`, salvo que se use
`make -C arqui` desde la raíz.

### Usando Make

Compilar y ejecutar un testbench:

```bash
cd arqui
make run TOP=tb_alu
```

Ejecutar el procesador completo con una ROM y una RAM concretas:

```bash
make run TOP=tb_topG ROM=demo.hex RAM=data.hex
```

El Makefile realiza internamente:

1. La compilación de todos los módulos RTL y del testbench seleccionado con
   `iverilog -g2012`.
2. La creación de `sim/build/<testbench>.vvp`.
3. La ejecución mediante `vvp`.
4. La carga de `programs/<ROM>` y `programs/<RAM>` mediante *plusargs*.

Los parámetros principales son:

| Parámetro | Valor por defecto | Descripción |
|---|---|---|
| `TOP` | `tb_topG` | Testbench sin extensión `.sv` |
| `ROM` | `program.hex` | Archivo dentro de `arqui/programs/` |
| `RAM` | `data.hex` | Imagen inicial de memoria de datos |
| `MAX_CYCLES` | `20000` | Límite usado por algunos flujos |
| `VVP_FLAGS` | vacío | *Plusargs* adicionales para el testbench |

Ejemplo con generación de ondas y un límite mayor:

```bash
make run TOP=tb_topG ROM=factorial.hex \
  VVP_FLAGS="+VCD +MAX_CYCLES=300000"
```

### Usando Icarus Verilog directamente

El mismo flujo puede ejecutarse sin Make:

```bash
cd arqui
mkdir -p sim/build sim/waves outputs

iverilog -g2012 \
  -o sim/build/tb_alu.vvp \
  $(find rtl -type f -name '*.sv' | sort) \
  tb/tb_alu.sv

vvp sim/build/tb_alu.vvp
```

Para el procesador completo:

```bash
iverilog -g2012 \
  -o sim/build/tb_topG.vvp \
  $(find rtl -type f -name '*.sv' | sort) \
  tb/tb_topG.sv

vvp sim/build/tb_topG.vvp \
  +FILE_ROM=programs/bench_seq.hex \
  +FILE_RAM=programs/data.hex \
  +HALT_PC=F8 \
  +MAX_CYCLES=300000 \
  +TEST_NAME=bench_seq
```

`HALT_PC` es la dirección de la instrucción `freeze` de la ROM. La suite de
benchmarks la calcula automáticamente, por lo que para medir programas se
recomienda usar `scripts/benchmarks.py`.

### Formas de onda

Algunos testbenches generan un `.vcd` siempre; `tb_topG` lo hace únicamente si
recibe `+VCD`.

```bash
cd arqui
make run TOP=tb_topG ROM=bench_stride.hex VVP_FLAGS="+VCD"
make wave TOP=tb_topG
```

También existen vistas preparadas:

```bash
make wave-pipeline
make wave-datapath
make wave-hazard
make wave-mem
```

## Flujo completo: Craft a procesador

Este ejemplo compila un benchmark, copia su ROM y RAM al directorio consumido
por el hardware y lo ejecuta:

```bash
# Desde la raíz.
python3 compi/main.py -r -b -O0 arqui/programs/src/bench_seq.craft

cp compi/output/bin_output/bench_seq.hex arqui/programs/bench_seq_manual.hex

make -C arqui run TOP=tb_topG \
  ROM=bench_seq_manual.hex \
  RAM=data.hex \
  VVP_FLAGS="+TEST_NAME=bench_seq_manual +HALT_PC=F8 +MAX_CYCLES=300000 +EXPECT_X11=7F80"
```

Si el compilador genera un archivo `.data.hex`, debe copiarse también a
`arqui/programs/` y pasarse mediante `RAM=<archivo>.data.hex`. Para ejecuciones
verificadas se recomienda la suite de benchmarks, porque calcula `HALT_PC`,
establece el límite de ciclos y comprueba el resultado esperado.

## Benchmarks

La suite principal incluye:

| Benchmark | Patrón de acceso |
|---|---|
| `bench_seq` | Recorrido secuencial de 256 elementos |
| `bench_stride` | Accesos con stride de ocho elementos |
| `bench_random` | Accesos pseudoaleatorios sobre 480 elementos |
| `bench_mmul` | Multiplicación de matrices 8x8 |

Cada programa se compila con O0, O1, O2 y O3. La suite también ejecuta pruebas
dirigidas P2 para *unrolling*, renombrado, DCE y reordenamiento, y compara el
procesador con caché frente a la configuración sin caché.

### Suite completa

```bash
cd arqui
make bench BENCH_ARGS=--no-open
```

El target recompila las ROM principales y las pruebas P2 antes de medir.

### Un benchmark

```bash
cd arqui
make bench
```

```

### Métricas generadas

- Ciclos e instrucciones ejecutadas.
- CPI e IPC.
- Stalls de memoria y de control.
- Lecturas, escrituras, hits y misses de L1 y L2.
- AMAT.
- Accesos y ciclos de transferencia hacia memoria principal.
- Utilización temporal del bus de memoria.
- Tamaño de código y transformaciones aplicadas.
- Comparaciones con/sin caché y entre O0, O1, O2 y O3.

Resultados:

```text
arqui/outputs/reports/
├── results.html              # Reporte comparativo
├── results.csv               # Benchmarks principales
├── results_no_cash.csv       # Configuración sin caché
├── results_p2.csv            # Pruebas dirigidas de optimización
├── compile_stats.csv
└── compile_stats_p2.csv
```

El análisis escrito de las métricas está en
[`arqui/docs/analisis_rendimiento.md`](arqui/docs/analisis_rendimiento.md).

## Pruebas

Ejecutar todos los testbenches de primer nivel:

```bash
make -C arqui run-all
```

Ejecutar las pruebas unitarias del compilador:

```bash
python3 -m unittest discover -s compi/tests -p 'test_*.py'
```

Limpiar los binarios y ondas de simulación:

```bash
make -C arqui clean
```

## Script de acceso rápido

`run.sh` permite invocar los objetivos más comunes desde la raíz:

```bash
chmod +x run.sh

./run.sh list
./run.sh run tb_alu
./run.sh run tb_topG
./run.sh wave tb_alu
./run.sh all
./run.sh clean
```

Para ejecutar un programa y volcar el estado final:

```bash
./run.sh run tb_general_dump factorial.hex
```

Los dumps se escriben en `arqui/outputs/`.

## Craft Studio

La interfaz gráfica permite editar programas `.craft`, consultar diagnósticos,
usar autocompletado, seleccionar optimizaciones y revisar artefactos.

```bash
python3 -m pip install PySide6
python3 compi/IDE/main.py
```

La guía de la IDE está en [`compi/IDE/README.md`](compi/IDE/README.md).

## Documentación

- [ISA Craft21](arqui/docs/isa.md)
- [Microarquitectura](arqui/docs/microarchitecture.md)
- [Jerarquía de memoria](arqui/docs/jerarquia_memoria.md)
- [Simulación y formas de onda](arqui/docs/simulation.md)
- [Análisis de rendimiento](arqui/docs/analisis_rendimiento.md)
- [Compilador Craft](compi/README.md)
- [Representación intermedia](compi/IR/README.md)
- [Herramientas y demostración TEA](arqui/scripts/README.md)

## Problemas frecuentes

### `iverilog: command not found`

Instale Icarus Verilog y compruebe que `iverilog` y `vvp` estén en `PATH`.

### No se encuentra la ROM o la RAM

Los valores de `ROM` y `RAM` son nombres relativos a `arqui/programs/`:

```bash
make -C arqui run TOP=tb_topG ROM=demo.hex RAM=data.hex
```

### La simulación no termina

El programa debe contener una instrucción `freeze` y usar el `HALT_PC`
correcto. Para benchmarks, use `scripts/benchmarks.py`, que calcula esa
dirección automáticamente.

### No aparece el archivo VCD

Para `tb_topG` agregue `+VCD`:

```bash
make -C arqui run TOP=tb_topG ROM=demo.hex VVP_FLAGS="+VCD"
```

### GTKWave no abre

La simulación puede ejecutarse sin visor. El `.vcd` queda en
`arqui/sim/waves/` y puede abrirse posteriormente con GTKWave o Surfer.
