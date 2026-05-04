# Modelado del software y simulacion

La simulacion de Craft21 modela el procesador completo en SystemVerilog y lo
ejecuta con Icarus Verilog. El objetivo es validar que los programas generados
por el compilador se puedan cargar en la ROM de instrucciones, ejecutar ciclo a
ciclo en el procesador y verificar sus efectos sobre registros, memoria normal y
boveda de llaves.

El modelo combina modulos RTL sintetizables en `arqui/rtl/` con testbenches en
`arqui/tb/`. Los programas y datos de prueba se cargan desde archivos
hexadecimales ubicados en `arqui/programs/`.

## Herramientas de simulacion

| Herramienta | Uso |
| --- | --- |
| Icarus Verilog (`iverilog`) | Compila los modulos SystemVerilog y el testbench. |
| `vvp` | Ejecuta el archivo compilado `.vvp`. |
| GTKWave / Surfer | Abre formas de onda `.vcd`. |
| Make | Automatiza compilacion, ejecucion y limpieza. |
| Python | Carga y extrae archivos binarios hacia/desde imagenes de RAM. |

El flujo principal se controla con `arqui/Makefile`:

```bash
cd arqui
make run TOP=tb_top
make run TOP=tb_top_vault
make run TOP=tb_tea
make wave TOP=tb_top
make run-all
make clean
```

El target `compile` invoca:

```bash
iverilog -g2012 -o sim/build/<TOP>.vvp rtl/*.sv tb/<TOP>.sv
```

Luego `run` ejecuta:

```bash
vvp sim/build/<TOP>.vvp
```

## Modelo de simulacion del procesador

El procesador completo se instancia desde `top.sv`. Los testbenches lo tratan
como DUT:

```systemverilog
top dut (.clk(clk), .reset(reset));
always #5 clk = ~clk;
```

El reloj tiene periodo de 10 ns. El reset se aplica durante varios ciclos antes
de iniciar cada prueba. Despues del reset, el PC empieza en cero y la ROM entrega
la primera instruccion del programa cargado.

La ejecucion se detiene de dos formas:

- por una instruccion `freeze`, detectada cuando `dut.Issue.pc_en` pasa a cero;
- por timeout si se supera el maximo de ciclos del testbench.

Este esquema evita que una simulacion se quede corriendo indefinidamente si hay
un branch mal resuelto o un programa sin final.

## Ciclo de ejecucion

El ciclo de instruccion simulado sigue las etapas del pipeline:

1. `issue.sv` lee la instruccion de `instr_rom.sv` usando el PC.
2. `if_id_pipe.sv` registra instruccion, PC y `PC + 4`.
3. `decode.sv` decodifica, lee bancos de registros y extiende inmediatos.
4. `control_unit.sv` genera senales de control segun opcode y campos `func`.
5. `id_ex_pipe.sv` transporta operandos y control a execute.
6. `execute.sv` ejecuta la ALU y resuelve branches/jumps.
7. `ex_mem_pipe.sv` transporta resultado y datos de store.
8. `memory.sv` accede a RAM normal o RAM Vault.
9. `mem_wb_pipe.sv` registra valores para writeback.
10. `writeback.sv` escribe resultados y retroalimenta el siguiente PC.

Cada flanco positivo de reloj avanza los registros secuenciales: PC, bancos de
registros, memorias de escritura y registros de pipeline.

## Banco de registros

El banco general se implementa en `regfile.sv` como 32 registros de 32 bits:

- dos puertos de lectura combinacional: `rd1` y `rd2`;
- un puerto de escritura secuencial: `rd`/`wd`;
- bloqueo de escritura sobre `x0`;
- bypass local para leer el mismo registro que se escribe en el ciclo actual.

La lectura combinacional permite que decode entregue operandos al pipeline sin
esperar otro ciclo. La escritura ocurre en flanco positivo si `we_reg` esta
activo y `rd != 0`.

El testbench `tb_regfile.sv` valida:

- escritura basica;
- lectura doble;
- bypass local;
- inmutabilidad de `x0`;
- multiples escrituras consecutivas.

## Unidad de control

`control_unit.sv` modela la decodificacion combinacional del procesador. Recibe:

| Entrada | Significado |
| --- | --- |
| `opcode` | Bits `3:0` de la instruccion. |
| `func23` | Bits `23:20`. |
| `func19` | Bit `19`. |
| `func15` | Bits `15:14`. |

Con esto genera control para ALU, memoria, branches, writeback y boveda:
`alu_control`, `we_reg`, `we_mem`, `result_src`, `alu_src`, `beq`, `bne`,
`blt`, `bge`, `jump`, `w_regv`, `w_memv`, `neather_portal` y
`neather_reset`.

`tb_control_unit.sv` prueba combinaciones de opcode y funcion para confirmar que
las senales esperadas se activan por tipo de instruccion.

## Unidades funcionales

La ALU se implementa en `alu.sv`. Opera sobre datos de 32 bits y soporta:

- suma y resta;
- desplazamientos logico/arithmeticos;
- comparacion `slt`;
- `xor`, `or`, `and`;
- multiplicacion y division;
- banderas `z_flag`, `n_flag` y `v_flag`.

La division retorna cero si el divisor es cero, lo cual simplifica el modelo al
evitar excepciones. `tb_alu.sv` valida operaciones aritmeticas, logicas y
banderas.

Otras unidades funcionales relevantes son:

| Modulo | Funcion |
| --- | --- |
| `imm_extend.sv` | Reconstruye inmediatos para formatos I, S, B y J. |
| `sumador_pc.sv` | Calcula `PC + 4`. |
| `sum31b.sv` | Suma valores de 32 bits para targets y rutas auxiliares. |
| `pc_decoder.sv` | Detecta `freeze` y controla `pc_enable`. |
| `mux31.sv`, `mux31_2.sv`, `mux_31_3.sv` | Seleccionan fuentes en datapath. |

## Memoria de instrucciones

`instr_rom.sv` modela la memoria de programa. Es una ROM de palabras de 32 bits
con profundidad parametrizable. La direccion del PC esta en bytes, por lo que la
ROM indexa con `addr[31:2]`.

En inicializacion, la ROM se llena con una instruccion tipo NOP y luego carga:

```systemverilog
$readmemh("programs/program.hex", memory);
```

En testbenches de integracion, el programa puede reemplazarse directamente con
`$readmemh(hex_file, dut.Issue.ROM.memory)`, por ejemplo `programs/demo.hex`,
`programs/factorial.hex` o `programs/tea.hex`.

## RAM normal

`data_ram.sv` modela una RAM de 64 KiB organizada por bytes:

- direccion efectiva: `addr[15:0]`;
- lectura de byte con extension de signo para `lb`;
- lectura de palabra de 32 bits para `lw`;
- escritura de byte para `sb`;
- escritura de palabra little endian para `sw`.

La memoria se inicializa con:

```systemverilog
$readmemh("programs/data.hex", mem);
```

En las pruebas de TEA, `tb_tea.sv` carga una imagen especifica:

```systemverilog
$readmemh("programs/tea_data.hex", `DRAM);
```

Luego verifica resultados leyendo directamente los bytes del arreglo interno y
armando palabras como:

```systemverilog
got = {`DRAM[offset+3], `DRAM[offset+2], `DRAM[offset+1], `DRAM[offset]};
```

## Boveda de llaves

La boveda se modela con dos bloques principales:

| Modulo | Descripcion |
| --- | --- |
| `neather_regfile.sv` | Banco de 32 registros Vault de 32 bits. |
| `neather_ram.sv` | RAM Vault de 64 KiB, cargada desde `programs/neather.hex`. |

El banco Vault solo recibe escritura si el procesador esta en Secure Mode:

```systemverilog
assign we_regV = w_regvWB & neather_modeWB;
```

La RAM Vault tambien protege escrituras:

```systemverilog
assign we_memv_aux = w_memv & neather_mode_aux;
```

Esto permite simular instrucciones como `portalv`, `lwv`, `swv`, `changev` y
`closev`. `tb_top_vault.sv` valida operaciones Vault revisando registros y
palabras de `neather_ram`. `tb_tea.sv` usa la boveda para comprobar un flujo de
cifrado/descifrado TEA.

## Testbenches disponibles

| Testbench | Proposito |
| --- | --- |
| `tb_alu.sv` | Valida operaciones y banderas de la ALU. |
| `tb_regfile.sv` | Valida banco de registros general. |
| `tb_neather_regfile.sv` | Valida banco de registros Vault. |
| `tb_control_unit.sv` | Verifica senales de control por opcode/func. |
| `tb_imm_extend.sv` | Verifica extension de inmediatos. |
| `tb_data_ram.sv` | Verifica loads/stores de RAM normal. |
| `tb_instr_rom.sv` | Verifica lectura de ROM de instrucciones. |
| `tb_pc.sv`, `tb_pc_decoder.sv`, `tb_sumador_pc.sv` | Verifican componentes de PC. |
| `tb_top.sv` | Ejecuta programas completos como demo, busqueda y factorial. |
| `tb_top_vault.sv` | Ejecuta programa con operaciones de boveda. |
| `tb_tea.sv` | Ejecuta programa TEA y valida memoria normal/Vault. |

Los testbenches generan formas de onda con:

```systemverilog
$dumpfile("sim/waves/<test>.vcd");
$dumpvars(0, <testbench>);
```

## Validacion de programas completos

`tb_top.sv` prueba el procesador completo cargando varios `.hex` en la ROM:

- `programs/demo.hex`;
- `programs/busqueda_arreglo.hex`;
- `programs/factorial.hex`.

Cada prueba:

1. limpia la ROM o la rellena con NOPs;
2. carga el programa con `$readmemh`;
3. aplica reset;
4. espera hasta detectar `freeze`;
5. revisa registros clave como `x11`, `x3`, `x5`, `x2` y `x0`;
6. reporta pruebas pasadas/fallidas.

`tb_top_vault.sv` agrega inspeccion directa de:

- banco general: `dut.Decode.RegBank.regs`;
- banco Vault: `dut.Decode.RegVBank.regs`;
- RAM Vault: `dut.mem.VaultRam.mem`;
- RAM normal: `dut.mem.NormalRam.mem`.

`tb_tea.sv` carga tres imagenes:

```systemverilog
$readmemh("programs/tea.hex", `ROM);
$readmemh("programs/neather.hex", `NRAM);
$readmemh("programs/tea_data.hex", `DRAM);
```

Luego verifica llaves, texto plano, texto cifrado y roundtrip esperado.

## Interaccion con la herramienta de carga de archivos

La carpeta `arqui/scripts/` contiene herramientas Python para mover archivos
externos hacia la RAM simulada y recuperar resultados.

### Carga de archivos

`load_file.py` convierte cualquier archivo binario a una imagen compatible con
`$readmemh`. Cada linea representa un byte y puede incluir una directiva de
direccion inicial:

```bash
python arqui/scripts/load_file.py \
  --input arqui/scripts/examples/foto.jpg \
  --output arqui/scripts/examples/foto.mem \
  --address 0x2000
```

Salida generada:

```text
@2000
48
6F
6C
61
```

La direccion debe estar dentro de la RAM de 64 KiB. El script valida que el
archivo completo quepa en el rango disponible y reporta cantidad de bytes y
rango usado.

Para usar la imagen en simulacion, se puede copiar o referenciar como
`programs/data.hex`, o cargarla desde un testbench con `$readmemh` sobre
`dut.mem.NormalRam.mem`.

### Extraccion de resultados

`extract_data.py` lee un dump `.mem`/`.hex` con directivas `@direccion` y extrae
un rango de bytes hacia un archivo binario:

```bash
python arqui/scripts/extract_data.py \
  --memory arqui/scripts/examples/foto.mem \
  --address 0x2000 \
  --size 4096 \
  --output arqui/scripts/examples/foto_resultado.jpg
```

Esto permite validar transformaciones sobre archivos completos: imagenes,
textos, binarios o cualquier otro formato tratado como bytes crudos.

## Archivos generados

La simulacion produce salidas bajo `arqui/sim/`:

| Ruta | Contenido |
| --- | --- |
| `sim/build/` | Ejecutables `.vvp` generados por Icarus Verilog. |
| `sim/waves/` | Formas de onda `.vcd`. |
| `sim/gtkwave/` | Configuraciones opcionales para GTKWave. |

Los archivos de programa y memoria usados por el modelo se encuentran en
`arqui/programs/`, por ejemplo:

| Archivo | Uso |
| --- | --- |
| `program.hex` | Programa por defecto cargado por `instr_rom.sv`. |
| `data.hex` | Datos por defecto cargados por `data_ram.sv`. |
| `neather.hex` | Contenido inicial de RAM Vault. |
| `tea.hex` | Programa TEA. |
| `tea_data.hex` | Datos de entrada para prueba TEA. |

## Resumen del modelo

El modelo de simulacion reproduce el comportamiento ciclo a ciclo del procesador
Craft21 usando RTL SystemVerilog. Los bancos de registros, ALU, unidad de
control, memorias y boveda se prueban de forma aislada y tambien integrados en
`top.sv`. Los programas compilados se cargan como imagenes `$readmemh`, se
ejecutan hasta `freeze` o timeout, y los resultados se verifican por inspeccion
directa de registros y memoria. La herramienta Python de carga/extraccion
permite incluir archivos reales en RAM y recuperar los datos generados por la
simulacion.
