module memory_no_cash(
    input logic clk,
    input logic reset,

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
    output logic [31:0] ex_mem,
    output logic stall_mem // hazard unit


);
// ==========================================================
//                 INSTANCIA CLK DIVIDER 
// ==========================================================
logic clk_mem;

clk_divider clk_div(
    .clk(clk),    //100 MHz
    .reset(reset), 
    .clkdiv(clk_mem)  // 50 MHz
);

// ==========================================================
//                 INSTANCIA MEM_CONTROLLER
// ==========================================================

logic ram_we;
logic [1:0] ram_size;
logic [31:0] ram_addr;
logic [31:0] ram_wdata;

mem_controller_no_cash MemCtrl (
    .reset(reset),       
    .clk (clk),
    .clk_mem (clk_mem),
    .req(we_mem | result_src[0]),
    .we (we_mem),
    .addr(alu_result),
    .size({size, 1'b0}),
    .wdata(rd2),
    .ram_we (ram_we),
    .ram_size(ram_size),
    .ram_addr(ram_addr),
    .ram_wdata(ram_wdata),
    .stall_mem(stall_mem)
);

// ==========================================================
//                       INSTANCIA DATA_RAM
// ==========================================================

data_ram NormalRam(
    .clk(clk_mem),
    .we_mem(ram_we),
    .size(ram_size),
    .addr(ram_addr),
    .wdata(ram_wdata),
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
    .addrV(alu_result),
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