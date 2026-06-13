`timescale 1ns/1ps

module tb_l2_cache;

    logic clk;
    logic reset;
    logic [31:0] addr;
    logic [31:0] data_out;
    logic hit;
    logic fill_en;
    logic [1:0] fill_way;
    logic [6:0] fill_set;
    logic [19:0] fill_tag;
    logic [255:0] fill_line;

    logic inv_en;
    logic [1:0] inv_way;
    logic [6:0] inv_set;

    l2_cache dut (
        .clk(clk), 
        .reset(reset),
        .addr(addr), 
        .data_out(data_out), 
        .hit(hit), 
        .fill_en(fill_en), 
        .fill_way(fill_way), 
        .fill_set(fill_set),
        .fill_tag(fill_tag), 
        .fill_line(fill_line),
        .inv_en(inv_en), 
        .inv_way(inv_way), 
        .inv_set(inv_set)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // puntero por set 
    logic [1:0] lru [0:127];

    // contadores por benchmark
    int g_accesses;
    int g_hits;
    int g_misses;

    // tabla final
    string rep_name [0:6];
    int rep_acc [0:6];
    int rep_hit [0:6];
    int rep_miss [0:6];
    int rep_n;

    function automatic logic [255:0] synth_line(input logic [31:0] block_id);
        logic [255:0] l;
        l = '0;
        for (int i = 0; i < 8; i++)
            l[i*32 +: 32] = {block_id[23:0], i[7:0]};
        return l;
    endfunction

    task automatic clear_cache;
        reset = 1;
        @(posedge clk); @(posedge clk);
        reset = 0;
        for (int s = 0; s < 128; s++) lru[s] = 2'b0;
        #1;
    endtask

    task automatic reset_counters;
        g_accesses = 0;
        g_hits = 0;
        g_misses = 0;
    endtask

    // emula al controlador: lookup; si miss, fill en el way FIFO y reintenta
    task automatic access(input logic [31:0] a);
        logic [19:0] t;
        logic [6:0] s;
        logic [1:0] chosen_way;
        addr = a;
        #1;
        g_accesses++;
        if (hit) begin
            g_hits++;
            // FIFO: el puntero no se actualiza en hits
        end else begin
            g_misses++;
            t = a[31:12];
            s = a[11:5];
            chosen_way = lru[s];
            @(posedge clk);
            fill_en  <= 1'b1;
            fill_way <= chosen_way;
            fill_set <= s;
            fill_tag <= t;
            fill_line <= synth_line({12'b0, t});
            @(posedge clk);
            fill_en  <= 1'b0;
            #1;
            lru[s] = lru[s] + 2'b1;  // avanza al siguiente way (wrap 0-3)
            addr = a;
            #1;
        end
    endtask

    task automatic snapshot(input string label);
        rep_name[rep_n] = label;
        rep_acc[rep_n] = g_accesses;
        rep_hit[rep_n] = g_hits;
        rep_miss[rep_n] = g_misses;
        rep_n++;
        $display("[%0s] accesos=%0d hits=%0d misses=%0d hit_rate=%0d%%",
                 label, g_accesses, g_hits, g_misses,
                 (g_accesses == 0) ? 0 : (100*g_hits)/g_accesses);
    endtask

    initial begin
        $dumpfile("sim/waves/tb_l2_cache.vcd");
        $dumpvars(0, tb_l2_cache);

        addr = 0;
        fill_en  = 0;
        fill_way = 0;
        fill_set = 0;
        fill_tag = 0;
        fill_line = '0;
        inv_en  = 0;
        inv_way = 0;
        inv_set = 0;
        rep_n  = 0;

        // chequeo minimo de cableado
        clear_cache();
        reset_counters();
        addr = 32'h00000000; #1;
        if (hit) $error("cableado: hit espurio tras reset");
        else  $display("[sanity] cold miss ok");

        // =====================================================
        $display("\n=== BENCH 1: recorrido secuencial 1024 palabras ===");
        $display("    espera: ~87%% hit (1 miss cada 8 palabras = linea de 32B)");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 1024; i++) begin
            access(i * 4);
        end
        snapshot("seq_1024");

        // =====================================================
        $display("\n=== BENCH 2: 4 pasadas sobre mismas 1024 palabras ===");
        $display("    espera: pasada 1 ~87%%, pasadas 2-4 ~100%% (localidad temporal)");
        clear_cache();
        reset_counters();
        for (int p = 0; p < 4; p++) begin
            for (int i = 0; i < 1024; i++) begin
                access(i * 4);
            end
        end
        snapshot("loop_x4");

        // =====================================================
        $display("\n=== BENCH 3: stride de 32B (una palabra por linea) ===");
        $display("    espera: ~0%% hit, cada acceso cae en linea diferente");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 1024; i++) begin
            access(i * 32);
        end
        snapshot("stride_32");

        // =====================================================
        $display("\n=== BENCH 4: conflicto 5 tags al mismo set, repetido ===");
        $display("    espera: thrashing, ~0%% hit (FIFO bota lo que se va a usar, 4-way)");
        // set=0: addr[11:5]=0 -> addr en multiplos de 0x1000 (bit 12+)
        clear_cache();
        reset_counters();
        for (int r = 0; r < 32; r++) begin
            access(32'h00000000);  // tag=0, set=0
            access(32'h00001000);  // tag=1, set=0
            access(32'h00002000);  // tag=2, set=0
            access(32'h00003000);  // tag=3, set=0
            access(32'h00004000);  // tag=4, set=0 -> thrashing
        end
        snapshot("trash_5way");

        // =====================================================
        $display("\n=== BENCH 5: working set de 64 lineas, 16 pasadas ===");
        $display("    espera: misses solo en la primera pasada, luego ~100%% hit");
        clear_cache();
        reset_counters();
        for (int p = 0; p < 16; p++) begin
            for (int i = 0; i < 64*8; i++) begin
                access(i * 4);
            end
        end
        snapshot("warm_64ln");

        // =====================================================
        $display("\n=== BENCH 6: random sobre region que cabe en L2 ===");
        $display("    espera: alto hit rate tras calentamiento (region ~16KB)");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 1024; i++) begin
            // 16 KB = 0x3FFF, alineado a palabra
            access(($random & 32'h00003FFF) & ~32'h3);
        end
        snapshot("rand_fit");

        // =====================================================
        $display("\n=== BENCH 7: random sobre region 4x mas grande que L2 ===");
        $display("    espera: bajo hit rate, dominan misses de capacidad/conflicto");
        clear_cache();
        reset_counters();
        for (int i = 0; i < 1024; i++) begin
            // 64 KB = 0xFFFF, alineado a palabra
            access(($random & 32'h0000FFFF) & ~32'h3);
        end
        snapshot("rand_big");

        // =====================================================
        $display("\n\n=================  RESUMEN  =================");
        $display("benchmark        accesos    hits   misses  hit%%   AMAT (hit=8, penal=33)");
        for (int k = 0; k < rep_n; k++) begin
            int hr_x100;
            real amat;
            hr_x100 = (rep_acc[k] == 0) ? 0 : (100*rep_hit[k])/rep_acc[k];
            amat = 8.0 + (real'(rep_miss[k]) / real'(rep_acc[k])) * 33.0;
            $display("%-15s   %6d  %6d  %6d   %3d    %0.2f",
                     rep_name[k], rep_acc[k], rep_hit[k], rep_miss[k],
                     hr_x100, amat);
        end
        $display("=============================================");
        $finish;
    end

endmodule
