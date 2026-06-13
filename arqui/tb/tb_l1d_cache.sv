`timescale 1ns/1ps

module tb_l1d_cache;

    logic        clk;
    logic        reset;
    logic [31:0] addr;
    logic [31:0] data_out;
    logic        hit;

    logic         fill_en;
    logic         fill_way;
    logic [5:0]   fill_set;
    logic [20:0]  fill_tag;
    logic [255:0] fill_line;

    logic        inv_en;
    logic        inv_way;
    logic [5:0]  inv_set;

    l1d_cache dut (
        .clk(clk), .reset(reset),
        .addr(addr), .data_out(data_out), .hit(hit),
        .fill_en(fill_en), .fill_way(fill_way), .fill_set(fill_set),
        .fill_tag(fill_tag), .fill_line(fill_line),
        .inv_en(inv_en), .inv_way(inv_way), .inv_set(inv_set)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // lru bit por set (modelo del futuro controlador)
    logic lru [0:63];

    // contadores por benchmark
    int g_accesses;
    int g_hits;
    int g_misses;

    // tabla final
    string rep_name [0:6];
    int    rep_acc  [0:6];
    int    rep_hit  [0:6];
    int    rep_miss [0:6];
    int    rep_n;

    function automatic logic [255:0] synth_line(input logic [31:0] block_id);
        logic [255:0] l;
        int i;
        l = '0;
        for (i = 0; i < 8; i = i + 1) begin
            l[i*32 +: 32] = {block_id[23:0], i[7:0]};
        end
        return l;
    endfunction

    task automatic clear_cache;
        reset = 1;
        @(posedge clk); @(posedge clk);
        reset = 0;
        for (int s = 0; s < 64; s++) lru[s] = 1'b0;
        #1;
    endtask

    task automatic reset_counters;
        g_accesses = 0;
        g_hits     = 0;
        g_misses   = 0;
    endtask

    // emula al controlador: lookup; si miss, fill en la via LRU y reintenta
    task automatic access(input logic [31:0] a);
        logic [20:0] t;
        logic [5:0]  s;
        logic        chosen_way;
        addr = a;
        #1;
        g_accesses++;
        if (hit) begin
            g_hits++;
        end else begin
            g_misses++;
            t = a[31:11];
            s = a[10:5];
            chosen_way = lru[s];
            @(posedge clk);
            fill_en   <= 1'b1;
            fill_way  <= chosen_way;
            fill_set  <= s;
            fill_tag  <= t;
            fill_line <= synth_line({11'b0, t});
            @(posedge clk);
            fill_en   <= 1'b0;
            #1;
            lru[s] = !chosen_way;
            addr = a;
            #1;
        end
    endtask

    task automatic snapshot(input string label);
        rep_name[rep_n] = label;
        rep_acc[rep_n]  = g_accesses;
        rep_hit[rep_n]  = g_hits;
        rep_miss[rep_n] = g_misses;
        rep_n++;
        $display("[%0s] accesos=%0d hits=%0d misses=%0d hit_rate=%0d%%",
                 label, g_accesses, g_hits, g_misses,
                 (g_accesses == 0) ? 0 : (100*g_hits)/g_accesses);
    endtask

    initial begin
        $dumpfile("sim/waves/tb_l1d_cache.vcd");
        $dumpvars(0, tb_l1d_cache);

        addr      = 0;
        fill_en   = 0;
        fill_way  = 0;
        fill_set  = 0;
        fill_tag  = 0;
        fill_line = '0;
        inv_en    = 0;
        inv_way   = 0;
        inv_set   = 0;
        rep_n     = 0;

        // chequeo minimo de cableado
        clear_cache();
        reset_counters();
        addr = 32'h00000000; #1;
        if (hit) $error("cableado: hit espurio tras reset");
        else     $display("[sanity] cold miss ok");

        // -----------------------------------------------------------
        $display("\n=== BENCH 1: recorrido secuencial 256 palabras ===");
        $display("    espera: ~87%% hit (1 miss cada 8 palabras = linea de 32B)");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 256; i++) begin
            access(i * 4);
        end
        snapshot("seq_256");

        // -----------------------------------------------------------
        $display("\n=== BENCH 2: 4 pasadas sobre mismas 256 palabras ===");
        $display("    espera: pasada 1 ~87%%, pasadas 2-4 ~100%% (localidad temporal)");
        clear_cache();
        reset_counters();
        for (int p = 0; p < 4; p++) begin
            for (int i = 0; i < 256; i++) begin
                access(i * 4);
            end
        end
        snapshot("loop_x4");

        // -----------------------------------------------------------
        $display("\n=== BENCH 3: stride de 32B (una palabra por linea) ===");
        $display("    espera: ~0%% hit hasta llenar caché, luego sigue mal por capacidad");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 256; i++) begin
            access(i * 32);
        end
        snapshot("stride_32");

        // -----------------------------------------------------------
        $display("\n=== BENCH 4: conflicto 3 tags al mismo set, repetido ===");
        $display("    espera: thrashing, ~0%% hit (LRU bota lo que se va a usar)");
        clear_cache();
        reset_counters();
        for (int r = 0; r < 32; r++) begin
            access(32'h00000000);
            access(32'h00001000);
            access(32'h00002000);
        end
        snapshot("trash_3way");

        // -----------------------------------------------------------
        $display("\n=== BENCH 5: working set de 16 lineas, 16 pasadas ===");
        $display("    espera: misses solo en la primera pasada, luego ~100%% hit");
        clear_cache();
        reset_counters();
        for (int p = 0; p < 16; p++) begin
            for (int i = 0; i < 16*8; i++) begin
                access(i * 4);
            end
        end
        snapshot("warm_16ln");

        // -----------------------------------------------------------
        $display("\n=== BENCH 6: random sobre region que cabe en cache ===");
        $display("    espera: alto hit rate tras calentamiento");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 1024; i++) begin
            // 64 lineas = 2 KB, cabe en cache (4 KB)
            access(($random & 32'h000003FF) & ~32'h3);
        end
        snapshot("rand_fit");

        // -----------------------------------------------------------
        $display("\n=== BENCH 7: random sobre region 4x mas grande que cache ===");
        $display("    espera: bajo hit rate, dominan misses de capacidad/conflicto");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 1024; i++) begin
            access(($random & 32'h00003FFF) & ~32'h3);
        end
        snapshot("rand_big");

        // -----------------------------------------------------------
        $display("\n\n=================  RESUMEN  =================");
        $display("benchmark        accesos    hits   misses  hit%%   AMAT (hit=1, penal=8)");
        for (int k = 0; k < rep_n; k++) begin
            int hr_x100;
            real amat;
            hr_x100 = (rep_acc[k] == 0) ? 0 : (100*rep_hit[k])/rep_acc[k];
            amat = 1.0 + (real'(rep_miss[k]) / real'(rep_acc[k])) * 8.0;
            $display("%-15s   %6d  %6d  %6d   %3d    %0.2f",
                     rep_name[k], rep_acc[k], rep_hit[k], rep_miss[k],
                     hr_x100, amat);
        end
        $display("=============================================");
        $finish;
    end

endmodule
