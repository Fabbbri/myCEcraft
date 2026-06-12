// ============================================================
//  Controlador de L1-D
// ============================================================

module l1_con (
    input logic clk,
    input logic reset,

    input logic is_write,
    input logic [31:0] addr,
    input logic [1:0] size,
    input logic [31:0] wdata,

    input logic [255:0] fill_line,
    input logic [2:0] block_offset_counter,

    input logic hit_l1,
    input logic [31:0] l1_data_out,

    output logic fill_en,
    output logic fill_way_out,
    output logic [5:0] fill_set,
    output logic [20:0] fill_tag,
    output logic [255:0] fill_line_out,

    output logic inv_en,
    output logic inv_way,
    output logic [5:0] inv_set,

    output logic [31:0] dato_cpu,

    output logic miss_l1_out
);

// ==========================================================
// Address breakdown
// addr[31:11] = tag (21 bits)
// addr[10:5]  = set (6 bits)
// addr[4:2]   = block offset (3 bits)
// addr[1:0]   = byte offset (ignorado)
// ==========================================================
logic [20:0] addr_tag;
logic [5:0]  addr_set;
logic [2:0]  addr_block;

assign addr_tag   = addr[31:11];
assign addr_set   = addr[10:5];
assign addr_block = addr[4:2];

// ==========================================================
// WayReg: FIFO de reemplazo para L1 (64 sets, 2-way)
// ==========================================================
logic way_to_fill;

// FIX: replace solo en fill real o store hit — no en cada ciclo de miss
logic replace;
assign replace = fill_en | (is_write & hit_l1);

set_reg #(.NUM_SETS(64), .NUM_WAYS(2)) WayReg (
    .clk     (clk),
    .reset   (reset),
    .set     (addr_set),
    .fill_en (replace),
    .way_out (way_to_fill)
);

// ==========================================================
// Outputs hacia pipeline / l2_con
// ==========================================================
assign miss_l1_out  = ~hit_l1;
assign dato_cpu     = l1_data_out;

// ==========================================================
// fill_en: FIX — solo al final del burst Y con burst activo
// Se registra un ciclo para que fill_line (de refill_regs) ya
// tenga la última palabra capturada antes de escribir en L1.
// ==========================================================
logic fill_en_comb;
assign fill_en_comb = (block_offset_counter == 3'b111) & ~hit_l1;

always_ff @(posedge clk)
    fill_en <= fill_en_comb & ~hit_l1;  // retrasado 1 ciclo, igual que l2_con

assign fill_way_out  = way_to_fill;
assign fill_set      = addr_set;
assign fill_tag      = addr_tag;
assign fill_line_out = fill_line;

// ==========================================================
// inv_en: FIX — solo en el ciclo exacto previo al fill,
// no en cada ciclo de miss (evita borrar la línea recién llenada)
// ==========================================================
logic fill_en_comb_d;
always_ff @(posedge clk)
    fill_en_comb_d <= fill_en_comb;

// Invalida justo cuando se detecta el final del burst, antes de que
// fill_en (retrasado) escriba la nueva línea.
assign inv_en  = fill_en_comb & ~fill_en_comb_d & ~hit_l1 & ~is_write;
assign inv_way = way_to_fill;
assign inv_set = addr_set;

endmodule