module ex_mem_pipe (
    input  logic clk,
    input  logic reset,

    input logic [1:0] result_src,
    input logic neather_wreg_src, w_memv, we_mem, size,
    input logic we_reg, neather_mode, w_regv,
    input logic [31:0] alu_result, rd2, rdv2, pcPlus4,
    input logic [4:0] instrD,

    // Hazard Unit
    input logic stallM,

    output logic [1:0] result_srcOUT,
    output logic neather_wreg_srcOUT, w_memvOUT, we_memOUT, sizeOUT,
    output logic we_regOUT, neather_modeOUT, w_regvOUT,
    output logic [31:0] alu_resultOUT, rd2OUT, rdv2OUT, pcPlus4OUT,
    output logic [4:0] instrDOUT
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        result_srcOUT       <= 2'b0;
        neather_wreg_srcOUT <= 1'b0;
        w_memvOUT           <= 1'b0;
        we_memOUT           <= 1'b0;
        sizeOUT             <= 1'b0;
        we_regOUT           <= 1'b0;
        neather_modeOUT     <= 1'b0;
        w_regvOUT           <= 1'b0;
        alu_resultOUT       <= 32'b0;
        rd2OUT              <= 32'b0;
        rdv2OUT             <= 32'b0;
        pcPlus4OUT          <= 32'b0;
        instrDOUT           <= 5'b0;
    end else if (stallM) begin
        // hold — mantener valores actuales
    end else begin
        result_srcOUT       <= result_src;
        neather_wreg_srcOUT <= neather_wreg_src;
        w_memvOUT           <= w_memv;
        we_memOUT           <= we_mem;
        sizeOUT             <= size;
        we_regOUT           <= we_reg;
        neather_modeOUT     <= neather_mode;
        w_regvOUT           <= w_regv;
        alu_resultOUT       <= alu_result;
        rd2OUT              <= rd2;
        rdv2OUT             <= rdv2;
        pcPlus4OUT          <= pcPlus4;
        instrDOUT           <= instrD;
    end
end

endmodule