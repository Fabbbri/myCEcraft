module imm_extend_itype(
    input  logic [15:0] imm,
    input  logic        imm_itype_src,
    output logic [31:0] imm_extended
);

/*
imm = intern
31 = 15             19 = 3
30 = 14             18 = 2
29 = 13             17 = 1
28 = 12             16 = 0
27 = 11             
26 = 10             
25 = 9            
24 = 8            
23 = 7             
22 = 6             
21 = 5
20 = 4
*/

assign imm_extended = (imm_itype_src == 1'b0) ? {{16{1'b0}}, imm}
                    : (imm_itype_src == 1'b1) ? {{17{imm[15]}}, imm[14:0]}
                    : 32'b0;

endmodule