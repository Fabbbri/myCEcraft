# Analisis de rendimiento y validacion

Metodologia de medicion, benchmarks y analisis de resultados de la jerarquia
de cache de datos (Proyecto Grupal II). Las metricas y su organizacion siguen
la Seccion 5 del enunciado (Cuadros 1/2/3). Todos los numeros provienen de
`scripts/benchmarks.py` (`outputs/reports/results.csv`).

## Metodologia de medicion

Las metricas se capturan en los testbenches (`tb/tb_topG.sv`,
`tb/tb_general_dump.sv`) muestreando señales del DUT cada ciclo (medicion no
invasiva, no altera el RTL):

- **Procesador (5.1)**: ciclos desde la salida de reset hasta el `freeze`,
  instrucciones completadas (no-NOP, sin flush ni stall), IPC = instr/ciclos y
  CPI = 1/IPC; ciclos de stall de memoria (`stall_mem`) y de control (`flushD`).
- **Cache (5.2)**: accesos a L1 clasificados por read/write y hit/miss en el
  primer ciclo de cada operacion real en MEM; L2 por load miss de L1 y por
  store drenado. El AMAT se deriva de los miss rates.
- **Memoria principal (5.3)**: accesos (miss de lectura de L2 + stores
  drenados, por write-through), ciclos de transferencia y utilizacion del bus.

Ciclos e instrucciones se cuentan sobre **la misma ventana** (reset -> `freeze`):
el conteo se congela en la instruccion de halt, de modo que el CPI es
internamente consistente. Como validacion cruzada, `tb_topG` y
`tb_general_dump` reportan metricas identicas sobre el mismo binario.

La automatizacion esta en `scripts/benchmarks.py`: compila la suite, corre cada
programa, valida su resultado en x11 contra el valor esperado (oraculo),
consolida `outputs/reports/results.csv` (32 columnas) y genera `results.html`.

## Benchmarks utilizados

| Programa | Patron | Que demuestra |
|---|---|---|
| `while loop x<5` | escalar, baseline | pipeline + cache en el caso minimo |
| `bench_seq` | recorrido secuencial de 256 palabras | localidad espacial (1 miss por linea de 8 palabras) |
| `bench_stride` | salto de 32 B (una palabra por linea) | peor caso espacial: cada acceso toca linea nueva |
| `bench_random` | permutacion pseudoaleatoria sobre 480 palabras (paso 341, coprimo) | sin localidad espacial, working set ~2 KB |
| `bench_mmul` | multiplicacion de matrices 8x8 | kernel con alta localidad (working set 768 B cabe en L1) y muchas escrituras |

Cada programa termina con su checksum en x11, verificado contra el valor
calculado a mano. Fuentes en `programs/src/*.craft`, compiladas con el
compilador propio (`python compi/main.py -r -b`) en O0/O1/O2/O3.

## Resultados (configuracion base, O0)

| Benchmark | Ciclos | Instr | CPI | IPC | L1 Hit | L2 Hit | AMAT | Stall mem | BW |
|---|---|---|---|---|---|---|---|---|---|
| while x<5 | 178 | 59 | 3.02 | 0.33 | 80.0% | 55.6% | 4.82 | 54% | 58% |
| bench_seq | 21 982 | 9 251 | 2.38 | 0.42 | 85.8% | 72.6% | 3.10 | 44% | 86% |
| bench_stride | 4 059 | 1 187 | 3.42 | 0.29 | 73.8% | 58.4% | 5.83 | 61% | 71% |
| bench_random | 60 212 | 23 964 | 2.51 | 0.40 | 90.6% | 81.6% | 2.19 | 47% | 88% |
| bench_mmul | 110 628 | 28 799 | **3.84** | 0.26 | **98.4%** | **95.9%** | **1.15** | **66%** | **89%** |

mmul tiene el **mejor** hit rate y AMAT pero el **peor** CPI: la calidad de la
cache y el rendimiento real divergen (ver Interpretacion). Tabla completa
(O0-O3) en `outputs/reports/results.csv`.

## Comparacion entre configuraciones (O0 / O1 / O2 / O3)

Mismo hardware, el compilador propio en cuatro niveles. O1 = unroll + rename;
O2 = DCE + reorder; O3 = todas. Aceleracion = ciclos_O0 / ciclos_Ox (>1 mas
rapido, <1 mas lento).

| Benchmark | Ciclos O0 | O1 | O2 | O3 |
|---|---|---|---|---|
| bench_seq | 21 982 | **13 680** (1.61x) | 27 034 (0.81x) | 13 680 (1.61x) |
| bench_stride | 4 059 | **3 019** (1.34x) | 4 682 (0.87x) | 3 037 (1.34x) |
| bench_random | 60 212 | **51 812** (1.16x) | 69 802 (0.86x) | 61 402 (0.98x) |
| bench_mmul | 110 628 | **108 786** (1.02x) | 121 972 (0.91x) | 118 934 (0.93x) |

- **O1 (unroll + rename) acelera** en los cuatro, de 1.02x (mmul) a 1.61x
  (seq). El unroll elimina saltos de control del bucle; el rename quita spills.
  El costo es codigo: en seq el binario crece de 252 a 636 B (2.5x) por un
  1.61x de velocidad.
- **O2 (DCE + reorder) regresa** en los cuatro (0.81-0.91x, mas lento que O0).
  El reorder inserta spill/reload de temporales que suben los ciclos sin cerrar
  el stall que pretende ocultar.
- **O3 ~ O1** donde el unroll manda (seq, stride); en random/mmul el componente
  de reorder lo arrastra hasta empatar o quedar bajo O0.

Interaccion compilador-cache (O0 -> O1):

| Benchmark | L1 Hit | AMAT |
|---|---|---|
| bench_seq | 85.8% -> 76.2% | 3.10 -> 5.58 |
| bench_stride | 73.8% -> 56.6% | 5.83 -> 11.04 |
| bench_random | 90.6% -> 89.0% | 2.19 -> 2.48 |
| bench_mmul | 98.4% -> 98.4% | 1.15 -> 1.14 |

O1 baja los ciclos pero **baja el hit rate**: elimina los aciertos baratos del
control del bucle, dejando los misses obligatorios como mayor fraccion (el AMAT
sube en consecuencia). mmul, ya saturado, no se mueve.

## Interpretacion

1. **El AMAT no predice el CPI.** mmul tiene el mejor AMAT (1.15) y el peor CPI
   (3.84): el cuello no esta en la frecuencia de misses sino en el ancho de
   banda de memoria.
2. **El cuello de botella es el write-through.** En mmul, 5 479 de 5 507 accesos
   a RAM (99.5%) son stores drenados; el bus queda 89% ocupado y el pipeline
   pasa 66% de los ciclos congelado, **pese a 98.4% de hit en L1**. Mejora
   identificada: write-back recortaria ese trafico en kernels con escrituras
   repetidas.
3. **La localidad espacial ordena los hits.** stride (una palabra por linea, sin
   reuso) tiene el peor L1 hit (73.8%) y AMAT (5.83); mmul y random (working set
   residente) los mejores.
4. **La medicion reproduce la teoria.** bench_seq predice 256/8 = 32 misses
   obligatorios; se midieron 34 (L1 read misses), el resto de los accesos caen
   dentro de la linea ya traida.
5. **La pared de memoria es real.** Aun con 85-98% de hit rate, el pipeline pasa
   44-66% de los ciclos congelado por memoria: la penalidad del burst domina
   sobre la frecuencia de misses.

## Validacion experimental

- **Oraculo x11**: cada corrida valida su checksum contra el valor calculado a
  mano. Suite de cache: **17/17 PASS** (while + 4 benchmarks x O0/O1/O2/O3).
  Verificado: bench_seq = 0x7F80, bench_stride = 0xF80, bench_random = 0x1C110,
  bench_mmul = 0x3F00, identico en los cuatro niveles -> las optimizaciones
  preservan el resultado.
- **Consistencia de instrumentacion**: `tb_topG` y `tb_general_dump` reportan
  metricas identicas sobre el mismo binario (mismas ventanas de conteo), lo que
  descarta sesgo del testbench.

## Como reproducir

```bash
cd arqui
make bench
```
