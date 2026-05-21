module execute(
    input logic jump, blt, bne, beq, bge,
    input logic [1:0] result_src,
    input logic neather_wreg_src, w_memv, we_mem, size, 
    input logic neather_portalIN,
    input logic [4:0] alu_control,
    input logic [1:0] alu_src,
    input logic we_reg, neather_mode, w_regv,
    input logic [31:0] rd1E, rd2E, immE, pc_actE, pc_plus4E, rdv2E,
    input logic [4:0] instrD, rs1EIN, rs2EIN,

    // Hazard Unit
    input logic [1:0] forwardA, forwardB,
    // forward
    input logic [31:0] ex_mem, mem_wb,

    output logic pc_srcEx, z_OUT, neather_portalOUT,
    output logic [1:0] result_srcOUT, 
    output logic neather_wreg_srcOUT, w_memvOUT, we_memOUT, 
    output logic sizeOUT, we_regOUT, neather_modeOUT, w_regvOUT,

    output logic [31:0] alu_result, rd2OUT, rdv2OUT, pc_plus4OUT,
    output logic [31:0] pc_targetOUT,
    output logic [4:0] instrDOUT, instrDOUT_hz, rs1EOUT, rs2EOUT,

    // Hazard Unit
    output logic result_src_0

);

// ==========================================================
//                       INSTANCIA TEA MUX31
// ==========================================================

logic tea_src;

assign tea_src = alu_control[0];

logic [31:0] d4;
logic [31:0] d5;
assign d4 = 32'd4;
assign d5 = 32'd5;

logic [31:0] tea01;

mux31 teaMux (
    .in1(d4),
    .in2(d5),
    .src(tea_src),
    .out(tea01)
);

// ==========================================================
//                       INSTANCIA PCTARG_SUM
// ==========================================================

logic [31:0] pc_target;
logic [31:0] pc_relative_target;
logic [31:0] jalr_target;
logic is_jalr;

sum31b pcTargetSum(
    .in1(immE),
    .in2(pc_actE),
    .out(pc_relative_target)
);

sum31b jalrTargetSum(
    .in1(immE),
    .in2(rd1E),
    .out(jalr_target)
);

assign is_jalr = jump && (result_src == 2'b00);
assign pc_target = is_jalr ? jalr_target : pc_relative_target;

// ==========================================================
//                       INSTANCIA FORWARD A MUX
// ==========================================================

logic [31:0] srcA;
logic [31:0] not_used;
assign not_used = 31'b0;

mux31_2 fwa_mux(
    .in1(rd1E),
    .in2(mem_wb),
    .in3(ex_mem),
    .in4(not_used),
    .src(forwardA),
    .out(srcA)
);

// ==========================================================
//                       INSTANCIA FORWARD B MUX
// ==========================================================

logic [31:0] srcB_hz;

mux31_2 fwb_mux(
    .in1(rd2E),
    .in2(mem_wb),
    .in3(ex_mem),
    .in4(not_used),
    .src(forwardB),
    .out(srcB_hz)
);

// ==========================================================
//                       INSTANCIA ALU_SRC MUX31_2
// ==========================================================

logic [31:0] srcB;

mux31_2 alu_mux(
    .in1(srcB_hz),
    .in2(tea01),
    .in3(rdv2E),
    .in4(immE),
    .src(alu_src),
    .out(srcB)
);

/*
always @(*) begin
    if (alu_src == 2'b00 || alu_src == 2'b11) begin
        $display("[EXEC] alu_src=%b rd1=%h srcB=%h immE=%h result=%h",
                  alu_src, rd1E, srcB, immE, alu_result);
    end
end
*/

// ==========================================================
//                       INSTANCIA ALU
// ==========================================================

logic v_flagUNUSED;
logic z_aux;
logic n_aux;

alu ALU(
    .srcA(srcA),
    .srcB(srcB),
    .alu_control(alu_control),
    .alu_result(alu_result),
    .z_flag(z_aux),
    .n_flag(n_aux),
    .v_flag(v_flagUNUSED)
);

// ==========================================================
//                       LÓGICA DE BRANCHES Y JUMP
// ==========================================================

logic notz;
logic notn;

assign notz = ~z_aux;
assign notn = ~n_aux;

// Compuertas AND

logic beqAND;
logic bneAND;

logic bgeOR;
logic bgeAND;

logic bltAND;

assign beqAND = beq & z_aux;
assign bneAND = bne & notz;

assign bgeOR = z_aux | notn;
assign bgeAND = bgeOR & bge;

assign bltAND = blt & n_aux;

// ==========================================================
//                       INSTANCIA OR5GATE
// ==========================================================

orgate5 TypeJ_OR(
    .in1(jump),
    .in2(beqAND),
    .in3(bneAND),
    .in4(bgeAND),
    .in5(bltAND),
    .out(pc_srcEx)
);

// ==========================================================
//                       OTRAS SEÑALES
// ==========================================================

assign result_srcOUT = result_src;
assign neather_wreg_srcOUT = neather_wreg_src;
assign w_memvOUT = w_memv;
assign we_memOUT = we_mem;
assign sizeOUT = size;

assign neather_portalOUT = neather_portalIN;
assign z_OUT = z_aux;

assign we_regOUT = we_reg;
assign neather_modeOUT = neather_mode;
assign w_regvOUT = w_regv; // DIRECCION CONTR

// NON CONTROL SIGNALS

assign rd2OUT = srcB_hz;
assign rdv2OUT = rdv2E;

assign instrDOUT = instrD;
assign pc_plus4OUT = pc_plus4E;

assign pc_targetOUT = pc_target;

// Hazard Unit 5 salidas
// pcSrcEx en top
assign rs1EOUT = rs1EIN;
assign rs2EOUT = rs2EIN;

assign instrDOUT_hz = instrD;
assign result_src_0 = result_src[0];

always @(*) begin
    $display("[EX] srcA=%h srcB=%h alu_ctrl=%b alu_src=%b immE=%h result=%h",
        srcA, srcB, alu_control, alu_src, immE, alu_result);
end

endmodule