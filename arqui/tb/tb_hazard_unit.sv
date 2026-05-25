`timescale 1ns/1ps

module tb_hazard_unit;

    // ── Entradas ─────────────────────────────────────────────
    logic [4:0] rs1DE, rs1EX;
    logic [4:0] rs2DE, rs2EX;
    logic [4:0] rdEX, rdMEM, rdWB;
    logic       result_src_0, pc_src_exOUT;
    logic       we_reg_mem, we_reg_wb;
    logic stall_mem;

    // ── Salidas ──────────────────────────────────────────────
    logic [1:0] forwardA, forwardB;
    logic       stallIF, stallD;
    logic       flushD, flushE;
    logic       stallE, stallM, stallW;

    // ── DUT ──────────────────────────────────────────────────
    hazard_unit dut(
        .rs1DE(rs1DE),
        .rs1EX(rs1EX),
        .rs2DE(rs2DE), 
        .rs2EX(rs2EX),
        .rdEX(rdEX),
        .rdMEM(rdMEM), 
        .rdWB(rdWB),
        .result_src_0(result_src_0), 
        .pc_src_exOUT(pc_src_exOUT), 
        .we_reg_mem(we_reg_mem), 
        .we_reg_wb(we_reg_wb),
        .stall_mem(stall_mem),

        .forwardA(forwardA),
        .forwardB(forwardB),
        .stallIF(stallIF),
        .stallD(stallD),
        .flushD(flushD),
        .flushE(flushE),
        .stallE(stallE),
        .stallM(stallM),
        .stallW(stallW)
    );

    // ── Task de verificación ─────────────────────────────────
    task check(
        input string        test_name,
        input logic [1:0]   exp_fwdA, exp_fwdB,
        input logic         exp_stallIF, exp_stallD,
        input logic         exp_flushD,  exp_flushE
    );
        #1; // dejar propagar combinacional
        if (forwardA  !== exp_fwdA   ||
            forwardB  !== exp_fwdB   ||
            stallIF   !== exp_stallIF||
            stallD   !== exp_stallD||
            flushD    !== exp_flushD ||
            flushE    !== exp_flushE)
        begin
            $display("FAIL [%s]", test_name);
            $display("  fwdA:   got %b  exp %b", forwardA,  exp_fwdA);
            $display("  fwdB:   got %b  exp %b", forwardB,  exp_fwdB);
            $display("  stallIF got %b  exp %b", stallIF,   exp_stallIF);
            $display("  stallDE got %b  exp %b", stallD,   exp_stallD);
            $display("  flushD: got %b  exp %b", flushD,    exp_flushD);
            $display("  flushE: got %b  exp %b", flushE,    exp_flushE);
        end else
            $display("PASS [%s]", test_name);
    endtask

    // ── Estímulos ────────────────────────────────────────────
    initial begin
        // valores seguros por defecto
        rs1DE=0; rs1EX=0; rs2DE=0; rs2EX=0;
        rdEX=0;  rdMEM=0; rdWB=0;
        result_src_0=0; pc_src_exOUT=0;
        we_reg_mem=0;   we_reg_wb=0; stall_mem = 0;

        // ── TEST 1: sin hazard ────────────────────────────────
        // Todos los registros distintos, sin writes activos
        rs1EX=5'd1; rs2EX=5'd2;
        rdMEM=5'd5; rdWB=5'd6;
        we_reg_mem=1; we_reg_wb=1; 
        check("Sin hazard", 2'b00, 2'b00, 0, 0, 0, 0);

        // ── TEST 2: forward MEM→EX en rs1 ────────────────────
        // add x7, x5, x3   (EX)
        // add x8, x7, x2   (MEM acaba de producir x7)
        rs1EX=5'd7; rs2EX=5'd2;
        rdMEM=5'd7; rdWB=5'd0;
        we_reg_mem=1; we_reg_wb=0;
        check("Forward MEM->EX rs1", 2'b10, 2'b00, 0, 0, 0, 0);

        // ── TEST 3: forward MEM→EX en rs2 ────────────────────
        rs1EX=5'd1; rs2EX=5'd7;
        rdMEM=5'd7; rdWB=5'd0;
        we_reg_mem=1; we_reg_wb=0;
        check("Forward MEM->EX rs2", 2'b00, 2'b10, 0, 0, 0, 0);

        // ── TEST 4: forward WB→EX en rs1 ─────────────────────
        rs1EX=5'd3; rs2EX=5'd9;
        rdMEM=5'd5; rdWB=5'd3;
        we_reg_mem=1; we_reg_wb=1;
        check("Forward WB->EX rs1", 2'b01, 2'b00, 0, 0, 0, 0);

        // ── TEST 5: forward WB→EX en rs2 ─────────────────────
        rs1EX=5'd9; rs2EX=5'd3;
        rdMEM=5'd5; rdWB=5'd3;
        we_reg_mem=1; we_reg_wb=1;
        check("Forward WB->EX rs2", 2'b00, 2'b01, 0, 0, 0, 0);

        // ── TEST 6: MEM tiene prioridad sobre WB ─────────────
        // Mismo registro en MEM y WB → debe ganar MEM (2'b10)
        rs1EX=5'd4; rs2EX=5'd4;
        rdMEM=5'd4; rdWB=5'd4;
        we_reg_mem=1; we_reg_wb=1;
        check("MEM prioridad sobre WB", 2'b10, 2'b10, 0, 0, 0, 0);

        // ── TEST 7: forward desactivado si we_reg=0 ──────────
        rs1EX=5'd4; rs2EX=5'd4;
        rdMEM=5'd4; rdWB=5'd4;
        we_reg_mem=0; we_reg_wb=0;
        check("Forward desactivado (we=0)", 2'b00, 2'b00, 0, 0, 0, 0);

        // ── TEST 8: no forward a x0 ───────────────────────────
        rs1EX=5'd0; rs2EX=5'd0;
        rdMEM=5'd0; rdWB=5'd0;
        we_reg_mem=1; we_reg_wb=1;
        check("No forward a x0", 2'b00, 2'b00, 0, 0, 0, 0);

        // ── TEST 9: load-use hazard en rs1 ────────────────────
        // lw x5, 0(x1)  → EX
        // add x7, x5, x3 → DE  (rs1DE = x5)
        rs1DE=5'd5; rs2DE=5'd3;
        rdEX=5'd5; result_src_0=1;
        rs1EX=5'd0; rs2EX=5'd0; // EX no necesita forward aquí
        rdMEM=5'd0; rdWB=5'd0;
        we_reg_mem=0; we_reg_wb=0;
        pc_src_exOUT=0;
        check("Load-use hazard rs1", 2'b00, 2'b00, 1, 1, 0, 1);

        // ── TEST 10: load-use hazard en rs2 ───────────────────
        rs1DE=5'd3; rs2DE=5'd5;
        rdEX=5'd5; result_src_0=1;
        check("Load-use hazard rs2", 2'b00, 2'b00, 1, 1, 0, 1);

        // ── TEST 11: load pero rdEX==x0 (no stall) ────────────
        rs1DE=5'd0; rs2DE=5'd0;
        rdEX=5'd0; result_src_0=1;
        check("Load rdEX=x0 no stall", 2'b00, 2'b00, 0, 0, 0, 0);

        // ── TEST 12: branch tomado (flush) ────────────────────
        result_src_0=0; pc_src_exOUT=1;
        rdEX=5'd0;
        check("Branch flush", 2'b00, 2'b00, 0, 0, 1, 1);

        // ── TEST 13: load-use + branch simultáneo ─────────────
        rs1DE=5'd5; rs2DE=5'd3;
        rdEX=5'd5; result_src_0=1;
        pc_src_exOUT=1;
        check("Load-use + branch", 2'b00, 2'b00, 1, 1, 1, 1);


        //  TEST 14: stall_mem bloquea pipeline ─────────────
        stall_mem = 1;

        rs1DE=5'd1; rs2DE=5'd2;
        rs1EX=5'd3; rs2EX=5'd4;
        rdEX=5'd5; rdMEM=5'd6; rdWB=5'd7;
        we_reg_mem=1; we_reg_wb=1;
        result_src_0=0;
        pc_src_exOUT=0;

        #1;
        check("stall_mem -> stallIF", 2'b00, 2'b00, 1, 1, 0, 0);

        // chequeo de E/M/W directo
        if (stallE !== 1'b1 || stallM !== 1'b1 || stallW !== 1'b1)
            $display("FAIL stall_mem outputs E/M/W");
        else
            $display("PASS stall_mem outputs E/M/W");

        // liberar stall
        stall_mem = 0;

        #1;
        check("stall_mem liberado", 2'b00, 2'b00, 0, 0, 0, 0);
        $display("\nSimulacion completa.");
        $finish;
    end

endmodule