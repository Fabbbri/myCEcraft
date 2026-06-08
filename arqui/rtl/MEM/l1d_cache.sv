// ============================================================
//  l1d_cache.sv
//  Caché L1 de datos — 2-way set associative, write-through,
//  no-write-allocate, 64 sets, línea de 256 bits
//
//  Puertos de escritura:
//    store hit:  escribe solo la palabra (addr_word) en el way que hizo hit
//    fill:       escribe línea completa tras miss
//    inv:        invalida una línea
//
//  Puerto de lectura secuencial (para refill_regs cuando miss L1 + hit L2):
//    l2_word_counter + hit_way → l2_refill_rdata
//    refill_regs acumula las 8 palabras y arma fill_line
// ============================================================

module l1d_cache (
    input  logic        clk,
    input  logic        reset,

    // Puerto de lectura principal (pipeline)
    input  logic [31:0] addr,
    output logic [31:0] data_out,
    output logic        hit,
    output logic        hit_way,

    // Fill: escribe línea completa tras miss
    input  logic         fill_en,
    input  logic         fill_way,
    input  logic [5:0]   fill_set,
    input  logic [20:0]  fill_tag,
    input  logic [255:0] fill_line,

    // Invalidación
    input  logic        inv_en,
    input  logic        inv_way,
    input  logic [5:0]  inv_set,

    // Store write-through: escribe solo la palabra en hit
    input  logic        is_write,
    input  logic [31:0] wdata,

    // Puerto de lectura secuencial para refill_regs
    // Usado cuando miss L1 + hit L2: refill_regs lee la línea
    // completa de L1 palabra por palabra para pasársela a L2
    // (no aplica aquí — L1 no provee líneas a L2, sino al revés)
    // Este puerto lo tiene L2, no L1.
    // L1 recibe fill_line desde refill_regs (ya muxeado).
    // No se necesita puerto extra aquí.

    // Señal de store hit hacia l1_con
    // l1_con necesita saber si el store pegó en L1 para:
    //   - avanzar el WayReg
    //   - propagar write-through a L2 y memoria
    output logic        store_hit_l1
);

    localparam int NUM_SETS  = 64;
    localparam int LINE_BITS = 256;
    localparam int TAG_BITS  = 21;

    logic [TAG_BITS-1:0]  tag_mem  [NUM_SETS-1:0][0:1];
    logic [LINE_BITS-1:0] data_mem [NUM_SETS-1:0][0:1];
    logic                 valid    [NUM_SETS-1:0][0:1];

    // ==========================================================
    // Descomposición de addr
    // addr[31:11] = tag  (21 bits)
    // addr[10:5]  = set  (6 bits)
    // addr[4:2]   = word (3 bits)
    // addr[1:0]   = byte offset (ignorado)
    // ==========================================================
    logic [TAG_BITS-1:0] addr_tag;
    logic [5:0]          addr_set;
    logic [2:0]          addr_word;

    assign addr_tag  = addr[31:11];
    assign addr_set  = addr[10:5];
    assign addr_word = addr[4:2];

    // ==========================================================
    // Hit logic
    // ==========================================================
    logic hit0, hit1;
    assign hit0 = valid[addr_set][0] & (tag_mem[addr_set][0] == addr_tag);
    assign hit1 = valid[addr_set][1] & (tag_mem[addr_set][1] == addr_tag);

    assign hit     = hit0 | hit1;
    assign hit_way = hit1;  // encoder 1-bit: way1 tiene prioridad

    // ==========================================================
    // Lectura: mux de línea → palabra
    // ==========================================================
    logic [LINE_BITS-1:0] sel_line;
    assign sel_line = hit1 ? data_mem[addr_set][1]
                           : data_mem[addr_set][0];

    assign data_out = sel_line[addr_word*32 +: 32];

    // ==========================================================
    // Store hit: hit en L1 durante un write
    // l1_con usa esto para:
    //   - avanzar WayReg (replace)
    //   - saber que hay que propagar a L2 y memoria (write-through)
    // ==========================================================
    assign store_hit_l1 = hit & is_write;

    // ==========================================================
    // Escritura
    // ==========================================================
    integer s;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (s = 0; s < NUM_SETS; s = s + 1) begin
                valid[s][0] <= 1'b0;
                valid[s][1] <= 1'b0;
            end
        end else begin

            // Store hit: actualizar solo la palabra en el way que hizo hit
            // tag y valid no cambian — la línea ya es válida
            if (store_hit_l1) begin
                data_mem[addr_set][hit_way][addr_word*32 +: 32] <= wdata;
            end

            // Refill: escribir línea completa tras miss
            // fill_line viene de refill_regs (mux entre mem y L2)
            if (fill_en) begin
                tag_mem [fill_set][fill_way] <= fill_tag;
                data_mem[fill_set][fill_way] <= fill_line;
                valid   [fill_set][fill_way] <= 1'b1;
            end

            // Invalidación
            if (inv_en) begin
                valid[inv_set][inv_way] <= 1'b0;
            end
        end
    end

endmodule