`timescale 1ns/1ps

module tb_top;

    parameter int MAX_CYCLES = 10000;

    // HALT_PC es variable entre tests (hay que cambiarlo)
    logic [31:0] halt_pc = 32'h00000110;

    logic clk   = 0;
    logic reset = 0;
    int tests_passed = 0;
    int tests_failed = 0;

    top dut (.clk(clk), .reset(reset));

    always #5 clk = ~clk;

    // INSTANCIAS DISTINTAS

    `define REGS  dut.Decode.RegBank.regs
    `define PC    dut.Issue.addr_aux
    `define ROM   dut.Issue.ROM.memory // acceder a rom en modulo instr_rom
    `define RAM   dut.Memory.NormalRam.mem // acceder a memoria en modulo data_ram

    // ======================================
    // TASK PARA APLICAR RESET
    // ======================================
    task automatic apply_reset();
        reset = 1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        reset = 0;
    endtask

    // ======================================
    // TASK PARA ESPERAR FIN DEL PROGRAMA
    // ======================================
    task automatic wait_for_finish(output bit timed_out);
        int cycles;
        logic [31:0] last_pc;
        timed_out = 0;
        cycles    = 0;
        last_pc   = 32'hFFFFFFFF;

        forever begin
            @(posedge clk);
            cycles++;

            // FREEZE: pc_enable=0 → PC dejó de avanzar
            if (dut.Issue.pc_en === 1'b0) begin
                $display("[INFO]  FREEZE detectado en PC=%h (ciclo %0d)", `PC, cycles);
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

    // ======================================
    // TASK PARA REVISAR REGISTROS
    // ======================================
    task automatic check_reg(input int idx, input logic [31:0] expected, input string name);
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

    // ======================================
    // TASK: Imprimir registros distintos de cero
    // ======================================
    task automatic dump_regs();
        $display("\n  --- Banco de registros ---");
        for (int i = 0; i < 32; i++)
            if (`REGS[i] !== 32'h0)
                $display("    x%02d = %h", i, `REGS[i]);
        $display("  --------------------------");
    endtask

    // ======================================
    // TASK: inicializar memoria ROM
    // ======================================
    task automatic load_and_reset(input string hex_file);
        // Inicializar ROM con NOPs
        for (int i = 0; i < 256; i++)
            `ROM[i] = 32'h00580000;
        $readmemh(hex_file, `ROM);
        $display("[LOAD]  %s", hex_file);
        apply_reset();
    endtask

    // ======================================
    // TASK: ejecutar simulacion 
    // recibe nombre, hex_file y 
    // el halt_pc del programa (ver asm)
    // ======================================
    task automatic run_test(
        input string       test_name,
        input string       hex_file,
        input logic [31:0] new_halt_pc
    );
        bit timed_out;

        $display("\n============================================================");
        $display("  TEST: %s", test_name);
        $display("============================================================");

        halt_pc = new_halt_pc;
        load_and_reset(hex_file);
        wait_for_finish(timed_out);

        if (timed_out) begin
            $display("[ERROR] Test abortado — dump de registros:");
            dump_regs();
            tests_failed++;
            return;
        end

        repeat (4) @(posedge clk);
    endtask

    // =========================================================
    //  Bloque principal: Agregar o quitar tests
    // =========================================================
    initial begin
        $display("============================================================");
        $display("         CRAFT21 ARCHITECTURE TESTBENCH");
        $display("============================================================");

        $dumpfile("sim/waves/tb_top.vcd");
        $dumpvars(0, tb_top);

        // TEST 1
        run_test("while loop x<5, return x=5", "programs/demo.hex", 32'h0000006C);
        $display("\n  --- Registros clave ---");
        check_reg(11, 32'h00000005, "x11");
        check_reg( 3, 32'h00000005, "x3");
        check_reg( 5, 32'h00000005, "x5");

        // TEST 2
        run_test("busqueda lineal arreglo, return pos=3", "programs/busqueda_arreglo.hex", 32'h00000268);
        $display("\n  --- Registros clave ---");
        check_reg(11, 32'h00000003, "x11");
        check_reg( 2, 32'h00000000, "x2");
        check_reg( 0, 32'h00000000, "x0");

        // TEST 3
        run_test("factorial(5) = 120", "programs/factorial.hex", 32'h0000016C);
        $display("\n  --- Registros clave ---");
        check_reg(11, 32'h00000078, "x11");  // 5! = 120 = 0x78
        check_reg( 2, 32'h00000000, "x2");
        check_reg( 0, 32'h00000000, "x0");


        // REPORTE FINAL
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
    `undef ROM
    `undef RAM

endmodule