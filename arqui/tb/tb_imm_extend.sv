`timescale 1ns/1ps

module tb_imm_extend;

    logic [21:0] imm;
    logic [1:0]  imm_src;
    logic [31:0] imm_extended;

    // DUT
    imm_extend dut (
        .imm(imm),
        .imm_src(imm_src),
        .imm_extended(imm_extended)
    );

    // Task para imprimir bonito
    task check(string name);
        $display("---- %s ----", name);
        $display("imm        = %b", imm);
        $display("imm_ext    = %0d (0x%h)", imm_extended, imm_extended);
        $display("");
    endtask

    initial begin

        // =========================
        // 🔹 SW (no shift)
        // =========================
        imm_src = 2'b00;

        // Caso positivo
        imm = 22'b0;
        imm[20:13] = 8'b00000001; // = 1
        imm[3:0]   = 4'b0001;     // +1 → total = 17
        #1;
        check("SW positivo (esperado ~17)");

        // Caso negativo
        imm = 22'b0;
        imm[21] = 1'b1; // signo negativo
        imm[20:13] = 8'b11111111;
        imm[3:0]   = 4'b1111;
        #1;
        check("SW negativo");

        // =========================
        // 🔹 LW (no shift)
        // =========================
        imm_src = 2'b01;

        imm = 22'b0;
        imm[20:13] = 8'b00000001;
        imm[11:8]  = 4'b0010; // → valor pequeño
        #1;
        check("LW positivo");

        // =========================
        // 🔹 JUMP (<<2)
        // =========================
        imm_src = 2'b10;

        // Queremos que el inmediato reconstruido sea 1
        imm = 22'b0;
        imm[20:13] = 8'b00000000;
        imm[11:8]  = 4'b0000;
        imm[7:4]   = 4'b0001; // = 1
        #1;
        check("JUMP: 1 -> esperado 4");

        // Caso: valor 2 → esperado 8
        imm[7:4] = 4'b0010;
        #1;
        check("JUMP: 2 -> esperado 8");

        // =========================
        // 🔹 BRANCH (<<2)
        // =========================
        imm_src = 2'b11;

        // inmediato = 1 → esperado 4
        imm = 22'b0;
        imm[20:13] = 8'b00000000;
        imm[3:0]   = 4'b0001;
        #1;
        check("BRANCH: 1 -> esperado 4");

        // inmediato = 3 → esperado 12
        imm[3:0] = 4'b0011;
        #1;
        check("BRANCH: 3 -> esperado 12");

        // Caso negativo (salto hacia atrás)
        imm = 22'b0;
        imm[21] = 1'b1;
        imm[20:13] = 8'b11111111;
        imm[3:0]   = 4'b1100;
        #1;
        check("BRANCH negativo");

        $finish;
    end

endmodule