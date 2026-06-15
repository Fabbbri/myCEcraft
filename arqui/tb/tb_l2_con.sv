// ============================================================
//  tb_l2_con.sv  —  Testbench unitario para l2_con.sv
//
//  Usa los modulos reales: request_queue, write_buffer y set_reg.
//
//  Escenarios:
//    S1  – Load HIT L2: stall 8 ciclos, dato_cpu correcto
//    S2  – Load MISS L2: stall hasta fill_en, miss_l2_out activo
//    S3  – Store MISS: no-write-allocate; rq_push=0, fill_en=0
//    S4  – Store HIT: WB_COMMIT activo, store_en=1, wb_commit_out=1
//    S5  – Orden RAW: WB no vacío bloquea FSM load en IDLE
//    S6  – wb_full genera stall para store
//    S7  – Stall sostenido durante ACCESS
//    S8  – WB_DRAIN bloqueado mientras load en ACCESS
//    S9  – mem_busy retiene WB_DRAIN; COMMIT sale al liberar
//    S10 – fill_en pulsa tras el posedge que captura burst_counter==7
//    S11 – wb_commit_out: pulso de 1 ciclo por WB_COMMIT
//    S12 – inv_en pulsa solo en IDLE→ACCESS con miss; no en HIT
//
//  Compilar:
//    make -C arqui run TOP=tb_l2_con
// ============================================================
`timescale 1ns/1ps

// ============================================================
//  TESTBENCH PRINCIPAL
// ============================================================
module tb_l2_con;

// -------------------------------------------------------
// DUT ports
// -------------------------------------------------------
logic        clk, reset;
logic        mem_busy;
logic        is_write, miss_l1, hit_l1;
logic [31:0] addr;
logic [1:0]  size;
logic [31:0] wdata;
logic [2:0]  burst_counter;
logic        burst_active;
logic [255:0] fill_line;
logic        hit_l2;
logic [31:0] l2_data_out;
logic        hit_l2_wb;

logic         fill_en;
logic [1:0]   fill_way_out;
logic [6:0]   fill_set;
logic [19:0]  fill_tag;
logic [255:0] fill_line_out;
logic        inv_en;
logic [1:0]  inv_way;
logic [6:0]  inv_set;
logic        store_en;
logic [31:0] store_addr_out;
logic [31:0] store_data_out;
logic [31:0] dato_cpu;
logic        stall;
logic        miss_l2_out;
logic [31:0] addr_out;
logic [1:0]  size_out;
logic        wb_write_out;
logic [31:0] wb_addr_out;
logic [31:0] wb_data_out;
logic [1:0]  wb_size_out;
logic        wb_commit_out;

// Variables auxiliares de test (scope de módulo, compatible iverilog)
integer cyc_cnt;
logic   inv_seen;
logic   commit_seen;

// -------------------------------------------------------
// DUT
// -------------------------------------------------------
l2_con DUT (.*);

// -------------------------------------------------------
// Clock
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
// Reset + defaults
// -------------------------------------------------------
task do_reset;
    begin
        is_write = 0; miss_l1 = 0; hit_l1 = 0;
        addr = '0; size = 2'b10; wdata = '0;
        burst_counter = '0; burst_active = 0;
        fill_line = '0;
        hit_l2 = 0; l2_data_out = '0; hit_l2_wb = 0;
        mem_busy = 0;
        reset = 1;
        repeat(3) @(posedge clk); #1;
        reset = 0;
        @(negedge clk);
    end
endtask

// -------------------------------------------------------
// Burst completo (8 palabras).
// El task vuelve en el negedge posterior a capturar counter==7: fill_en sigue
// alto hasta el siguiente posedge, de modo que el caller puede comprobar el
// pulso sin saltarselo.
// -------------------------------------------------------
task do_burst;
    integer bi;
    begin
        burst_active = 1;
        for (bi = 0; bi < 8; bi = bi + 1) begin
            @(negedge clk);
            burst_counter = bi[2:0];
            @(posedge clk); #1;
        end
        @(negedge clk);
        burst_active  = 0;
        burst_counter = '0;
    end
endtask

// -------------------------------------------------------
// Esperar entrada a ACCESS (timeout 30 ciclos)
// -------------------------------------------------------
task wait_for_access;
    integer wc;
    begin
        wc = 0;
        while (DUT.load_state !== 2'b01 && wc < 30) begin
            @(posedge clk); #1;
            wc = wc + 1;
        end
        if (wc >= 30)
            $display("  WARN  wait_for_access: timeout");
    end
endtask

// -------------------------------------------------------
// Esperar WB_COMMIT (timeout 40 ciclos)
// -------------------------------------------------------
task wait_for_wb_commit;
    integer wc;
    begin
        wc = 0;
        while (!wb_commit_out && wc < 40) begin
            @(posedge clk); #1;
            wc = wc + 1;
        end
    end
endtask

// ============================================================
// S1 – Load HIT: stall 8 ciclos, dato_cpu correcto
// ============================================================
task test_s1_load_hit;
    begin
        $display("\n--- S1: Load HIT en L2 ---");
        do_reset();

        addr        = 32'hDEAD_0100;
        size        = 2'b10;
        is_write    = 0;
        miss_l1     = 1;
        hit_l2      = 1;
        l2_data_out = 32'hCAFE_F00D;

        wait_for_access();
        chk("S1 stall durante ACCESS",   stall,       1'b1);
        chk("S1 miss_l2_out=0 (hit)",    miss_l2_out, 1'b0);

        // Esperar los 8 ciclos de ACCESS
        repeat(7) @(posedge clk); #1;
        @(posedge clk); #1;

        chk("S1 stall bajo en DONE",     stall,    1'b0);
        chk32("S1 dato_cpu correcto",    dato_cpu, 32'hCAFE_F00D);

        miss_l1 = 0;
        repeat(3) @(posedge clk); #1;
    end
endtask

// ============================================================
// S2 – Load MISS: espera fill_en
// ============================================================
task test_s2_load_miss;
    begin
        $display("\n--- S2: Load MISS en L2 ---");
        do_reset();

        addr     = 32'hBEEF_0200;
        size     = 2'b10;
        is_write = 0;
        miss_l1  = 1;
        hit_l2   = 0;

        wait_for_access();
        chk("S2 stall durante ACCESS",  stall,       1'b1);
        chk("S2 miss_l2_out=1",         miss_l2_out, 1'b1);

        do_burst();
        chk("S2 fill_en activo tras burst", fill_en, 1'b1);

        @(posedge clk); #1;
        chk("S2 stall bajo post-fill", stall, 1'b0);

        miss_l1 = 0;
        repeat(3) @(posedge clk); #1;
    end
endtask

// ============================================================
// S3 – Store MISS: no-write-allocate
// ============================================================
task test_s3_store_miss;
    begin
        $display("\n--- S3: Store MISS - no-write-allocate ---");
        do_reset();

        addr      = 32'h1234_5678;
        wdata     = 32'hABCD_EF01;
        size      = 2'b10;
        is_write  = 1;
        miss_l1   = 1;
        hit_l2    = 0;
        hit_l2_wb = 0;

        @(posedge clk); #1;
        chk("S3 rq_push=0 (store)",  DUT.rq_push,   1'b0);
        chk("S3 fill_en=0",          fill_en,        1'b0);
        chk("S3 miss_l2_out=0",      miss_l2_out,    1'b0);

        miss_l1 = 0; is_write = 0;
        repeat(15) @(posedge clk); #1;
    end
endtask

// ============================================================
// S4 – Store HIT: WB_COMMIT, store_en, wb_commit_out
// ============================================================
task test_s4_store_hit;
    begin
        $display("\n--- S4: Store HIT - WB_COMMIT ---");
        do_reset();

        addr      = 32'hAAAA_0004;
        wdata     = 32'h1234_5678;
        size      = 2'b10;
        is_write  = 1;
        miss_l1   = 1;
        hit_l2_wb = 1;

        @(posedge clk); #1;
        miss_l1 = 0; is_write = 0;

        wait_for_wb_commit();
        chk("S4 wb_write_out en COMMIT",   wb_write_out,  1'b1);
        chk("S4 store_en hacia L2",        store_en,      1'b1);
        chk("S4 wb_commit_out=1 (PMU)",    wb_commit_out, 1'b1);
        chk32("S4 wb_data_out correcto",   wb_data_out,   32'h1234_5678);

        @(posedge clk); #1;
        chk("S4 wb_commit_out=0 post-COMMIT", wb_commit_out, 1'b0);
        chk("S4 store_en=0 post-COMMIT",      store_en,      1'b0);

        repeat(2) @(posedge clk); #1;
    end
endtask

// ============================================================
// S5 – Orden RAW: WB no vacío bloquea FSM load en IDLE
// ============================================================
task test_s5_raw_order;
    begin
        $display("\n--- S5: RAW order - WB no vacio bloquea load ---");
        do_reset();

        // Store entra al WB
        addr = 32'hCCCC_0008; wdata = 32'hDEAD_BEEF;
        is_write = 1; miss_l1 = 1; hit_l2_wb = 0;
        @(posedge clk); #1;
        miss_l1 = 0; is_write = 0;

        // Load inmediato — WB aún no vacío
        @(negedge clk);
        addr = 32'hCCCC_0008; miss_l1 = 1; is_write = 0; hit_l2 = 0;
        @(posedge clk); #1;

        chk("S5 FSM load en IDLE mientras WB pendiente",
            (DUT.load_state == 2'b00), 1'b1);

        miss_l1 = 0;
        repeat(15) @(posedge clk); #1;
    end
endtask

// ============================================================
// S6 – wb_full genera stall para store
// ============================================================
task test_s6_wb_full;
    integer fi;
    begin
        $display("\n--- S6: wb_full -> stall para store ---");
        do_reset();

        // Llenar WB con 8 stores a addr distintas
        for (fi = 0; fi < 8; fi = fi + 1) begin
            @(negedge clk);
            addr     = 32'h1000_0000 + (fi << 2);
            wdata    = 32'hDEAD_0000 + fi;
            is_write = 1; miss_l1 = 1;
            @(posedge clk); #1;
            miss_l1 = 0; is_write = 0;
            @(posedge clk); #1;
        end

        // Store adicional con WB lleno
        @(negedge clk);
        addr = 32'h2000_0000; wdata = 32'hFFFF_FFFF;
        is_write = 1; miss_l1 = 1;
        @(posedge clk); #1;
        chk("S6 stall por wb_full", stall, 1'b1);

        miss_l1 = 0; is_write = 0;
        repeat(25) @(posedge clk); #1;
    end
endtask

// ============================================================
// S7 – Stall sostenido durante ACCESS
// ============================================================
task test_s7_stall_during_access;
    begin
        $display("\n--- S7: Stall sostenido durante ACCESS ---");
        do_reset();

        addr = 32'h5555_0000; miss_l1 = 1; is_write = 0; hit_l2 = 1;

        wait_for_access();
        chk("S7 stall ciclo 0 ACCESS",  stall, 1'b1);

        repeat(4) @(posedge clk); #1;
        chk("S7 stall ciclo 4 ACCESS",  stall, 1'b1);

        repeat(5) @(posedge clk); #1;
        chk("S7 stall bajo tras DONE",  stall, 1'b0);

        miss_l1 = 0;
        repeat(3) @(posedge clk); #1;
    end
endtask

// ============================================================
// S8 – WB_DRAIN bloqueado mientras load en ACCESS
// ============================================================
task test_s8_wb_blocked_during_access;
    begin
        $display("\n--- S8: WB_DRAIN bloqueado durante ACCESS ---");
        do_reset();

        // Store en WB
        @(negedge clk);
        addr = 32'hBBBB_000C; wdata = 32'h1111_2222;
        is_write = 1; miss_l1 = 1; hit_l2_wb = 0;
        @(posedge clk); #1;
        miss_l1 = 0; is_write = 0;
        @(posedge clk); #1;

        // Load que esperará a que WB drene antes de entrar a ACCESS
        @(negedge clk);
        addr = 32'hAAAA_0010; is_write = 0; miss_l1 = 1; hit_l2 = 0;
        repeat(2) @(posedge clk); #1;

        // Verificar: si ya está en ACCESS, WB no puede estar en DRAIN
        if (DUT.load_state == 2'b01) begin
            chk("S8 WB no en DRAIN durante ACCESS",
                (DUT.wb_state != 2'b01), 1'b1);
        end else begin
            $display("  INFO  S8: load aun en IDLE (WB drenando primero) - correcto");
            pass_cnt = pass_cnt + 1;
        end

        miss_l1 = 0;
        repeat(20) @(posedge clk); #1;
    end
endtask

// ============================================================
// S9 – mem_busy retiene WB_DRAIN; COMMIT al liberar
// ============================================================
task test_s9_mem_busy;
    begin
        $display("\n--- S9: mem_busy retrasa WB_COMMIT ---");
        do_reset();

        addr = 32'h9999_0020; wdata = 32'hFEED_FACE;
        is_write = 1; miss_l1 = 1; hit_l2_wb = 0;
        @(posedge clk); #1;
        miss_l1 = 0; is_write = 0;

        // Esperar a que WB_DRAIN esté cerca de wb_cnt==6
        repeat(7) @(posedge clk); #1;

        // Activar mem_busy
        @(negedge clk);
        mem_busy = 1;
        @(posedge clk); #1;
        chk("S9 WB_DRAIN retenido con mem_busy",
            (DUT.wb_state == 2'b01), 1'b1);

        // Liberar
        @(negedge clk);
        mem_busy = 0;
        wait_for_wb_commit();
        chk("S9 wb_write_out tras liberar", wb_write_out,  1'b1);
        chk("S9 wb_commit_out=1 (PMU)",     wb_commit_out, 1'b1);

        repeat(3) @(posedge clk); #1;
    end
endtask

// ============================================================
// S10 – fill_en: registrado a partir de burst_counter==7
// ============================================================
task test_s10_fill_en_delay;
    integer bi;
    begin
        $display("\n--- S10: fill_en registrado al final del burst ---");
        do_reset();

        addr = 32'h7777_0030; is_write = 0; miss_l1 = 1; hit_l2 = 0;
        wait_for_access();

        burst_active = 1;
        for (bi = 0; bi < 7; bi = bi + 1) begin
            @(negedge clk); burst_counter = bi[2:0];
            @(posedge clk); #1;
            chk("S10 fill_en=0 durante burst", fill_en, 1'b0);
        end

        // El RTL registra burst_last_d en este posedge. Tras las NBA,
        // fill_en ya refleja el pulso, que l2_cache consumira en el siguiente
        // posedge con la linea completa de refill_regs.
        @(negedge clk); burst_counter = 3'b111;
        @(posedge clk); #1;
        chk("S10 fill_en=1 tras capturar counter==7", fill_en, 1'b1);

        // Al retirar burst_active, burst_last_d se limpia en el siguiente
        // posedge y fill_en vuelve a cero.
        @(negedge clk);
        burst_active = 0; burst_counter = '0;
        @(posedge clk); #1;
        chk("S10 fill_en=0 tras pulso", fill_en, 1'b0);

        miss_l1 = 0;
        repeat(3) @(posedge clk); #1;
    end
endtask

// ============================================================
// S11 – wb_commit_out: pulso de 1 ciclo por store
// ============================================================
task test_s11_wb_commit_pmu;
    integer si;
    begin
        $display("\n--- S11: wb_commit_out PMU ---");
        do_reset();

        // Dos stores en WB
        for (si = 0; si < 2; si = si + 1) begin
            @(negedge clk);
            addr     = 32'hEEEE_0000 + (si << 2);
            wdata    = 32'hF0F0_0000 + si;
            is_write = 1; miss_l1 = 1; hit_l2_wb = 0;
            @(posedge clk); #1;
            miss_l1 = 0; is_write = 0;
            @(posedge clk); #1;
        end

        // Primer COMMIT
        wait_for_wb_commit();
        chk("S11 wb_commit_out pulso store#0", wb_commit_out, 1'b1);

        @(posedge clk); #1;
        chk("S11 wb_commit_out=0 tras COMMIT#0", wb_commit_out, 1'b0);

        // Segundo COMMIT
        wait_for_wb_commit();
        chk("S11 wb_commit_out pulso store#1", wb_commit_out, 1'b1);

        @(posedge clk); #1;
        chk("S11 wb_commit_out=0 tras COMMIT#1", wb_commit_out, 1'b0);

        repeat(3) @(posedge clk); #1;
    end
endtask

// ============================================================
// S12 – inv_en: pulsa en IDLE→ACCESS con miss; nunca en HIT
// ============================================================
task test_s12_inv_en_pulse;
    integer wi;
    begin
        $display("\n--- S12: inv_en IDLE->ACCESS con miss ---");
        do_reset();

        // MISS: inv_en debe pulsar en la transición
        addr = 32'h3333_0040; is_write = 0; miss_l1 = 1; hit_l2 = 0;

        inv_seen = 0;
        for (wi = 0; wi < 6; wi = wi + 1) begin
            @(posedge clk); #1;
            if (inv_en) inv_seen = 1;
        end
        chk("S12 inv_en pulsado en IDLE->ACCESS con miss", inv_seen, 1'b1);

        // Una vez en ACCESS, inv_en no sigue activo
        if (DUT.load_state == 2'b01)
            chk("S12 inv_en=0 dentro de ACCESS", inv_en, 1'b0);

        miss_l1 = 0;
        // Salir de ACCESS con burst si es miss
        do_burst();
        repeat(3) @(posedge clk); #1;

        // HIT: inv_en nunca debe pulsar
        do_reset();
        addr = 32'h4444_0050; is_write = 0; miss_l1 = 1; hit_l2 = 1;

        inv_seen = 0;
        for (wi = 0; wi < 12; wi = wi + 1) begin
            @(posedge clk); #1;
            if (inv_en) inv_seen = 1;
        end
        chk("S12 inv_en=0 en load HIT (nunca pulsa)", inv_seen, 1'b0);

        miss_l1 = 0;
        repeat(3) @(posedge clk); #1;
    end
endtask

// ============================================================
// MAIN
// ============================================================
initial begin
    $dumpfile("tb_l2_con.vcd");
    $dumpvars(0, tb_l2_con);

    test_s1_load_hit();
    test_s2_load_miss();
    test_s3_store_miss();
    test_s4_store_hit();
    test_s5_raw_order();
    test_s6_wb_full();
    test_s7_stall_during_access();
    test_s8_wb_blocked_during_access();
    test_s9_mem_busy();
    test_s10_fill_en_delay();
    test_s11_wb_commit_pmu();
    test_s12_inv_en_pulse();

    $display("\n========================================");
    $display("  RESULTADOS: %0d PASS  /  %0d FAIL", pass_cnt, fail_cnt);
    $display("========================================");
    if (fail_cnt == 0) begin
        $display("ALL TESTS PASSED");
        $finish;
    end else begin
        $fatal(1, "SOME TESTS FAILED");
    end
end

initial begin #500000; $fatal(1, "TIMEOUT"); end

endmodule
