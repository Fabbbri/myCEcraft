module memory(
    input logic clk,

    input logic [1:0] result_src, 
    input logic neather_wreg_src, w_memv, we_mem, size,
    input logic we_reg, neather_mode, w_regv,

    input logic [31:0] alu_result, rd2, rdv2, pc_plus4,
    input logic [4:0] instrD,

    output logic [1:0] result_srcOUT,
    output logic neather_wreg_srcOUT, we_regOUT, neather_modeOUT, w_regvOUT,
    output logic [31:0] rMemData, rvMemData, alu_resultOUT, pc_plus4OUT,
    output logic [31:0] rdataPass0v,
    output logic [4:0] instrDOUT, instrMOUT_hz, 
    output logic we_reg_MEM_hz, // hazard unit

    // forward
    output logic [31:0] ex_mem


);

// ==========================================================
//                       INSTANCIA DATA_RAM
// ==========================================================

logic [31:0] ram_addr;
logic [1:0] size_aux;

assign ram_addr = alu_result;
assign size_aux = {size, 1'b0};

data_ram NormalRam(
    .clk(clk),
    .we_mem(we_mem),
    .size(size_aux),
    .addr(ram_addr),
    .wdata(rd2),
    .rdata(rMemData)
);

// ==========================================================
//                       INSTANCIA NEATHER_RAM
// ==========================================================

logic neather_mode_aux;
logic we_memv_aux;
logic [31:0] addrPortal_aux;

assign neather_mode_aux = neather_mode;
assign we_memv_aux = w_memv & neather_mode_aux;

// CAMBIAR CUANDO SE IMPLEMENTE EL LOGV ANTI ATAQUES 
assign addrPortal_aux = 32'b0;

neather_ram VaultRam(
    .clk(clk),
    .we_memV(we_memv_aux),
    .addrV(ram_addr),
    .addrPortal(addrPortal_aux),
    .wdataV(rdv2),
    .rdataV(rvMemData),
    .rdataPass0V(rdataPass0v)
);

// ==========================================================
//                       OTRAS SEÑALES
// ==========================================================

assign result_srcOUT = result_src;
assign neather_wreg_srcOUT = neather_wreg_src;

assign we_regOUT = we_reg;
assign neather_modeOUT = neather_mode;
assign w_regvOUT = w_regv;

// NON CONTROL SIGNALS

assign alu_resultOUT = alu_result;
assign pc_plus4OUT = pc_plus4;
assign instrDOUT = instrD;

// Hazard Unit
assign instrMOUT_hz = instrD;
assign we_reg_MEM_hz = we_reg;
assign ex_mem = alu_result;


endmodule