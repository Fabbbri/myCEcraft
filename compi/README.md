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

N/A

---

## 3. Análisis semántico

N/A

---

## 4. Generación de ensamblador

N/A

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

### En progreso
- implementación del parser
- definición de la gramática mínima inicial
- construcción progresiva del AST

### Pendiente
- parser completo
- análisis semántico
- tabla de símbolos
- ensamblador
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