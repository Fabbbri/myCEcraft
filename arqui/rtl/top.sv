module top(
    input logic clk,
    input logic reset
);

// ==========================================================
//   DECLARACIONES — TODAS ARRIBA, ANTES DE CUALQUIER INSTANCIA
// ==========================================================

// IF
logic [31:0] pcF, pc4F, instrF;

// IF/ID → ID
logic [31:0] instrDE, pcDE, pc4DE;

logic [31:0] pc4DEOUT, pcDEOUT;

// ID → ID/EX
logic        jumpDE, bltDE, bgeDE, bneDE, beqDE;
logic [1:0]  result_srcDE, alu_srcDE;
logic        neather_wreg_srcDE, w_memvDE, we_memDE, sizeDE, neather_portalDE;
logic [4:0]  alu_controlDE, instrDDE;
logic        neather_modeDE, we_regDE, w_regvDE;
logic [31:0] rd1DE, rd2DE, immDE, rdv2DE;

// ID/EX → EX
logic        jumpEX, bltEX, bgeEX, bneEX, beqEX;
logic [1:0]  result_srcEX, alu_srcEX;
logic        neather_wreg_srcEX, w_memvEX, we_memEX, sizeEX;
logic [4:0]  alu_controlEX, instrDEX;
logic        we_regEX, neather_modeEX, w_regvEX;
logic [31:0] rd1EX, rd2EX, immEX, pc_actEX, pcplus4EX, rdv2EX;
logic        pc_srcEX, zEX, neather_portalEX;

// EX → EX/MEM
logic [31:0] alu_resultEX, pc_targetEX;
logic [1:0]  result_srcEX_out;
logic        neather_wreg_srcEX_out, w_memvEX_out, we_memEX_out, sizeEX_out;
logic        we_regEX_out, neather_modeEX_out, w_regvEX_out;
logic        neather_portalEX_out;
logic [31:0] rd2EX_out, rdv2EX_out, pcplus4EX_out;
logic [4:0]  instrDEX_out;

// EX/MEM → MEM
logic [1:0]  result_srcMEM;
logic        neather_wreg_srcMEM, w_memvMEM, we_memMEM, sizeMEM;
logic        we_regMEM, neather_modeMEM, w_regvMEM;
logic [31:0] alu_resultMEM, rd2MEM, rdv2MEM, pcPlus4MEM;
logic [4:0]  instrDMEM;

// MEM → MEM/WB
logic [31:0] rMemDataMEM, rvMemDataMEM, rdataPass0vMEM;
logic [31:0] alu_resultMEM_out, pcPlus4MEM_out;
logic [4:0]  instrDMEM_out;

// MEM/WB → WB
logic [1:0]  result_srcWB;
logic        neather_wreg_srcWB, we_regWB, neather_modeWB, w_regvWB;
logic [31:0] rMemDataWB, rvMemDataWB, alu_resultWB, pc_plus4WB;
logic [4:0]  instrDWB;

// WB → feedback
logic [31:0] newpc, wdWB, wdvWB;
logic        we_regWB_fb, neather_modeWB_fb, w_regvWB_fb;
logic [4:0]  instrDWB_fb;

// Hazard Unit Salidas
logic stallIF;
logic stallD, flushD, flushE;
logic stallE, stallM, stallW;

logic [4:0] rs1DEX, rs2DEX;// intermedio

logic [1:0] forwardA, forwardB;


// forward de ex y mem
logic [31:0] ex_mem_hz; // entrada execute, salida mem y wb
// wdWB = mem_wb;

//entradas de Hazard
//pc_srcEX ya existe
logic [4:0] rs1DE, rs2DE; // entrada de ID_EX y de Hazard
logic [4:0] rs1EX, rs2EX, rdEX;
logic [4:0] rdMEM;
logic we_reg_mem;
logic result_src_0;

logic [4:0] rdWB;
logic we_reg_wb;
logic stall_mem;

// ==========================================================
//                       ISSUE
// ==========================================================

issue Issue(
    .clk(clk),
    .reset(reset),
    .stallIF(stallIF),

    .new_addr(newpc),

    .addr(pcF),
    .pc_plus4F(pc4F),
    .instr(instrF)
);

// ==========================================================
//                       IF/ID
// ==========================================================

if_id_pipe if_id(
    .clk(clk),
    .reset(reset),

    .instr_in(instrF),
    .pc_in(pc4F),
    .addr_in(pcF),

    .stallD(stallD),
    .flushD(flushD),

    .instr_out(instrDE),
    .pc_out(pc4DE),
    .addr_out(pcDE)
);

// ==========================================================
//                       DECODE
// ==========================================================

decode Decode(
    .clk(clk),

    .instr(instrDE), 
    .pc_plus4(pc4DE), 
    .pc_act(pcDE),
    .neather_portal(neather_portalEX), 
    .z(zEX), 
    .we_regWB(we_regWB), 
    .w_regvWB(w_regvWB), 
    .neather_modeWB(neather_modeWB),
    .wd(wdWB), 
    .wdv(wdvWB),
    .instrDIN(instrDWB),

    .jump(jumpDE), 
    .blt(bltDE), 
    .bge(bgeDE), 
    .bne(bneDE), 
    .beq(beqDE), 
    .result_src(result_srcDE), 
    .alu_src(alu_srcDE),
    .neather_wreg_src(neather_wreg_srcDE), 
    .w_memv(w_memvDE), 
    .we_mem(we_memDE), 
    .size(sizeDE), 
    .neather_portalOUT(neather_portalDE),
    .alu_control(alu_controlDE), 
    .instrDOUT(instrDDE),
    .neather_modeOUT(neather_modeDE),
    .we_reg(we_regDE),
    .w_regv(w_regvDE),
    .rd1(rd1DE), 
    .rd2(rd2DE), 
    .imm(immDE), 
    .pc_actOUT(pcDEOUT), 
    .pc_plus4OUT(pc4DEOUT), 
    .rdv2(rdv2DE),

    .rs1DE(rs1DE),
    .rs2DE(rs2DE) 
);

// ==========================================================
//                       ID/EX
// ==========================================================

id_ex_pipe id_ex(
    .clk(clk),
    .reset(reset),

    .jump(jumpDE), 
    .blt(bltDE), 
    .bge(bgeDE), 
    .bne(bneDE), 
    .beq(beqDE),
    .result_src(result_srcDE), 
    .alu_src(alu_srcDE), 
    .neather_wreg_src(neather_wreg_srcDE), 
    .w_memv(w_memvDE), 
    .we_mem(we_memDE), 
    .size(sizeDE), 
    .neather_portal(neather_portalDE),
    .alu_control(alu_controlDE), 
    .neather_mode(neather_modeDE),
    .we_reg(we_regDE),
    .w_regv(w_regvDE),
    .instrD(instrDDE),
    .rd1(rd1DE), 
    .rd2(rd2DE), 
    .imm(immDE), 
    .pc_act(pcDEOUT), 
    .pcplus4(pc4DEOUT), 
    .rdv2(rdv2DE),

    .rs1DIN(rs1DE),
    .rs2DIN(rs2DE),

    .flushE(flushE),
    .stallE(stallE),

    .jumpOUT(jumpEX), 
    .bltOUT(bltEX), 
    .bgeOUT(bgeEX), 
    .bneOUT(bneEX), 
    .beqOUT(beqEX), 
    .result_srcOUT(result_srcEX), 
    .alu_srcOUT(alu_srcEX),
    .neather_wreg_srcOUT(neather_wreg_srcEX), 
    .w_memvOUT(w_memvEX), 
    .we_memOUT(we_memEX), 
    .sizeOUT(sizeEX), 
    .neather_portalOUT(neather_portalEX),
    .alu_controlOUT(alu_controlEX),
    .we_regOUT(we_regEX), 
    .neather_modeOUT(neather_modeEX), 
    .w_regvOUT(w_regvEX),
    .rd1OUT(rd1EX), 
    .rd2OUT(rd2EX), 
    .immOUT(immEX), 
    .pc_actOUT(pc_actEX), 
    .pcplus4OUT(pcplus4EX), 
    .rdv2OUT(rdv2EX), 
    .instrDOUT(instrDEX),

    .rs1DOUT(rs1DEX),
    .rs2DOUT(rs2DEX)
);

// ==========================================================
//                       EX
// ==========================================================

// DESPUES HAY QUE METERLE con: logic rdataPass0vMEM;

execute Exec(
    .jump(jumpEX),
    .blt(bltEX), 
    .bge(bgeEX),
    .bne(bneEX), 
    .beq(beqEX),
    .result_src(result_srcEX),
    .neather_wreg_src(neather_wreg_srcEX), 
    .w_memv(w_memvEX), 
    .we_mem(we_memEX), 
    .size(sizeEX), 
    .neather_portalIN(neather_portalEX),
    .alu_control(alu_controlEX),
    .alu_src(alu_srcEX),
    .we_reg(we_regEX),
    .neather_mode(neather_modeEX), 
    .w_regv(w_regvEX),
    .rd1E(rd1EX), 
    .rd2E(rd2EX), 
    .immE(immEX),
    .pc_actE(pc_actEX),
    .pc_plus4E(pcplus4EX), 
    .rdv2E(rdv2EX),
    .instrD(instrDEX),

    .rs1EIN(rs1DEX),
    .rs2EIN(rs2DEX),
    .forwardA(forwardA),
    .forwardB(forwardB),

    .ex_mem(ex_mem_hz),
    .mem_wb(wdWB),

    .pc_srcEx(pc_srcEX), // va a la Hazard Unit
    .z_OUT(zEX), 
    .neather_portalOUT(neather_portalEX_out),
    .result_srcOUT(result_srcEX_out),
    .neather_wreg_srcOUT(neather_wreg_srcEX_out), 
    .w_memvOUT(w_memvEX_out), 
    .we_memOUT(we_memEX_out), 
    .sizeOUT(sizeEX_out), 
    .we_regOUT(we_regEX_out), 
    .neather_modeOUT(neather_modeEX_out),
    .w_regvOUT(w_regvEX_out),

    .alu_result(alu_resultEX), 
    .rd2OUT(rd2EX_out), 
    .rdv2OUT(rdv2EX_out), 
    .pc_plus4OUT(pcplus4EX_out),
    .pc_targetOUT(pc_targetEX),
    .instrDOUT(instrDEX_out),

    .instrDOUT_hz(rdEX),
    .rs1EOUT(rs1EX),
    .rs2EOUT(rs2EX),

    .result_src_0(result_src_0)
);

// ==========================================================
//                       EX/MEM
// ==========================================================

ex_mem_pipe ex_mem(
    .clk(clk),
    .reset(reset),
    .stallM(stallM),

    .result_src(result_srcEX_out),
    .neather_wreg_src(neather_wreg_srcEX_out), 
    .w_memv(w_memvEX_out), 
    .we_mem(we_memEX_out), 
    .size(sizeEX_out), 
    .we_reg(we_regEX_out), 
    .neather_mode(neather_modeEX_out), 
    .w_regv(w_regvEX_out),
    .alu_result(alu_resultEX), 
    .rd2(rd2EX_out),
    .rdv2(rdv2EX_out), 
    .pcPlus4(pcplus4EX_out),
    .instrD(instrDEX_out), 

    .result_srcOUT(result_srcMEM), 
    .neather_wreg_srcOUT(neather_wreg_srcMEM), 
    .w_memvOUT(w_memvMEM), 
    .we_memOUT(we_memMEM), 
    .sizeOUT(sizeMEM),
    .we_regOUT(we_regMEM), 
    .neather_modeOUT(neather_modeMEM), 
    .w_regvOUT(w_regvMEM),
    .alu_resultOUT(alu_resultMEM),
    .rd2OUT(rd2MEM), 
    .rdv2OUT(rdv2MEM), 
    .pcPlus4OUT(pcPlus4MEM),
    .instrDOUT(instrDMEM)
);

// ==========================================================
//                       MEM
// ==========================================================

memory Memory(
    .clk(clk),
    .reset(reset),
    .w_memv(w_memvMEM), 
    .we_mem(we_memMEM), 
    .size(sizeMEM),
    .neather_mode(neather_modeMEM),
    .we_reg(we_regMEM),                      // ← falta
    .w_regv(w_regvMEM),                      // ← falta
    .result_src(result_srcMEM),              // ← falta
    .neather_wreg_src(neather_wreg_srcMEM),  // ← falta

    .alu_result(alu_resultMEM), 
    .rd2(rd2MEM), 
    .rdv2(rdv2MEM), 
    .pc_plus4(pcPlus4MEM),
    .instrD(instrDMEM),

    .rMemData(rMemDataMEM), 
    .rvMemData(rvMemDataMEM), 
    .alu_resultOUT(alu_resultMEM_out), 
    .pc_plus4OUT(pcPlus4MEM_out),
    .rdataPass0v(rdataPass0vMEM),
    .instrDOUT(instrDMEM_out),

    .instrMOUT_hz(rdMEM),
    .we_reg_MEM_hz(we_reg_mem),
    .ex_mem(ex_mem_hz),
    .stall_mem(stall_mem)
);

// ==========================================================
//                       MEM/WB
// ==========================================================


mem_wb_pipe mem_wb(
    .clk(clk),
    .reset(reset),
    .stallW(stallW),

    // señales de control vienen directo de ex_mem_pipe (no pasan por memory)
    .result_src(result_srcMEM), 
    .neather_wreg_src(neather_wreg_srcMEM),
    .we_reg(we_regMEM), 
    .neather_mode(neather_modeMEM), 
    .w_regv(w_regvMEM),

    // datos vienen de memory
    .rMemData(rMemDataMEM),  
    .alu_result(alu_resultMEM_out), 
    .rvMemData(rvMemDataMEM), 
    .pcPlus4(pcPlus4MEM_out),
    .instrD(instrDMEM_out), 

    .result_srcOUT(result_srcWB), 
    .neather_wreg_srcOUT(neather_wreg_srcWB),
    .we_regOUT(we_regWB), 
    .neather_modeOUT(neather_modeWB), 
    .w_regvOUT(w_regvWB),
    .rMemDataOUT(rMemDataWB),  
    .alu_resultOUT(alu_resultWB), 
    .rvMemDataOUT(rvMemDataWB), 
    .pcPlus4OUT(pc_plus4WB),
    .instrDOUT(instrDWB)
);

// ==========================================================
//                       WB
// ==========================================================

writeback WriteBack(
    .result_src(result_srcWB),
    .neather_wreg_src(neather_wreg_srcWB),
    .we_reg(we_regWB), 
    .neather_mode(neather_modeWB), 
    .w_regv(w_regvWB),

    .rMemData(rMemDataWB),
    .alu_result(alu_resultWB), 
    .rvMemData(rvMemDataWB), 
    .pc_plus4(pc_plus4WB), 

    .pc_srcEx(pc_srcEX),
    .pc_plus4F(pc4F),
    .pc_target_EX(pc_targetEX),
    .instrD(instrDWB),

    .we_regOUT(we_regWB_fb), 
    .neather_modeOUT(neather_modeWB_fb), 
    .w_regvOUT(w_regvWB_fb),
    
    .wdOUT(wdWB), // mem_wb
    .wdvOUT(wdvWB),

    .new_addr(newpc),
    .instrDOUT(instrDWB_fb),

    .instrWbOUT_hz(rdWB),
    .we_reg_wb_hz(we_reg_wb)
);

// ==========================================================
//                       FEEDBACK WB → DECODE
// ==========================================================

// Las señales de feedback que decode necesita vienen de writeback,
// no del pipe mem_wb. Se renombran aquí para que quede claro.
// we_regWB, w_regvWB, neather_modeWB, instrDWB ya existen como
// salidas de mem_wb_pipe, pero el decode necesita los valores
// procesados por writeback:

// Si writeback solo los pasa sin modificar, conecta directo:
// assign we_regWB    = we_regWB_fb;   // ← driver doble, NO hacer esto
// En su lugar, decode debería recibir we_regWB_fb directamente.
// Puede ajustarse las conexiones de Decode arriba para usar _fb si es necesario.

// ==========================================================
//                       WB/IF
// ==========================================================

// ya está incluido dentro de Issue

// ==========================================================
//                       HAZARD UNIT
// ==========================================================

hazard_unit HazardUnit(
    .rs1DE(rs1DE),
    .rs1EX(rs1EX),
    .rs2DE(rs2DE), 
    .rs2EX(rs2EX),
    .rdEX(rdEX),
    .rdMEM(rdMEM), 
    .rdWB(rdWB),
    .result_src_0(result_src_0), 
    .pc_src_exOUT(pc_srcEX), 
    .we_reg_mem(we_reg_mem), 
    .we_reg_wb(we_reg_wb),
    .stall_mem(stall_mem),

    .forwardA(forwardA),
    .forwardB(forwardB),
    .stallIF(stallIF),
    .stallD(stallD),
    .flushD(flushD),
    .flushE(flushE),
    .stallE(stallE),
    .stallM(stallM),
    .stallW(stallW)
);

endmodule