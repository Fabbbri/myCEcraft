`timescale 1ns/1ps

module tb_tea;

    parameter int MAX_CYCLES = 200000;
    parameter int ROM_DEPTH  = 2048;
    parameter int RAM_DEPTH  = 65536;

    localparam ROM_HEX   = "programs/tea.hex";
    localparam VAULT_HEX = "programs/neather.hex";
    localparam DATA_HEX  = "programs/tea_data.hex";

    localparam int KEY_BASE       = 16'h8000;
    localparam int PLAIN_BASE     = 16'h8010;
    localparam int CIPHER_BASE    = 16'h8018;
    localparam int ROUNDTRIP_BASE = 16'h8020;
    localparam int DELTA_ADDR     = 16'h8028;
    localparam int SUM_INIT_ADDR  = 16'h802C;

    logic clk   = 0;
    logic reset = 0;
    int tests_passed = 0;
    int tests_failed = 0;

    top dut (.clk(clk), .reset(reset));
    defparam dut.Issue.ROM.DEPTH = ROM_DEPTH;

    always #5 clk = ~clk;

    `define REGS  dut.Decode.RegBank.regs
    `define VREGS dut.Decode.RegVBank.regs
    `define PC    dut.Issue.addr_aux
    `define ROM   dut.Issue.ROM.memory
    `define NRAM  dut.mem.VaultRam.mem
    `define DRAM  dut.mem.NormalRam.mem

    task automatic apply_reset();
        reset = 1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        reset = 0;
    endtask

    task automatic wait_for_finish(output bit timed_out);
        int cycles;
        timed_out = 0;
        cycles    = 0;

        forever begin
            @(posedge clk);
            cycles++;

            if (dut.Issue.pc_en === 1'b0) begin
                $display("[INFO]  FREEZE detectado en PC=%h (ciclo %0d)",
                          `PC, cycles);
                repeat (5) @(posedge clk);
                return;
            end

            if (cycles >= MAX_CYCLES) begin
                $display("[ERROR] Timeout tras %0d ciclos - ultimo PC: %h",
                          MAX_CYCLES, `PC);
                timed_out = 1;
                return;
            end
        end
    endtask

    task automatic check_reg(
        input int          idx,
        input logic [31:0] expected,
        input string       name
    );
        logic [31:0] got;
        got = `REGS[idx];
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] %-12s (x%02d) = %h", name, idx, got);
        end else begin
            tests_failed++;
            $display("  [FAIL] %-12s (x%02d) esperado=%h obtenido=%h",
                      name, idx, expected, got);
        end
    endtask

    task automatic check_dram_word(
        input int          offset,
        input logic [31:0] expected,
        input string       label
    );
        logic [31:0] got;
        got = {`DRAM[offset+3], `DRAM[offset+2],
               `DRAM[offset+1], `DRAM[offset]};
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] DRAM[%04h] = %h  (%s)", offset, got, label);
        end else begin
            tests_failed++;
            $display("  [FAIL] DRAM[%04h] esperado=%h obtenido=%h  (%s)",
                      offset, expected, got, label);
        end
    endtask

    task automatic check_nram_word(
        input int          offset,
        input logic [31:0] expected,
        input string       label
    );
        logic [31:0] got;
        got = {`NRAM[offset+3], `NRAM[offset+2],
               `NRAM[offset+1], `NRAM[offset]};
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] NRAM[%04h] = %h  (%s)", offset, got, label);
        end else begin
            tests_failed++;
            $display("  [FAIL] NRAM[%04h] esperado=%h obtenido=%h  (%s)",
                      offset, expected, got, label);
        end
    endtask

    task automatic dump_nonzero_regs();
        $display("\n  --- Banco de registros no cero ---");
        for (int i = 0; i < 32; i++) begin
            if (`REGS[i] !== 32'h0) begin
                $display("    x%02d = %h", i, `REGS[i]);
            end
        end
        $display("  ----------------------------------");
    endtask

    task automatic load_and_reset();
        #1;

        for (int i = 0; i < ROM_DEPTH; i++) begin
            `ROM[i] = 32'h00580000;
        end

        for (int i = 0; i < 32; i++) begin
            `REGS[i] = 32'h0;
            `VREGS[i] = 32'h0;
        end

        dut.Decode.SM.sm = 1'b0;

        for (int i = 0; i < RAM_DEPTH; i++) begin
            `NRAM[i] = 8'h00;
            `DRAM[i] = 8'h00;
        end

        $readmemh(ROM_HEX, `ROM);
        $readmemh(VAULT_HEX, `NRAM);
        $readmemh(DATA_HEX, `DRAM);

        $display("[LOAD]  ROM   : %s", ROM_HEX);
        $display("[LOAD]  VAULT : %s", VAULT_HEX);
        $display("[LOAD]  DATA  : %s", DATA_HEX);

        apply_reset();

        @(negedge clk);
        dut.Decode.SM.sm = 1'b0;
    endtask

    initial begin
        bit timed_out;

        $dumpfile("sim/waves/tb_tea.vcd");
        $dumpvars(0, tb_tea);

        $display("============================================================");
        $display("         CRAFT21 TEA PROGRAM TESTBENCH");
        $display("============================================================");

        $display("\n============================================================");
        $display("  TEST: compi/ejemplos/tea.craft encrypt/decrypt roundtrip");
        $display("============================================================");

        load_and_reset();
        wait_for_finish(timed_out);

        if (timed_out) begin
            tests_failed++;
            $display("[ERROR] Test abortado por timeout");
            dump_nonzero_regs();
        end else begin
            $display("\n  --- Registros clave ---");
            check_reg(11, 32'h00000000, "return");
            check_reg( 2, 32'h00000000, "sp");
            check_reg( 0, 32'h00000000, "zero");

            $display("\n  --- Vault RAM ---");
            check_nram_word(16'h0000, 32'h00000000, "password bootstrap");

            $display("\n  --- Data RAM: estado inicial conservado ---");
            check_dram_word(KEY_BASE + 0, 32'h00000000, "key[0]");
            check_dram_word(KEY_BASE + 4, 32'h00000001, "key[1]");
            check_dram_word(KEY_BASE + 8, 32'h00000002, "key[2]");
            check_dram_word(KEY_BASE + 12, 32'h00000003, "key[3]");
            check_dram_word(PLAIN_BASE + 0, 32'h00000000, "plain[0]");
            check_dram_word(PLAIN_BASE + 4, 32'h00000000, "plain[1]");
            check_dram_word(DELTA_ADDR, 32'h9E3779B9, "DELTA");
            check_dram_word(SUM_INIT_ADDR, 32'hC6EF3720, "SUM_INIT");

            $display("\n  --- Data RAM: resultados TEA ---");
            check_dram_word(CIPHER_BASE + 0, 32'hFB0EED65, "cipher[0]");
            check_dram_word(CIPHER_BASE + 4, 32'h3892B421, "cipher[1]");
            check_dram_word(ROUNDTRIP_BASE + 0, 32'h00000000, "roundtrip[0]");
            check_dram_word(ROUNDTRIP_BASE + 4, 32'h00000000, "roundtrip[1]");
        end

        $display("\n============================================================");
        $display("  REPORTE FINAL");
        $display("============================================================");
        $display("  PASADOS : %0d", tests_passed);
        $display("  FALLIDOS: %0d", tests_failed);
        $display("  Total   : %0d", tests_passed + tests_failed);

        if (tests_failed == 0) begin
            $display("  RESULTADO: ** ALL TESTS PASSED **");
        end else begin
            $display("  RESULTADO: ** %0d FALLO(S) **", tests_failed);
        end

        $display("============================================================\n");
        $finish;
    end

    `undef REGS
    `undef VREGS
    `undef PC
    `undef ROM
    `undef NRAM
    `undef DRAM

endmodule
