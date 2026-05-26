`timescale 1ns/1ps

module tb_l1d_cache;

    // DUT I/O
    logic        clk;
    logic        reset;
    logic [31:0] addr;
    logic [31:0] data_out;
    logic        hit;
    logic        hit_way;

    logic        fill_en;
    logic        fill_way;
    logic [5:0]  fill_set;
    logic [20:0] fill_tag;
    logic [255:0] fill_line;

    logic        inv_en;
    logic        inv_way;
    logic [5:0]  inv_set;

    l1d_cache dut (
        .clk(clk), .reset(reset),
        .addr(addr), .data_out(data_out), .hit(hit), .hit_way(hit_way),
        .fill_en(fill_en), .fill_way(fill_way), .fill_set(fill_set),
        .fill_tag(fill_tag), .fill_line(fill_line),
        .inv_en(inv_en), .inv_way(inv_way), .inv_set(inv_set)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Counters
    int errors;
    int checks;

    // Build a synthetic 256-bit line where word[i] = base ^ i
    function automatic logic [255:0] make_line(input logic [31:0] base);
        logic [255:0] l;
        int i;
        l = '0;
        for (i = 0; i < 8; i = i + 1) begin
            l[i*32 +: 32] = base ^ i;
        end
        return l;
    endfunction

    // Pack an address from {tag, set, word, byte}
    function automatic logic [31:0] pack_addr(
        input logic [20:0] t,
        input logic [5:0]  s,
        input logic [2:0]  w,
        input logic [1:0]  b
    );
        return {t, s, w, b};
    endfunction

    // Drive a fill on the next posedge
    task automatic do_fill(
        input logic        way,
        input logic [5:0]  s,
        input logic [20:0] t,
        input logic [255:0] line
    );
        @(posedge clk);
        fill_en   <= 1'b1;
        fill_way  <= way;
        fill_set  <= s;
        fill_tag  <= t;
        fill_line <= line;
        @(posedge clk);
        fill_en   <= 1'b0;
        #1;
    endtask

    task automatic do_invalidate(
        input logic        way,
        input logic [5:0]  s
    );
        @(posedge clk);
        inv_en  <= 1'b1;
        inv_way <= way;
        inv_set <= s;
        @(posedge clk);
        inv_en  <= 1'b0;
        #1;
    endtask

    task automatic check_hit(
        input string        label,
        input logic [31:0]  a,
        input logic [31:0]  expected_data,
        input logic         expected_way
    );
        addr = a;
        #1;
        checks++;
        if (!hit) begin
            $error("[%0s] expected HIT, got MISS  addr=%h", label, a);
            errors++;
        end else if (hit_way !== expected_way) begin
            $error("[%0s] way mismatch  addr=%h got=%0d exp=%0d",
                   label, a, hit_way, expected_way);
            errors++;
        end else if (data_out !== expected_data) begin
            $error("[%0s] data mismatch  addr=%h got=%h exp=%h",
                   label, a, data_out, expected_data);
            errors++;
        end else begin
            $display("[%0s] OK  addr=%h data=%h way=%0d",
                     label, a, data_out, hit_way);
        end
    endtask

    task automatic check_miss(
        input string       label,
        input logic [31:0] a
    );
        addr = a;
        #1;
        checks++;
        if (hit) begin
            $error("[%0s] expected MISS, got HIT  addr=%h data=%h",
                   label, a, data_out);
            errors++;
        end else begin
            $display("[%0s] OK miss  addr=%h", label, a);
        end
    endtask

    initial begin
        $dumpfile("sim/waves/tb_l1d_cache.vcd");
        $dumpvars(0, tb_l1d_cache);

        errors = 0;
        checks = 0;

        // Init
        reset     = 1;
        addr      = 32'h0;
        fill_en   = 0;
        fill_way  = 0;
        fill_set  = 0;
        fill_tag  = 0;
        fill_line = '0;
        inv_en    = 0;
        inv_way   = 0;
        inv_set   = 0;

        // Hold reset a few cycles so valid bits go low
        repeat (2) @(posedge clk);
        reset = 0;
        #1;

        $display("== TEST 1: cold miss on every set ==");
        check_miss("cold0", pack_addr(21'h00000, 6'd0,  3'd0, 2'd0));
        check_miss("cold1", pack_addr(21'h00001, 6'd17, 3'd3, 2'd0));
        check_miss("cold2", pack_addr(21'h1FFFF, 6'd63, 3'd7, 2'd0));

        $display("== TEST 2: fill way0 of set 5, tag 0xA, read all 8 words ==");
        do_fill(1'b0, 6'd5, 21'h0000A, make_line(32'hDEAD0000));
        // expected word i = 0xDEAD0000 ^ i
        for (int w = 0; w < 8; w++) begin
            check_hit($sformatf("rd_w%0d", w),
                      pack_addr(21'h0000A, 6'd5, w[2:0], 2'd0),
                      32'hDEAD0000 ^ w,
                      1'b0);
        end

        $display("== TEST 3: tag mismatch on filled set -> miss ==");
        check_miss("tag_mm", pack_addr(21'h0000B, 6'd5, 3'd0, 2'd0));

        $display("== TEST 4: fill way1 same set with different tag ==");
        do_fill(1'b1, 6'd5, 21'h0000B, make_line(32'hCAFE0000));
        check_hit("way0_still",
                  pack_addr(21'h0000A, 6'd5, 3'd2, 2'd0),
                  32'hDEAD0000 ^ 2, 1'b0);
        check_hit("way1_new",
                  pack_addr(21'h0000B, 6'd5, 3'd2, 2'd0),
                  32'hCAFE0000 ^ 2, 1'b1);

        $display("== TEST 5: different set is independent ==");
        check_miss("other_set", pack_addr(21'h0000A, 6'd6, 3'd0, 2'd0));
        do_fill(1'b0, 6'd6, 21'h0000A, make_line(32'hBEEF0000));
        check_hit("set6_w0",
                  pack_addr(21'h0000A, 6'd6, 3'd0, 2'd0),
                  32'hBEEF0000, 1'b0);

        $display("== TEST 6: invalidate way0 set 5 -> miss for tag A, hit kept for tag B ==");
        do_invalidate(1'b0, 6'd5);
        check_miss("inv_way0",
                   pack_addr(21'h0000A, 6'd5, 3'd0, 2'd0));
        check_hit("way1_kept",
                  pack_addr(21'h0000B, 6'd5, 3'd1, 2'd0),
                  32'hCAFE0000 ^ 1, 1'b1);

        $display("== TEST 7: byte offset must be ignored (word selected by [4:2]) ==");
        check_hit("byte_off_1",
                  pack_addr(21'h0000B, 6'd5, 3'd4, 2'd1),
                  32'hCAFE0000 ^ 4, 1'b1);
        check_hit("byte_off_3",
                  pack_addr(21'h0000B, 6'd5, 3'd4, 2'd3),
                  32'hCAFE0000 ^ 4, 1'b1);

        $display("== TEST 8: refill way0 set 5 with new tag/data overrides ==");
        do_fill(1'b0, 6'd5, 21'h12345, make_line(32'h11110000));
        check_hit("refill_w0",
                  pack_addr(21'h12345, 6'd5, 3'd0, 2'd0),
                  32'h11110000, 1'b0);
        check_hit("refill_w7",
                  pack_addr(21'h12345, 6'd5, 3'd7, 2'd0),
                  32'h11110000 ^ 7, 1'b0);

        $display("== TEST 9: reset clears all valid bits ==");
        reset = 1;
        @(posedge clk); @(posedge clk);
        reset = 0;
        #1;
        check_miss("post_rst_a", pack_addr(21'h12345, 6'd5, 3'd0, 2'd0));
        check_miss("post_rst_b", pack_addr(21'h0000B, 6'd5, 3'd0, 2'd0));
        check_miss("post_rst_c", pack_addr(21'h0000A, 6'd6, 3'd0, 2'd0));

        $display("==================================");
        $display("checks=%0d  errors=%0d", checks, errors);
        if (errors == 0) $display("RESULT: PASS");
        else             $display("RESULT: FAIL");
        $display("==================================");
        $finish;
    end

endmodule
