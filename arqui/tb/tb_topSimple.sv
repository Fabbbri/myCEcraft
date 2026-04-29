`timescale 1ns/1ps

module tb_topSimple;

    parameter int          MAX_CYCLES = 5000;
    parameter logic [31:0] HALT_PC    = 32'h00000110;

    logic clk   = 0;
    logic reset = 0;
    int tests_passed = 0;
    int tests_failed = 0;

    top dut (.clk(clk), .reset(reset));

    always #5 clk = ~clk;

    `define REGS  dut.Decode.RegBank.regs
    `define PC    dut.Issue.addr_aux

    task automatic apply_reset();
        reset = 1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        reset = 0;
        $display("[RESET] Reset liberado en t=%0t ns", $time);
    endtask

    // =========================================================
    //  Task: Esperar fin — con debug inline por ciclo
    // =========================================================
    task automatic wait_for_finish(output bit timed_out);
        int cycles;
        timed_out = 0;
        cycles    = 0;

        forever begin
            @(posedge clk);
            cycles++;

            // ── DEBUG: muestra solo las iteraciones del loop ──
            // Ciclos 250-350: primera iteración del loop
            // Ciclos 1700+:   últimas iteraciones antes del halt
            if ((cycles >= 250 && cycles <= 350) ||
                (cycles >= 1700)) begin
                $display("c=%0d PC=%h | EX: rd1=%h rd2=%h bge=%b pc_src=%b | WB: rd=%0d wd=%h we=%b | x3=%h x4=%h x17=%h",
                    cycles,
                    `PC,
                    dut.rd1EX, dut.rd2EX,
                    dut.bgeEX, dut.pc_srcEX,
                    dut.instrDWB, dut.wdWB, dut.we_regWB,
                    `REGS[3], `REGS[4], `REGS[17]);
            end

            if (`PC === HALT_PC) begin
                $display("[INFO]  HALT en PC=%h  (ciclo %0d)", `PC, cycles);
                return;
            end

            if (cycles >= MAX_CYCLES) begin
                $display("[ERROR] Timeout tras %0d ciclos — último PC: %h",
                          MAX_CYCLES, `PC);
                timed_out = 1;
                return;
            end
        end
    endtask

    task automatic check_reg(input int idx, input logic [31:0] expected, input string name);
        logic [31:0] got;
        got = `REGS[idx];
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] %-4s (x%02d) = %h", name, idx, got);
        end else begin
            tests_failed++;
            $display("  [FAIL] %-4s (x%02d)  esperado=%h  obtenido=%h", name, idx, expected, got);
        end
    endtask

    task automatic dump_regs();
        $display("\n  --- Banco de registros ---");
        for (int i = 0; i < 32; i++)
            if (`REGS[i] !== 32'h0)
                $display("    x%02d = %h", i, `REGS[i]);
        $display("  --------------------------");
    endtask

    task automatic run_test(string test_name);
        bit timed_out;

        $display("\n============================================================");
        $display("  TEST: %s", test_name);
        $display("============================================================");

        apply_reset();
        wait_for_finish(timed_out);

        if (timed_out) begin
            $display("[ERROR] Test abortado — dump de registros:");
            dump_regs();
            tests_failed++;
            return;
        end

        repeat (4) @(posedge clk);

        $display("\n  --- Registros clave ---");
        check_reg(11, 32'h00000005, "x11");
        check_reg( 3, 32'h00000005, "x3");
        check_reg( 5, 32'h00000005, "x5");
        check_reg( 2, 32'h00000000, "x2");
        check_reg( 0, 32'h00000000, "x0");
    endtask

    initial begin
        $display("============================================================");
        $display("         CRAFT21 ARCHITECTURE TESTBENCH");
        $display("============================================================");

        $dumpfile("sim/waves/tb_top.vcd");
        $dumpvars(0, tb_top);

        run_test("while loop x<5, return x=5");

        $display("\n============================================================");
        $display("  REPORTE FINAL");
        $display("============================================================");
        $display("  PASADOS : %0d", tests_passed);
        $display("  FALLIDOS: %0d", tests_failed);
        $display("  Total   : %0d", tests_passed + tests_failed);

        if (tests_failed == 0)
            $display("  RESULTADO: ** ALL TESTS PASSED **");
        else
            $display("  RESULTADO: ** %0d FALLO(S) **", tests_failed);

        $display("============================================================\n");
        $finish;
    end

    `undef REGS
    `undef PC

endmodule