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

### `programs/` - Programas de prueba 

Contiene todos los programas que serán ejecutados por la CPU:

```
programs/
├── sum.s
├── fibonacci.s
├── test1.hex
├── test2.mem
```

### `scripts/` - Automatización

Cualquier script en python que ayude a facilitar el flujo de trabajo:

```
scripts/
├── assemble.py
├── generate_mem.py
├── run_tests.py
```

## Funcionalidad

### Programa en C (`chacha20_c.c`)

Por editar ...
- Función principal que llama a la función `chacha_encrypt` en ensamblador.
- Funciones básicas para imprimir texto, hexadecimales y números, memcpy
- Función `main` llama a TODOS los tests (vectores de prueba de RFC) para el algoritmo de cifrado ChaCha20 y les hace print.
- Función `encrypt_personal` para utilizar un texto (string) cualquiera y cifrarlo utilizando un `key , nonce seriales` y un counter. Devuelve el texto encriptado y desencriptado.

### Código de inicio (`startup.s`)
...

Para mas informacion de las funciones consultar :
- [`chacha20/c-asm/DOCUMENTACION.md`](/chacha20/c-asm/DOCUMENTACION.md) - Documentacion de Chacha20 en C + ASM

## Requisitos previos

Es necesario para compilar y ejecutar este proyecto tener docker (en un entorno Linux)

```bash
# En linux
sudo apt install -y docker.io
```

También se debe instalar: `riscv64-unknown-elf-gcc`, `qemu-riscv64`, `gdb`.

Además se recomienda instalar el compilador de C `gcc`. Finalmente, puede ser útil instalar python si desea ver la impementación en python (aspecto no concluido EXTRA al proyecto).

Si va a clonar el repositorio, debe tener `git`

## Compilación y ejecución

```bash
# En la raiz
chmod +x run.sh
./run.sh

# Navegar a la carpeta c-asm con c
cd chacha20/c-asm

# Compilar
./build.sh

# Ejecutar con QEMU (en una terminal)
./run-qemu.sh

# En otra terminal, conectar GDB
docker exec -it rvqemu /bin/bash
cd /home/rvqemu-dev/workspace/chacha20/c-asm
gdb-multiarch chacha20.elf
```

## Inicio rápido QEMU-GDB
```bash
# En la raiz
chmod +x run.sh # la primera vez 
chmod +x chacha-qemu.sh # la primera vez 

./run.sh
# dos opciones:
./chacha-qemu.sh # 1) si desea compilar otra vez
./run-qemu.sh # 2) si desea correr el archivo ya existente

# En otra terminal, conectar GDB
chmod +x chacha-gdb.sh # la primera vez
./chacha-gdb.sh
```

## Convenciones de llamada Craft21

- `a0`: Primer parámetro de entrada y valor de retorno
- `a1-a7`: Parámetros adicionales
- `s0-s11`: Registros salvados (preserved)
- `t0-t6`: Registros temporales
- `ra`: Dirección de retorno
- `sp`: Puntero de pila

La función assembly respeta estas convenciones:
1. Guarda registros que modifica en la pila
2. Recibe parámetro en `a0` u otros `a`
3. Devuelve resultado en `a0` u otros `a`
4. Restaura registros `s` antes de retornar

## Comandos útiles de Git 

Las ramas son de tipo feature, fix o docs.
Los commits son de tipo feat, fix, test, doc, refacture

```git
git checkout <rama_existente>

git checkout -b <tipo>/<nombre_nueva_rama>

git commit -m "<tipo>(): <descripcion>"

# Desde la rama develop/main por ejemplo:
git merge --no-ff <nombre_rama>

# Despues de editar el mensaje:
# Presionar ESC
# Escribir 
:wq # significa write y quit

# Eliminar rama local
git push origin --delete <nombre_rama>

# Eliminar rama remota
git branch -d <nombre_rama>
```

## Comandos útiles para probar la arquitectura
```bash
# Estando en la raíz
chmod +x run.sh # la primera vez 

./run.sh
```