# Arquitectura Craft21: MyCECraft

Este programa muestra la arquitectura Craft21 para el proyecto Compilador-Procesador MyCECraft. El procesador está realizado en SystemVerilog utilizando IcarusVerilog y GTKWave o Surfer (en ambiente IOS (Apple Silicon)).

## Archivos

Por editar...\

- `chacha20_c.c`: Programa principal en C. 
- `startup.s`: Código de inicio que configura la pila y llama a main(). Los programas C necesitan inicialización antes de ejecutar main()
- `chacha20_asm.s`: Función en ensamblador que realiza el cifrado Chacha20 siguiendo las convenciones de llamada RISC-V
- `linker.ld`: Script de enlazado que define la memoria y punto de entrada
- `build.sh`: Script de compilación
- `run-qemu.sh`: Script para ejecutar QEMU

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

## Comandos útiles de Makefile
```bash
# Estando en la raíz
chmod +x run-arqui.sh # la primera vez 

./run-arqui.sh
```