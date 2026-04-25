`timescale 1ns/1ps

module tb_alu;

    // ─── Señales ───────────────────────────────────────────────────────────────
    logic [31:0] srcA, srcB;
    logic [4:0]  alu_control;
    logic [31:0] alu_result;
    logic        z_flag, n_flag, v_flag;

    // ─── Contadores de pruebas ─────────────────────────────────────────────────
    int tests_passed = 0;
    int tests_failed = 0;

    // ─── Instancia DUT ────────────────────────────────────────────────────────
    alu dut (
        .srcA       (srcA),
        .srcB       (srcB),
        .alu_control(alu_control),
        .alu_result (alu_result),
        .z_flag     (z_flag),
        .n_flag     (n_flag),
        .v_flag     (v_flag)
    );

    // ─── Tarea de verificación ─────────────────────────────────────────────────
    task automatic check(
        input string   test_name,
        input [31:0]   exp_result,
        input logic    exp_z,
        input logic    exp_n,
        input logic    exp_v
    );
        #1; // pequeño delay para que se propague
        if (alu_result === exp_result &&
            z_flag    === exp_z      &&
            n_flag    === exp_n      &&
            v_flag    === exp_v) begin
            $display("  [PASS] %s", test_name);
            tests_passed++;
        end else begin
            $display("  [FAIL] %s", test_name);
            if (alu_result !== exp_result)
                $display("         result  : got %0d (0x%08h), esperado %0d (0x%08h)",
                         $signed(alu_result), alu_result,
                         $signed(exp_result), exp_result);
            if (z_flag !== exp_z)
                $display("         z_flag  : got %b, esperado %b", z_flag, exp_z);
            if (n_flag !== exp_n)
                $display("         n_flag  : got %b, esperado %b", n_flag, exp_n);
            if (v_flag !== exp_v)
                $display("         v_flag  : got %b, esperado %b", v_flag, exp_v);
            tests_failed++;
        end
    endtask

    // ─── Estímulos ─────────────────────────────────────────────────────────────
    initial begin
        $display("============================================================");
        $display("               ALU TESTBENCH");
        $display("============================================================");

        // ── 5'b00000  ADD ──────────────────────────────────────────────────────
        $display("\n[ADD - 5'b00000]");

        // 3 + 4 = 7
        srcA = 32'd3; srcB = 32'd4; alu_control = 5'b00000;
        check("3 + 4 = 7",          32'd7,          0, 0, 0);

        // 0 + 0 = 0  → z_flag
        srcA = 0; srcB = 0; alu_control = 5'b00000;
        check("0 + 0 = 0 (z_flag)", 32'd0,          1, 0, 0);

        // -1 + 1 = 0 → z_flag
        srcA = 32'hFFFF_FFFF; srcB = 32'd1; alu_control = 5'b00000;
        check("-1 + 1 = 0 (z_flag)", 32'd0,         1, 0, 0);

        // Overflow positivo: MAX_INT + 1 → resultado negativo, v_flag
        srcA = 32'h7FFF_FFFF; srcB = 32'd1; alu_control = 5'b00000;
        check("MAX_INT + 1 overflow (v_flag)", 32'h8000_0000, 0, 1, 1);

        // Overflow negativo: MIN_INT + (-1) → resultado positivo, v_flag
        srcA = 32'h8000_0000; srcB = 32'hFFFF_FFFF; alu_control = 5'b00000;
        check("MIN_INT + (-1) overflow (v_flag)", 32'h7FFF_FFFF, 0, 0, 1);

        // Resultado negativo: -5 + 2 = -3 → n_flag
        srcA = 32'hFFFF_FFFB; srcB = 32'd2; alu_control = 5'b00000;
        check("-5 + 2 = -3 (n_flag)", 32'hFFFF_FFFD, 0, 1, 0);

        // ── 5'b00001  SUB ──────────────────────────────────────────────────────
        $display("\n[SUB - 5'b00001]");

        // 7 - 3 = 4
        srcA = 32'd7; srcB = 32'd3; alu_control = 5'b00001;
        check("7 - 3 = 4",          32'd4,          0, 0, 0);

        // 5 - 5 = 0  → z_flag
        srcA = 32'd5; srcB = 32'd5; alu_control = 5'b00001;
        check("5 - 5 = 0 (z_flag)", 32'd0,          1, 0, 0);

        // 3 - 7 = -4 → n_flag
        srcA = 32'd3; srcB = 32'd7; alu_control = 5'b00001;
        check("3 - 7 = -4 (n_flag)", 32'hFFFF_FFFC, 0, 1, 0);

        // Overflow: MIN_INT - 1 → positivo, v_flag
        srcA = 32'h8000_0000; srcB = 32'd1; alu_control = 5'b00001;
        check("MIN_INT - 1 overflow (v_flag)", 32'h7FFF_FFFF, 0, 0, 1);

        // Overflow: MAX_INT - (-1) → negativo, v_flag
        srcA = 32'h7FFF_FFFF; srcB = 32'hFFFF_FFFF; alu_control = 5'b00001;
        check("MAX_INT - (-1) overflow (v_flag)", 32'h8000_0000, 0, 1, 1);

        // ── 5'b00010  SLL ──────────────────────────────────────────────────────
        $display("\n[SLL - 5'b00010]");

        srcA = 32'd1;  srcB = 32'd4; alu_control = 5'b00010;
        check("1 << 4 = 16",        32'd16,         0, 0, 0);

        srcA = 32'd1;  srcB = 32'd31; alu_control = 5'b00010;
        check("1 << 31 = MSB set",  32'h8000_0000,  0, 1, 0);

        srcA = 32'hFFFF_FFFF; srcB = 32'd1; alu_control = 5'b00010;
        check("0xFFFFFFFF << 1",    32'hFFFF_FFFE,  0, 1, 0);

        // ── 5'b00011  SLT ──────────────────────────────────────────────────────
        $display("\n[SLT - 5'b00011]");

        srcA = 32'd3;  srcB = 32'd5; alu_control = 5'b00011;
        check("3 < 5  → 1",         32'd1,          0, 0, 0);

        srcA = 32'd5;  srcB = 32'd3; alu_control = 5'b00011;
        check("5 < 3  → 0",         32'd0,          1, 0, 0);

        srcA = 32'd5;  srcB = 32'd5; alu_control = 5'b00011;
        check("5 < 5  → 0",         32'd0,          1, 0, 0);

        // -1 < 1 (signed) → 1
        srcA = 32'hFFFF_FFFF; srcB = 32'd1; alu_control = 5'b00011;
        check("-1 < 1 → 1",         32'd1,          0, 0, 0);

        // 1 < -1 (signed) → 0
        srcA = 32'd1; srcB = 32'hFFFF_FFFF; alu_control = 5'b00011;
        check("1 < -1 → 0",         32'd0,          1, 0, 0);

        // ── 5'b00100  XOR ──────────────────────────────────────────────────────
        $display("\n[XOR - 5'b00100]");

        srcA = 32'hAAAA_AAAA; srcB = 32'h5555_5555; alu_control = 5'b00100;
        check("0xAAAA ^ 0x5555 = 0xFFFF", 32'hFFFF_FFFF, 0, 1, 0);

        srcA = 32'hDEAD_BEEF; srcB = 32'hDEAD_BEEF; alu_control = 5'b00100;
        check("X ^ X = 0 (z_flag)", 32'd0,          1, 0, 0);

        // ── 5'b00101  SRL ──────────────────────────────────────────────────────
        $display("\n[SRL - 5'b00101]");

        srcA = 32'd16; srcB = 32'd4; alu_control = 5'b00101;
        check("16 >> 4 = 1",        32'd1,          0, 0, 0);

        srcA = 32'h8000_0000; srcB = 32'd1; alu_control = 5'b00101;
        check("MSB >> 1 lógico",    32'h4000_0000,  0, 0, 0);

        // ── 5'b00110  SRA ──────────────────────────────────────────────────────
        $display("\n[SRA - 5'b00110]");

        srcA = 32'h8000_0000; srcB = 32'd1; alu_control = 5'b00110;
        check("SRA: MSB >> 1 aritmético", 32'hC000_0000, 0, 1, 0);

        srcA = 32'd16; srcB = 32'd4; alu_control = 5'b00110;
        check("SRA: 16 >>> 4 = 1",  32'd1,          0, 0, 0);

        // ── 5'b00111  OR ───────────────────────────────────────────────────────
        $display("\n[OR - 5'b00111]");

        srcA = 32'hAAAA_AAAA; srcB = 32'h5555_5555; alu_control = 5'b00111;
        check("0xAAAA | 0x5555 = 0xFFFF", 32'hFFFF_FFFF, 0, 1, 0);

        srcA = 32'd0; srcB = 32'd0; alu_control = 5'b00111;
        check("0 | 0 = 0 (z_flag)", 32'd0,          1, 0, 0);

        // ── 5'b01000  AND ──────────────────────────────────────────────────────
        $display("\n[AND - 5'b01000]");

        srcA = 32'hFFFF_FFFF; srcB = 32'hAAAA_AAAA; alu_control = 5'b01000;
        check("0xFFFF & 0xAAAA",    32'hAAAA_AAAA,  0, 1, 0);

        srcA = 32'hAAAA_AAAA; srcB = 32'h5555_5555; alu_control = 5'b01000;
        check("0xAAAA & 0x5555 = 0 (z_flag)", 32'd0, 1, 0, 0);

        // ── 5'b01001  MUL ──────────────────────────────────────────────────────
        $display("\n[MUL - 5'b01001]");

        srcA = 32'd6; srcB = 32'd7; alu_control = 5'b01001;
        check("6 * 7 = 42",         32'd42,         0, 0, 0);

        srcA = 32'd0; srcB = 32'd999; alu_control = 5'b01001;
        check("0 * 999 = 0 (z_flag)", 32'd0,        1, 0, 0);

        srcA = 32'd100; srcB = 32'd100; alu_control = 5'b01001;
        check("100 * 100 = 10000",   32'd10000,     0, 0, 0);

        // ── 5'b01010  DIV ──────────────────────────────────────────────────────
        $display("\n[DIV - 5'b01010]");

        srcA = 32'd42; srcB = 32'd7; alu_control = 5'b01010;
        check("42 / 7 = 6",         32'd6,          0, 0, 0);

        srcA = 32'd10; srcB = 32'd3; alu_control = 5'b01010;
        check("10 / 3 = 3 (truncado)", 32'd3,       0, 0, 0);

        // División por cero → resultado 0
        srcA = 32'd99; srcB = 32'd0; alu_control = 5'b01010;
        check("99 / 0 = 0 (div-by-zero)", 32'd0,    1, 0, 0);

        srcA = 32'd0; srcB = 32'd5; alu_control = 5'b01010;
        check("0 / 5 = 0 (z_flag)", 32'd0,          1, 0, 0);

        // ── Control inválido → 32'b0 ───────────────────────────────────────────
        $display("\n[Control inválido]");

        srcA = 32'hDEAD; srcB = 32'hBEEF; alu_control = 5'b11111;
        check("control=11111 → 0", 32'd0,           1, 0, 0);

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