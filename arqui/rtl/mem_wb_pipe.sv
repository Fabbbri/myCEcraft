module mem_wb_pipe(
    input  logic clk,
    input  logic reset,

    input logic [1:0] result_src, 
    input logic neather_wreg_src,
    input logic we_reg, neather_mode, w_regv,
    input logic [31:0] rMemData,  alu_result, rvMemData, pcPlus4,
    input logic [4:0] instrD, 

    output logic [1:0] result_srcOUT, 
    output logic neather_wreg_srcOUT,
    output logic we_regOUT, neather_modeOUT, w_regvOUT,
    output logic [31:0] rMemDataOUT,  alu_resultOUT, rvMemDataOUT, pcPlus4OUT,
    output logic [4:0] instrDOUT
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        result_srcOUT       <= 2'b0;
        neather_wreg_srcOUT <= 1'b0;
        we_regOUT           <= 1'b0;
        neather_modeOUT     <= 1'b0;
        w_regvOUT           <= 1'b0;
        rMemDataOUT         <= 32'b0;
        alu_resultOUT        <= 32'b0;
        rvMemDataOUT        <= 32'b0;
        pcPlus4OUT          <= 32'b0;
        instrDOUT           <= 5'b0;
    end else begin
        result_srcOUT       <= result_src;
        neather_wreg_srcOUT <= neather_wreg_src;
        we_regOUT           <= we_reg;
        neather_modeOUT     <= neather_mode;
        w_regvOUT           <= w_regv;
        rMemDataOUT         <= rMemData;
        alu_resultOUT        <= alu_result;
        rvMemDataOUT        <= rvMemData;
        pcPlus4OUT          <= pcPlus4;
        instrDOUT           <= instrD;
    end
end

endmodule