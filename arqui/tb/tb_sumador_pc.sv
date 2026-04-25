`timescale 1ns/1ps

module tb_sumador_pc;

    // ─── Señales ───────────────────────────────────────────────────────────────
    logic [31:0] addr;
    logic [31:0] pcplus4;

    // ─── Contadores de pruebas ─────────────────────────────────────────────────
    int tests_passed = 0;
    int tests_failed = 0;

    // ─── Instancia DUT ────────────────────────────────────────────────────────
    sumador_pc dut (
        .addr(addr),
        .pcplus4(pcplus4)

    );

    // ─── Tarea de verificación ─────────────────────────────────────────────────
    task automatic check(
        input string   test_name,
        input [31:0]   exp_result

    );
        #1; // pequeño delay para que se propague
        if (pcplus4 === exp_result) begin
            $display("  [PASS] %s", test_name);
            tests_passed++;
        end else begin
            $display("  [FAIL] %s", test_name);
            if (pcplus4 !== exp_result)
                $display("         result  : got %0d (0x%08h), esperado %0d (0x%08h)",
                         $signed(pcplus4), pcplus4,
                         $signed(exp_result), exp_result);
            tests_failed++;
        end
    endtask

    // ─── Estímulos ─────────────────────────────────────────────────────────────
    initial begin
        $display("============================================================");
        $display("               SUMADOR_PC TESTBENCH");
        $display("============================================================");

        // Inicio de tests
        $display("\n[Inicio de tests]");

        // 0 In = 4 Out 
        addr = 32'd0;
        check("0 + 4 = 4",          32'd4);

        // FFFFFC In = 0  
        addr = 32'hFFFF_FFFC;
        check("0xFFFFFC + 4 = 0 (overflow)", 32'd0);

        // ── Resumen ────────────────────────────────────────────────────────────
        $display("\n============================================================");
        $display("  Resultados: %0d PASADOS  /  %0d FALLIDOS  /  %0d TOTAL",
                 tests_passed, tests_failed, tests_passed + tests_failed);
        $display("============================================================\n");

        if (tests_failed == 0)
            $display("  *** TODAS LAS PRUEBAS PASARON ***\n");
        else
            $display("  *** REVISAR FALLOS ARRIBA ***\n");

        $finish;
    end

endmodule