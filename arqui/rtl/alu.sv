module alu(

    input logic [31:0] srcA,
    input logic [31:0] srcB,
    input logic [4:0] alu_control,
    output logic [31:0] alu_result,
    output logic z_flag,
    output logic n_flag,
    output logic v_flag
);

logic [31:0] sum;
logic [31:0] sub;

assign sum = srcA + srcB;
assign sub = srcA - srcB; 

assign v_flag = (alu_control == 5'b00000) ? 
                ((srcA[31] ^ sum[31]) & ~(srcA[31] ^ srcB[31])) :

                (alu_control == 5'b00001) ? 
                ((srcA[31] ^ srcB[31]) & (srcA[31] ^ sub[31])) :

                1'b0;

assign z_flag = (alu_result == 32'b0);
assign n_flag = alu_result[31];

                    // SUMA
assign alu_result = (alu_control == 5'b00000) ? (sum)

                    // RESTA
                    : (alu_control == 5'b00001) ? (sub)

                    // SLL... 4:0 pues a lo mucho se hace con 32
                    : (alu_control == 5'b00010) ? (srcA << srcB[4:0])

                    // SLT
                    : (alu_control == 5'b00011) ? {31'b0, (sub[31] ^ v_flag)} 

                    // XOR
                    : (alu_control == 5'b00100) ? (srcA ^ srcB)

                    // SRL... 4:0 pues a lo mucho se hace con 32
                    : (alu_control == 5'b00101) ? (srcA >> srcB[4:0])

                    // SRA
                    : (alu_control == 5'b00110) ? (32'($signed(srcA) >>> srcB[4:0]))

                    // OR
                    : (alu_control == 5'b00111) ? (srcA | srcB)

                    // AND
                    : (alu_control == 5'b01000) ? (srcA & srcB)

                    // MUL
                    : (alu_control == 5'b01001) ? (srcA * srcB)

                    // DIV
                    : (alu_control == 5'b01010) ? (srcB != 0 ? (srcA / srcB) : 32'b0)

                    : 32'b0;

endmodule