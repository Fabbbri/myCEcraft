`timescale 1ns/1ps

module tb_control_unit;

    // ─── Señales ───────────────────────────────────────────────────────────────
    logic [3:0] opcode;
    logic [3:0] func23;
    logic       func19;
    logic [1:0] func15;

    logic [4:0] alu_control;
    logic       we_reg, size;
    logic       imm_src2;
    logic [1:0] imm_src;
    logic       we_mem;
    logic       beq, bne, blt, bge, jump;
    logic       w_regv, w_memv;
    logic [1:0] result_src, alu_src;
    logic       neather_portal, neather_reset, neather_wreg_src;

    // ─── Contadores ───────────────────────────────────────────────────────────
    int tests_passed = 0;
    int tests_failed = 0;

    // ─── Instancia DUT ────────────────────────────────────────────────────────
    control_unit dut (
        .opcode           (opcode),
        .func23           (func23),
        .func19           (func19),
        .func15           (func15),
        .alu_control      (alu_control),
        .we_reg           (we_reg),
        .size             (size),
        .imm_src2         (imm_src2),
        .imm_src          (imm_src),
        .we_mem           (we_mem),
        .beq              (beq),
        .bne              (bne),
        .blt              (blt),
        .bge              (bge),
        .jump             (jump),
        .w_regv           (w_regv),
        .w_memv           (w_memv),
        .result_src       (result_src),
        .alu_src          (alu_src),
        .neather_portal   (neather_portal),
        .neather_reset    (neather_reset),
        .neather_wreg_src (neather_wreg_src)
    );

    // ─── Tarea de verificación ─────────────────────────────────────────────────
    task automatic check(
        input string  test_name,
        // señales esperadas
        input [4:0]  exp_alu_control,
        input        exp_we_reg,
        input        exp_size,
        input        exp_imm_src2,
        input [1:0]  exp_imm_src,
        input        exp_we_mem,
        input        exp_beq,
        input        exp_bne,
        input        exp_blt,
        input        exp_bge,
        input        exp_jump,
        input        exp_w_regv,
        input        exp_w_memv,
        input [1:0]  exp_result_src,
        input [1:0]  exp_alu_src,
        input        exp_neather_portal,
        input        exp_neather_reset,
        input        exp_neather_wreg_src
    );
        #1;
        if (alu_control       === exp_alu_control      &&
            we_reg            === exp_we_reg           &&
            size              === exp_size             &&
            imm_src2          === exp_imm_src2         &&
            imm_src           === exp_imm_src          &&
            we_mem            === exp_we_mem           &&
            beq               === exp_beq              &&
            bne               === exp_bne              &&
            blt               === exp_blt              &&
            bge               === exp_bge              &&
            jump              === exp_jump             &&
            w_regv            === exp_w_regv           &&
            w_memv            === exp_w_memv           &&
            result_src        === exp_result_src       &&
            alu_src           === exp_alu_src          &&
            neather_portal    === exp_neather_portal   &&
            neather_reset     === exp_neather_reset    &&
            neather_wreg_src  === exp_neather_wreg_src) begin
            $display("  [PASS] %s", test_name);
            tests_passed++;
        end else begin
            $display("  [FAIL] %s", test_name);
            if (alu_control      !== exp_alu_control)      $display("         alu_control      : got %05b, esperado %05b", alu_control,      exp_alu_control);
            if (we_reg           !== exp_we_reg)           $display("         we_reg           : got %b,     esperado %b",     we_reg,           exp_we_reg);
            if (size             !== exp_size)             $display("         size             : got %b,     esperado %b",     size,             exp_size);
            if (imm_src2         !== exp_imm_src2)         $display("         imm_src2         : got %b,     esperado %b",     imm_src2,         exp_imm_src2);
            if (imm_src          !== exp_imm_src)          $display("         imm_src          : got %02b,    esperado %02b",   imm_src,          exp_imm_src);
            if (we_mem           !== exp_we_mem)           $display("         we_mem           : got %b,     esperado %b",     we_mem,           exp_we_mem);
            if (beq              !== exp_beq)              $display("         beq              : got %b,     esperado %b",     beq,              exp_beq);
            if (bne              !== exp_bne)              $display("         bne              : got %b,     esperado %b",     bne,              exp_bne);
            if (blt              !== exp_blt)              $display("         blt              : got %b,     esperado %b",     blt,              exp_blt);
            if (bge              !== exp_bge)              $display("         bge              : got %b,     esperado %b",     bge,              exp_bge);
            if (jump             !== exp_jump)             $display("         jump             : got %b,     esperado %b",     jump,             exp_jump);
            if (w_regv           !== exp_w_regv)           $display("         w_regv           : got %b,     esperado %b",     w_regv,           exp_w_regv);
            if (w_memv           !== exp_w_memv)           $display("         w_memv           : got %b,     esperado %b",     w_memv,           exp_w_memv);
            if (result_src       !== exp_result_src)       $display("         result_src       : got %02b,    esperado %02b",   result_src,       exp_result_src);
            if (alu_src          !== exp_alu_src)          $display("         alu_src          : got %02b,    esperado %02b",   alu_src,          exp_alu_src);
            if (neather_portal   !== exp_neather_portal)   $display("         neather_portal   : got %b,     esperado %b",     neather_portal,   exp_neather_portal);
            if (neather_reset    !== exp_neather_reset)    $display("         neather_reset    : got %b,     esperado %b",     neather_reset,    exp_neather_reset);
            if (neather_wreg_src !== exp_neather_wreg_src) $display("         neather_wreg_src : got %b,     esperado %b",     neather_wreg_src, exp_neather_wreg_src);
            tests_failed++;
        end
    endtask

    // ─── Estímulos ─────────────────────────────────────────────────────────────
    // check(nombre,
    //       alu_ctrl, we_reg, size, imm_src2, imm_src,
    //       we_mem, beq, bne, blt, bge, jump,
    //       w_regv, w_memv, result_src, alu_src,
    //       n_portal, n_reset, n_wreg_src)

    initial begin
        $dumpfile("sim/waves/tb_control_unit.vcd");
        $dumpvars(0, tb_control_unit);

        $display("============================================================");
        $display("          CONTROL UNIT TESTBENCH");
        $display("============================================================");

        // ── TypeR (0000) ──────────────────────────────────────────────────────
        $display("\n[TypeR - opcode 0000]");

        // ADD: func23=0000, func19=0 → alu_control=00000
        opcode=4'b0000; func23=4'b0000; func19=0; func15=2'b00;
        check("TypeR ADD",
              5'b00000, 1, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // SUB: func23=0001, func19=0 → alu_control=00010... depende de tu encoding
        opcode=4'b0000; func23=4'b0001; func19=1; func15=2'b00;
        check("TypeR func23=0001 func19=1",
              5'b00011, 1, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // FREEZE: func23=0101, func19=1 → we_reg=0
        opcode=4'b0000; func23=4'b0101; func19=1; func15=2'b00;
        check("TypeR FREEZE (we_reg=0)",
              5'b01011, 0, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // SLEEP: func23=0110, func19=0 → we_reg=0
        opcode=4'b0000; func23=4'b0110; func19=0; func15=2'b00;
        check("TypeR SLEEP (we_reg=0)",
              5'b01100, 0, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // ── TypeI (0001) ──────────────────────────────────────────────────────
        $display("\n[TypeI - opcode 0001]");

        // addi: func15=00 → imm_src2=1, imm_src=10
        opcode=4'b0001; func23=4'b0000; func19=0; func15=2'b00;
        check("TypeI addi (func15=00)",
              5'b00000, 1, 1, 1, 2'b10,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b11,
              0, 0, 0);

        // addiHIGH: func15=01 → imm_src2=0, imm_src=11
        opcode=4'b0001; func23=4'b0000; func19=0; func15=2'b01;
        check("TypeI addiHIGH (func15=01)",
              5'b00000, 1, 1, 0, 2'b11,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b11,
              0, 0, 0);

        // ── Type SW/LW (0010) ─────────────────────────────────────────────────
        $display("\n[Type SW/LW - opcode 0010]");

        // SW: func19=0 → we_reg=0, we_mem=1, imm_src2=0, imm_src=01
        opcode=4'b0010; func23=4'b0000; func19=0; func15=2'b00;
        check("SW (func19=0)",
              5'b00000, 0, 1, 0, 2'b01,
              1, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b11,
              0, 0, 0);

        // LW: func19=1 → we_reg=1, we_mem=0, imm_src2=1, imm_src=00, result_src=01
        opcode=4'b0010; func23=4'b0000; func19=1; func15=2'b00;
        check("LW (func19=1)",
              5'b00000, 1, 1, 1, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b01, 2'b11,
              0, 0, 0);

        // ── Type SB/LB (0011) ─────────────────────────────────────────────────
        $display("\n[Type SB/LB - opcode 0011]");

        // SB: func19=0
        opcode=4'b0011; func23=4'b0000; func19=0; func15=2'b00;
        check("SB (func19=0)",
              5'b00000, 0, 0, 0, 2'b01,
              1, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b11,
              0, 0, 0);

        // LB: func19=1
        opcode=4'b0011; func23=4'b0000; func19=1; func15=2'b00;
        check("LB (func19=1)",
              5'b00000, 1, 0, 1, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b01, 2'b11,
              0, 0, 0);

        // ── Type J (0100) ─────────────────────────────────────────────────────
        $display("\n[Type J - opcode 0100]");

        // JAL: func19=0 → we_reg=1, jump=1, result_src=10, imm_src2=0, imm_src=00
        opcode=4'b0100; func23=4'b0000; func19=0; func15=2'b00;
        check("JAL (func19=0)",
              5'b00000, 1, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 1,
              0, 0, 2'b10, 2'b11,
              0, 0, 0);

        // JALR: func19=1 → we_reg=0, jump=1, result_src=00, imm_src2=1, imm_src=01
        opcode=4'b0100; func23=4'b0000; func19=1; func15=2'b00;
        check("JALR (func19=1)",
              5'b00000, 0, 1, 1, 2'b01,
              0, 0, 0, 0, 0, 1,
              0, 0, 2'b00, 2'b11,
              0, 0, 0);

        // ── Type B (0110) ─────────────────────────────────────────────────────
        $display("\n[Type B/Logv - opcode 0110]");

        // BEQ: func23=0000, func19=0
        opcode=4'b0110; func23=4'b0000; func19=0; func15=2'b00;
        check("BEQ",
              5'b00001, 0, 1, 0, 2'b10,
              0, 1, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // BNE: func23=0000, func19=1
        opcode=4'b0110; func23=4'b0000; func19=1; func15=2'b00;
        check("BNE",
              5'b00001, 0, 1, 0, 2'b10,
              0, 0, 1, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // BLT: func23=0001, func19=0
        opcode=4'b0110; func23=4'b0001; func19=0; func15=2'b00;
        check("BLT",
              5'b00001, 0, 1, 0, 2'b10,
              0, 0, 0, 1, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // BGE: func23=0001, func19=1
        opcode=4'b0110; func23=4'b0001; func19=1; func15=2'b00;
        check("BGE",
              5'b00001, 0, 1, 0, 2'b10,
              0, 0, 0, 0, 1, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

        // LOGVB / neather_portal: func23=0010, func19=0
        opcode=4'b0110; func23=4'b0010; func19=0; func15=2'b00;
        check("LOGVB / neather_portal",
              5'b00001, 0, 1, 0, 2'b10,
              0, 0, 1, 0, 0, 0,
              0, 0, 2'b00, 2'b10,
              1, 0, 0);

        // ── Type RVault (1010) ────────────────────────────────────────────────
        $display("\n[Type RVault - opcode 1010]");

        opcode=4'b1010; func23=4'b0011; func19=1; func15=2'b00;
        check("RVault func23=0011 func19=1",
              5'b00111, 1, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b11, 2'b01,
              0, 0, 0);

        // ── Change V (1011) ───────────────────────────────────────────────────
        $display("\n[Change V - opcode 1011]");

        opcode=4'b1011; func23=4'b0000; func19=0; func15=2'b00;
        check("Change V",
              5'b00000, 0, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              1, 0, 2'b00, 2'b00,
              0, 0, 0);

        // ── Close V (1100) ────────────────────────────────────────────────────
        $display("\n[Close V - opcode 1100]");

        opcode=4'b1100; func23=4'b0000; func19=0; func15=2'b00;
        check("Close V / neather_reset",
              5'b00000, 0, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 1, 0);

        // ── Type SWV/LWV (1110) ───────────────────────────────────────────────
        $display("\n[Type SWV/LWV - opcode 1110]");

        // SWV: func19=0
        opcode=4'b1110; func23=4'b0000; func19=0; func15=2'b00;
        check("SWV (func19=0)",
              5'b00000, 0, 1, 0, 2'b01,
              0, 0, 0, 0, 0, 0,
              0, 1, 2'b00, 2'b11,
              0, 0, 0);

        // LWV: func19=1
        opcode=4'b1110; func23=4'b0000; func19=1; func15=2'b00;
        check("LWV (func19=1)",
              5'b00000, 0, 1, 1, 2'b00,
              0, 0, 0, 0, 0, 0,
              1, 0, 2'b00, 2'b11,
              0, 0, 1);

        // ── Type Imm V (1111) ─────────────────────────────────────────────────
        $display("\n[Type Imm V - opcode 1111]");

        // addiLOWv: func15=00
        opcode=4'b1111; func23=4'b0000; func19=0; func15=2'b00;
        check("addiLOWv (func15=00)",
              5'b00000, 0, 1, 1, 2'b00,
              0, 0, 0, 0, 0, 0,
              1, 0, 2'b00, 2'b11,
              0, 0, 0);

        // addiHIGHv: func15=01
        opcode=4'b1111; func23=4'b0000; func19=0; func15=2'b01;
        check("addiHIGHv (func15=01)",
              5'b00000, 0, 1, 0, 2'b11,
              0, 0, 0, 0, 0, 0,
              1, 0, 2'b00, 2'b11,
              0, 0, 0);

        // ── Opcode no usado → defaults ─────────────────────────────────────────
        $display("\n[Opcode no usado]");

        opcode=4'b0101; func23=4'b0000; func19=0; func15=2'b00;
        check("opcode 0101 (no usado) → defaults",
              5'b00000, 0, 1, 0, 2'b00,
              0, 0, 0, 0, 0, 0,
              0, 0, 2'b00, 2'b00,
              0, 0, 0);

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
