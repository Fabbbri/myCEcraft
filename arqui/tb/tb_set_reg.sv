`timescale 1ns/1ps

module tb_set_reg;

    // === L1: 64 sets, 2 ways (WAY_BITS=1) ===
    logic clk    = 0;
    logic reset  = 1;
    logic [5:0] set1   = 0;
    logic fill1  = 0;
    logic way1;

    set_reg #(.NUM_SETS(64), .NUM_WAYS(2)) DUT_L1 (
        .clk (clk),
        .reset (reset),
        .set (set1),
        .fill_en (fill1),
        .way_out (way1)
    );

    // === L2: 128 sets, 4 ways (WAY_BITS=2) ===
    logic [6:0] set2  = 0;
    logic fill2 = 0;
    logic [1:0] way2;

    set_reg #(.NUM_SETS(128), .NUM_WAYS(4)) DUT_L2 (
        .clk (clk),
        .reset (reset),
        .set (set2),
        .fill_en (fill2),
        .way_out (way2)
    );

    always #5 clk = ~clk;

    task show_l1;
        $display("T=%0t | set1=%0d fill1=%b | way1=%b", $time, set1, fill1, way1);
    endtask

    task show_l2;
        $display("T=%0t | set2=%0d fill2=%b | way2=%02b", $time, set2, fill2, way2);
    endtask

    initial begin
        $dumpfile("sim/waves/tb_set_reg.vcd");
        $dumpvars(0, tb_set_reg);

        #10; reset = 0;

        // estado inicial
        $display("\n=== Estado inicial tras reset ===");
        set1 = 0; set2 = 0; #1;
        show_l1(); 
        show_l2();

        // =====================================================
        // L1: set 0 -> 0->1->0->1
        // =====================================================

        $display("\n=== L1: fill x1 en set 0 (espera way1=1) ===");
        set1 = 6'd0; fill1 = 1;
        @(posedge clk); #1;
        show_l1(); fill1 = 0;

        $display("\n=== L1: fill x2 en set 0 (espera way1=0, wrap) ===");
        set1 = 6'd0; fill1 = 1;
        @(posedge clk); #1;
        show_l1(); fill1 = 0;

        $display("\n=== L1: fill x3 en set 0 (espera way1=1) ===");
        set1 = 6'd0; fill1 = 1;
        @(posedge clk); #1;
        show_l1(); fill1 = 0;

        // =====================================================
        // L1: sets independientes
        // =====================================================

        $display("\n=== L1: fill en set 5 no afecta set 0 ===");
        set1 = 6'd5; fill1 = 1;
        @(posedge clk); #1;
        show_l1(); fill1 = 0;
        set1 = 6'd0; #1;
        show_l1();

        $display("\n=== L1: set 5 avanzo a 1, set 7 sigue en 0 ===");
        set1 = 6'd5; #1; show_l1();
        set1 = 6'd7; #1; show_l1();

        // =====================================================
        // L2: set 0 -> 00->01->10->11->00
        // =====================================================

        $display("\n=== L2: estado inicial set 0 (espera way2=00) ===");
        set2 = 7'd0; #1; show_l2();

        $display("\n=== L2: fill x1 (espera way2=01) ===");
        set2 = 7'd0; fill2 = 1;
        @(posedge clk); #1;
        show_l2(); fill2 = 0;

        $display("\n=== L2: fill x2 (espera way2=10) ===");
        set2 = 7'd0; fill2 = 1;
        @(posedge clk); #1;
        show_l2(); fill2 = 0;

        $display("\n=== L2: fill x3 (espera way2=11) ===");
        set2 = 7'd0; fill2 = 1;
        @(posedge clk); #1;
        show_l2(); fill2 = 0;

        $display("\n=== L2: fill x4 (espera way2=00, wrap) ===");
        set2 = 7'd0; fill2 = 1;
        @(posedge clk); #1;
        show_l2(); fill2 = 0;

        // =====================================================
        // L1: set maximo (63)
        // =====================================================

        $display("\n=== L1: set maximo 63 inicia en 0 ===");
        set1 = 6'd63; #1; show_l1();

        $display("\n=== L1: fill x1 en set 63 (espera way1=1) ===");
        set1 = 6'd63; fill1 = 1;
        @(posedge clk); #1;
        show_l1(); fill1 = 0;

        $display("\n=== L1: fill x2 en set 63 (espera way1=0, wrap) ===");
        set1 = 6'd63; fill1 = 1;
        @(posedge clk); #1;
        show_l1(); fill1 = 0;

        $display("\n=== L1: set 63 no afecta set 62 ===");
        set1 = 6'd62; #1; show_l1();

        // =====================================================
        // L2: sets independientes y sets grandes
        // =====================================================

        $display("\n=== L2: set 1 inicia en 00, set 0 sigue en 00 ===");
        set2 = 7'd1; #1;
        show_l2();
        set2 = 7'd0; #1;
        show_l2();

        $display("\n=== L2: set 64 (mitad superior) inicia en 00 ===");
        set2 = 7'd64; #1; show_l2();

        $display("\n=== L2: fill x2 en set 64 (espera way2=10) ===");
        set2 = 7'd64; fill2 = 1;
        @(posedge clk); #1;
        show_l2(); fill2 = 0;
        set2 = 7'd64; fill2 = 1;
        @(posedge clk); #1;
        show_l2(); fill2 = 0;

        $display("\n=== L2: set 100 inicia en 00, set 64 no afectado ===");
        set2 = 7'd100; #1; show_l2();
        set2 = 7'd64;  #1; show_l2();

        $display("\n=== L2: set maximo 127, fill x3 (espera way2=11) ===");
        set2 = 7'd127; fill2 = 1; @(posedge clk); #1;
        show_l2(); fill2 = 0;
        set2 = 7'd127; fill2 = 1; @(posedge clk); #1;
        show_l2(); fill2 = 0;
        set2 = 7'd127; fill2 = 1;
        @(posedge clk); #1;
        show_l2(); fill2 = 0;

        $display("\n=== L2: set 126 sigue en 00 (set 127 no lo afecta) ===");
        set2 = 7'd126; #1; show_l2();

        // =====================================================
        // Reset limpia todo
        // =====================================================

        $display("\n=== Avanzar set 0 L2 y L1, luego reset ===");
        set2 = 7'd0; 
        fill2 = 1; 
        @(posedge clk); 
        #1; 
        fill2 = 0;
        set1 = 6'd0; 
        fill1 = 1; 
        @(posedge clk); 
        #1; 
        fill1 = 0;
        $display("Antes del reset:");
        set1 = 0; 
        set2 = 0; 
        #1;
        show_l1(); 
        show_l2();

        reset = 1; 
        @(posedge clk); 
        #1; 
        reset = 0;
        $display("Despues del reset:");
        #1; 
        show_l1(); 
        show_l2();

        $finish;
    end

endmodule
