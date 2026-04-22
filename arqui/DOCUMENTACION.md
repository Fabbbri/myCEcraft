En este archivo va la docu...

## Extensión de inmediatos 

Se tienen las siguientes tipos de instrucciones con inmediatos: I, S, J, B

De estas operaciones se tiene que:
- S y J usan bits del 4 al 27
- I y B usan bits del 4 al 31

### Tipo S

Para los tipo S de opcode `0010` (para ST/LD de Word), `0011` (para ST/LD de Byte) y `1110` (para ST/LD de vault) se tiene:

| func[19] | inmediatos [12:0] | nemónico |
|--------------|--------------|--------------|
| 0      | [27:20][8:4]      | sw     |
| 1      | [27:20][18:14]      | lw     |
| 0      | [27:20][8:4]      | sb     |
| 1      | [27:20][18:14]      | lb     |
| 0      | [27:20][8:4]      | sb     |
| 1      | [27:20][18:14]      | lb     |

Todos estos tienen como bit de signo al bit 27
El func 19 indica si es un sw o lw, o sea, si tiene que agarrar a los bits [18:14] o a los bits [8:4] para formar 13 bits

| Imm | Bits reales |
|--------------|--------------|
| 0      | 4 o 14      |
| 1      | 5 o 15     |
| 2      | 6 o 16     |
| 3      | 7 o 17     |
| 4      | 8 o 18     |
| 5      | 20     |
| 6      | 21     |
| 7      | 22     |
| 8      | 23     |
| 9      | 24     |
| 10     | 25     |
| 11     | 26     |
| 12     | 27     |

### Tipo J

Para los tipo J de opcode `0100` se tiene:

| func[19] | inmediatos [17:0] | nemónico |
|--------------|--------------|--------------|
| 0      | [27:20][18:14][13:9]      | jal     |
| 1      | [27:20][18:14][13:9]      | jalr    |

Todos estos tienen como bit de signo al bit 27
El func 19 indica si es un jal o un jalr. Siempre agarra los mismos bits para formar 18 bits

| Imm | Bits reales |
|--------------|--------------|
| 0      | 9      |
| 1      | 10     |
| 2      | 11     |
| 3      | 12     |
| 4      | 13     |
| 5      | 14     |
| 6      | 15     |
| 7      | 16     |
| 8      | 17     |
| 9      | 18     |
| 10     | 20     |
| 11     | 21     |
| 12     | 22     |
| 13     | 23     |
| 14     | 24     |
| 15     | 25     |
| 16     | 26     |
| 17     | 27     |

### Tipo B:

Para los tipo B de opcode `0110` 

| func[23:19] | inmediatos [16:0] | nemónico |
|--------------|--------------|--------------|
| 00000      | [31:24][8:4]      | beq     |
| 00001      | [31:24][8:4]      | bne     |
| 00010      | [31:24][8:4]      | blt     |
| 00011      | [31:24][8:4]      | bge     |
| 00100      | [31:24][8:4]      | portalv |

Dónde func permite diferenciar el tipo de operación y la combinación `00100` activa el ENABLE_SECURE_MODE_REG

| Imm | Bits reales |
|--------------|--------------|
| 0      | 4      |
| 1      | 5      |
| 2      | 6      |
| 3      | 7      |
| 4      | 8      |
| 5      | 24     |
| 6      | 25     |
| 7      | 26     |
| 8      | 27     |
| 9      | 28     |
| 10     | 29     |
| 11     | 30     |
| 12     | 31     |

### Tipo I

Los tipo I, de opcode = `0001` y `1011` para los de bóveda. Utilizan un func para determinar el tipo de operación, pero no tiene que ver con los inmediatos a elegir, para todos, tanto I como IV, usan los bits 31 a 16 para formar 16 bits.

| func[15:14] | inmediatos [15:0] | nemónico |
|--------------|--------------|--------------|
| 00      | [31:16]      | addi    |
| 01      | [31:16]      | addiHIGH     |
| 10      | [31:16]      | addiSIGNED     |
| 11      | [31:16]      | PAUSE/NOP     |
| 00      | [31:16]      | addiLOWv |
| 01      | [31:16]      | addiHIGHv |

| Imm | Bits reales |
|--------------|--------------|
| 0      | 16     |
| 1      | 17     |
| 2      | 18     |
| 3      | 19     |
| 4      | 20     |
| 5      | 21     |
| 6      | 22     |
| 7      | 23     |
| 8      | 24     |
| 9      | 25     |
| 10     | 26     |
| 11     | 27     |
| 12     | 28     |
| 13     | 29     |
| 14     | 30     |
| 15     | 31     |

## ALU

Las operaciones tipo R tienen todas `opcode [3:0] = 0000`

| func[21:19] | índice | nemónico |
|--------------|--------------|--------------|
| Celda 1      | 1      | add     |
| Celda 3      | 2      | sub     |
| Celda 1      | 3      | sll     |
| Celda 3      | 4      | slt     |
| Celda 1      | 5      | xor     |
| Celda 3      | 6      | srl     |
| Celda 3      | 7      | sra     |
| Celda 3      | 8      | or     |
| Celda 3      | 9      | mul     |
| Celda 3      | 10      | div    |

Se tienen 10 operaciones:

- `add` realiza rs1 + rs2 y lo guarda en rd.
- `sub` realiza rs1 - rs2 y lo guarda en rd.
- `sll` realiza rs1 << rs2 y lo guarda en rd.
- `slt` realiza rs1 + rs2 y lo guarda en rd.
