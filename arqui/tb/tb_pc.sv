`timescale 1ns/1ps

module tb_pc;

    // ─── Señales ───────────────────────────────────────────────────────────────
    logic clk;
    logic pc_enable;
    logic reset;
    logic [31:0] new_addr;
    logic [31:0] addr;

    // ─── Contadores de pruebas ─────────────────────────────────────────────────
    int tests_passed = 0;
    int tests_failed = 0;

    // ─── Instancia DUT ────────────────────────────────────────────────────────
    pc dut (
        .clk      (clk),
        .pc_enable(pc_enable),
        .reset    (reset),
        .new_addr (new_addr),
        .addr     (addr)
    );

    // ─── Tarea de verificación ─────────────────────────────────────────────────
    task automatic check(
        input string  test_name,
        input [31:0]  exp_result
    );
        if (addr === exp_result) begin
            $display("  [PASS] %s", test_name);
            tests_passed++;
        end else begin
            $display("  [FAIL] %s", test_name);
            $display("         result  : got %0d (0x%08h), esperado %0d (0x%08h)",
                     $signed(addr), addr,
                     $signed(exp_result), exp_result);
            tests_failed++;
        end
    endtask

    // ─── Helper: avanzar un ciclo y estabilizar ────────────────────────────────
    task automatic tick();
        #1;
        @(posedge clk);
        #1; // pequeño delay post-flanco para que se propague
    endtask

    // ─── Clock: periodo 10ns ───────────────────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ─── Estímulos ─────────────────────────────────────────────────────────────
    initial begin
        $display("============================================================");
        $display("               PC TESTBENCH");
        $display("============================================================");

        // Inicialización
        new_addr   = 32'd0;
        reset      = 1'b0;
        pc_enable  = 1'b0;

        // Reset inicial para llevar addr a 0 de forma limpia
        reset = 1'b1;
        tick();
        reset = 1'b0;

        // ── Caso 1: No reset, No pc_enable → addr no cambia (queda en 0) ───────
        $display("\n[Caso 1: No reset, No pc_enable]");
        new_addr  = 32'd4;
        reset     = 1'b0;
        pc_enable = 1'b0;
        tick();
        check("No reset, No pc_enable → addr se mantiene en 0", 32'd0);

        // ── Caso 2: SI reset, No pc_enable → addr vuelve a 0 ──────────────────
        $display("\n[Caso 2: SI reset, No pc_enable]");
        // Primero cargamos un valor en addr
        new_addr  = 32'd12;
        pc_enable = 1'b1;
        tick();
        pc_enable = 1'b0;
        // Ahora aplicamos reset
        new_addr  = 32'd16;
        reset     = 1'b1;
        pc_enable = 1'b0;
        tick();
        reset = 1'b0;
        check("SI reset, No pc_enable → addr = 0", 32'd0);

        // ── Caso 3: No reset, SI pc_enable → addr toma new_addr ───────────────
        $display("\n[Caso 3: No reset, SI pc_enable]");
        new_addr  = 32'd16;
        reset     = 1'b0;
        pc_enable = 1'b1;
        tick();
        pc_enable = 1'b0;
        check("No reset, SI pc_enable → addr = 16", 32'd16);

        // ── Caso 4: SI reset, SI pc_enable → reset tiene prioridad → addr = 0 ─
        $display("\n[Caso 4: SI reset, SI pc_enable]");
        new_addr  = 32'd16;
        reset     = 1'b1;
        pc_enable = 1'b1;
        tick();
        reset     = 1'b0;
        pc_enable = 1'b0;
        check("SI reset, SI pc_enable → reset gana, addr = 0", 32'd0);

        // ── Caso 5: Incremento secuencial (simulando PC+4) ────────────────────
        $display("\n[Caso 5: Incremento secuencial PC+4]");
        reset     = 1'b1; tick(); reset = 1'b0; // partir de 0
        pc_enable = 1'b1;
        new_addr  = 32'd4;  tick(); check("PC = 4",  32'd4);
        new_addr  = 32'd8;  tick(); check("PC = 8",  32'd8);
        new_addr  = 32'd12; tick(); check("PC = 12", 32'd12);
        new_addr  = 32'd16; tick(); check("PC = 16", 32'd16);
        pc_enable = 1'b0;

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