// L1-D cache datapath: 2-way set associative.
// Size 4 KB, line 32 B (8 words), 64 sets, 32-bit words, 32-bit addrs.
// Address layout:
//   [31:11] tag (21b)  [10:5] set (6b)  [4:2] word (3b)  [1:0] byte (2b)
//
// This module exposes:
//   * a combinational lookup port  -> {hit, data_out}
//   * a synchronous fill port      -> loads a full line into a chosen way
//   * a synchronous invalidate port
//
// Replacement policy / write policy / refill state machine live outside
// this module (cache controller, future stage).

module l1d_cache (
    input  logic        clk,
    input  logic        reset,

    // Lookup port (combinational)
    input  logic [31:0] addr,
    output logic [31:0] data_out,
    output logic        hit,
    output logic        hit_way,      // 0 -> way0, 1 -> way1 (valid when hit)

    // Fill port (synchronous): controller writes a full line in here
    input  logic        fill_en,
    input  logic        fill_way,     // 0 or 1
    input  logic [5:0]  fill_set,
    input  logic [20:0] fill_tag,
    input  logic [255:0] fill_line,

    // Invalidate port (synchronous)
    input  logic        inv_en,
    input  logic        inv_way,
    input  logic [5:0]  inv_set
);

    // Geometry constants (kept local for readability; not parameterized
    // intentionally to match spec exactly during this stage).
    localparam int NUM_SETS   = 64;
    localparam int LINE_BITS  = 256;
    localparam int TAG_BITS   = 21;

    // Storage
    logic [TAG_BITS-1:0] tag_mem  [NUM_SETS-1:0][0:1];
    logic [LINE_BITS-1:0] data_mem [NUM_SETS-1:0][0:1];
    logic                 valid    [NUM_SETS-1:0][0:1];

    // Address decode
    logic [20:0] addr_tag;
    logic [5:0]  addr_set;
    logic [2:0]  addr_word;

    assign addr_tag  = addr[31:11];
    assign addr_set  = addr[10:5];
    assign addr_word = addr[4:2];

    // Tag compare per way + valid check
    logic hit0, hit1;
    assign hit0 = valid[addr_set][0] && (tag_mem[addr_set][0] == addr_tag);
    assign hit1 = valid[addr_set][1] && (tag_mem[addr_set][1] == addr_tag);
    assign hit     = hit0 | hit1;
    assign hit_way = hit1;     // priority irrelevant: tags are unique per set

    // Way mux -> line select
    logic [LINE_BITS-1:0] sel_line;
    assign sel_line = hit1 ? data_mem[addr_set][1] : data_mem[addr_set][0];

    // Word mux inside the line (block offset)
    assign data_out = sel_line[addr_word*32 +: 32];

    // Synchronous side: reset clears valid bits; fill writes a full line;
    // invalidate drops the valid bit on the selected way.
    integer s;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (s = 0; s < NUM_SETS; s = s + 1) begin
                valid[s][0] <= 1'b0;
                valid[s][1] <= 1'b0;
            end
        end else begin
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
