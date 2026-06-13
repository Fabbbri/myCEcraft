# Analisis de rendimiento y validacion

Metodologia de medicion, benchmarks y analisis de resultados de la jerarquia
de cache de datos (Proyecto Grupal II). Las metricas y su organizacion siguen
la Seccion 5 del enunciado (Cuadros 1/2/3).

## Metodologia de medicion

Las metricas se capturan en `tb/tb_topG.sv` muestreando señales del DUT cada
ciclo (medicion no invasiva, no altera el RTL):

- **Procesador (5.1)**: ciclos hasta el `freeze`, instrucciones completadas
  (no-NOP, sin flush ni stall), IPC = instr/ciclos y CPI = 1/IPC; stalls de
  memoria (`stall_mem`) y de control (`flushD`).
- **Cache (5.2)**: accesos a L1 clasificados por read/write y hit/miss en el
  primer ciclo de cada operacion real en MEM; L2 por load miss y por store
  drenado. El AMAT se deriva de los miss rates.
- **Memoria principal (5.3)**: accesos (misses de lectura de L2 + stores
  drenados, por write-through), ciclos de transferencia y utilizacion del bus.

La automatizacion esta en `scripts/benchmarks.py`: corre la suite, valida el
resultado de cada programa contra su valor esperado en x11 (oraculo),
consolida `outputs/reports/results.csv` (30 columnas) y genera la vista
`results.html`, organizada en los tres bloques del spec mas la comparacion
del compilador.

## Benchmarks utilizados

| Programa | Patron | Que demuestra |
|---|---|---|
| `while loop x<5` | escalar, baseline | pipeline + cache en el caso minimo |
| `bench_seq` | recorrido secuencial de 256 palabras | localidad espacial (1 miss por linea de 8 palabras) |
| `bench_stride` | salto de 32 B (una palabra por linea) | peor caso espacial: cada acceso toca linea nueva |
| `bench_random` | permutacion pseudoaleatoria sobre 480 palabras (paso 341, coprimo) | sin localidad espacial, working set ~2 KB |
| `bench_mmul` | multiplicacion de matrices 8x8 | kernel real con alta localidad (working set 768 B cabe en L1) |

Cada programa termina con su resultado (checksum) en x11, verificado contra el
valor calculado a mano. Fuentes en `programs/src/*.craft`, compiladas con el
compilador propio (`python compi/main.py -r -b`) en O0 y O1.

## Resultados (configuracion base, sin optimizar)

| Benchmark | IPC | CPI | L1 Hit | L2 Hit | AMAT | Stalls mem | BW |
|---|---|---|---|---|---|---|---|
| while x<5 | 0.40 | 2.52 | 80.0% | 55.6% | 4.82 | 54% | 58% |
| bench_seq | 0.37 | 2.67 | 90.6% | 72.7% | 2.39 | 53% | 86% |
| bench_stride | 0.26 | 3.84 | 82.7% | 59.0% | 4.16 | 68% | 71% |
| bench_random | 0.36 | 2.81 | 93.1% | 80.7% | 1.88 | 56% | 87% |
| bench_mmul | **0.46** | **2.19** | **97.3%** | **90.0%** | **1.28** | 46% | 88% |

AMAT global (miss rates promediados: L1 11.3%, L2 28.4%) ≈ **2.70 ciclos**.
Tabla completa (30 columnas, O0 y O1) en `outputs/reports/results.csv`.

## Comparacion entre configuraciones (compilador O0 vs O1)

Mismo hardware, el compilador propio en dos niveles de optimizacion:

| Benchmark | Ciclos O0 → O1 | Acelera | CPI O0 → O1 | L1 Hit O0 → O1 |
|---|---|---|---|---|
| bench_seq | 21 992 → 13 681 | 1.61x | 2.67 → 2.29 | 90.6% → 76.2% |
| bench_stride | 4 085 → 3 020 | 1.35x | 3.84 → 3.84 | 82.7% → 56.6% |
| bench_random | 57 509 → 51 813 | 1.11x | 2.81 → 2.46 | 93.1% → 89.0% |
| bench_mmul | (O1 incorrecto) | — | — | — |

O1 aplica loop unrolling y renombrado de registros: baja los ciclos, pero
suele **bajar el hit rate** porque elimina los aciertos baratos del control del
bucle y deja los misses obligatorios como mayor fraccion (el AMAT sube en
consecuencia). Es la interaccion compilador-cache que el proyecto busca medir.

## Interpretacion

1. **La jerarquia se paga.** Contra el modelo sin cache de la iteracion 2
   (CPI 8.19 en el while), el mismo programa corre a CPI 2.52: ~3.2x.
2. **La localidad determina el rendimiento.** Mismo hardware: mmul (working set
   en L1) logra CPI 2.19; stride (sin localidad) 3.84, ~75% mas lento.
3. **La medicion reproduce la teoria.** Para bench_seq se predicen 32 misses
   obligatorios (256/8); se midieron 33. El AMAT ordena los benchmarks igual
   que el CPI medido.
4. **La pared de memoria es real.** Aun con 90%+ de hit rate, el pipeline pasa
   46-68% de los ciclos congelado: el miss penalty (8 + 25 ciclos) domina.
5. **El costo del write-through es medible.** En mmul, 2216 de 2242 accesos a
   RAM (98.8%) son stores; el bus queda 88% ocupado. Mejora futura identificada:
   write-back reduciria ese trafico en cargas con escrituras repetidas.

## Validacion experimental

- Suite: **8/9 corridas PASS** (resultado en x11 verificado por programa). Las
  5 corridas base (O0 + while) pasan; de las 4 variantes O1, 3 pasan y
  **mmul O1 falla** — el oraculo detecta que la optimizacion rompe el resultado
  (regresion del compilador, no del cache). Esto valida que las pruebas no solo
  miden, tambien atrapan errores.
- TEA + boveda (`tb_tea_loader`): 19/20 PASS; cifrado/descifrado y roundtrip
  correctos. El unico fallo (limpieza de la password de bootstrap en NRAM[0])
  es del camino de la boveda, independiente de la jerarquia de cache.

## Como reproducir

```bash
cd arqui
python scripts/benchmarks.py            # corre la suite, genera results.csv + results.html
python scripts/benchmarks.py --compile  # ademas recompila O0/O1 y captura metricas del compilador
python scripts/benchmarks.py --list     # lista los benchmarks
```
