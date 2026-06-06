module l2_cache (
    input logic clk,
    input logic reset,

    // Señales para obtener hit y data out
    input  logic [31:0] addr,
    output logic [31:0] data_out,
    output logic hit,
    output logic [1:0] hit_way,

    // Señales de llenado - refill
    input logic fill_en,
    input logic [1:0] fill_way,
    input logic [6:0] fill_set,
    input logic [19:0] fill_tag,
    input logic [255:0] fill_line,

    // Señales para invalidar líneas
    input logic inv_en,
    input logic [1:0] inv_way,
    input logic [6:0] inv_set

    // Señales para store (Way hit y miss son iguales)
    input  logic        store_en,        // is_write desde L1
    input  logic [31:0] w_data,          // dato a escribir
);

    localparam int NUM_SETS  = 128;
    localparam int LINE_BITS = 256;
    localparam int TAG_BITS  = 20;
    localparam int NUM_WAYS  = 4;

    logic [TAG_BITS-1:0] tag_mem [NUM_SETS-1:0][0:NUM_WAYS-1];
    logic [LINE_BITS-1:0] data_mem [NUM_SETS-1:0][0:NUM_WAYS-1];
    logic valid [NUM_SETS-1:0][0:NUM_WAYS-1];

    // addr[1:0] = byte offset (ignorado)
    // addr[4:2] = word offset dentro de la línea (3 bits)
    // addr[11:5] = set index (7 bits)
    // addr[31:12] = tag (20 bits)

    logic [TAG_BITS-1:0] addr_tag;
    logic [6:0] addr_set;
    logic [2:0] addr_word;

    assign addr_tag = addr[31:12];
    assign addr_set = addr[11:5];
    assign addr_word = addr[4:2];

    // Hit por way
    logic hit0, hit1, hit2, hit3;
    assign hit0 = valid[addr_set][0] && (tag_mem[addr_set][0] == addr_tag);
    assign hit1 = valid[addr_set][1] && (tag_mem[addr_set][1] == addr_tag);
    assign hit2 = valid[addr_set][2] && (tag_mem[addr_set][2] == addr_tag);
    assign hit3 = valid[addr_set][3] && (tag_mem[addr_set][3] == addr_tag);

    // OR 4:1 -> hit
    assign hit = hit0 | hit1 | hit2 | hit3;

    // Encoder 2 ORs -> selector del mux de datos
    //   hit_way[1] = hit2 | hit3
    //   hit_way[0] = hit1 | hit3
    assign hit_way[1] = hit2 | hit3;
    assign hit_way[0] = hit1 | hit3;

    // Mux de block offset por way (selecciona la palabra de 32 bits)
    logic [31:0] way0_data, way1_data, way2_data, way3_data;
    assign way0_data = data_mem[addr_set][0][addr_word*32 +: 32];
    assign way1_data = data_mem[addr_set][1][addr_word*32 +: 32];
    assign way2_data = data_mem[addr_set][2][addr_word*32 +: 32];
    assign way3_data = data_mem[addr_set][3][addr_word*32 +: 32];

    // Mux 4:1 final seleccionado por encoder -> data_out
    always_comb
        case (hit_way)
            2'b11:   data_out = way3_data;
            2'b10:   data_out = way2_data;
            2'b01:   data_out = way1_data;
            default: data_out = way0_data;
        endcase

    // DESCOMPOSICION PARA STORE

    // Descomponer store_addr igual que addr
    logic [TAG_BITS-1:0] st_tag;
    logic [6:0]          st_set;
    logic [2:0]          st_word;

    assign st_tag  = addr[31:12];
    assign st_set  = addr[11:5];
    assign st_word = addr[4:2];

    logic store_way_l2 = store_en & store_hit_l2;

    // Escritura (fill e invalidación)
    integer s, w;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (s = 0; s < NUM_SETS; s = s + 1)
                for (w = 0; w < NUM_WAYS; w = w + 1)
                    valid[s][w] <= 1'b0;
        end else begin
            // Store write-through: solo si hubo hit en L2
            // Si miss, el controlador L2 escribe directo a memoria
            // L2 es no-write-allocate igual que L1
            if (store_way_l2) begin // estamos en STORE HIT WAY
                data_mem[st_set][st_hit_way][st_word*32 +: 32] <= store_data;
                // tag y valid no cambian
            end
            if (fill_en) begin
                tag_mem [fill_set][fill_way] <= fill_tag;
                data_mem[fill_set][fill_way] <= fill_line;
                valid   [fill_set][fill_way] <= 1'b1;
            end
            if (inv_en) begin
                valid[inv_set][inv_way] <= 1'b0;
            end
        end
    end

endmodule
