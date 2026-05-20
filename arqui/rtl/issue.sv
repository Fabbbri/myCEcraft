module issue(
    input logic clk, reset, stallIF // hazard
    input logic [31:0] new_addr,

    output logic [31:0] addr, pc_plus4F, instr
);

// ==========================================================
//                       PC
// ==========================================================

logic pc_en;
logic [31:0] addr_aux;

pc pc_reg(
    .clk(clk),
    .pc_enable(pc_en),
    .reset(reset),
    .new_addr(new_addr),
    .addr(addr_aux),
    .stallIF(stallIF)
);

// ==========================================================
//                       INSTR ROM
// ==========================================================

instr_rom ROM(
    .addr(addr_aux),
    .instr(instr)
);

// ==========================================================
//                       SUMADOR PC
// ==========================================================

sumador_pc SUMPC(
    .addr(addr_aux),
    .pcplus4(pc_plus4F)
);

// ==========================================================
//                       SUMADOR PC
// ==========================================================


logic [8:0] pc_dec_aux;
assign pc_dec_aux = {instr[23:19], instr[3:0]};

pc_decoder pcDec(
    .pcDEC(pc_dec_aux),
    .pc_enable(pc_en)
);

// ==========================================================
//                       OTRAS SEÑALES
// ==========================================================

assign addr = addr_aux;

endmodule