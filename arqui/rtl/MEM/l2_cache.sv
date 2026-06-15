// ============================================================
//  l2_cache.sv — 4-way set associative, write-through,
//  no-write-allocate, 128 sets, línea 256 bits
// ============================================================

module l2_cache (
    input  logic        clk,
    input  logic        reset,

    input  logic [31:0] addr,
    output logic [31:0] data_out,
    output logic        hit,

    input  logic         fill_en,
    input  logic [1:0]   fill_way,
    input  logic [6:0]   fill_set,
    input  logic [19:0]  fill_tag,
    input  logic [255:0] fill_line,

    input  logic        inv_en,
    input  logic [1:0]  inv_way,
    input  logic [6:0]  inv_set,

    input  logic        store_en,
    input  logic [31:0] store_addr,
    input  logic [31:0] store_data,

    output logic        hit_l2_wb,

    input  logic [6:0]  l2_refill_set
);

    localparam int NUM_SETS  = 128;
    localparam int LINE_BITS = 256;
    localparam int TAG_BITS  = 20;
    localparam int NUM_WAYS  = 4;

    logic [TAG_BITS-1:0]  tag_mem  [NUM_SETS-1:0][0:NUM_WAYS-1];
    logic [LINE_BITS-1:0] data_mem [NUM_SETS-1:0][0:NUM_WAYS-1];
    logic                 valid    [NUM_SETS-1:0][0:NUM_WAYS-1];

    logic [TAG_BITS-1:0] addr_tag;
    logic [6:0] addr_set;
    logic [2:0] addr_word;
    logic [1:0]  hit_way_wb;
    logic [1:0]  hit_way;

    assign addr_tag  = addr[31:12];
    assign addr_set  = addr[11:5];
    assign addr_word = addr[4:2];

    // Hit logic
    logic hit0, hit1, hit2, hit3;
    assign hit0 = valid[addr_set][0] & (tag_mem[addr_set][0] == addr_tag);
    assign hit1 = valid[addr_set][1] & (tag_mem[addr_set][1] == addr_tag);
    assign hit2 = valid[addr_set][2] & (tag_mem[addr_set][2] == addr_tag);
    assign hit3 = valid[addr_set][3] & (tag_mem[addr_set][3] == addr_tag);

    assign hit        = hit0 | hit1 | hit2 | hit3;
    assign hit_way[1] = hit2 | hit3;
    assign hit_way[0] = hit1 | hit3;

    // FIX: lectura principal con case explícito (sin variable part-select)
    logic [LINE_BITS-1:0] sel_line;
    always_comb
        case (hit_way)
            2'b11:   sel_line = data_mem[addr_set][3];
            2'b10:   sel_line = data_mem[addr_set][2];
            2'b01:   sel_line = data_mem[addr_set][1];
            default: sel_line = data_mem[addr_set][0];
        endcase

    always_comb
        case (addr_word)
            3'd0: data_out = sel_line[  31:  0];
            3'd1: data_out = sel_line[  63: 32];
            3'd2: data_out = sel_line[  95: 64];
            3'd3: data_out = sel_line[ 127: 96];
            3'd4: data_out = sel_line[ 159:128];
            3'd5: data_out = sel_line[ 191:160];
            3'd6: data_out = sel_line[ 223:192];
            3'd7: data_out = sel_line[ 255:224];
            default: data_out = '0;
        endcase

    // FIX: puerto refill con case explícito
    logic [LINE_BITS-1:0] refill_line;
    always_comb
        case (hit_way)
            2'b11:   refill_line = data_mem[l2_refill_set][3];
            2'b10:   refill_line = data_mem[l2_refill_set][2];
            2'b01:   refill_line = data_mem[l2_refill_set][1];
            default: refill_line = data_mem[l2_refill_set][0];
        endcase

    // WB hit logic
    logic [TAG_BITS-1:0] st_tag;
    logic [6:0]          st_set;
    logic [2:0]          st_word;

    assign st_tag  = store_addr[31:12];
    assign st_set  = store_addr[11:5];
    assign st_word = store_addr[4:2];

    logic st_hit0, st_hit1, st_hit2, st_hit3;
    assign st_hit0 = valid[st_set][0] & (tag_mem[st_set][0] == st_tag);
    assign st_hit1 = valid[st_set][1] & (tag_mem[st_set][1] == st_tag);
    assign st_hit2 = valid[st_set][2] & (tag_mem[st_set][2] == st_tag);
    assign st_hit3 = valid[st_set][3] & (tag_mem[st_set][3] == st_tag);

    assign hit_l2_wb     = st_hit0 | st_hit1 | st_hit2 | st_hit3;
    assign hit_way_wb[1] = st_hit2 | st_hit3;
    assign hit_way_wb[0] = st_hit1 | st_hit3;

    // Escritura
    integer s, w;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (s = 0; s < NUM_SETS; s = s + 1)
                for (w = 0; w < NUM_WAYS; w = w + 1)
                    valid[s][w] <= 1'b0;
        end else begin
            // Store write-through: FIX — case explícito
            if (store_en & hit_l2_wb) begin
                case (st_word)
                    3'd0: data_mem[st_set][hit_way_wb][  31:  0] <= store_data;
                    3'd1: data_mem[st_set][hit_way_wb][  63: 32] <= store_data;
                    3'd2: data_mem[st_set][hit_way_wb][  95: 64] <= store_data;
                    3'd3: data_mem[st_set][hit_way_wb][ 127: 96] <= store_data;
                    3'd4: data_mem[st_set][hit_way_wb][ 159:128] <= store_data;
                    3'd5: data_mem[st_set][hit_way_wb][ 191:160] <= store_data;
                    3'd6: data_mem[st_set][hit_way_wb][ 223:192] <= store_data;
                    3'd7: data_mem[st_set][hit_way_wb][ 255:224] <= store_data;
                    default: ;
                endcase
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