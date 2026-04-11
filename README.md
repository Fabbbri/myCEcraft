# myCEcraft

Compilador académico para el curso **CE1108 | Compiladores e Intérpretes** del **Instituto Tecnológico de Costa Rica**.

El objetivo del proyecto es traducir código fuente escrito en un lenguaje diseñado por el grupo hacia **código binario ejecutable**, pasando por varias fases intermedias como análisis léxico, análisis sintáctico, análisis semántico, generación de ensamblador y generación de binario. El proyecto también requiere definir una **arquitectura de computadora personalizada**, incluyendo tamaño de palabra, registros, memoria y conjunto de instrucciones. 


## Integrantes:
1. Jafet Diaz Morales
2. Fabricio González Cerdas
3. Jian Zheng Wu

## Estado del proyecto

Este repositorio contiene la implementación en desarrollo del compilador del lenguaje **myCEcraft**.

Actualmente, el proyecto se enfoca en construir de forma incremental las fases del compilador:

- Análisis léxico
- Análisis sintáctico
- Análisis semántico y tabla de símbolos
- Generación de ensamblador
- Resolución de referencias y saltos
- Generación de código binario

## Características del lenguaje

El lenguaje diseñado por el grupo incluye, entre otros, los siguientes elementos:

### Palabras reservadas
- `if`
- `else`
- `while`
- `for`
- `return`
- `craft`
- `summon`
- `invoke`
- `as`

### Tipos soportados
- `int`
- `uint32`
- `uint16`
- `char`
- `void`
- `pointer[...]`
- `chest[...]`

### Comentarios
```txt
// comentario de una línea

/* comentario
   de múltiples líneas */