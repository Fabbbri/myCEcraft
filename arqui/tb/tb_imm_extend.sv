`timescale 1ns/1ps

module tb_imm_extend;

    // ── DUT ────────────────────────────────────────────────────────────────
    logic [27:0] imm;
    logic  [1:0] imm_src;
    logic        we_reg;
    logic [31:0] imm_extended;

    imm_extend dut (
        .imm(imm), .imm_src(imm_src), .we_reg(we_reg),
        .imm_extended(imm_extended)
    );

    // ── contadores ─────────────────────────────────────────────────────────
    int pass_count = 0;
    int fail_count = 0;

    task automatic check(
        input string      name,
        input logic [31:0] got,
        input logic [31:0] expected
    );
        if (got === expected) begin
            $display("PASS  %-30s | 0x%08h", name, got);
            pass_count++;
        end else begin
            $display("FAIL  %-30s | got=0x%08h  expected=0x%08h", name, got, expected);
            fail_count++;
        end
    endtask

    // ── macro para limpiar imm antes de cada test ─────────────────────────
    // (se resetea explícitamente en cada caso para evitar bits residuales)

    initial begin
        $display("====================================================================");
        $display("  imm_extend testbench");
        $display("====================================================================");

        // ==================================================================
        // SW  (temp_signal=001  we_reg=0  imm_src=01)
        //
        // Bits codificados: reales [8:4]→imm[4:0]  [27:20]→imm[23:16]
        // Fórmula: {20{imm[23]}, imm[22:16], imm[4:0]}   20+7+5=32
        // Signo = imm[23] (bit real 27), los datos son imm[22:16] + imm[4:0]
        // ==================================================================
        we_reg=0; imm_src=2'b01;

        imm=28'h0000000; #1; check("SW zero",     imm_extended, 32'h00000000);
        // imm[22:16]=0b0000001  imm[4:0]=0b10101  signo=0
        // {20'h0, 7'b0000001, 5'b10101} = 0x00000035
        imm=28'h0010015; #1; check("SW pos",      imm_extended, 32'h00000035);
        // imm[23]=1  resto=0  → {20'hFFFFF, 7'h00, 5'h00} = 0xFFFFF000
        imm=28'h0800000; #1; check("SW neg base", imm_extended, 32'hFFFFF000);
        // imm[23]=1  imm[22:16]=7'h7F  imm[4:0]=5'h1F → 0xFFFFFFFF
        imm=28'h0FF001F; #1; check("SW neg full", imm_extended, 32'hFFFFFFFF);

        // ==================================================================
        // LW  (temp_signal=100  we_reg=1  imm_src=00)
        //
        // Bits codificados: reales [18:14]→imm[14:10]  [27:20]→imm[23:16]
        // Fórmula: {20{imm[23]}, imm[22:16], imm[14:10]}   20+7+5=32
        // Signo = imm[23] (bit real 27)
        // ==================================================================
        we_reg=1; imm_src=2'b00;

        imm=28'h0000000; #1; check("LW zero",     imm_extended, 32'h00000000);
        // imm[22:16]=7'b0000010  imm[14:10]=5'b00011  signo=0
        // {20'h0, 7'b0000010, 5'b00011} = 0x00000043
        imm=28'h0020C00; #1; check("LW pos",      imm_extended, 32'h00000043);
        // imm[23]=1  resto=0 → 0xFFFFF000
        imm=28'h0800000; #1; check("LW neg base", imm_extended, 32'hFFFFF000);
        // imm[23]=1  imm[22:16]=7'h7F  imm[14:10]=5'h1F → 0xFFFFFFFF
        imm=28'h0FF7C00; #1; check("LW neg full", imm_extended, 32'hFFFFFFFF);

        // ==================================================================
        // JAL  (temp_signal=000  we_reg=0  imm_src=00)
        //
        // Bits codificados: reales [13:9]→imm[9:5]  [18:14]→imm[14:10]
        //                          [27:20]→imm[23:16]  (gap en real 19=imm[15])
        // Fórmula: {12{imm[23]}, imm[23:16], imm[14:10], imm[9:5], 2'b00}
        //          12+8+5+5+2=32
        // Signo = imm[23] (bit real 27), imm[23] también es dato (offset bit 19)
        // Los 2'b00 finales = alineamiento 4B (offset bits [1:0] = 0)
        // ==================================================================
        we_reg=0; imm_src=2'b00;

        imm=28'h0000000; #1; check("JAL zero",     imm_extended, 32'h00000000);
        // imm[9:5]=5'b00001  resto=0 → offset bit[4]=1 → resultado=4
        imm=28'h0000020; #1; check("JAL +4",       imm_extended, 32'h00000004);
        // todos los bits de dato a 1, signo=0
        // imm[22:16]=7'h7F  imm[14:10]=5'h1F  imm[9:5]=5'h1F  imm[23]=0
        // {12'h000, 8'b01111111, 5'h1F, 5'h1F, 2'b00} = 0x0007FFFC
        imm=28'h07F7FE0; #1; check("JAL max pos",  imm_extended, 32'h0007FFFC);
        // imm[23]=1  resto datos=0 → 0xFFF80000
        imm=28'h0800000; #1; check("JAL neg base", imm_extended, 32'hFFF80000);
        // imm[23]=1  todos datos=1 → 0xFFFFFFFC
        imm=28'h0FF7FE0; #1; check("JAL neg full", imm_extended, 32'hFFFFFFFC);

        // ==================================================================
        // JALR  (temp_signal=101  we_reg=1  imm_src=01)
        //
        // Mismo encoding que JAL
        // ==================================================================
        we_reg=1; imm_src=2'b01;

        imm=28'h0000000; #1; check("JALR zero",     imm_extended, 32'h00000000);
        imm=28'h0000020; #1; check("JALR +4",        imm_extended, 32'h00000004);
        imm=28'h07F7FE0; #1; check("JALR max pos",   imm_extended, 32'h0007FFFC);
        imm=28'h0800000; #1; check("JALR neg base",  imm_extended, 32'hFFF80000);
        imm=28'h0FF7FE0; #1; check("JALR neg full",  imm_extended, 32'hFFFFFFFC);

        // ==================================================================
        // BRANCH  (temp_signal=010  we_reg=0  imm_src=10)
        //
        // Bits codificados: reales [8:4]→imm[4:0]  [31:24]→imm[27:20]
        // Fórmula: {17{imm[27]}, imm[27:20], imm[4:0], 2'b00}
        //          17+8+5+2=32
        // Signo = imm[27] (bit real 31), imm[27] también es dato (offset bit 14)
        // Los 2'b00 finales = alineamiento 4B
        // ==================================================================
        we_reg=0; imm_src=2'b10;

        imm=28'h0000000; #1; check("BRANCH zero",     imm_extended, 32'h00000000);
        // imm[4:0]=5'b00100 (solo bit2=1) → offset bit[4]=1 → resultado=0x10
        imm=28'h0000004; #1; check("BRANCH +16",      imm_extended, 32'h00000010);
        // imm[20]=1  imm[4:0]=5'b00100  signo=0
        // {17'h0, 8'b00000001, 5'b00100, 2'b00} = 0x00000090
        imm=28'h0100004; #1; check("BRANCH pos",      imm_extended, 32'h00000090);
        // imm[27]=1  resto=0 → {17{1}, 8'b10000000, 5'h0, 2'b00}
        // = 0xFFFFC000
        imm=28'h8000000; #1; check("BRANCH neg base", imm_extended, 32'hFFFFC000);
        // imm[27]=1  imm[26:20]=7'h7F  imm[4:0]=5'h1F → 0xFFFFFFFC
        imm=28'hFF0001F; #1; check("BRANCH neg full", imm_extended, 32'hFFFFFFFC);

        // ==================================================================
        // ADDI unsigned  (temp_signal=110  we_reg=1  imm_src=10)
        //
        // Bits codificados: reales [31:16]→imm[27:12]  (16 bits)
        // Fórmula: {16'b0, imm[27:12]}   16+16=32
        // Sin extensión de signo
        // ==================================================================
        we_reg=1; imm_src=2'b10;

        imm=28'h0000000; #1; check("ADDI_U zero",     imm_extended, 32'h00000000);
        // imm[27:12]=16'h0001 → 0x00000001
        imm=28'h0001000; #1; check("ADDI_U 1",        imm_extended, 32'h00000001);
        // imm[27:12]=16'hABCD → 0x0000ABCD
        imm=28'hABCD000; #1; check("ADDI_U 0xABCD",   imm_extended, 32'h0000ABCD);
        // bit alto=1 pero zero-extended → sigue positivo
        imm=28'h8000000; #1; check("ADDI_U high bit", imm_extended, 32'h00008000);

        // ==================================================================
        // ADDI signed  (temp_signal=111  we_reg=1  imm_src=11)
        //
        // Bits codificados: reales [31:16]→imm[27:12]  (16 bits)
        // Fórmula: {17{imm[27]}, imm[26:12]}   17+15=32
        // Signo = imm[27] (bit real 31)
        // ==================================================================
        we_reg=1; imm_src=2'b11;

        imm=28'h0000000; #1; check("ADDI_S zero",    imm_extended, 32'h00000000);
        // imm[26:12]=15'h0001  signo=0 → 0x00000001
        imm=28'h0001000; #1; check("ADDI_S +1",      imm_extended, 32'h00000001);
        // imm[26:12]=15'h7FFF  signo=0 → 0x00007FFF
        imm=28'h7FFF000; #1; check("ADDI_S max pos", imm_extended, 32'h00007FFF);
        // imm[27]=1  imm[26:12]=15'h7FFF → {17{1}, 15'h7FFF} = 0xFFFFFFFF
        imm=28'hFFFF000; #1; check("ADDI_S -1",      imm_extended, 32'hFFFFFFFF);
        // imm[27]=1  imm[26:12]=0 → {17{1}, 15'h0} = 0xFFFF8000
        imm=28'h8000000; #1; check("ADDI_S min",     imm_extended, 32'hFFFF8000);

        // ==================================================================
        // Señal indefinida (011) → default → 0
        // ==================================================================
        we_reg=0; imm_src=2'b11; imm=28'hFFFFFFF; #1;
        check("UNDEF 011", imm_extended, 32'h00000000);

        // ==================================================================
        // Resumen
        // ==================================================================
        $display("====================================================================");
        $display("  Resultados: %0d PASS  %0d FAIL", pass_count, fail_count);
        $display("====================================================================");
        $finish;
    end

endmodule