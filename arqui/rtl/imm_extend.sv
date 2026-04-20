module imm_extend(
    input  logic [21:0]  imm, // bits 25 a 4
    input logic [1:0] imm_src,
    output logic [31:0] imm_extended // extendido
);

/*
imm = intern
25 = 21             13 = 9
24 = 20             12 = 8
23 = 19             11 = 7
22 = 18             10 = 6
21 = 17             9 = 5
20 = 16             8 = 4
19 = 15             7 = 3
18 = 14             6 = 2
17 = 13             5 = 1
16 = 12             4 = 0
15 = 11
14 = 10
*/

always_comb begin
    case (imm_src)
        // SW
        // Sign extended para SW (25:17 y 7:4). 12 bits y el de signo 
        // Puede no estar alineado 
        2'b00: imm_extended = {{20{imm[21]}}, imm[20:13], imm[3:0]};

        // LW 
        // Sign extended para LW (25:17 y 15:12). 12 bits y el de signo
        // Puede no estar alineado
        2'b01: imm_extended = {{20{imm[21]}}, imm[20:13], imm[11:8]};

        // Sign extended para J (25:17 , 15:12	11:8). 
        // Total de 16 bits y el bit de signo 
        // 2 0s al final para alineamiento
        2'b10: imm_extended = {{14{imm[21]}}, imm[20:13], imm[11:8], imm[7:4], 2'b00};

        // Sign extended para B (25:17 y 7:4) 
        // Total de 12 bits y el bit de signo
        // 2 0s al final para alineamiento
        2'b11: imm_extended = {{18{imm[21]}}, imm[20:13], imm[3:0], 2'b00};

    endcase
end

endmodule