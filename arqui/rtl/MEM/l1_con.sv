// ============================================================
//  Controlador de L1-D 
// ============================================================

module l1_con (
    input logic clk,
    input logic reset,

    // Datos que vienen del pipeline
    input logic is_write,
    input logic [31:0] addr,
    input logic [1:0] size,
    input logic [31:0] wdata,

    // Desde banco de registros (linea de refill)
    input logic [255:0] fill_line, // linea completa del burst
    // Desde mem_controller: contador de palabras del burst (0..7)
    input logic [2:0] block_offset_counter, // contador de palabras del burst (0..7)

    // Hacia l1d_cache: fill
    output logic fill_en,
    output logic fill_way_out,
    output logic [5:0] fill_set,
    output logic [20:0] fill_tag,
    output logic [255:0] fill_line_out,

    // Hacia l1d_cache: invalidacion
    output logic inv_en,
    output logic inv_way,
    output logic [5:0] inv_set,

    // Hacia CPU/pipeline
    output logic [31:0] dato_cpu,

    // Hacia l2_con 
    output logic miss_l1,
    output logic hit_l1,  

);

// ==========================================================
// Address breakdown 
// addr[31:11] = tag (21 bits)
// addr[10:5] = set (6 bits)
// addr[4:2] = block offset (3 bits)
// addr[1:0] = byte offset (ignorado)
// ==========================================================
logic [20:0] addr_tag;
logic [5:0] addr_set;
logic [2:0] addr_block;

assign addr_tag = addr[31:11];
assign addr_set = addr[10:5];
assign addr_block = addr[4:2];

// ==========================================================
// WayReg: FIFO de reemplazo para L1 (64 sets, 2-way)
// ==========================================================
logic way_to_fill;

set_reg #(.NUM_SETS(64), .NUM_WAYS(2)) WayReg (
    .clk (clk),
    .reset (reset),
    .set (addr_set),
    .fill_en (fill_en),
    .way_out (way_to_fill)
);



endmodule
