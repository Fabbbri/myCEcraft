`timescale 1ns/1ps

module tb_top_vault;

    parameter int MAX_CYCLES = 15000;
    parameter int ROM_DEPTH  = 512;

    logic clk   = 0;
    logic reset = 0;
    int tests_passed = 0;
    int tests_failed = 0;

    top dut (.clk(clk), .reset(reset));
    always #5 clk = ~clk;

    `define REGS  dut.Decode.RegBank.regs
    `define VREGS dut.Decode.RegVBank.regs
    `define PC    dut.Issue.addr_aux
    `define ROM   dut.Issue.ROM.memory
    `define NRAM  dut.mem.VaultRam.mem
    `define DRAM  dut.mem.NormalRam.mem

    // =========================================================
    //  Reset
    // =========================================================
    task automatic apply_reset();
        reset = 1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        reset = 0;
    endtask

    // =========================================================
    //  Esperar fin — detecta FREEZE (pc_enable=0)
    // =========================================================
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
                $display("[ERROR] Timeout tras %0d ciclos — último PC: %h",
                          MAX_CYCLES, `PC);
                timed_out = 1;
                return;
            end
        end
    endtask

    // =========================================================
    //  Verificar registro normal
    // =========================================================
    task automatic check_reg(
        input int          idx,
        input logic [31:0] expected,
        input string       name
    );
        logic [31:0] got;
        got = `REGS[idx];
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] %-4s (x%02d) = %h", name, idx, got);
        end else begin
            tests_failed++;
            $display("  [FAIL] %-4s (x%02d)  esperado=%h  obtenido=%h",
                      name, idx, expected, got);
        end
    endtask

    // =========================================================
    //  Verificar word en neather_ram (little-endian)
    // =========================================================
    task automatic check_nram(
        input int          offset,
        input logic [31:0] expected,
        input string       label
    );
        logic [31:0] got;
        got = {`NRAM[offset+3], `NRAM[offset+2],
               `NRAM[offset+1], `NRAM[offset]};
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] NRAM[%0d] = %h  (%s)", offset, got, label);
        end else begin
            tests_failed++;
            $display("  [FAIL] NRAM[%0d]  esperado=%h  obtenido=%h  (%s)",
                      offset, expected, got, label);
        end
    endtask

    // =========================================================
    //  Cargar programa y limpiar estado
    // =========================================================
    task automatic load_and_reset(input string hex_file);
        for (int i = 0; i < ROM_DEPTH; i++)
            `ROM[i] = 32'h00580000;

        for (int i = 0; i < 32; i++)
            `REGS[i] = 32'h0;

        for (int i = 0; i < 32; i++)
            `VREGS[i] = 32'h0;

        dut.Decode.SM.sm = 1'b0;

        for (int i = 0; i < 256; i++)
            `NRAM[i] = 8'h00;
        `NRAM[0] = 8'h49;
        `NRAM[1] = 8'h08;
        `NRAM[2] = 8'h00;
        `NRAM[3] = 8'h00;

        for (int i = 0; i < 512; i++)
            `DRAM[i] = 8'h00;

        $readmemh(hex_file, `ROM);
        $display("[LOAD]  %s", hex_file);

        apply_reset();

        @(negedge clk);
        dut.Decode.SM.sm = 1'b0;
    endtask

    // =========================================================
    //  Bloque principal
    // =========================================================
    initial begin
        bit timed_out;

        $dumpfile("sim/waves/tb_vault.vcd");
        $dumpvars(0, tb_top_vault);

        $display("\n[DEBUG] Monitoreo WB + MEM (pipeline real)\n");

        fork
            begin
                $display("\n[DEBUG] Monitoreo WB + MEM (pipeline real)\n");

                forever begin
                    @(posedge clk);

                    // WRITEBACK REGFILE NORMAL
                    if (dut.WriteBack.we_regOUT) begin
                        $display("[WB REG] rd=%0d wd=%h",
                            dut.WriteBack.instrDOUT,
                            dut.WriteBack.wdOUT);
                    end

                    // WRITEBACK REGFILE BOVEDA
                    if (dut.WriteBack.w_regvOUT && dut.WriteBack.neather_modeOUT) begin
                        $display("[WB VREG] rdv=%0d wdv=%h",
                            dut.WriteBack.instrDOUT,
                            dut.WriteBack.wdvOUT);
                    end

                    // WRITE MEM NORMAL
                    if (dut.mem.we_mem) begin
                        $display("[MEM WRITE] addr=%h data=%h",
                            dut.mem.alu_result,
                            dut.mem.rd2);
                    end

                    // WRITE MEM BOVEDA
                    if (dut.mem.w_memv && dut.mem.neather_mode) begin
                        $display("[MEM VWRITE] addr=%h data=%h",
                            dut.mem.alu_result,
                            dut.mem.rdv2);
                    end

                    $display("[MEM DEBUG] w_memv=%b we_mem=%b neather_mode=%b addr=%h",
                                dut.mem.w_memv,
                                dut.mem.we_mem,
                                dut.mem.neather_mode,
                                dut.mem.alu_result
                            );
                end
            end
        join_none

        $display("============================================================");
        $display("         CRAFT21 VAULT TESTBENCH");
        $display("============================================================");

        $display("\n============================================================");
        $display("  TEST: ender demo — neather vault ops");
        $display("============================================================");

        load_and_reset("programs/ender_demo.hex");
        wait_for_finish(timed_out);

        if (timed_out) begin
            tests_failed++;
            $display("[ERROR] Test abortado por timeout");
        end else begin
            $display("\n  --- Registros clave ---");
            check_reg(11, 32'h00000000, "x11");
            check_reg( 2, 32'h00000000, "x2");
            check_reg( 0, 32'h00000000, "x0");

            $display("\n  --- Neather RAM ---");
            check_nram(0, 32'h002396E3, "key[0]");
            check_nram(4, 32'h002396E3, "copia lwv→swv");
        end

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
    `undef VREGS
    `undef PC
    `undef ROM
    `undef NRAM
    `undef DRAM

endmodule