// ============================================================
//  tb_l2_cache.sv  —  Testbench unitario para l2_cache.sv
//
//  Cobertura:
//    T1  – Reset: cold miss
//    T2  – Fill → hit ciclo siguiente; tag distinto → miss
//    T3  – Lectura correcta de los 8 words de la línea
//    T4  – 4 fills mismo set, vías 0-3 independientes
//    T5  – inv_en invalida vía exacta; otras vías intactas
//    T6  – store_en write-through actualiza solo el word indicado
//    T7  – hit_l2_wb detecta hit con store_addr ≠ addr principal
//    T8  – Sets independientes: mismo tag, sets distintos
//    T9  – Fill + inv_en simultáneos en vías distintas
//    T10 – store_en en todos los 8 words
//
//  Compilar:
//    iverilog -g2012 -o tb_l2_cache tb_l2_cache.sv l2_cache.sv && vvp tb_l2_cache
// ============================================================
`timescale 1ns/1ps

module tb_l2_cache;

// -------------------------------------------------------
// DUT ports
// -------------------------------------------------------
logic        clk, reset;
logic [31:0] addr;
logic [31:0] data_out;
logic        hit;

logic         fill_en;
logic [1:0]   fill_way;
logic [6:0]   fill_set;
logic [19:0]  fill_tag;
logic [255:0] fill_line;

logic        inv_en;
logic [1:0]  inv_way;
logic [6:0]  inv_set;

logic        store_en;
logic [31:0] store_addr;
logic [31:0] store_data;

logic        hit_l2_wb;
logic [6:0]  l2_refill_set;

// -------------------------------------------------------
// Variables de test — declaradas en scope de módulo para
// que iverilog las acepte (no soporta logic local en begin)
// -------------------------------------------------------
logic [255:0] t_line;
logic [255:0] t_lines [0:3];
logic [19:0]  t_tags  [0:3];
logic [31:0]  t_new_val;
integer       t_w, t_v;

// -------------------------------------------------------
// DUT
// -------------------------------------------------------
l2_cache DUT (.*);

// -------------------------------------------------------
// Clock 10 ns
// -------------------------------------------------------
initial clk = 0;
always  #5 clk = ~clk;

// -------------------------------------------------------
// Contadores
// -------------------------------------------------------
integer pass_cnt, fail_cnt;
initial begin pass_cnt = 0; fail_cnt = 0; end

task automatic chk;
    input [200*8-1:0] lbl;
    input logic got;
    input logic exp;
    begin
        if (got === exp) begin
            $display("  PASS  %0s", lbl);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  FAIL  %0s  got=%0b  exp=%0b", lbl, got, exp);
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

task automatic chk32;
    input [200*8-1:0] lbl;
    input [31:0] got;
    input [31:0] exp;
    begin
        if (got === exp) begin
            $display("  PASS  %0s  (0x%08h)", lbl, got);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  FAIL  %0s  got=0x%08h  exp=0x%08h", lbl, got, exp);
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

// -------------------------------------------------------
// Helper: limpiar entradas de control
// -------------------------------------------------------
task clear_inputs;
    begin
        addr          = '0;
        fill_en       = 0; fill_way = '0; fill_set = '0;
        fill_tag      = '0; fill_line = '0;
        inv_en        = 0; inv_way = '0; inv_set = '0;
        store_en      = 0; store_addr = '0; store_data = '0;
        l2_refill_set = '0;
    end
endtask

// -------------------------------------------------------
// Helper: fill de una línea (1 ciclo activo)
// -------------------------------------------------------
task do_fill;
    input [1:0]   way;
    input [6:0]   fset;
    input [19:0]  ftag;
    input [255:0] fline;
    begin
        @(negedge clk);
        fill_en   = 1; fill_way = way;
        fill_set  = fset; fill_tag = ftag; fill_line = fline;
        @(posedge clk); #1;
        fill_en = 0;
    end
endtask

// -------------------------------------------------------
// Helper: construye dirección desde (tag, set, word)
//   addr[31:12]=tag  addr[11:5]=set  addr[4:2]=word
// -------------------------------------------------------
function [31:0] make_addr;
    input [19:0] tag;
    input [6:0]  fset;
    input [2:0]  word;
    begin
        make_addr = {tag, fset, word, 2'b00};
    end
endfunction

// ============================================================
// MAIN
// ============================================================
initial begin
    $dumpfile("tb_l2_cache.vcd");
    $dumpvars(0, tb_l2_cache);
    clear_inputs();

    // --------------------------------------------------------
    // T1 – Reset: cold miss
    // --------------------------------------------------------
    $display("\n--- T1: Reset / cold miss ---");
    reset = 1;
    repeat(2) @(posedge clk); #1;
    reset = 0;

    addr = make_addr(20'hAAAAA, 7'h00, 3'd0);
    @(posedge clk); #1;
    chk("T1 cold miss tras reset", hit, 1'b0);

    // --------------------------------------------------------
    // T2 – Fill → hit; tag distinto → miss
    // --------------------------------------------------------
    $display("\n--- T2: Fill -> hit ---");
    t_line = 256'hDEADBEEFCAFEF00D12345678_9ABCDEF0DEADBEEFCAFEF00D123456789ABCDEF0;
    do_fill(2'd0, 7'h05, 20'h00001, t_line);

    addr = make_addr(20'h00001, 7'h05, 3'd0);
    @(posedge clk); #1;
    chk("T2 hit tras fill way0", hit, 1'b1);

    addr = make_addr(20'h00002, 7'h05, 3'd0);
    @(posedge clk); #1;
    chk("T2 miss con tag diferente", hit, 1'b0);

    // --------------------------------------------------------
    // T3 – Lectura de los 8 words de la línea
    // --------------------------------------------------------
    $display("\n--- T3: Lectura 8 words ---");
    t_line[  31:  0] = 32'hA0A0_0000;
    t_line[  63: 32] = 32'hA1A1_1111;
    t_line[  95: 64] = 32'hA2A2_2222;
    t_line[ 127: 96] = 32'hA3A3_3333;
    t_line[ 159:128] = 32'hA4A4_4444;
    t_line[ 191:160] = 32'hA5A5_5555;
    t_line[ 223:192] = 32'hA6A6_6666;
    t_line[ 255:224] = 32'hA7A7_7777;

    do_fill(2'd0, 7'h0A, 20'hABCDE, t_line);

    for (t_w = 0; t_w < 8; t_w = t_w + 1) begin
        addr = make_addr(20'hABCDE, 7'h0A, t_w[2:0]);
        @(posedge clk); #1;
        chk("T3 hit word", hit, 1'b1);
        chk32("T3 data word", data_out, t_line[t_w*32 +: 32]);
    end

    // --------------------------------------------------------
    // T4 – 4 fills en el mismo set, vías 0-3
    // --------------------------------------------------------
    $display("\n--- T4: 4 vias en mismo set ---");
    t_lines[0] = 256'h0001; t_tags[0] = 20'hTA000;
    t_lines[1] = 256'h0002; t_tags[1] = 20'hTA001;
    t_lines[2] = 256'h0003; t_tags[2] = 20'hTA002;
    t_lines[3] = 256'h0004; t_tags[3] = 20'hTA003;

    for (t_v = 0; t_v < 4; t_v = t_v + 1)
        do_fill(t_v[1:0], 7'h01, t_tags[t_v], t_lines[t_v]);

    for (t_v = 0; t_v < 4; t_v = t_v + 1) begin
        addr = make_addr(t_tags[t_v], 7'h01, 3'd0);
        @(posedge clk); #1;
        chk("T4 hit way", hit, 1'b1);
        chk32("T4 data way word0", data_out, t_lines[t_v][31:0]);
    end

    // --------------------------------------------------------
    // T5 – inv_en invalida la vía exacta
    // --------------------------------------------------------
    $display("\n--- T5: inv_en ---");
    t_line = 256'hCAFE_1234;
    do_fill(2'd2, 7'h02, 20'hFACE0, t_line);

    addr = make_addr(20'hFACE0, 7'h02, 3'd0);
    @(posedge clk); #1;
    chk("T5 hit antes de inv", hit, 1'b1);

    @(negedge clk);
    inv_en = 1; inv_way = 2'd2; inv_set = 7'h02;
    @(posedge clk); #1;
    inv_en = 0;

    addr = make_addr(20'hFACE0, 7'h02, 3'd0);
    @(posedge clk); #1;
    chk("T5 miss tras inv", hit, 1'b0);

    // Otra vía del mismo set no afectada
    t_line = 256'hBEEF_5678;
    do_fill(2'd0, 7'h02, 20'hBEEF0, t_line);
    addr = make_addr(20'hBEEF0, 7'h02, 3'd0);
    @(posedge clk); #1;
    chk("T5 otra via no afectada", hit, 1'b1);

    // --------------------------------------------------------
    // T6 – store_en write-through
    // --------------------------------------------------------
    $display("\n--- T6: store_en write-through ---");
    t_line        = '0;
    t_line[63:32] = 32'hOLD_WORD1;
    do_fill(2'd0, 7'h10, 20'h00A00, t_line);

    @(negedge clk);
    store_en   = 1;
    store_addr = make_addr(20'h00A00, 7'h10, 3'd1);
    store_data = 32'hNEW_0001;
    @(posedge clk); #1;
    store_en = 0;

    addr = make_addr(20'h00A00, 7'h10, 3'd1);
    @(posedge clk); #1;
    chk("T6 hit tras store_en", hit, 1'b1);
    chk32("T6 word1 actualizado", data_out, 32'hNEW_0001);

    addr = make_addr(20'h00A00, 7'h10, 3'd0);
    @(posedge clk); #1;
    chk32("T6 word0 sin cambios", data_out, t_line[31:0]);

    // --------------------------------------------------------
    // T7 – hit_l2_wb
    // --------------------------------------------------------
    $display("\n--- T7: hit_l2_wb ---");
    t_line = 256'hBEEF_9999;
    do_fill(2'd0, 7'h20, 20'hDEAD0, t_line);

    addr       = make_addr(20'h00000, 7'h00, 3'd0);
    store_addr = make_addr(20'hDEAD0, 7'h20, 3'd0);
    @(posedge clk); #1;
    chk("T7 hit_l2_wb=1",     hit_l2_wb, 1'b1);
    chk("T7 hit principal=0", hit,        1'b0);

    store_addr = make_addr(20'hFFFFF, 7'h7F, 3'd7);
    @(posedge clk); #1;
    chk("T7 hit_l2_wb=0 (miss)", hit_l2_wb, 1'b0);

    // --------------------------------------------------------
    // T8 – Sets independientes
    // --------------------------------------------------------
    $display("\n--- T8: Sets independientes ---");
    t_lines[0] = 256'hAAAA_AAAA;
    t_lines[1] = 256'hBBBB_BBBB;
    do_fill(2'd0, 7'h30, 20'hCA110, t_lines[0]);
    do_fill(2'd0, 7'h31, 20'hCA110, t_lines[1]);

    addr = make_addr(20'hCA110, 7'h30, 3'd0);
    @(posedge clk); #1;
    chk("T8 hit set 0x30",  hit,      1'b1);
    chk32("T8 data 0x30",   data_out, t_lines[0][31:0]);

    addr = make_addr(20'hCA110, 7'h31, 3'd0);
    @(posedge clk); #1;
    chk("T8 hit set 0x31",  hit,      1'b1);
    chk32("T8 data 0x31",   data_out, t_lines[1][31:0]);

    // --------------------------------------------------------
    // T9 – Fill + inv_en simultáneos en vías distintas
    // --------------------------------------------------------
    $display("\n--- T9: Fill y inv_en simultaneos ---");
    // Precargar way=1 y way=3 en set=0x40
    do_fill(2'd1, 7'h40, 20'h11111, 256'h1111);
    do_fill(2'd3, 7'h40, 20'h33333, 256'h3333);

    // Simultaneo: fill way=0 + inv way=1
    @(negedge clk);
    fill_en  = 1; fill_way = 2'd0;
    fill_set = 7'h40; fill_tag = 20'h00000; fill_line = 256'hF00F;
    inv_en   = 1; inv_way = 2'd1; inv_set = 7'h40;
    @(posedge clk); #1;
    fill_en = 0; inv_en = 0;

    // way=0 debe tener hit
    addr = make_addr(20'h00000, 7'h40, 3'd0);
    @(posedge clk); #1;
    chk("T9 hit way0 tras fill", hit, 1'b1);
    chk32("T9 data way0", data_out, 32'h0000_F00F);

    // way=1 debe ser miss
    addr = make_addr(20'h11111, 7'h40, 3'd0);
    @(posedge clk); #1;
    chk("T9 miss way1 tras inv", hit, 1'b0);

    // way=3 no afectado
    addr = make_addr(20'h33333, 7'h40, 3'd0);
    @(posedge clk); #1;
    chk("T9 hit way3 intacto", hit, 1'b1);

    // --------------------------------------------------------
    // T10 – store_en en todos los 8 words
    // --------------------------------------------------------
    $display("\n--- T10: store_en todos los words ---");
    t_line = '0;
    do_fill(2'd0, 7'h50, 20'hCCCCC, t_line);

    for (t_w = 0; t_w < 8; t_w = t_w + 1) begin
        t_new_val = 32'hDE00_0000 + t_w;
        @(negedge clk);
        store_en   = 1;
        store_addr = make_addr(20'hCCCCC, 7'h50, t_w[2:0]);
        store_data = t_new_val;
        @(posedge clk); #1;
        store_en = 0;

        addr = make_addr(20'hCCCCC, 7'h50, t_w[2:0]);
        @(posedge clk); #1;
        chk32("T10 store word", data_out, t_new_val);
    end

    // --------------------------------------------------------
    // Resumen
    // --------------------------------------------------------
    $display("\n========================================");
    $display("  RESULTADOS: %0d PASS  /  %0d FAIL", pass_cnt, fail_cnt);
    $display("========================================");
    if (fail_cnt == 0) $display("ALL TESTS PASSED");
    else               $display("SOME TESTS FAILED");

    $finish;
end

initial begin #100000; $display("TIMEOUT"); $finish; end

endmodule