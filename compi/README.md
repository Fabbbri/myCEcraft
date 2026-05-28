# Estado del proyecto — Compilador myCEcraft

## Guía de uso.
- Imprimir análisis lexico
```bash
python3 compi/main.py --tokens compi/ejemplos/demo.craft
```

- Imprimir análisis sintáctico
```bash
python3 compi/main.py -t compi/ejemplos/demo.craft
```
- Guardar AST en `compi/output/ast/<archivo>.ast.txt`
```bash
python3 compi/main.py --ast compi/ejemplos/demo.craft
```

- Guardar tabla de simbolos con referencias sin resolver en `compi/output/symbols/<archivo>.symbols.txt`:
```bash
python3 compi/main.py -m compi/ejemplos/demo.craft
```

- Generar ensamblador sin resolver y resuelto:
```bash
python3 compi/main.py -r compi/ejemplos/demo.craft
```

- Generar ensamblador resuelto y guardar la tabla de simbolos actualizada con listado de labels:
```bash
python3 compi/main.py -m -r -b compi/ejemplos/demo.craft
```

- Generar ensamblador resuelto, no resuelto y.bin, .hex, y .lst 
```bash
python3 compi/main.py -r -b compi/ejemplos/demo.craft
```

## Imports (invoke) expandido

Cuando un archivo contiene `invoke`, el compilador hace una expansion simple
antes de compilar:

- Crea un nuevo archivo combinado en `compi/expanded/` con sufijo `.expanded.craft`.
- Inserta el contenido de los modulos importados al inicio del archivo.
- Elimina los `invoke` del archivo combinado.
- Reescribe llamadas `summon:alias.func(...)` a `summon:func(...)`.
- Si el archivo principal tiene `@EnterCraftWorld`, se conserva en el archivo
  expandido (una sola vez).
- Soporta imports anidados y evita ciclos (un modulo ya importado no se repite).

Ejemplo:

```craft
@EnterCraftWorld
invoke "mod_a" as a;

craft:int main() {
    return summon:a.suma2(3);
}
```

El archivo expandido se genera como:

```
compi/output/expanded/<archivo>.expanded.craft
```

## Tabla de simbolos: variables en STACK

Para variables locales en `STACK`, la tabla no muestra una direccion absoluta
del dump final. Muestra la direccion efectiva como expresion de runtime basada
en el `fp` de la funcion activa. Por ejemplo, si en ensamblador se ve:

```riscv
lw x3, -4(x17) ; x
```

`x17` es el `fp` (frame pointer). En la tabla se imprime como
`runtime(x17-4)`, porque esa direccion solo se puede resolver mientras la
funcion esta activa. Despues del epilogo, el `fp` se restaura y el dump final no
permite asociar de forma confiable esa variable local con una direccion unica.


## 1. Análisis léxico

### Estado actual
La fase de análisis léxico está **implementada y funcional**.

Actualmente el lexer reconoce correctamente:

- **Palabras reservadas**:
  - `if`, `else`, `while`, `for`, `return`
  - `craft`, `summon`, `invoke`, `as`
- **Tipos**:
  - `int`, `uint32`, `uint16`, `char`, `void`, `pointer`, `chest`
- **Pragmas**:
  - `@EnterCraftWorld`
  - `@inline`
- **Literales**:
  - enteros decimales
  - enteros hexadecimales
  - cadenas de texto
- **Operadores**:
  - aritméticos: `+`, `-`, `*`, `/`
  - desplazamiento: `<<`, `>>`
  - relacionales: `==`, `!=`, `<`, `>`, `<=`, `>=`
  - bit a bit: `^`, `&`, `|`, `~`
  - especiales del lenguaje: `<+4`, `>+5`
  - asignación: `=`
- **Delimitadores y separadores**:
  - `;`, `{`, `}`, `(`, `)`, `[`, `]`, `,`, `:`, `.`
- **Comentarios**:
  - una línea: `//`
  - multilínea: `/* ... */`

Además:
- ignora correctamente espacios en blanco y comentarios
- genera un token `EOF` al final
- lleva control de **línea y columna**
- clasifica identificadores como keywords o tipos cuando corresponde

### Casos que sí funcionan
Se probó correctamente con ejemplos como:

- `invoke "matematica" as m;`
- `x:int = summon:m.suma(3, 5);`
- `key:chest[uint32,4] = [0x0, 0x0, 0x0, 0x0];`
- expresiones con `<+4` y `>+5`

### Errores léxicos que ya detecta
Actualmente detecta y reporta:

- símbolo no reconocido
- cadena sin cerrar
- comentario multilínea sin cerrar

### Decisión importante tomada
Se corrigió la responsabilidad del lexer para que:

- `craftft` se reconozca como **identificador válido**
y no como error léxico

Eso se dejó así porque ese tipo de problema pertenece al **análisis sintáctico**, no al léxico.

### Qué falta en esta fase
La base del lexer ya está bastante bien para continuar.

Pendientes opcionales de mejora:

- mejorar aún más los mensajes de error

---

## 2. Análisis sintáctico

### Estado actual
La fase de análisis sintáctico está **implementada**.

El parser toma la lista de tokens generada por el lexer, valida la estructura
del programa y construye un AST imprimible.

Actualmente reconoce:

- imports: `invoke "modulo" as alias;`
- pragma obligatorio de archivo: `@EnterCraftWorld`
- pragmas `@inline` aplicados a funciones
- funciones: `craft:<tipo> nombre(<parametros>) { ... }`
- parámetros `nombre:<tipo>`
- tipos primitivos: `int`, `uint32`, `uint16`, `char`, `void`
- tipos compuestos: `pointer[<tipo>]`, `pointer`, `chest[<tipo>, <tamano>]`
- tipo especial de bóveda: `chest[ender, <tamano>]`
- declaraciones de variables: `nombre:<tipo> = <expresion>;`
- asignaciones: `nombre = <expresion>;` y `arreglo[i] = <expresion>;`
- bloques `{ ... }`
- `if` / `else if` / `else`
- `while`
- `for`
- `return;` y `return <expresion>;`
- llamadas con `summon:nombre(...)` y `summon:alias.nombre(...)`
- literales enteros, hexadecimales, strings y arreglos `[ ... ]`
- acceso a arreglos: `arr[i]`
- expresiones aritméticas, relacionales, bit a bit y especiales `<+4`, `>+5`

### Uso

```bash
python compi/main.py -t compi/demo.craft
```

Opciones útiles:

- `-t` o `--ast`: imprime el AST.
- `--tokens` o `-l`: imprime la lista de tokens antes del análisis sintáctico.

Si no se indica ninguna opción, el compilador realiza lexer + parser y reporta
que el análisis sintáctico terminó correctamente.

### Errores sintácticos que detecta

Actualmente detecta errores básicos como:

- falta de `;`
- falta de `)`, `]` o `}`
- pragmas `@inline` fuera de funciones
- tipos mal formados
- llamadas `summon` incompletas
- asignaciones con lado izquierdo no asignable

---

## 3. Análisis semántico

### Estado actual
La fase de análisis semántico inicial está **implementada**.

El analizador semántico recorre el AST generado por el parser y construye la
tabla de símbolos con scopes, tipos y memoria preliminar.

Actualmente realiza:

- registro de imports como aliases de módulo
- registro de funciones en el scope global
- registro de parámetros dentro del scope de cada función
- registro de variables globales, locales y de ciclos
- validación de redeclaraciones dentro del mismo scope
- validación básica de variables usadas antes de declararse
- validación básica de llamadas a funciones locales
- validación de aliases usados en llamadas tipo `summon:alias.funcion(...)`
- inferencia básica de tipos en literales, expresiones, arreglos e índices
- asignación preliminar de memoria
- registro de etiquetas simbólicas para `if`, `while` y `for`
- asignación de variables `chest[ender, N]` al segmento `VAULT`

### Convención de memoria actual

Como la arquitectura todavía está en desarrollo, se usa una convención inicial
compatible con la idea de usar `sp`/stack:

- funciones: segmento `TEXT`, dirección pendiente
- etiquetas de saltos: segmento `TEXT`, dirección pendiente
- parámetros: segmento `STACK`, offsets negativos desde el frame pointer
- variables locales: segmento `STACK`, offsets negativos desde el frame pointer
- variables globales: segmento `DATA`, desde `0x8000`
- variables de bóveda: segmento `VAULT`, offsets desde `v0`

Las direcciones reales de funciones y etiquetas quedan sin resolver porque eso
depende de la generación de ensamblador y del conteo real de instrucciones. Esa
resolución corresponde a fases 4 y 5.

### Uso

```bash
python compi/main.py -m compi/demo.craft
```

### Ver la tabla de símbolos al final (junto con binario)

Si querés generar el binario y además ver la tabla de símbolos al final de la ejecución,
usá `-m/--symbols` junto con `-o`:

```bash
python compi/main.py -m -o compi/demo.bin compi/demo.craft
```

Esto genera:
- `compi/output/symbols/<archivo>.symbols.txt` con la tabla en texto monoespaciado.
- la salida habitual de generación (`.hex`, `.bin`, `.lst`), y
- el dump de la tabla de símbolos (scopes + símbolos + memoria).

### Ver direcciones resueltas de labels y funciones

Las direcciones reales de `TEXT` (labels de saltos y entradas de función) dependen del
conteo real de instrucciones en el ensamblador. Para ver esas direcciones, agregá `-r/--resolve`:

```bash
python compi/main.py -m -r -o compi/demo.bin compi/demo.craft
```

Con `-m -r` el compilador:
- imprime un bloque `=== Labels resueltas (.text) ===` con `pc=0x....`, y
- marca en la tabla de símbolos las `LABEL`/funciones que aparezcan en el `.text` con `addr=0x....`.

Tip: si querés guardarlo en un archivo de texto:

```bash
python compi/main.py -m -r -o compi/demo.bin compi/demo.craft > compi/demo.symbols.txt
```

Opciones útiles:

- `-m` o `--symbols`: imprime scopes, símbolos, tipos y memoria.
- `-t` o `--ast`: imprime el AST.
- `--tokens` o `-l`: imprime tokens.

Si no se indica ninguna opción, el compilador realiza lexer + parser + análisis
semántico y reporta que terminó correctamente.

---

## 4. Generación de ensamblador

### Estado actual
La fase de generación de ensamblador está implementada.

En esta fase, el compilador traduce el código fuente a ensamblador para la
arquitectura definida.

Actualmente esta fase:

- genera instrucciones de ensamblador para asignaciones y operaciones
  aritméticas/lógicas
- genera saltos condicionales e incondicionales para estructuras de control
  (`if`, `while`, `for`)
- genera código para llamadas a función, paso de parámetros y retorno de valores
- mantiene un contador de instrucciones para calcular direcciones de memoria
- inicializa variables `chest[ender, N]` usando instrucciones de bóveda

Ejemplo de bóveda:

```craft
@EnterCraftWorld
craft:int main() {
    enderopen x3;
    key:chest[ender, 4] = [2332323, 1234, 13234, 124];
    enderlow v2, v0, 0x1234;
    enderhigh v2, v2, 0xABCD;
    enderkey v2, v1;
    enderload v3, 0(v0);
    enderstore v3, 4(v0);
    enderclose;
    return 0;
}
```

`chest[ender, N]` puede usar cualquier nombre de variable y cualquier lista de
literales numericos compatible con su tamaño. Los valores del ejemplo no son
fijos.

Las instrucciones explícitas de bóveda disponibles son:

| Keyword | Ensamblador generado |
|---|---|
| `enderopen a;` | `portalv a, v0, 0` |
| `enderopen a, off;` | `portalv a, v0, off` |
| `enderclose;` | `closev` |
| `enderload dst, off(base);` | `lwv dst, off(base)` |
| `enderstore src, off(base);` | `swv src, off(base)` |
| `enderkey dst, src;` | `changev dst, src` |
| `enderlow dst, base, imm;` | `addiLOWv dst, base, imm` |
| `enderhigh dst, base, imm;` | `addiHIGHv dst, base, imm` |
| `enderPortal(clave);` | carga la clave y emite `portalv clave, v0, 0` |
| `enderPortal(clave): ... endchange` | carga la clave y emite `portalv clave, v0, offset a endchange` |
| `enderchange(num)` | divide `num` en low/high y emite `changev v0, low, high` + `swv` |
| `enderclose` | `closev` |

Todo archivo `.craft` debe incluir `@EnterCraftWorld`. El generador emite al
inicio de `.text`:

```asm
portalv x0, x0, enderExit
lwv v0, 0(v0)
enderExit:
```

Para inicializar arreglos de bóveda, el programador no tiene que escribir
`enderlow`/`enderhigh` manualmente. El compilador traduce:

```craft
key:chest[ender, 4] = [1, 2, 3, 4];
```

a instrucciones como:

```asm
addiLOWv v1, v0, ...
addiHIGHv v1, v1, ...
swv v1, 0(v0)
```

### Uso

```bash
python compi/main.py -s compi/demo.craft
```

Opciones útiles:

- `-s` o `--asm`: genera el archivo `.asm` del programa de entrada.
- `-O0`: no aplica optimizaciones.
- `-O1`, `-O` o `--optimize`: activa loop unrolling y renombramiento de registros.
- `-O2`: perfil reservado; por ahora no aplica optimizaciones.
- `--unroll-factor N`: aplica loop unrolling con factor configurable.
- `--rename-registers`: activa solo el renombramiento de registros estaticos en IR.
- Los artefactos generados por defecto se escriben en `output/`.

### Optimizaciones de iteracion 3

Con `-O1`, `-O` o `--optimize`, el compilador aplica solamente:

- **Loop unrolling sobre IR**. La pasada trabaja sobre instrucciones
  `IRInstruction` ya generadas. Para loops contados con inicio, limite e
  incremento constantes, usa el estilo clasico: aumenta el stride por el factor,
  sustituye `i`, `i + 1`, etc. en las copias del cuerpo y emite el remainder
  despues del loop. Si el factor es mayor que las iteraciones conocidas,
  reporta un error de optimizacion.
- **Renombramiento de registros estaticos en IR**. La pasada renombra
  temporales `tN` usando los registros temporales definidos para Craft21
  (`x3` a `x10`). Esto permite mostrar como se reducen dependencias falsas
  WAR/WAW sin inventar registros que no existen en la arquitectura.

Ademas, cuando se aplica loop unrolling con `-i`, se genera una vista fuente en:

```text
compi/output/optimized/<archivo>.O1.craft
```

Esa vista `.craft` es para demostracion. La transformacion que usa el compilador
para optimizar y construir los bloques basicos se aplica sobre el IR.

Ejemplos:

```bash
python compi/main.py -O1 -i compi/ejemplos/demo.craft
python compi/main.py --unroll-factor 4 -i compi/ejemplos/array_unrolling_demo.craft
python compi/main.py --unroll-factor 4 --rename-registers -i compi/ejemplos/array_unrolling_demo.craft
```

---

## 5. Cálculo de saltos y resolución de referencias

### Estado actual
La fase de cálculo de saltos y resolución de referencias está implementada en
una primera versión.

Esta fase toma el ensamblador generado en fase 4 y realiza dos pasadas:

- identifica etiquetas del segmento `.text` y las asocia con su dirección `pc`
- reemplaza referencias simbólicas en saltos por offsets relativos en bytes
- valida que los offsets estén alineados a 4 bytes
- valida rangos de salto para instrucciones tipo `B` y `J`
- conserva comentarios con la etiqueta original y la dirección destino

La convención usada actualmente es:

```text
offset = target_pc - current_pc
```

### Uso

```bash
python compi/main.py -r compi/demo.craft
```

Esto genera:

- `demo.asm`: ensamblador de fase 4
- `demo.resolved.asm`: ensamblador con saltos y referencias resueltas

También se puede combinar con `-s`:

```bash
python compi/main.py -s -r compi/demo.craft
```

Ejemplo de transformación:

```asm
bge x3, x4, .L_codegen_2_while_end
```

pasa a:

```asm
bge x3, x4, 24 ; target=.L_codegen_2_while_end ; addr=0x0038
```

---

## 6. Generación de código binario

### Estado actual
La fase de generación de código binario está implementada en una primera
versión para instrucciones del segmento `.text`.

Esta fase toma el ensamblador con referencias resueltas de fase 5 y codifica
cada instrucción en una palabra de 32 bits según los formatos definidos para
Craft21.

Actualmente soporta:

- instrucciones tipo `R`: `add`, `sub`, `sll`, `slt`, `xor`, `srl`, `sra`,
  `or`, `and`, `mul`, `div`, `sleep`, `freeze`
- instrucciones tipo `I`: `addi`, `addiHIGH`, `addiSigned`
- instrucciones tipo `S`: `sw`, `lw`, `sb`, `lb`
- instrucciones tipo `J`: `jal`, `jalr`
- instrucciones tipo `B`: `beq`, `bne`, `blt`, `bge`, `portalv`

### Uso

```bash
python compi/main.py compi/demo.craft -o compi/demo.bin
```

Esto genera:

- `demo.bin`: imagen binaria completa con encabezado, `.text` y `.data`
- `demo.hex`: una instrucción hexadecimal de 32 bits por línea
- `demo.data.hex`: datos iniciales en bytes, si el programa tiene `.data`
- `demo.lst`: listado legible con encabezado, PC, hexadecimal, instrucciones y datos

Si se omite `-o`, también se puede generar binario con el alias `-b`:

```bash
python compi/main.py -b compi/demo.craft
```

En ese caso se usa el nombre del archivo fuente con extensión `.bin`.

Para generar ensamblador además del binario:

```bash
python compi/main.py -s compi/demo.craft -o compi/demo.bin
```

Para guardar también el ensamblador con referencias resueltas:

```bash
python compi/main.py -r compi/demo.craft -o compi/demo.bin
```

El archivo `.hex` está pensado para cargarse con `$readmemh`, como en
`instr_rom.sv`. El archivo `.bin` usa este encabezado big-endian:

```text
magic             4 bytes  "MYCE"
version           2 bytes
header_size       2 bytes
entry_point       4 bytes
text_offset       4 bytes
text_size         4 bytes
data_offset       4 bytes
data_size         4 bytes
text_base         4 bytes
data_base         4 bytes
instruction_count 4 bytes
flags             4 bytes
```

Después del encabezado vienen las instrucciones codificadas en palabras de
32 bits y luego los datos globales iniciales. Los datos se empaquetan en orden
little-endian para que coincidan con `data_ram.sv`, donde el byte bajo vive en
la dirección menor.

### Alcance actual

La versión actual empaqueta instrucciones y datos globales iniciales. El
encabezado ya describe dónde empieza y cuánto mide cada sección.

### Cargar `.hex` en la ROM de arquitectura

La arquitectura actual no carga directamente el contenedor `.bin`. El módulo
`instr_rom.sv` carga instrucciones desde:

```systemverilog
$readmemh("programs/program.hex", memory);
```

Por eso, para probar un programa compilado en la ROM se debe copiar el `.hex`
generado por el compilador a `arqui/programs/program.hex`.

Ejemplo con un programa sin datos globales:

```powershell
python compi/main.py compi/demo.craft -o compi/demo.bin
New-Item -ItemType Directory -Force arqui/programs
Copy-Item compi/demo.hex arqui/programs/program.hex
Set-Content -NoNewline arqui/programs/data.hex ""
```

Ejemplo con un programa que sí genera `.data`, como `tea.craft`:

```powershell
python compi/main.py compi/tea.craft -o compi/tea.bin
New-Item -ItemType Directory -Force arqui/programs
Copy-Item compi/tea.hex arqui/programs/program.hex
Copy-Item compi/tea.data.hex arqui/programs/data.hex
```

Luego se puede correr el testbench de ROM desde `arqui`:

```powershell
cd arqui
make run TOP=tb_instr_rom
```

O desde la raíz del repositorio en un entorno tipo Bash:

```bash
./run.sh run tb_instr_rom
```

Para verificar manualmente, la primera línea de `program.hex` debe aparecer en
la salida `instr` cuando `addr = 0`, la segunda línea cuando `addr = 4`, y así
sucesivamente.

---

## 7. Estado general del proyecto

### Completado o bien encaminado
- especificación general del lenguaje
- tabla de tokens
- regex del lexer
- lexer funcional
- parser sintáctico
- construcción e impresión del AST
- análisis semántico inicial
- tabla de símbolos con scopes
- asignación preliminar de memoria para stack/data/text
- generación de ensamblador (fase 4)
- cálculo de saltos y resolución de referencias (fase 5)
- generación inicial de código binario para instrucciones (fase 6)

### En progreso
- integración directa del binario final con la memoria de instrucciones/datos

### Pendiente
- cargador/simulador que consuma directamente el contenedor `.bin`

---

# Tabla de símbolos

La tabla de símbolos es una estructura del compilador que guarda información semántica sobre los identificadores del programa. No trabaja a nivel de caracteres como el lexer, sino a nivel de entidades del lenguaje, por ejemplo variables, funciones, parámetros, aliases de módulos y etiquetas.

## ¿Para qué sirve?

Su objetivo es permitir que el compilador responda preguntas como estas:

- si un identificador ya fue declarado
- en qué ámbito fue declarado
- qué tipo tiene
- si una referencia es válida desde el bloque actual
- si más adelante debe reservar memoria para ese símbolo

## Qué guarda cada símbolo

Cada entrada de la tabla de símbolos suele almacenar:

- nombre del símbolo
- clase del símbolo (`VARIABLE`, `FUNCTION`, `PARAMETER`, etc.)
- tipo (`int`, `uint32`, `pointer[char]`, `chest[int, 10]`, etc.)
- archivo, línea y columna de declaración
- ámbito al que pertenece
- información adicional, como parámetros de una función o datos de memoria futuros

## Ámbitos

La tabla de símbolos no es una sola lista plana. Se organiza en **scopes** o ámbitos.

Ejemplos de ámbitos:

- global
- función
- bloque
- ciclo
- condicional

Cada ámbito puede tener un ámbito padre. Entonces, cuando el compilador busca un nombre, primero revisa el ámbito actual y luego sube hacia los padres hasta llegar al global.

## Operaciones básicas

Las operaciones principales son:

- `define`: registrar un símbolo en el ámbito actual
- `lookup_local`: buscar solo en el ámbito actual
- `lookup`: buscar en el ámbito actual y en sus padres
- `enter_scope`: entrar a un nuevo ámbito
- `exit_scope`: salir del ámbito actual

## Relación con el proyecto

En este proyecto, la tabla de símbolos será importante para:

- registrar variables globales y locales
- registrar funciones y sus parámetros
- manejar imports con alias
- detectar redeclaraciones
- validar usos de identificadores
- preparar la información que luego se usará para memoria, saltos y generación de código

## Idea clave

El lexer reconoce tokens, pero la tabla de símbolos registra significado. Por eso normalmente se llena durante el parser o en la fase semántica, no directamente durante el análisis léxico.
