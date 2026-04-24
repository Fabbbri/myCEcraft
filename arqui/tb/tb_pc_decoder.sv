`timescale 1ns/1ps

module tb_pc_decoder;

    // ─── Señales ───────────────────────────────────────────────────────────────
    logic [8:0] pcDEC;
    logic pc_enable;

    // ─── Contadores de pruebas ─────────────────────────────────────────────────
    int tests_passed = 0;
    int tests_failed = 0;

    // ─── Instancia DUT ────────────────────────────────────────────────────────
    pc_decoder dut (
        .pcDEC(pcDEC),
        .pc_enable(pc_enable)

    );

    // ─── Tarea de verificación ─────────────────────────────────────────────────
    task automatic check(
        input string   test_name,
        input [31:0]   exp_result

    );
        #1; // pequeño delay para que se propague
        if (pc_enable === exp_result) begin
            $display("  [PASS] %s", test_name);
            tests_passed++;
        end else begin
            $display("  [FAIL] %s", test_name);
            if (pc_enable !== exp_result)
                $display("         result  : got %0d (0x%08h), esperado %0d (0x%08h)",
                         $signed(pc_enable), pc_enable,
                         $signed(exp_result), exp_result);
            tests_failed++;
        end
    endtask

    // ─── Estímulos ─────────────────────────────────────────────────────────────
    initial begin
        $display("============================================================");
        $display("               PC_DECODER TESTBENCH");
        $display("============================================================");

        // Inicio de tests
        $display("\n[Inicio de tests]");

        // FREEZE 
        pcDEC = 9'b01100_0000;
        check("FREEZE",          1'd0);

        // not FREEZE  
        pcDEC = 9'b10100_0000;
        check("NOT FREEZE", 1'd1);


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