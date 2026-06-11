# Analisis de rendimiento y validacion

Metodologia de medicion, benchmarks y analisis de resultados de la jerarquia
de cache (Proyecto Grupal II).

## Metodologia

Las metricas se capturan en `tb/tb_topG.sv` muestreando señales del DUT cada
ciclo (medicion no invasiva, no altera el RTL):

- **Ciclos / instrucciones / CPI**: contador de ciclos hasta el `freeze` y
  contador de instrucciones no-NOP que entran a EX sin flush ni stall.
- **Accesos a L1**: se detecta el primer ciclo de cada operacion de memoria
  real en MEM (load = `result_src==01`, store = `we_mem`) y se clasifica con
  `hit_l1` en ese ciclo.
- **L2**: cada load miss de L1 baja a L2 (se muestrea `hit_l2`); cada store
  drenado se clasifica con `hit_l2_wb` en el commit del write buffer.
- **Memoria principal**: misses de lectura de L2 + stores drenados
  (write-through: todo store llega a RAM aunque haya sido hit en L2).
- **Stalls**: ciclos con `stall_mem` activo (memoria) y ciclos de fetch
  perdidos por branch tomado (`flushD`).
- **Ancho de banda**: ciclos con el bus de RAM ocupado / ciclos totales.

La automatizacion esta en `scripts/benchmarks.py`: corre la suite, valida el
resultado de cada programa contra su valor esperado en x11, consolida
`outputs/reports/results.csv` y genera la vista `results.html`.

## Benchmarks

| Programa | Patron | Que demuestra |
|---|---|---|
| `while loop x<5` | escalar, baseline | pipeline + cache en el caso minimo |
| `bench_seq` | recorrido secuencial de 256 palabras | localidad espacial (1 miss por linea de 8 palabras) |
| `bench_stride` | salto de 32 B (una palabra por linea) | peor caso espacial: cada acceso toca linea nueva |
| `bench_random` | permutacion pseudoaleatoria sobre 480 palabras (paso 341, coprimo) | patron aleatorio: sin localidad espacial, working set ~2 KB |
| `bench_mmul` | multiplicacion de matrices 8x8 | kernel real con alta localidad (working set 768 B cabe en L1) |

Cada programa termina con su resultado (checksum) en x11, verificado contra
el valor calculado a mano. Fuentes en `programs/src/*.craft`, compiladas con
el compilador propio (`python compi/main.py -r -b`).

## Resultados

| Benchmark | CPI | L1 Hit | L2 Hit | Stalls mem / ciclos | BW util |
|---|---|---|---|---|---|
| while x<5 | 2.52 | 80.0% | 55.6% | 54% | 58% |
| bench_seq | 2.67 | 90.6% | 72.7% | 53% | 86% |
| bench_stride | 3.84 | 82.7% | 59.0% | 68% | 71% |
| bench_random | 2.81 | 93.1% | 80.7% | — | — |
| bench_mmul | **2.19** | **97.3%** | **90.0%** | 46% | 88% |

(Tabla completa con las 22 columnas en `outputs/reports/results.csv`.)

## Interpretacion

1. **La jerarquia se paga sola.** Contra el modelo sin cache de la iteracion 2
   (CPI 8.19 en el while loop), el mismo programa corre a CPI 2.52: ~3.2x.

2. **La localidad determina el rendimiento.** Mismo hardware: mmul (alta
   localidad, working set cabe en L1) logra CPI 2.19; stride (cero localidad
   espacial) 3.84 — 75% mas lento. Es la demostracion empirica del impacto
   del patron de acceso.

3. **La medicion reproduce la teoria.** Para bench_seq el modelo predice 32
   misses obligatorios (256 palabras / 8 por linea); se midieron 33. El AMAT
   calculado con la formula de la Leccion 13 ordena los benchmarks igual que
   el CPI medido:
   - mmul: 1 + 0.027·(8 + 0.10·25) ≈ 1.28 ciclos
   - seq: 1 + 0.094·(8 + 0.27·25) ≈ 2.39 ciclos
   - stride: 1 + 0.173·(8 + 0.41·25) ≈ 4.16 ciclos

4. **La pared de memoria es real.** Incluso con 90%+ de hit rate, el pipeline
   pasa 46-68% de los ciclos congelado esperando memoria: el miss penalty
   (8 + 25 ciclos) domina aunque los misses sean pocos.

5. **El costo del write-through es medible.** En mmul, 2216 de los 2242
   accesos a RAM (98.8%) son stores drenados; el bus esta ocupado el 88% del
   tiempo. El hit rate alto no reduce el trafico de escritura con esta
   politica. Trabajo futuro identificado: write-back reduciria los accesos a
   RAM en un orden de magnitud en cargas con stores repetidos.

6. **Los stalls de memoria dominan a los de control por ~25x** (mmul: 21100
   vs 788 ciclos). El esfuerzo de optimizacion conjunto con el compilador
   debe ir a localidad de datos, no a branches.

## Validacion funcional

- Suite de benchmarks: 5/5 PASS (resultado en x11 verificado por programa).
- TEA + boveda (`tb_tea_loader` sobre la jerarquia nueva): 19/20 PASS — el
  cifrado, descifrado y roundtrip son correctos. El unico fallo es la
  limpieza de la password de bootstrap en NRAM[0] (pendiente verificar si es
  preexistente al cache).

## Como reproducir

```bash
cd arqui
python scripts/benchmarks.py        # corre todo y abre el reporte HTML
make run TOP=tb_tea_loader          # validacion TEA/boveda
```
