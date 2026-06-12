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

---

## Caché L2: políticas de escritura, reemplazo y parámetros

| Nivel | Tamaño | Asociatividad | Linea | Sets | Hit time |
|---|---|---|---|---|---|
| L2 | 16 KB | 4-way | 32 B | 128 | 8 ciclos (FSM) |
| RAM | 64 KB | — | burst de 8 palabras | — | ~25 ciclos del procesador |

### División de la dirección — L2

```
L2:  | tag 20b [31:12] | set 7b [11:5] | word 3b [4:2] | byte 2b [1:0] |
```

### Funcionamiento de caché L2 unificado

---

## Justificación técnica de políticas, reemplazo y parámetros configurables

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
