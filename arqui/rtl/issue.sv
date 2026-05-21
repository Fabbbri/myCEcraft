module issue(
    input logic clk, reset, stallIF, // hazard
    input logic [31:0] new_addr,
    input logic flushD, stallD, // hazards adelantados para instr por ser ROM sincrona

    output logic [31:0] addr, pc_plus4F, instr
);

// ==========================================================
//                       PC
// ==========================================================

logic pc_en;
logic [31:0] addr_aux;
logic [31:0] addr_delayed; // PC que corresponde a la instr que sale ahora

// Retener el PC un ciclo para que sea coherente con instr síncrona
always_ff @(posedge clk or posedge reset) begin
    if (reset)
        addr_delayed <= 32'b0;
    else if (!stallIF)
        addr_delayed <= addr_aux;
end

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
    .clk(clk), // ROM síncrona
    .stall(stallD),   // viene de hazard_unit
    .addr(addr_aux),
    .instr(instr)
);

// ==========================================================
//                       SUMADOR PC
// ==========================================================

sumador_pc SUMPC(
    .addr(addr_delayed),
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

assign addr = addr_delayed; // PC coherente con instr

endmodule