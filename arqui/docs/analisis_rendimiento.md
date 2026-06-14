# Analisis de rendimiento y validacion

Este analisis se construyo a partir de las metricas generadas en
`outputs/reports/results.html` y de los datos crudos de `results.csv` y
`results_no_cash.csv`. El objetivo es medir por separado el efecto de la
jerarquia de cache y el de las optimizaciones del compilador sobre el
procesador.

## Metodologia de medicion

La suite se ejecuta mediante `scripts/benchmarks.py`. Primero se compila el
testbench con Icarus Verilog y luego cada programa se ejecuta con `vvp` hasta
alcanzar la instruccion `freeze`. La direccion de parada se obtiene
automaticamente del archivo `.hex`, por lo que todas las configuraciones
terminan en el mismo punto logico del programa.

Para cada benchmark se realizaron las siguientes comparaciones:

1. **Con cache y sin cache:** se utilizo la misma ROM O0 y el mismo punto de
   parada. La configuracion sin cache usa `top_no_cash`, una memoria realista
   con reloj de 50 MHz, transferencias en rafagas de ocho palabras y una
   penalizacion aproximada de 22 ciclos por acceso. La configuracion con cache
   usa la jerarquia L1/L2.
2. **Niveles del compilador:** cada programa se compilo con O0, O1, O2 y O3.
   O0 es la referencia; O1 aplica *loop unrolling* y renombrado de registros;
   O2 aplica eliminacion de codigo muerto y reordenamiento; O3 combina todas
   las optimizaciones.
3. **Validacion funcional:** todas las variantes de un mismo programa deben
   dejar en `x11` el valor esperado. Esto evita interpretar como mejora una
   ejecucion que produzca un resultado incorrecto.

Las principales metricas son:

- `CPI = ciclos / instrucciones` e `IPC = instrucciones / ciclos`.
- Tasa de aciertos L1 y L2, separando lecturas y escrituras.
- Ciclos de espera en memoria y stalls de control.
- Accesos y ciclos de transferencia hacia memoria principal.
- `AMAT = 1 + missL1 * (8 + missL2 * 25)`.
- Aceleracion de cache: `ciclos sin cache / ciclos con cache`.
- Aceleracion del compilador: `ciclos O0 / ciclos Ox`.

Los ciclos se obtienen de una simulacion digital determinista. Por ello no se
promedian tiempos de pared ni se reporta desviacion estandar: al repetir una
corrida con la misma ROM y configuracion se obtiene el mismo conteo. Los
tiempos de compilacion si dependen del equipo anfitrion y se usan solo como
referencia, no como medida del rendimiento del procesador.

## Benchmarks utilizados

| Benchmark | Patron evaluado | Resultado esperado en `x11` |
|---|---|---:|
| `bench_seq` | Inicializacion y lectura secuencial de 256 elementos; alta localidad espacial | `0x7F80` |
| `bench_stride` | Acceso a un arreglo de 256 elementos con stride de 8; aprovecha menos cada bloque | `0x0F80` |
| `bench_random` | Inicializacion secuencial y 480 lecturas en orden pseudoaleatorio, con salto 341 modulo 480 | `0x1C110` |
| `bench_mmul` | Multiplicacion de matrices 8x8 con tres ciclos anidados; alta reutilizacion de datos | `0x3F00` |

La suite adicional P2 contiene pruebas dirigidas de *unrolling*, renombrado,
eliminacion de codigo muerto y reordenamiento. Estas pruebas permiten comprobar
cada transformacion de forma aislada, ademas de observar su efecto en programas
mas completos.

## Resultados de la configuracion base (O0)

| Benchmark | Ciclos | Instrucciones | IPC | CPI | Stalls MEM | Stalls control |
|---|---:|---:|---:|---:|---:|---:|
| `bench_seq` | 21,982 | 9,251 | 0.421 | 2.38 | 9,644 | 1,029 |
| `bench_random` | 60,212 | 23,964 | 0.398 | 2.51 | 28,072 | 2,885 |
| `bench_stride` | 4,059 | 1,187 | 0.292 | 3.42 | 2,473 | 133 |
| `bench_mmul` | 110,628 | 28,799 | 0.260 | 3.84 | 73,536 | 1,575 |

`bench_seq` obtiene el mejor CPI por su recorrido regular. `bench_stride`
ejecuta pocas instrucciones, pero desperdicia parte de cada bloque traido a
cache y presenta el peor AMAT entre las cuatro cargas. `bench_mmul` tiene una
tasa de aciertos muy alta, aunque su CPI sigue siendo el mayor: realiza 13,891
operaciones de datos en L1 y acumula 73,536 stalls de memoria. Por tanto, la
tasa de aciertos debe analizarse junto con el numero total de accesos, no de
forma aislada.

### Comportamiento de la jerarquia de memoria

| Benchmark | Hit L1 | Hit L2 | AMAT (ciclos) | Accesos a RAM | BW utilizado |
|---|---:|---:|---:|---:|---:|
| `bench_seq` | 85.84% | 72.62% | 3.10 | 1,063 | 86.43% |
| `bench_random` | 90.57% | 81.55% | 2.19 | 2,948 | 87.68% |
| `bench_stride` | 73.76% | 58.43% | 5.83 | 166 | 71.22% |
| `bench_mmul` | 98.37% | 95.88% | 1.15 | 5,507 | 89.41% |

El AMAT global reportado es de 2.77 ciclos. El patron con stride es el menos
favorable para la jerarquia: alcanza solo 73.76% de aciertos en L1 y 58.43% en
L2. En cambio, la multiplicacion de matrices reutiliza intensamente sus datos
y obtiene un AMAT de 1.15 ciclos. La politica de escritura es *write-through*,
por lo que todo `store` drenado llega a memoria aun cuando haya sido hit; por
eso los accesos a RAM no equivalen unicamente a los misses de L2.

## Comparacion entre configuraciones

### Con cache frente a sin cache

| Benchmark | Ciclos sin cache | Ciclos con cache | Aceleracion | CPI sin cache | CPI con cache | Reduccion de trafico |
|---|---:|---:|---:|---:|---:|---:|
| `bench_seq` | 50,342 | 21,982 | 2.29x | 5.43 | 2.38 | 1.9x |
| `bench_random` | 140,771 | 60,212 | 2.34x | 5.87 | 2.51 | 2.0x |
| `bench_stride` | 6,438 | 4,059 | 1.59x | 5.37 | 3.42 | 1.6x |
| `bench_mmul` | 341,921 | 110,628 | 3.09x | 11.87 | 3.84 | 2.5x |

La cache mejora las cuatro cargas. El mayor beneficio aparece en
`bench_mmul`: la reutilizacion temporal permite reducir el tiempo a casi un
tercio y el trafico al bus en 2.5x. `bench_stride` obtiene la menor aceleracion
porque el salto entre elementos reduce la utilidad de los bloques cargados.
Estos resultados validan experimentalmente la relacion entre localidad,
aciertos, stalls y CPI.

### O0, O1, O2 y O3

| Benchmark | Ciclos O0 | Ciclos O1 | Speedup O1 | Ciclos O2 | Speedup O2 | Ciclos O3 | Speedup O3 |
|---|---:|---:|---:|---:|---:|---:|---:|
| `bench_seq` | 21,982 | 13,680 | 1.61x | 21,982 | 1.00x | 13,680 | 1.61x |
| `bench_stride` | 4,059 | 3,019 | 1.34x | 4,059 | 1.00x | 3,019 | 1.34x |
| `bench_random` | 60,212 | 51,812 | 1.16x | 60,212 | 1.00x | 51,812 | 1.16x |
| `bench_mmul` | 110,628 | 108,786 | 1.02x | 110,528 | 1.00x | 108,686 | 1.02x |

O1 y O3 reducen de forma importante el numero de instrucciones dinamicas en
los recorridos simples: `bench_seq` pasa de 9,251 a 5,955 instrucciones,
`bench_stride` de 1,187 a 775 y `bench_random` de 23,964 a aproximadamente
21,023. La mejora proviene principalmente del *unrolling* y de la reduccion de
dependencias asociada al renombrado.

El aumento del tamano estatico es el costo principal: `bench_seq` y
`bench_stride` pasan de 252 a 636 bytes con O1/O3, y `bench_random` de 336 a
588/580 bytes. En `bench_stride`, incluso el CPI empeora de 3.42 a 3.90, pero
el programa termina antes porque ejecuta 34.7% menos instrucciones. Esto
demuestra que CPI y tiempo total no son equivalentes y deben reportarse juntos.

O2 no encuentra oportunidades relevantes en `bench_seq` ni `bench_stride`.
En `bench_random` elimina una instruccion estatica, sin cambiar los ciclos, y
en `bench_mmul` elimina seis, con una mejora marginal de 100 ciclos. O3 hereda
las mejoras de O1 y agrega una reduccion pequeña en `bench_mmul`, donde alcanza
108,686 ciclos. En consecuencia, aplicar mas pases no garantiza una mejora
proporcional; el resultado depende de que el programa contenga el patron que
cada optimizacion puede explotar.

Las pruebas dirigidas P2 confirman esta dependencia. DCE obtiene aceleraciones
entre 1.74x y 2.39x en las cadenas de codigo muerto; *unrolling* obtiene entre
1.10x y 1.40x; y el reordenamiento varia entre 1.01x y 1.23x. Las pruebas de
renombrado conservan los mismos ciclos en estos casos, aunque registran entre
5 y 12 renombrados, por lo que validan la transformacion semantica pero no una
ganancia de rendimiento para esas cargas.

## Validacion experimental

La validacion combina consistencia funcional y consistencia de las metricas:

- Las 16 corridas principales, cuatro programas por cuatro niveles, producen
  el valor esperado en `x11`; no se reportan fallos ni timeouts.
- Las variantes con y sin cache usan exactamente la misma ROM O0 y el mismo
  `HALT_PC`. La version sin cache siempre requiere mas ciclos, como predice el
  modelo de memoria.
- En todas las filas se cumple `CPI = ciclos / instrucciones` e
  `IPC = instrucciones / ciclos`, dentro del redondeo mostrado.
- Los conteos de cache son coherentes: lecturas y escrituras se descomponen en
  hits y misses, y los accesos L2 corresponden a las solicitudes que bajan
  desde L1.
- Las 16 pruebas P2 reportadas tambien terminan con estado `OK` tanto en O0
  como con su optimizacion especifica.

Los experimentos respaldan dos conclusiones. Primero, la jerarquia L1/L2 es
efectiva: reduce entre 1.59x y 3.09x los ciclos y entre 1.6x y 2.5x el trafico
hacia RAM. Segundo, las optimizaciones del compilador son selectivas: O1/O3
benefician especialmente a los ciclos con bucles, mientras que O2 solo aporta
cuando existe codigo muerto o trabajo reordenable. La correccion se mantiene
en todos los casos mediante la comprobacion del resultado arquitectonico.

## Como reproducir

Desde el directorio `arqui`:

```bash
make bench
```

Los resultados se escriben en `outputs/reports/results.html`, con los datos
tabulares completos en `results.csv`, `results_no_cash.csv` y
`results_p2.csv`.
