# Representación Intermedia (IR) y Bloques Básicos

Este directorio contiene la implementación de la Fase de Representación Intermedia del compilador `myCEcraft`. Esta fase se encarga de disminuir drásticamente la complejidad del AST (Abstract Syntax Tree) transformándolo en un lenguaje plano, lineal y de muy bajo nivel denominado **Código de Tres Direcciones (3AC)**. Además, agrupa estas instrucciones en **Bloques Básicos** y construye el **Control Flow Graph (Grafo de Flujo de Control - CFG)**.

Este paso intermedio es obligatorio según los requisitos para preparar el terreno hacia las optimizaciones de código, antes de la generación final del lenguaje ensamblador de la arquitectura objetivo.

## Estructura de Archivos

- `instructions.py`: Define el "nuevo lenguaje". Contiene las declaraciones de clases de datos (DataClasses) que conforman el conjunto de instrucciones de Tres Direcciones (`IRBinOp`, `IRAssign`, `IRJump`, etc.).
- `ir_generator.py`: Funciona como el traductor que recorre o "visita" el AST crudo y emite secuencialmente la lista plana de instrucciones IR `instructions.py` desarmando anidaciones mediante saltos explícitos y variables temporales infinitas.
- `basic_blocks.py`: Analizador que toma la lista total del IR y la divide lógicamente en **Bloques Básicos** según las reglas de terminación (saltos, returns) y entrada (etiquetas), construyendo el grafo final (CFG) que expone los predecesores y sucesores de cada trozo de código.

---

##  1. Código de Tres Direcciones (3AC)

El código generado en el IR se denomina "de tres direcciones" porque cada instrucción puede tener, a lo sumo, tres operandos (generalmente dos parámetros origen y un destino). Para lograr esto, se "aplastan" las grandes expresiones del AST apoyándose en la creación de múltiples temporales (`t0`, `t1`, `t2`...).

### Ejemplo de aplanamiento

**Código `.craft` Original (AST Complejo):**
```craft
x = (a + 5) * b;
```

**Resultado en Representación Intermedia (IR):**
```text
t0 = a + 5
t1 = t0 * b
x = t1
```
*(Nota: El IR destruye también las llaves y ámbitos anidados usando `Jump` y `JumpIfFalse` explícitos anclados a `Labels`, idéntico a cómo funciona el silicio subyacente.)*

---

##  2. Bloques Básicos e Identificación

A partir del código lineal de la etapa anterior, el sistema debe organizar las instrucciones para su optimización. Esta tarea es manejada por el `ControlFlowGraph` en `basic_blocks.py`.

Un **Bloque Básico** es un pedazo ininterrumpido de código. Si la ejecución del bloque inicia en la primera instrucción, está garantizado matemáticamente que se ejecutarán todas sus líneas hasta llegar a la última, sin bifurcaciones o saltos internos.

### Reglas de división aplicadas:
1. El destino de cualquier salto (es decir, un `Label` o inicio de función) **siempre define el comienzo de un nuevo bloque**.  
2. Un salto (`Jump`/`JumpIfFalse`) o retorno (`Return`) **siempre cierra y termina el bloque actual.**  
3. Cualquier otra instrucción es anexada secuencialmente al bloque vigente.

### Control Flow Graph (CFG)
Luego de la segmentación en bloques aislados, el analizador verifica las últimas instrucciones de cada bloque para trazar líneas (aristas) conectándolos a nivel lógico. 
- Si un bloque termina en condicional (IfFalse), se bifurca apuntando como sucesor tanto a la etiqueta destino como a el bloque que le sigue físicamente (caída o "fallthrough").
- Si termina en incondicional, conecta directo al macro destino.
- Si no tiene saltos, conecta simplemente al siguiente bloque.

**Reporte generado por el compilador:**
```text
[B_label_L_end_if_9]
  -> Sucesores: B_label_L_while_start_4
  L_end_if_9:
    t20 = suma < 100
    seguir = t20
    goto L_while_start_4
```
*Se muestra cómo la estructura aisló las tres instrucciones en un bloque con un estado claro, y determinó automáticamente sus bloques vecinos, construyendo el diagrama que será navegado durante la Fase de Optimización.*

---

##  Uso e Invocación

Se integró un flag paramétrico explícito en la CLI del compilador `main.py` para invocar visualmente esta etapa sin obligar a la generación completa de los binarios:

```bash
python compi/main.py -i <archivo.craft>
o bien:
python compi/main.py --ir <archivo.craft>
```

Esta ejecución dejará un registro volcado con las dos etapas completadas (IR Crudo en la parte superior y Reporte Detallado de Bloques CFG en la parte inferior) en la ruta por defecto:
`compi/output/ir/`
