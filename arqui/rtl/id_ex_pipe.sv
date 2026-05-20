module id_ex_pipe (
    input  logic clk,
    input  logic reset,

    input  logic jump, blt, bge, bne, beq, 
    input logic [1:0] result_src, alu_src,
    input logic neather_wreg_src, w_memv, we_mem, size, neather_portal,
    input logic [4:0] alu_control,
    input logic we_reg, neather_mode, w_regv,
    input logic [31:0] rd1, rd2, imm, pc_act, pcplus4, rdv2, 
    input logic [4:0] instrD, rs1DIN, rsD2IN,

    // Hazard Unit
    input logic flushE,

    output  logic jumpOUT, bltOUT, bgeOUT, bneOUT, beqOUT, 
    output logic [1:0] result_srcOUT, alu_srcOUT,
    output logic neather_wreg_srcOUT, w_memvOUT, we_memOUT, sizeOUT, neather_portalOUT,
    output logic [4:0] alu_controlOUT,
    output logic we_regOUT, neather_modeOUT, w_regvOUT,
    output logic [31:0] rd1OUT, rd2OUT, immOUT, pc_actOUT, pcplus4OUT, rdv2OUT, 
    output logic [4:0] instrDOUT, rs1DOUT, rs2DOUT
);

always_ff @(posedge clk or posedge reset) begin
    if (reset || flushE) begin // si es reset o flushE, se inserta un nop
        jumpOUT              <= 1'b0;
        bltOUT               <= 1'b0;
        bgeOUT               <= 1'b0;
        bneOUT               <= 1'b0;
        beqOUT               <= 1'b0;
        result_srcOUT        <= 2'b0;
        alu_srcOUT           <= 2'b0;
        neather_wreg_srcOUT  <= 1'b0;
        w_memvOUT            <= 1'b0;
        we_memOUT            <= 1'b0;
        sizeOUT              <= 1'b0;
        neather_portalOUT    <= 1'b0;
        alu_controlOUT       <= 5'b0;
        we_regOUT            <= 1'b0;
        neather_modeOUT      <= 1'b0;
        w_regvOUT            <= 1'b0;
        rd1OUT               <= 32'b0;
        rd2OUT               <= 32'b0;
        immOUT               <= 32'b0;
        pc_actOUT            <= 32'b0;
        pcplus4OUT           <= 32'b0;
        rdv2OUT              <= 32'b0;
        instrDOUT            <= 5'b0;
        rs1DOUT                <= 5'b0;
        rs2DOUT               <= 5'b0;
    end else begin
        jumpOUT              <= jump;
        bltOUT               <= blt;
        bgeOUT               <= bge;
        bneOUT               <= bne;
        beqOUT               <= beq;
        result_srcOUT        <= result_src;
        alu_srcOUT           <= alu_src;
        neather_wreg_srcOUT  <= neather_wreg_src;
        w_memvOUT            <= w_memv;
        we_memOUT            <= we_mem;
        sizeOUT              <= size;
        neather_portalOUT    <= neather_portal;
        alu_controlOUT       <= alu_control;
        we_regOUT            <= we_reg;
        neather_modeOUT      <= neather_mode;
        w_regvOUT            <= w_regv;
        rd1OUT               <= rd1;
        rd2OUT               <= rd2;
        immOUT               <= imm;
        pc_actOUT            <= pc_act;
        pcplus4OUT           <= pcplus4;
        rdv2OUT              <= rdv2;
        instrDOUT            <= instrD;
        rs1DOUT              <= rs1DIN;
        rs2DOUT              <= rs1DIN;
    end
end

endmodule