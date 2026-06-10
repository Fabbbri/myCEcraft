// ============================================================
//  l1d_cache.sv — 2-way set associative, write-through,
//  no-write-allocate, 64 sets, línea 256 bits
// ============================================================

module l1d_cache (
    input  logic        clk,
    input  logic        reset,

    input  logic [31:0] addr,
    output logic [31:0] data_out,
    output logic        hit,
    output logic        hit_way,

    input  logic         fill_en,
    input  logic         fill_way,
    input  logic [5:0]   fill_set,
    input  logic [20:0]  fill_tag,
    input  logic [255:0] fill_line,

    input  logic        inv_en,
    input  logic        inv_way,
    input  logic [5:0]  inv_set,

    input  logic        is_write,
    input  logic [31:0] wdata,

    output logic        store_hit_l1
);

    localparam int NUM_SETS  = 64;
    localparam int LINE_BITS = 256;
    localparam int TAG_BITS  = 21;

    logic [TAG_BITS-1:0]  tag_mem  [NUM_SETS-1:0][0:1];
    logic [LINE_BITS-1:0] data_mem [NUM_SETS-1:0][0:1];
    logic                 valid    [NUM_SETS-1:0][0:1];

    logic [TAG_BITS-1:0] addr_tag;
    logic [5:0]          addr_set;
    logic [2:0]          addr_word;

    assign addr_tag  = addr[31:11];
    assign addr_set  = addr[10:5];
    assign addr_word = addr[4:2];

    logic hit0, hit1;
    assign hit0 = valid[addr_set][0] & (tag_mem[addr_set][0] == addr_tag);
    assign hit1 = valid[addr_set][1] & (tag_mem[addr_set][1] == addr_tag);

    assign hit     = hit0 | hit1;
    assign hit_way = hit1;

    // FIX: mux explícito de palabra (sin variable part-select)
    logic [LINE_BITS-1:0] sel_line;
    assign sel_line = hit1 ? data_mem[addr_set][1]
                           : data_mem[addr_set][0];

    logic [31:0] word_mux;
    always_comb
        case (addr_word)
            3'd0: word_mux = sel_line[  31:  0];
            3'd1: word_mux = sel_line[  63: 32];
            3'd2: word_mux = sel_line[  95: 64];
            3'd3: word_mux = sel_line[ 127: 96];
            3'd4: word_mux = sel_line[ 159:128];
            3'd5: word_mux = sel_line[ 191:160];
            3'd6: word_mux = sel_line[ 223:192];
            3'd7: word_mux = sel_line[ 255:224];
            default: word_mux = '0;
        endcase

    assign data_out = word_mux;

    assign store_hit_l1 = hit & is_write;

    // Escritura
    integer s;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (s = 0; s < NUM_SETS; s = s + 1) begin
                valid[s][0] <= 1'b0;
                valid[s][1] <= 1'b0;
            end
        end else begin
            // Store hit: FIX — case explícito, sin variable part-select
            if (store_hit_l1) begin
                case (addr_word)
                    3'd0: data_mem[addr_set][hit_way][  31:  0] <= wdata;
                    3'd1: data_mem[addr_set][hit_way][  63: 32] <= wdata;
                    3'd2: data_mem[addr_set][hit_way][  95: 64] <= wdata;
                    3'd3: data_mem[addr_set][hit_way][ 127: 96] <= wdata;
                    3'd4: data_mem[addr_set][hit_way][ 159:128] <= wdata;
                    3'd5: data_mem[addr_set][hit_way][ 191:160] <= wdata;
                    3'd6: data_mem[addr_set][hit_way][ 223:192] <= wdata;
                    3'd7: data_mem[addr_set][hit_way][ 255:224] <= wdata;
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