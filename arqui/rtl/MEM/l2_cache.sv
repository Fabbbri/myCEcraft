// ============================================================
//  l2_cache.sv
//  Caché L2 — 4-way set associative, write-through,
//  no-write-allocate, 128 sets, línea de 256 bits
//
//  Puertos de escritura:
//    store:  escribe solo la palabra si hit (write-through)
//    fill:   escribe línea completa tras miss
//    inv:    invalida una línea
//
//  Puerto de lectura secuencial (para refill_regs):
//    Cuando miss L1 + hit L2, refill_regs necesita leer la línea
//    completa de L2 palabra por palabra para armar fill_line de L1.
//    l1_con genera l2_word_counter (0..7) y refill_regs acumula.
// ============================================================

module l2_cache (
    input  logic        clk,
    input  logic        reset,

    // Puerto de lectura principal (pipeline via l2_con)
    input  logic [31:0] addr,
    output logic [31:0] data_out,
    output logic        hit,
    output logic [1:0]  hit_way,

    // Fill: escribe línea completa tras miss
    input  logic         fill_en,
    input  logic [1:0]   fill_way,
    input  logic [6:0]   fill_set,
    input  logic [19:0]  fill_tag,
    input  logic [255:0] fill_line,

    // Invalidación
    input  logic        inv_en,
    input  logic [1:0]  inv_way,
    input  logic [6:0]  inv_set,

    // Puerto de store (desde WB drain en l2_con)
    // store_addr es wb_addr (dirección del WB head), no addr del pipeline
    input  logic        store_en,
    input  logic [31:0] store_addr,
    input  logic [31:0] store_data,

    // Hit del WB head: l2_con decide si escribir en L2 o solo en memoria
    output logic        hit_l2_wb,
    output logic [1:0]  hit_way_wb,

    // Puerto de lectura secuencial para refill_regs
    // Cuando miss L1 + hit L2:
    //   l1_con incrementa l2_word_counter cada ciclo
    //   l2_cache devuelve la palabra correspondiente (combinacional)
    //   refill_regs la captura y arma fill_line para L1
    input  logic [2:0]  l2_refill_word,  // índice de palabra [0..7]
    input  logic [1:0]  l2_refill_way,   // hit_way del acceso original
    input  logic [6:0]  l2_refill_set,   // set del acceso original
    output logic [31:0] l2_refill_rdata  // palabra solicitada (combinacional)
);

    localparam int NUM_SETS  = 128;
    localparam int LINE_BITS = 256;
    localparam int TAG_BITS  = 20;
    localparam int NUM_WAYS  = 4;

    logic [TAG_BITS-1:0]  tag_mem  [NUM_SETS-1:0][0:NUM_WAYS-1];
    logic [LINE_BITS-1:0] data_mem [NUM_SETS-1:0][0:NUM_WAYS-1];
    logic                 valid    [NUM_SETS-1:0][0:NUM_WAYS-1];

    // ==========================================================
    // Descomposición de addr (puerto principal)
    // addr[31:12] = tag  (20 bits)
    // addr[11:5]  = set  (7 bits)
    // addr[4:2]   = word (3 bits)
    // addr[1:0]   = byte offset (ignorado)
    // ==========================================================
    logic [TAG_BITS-1:0] addr_tag;
    logic [6:0]          addr_set;
    logic [2:0]          addr_word;

    assign addr_tag  = addr[31:12];
    assign addr_set  = addr[11:5];
    assign addr_word = addr[4:2];

    // ==========================================================
    // Hit logic (puerto principal)
    // ==========================================================
    logic hit0, hit1, hit2, hit3;
    assign hit0 = valid[addr_set][0] & (tag_mem[addr_set][0] == addr_tag);
    assign hit1 = valid[addr_set][1] & (tag_mem[addr_set][1] == addr_tag);
    assign hit2 = valid[addr_set][2] & (tag_mem[addr_set][2] == addr_tag);
    assign hit3 = valid[addr_set][3] & (tag_mem[addr_set][3] == addr_tag);

    assign hit = hit0 | hit1 | hit2 | hit3;

    // Encoder 4:2
    assign hit_way[1] = hit2 | hit3;
    assign hit_way[0] = hit1 | hit3;

    // ==========================================================
    // Lectura principal: mux 4:1 por way → palabra
    // ==========================================================
    logic [31:0] way0_data, way1_data, way2_data, way3_data;
    assign way0_data = data_mem[addr_set][0][addr_word*32 +: 32];
    assign way1_data = data_mem[addr_set][1][addr_word*32 +: 32];
    assign way2_data = data_mem[addr_set][2][addr_word*32 +: 32];
    assign way3_data = data_mem[addr_set][3][addr_word*32 +: 32];

    always_comb
        case (hit_way)
            2'b11:   data_out = way3_data;
            2'b10:   data_out = way2_data;
            2'b01:   data_out = way1_data;
            default: data_out = way0_data;
        endcase

    // ==========================================================
    // Lectura secuencial para refill_regs
    // Combinacional: en cada ciclo de l2_refill_active,
    // entrega data_mem[l2_refill_set][l2_refill_way][l2_refill_word]
    // refill_regs captura esto en reg_l2 con l2_word_counter como índice
    // ==========================================================
    assign l2_refill_rdata =
        data_mem[l2_refill_set][l2_refill_way][l2_refill_word*32 +: 32];

    // ==========================================================
    // Descomposición de store_addr (puerto WB drain)
    // ==========================================================
    logic [TAG_BITS-1:0] st_tag;
    logic [6:0]          st_set;
    logic [2:0]          st_word;

    assign st_tag  = store_addr[31:12];
    assign st_set  = store_addr[11:5];
    assign st_word = store_addr[4:2];

    // Hit por way evaluado con store_addr
    logic st_hit0, st_hit1, st_hit2, st_hit3;
    assign st_hit0 = valid[st_set][0] & (tag_mem[st_set][0] == st_tag);
    assign st_hit1 = valid[st_set][1] & (tag_mem[st_set][1] == st_tag);
    assign st_hit2 = valid[st_set][2] & (tag_mem[st_set][2] == st_tag);
    assign st_hit3 = valid[st_set][3] & (tag_mem[st_set][3] == st_tag);

    assign hit_l2_wb = st_hit0 | st_hit1 | st_hit2 | st_hit3;

    assign hit_way_wb[1] = st_hit2 | st_hit3;
    assign hit_way_wb[0] = st_hit1 | st_hit3;

    // ==========================================================
    // Escritura
    // ==========================================================
    integer s, w;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (s = 0; s < NUM_SETS; s = s + 1)
                for (w = 0; w < NUM_WAYS; w = w + 1)
                    valid[s][w] <= 1'b0;
        end else begin

            // Store write-through: solo la palabra, solo si hit en L2
            // Si miss: no-write-allocate → solo va a memoria
            if (store_en & hit_l2_wb) begin
                data_mem[st_set][hit_way_wb][st_word*32 +: 32] <= store_data;
                // tag y valid no cambian
            end

            // Refill completo tras load miss
            // fill_line viene de refill_regs (desde mem_controller)
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