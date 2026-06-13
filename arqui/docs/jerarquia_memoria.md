# Arquitectura de la jerarquía de memoria

- **Integrantes:**
Jafet Díaz Morales,
Ana Melissa Vásquez Rojas,
Adrián González Jiménez,
Fabricio González Cerdas,
Jian Zheng Wu
- **Curso:** CE-4301 Arquitectura de Computadores I
- **Proyecto:** Análisis de Impacto de Memoria Caché y Optimizaciones de Compilador en la Organización de Procesador Propio tipo RISC
- **Profesor:** Dr. Ing. Jeferson González Gómez

---

## Tabla de contenidos

1. [Diagrama de la jerarquía L1/L2](#diagrama-de-la-jerarquía-l1l2)
2. [Caché L1: políticas de escritura, reemplazo y parámetros](#caché-l1-políticas-de-escritura-reemplazo-y-parámetros)
   - [Funcionamiento de caché L1-D con políticas elegidas](#funcionamiento-de-caché-l1-d-con-políticas-elegidas)
3. [Caché L2: políticas de escritura, reemplazo y parámetros](#caché-l2-políticas-de-escritura-reemplazo-y-parámetros)
   - [Funcionamiento de caché L2 unificado](#funcionamiento-de-caché-l2-unificado)
4. [Justificación técnica de políticas, reemplazo y parámetros configurables](#justificación-técnica-de-políticas-reemplazo-y-parámetros-configurables)
5. [Flujo de un acceso](#flujo-de-un-acceso)
6. [Integración con el pipeline del procesador](#integración-con-el-pipeline-del-procesador)
   - [Manejo de stalls de pipeline por misses](#manejo-de-stalls-de-pipeline-por-misses)
7. [Ordenamiento y coherencia](#ordenamiento-y-coherencia)
8. [Limitaciones conocidas](#limitaciones-conocidas)

---

Este documento describe el diseño de la jerarquia de cache de datos de Craft21
(Proyecto Grupal II), las decisiones de politica tomadas por el grupo y su
justificacion.

## Diagrama de la jerarquía L1/L2



La ROM de instrucciones es de acceso directo (1 ciclo, sin misses), por lo que
la jerarquia solo aplica a datos. La boveda (neather_ram) es un camino aparte
sin cache.

---

## Caché L1: políticas de escritura, reemplazo y parámetros

| Nivel | Tamaño | Asociatividad | Linea | Sets | Hit time |
|---|---|---|---|---|---|
| L1-D | 4 KB | 2-way | 32 B (8 palabras) | 64 | 1 ciclo (combinacional) |

### División de la dirección — L1

```
L1:  | tag 21b [31:11] | set 6b [10:5] | word 3b [4:2] | byte 2b [1:0] |
```

### Funcionamiento de caché L1-D con políticas elegidas

![image:con_l1](DF-L1Con.png)

---

## Caché L2: Decisiones de diseño, políticas de escritura, reemplazo y parámetros

### 1. Resumen

La caché L2 actúa como nivel de respaldo para la L1D. Su objetivo es absorber los misses de L1 antes de recurrir a la DRAM principal, reduciendo la penalización de latencia de acceso.

| Nivel | Tamaño | Asociatividad | Linea | Sets | Hit time |
|---|---|---|---|---|---|
| L2 | 16 KB | 4-way | 32 B | 128 | 8 ciclos (FSM) |
| RAM | 64 KB | — | burst de 8 palabras | — | ~25 ciclos del procesador |

- **Política de escritura:** El grupo definió Write Through, No-Write-Allocate.
- **Política de reemplazo:** El grupo definió FIFO.

### División de la dirección — L2

```
L2:  | tag 20b [31:12] | set 7b [11:5] | word 3b [4:2] | byte 2b [1:0] |
```
 
---
 
### 2. Parámetros Configurables
 
| Parámetro | Valor | Símbolo |
|---|---|---|
| Tamaño de línea | 256 bits (32 bytes) | `LINE_BITS = 256` |
| Número de conjuntos | 128 | `SETS = 128` |
| Asociatividad | 4 vías | `WAYS = 4` |
| Capacidad total | 128 × 4 × 32 B = **16 KB** | — |
| Bits de índice | 7 | `INDEX_BITS = 7` |
| Bits de offset (palabra) | 3 | `OFFSET_BITS = 3` |
| Bits de tag | 32 − 7 − 3 − 2 = **20** | `TAG_BITS = 20` |

#### Justificación de parámetros
 
En el enunciado del proyecto se indican los siguientes parámetros:

- **Tamaño:** 16 KB (4096 palabras de 32 bits, simulable en Icarus Verilog)
- **Asociatividad:** 4-way set associative
- **Tamaño de línea:** 32 bytes = 256 bits (8 palabras)

Por estas razones, como parte del diseño se decidieron obtener ciertos parametros importantes: 

```math
\#Sets = \frac{(\#Bloques)}{(\#Vías)} = \frac{512}{4} =  128
```
```math
\text{Bits de Sets} = n, \text{con } 2^n = \#Sets = 2^7= 128
```
```math
\text{Bits de Set} = n = 7 bits
```
```math
\text{Bits de Block Offset} = b, \text{con } 2^b = \#\text{Palabras por Bloque} = 2^3 = 8
```
```math
\text{Bits de Block Offset} = b = 3 bits
```

De esta forma, se obtuvo que:
- **Bits de Set:** 7
- **Bits de Block Offset:** 3
- **Bits de Byte Offset:** 2

La justificación de estos datos es puramente matemática y los valores no son arbitrarios sino la derivación de utilizar los valores solicitados por el enunciado. 

### 3. Política de Escritura
 
#### Decisión: Write-Through + No-Write-Allocate
 
```
En un store, si la dirección no está, entonces no es necesario:
  1. Se escribe directamente en DRAM (vía write buffer).
  2. Si hay hit en L2: se actualiza también el dato en L2.
  3. Si hay miss en L2: NO se asigna nueva línea (no-write-allocate).
```
 
#### Justificación técnica
 
**Write-through** fue elegido sobre write-back por las siguientes razones:
 
- **Simplifica la coherencia L1-L2:** Con write-through, L2 siempre contiene datos ≥ tan recientes como L1. No es necesario implementar un protocolo dirty-bit + writeback al desalojar líneas de L1, lo que simplifica la implementación y diseño.
- **Elimina el estado "dirty":** El bit `valid` es suficiente por línea; no se requiere bit `dirty`. Esto reduce el área del array de tags, simplifica la decodificación y reduce las variables necesarias a considerar en FSM del controlador.
- **Reduce la complejidad del reemplazo:** Al desalojar una línea de L2, nunca es necesario escribirla de vuelta a DRAM, porque DRAM ya tiene la versión actualizada.
- **Adecuado para el patrón de acceso del benchmark:** Se identificó que en general, los stores en los benchmarks de CRAFT21 son poco frecuentes comparados con los loads; el costo extra de write-through (latencia de store) no domina el CPI total. Además, se apuesta a que el principio de que si el dato no está, no necesita escribirse en L2 pero si en DRAM para mantener la coherencia.

**No-write-allocate** complementa write-through:
 
- Un store que produce miss en L2 es poco probable que sea seguido de un load a la misma dirección en el corto plazo (patrón write-only).
- Traer una línea completa solo para escribir un word desperdiciaría ancho de banda L2↔DRAM.
- Los stores drenan por el **write buffer** en background, sin bloquear el pipeline para fetches de instrucción.

#### Trade-off reconocido
 
Se es consciente de las desventajas de esta decisión técnica. Si el programa tiene muchos stores seguidos de loads a la misma región (write-then-read), no-write-allocate penaliza los loads subsiguientes. Para los benchmarks actuales esto no es el caso dominante, por lo que la política no representa un un problema significativo.
 
---
 
### 4. Política de Reemplazo
 
#### Decisión: FIFO (First-In, First-Out)
 
Cada conjunto de 4 vías mantiene un puntero de 2 bits (`fifo_ptr`) que indica la vía más antigua, es decir, la próxima en ser reemplazada. El puntero avanza en orden circular únicamente al cargar una nueva línea (miss); los hits no lo modifican.
 
```
Estado inicial:   fifo_ptr = 2'b00  (reemplazar W0 primero)
 
Secuencia de fills en un conjunto:
  Fill #1 → escribe W0, fifo_ptr ← 01
  Fill #2 → escribe W1, fifo_ptr ← 10
  Fill #3 → escribe W2, fifo_ptr ← 11
  Fill #4 → escribe W3, fifo_ptr ← 00  (ciclo completo)
  Fill #5 → escribe W0 (desaloja la línea más antigua), fifo_ptr ← 01
```
 
#### Justificación técnica
 
**Simplicidad de implementación:** FIFO requiere únicamente un contador de 2 bits por conjunto (`128 × 2 = 256 bits` en total para los punteros). No necesita comparadores de edad ni actualizaciones en cada hit, a diferencia de LRU. Además, es ventajoso por sobre una política Random puesto que sería más díficil y se considera ineficiente porque los benchmarks no presentan accesos aleatorios sino que se aplican conceptos de localidad espacial y temporal.
 
**Sin actualizaciones en hit:** A diferencia de LRU, un hit en L2 no modifica ningún estado de reemplazo. Esto reduce la complejidad del datapath de control en `l2_con.sv` — solo los misses (estados `FILL`) tocan `fifo_ptr`.
 
**Determinismo de simulación:** El orden de reemplazo es completamente predecible a partir de la secuencia de misses, lo que facilita la verificación del comportamiento con testbenches basados en `$readmemh` y contadores de ciclo.

**Costo de hardware:** Solo 256 bits adicionales de estado (los punteros), frente a los ~640 bits que requeriría LRU exacto con codificación de permutaciones para 4 vías.
 
#### Trade-off reconocido
 
FIFO es susceptible a la **anomalía de Bélády**: aumentar la asociatividad puede incrementar la tasa de misses para ciertos patrones de acceso cíclico. Sin embargo, con 4 vías y los patrones de acceso actuales de CRAFT21, este caso no se manifiesta mayoritariamente. Si se detectara degradación en futuros benchmarks con mayor localidad temporal, una migración a pseudo-LRU sería el siguiente paso natural.
 
---
 
## 5. Arquitectura de Control L2: Dos FSMs Independientes
 
`l2_con.sv` contiene dos máquinas de estado que operan en paralelo: una para loads y otra para el drenado del write buffer.
 
---
 
### 5.0 Flujo conceptual del controlador L2
 
El siguiente diagrama muestra el flujo de decisión de alto nivel del controlador. Es una vista conceptual — en el código real, las rutas se implementan mediante las dos FSMs descritas en 5.1 y 5.2.

![image:con_l2](DF-L2Con.png)

De este diagrama se pueden hacer ciertas aclaraciones:

En el camino de Store Miss se realiza no-write-allocate, solo se escriba en memoria. En el camino de Store Hit, se escribe en L2 y en Memoria. En el camino de Load Hit, se devuelve el dato usando offset de dirección. En el camino Load Miss ocurren varias cosas: 

1. Se activa `inv_en`, para lo cuál se utiliza el FIFO ptr para determinar la vía a reemplazar. 
2. Acceso a DRAM donde en el burst de 8 palabras se escribe la línea completa en un set de registros auxiliar (refill_regs). 
3. Se activa `fill_en` en el ciclo posterior a que `burst_count ==7` de forma tal que se escriba en la línea invalidad de L2 el dato del set de registros auxiliar. A su vez, se envía señal a L1 para que también haga refill.
4. Se actualiza el bit de validez. Se avanza el puntero del FIFO.
 
**Aclaraciones respecto al diagrama conceptual original:**
 
- **"Hit time 8 / ciclo 9 se vuelve a analizar":** En el código, esto corresponde a `load_cnt >= 7 && hit_l2` dentro de `ACCESS`. Los 8 ciclos son el hit-time fijo; el re-análisis es la evaluación de `hit_l2` en el último ciclo del contador antes de transicionar a `DONE`.
- **`inv_l2 = 0 (V=1 se mantiene)` en el path de hit:** El diagrama refleja que en un load hit, `inv_en` permanece desasertado (`inv_en` solo pulsa en la transición `IDLE→ACCESS` con `~hit_l2`). La línea válida no se toca.
- **"Devuelve línea completa a L1 a través del banco de registros":** En el código, esto es `fill_line` (acumulada en `refill_regs`) pasada como `fill_line_out` hacia `l2_cache` y de ahí propagada a `l1_con`. El write buffer de stores es independiente de este path.
- **STORE MISS / no-write-allocate:** El diagrama lo muestra como `we_l2 = 0`. En el código, un miss de store simplemente no activa `fill_en` ni `store_en` — el dato va directo al write buffer (`wb_push`) y de ahí a MEM vía `WB_COMMIT`.
---
 
### 5.1 FSM Load (`load_state`)

Se implementó la siguiente FSM:

```
      rq_empty=0 & wb_empty              load_cnt>=7 & hit_l2
          ┌──────────────────┐         ┌──────────────────────┐
          ▼                  │         │                       ▼
        IDLE ──────────────► ACCESS ───┤                     DONE ──► IDLE
                                       │                       ▲       (cuando ~burst_active)
                                       └──────────────────────►┘
                                          fill_en (miss: burst completo)
```
 
| Estado | Condición de salida | Descripción |
|---|---|---|
| `IDLE` | `!rq_empty && wb_empty` | Espera un load encolado; bloquea si el WB no está vacío (orden RAW) |
| `ACCESS` | `load_cnt >= 7 && hit_l2` → `DONE` | Hit: tiempo de acceso fijo de 8 ciclos (`load_cnt` 0→7) |
| `ACCESS` | `fill_en` → `DONE` | Miss: espera hasta que el burst de DRAM complete y `fill_en` se aserte |
| `DONE` | `~burst_active` → `IDLE` | Espera a que el burst termine antes de liberar la FSM |
 
El estado `ACCESS` no tiene un contador fijo para misses; en cambio espera la señal `fill_en`. Esto es necesario porque el burst de DRAM tiene latencia variable. Salir a ciclo fijo causaba que la FSM popeara el request antes de que el dato llegara a L2, generando loads duplicados cuyos bursts tardíos sobreescribían líneas válidas en L1.
 
La FSM no entra a `ACCESS` mientras el write buffer tenga entradas pendientes. Esto preserva el orden read-after-write hacia DRAM: si un store previo aún no se ha drenado, un load a la misma dirección podría leer el valor viejo de RAM.
 
---
 
### 5.2 FSM Write Buffer Drain (`wb_state`)
 
```
      wb_empty=0 & load_state≠ACCESS & ~fill_en        wb_cnt==6 & ~mem_busy
          ┌──────────────────────────────┐            ┌───────────────────────┐
          ▼                              │            │                       ▼
       WB_IDLE ───────────────────────► WB_DRAIN ────┘                  WB_COMMIT ──► WB_IDLE
```
 
| Estado | Condición de salida | Descripción |
|---|---|---|
| `WB_IDLE` | `!wb_empty && load_state != ACCESS && ~fill_en` | Espera stores pendientes; bloqueada durante ACCESS y fill |
| `WB_DRAIN` | `wb_cnt == 6 && !mem_busy` | Latencia de drenado de 7 ciclos; reintenta si `mem_busy` |
| `WB_COMMIT` | incondicional → `WB_IDLE` | Emite `wb_write_out`, `wb_pop`, `store_en` si hay hit en L2 |
 
La FSM de drenado se inhibe mientras `load_state == ACCESS` o mientras `fill_en` está activo. Esto evita que un commit al `mem_controller` colisione con un burst de refill en vuelo, lo cual corrompería el orden de transacciones en el bus de memoria.
 
Si el `mem_controller` tiene su cola llena (`mem_busy = 1`), `WB_DRAIN` no avanza a `WB_COMMIT`. Sin esta guarda, el commit ocurriría con la cola llena y la escritura se perdería silenciosamente.
 
`fill_en` se genera registrando la detección de `burst_counter == 7`. El delay de un ciclo es necesario porque en el ciclo donde llega la última palabra del burst, `refill_regs` aún está capturándola (su `always_ff` escribe en el mismo flanco). Sin el registro, `fill_line_out[255:224]` tendría el valor anterior y L2 almacenaría una línea parcialmente corrompida.
 
La invalidación de la línea víctima en L2 se aserta únicamente en el ciclo exacto de transición `IDLE → ACCESS`, y solo cuando hay miss. Mantener `inv_en` activo durante todo `ACCESS` borraría la línea recién escrita por el fill.

Cuando `l2_con` completa un fill, señaliza a `l1_con` para invalidar la línea old y escribir la nueva. Un bug de integración encontrado fue que `inv_en` se mantenía activo durante todo el estado de miss, borrando la línea recién escrita. 

La solución consistía en la detección de flanco en `inv_en`: La invalidación se ejecuta solo en el ciclo exacto del pulso, no durante todo el período activo de `inv_en`.
 
---
 
### 5.3 Cola de Requests (Request Queue)
 
Los misses de loads en L1D se encolan en una `sync_fifo` antes de ser procesados por `l2_con`:
 
- **Profundidad:** 8 entradas
- **Ancho:** dirección de 32 bits + metadatos de transacción

`PTR_BITS'(DEPTH)` con `DEPTH=8` y `PTR_BITS=3` produce `3'(8) = 3'b000 = 0`, haciendo que `full == empty` desde el reset — la FIFO aparece simultáneamente llena y vacía. Usar `COUNT_BITS = PTR_BITS + 1 = 4` evita el truncamiento silencioso del literal de SystemVerilog. Esta es una limitación conocida de Icarus Verilog con casting de constantes.
 
#### Gating de `rq_push` durante ACCESS/DONE
 
Cuatro condiciones combinadas garantizan exactamente un push por miss:
- `miss_l1 & ~is_write`: solo loads, los stores van al write buffer.
- `~rq_full`: no desborda la cola.
- `load_state == IDLE`: no encola mientras hay un request en vuelo.
- `rq_empty`: evita duplicados si el miss_l1 se mantiene sostenido durante el stall — sin esta guarda, cada ciclo de stall intentaría encolar la misma dirección.

---

## Resumen de Justificación técnica de políticas, reemplazo y parámetros configurables

| Decision | Eleccion | Justificacion |
|---|---|---|
| Escritura L1 | **Write-through** | Simplicidad de coherencia: L2 y RAM siempre tienen el dato. No requiere dirty bits ni eviction de lineas sucias. |
| Escritura L2 | **Write-through** (con autorizacion del profesor; el enunciado pedia write-back) | Uniformidad con L1 y simplicidad. El costo medido es alto trafico de escritura a RAM (ver analisis de rendimiento: 86-88% de utilizacion del bus). |
| Asignacion en write miss | **No-write-allocate** | Un store que falla no trae la linea: escribe hacia abajo. Combinacion clasica con write-through. |
| Reemplazo L1 y L2 | **FIFO** (puntero por set, `set_reg.sv`) | 1 contador chico por set, sin actualizacion en hits. Trade-off aceptado: puede expulsar lineas calientes que LRU conservaria. |
| Write buffers | Request queue (8) y write buffer (8) en `l2_con`; cola asincrona (8) y write buffer (8) en `mem_controller` | Absorben los stores para que el pipeline no espere los ~25 ciclos de RAM por cada escritura. |

---

## Flujo de un acceso

**Load (lectura):**
1. Lookup combinacional en L1 con `alu_result`. Hit: dato en el mismo ciclo, sin stall.
2. Miss en L1: el pipeline se congela (`stall_mem`). El load espera a que el
   write buffer de L2 drene (orden read-after-write) y se encola en la
   request queue de `l2_con`.
3. La FSM de L2 evalua `hit_l2`. Hit: el dato sale de L2 tras el hit time.
   Miss: se pide un burst de 8 palabras a `mem_controller`, que lee la linea
   completa de RAM (alineada a 32 B), la acumula en `refill_regs` y la
   escribe en L2 y L1. El load reintenta y acierta.

**Store (escritura):**
1. Si la linea esta en L1, se actualiza la palabra en L1 (mismo ciclo).
2. El store SIEMPRE se empuja al write buffer de `l2_con` (write-through),
   que lo drena hacia L2 (si hit) y hacia RAM via `mem_controller`.
3. El pipeline solo se detiene si el write buffer esta lleno (backpressure).

---

## Integración con el pipeline del procesador

### Manejo de stalls de pipeline por misses

- `stall_mem = stall_l2 | stall_mc | (load & ~hit_l1 & ~hit_l2)`: un load sin
  dato valido retiene IF/ID/EX/MEM/WB hasta que algun nivel lo tenga.
- Los flushes por branch se suprimen durante el stall y se aplican al
  liberarse (los registros de pipeline retienen su contenido mientras estan
  congelados).
- El dominio de RAM corre a 50 MHz (`clk_divider`); el cruce se hace con la
  cola asincrona del `mem_controller`.

---

## Ordenamiento y coherencia

Con write-through la coherencia entre niveles es directa (no hay lineas
sucias). El orden read-after-write se garantiza en dos puntos:

1. `l2_con`: un load no inicia su acceso mientras su write buffer tenga
   stores pendientes.
2. `fsm_memory`: una lectura no inicia su burst mientras el write buffer de
   memoria este drenando (`wb_conflict`).

Como ambos caminos comparten la request queue del `mem_controller` (FIFO),
las escrituras siempre llegan a RAM antes que la lectura que las sigue.

## Limitaciones conocidas

- El hit de L2 paga los 8 ciclos completos de la FSM aunque el dato este
  disponible antes (hit time fijo segun el enunciado).
- Dos stores consecutivos a la misma direccion: el filtro anti-duplicados
  del write buffer descartaria el segundo. El codigo generado por el
  compilador no produce ese patron.
- `burst_active` cruza de dominio sin sincronizador en la transicion
  DONE→IDLE de `l2_con` (funciona en simulacion; para sintesis se
  recomienda un sincronizador 2-FF).
- Los contadores de metricas viven en el testbench (medicion no invasiva),
  no en RTL.
