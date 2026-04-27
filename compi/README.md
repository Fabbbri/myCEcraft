# Estado del proyecto — Compilador myCEcraft

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
- pragmas `@inline` aplicados a funciones
- funciones: `craft:<tipo> nombre(<parametros>) { ... }`
- parámetros `nombre:<tipo>`
- tipos primitivos: `int`, `uint32`, `uint16`, `char`, `void`
- tipos compuestos: `pointer[<tipo>]`, `pointer`, `chest[<tipo>, <tamano>]`
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

### Convención de memoria actual

Como la arquitectura todavía está en desarrollo, se usa una convención inicial
compatible con la idea de usar `sp`/stack:

- funciones: segmento `TEXT`, dirección pendiente
- etiquetas de saltos: segmento `TEXT`, dirección pendiente
- parámetros: segmento `STACK`, offsets positivos desde `sp`/frame pointer
- variables locales: segmento `STACK`, offsets negativos
- variables globales: segmento `DATA`, desde `0x1000`

Las direcciones reales de funciones y etiquetas quedan sin resolver porque eso
depende de la generación de ensamblador y del conteo real de instrucciones. Esa
resolución corresponde a fases 4 y 5.

### Uso

```bash
python compi/main.py -m compi/demo.craft
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

### Uso

```bash
python compi/main.py -s compi/demo.craft
```

Opciones útiles:

- `-s` o `--asm`: genera el archivo `.asm` del programa de entrada.

---

## 5. Cálculo de saltos y resolución de referencias

N/A

---

## 6. Generación de código binario

N/A

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

### En progreso
- resolución real de direcciones de etiquetas

### Pendiente
- saltos y referencias
- binario final

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
