module imm_extend(
    input  logic [27:0]  imm, // bits 31 a 4
    input logic [1:0] imm_src,
    input logic imms_src2
    output logic [31:0] imm_extended // extendido
);

/*
Señal de control: 

TEMP_SIGNAL = {WE_REG, IMM_SCR[1], IMM_SRC[2]}

ST(001) o LW (100)
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


JUMP (101) jalr o (000) jal
| Imm | Bits reales |
|--------------|--------------|
| 2      | 9      |
| 3      | 10     |
| 4      | 11     |
| 5      | 12     |
| 6      | 13     |
| 7      | 14     |
| 8      | 15     |
| 9      | 16     |
| 10      | 17     |
| 11      | 18     |
| 12     | 20     |
| 13     | 21     |
| 14     | 22     |
| 15     | 23     |
| 16     | 24     |
| 17     | 25     |
| 18     | 26     |
| 19     | 27     |

BRANCH (010)
| Imm | Bits reales |
|--------------|--------------|
| 2      | 4      |
| 3      | 5      |
| 4      | 6      |
| 5      | 7      |
| 6      | 8      |
| 7      | 24     |
| 8      | 25     |
| 9      | 26     |
| 10     | 27     |
| 11     | 28     |
| 12     | 29     |
| 13     | 30     |
| 14     | 31     |

IMMEDIATE (110) addi o (111) addi Signed
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


*/

/*
31 = 27
...
intern - 4 = real
...
4 = 0
*/

logic imm_src2;
logic [2:0] temp_signal;

assign temp_signal = {imm_src2, imm_src};

                        // SW
                        // Sign extended para SW [27:20][8:4], 12 bits y el de signo
                        // Puede no estar alineado 
                        // src = 001, 32 - 12 = 20
assign imm_extended = (temp_signal == 3'b001) ? {{20{imm[23]}}, imm[22:16], imm[4:0]}

                    // LW 
                    // Sign extended para LW [27:20][18:14]. 12 bits y el de signo
                    // Puede no estar alineado
                    // src = 100, 32 - 12 = 20
                    : (temp_signal == 3'b100) ? {{20{imm[23]}}, imm[22:16], imm[14:10]}

                    // Sign extended para J [27:20][18:14][13:9]. 
                    // Total de 17 bits y el bit de signo 
                    // 2 0s al final para alineamiento
                    // src = 101 (jalr) o 000 (jal), 32 - 17 = 15 - 2 = 13
                    : (temp_signal == 3'b101) ? {{13{imm[23]}}, imm[22:16], imm[14:10], imm[9:5], 2'b00}
                    : (temp_signal == 3'b000) ? {{13{imm[23]}}, imm[22:16], imm[14:10], imm[9:5], 2'b00}

                    // Sign extended para B [31:24][8:4] 
                    // Total de 12 bits y el bit de signo
                    // 2 0s al final para alineamiento
                    // src = 010, 32 - 12 = 20 - 2 = 18
                    : (temp_signal == 3'b010) ? {{18{imm[27]}}, imm[26:20], imm[4:0], 2'b00}
                    
                    // Sign extended para I [31:16]
                    // Total de 16 bits (o 15 y el de signo)
                    // Puede no estar alineado
                    // src = (110) addiUnsigned o (111) addiSigned, 32 - 16 = 16, 32 - 15 = 17
                    // 
                    : (temp_signal == 3'b110) ? {{16{1'b0}}, imm[27:12]}
                    : (temp_signal == 3'b111) ? {{17{imm[27]}}, imm[26:12]}

                    : (temp_signal == 3'b011) ? {imm[27:12], {16{1'b0}}} // addiHIGH (011)

                    : 32'b0;

endmodule