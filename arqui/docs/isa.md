# Arquitectura del set de instrucciones Craft21

Craft21 es una ISA RISC de 32 bits disenada para el proyecto myCEcraft. La
arquitectura usa instrucciones de longitud fija, campos de registros de 5 bits y
un conjunto pequeno de formatos para simplificar el decodificador, la unidad de
control y el pipeline. Ademas del banco de registros general, incluye un banco y
una memoria especiales de boveda para proteger llaves y apoyar rutinas de
cifrado como TEA.

## Objetivos de diseño

- Mantener un datapath simple: instrucciones de 32 bits, opcode de 4 bits y
  campos de registros uniformes.
- Reducir area y complejidad de control usando pocos formatos: R, I, S, J, B,
  Vault Reg, Vault S y IV.
- Separar datos normales de datos sensibles: registros `v*` y memoria Vault solo
  se escriben en modo seguro.
- Facilitar al compilador la generacion de codigo: sintaxis tipo RISC con
  operandos explicitos y offsets relativos ya resueltos.
- Soportar TEA sin agregar una unidad criptografica grande: la rutina se expresa
  con ALU, memoria y operaciones Vault especializadas.

## Modelo de maquina

- Palabra de instruccion: 32 bits.
- PC: direcciona instrucciones alineadas a 4 bytes; el flujo normal avanza con
  `PC + 4`.
- Banco general: 32 registros de 32 bits (`x0` a `x31`).
- Banco Vault: 32 registros de 32 bits (`v0` a `v31`), habilitados para escritura
  solo cuando Secure Mode esta activo.
- Memoria de datos normal: accesible con `lw`, `sw`, `lb` y `sb`.
- Memoria Vault: accesible con `lwv` y `swv` durante Secure Mode.
- Orden de bytes en seccion `.data`: los datos del compilador se emiten en
  little endian para `.word`, `.half` y `.byte`.

## Tipos y tamanos de datos

| Tipo | Tamano | Instrucciones | Uso |
| --- | --- | --- | --- |
| Byte | 8 bits | `lb`, `sb` | Caracteres, buffers y datos compactos. |
| Half | 16 bits | Directiva `.half` | Datos en memoria generados por el ensamblador/binario. |
| Word | 32 bits | ALU, `lw`, `sw`, `lwv`, `swv` | Enteros, direcciones, llaves y bloques TEA. |
| Inmediato I | 16 bits | `addi`, `addiHIGH`, `addiSigned`, `addiLOWv`, `addiHIGHv` | Constantes y construccion de valores de 32 bits. |
| Offset S/VS | 13 bits con signo | `lw`, `sw`, `lb`, `sb`, `lwv`, `swv` | Acceso base + desplazamiento. |
| Offset B | 15 bits codificados con alineamiento a 4 | `beq`, `bne`, `blt`, `bge`, `portalv` | Saltos condicionales relativos al PC. |
| Offset J | 20 bits codificados con alineamiento a 4 | `jal`, `jalr` | Saltos y llamadas. |

## Registros disponibles

Los campos de registro son de 5 bits. Por eso la ISA puede direccionar 32
registros generales y 32 registros Vault con el mismo ancho de campo.

**Table 1: Registros Craft21**

| Indice | Register | ABI Name | Description | Saver |
| --- | --- | --- | --- | --- |
| 1 | x0 | zero | Wired zero | - |
| 2 | x1 | ra | Return address | Caller |
| 3 | x2 | sp | Stack pointer | Callee |
| 4-11 | x3-10 | t0-t7 | Temporaries | Caller |
| 12-13 | x11-12 | a0-a1 | Return Values / function arguments | Caller |
| 14-17 | x13-16 | a2-a5 | Extra function arguments | Caller |
| 18 | x17 | s0/fp | Frame pointer / saved register | Callee |
| 19-20 | x18-19 | reserved | Reserved registers | - |
| 21-32 | x20-31 | s1-s12 | Saved registers | Callee |
| 1' | v0 | rpass | Password container | VaultCaller |
| 2'-5' | v1-4 | key0-3 | Key registers | VaultCaller |
| 6'-32' | v5-31 | reserved | Extra Vault registers | VaultCaller |

`x0` siempre lee cero y sirve para construir constantes o descartar resultados.
`x1` guarda direcciones de retorno. `x2` apunta a la pila. `x17` funciona como
frame pointer. Los registros temporales son responsabilidad del llamador; los
registros salvados deben preservarse por la funcion llamada. Los registros Vault
son volatiles desde el punto de vista de llamadas y se limpian/cambian alrededor
de Secure Mode.

## Modos de direccionamiento

| Modo | Forma | Ejemplo | Descripcion |
| --- | --- | --- | --- |
| Registro-registro | `op rd, rs1, rs2` | `add x3, x4, x5` | Opera con dos registros fuente. |
| Inmediato | `op rd, rs1, imm` | `addi x3, x0, 10` | Suma o carga constantes de 16 bits. |
| Memoria base + offset | `op reg, off(base)` | `lw x3, 8(x2)` | Direccion efectiva `base + off`. |
| Branch relativo | `op rs1, rs2, off` | `beq x3, x4, -16` | Cambia el PC si se cumple la condicion. |
| Jump relativo | `jal rd, off` | `jal x1, 32` | Escribe retorno en `rd` y salta. |
| Jump indirecto | `jalr rd, off` | `jalr x1, 0` | Usa el formato J con funcion de retorno indirecto. |
| Vault base + offset | `op vreg, off(vbase)` | `lwv v1, 0(v0)` | Acceso a memoria Vault en Secure Mode. |
| Portal Vault | `portalv pass, rv, off` | `portalv x3, v0, 128` | Autentica y activa Secure Mode si la comparacion es valida. |

Los offsets de branch y jump deben estar alineados a 4 bytes. El compilador
resuelve etiquetas a offsets numericos antes de generar el binario.

## Sintaxis de ensamblador

La sintaxis usa el mnemonico seguido por operandos separados por coma:

```asm
add rd, rs1, rs2
addi rd, rs1, imm16
lw rd, offset(rs1)
sw rs2, offset(rs1)
beq rs1, rs2, offset
jal rd, offset
portalv pass, rpass, offset
lwv rdv, offset(rbasev)
swv rsv, offset(rbasev)
closev
freeze
```

Los registros pueden escribirse con nombre fisico (`x3`, `v1`) o con alias ABI
cuando el compilador lo permite (`t0`, `a0`, `sp`, `rpass`, `key0`). Los
inmediatos aceptan decimal o hexadecimal, por ejemplo `16` y `0x10`.

## Formatos y codificacion

El opcode ocupa los bits `3:0`. Los campos de registros ocupan 5 bits. Los
inmediatos se dividen para reutilizar rutas de datos y mantener el decodificador
compacto.

| Formato | Bits principales | Uso |
| --- | --- | --- |
| R | `[23:19]=func`, `[18:14]=rs2`, `[13:9]=rs1`, `[8:4]=rd`, `[3:0]=opcode` | ALU y control especial. |
| I | `[31:16]=imm`, `[15:14]=func`, `[13:9]=rs1`, `[8:4]=rd`, `[3:0]=opcode` | Inmediatos. |
| S | `[27:20]=imm[12:5]`, `[19]=func`, `[18:14]`, `[13:9]`, `[8:4]`, `[3:0]=opcode` | Load/store normal. |
| J | `[27:20]=imm[19:12]`, `[19]=func`, `[18:14]=imm[11:7]`, `[13:9]=imm[6:2]`, `[8:4]=rd`, `[3:0]=opcode` | Saltos. |
| B | `[31:24]=imm[14:7]`, `[23:19]=func`, `[18:14]=rs2`, `[13:9]=rs1`, `[8:4]=imm[6:2]`, `[3:0]=opcode` | Branch y portal. |
| Vault S | Igual a S, pero con registros/memoria Vault | `swv`, `lwv`. |
| Vault Reg | Igual a R, pero con semantica Vault | `sllv`, `slrv`, `changev`, `closev`. |
| IV | Igual a I, pero destino Vault | `addiLOWv`, `addiHIGHv`. |

## Familias de instrucciones

### ALU

Las instrucciones tipo R ejecutan operaciones aritmeticas y logicas de 32 bits.
`sll`, `srl` y `sra` usan los 5 bits bajos de `rs2` como cantidad de
desplazamiento. `slt` compara con signo. `div` retorna cero si el divisor es
cero para evitar excepciones en hardware.

| Mnemonico | Sintaxis | Efecto |
| --- | --- | --- |
| `add` | `add rd, rs1, rs2` | `rd = rs1 + rs2` |
| `sub` | `sub rd, rs1, rs2` | `rd = rs1 - rs2` |
| `sll` | `sll rd, rs1, rs2` | `rd = rs1 << rs2[4:0]` |
| `slt` | `slt rd, rs1, rs2` | `rd = 1` si `rs1 < rs2`, si no `0` |
| `xor` | `xor rd, rs1, rs2` | XOR bit a bit |
| `srl` | `srl rd, rs1, rs2` | Corrimiento logico derecho |
| `sra` | `sra rd, rs1, rs2` | Corrimiento aritmetico derecho |
| `or` | `or rd, rs1, rs2` | OR bit a bit |
| `and` | `and rd, rs1, rs2` | AND bit a bit |
| `mul` | `mul rd, rs1, rs2` | Producto de 32 bits bajos |
| `div` | `div rd, rs1, rs2` | Division entera; cero si `rs2 = 0` |

### Memoria

`lw` y `sw` transfieren palabras de 32 bits. `lb` y `sb` transfieren bytes. La
direccion efectiva se calcula con la ALU como `rs1 + offset`.

| Mnemonico | Sintaxis | Efecto |
| --- | --- | --- |
| `lw` | `lw rd, off(rs1)` | Carga una palabra desde memoria normal. |
| `sw` | `sw rs2, off(rs1)` | Guarda una palabra en memoria normal. |
| `lb` | `lb rd, off(rs1)` | Carga un byte desde memoria normal. |
| `sb` | `sb rs2, off(rs1)` | Guarda un byte en memoria normal. |

### Control de flujo

Los branches comparan `rs1` y `rs2` usando la ALU. Si la condicion es verdadera,
el PC recibe `PC + offset`; si no, continua en `PC + 4`.

| Mnemonico | Sintaxis | Efecto |
| --- | --- | --- |
| `beq` | `beq rs1, rs2, off` | Salta si `rs1 == rs2`. |
| `bne` | `bne rs1, rs2, off` | Salta si `rs1 != rs2`. |
| `blt` | `blt rs1, rs2, off` | Salta si `rs1 < rs2`. |
| `bge` | `bge rs1, rs2, off` | Salta si `rs1 >= rs2`. |
| `jal` | `jal rd, off` | `rd = PC + 4`; salta relativo. |
| `jalr` | `jalr rd, off` | Retorno/salto indirecto segun la ruta J del procesador. |
| `sleep` | `sleep` | No escribe registros; se usa como pausa/NOP. |
| `freeze` | `freeze` | Detiene el avance del PC para finalizar simulaciones. |

### Inmediatos

`addi` suma un inmediato sin signo de 16 bits. `addiSigned` usa extension de
signo. `addiHIGH` coloca el inmediato en la mitad alta, util para construir
constantes de 32 bits en dos instrucciones.

```asm
addiHIGH x3, x0, 0x1234
addi     x3, x3, 0x5678
```

### Boveda de llaves y Secure Mode

La boveda separa secretos del banco general. `portalv` compara/autentica la
clave de entrada y, si el resultado es valido, activa Secure Mode. Mientras ese
modo esta activo, el procesador permite escritura en registros Vault y memoria
Vault. `closev` cierra el modo seguro y resetea el flujo Vault.

| Mnemonico | Sintaxis | Efecto |
| --- | --- | --- |
| `portalv` | `portalv pass, rpass, off` | Abre Secure Mode y puede desviar el flujo. |
| `lwv` | `lwv rdv, off(rbasev)` | Carga una palabra desde memoria Vault. |
| `swv` | `swv rsv, off(rbasev)` | Guarda una palabra en memoria Vault. |
| `changev` | `changev rdv, rsv` | Copia/cambia registros Vault. |
| `changev` | `changev rdv, rs1, rs2` | Construye/cambia un valor Vault desde registros generales. |
| `closev` | `closev` | Cierra Secure Mode. |
| `addiLOWv` | `addiLOWv rdv, rsv, imm` | Ajusta 16 bits bajos de un registro Vault. |
| `addiHIGHv` | `addiHIGHv rdv, rs1, imm` | Ajusta 16 bits altos hacia destino Vault. |

### Cifrado TEA

TEA requiere operaciones de suma modular, XOR, desplazamientos y acceso a cuatro
llaves de 32 bits. Craft21 lo soporta con:

- ALU normal: `add`, `xor`, `sll`, `srl`, `and`, `or` y comparaciones para el
  ciclo de rondas.
- Memoria normal: lectura/escritura de bloques de datos cifrados.
- Boveda: `portalv`, `lwv`, `swv`, `changev`, `closev` y registros `key0-key3`
  para cargar y proteger llaves.
- Operaciones In-Vault: `sllv` y `slrv`, usadas como apoyo para desplazamientos
  y combinaciones con datos Vault sin exponer todos los valores al banco general.

La decision evita una unidad TEA dedicada, que aumentaria area y verificacion.
El costo es mas instrucciones por bloque, pero el procesador conserva una ALU
general pequena y reutilizable.

## Justificacion de caracteristicas

| Caracteristica | Justificacion |
| --- | --- |
| Instrucciones de 32 bits | Simplifican fetch, decode y pipeline; no se requiere manejar instrucciones variables. |
| Opcode de 4 bits | Alcanza para las familias actuales y reduce logica de decodificacion. |
| Registros de 5 bits | Permiten 32 registros sin campos especiales. |
| `x0` cableado a cero | Reduce instrucciones necesarias para constantes, movimientos y comparaciones. |
| Formatos parecidos a RISC | Facilitan al compilador, al ensamblador y a los testbenches generar binario. |
| Inmediatos divididos | Reutilizan campos ya existentes y evitan ampliar multiplexores. |
| Separacion Vault | Protege llaves y datos sensibles con poco hardware adicional: banco Vault, RAM Vault y bandera Secure Mode. |
| `portalv`/`closev` | Delimitan claramente el acceso seguro y simplifican la politica de control. |
| TEA por software | Menor area que un acelerador dedicado; suficiente para validar cifrado en el proyecto. |
| `freeze` | Permite terminar simulaciones de forma observable deteniendo el PC. |

## Hoja de referencia rapida

### Table 2: Operaciones tipo R

| 23:19 | 18:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- |
| func | rs2 | rs1 | rd | opcode |  |
| 00000 | rs2 | rs1 | rd | 0000 | add |
| 00001 | rs2 | rs1 | rd | 0000 | sub |
| 00010 | rs2 | rs1 | rd | 0000 | sll |
| 00011 | rs2 | rs1 | rd | 0000 | slt |
| 00100 | rs2 | rs1 | rd | 0000 | xor |
| 00101 | rs2 | rs1 | rd | 0000 | srl |
| 00110 | rs2 | rs1 | rd | 0000 | sra |
| 00111 | rs2 | rs1 | rd | 0000 | or |
| 01000 | rs2 | rs1 | rd | 0000 | and |
| 01001 | rs2 | rs1 | rd | 0000 | mul |
| 01010 | rs2 | rs1 | rd | 0000 | div |
| 01011 | x0 | x0 | x0 | 0000 | sleep |
| 01100 | x0 | x0 | x0 | 0000 | freeze |

### Table 3: Operaciones tipo I

| 31:16 | 15:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- |
| imm [15:0] | func[1:0] | rs1 | rd | opcode |  |
| imm [15:0] | 00 | rs1 | rd | 0001 | addi |
| imm [15:0] | 01 | rs1 | rd | 0001 | addiHIGH |
| imm [15:0] | 10 | rs1 | rd | 0001 | addiSigned |

### Table 4: Operaciones tipo S

| 27:20 | func [19] | 18:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- | --- |
| imm[12:5] | func [19] | rs2/imm[4:0] | rs1 | imm[4:0]/rd | opcode |  |
| imm[12:5] | 0 | rs2 | rs1 | imm[4:0] | 0010 | sw |
| imm[12:5] | 1 | imm[4:0] | rs1 | rd | 0010 | lw |
| imm[12:5] | 1 | imm[4:0] | rs1 | rd | 0011 | lb |
| imm[12:5] | 0 | rs2 | rs1 | imm[4:0] | 0011 | sb |

### Table 5: Operaciones tipo J

| 27:20 | 23:19 | 18:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- | --- |
| imm[19:12] | func | imm[11:7] | imm[6:2] | rd | opcode |  |
| imm[19:12] | 00000 | imm[11:7] | imm[6:2] | rd | 0100 | jal |
| imm[19:12] | 00001 | imm[11:7] | imm[6:2] | rd | 0100 | jalr |

### Table 6: Operaciones tipo B

| 31:24 | 23:19 | 18:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- | --- |
| imm[14:7] | func | rs2 | rs1 | imm[6:2] | opcode |  |
| imm[14:7] | 00000 | rs2 | rs1 | imm[6:2] | 0110 | beq |
| imm[14:7] | 00001 | rs2 | rs1 | imm[6:2] | 0110 | bne |
| imm[14:7] | 00010 | rs2 | rs1 | imm[6:2] | 0110 | blt |
| imm[14:7] | 00011 | rs2 | rs1 | imm[6:2] | 0110 | bge |
| imm[14:7] | 00100 | rv/pass | rs1 | imm[6:2] | 0110 | portalv |

### Table 7: Operaciones PrepareVault (Vault S)

| 27:20 | func [19] | 18:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- | --- |
| imm[12:5] | func [19] | rv/imm[4:0] | rs1 | imm[4:0]/rdv | opcode |  |
| imm[12:5] | 0 | rv | rs1 | imm[4:0] | 1110 | swv |
| imm[12:5] | 1 | imm[4:0] | rs1 | rdv | 1110 | lwv |

### Table 8: Operaciones In-Vault (Vault Reg)

| 23:19 | 18:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- |
| func | rs2 | rs1 | rd | opcode |  |
| 00000 | rv | rs1 | rd | 1010 | sllv |
| 00001 | rv | rs1 | rd | 1010 | slrv |
| 00000 | rs2 | rs1 | rdv | 1011 | changev |
| 00000 | zero | x21 | zero | 1100 | closev |

### Table 9: Operaciones Login (Vault B)

| 31:24 | 23:19 | 18:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- | --- |
| imm[14:7] | 00100 | rv1/pass | rs1 | imm[6:2] | 0110 | portalv |

### Table 10: Operaciones tipo IV

| 31:16 | 15:14 | 13:9 | 8:4 | 3:0 | Mnemonico |
| --- | --- | --- | --- | --- | --- |
| imm [15:0] | func[1:0] | rs1 | rdv | opcode |  |
| imm [15:0] | 00 | rs1 | rdv | 1111 | addiLOWv |
| imm [15:0] | 01 | rs1 | rdv | 1111 | addiHIGHv |