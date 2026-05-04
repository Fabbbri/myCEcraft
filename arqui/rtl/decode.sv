module decode(
    input logic clk,

    input logic [31:0] instr, pc_plus4, pc_act,
    input logic neather_portal, z, we_regWB, w_regvWB, neather_modeWB,
    input logic [31:0] wd, wdv,
    input logic [4:0] instrDIN,

    output logic jump, blt, bge, bne, beq, 
    output logic [1:0] result_src, alu_src,
    output logic neather_wreg_src, w_memv, we_mem, size, neather_portalOUT,
    output logic [4:0] alu_control, instrDOUT,
    output logic neather_modeOUT,
    output logic we_reg, w_regv,
    output logic [31:0] rd1, rd2, imm, pc_actOUT, pc_plus4OUT, rdv2
);

// ==========================================================
//                       CONTROL_UNIT
// ==========================================================

logic immSrc2;
logic [1:0] immSrc;
logic reset;

control_unit CU(
    .opcode(instr[3:0]),
    .func23(instr[23:20]),
    .func19(instr[19]),
    .func15(instr[15:14]),

    .alu_control(alu_control),
    .we_reg(we_reg),
    .size(size),
    .imm_src2(immSrc2),
    .imm_src(immSrc),
    .we_mem(we_mem),
    .beq(beq),
    .bne(bne),
    .blt(blt),
    .bge(bge),
    .jump(jump),
    .w_regv(w_regv),
    .w_memv(w_memv),
    .result_src(result_src),
    .alu_src(alu_src),
    .neather_portal(neather_portalOUT),
    .neather_reset(reset),
    .neather_wreg_src(neather_wreg_src)
);

// ==========================================================
//                       SECURE_MODE
// ==========================================================

logic sm_en;
assign sm_en = z & neather_portal;

secure_mode SM(
    .clk(clk),
    .neather_portal(sm_en),
    .reset(reset),
    .sm(neather_modeOUT)
);

// ==========================================================
//                       imm_extend
// ==========================================================

imm_extend immExt(
    .imm(instr[31:4]),
    .imm_src2(immSrc2),
    .imm_src(immSrc),
    .imm_extended(imm)
);

// ==========================================================
//                       REGFILE
// ==========================================================

regfile RegBank(
    .clk(clk),
    .we_reg(we_regWB),
    .rs1(instr[13:9]),
    .rs2(instr[18:14]),
    .rd(instrDIN),
    .wd(wd),
    .rd1(rd1),
    .rd2(rd2)
);

// ==========================================================
//                       REGFILE V
// ==========================================================

logic we_regV;
assign we_regV = w_regvWB & neather_modeWB; 

neather_regfile RegVBank(
    .clk(clk),
    .we_regV(we_regV),
    .rv2(instr[18:14]),
    .rdv(instrDIN),
    .wdV(wdv),
    .rdv2(rdv2)
);

// ==========================================================
//                       OTRAS SEÑALES
// ==========================================================

always @(*) begin
    $display("[IMM RAW] instr=%h imm_raw=%h", instr, imm);
    $display("RS1=%0d VALUE=%h", instr[13:9], rd1);
    $display("[INST] instr=%h opcode=%b func19=%b", instr, instr[3:0], instr[19]);
end

logic [4:0] rdest;
assign rdest = instr[8:4];
assign instrDOUT = rdest;


assign pc_plus4OUT = pc_plus4;
assign pc_actOUT = pc_act;

endmodule