module execute(
    input logic jump, blt, bne, beq,
    input logic [1:0] result_src,
    input logic neather_wreg_src, w_memv, we_mem, size, 
    input logic neather_portalIN,
    input logic [4:0] alu_control,
    input logic [1:0] alu_src,
    input logic we_reg, neather_mode, w_regV
    input logic [31:0] rd1E, rd2E, immE, pc_actE, wdE, pc_plus4E, rdV2E, wdVE,

    output logic pc_srcEx, neather_portalOUT,
    output logic result_srcOUT, neather_wreg_srcOUT, w_memvOUT, we_memOUT, 
    output logic sizeOUT, we_regOUT, neather_modeOUT, w_regVOUT,

    output logic [31:0] alu_result, rd2OUT, rdV2OUT, wdOUT, pc_plus4OUT, wdVOUT
    output logic [31:0] pc_targetOUT
);

logic tea_src;

assign tea_src = alu_control[0];

// ==========================================================
//                       INSTANCIA MUX31
// ==========================================================

mux31 mux31 (
    .in1(),
    .in2(),
    .src(),
    .out()

);

// Señales de compuertas and

// ==========================================================
//                       INSTANCIA OR5GATE
// ==========================================================

orgate5 orgate5 (
    .in1(jump),
    .in2(),
    .in3(),
    .in4(),
    .in5(),
    .out(pc_srcEx)
);

endmodule