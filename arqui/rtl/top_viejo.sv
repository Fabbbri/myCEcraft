module top_viejo(
    input logic clk,
    input logic reset
);

// ==========================================================
//                       INSTANCIAS
// ==========================================================

// ==========================================================
//                       ISSUE
// ==========================================================

logic [31:0] pcF, pc4F, instrF;

issue Issue(
    .clk(clk),
    .reset(reset),

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

    .instr_out(instrDE),
    .pc_out(pc4DE),
    .addr_out(pcDE)
);

// ==========================================================
//                       DECODE
// ==========================================================

logic [31:0] instrDE, pcDE, pc4DE;

logic jumpDE, bltDE, bgeDE, bneDE, beqDE;
logic [1:0] result_srcDE, alu_srcDE;
logic neather_wreg_srcDE, w_memvDE, we_memDE, sizeDE, neather_portalDE;
logic [4:0] alu_controlDE, instrDDE;
logic neather_modeDE, we_regDE, w_regvDE;
logic [31:0] rd1DE, rd2DE, immDE, rdv2DE;
// pc y pc4 siguen siendo el mismo en DE


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
    .pc_actOUT(pcDE), 
    .pc_plus4OUT(pc4DE), 
    .rdv2(rdv2DE)  
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
    .pc_act(pcDE), 
    .pc_plus4(pc4DE), 
    .rdv2(rdv2DE),

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
    .instrDOUT(instrDEX)
);

// ==========================================================
//                       EX
// ==========================================================

logic jumpEX, bltEX, bgeEX, bneEX, beqEX;
logic [1:0] result_srcEX, alu_srcEX;
logic neather_wreg_srcEX, w_memvEX, we_memEX, sizeEX;
logic [4:0] alu_controlEX, instrDEX;
logic we_regEX, neather_modeEX, w_regvEX;
logic [31:0] rd1EX, rd2EX, immEX, pc_actEX, pcplus4EX, rdv2EX;

// DESPUES HAY QUE METERLE con: logic rdataPass0vMEM;

logic pc_srcEX, zEX, neather_portalEX; // (se usa en WB y en DECODE)

logic [31:0] alu_resultEX, pc_targetEX;

execute Exec(
    .jump(jumpEX),
    .blt(bltEX), 
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
    .neather_mode(neather_modeEX), 
    .w_regv(w_regvEX),
    .rd1E(rd1EX), 
    .rd2E(rd2EX), 
    .immE(immEX),
    .pc_actE(pc_actEX),
    .pc_plus4E(pcplus4EX), 
    .rdv2E(rdv2EX),
    .instrD(instrDEX),

    .pc_srcEx(pc_srcEX), 
    .z_OUT(zEX), 
    .neather_portalOUT(neather_portalEX), // no cambia
    .result_srcOUT(result_srcEX), // no cambia
    .neather_wreg_srcOUT(neather_wreg_srcEX), 
    .w_memvOUT(w_memvEX), 
    .we_memOUT(we_memEX), 
    .sizeOUT(sizeEX), 
    .we_regOUT(we_regEX), 
    .neather_modeOUT(neather_modeEX),
    .w_regvOUT(w_regvEX),

    .alu_result(alu_resultEX), 
    .rd2OUT(rd2EX), 
    .rdv2OUT(rdv2EX), 
    .pc_plus4OUT(pcplus4EX),
    .pc_targetOUT(pc_targetEX),
    .instrDOUT(instrDEX)
);


// ==========================================================
//                       EX/MEM
// ==========================================================

ex_mem_pipe ex_mem(
    .clk(clk),
    .reset(reset),

    .result_src(result_srcEX),
    .neather_wreg_src(neather_wreg_srcEX), 
    .w_memv(w_memvEX), 
    .we_mem(we_memEX), 
    .size(sizeEX), 
    .we_reg(we_regEX), 
    .neather_mode(neather_modeEX), 
    .w_regv(w_regvEX),
    .alu_result(alu_resultEX), 
    .rd2(rd2EX),
    .rdv2(rdv2EX), 
    .pcPlus4(pcplus4EX),
    .instrD(instrDEX), 

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

logic [1:0] result_srcMEM;
logic neather_wreg_srcMEM, w_memvMEM, we_memMEM, sizeMEM;
logic we_regMEM, neather_modeMEM, w_regvMEM;
logic [31:0] alu_resultMEM, rd2MEM, rdv2MEM, pcPlus4MEM;
logic [4:0] instrDMEM;

logic [31:0] rMemDataMEM, rvMemDataMEM;

logic rdataPass0vMEM;

memory mem(
    .clk(clk),

    .result_src(result_srcMEM), 
    .neather_wreg_src(neather_wreg_srcMEM), 
    .w_memv(w_memvMEM), 
    .we_mem(we_memMEM), 
    .size(sizeMEM),
    .we_reg(we_regMEM), 
    .neather_mode(neather_modeMEM),
    .w_regv(w_regvMEM),

    .alu_result(alu_resultMEM), 
    .rd2(rd2MEM), 
    .rdv2(rdv2MEM), 
    .pc_plus4(pcPlus4MEM), // es la misma, se expande
    .instrD(instrDMEM),

    .result_srcOUT(result_srcMEM),
    .neather_wreg_srcOUT(neather_wreg_srcMEM), 
    .we_regOUT(we_regMEM), 
    .neather_modeOUT(neather_modeMEM),
    .w_regvOUT(w_regvMEM),
    .rMemData(rMemDataMEM), 
    .rvMemData(rvMemDataMEM), 
    .alu_resultOUT(alu_resultMEM), 
    .pc_plus4OUT(pcPlus4MEM),
    .rdataPass0v(rdataPass0vMEM),
    .instrDOUT(instrDMEM)
);

// ==========================================================
//                       MEM/WB
// ==========================================================

mem_wb_pipe mem_wb(
    .clk(clk),
    .reset(reset),

    .result_src(result_srcMEM), 
    .neather_wreg_src(neather_wreg_srcMEM),
    .we_reg(we_regMEM), 
    .neather_mode(neather_modeMEM), 
    .w_regv(w_regvMEM),
    .rMemData(rMemDataMEM),  
    .alu_result(alu_resultMEM), 
    .rvMemData(rvMemDataMEM), 
    .pcPlus4(pcPlus4MEM),
    .instrD(instrDMEM), 

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

logic [1:0] result_srcWB;
logic neather_wreg_srcWB, we_regWB, neather_modeWB, w_regvWB;
logic [31:0] rMemDataWB, rvMemDataWB, alu_resultWB, pc_plus4WB;
logic [4:0] instrDWB;

logic [31:0] newpc, wdWB, wdvWB;

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
    .pc_plus4F(pc4F), // para el mux
    .pc_target_EX(pc_targetEX),
    .instrD(instrDWB),

// outputs

    .we_regOUT(we_regWB), 
    .neather_modeOUT(neather_modeWB), 
    .w_regvOUT(w_regvWB),
    
    .wdOUT(wdWB), 
    .wdvOUT(wdvWB),

    .new_addr(newpc), // sale del mux de pc
    .instrDOUT(instrDWB)
);

// ==========================================================
//                       WB/IF
// ==========================================================

// ya está incluido dentro de Issue

endmodule