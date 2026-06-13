`timescale 1ns/1ps

// ===================================================================
//  Testbench para el controlador de caché L1-D
// ===================================================================

module tb_l1_con;

    logic clk  = 0;
    logic reset = 1;
    always #5 clk = ~clk;

    // ==== Entradas =================================================
    logic is_write = 0;
    logic [31:0] addr = 0;
    logic [1:0] size = 2'b10;   // word (no usado en la lógica interna)
    logic [31:0] wdata = 0;
    logic [255:0] fill_line = '0;
    logic [2:0] block_offset_counter = 0;
    logic hit_l1 = 0;
    logic [31:0] l1_data_out = 0;

    // ==== Salidas =================================================
    logic fill_en;
    logic fill_way_out;
    logic [5:0] fill_set;
    logic [20:0] fill_tag;
    logic [255:0] fill_line_out;
    logic inv_en;
    logic inv_way;
    logic [5:0] inv_set;
    logic [31:0] dato_cpu;
    logic miss_l1_out;

    // ==== DUT =====================================================
    l1_con uut (
        .clk(clk),
        .reset(reset),
        .is_write(is_write),
        .addr(addr),
        .size(size),
        .wdata(wdata),
        .fill_line(fill_line),
        .block_offset_counter (block_offset_counter),
        .hit_l1(hit_l1),
        .l1_data_out(l1_data_out),
        .fill_en(fill_en),
        .fill_way_out(fill_way_out),
        .fill_set(fill_set),
        .fill_tag(fill_tag),
        .fill_line_out(fill_line_out),
        .inv_en(inv_en),
        .inv_way(inv_way),
        .inv_set(inv_set),
        .dato_cpu(dato_cpu),
        .miss_l1_out(miss_l1_out)
    );

    // ==== Helper de display ====================================================================
    task show;
        $display("T=%0t | hit=%b wr=%b ctr=%0d | miss=%b dato=%08X | fill_en=%b inv_en=%b | set=%0d tag=%05X way=%b",
            $time, hit_l1, is_write, block_offset_counter, miss_l1_out, dato_cpu, fill_en, inv_en,
            fill_set, fill_tag, fill_way_out);
    endtask

    localparam [31:0] ADDR_A = 32'h0000_0040; // tag=0, set=2
    localparam [31:0] ADDR_B = 32'h0000_00A0; // tag=0, set=5
    localparam [31:0] ADDR_C = 32'h0000_0840; // tag=1, set=2

    logic first_way;
    integer i;

    initial begin
        $dumpfile("sim/waves/tb_l1_con.vcd");
        $dumpvars(0, tb_l1_con);

        // ==== Reset ============================================================================
        $display("\n=== 1. Reset inicial ===");
        #10; reset = 0;
        @(posedge clk); #1;
        show();

        // ==== Read hit ========================================================================
        $display("\n=== 2. Read hit (ADDR_A: tag=0 set=2) ===");
        addr = ADDR_A;
        hit_l1  = 1;
        is_write  = 0;
        l1_data_out = 32'hDDAA_BBFF;
        block_offset_counter = 3'd0;
        @(posedge clk); #1;
        show();
        $display(" miss_l1_out (esp 0) = %b", miss_l1_out);
        $display(" dato_cpu (esp 0xDDAABBFF) = 0x%08X", dato_cpu);
        $display(" fill_en (esp 0) = %b", fill_en);
        $display(" inv_en (esp 0) = %b", inv_en);
        hit_l1 = 0;

        // ==== Write hit ========================================================================
        $display("\n=== 3. Write hit (ADDR_A, wdata=0xCAFECAFE) ===");
        addr  = ADDR_A;
        hit_l1 = 1;
        is_write = 1;
        wdata  = 32'hCAFE_CAFE;
        block_offset_counter = 3'd0;
        $display("  fill_way_out antes del flanco = %b", fill_way_out);
        @(posedge clk); #1;   // replace = is_write & hit_l1 -> set_reg avanza
        is_write = 0;
        hit_l1  = 0;
        $display(" fill_way_out despues (FIFO avanzado) = %b", fill_way_out);
        $display(" fill_en (esp 0)  = %b", fill_en);
        $display(" inv_en  (esp 0)  = %b", inv_en);
        show();

        // ==== Read miss, burst ciclos 0-6 (sin fill_en ni inv_en) ================
        $display("\n=== 4. Read miss burst ciclos 0-6 (fill_en=0 inv_en=0) ===");
        addr  = ADDR_B;
        hit_l1  = 0;
        is_write = 0;
        fill_line = 256'hAABB_CCDD_BFFF_0011_2233_4455_6677_8899_AABB_CCDD_BFFF_0011_2233_4455_6677_8899;
        for (i = 0; i < 7; i = i + 1) begin
            block_offset_counter = i[2:0];
            @(posedge clk); #1;
            show();
        end

        // ==== Read miss, counter=7: inv_en antes del flanco, fill_en después ─
        // Timing: fill_en_comb es combinacional (counter==7 & ~hit).
        //  PRE-flanco:  fill_en_comb=1, fill_en_comb_d todavía=0 -> inv_en=1, fill_en=0
        //  POST-flanco: fill_en_comb_d=1, fill_en=1 -> inv_en=0
        $display("\n=== 5. Read miss counter=7 (ADDR_B set=5): inv_en luego fill_en ===");
        // counter venía de 6 -> fill_en_comb_d ya es 0 después del último posedge
        block_offset_counter = 3'd7;
        #1;
        $display(" [PRE-flanco] inv_en (esp 1) = %b fill_en (esp 0) = %b", inv_en, fill_en);
        show();
        @(posedge clk); #1;
        $display(" [POST-flanco] fill_en (esp 1) = %b  inv_en  (esp 0) = %b", fill_en, inv_en);
        $display(" fill_set (esp 5)  = %0d", fill_set);
        $display(" fill_tag (esp 0)  = 0x%05X", fill_tag);
        $display(" fill_line_out[31:0] = 0x%08X", fill_line_out[31:0]);
        show();
        // Limpiar
        block_offset_counter = 3'd0;
        @(posedge clk); #1;

        // ==== Write miss, counter=7: fill_en=1 pero inv_en=0 ====================─
        // inv_en incluye ~is_write, por tanto no se emite en stores
        $display("\n=== 6. Write miss counter=7 (ADDR_A set=2 is_write=1): fill_en sin inv_en ===");
        addr = ADDR_A;
        hit_l1  = 0;
        is_write = 1;
        fill_line = 256'hDDAA_BBFF_DDAA_BBFF_DDAA_BBFF_DDAA_BBFF_DDAA_BBFF_DDAA_BBFF_DDAA_BBFF_DDAA_BBFF;
        block_offset_counter = 3'd0;
        @(posedge clk); #1;   // asegurar fill_en_comb_d=0
        block_offset_counter = 3'd7;
        #1;
        $display(" [PRE-flanco]  inv_en  (esp 0 por is_write=1) = %b", inv_en);
        @(posedge clk); #1;
        $display(" [POST-flanco] fill_en (esp 1) = %b  inv_en (esp 0) = %b", fill_en, inv_en);
        show();
        is_write = 0;
        block_offset_counter = 3'd0;
        @(posedge clk); #1;

        // ====Verificación de campos de dirección (ADDR_C: tag=1 set=2) ========
        $display("\n=== 7. Campos de direccion (ADDR_C=0x%08X tag=1 set=2) ===", ADDR_C);
        addr = ADDR_C;
        hit_l1 = 0;
        is_write = 0;
        fill_line = '0;
        block_offset_counter = 3'd0;
        @(posedge clk); #1; // limpiar fill_en_comb_d
        block_offset_counter = 3'd7;
        #1;
        $display(" fill_set (esp 2) = %0d", fill_set);
        $display(" fill_tag (esp 1) = 0x%05X", fill_tag);
        $display(" inv_set  (esp 2) = %0d", inv_set);
        @(posedge clk); #1;
        show();
        block_offset_counter = 3'd0;
        @(posedge clk); #1;

        // ==== Rotación FIFO: 2 fills consecutivos al mismo set ====================
        // Después de cada fill, set_reg avanza el puntero FIFO (0->1->0).
        // Los dos fills deben usar ways distintos.
        $display("\n=== 8. FIFO replacement: 2 fills en set 2 (way debe alternar) ===");
        addr = ADDR_A;          // set=2
        hit_l1  = 0;
        is_write = 0;
        fill_line = 256'h1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF_0000;
        block_offset_counter = 3'd0;
        @(posedge clk); #1;
        block_offset_counter = 3'd7;
        first_way = fill_way_out;
        #1;
        $display("  Primer fill: fill_way_out = %b", fill_way_out);
        @(posedge clk); #1;   // fill_en=1 -> replace=1 -> set_reg avanza
        show();

        block_offset_counter = 3'd0;
        addr = ADDR_C; // mismo set=2, tag diferente
        fill_line = 256'hFEDC_BA98_7654_3210_FEDC_BA98_7654_3210_FEDC_BA98_7654_3210_FEDC_BA98_7654_3210;
        @(posedge clk); #1;
        block_offset_counter = 3'd7;
        #1;
        $display(" Segundo fill: fill_way_out (esp distinto a %b) = %b", first_way, fill_way_out);
        @(posedge clk); #1;
        show();
        block_offset_counter = 3'd0;
        @(posedge clk); #1;

        // ==== Reset durante miss ============================================================
        $display("\n=== 9. Reset durante miss (counter=6) ===");
        addr = ADDR_A;
        hit_l1 = 0;
        is_write = 0;
        fill_line = 256'hFF;
        block_offset_counter = 3'd6;
        @(posedge clk); #1;
        $display(" Antes del reset:");
        show();
        reset = 1;
        @(posedge clk); #1;
        reset = 0;
        block_offset_counter = 3'd0;
        $display(" Despues del reset (fill_en=0, way=0):");
        show();
        $display(" fill_way_out (esp 0) = %b", fill_way_out);
        $display(" fill_en (esp 0) = %b", fill_en);

        #20;
        $display("\n=== FIN tb_l1_con ===");
        $finish;
    end

endmodule
