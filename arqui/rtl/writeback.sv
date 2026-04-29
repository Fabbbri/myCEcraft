module writeback(
    input logic [1:0] result_src,
    input logic neather_wreg_src,
    input logic we_reg, neather_mode, w_regv,

    input logic [31:0] rMemData, alu_result, rvMemData, pc_plus4, 

    input logic pc_srcEx,
    input logic [31:0] pc_plus4F, pc_target_EX,
    input logic [4:0] instrD,

    output logic we_regOUT, neather_modeOUT, w_regvOUT,
    output logic [31:0] wdOUT, wdvOUT,

    output logic [31:0] new_addr,
    output logic [4:0] instrDOUT
);

// ==========================================================
//                       NEATHER WREG SRC
// ==========================================================

mux31 wreg_mux(
    .in1(alu_result),
    .in2(rvMemData),
    .src(neather_wreg_src),
    .out(wdvOUT)
);

// ==========================================================
//                       TEA_SUM
// ==========================================================

logic [31:0] teaSum11;

sum31b tea_sum(
    .in1(alu_result),
    .in2(rvMemData),
    .out(teaSum11)
);

// ==========================================================
//                       RESULT_SRC [1:0]
// ==========================================================

mux31_2 resultSRC_mux(
    .in1(alu_result), // 00
    .in2(rMemData), // 01
    .in3(pc_plus4),
    .in4(teaSum11),
    .src(result_src),
    .out(wdOUT)
);

// ==========================================================
//                       NEW PC MUX
// ==========================================================

mux31 new_pc_mux(
    .in1(pc_plus4F),
    .in2(pc_target_EX),
    .src(pc_srcEx),
    .out(new_addr)
);

// ==========================================================
//                       OTRAS SEÑALES
// ==========================================================

assign instrDOUT = instrD;
assign we_regOUT = we_reg;
assign w_regvOUT = w_regv;
assign neather_modeOUT = neather_mode;

endmodule