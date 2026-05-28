`timescale 1ns/1ps

module tb_topG;

    string FILE_ROM;
    string FILE_RAM;
    longint cycle_count;
    longint instr_count;
    integer csv_fd;

    // ==========================================
    // Parametros
    // ==========================================

    parameter int          MAX_CYCLES = 20000;
    parameter logic [31:0] HALT_PC    = 32'h0000006C; // freeze en 0x006C

    // h00000160 para Factorial.hex

    logic clk   = 0;
    logic reset = 0;
    int tests_passed = 0;
    int tests_failed = 0;

    // ==========================================
    // Instancia
    // ==========================================

    top dut (.clk(clk), .reset(reset));

    always #5 clk = ~clk;

    // ==========================================
    // Variables de la dut
    // ==========================================

    `define REGS  dut.Decode.RegBank.regs
    `define PC    dut.Issue.addr_aux
    `define ROM   dut.Issue.ROM.memory // acceder a rom en modulo instr_rom
    `define RAM   dut.Memory.NormalRam.mem // acceder a memoria en modulo data_ram

    // ==========================================
    // Contadores
    // ==========================================

    localparam logic [31:0] NOP = 32'h00580000;
    logic halt_detected = 0;

    // 1. Ciclos ocurridos
    always @(posedge clk) begin
        if (`PC === HALT_PC) halt_detected <= 1;
        if (!reset && !halt_detected)
            cycle_count++;
    end

    // 2. Instrucciones distintas de NOP y que pasan por EX
    // stallE=1 congela EX sin flush -> misma instruccion se contaria N veces durante stall_mem
    always @(posedge clk) begin
        if (!reset) begin
            if (dut.instrDE !== NOP &&
                dut.instrDE !== 32'hxxxxxxxx &&
                !dut.flushE &&
                !dut.stallE)
            begin
                instr_count++;
            end
        end
    end

    // ==========================================
    // Task para aplicar reset
    // ==========================================

    task automatic apply_reset();
        reset = 1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        reset = 0;

        $display("[RESET] Reset liberado en t=%0t ns", $time);

        @(posedge clk); #1;
        $display("[DEBUG] pcF=%h instrF=%h newpc=%h stallIF=%b flushD=%b flushE=%b stall_mem=%b",
            dut.pcF,
            dut.instrF,
            dut.newpc,
            dut.stallIF,
            dut.flushD,
            dut.flushE,
            dut.stall_mem);

        $display("[PIPE] pcF=%08h instrF=%08h | pcDE=%08h instrDE=%08h",
         dut.pcF, dut.instrF, dut.pcDE, dut.instrDE);

    endtask

    // ==========================================
    //  Task: Esperar fin de programa
    // ==========================================
    task automatic wait_for_finish(output bit timed_out);
        int cycles;
        timed_out = 0;
        cycles    = 0;

        forever begin
            @(posedge clk);
            cycles++;

            // Detectar freeze
            if (`PC === HALT_PC) begin
                $display("[INFO]  HALT en PC=%h  (ciclo %0d)", `PC, cycles);
                return;
            end

            // Terminar si lleva muchos ciclos
            if (cycles >= MAX_CYCLES) begin
                $display("[ERROR] Timeout tras %0d ciclos - último PC: %h",
                          MAX_CYCLES, `PC);
                timed_out = 1;
                return;
            end
        end
    endtask

    // ==========================================
    //  Task: Revisar registros
    // ==========================================

    task automatic check_reg(input int idx, input logic [31:0] expected, input string name);
        logic [31:0] got;
        got = `REGS[idx];
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] %-4s (x%02d) = %h", name, idx, got);
        end else begin
            tests_failed++;
            $display("  [FAIL] %-4s (x%02d)  esperado=%h  obtenido=%h", name, idx, expected, got);
        end
    endtask

    // ======================================
    // Task: Imprimir registros distintos de cero
    // ======================================

    task automatic dump_regs();
        $display("\n  --- Banco de registros ---");
        for (int i = 0; i < 32; i++)
            if (`REGS[i] !== 32'h0)
                $display("    x%02d = %h", i, `REGS[i]);
        $display("  --------------------------");
    endtask

    // ======================================
    // Task: inicializar memoria ROM
    // ======================================
    task automatic load_and_reset(input string rom_file, input string ram_file);
        // Inicializar ROM con NOPs
        for (int i = 0; i < (16384-1); i++)
            `ROM[i] = 32'h00580000;
        $readmemh(rom_file, `ROM);
        $display("[LOAD]  %s", rom_file);

        $readmemh(ram_file, `RAM);
        $display("[LOAD] %s", ram_file);
        apply_reset();
    endtask

    task automatic run_test(
        input string test_name,
        input string rom_file,
        input string ram_file
    );
        bit timed_out;

        $display("\n============================================================");
        $display("  TEST: %s", test_name);
        $display("============================================================");

        // ======================================
        // Resetear variables
        // ======================================

        cycle_count = 0;
        instr_count = 0;
        halt_detected = 0; 

        load_and_reset(rom_file, ram_file);
        wait_for_finish(timed_out);

        if (timed_out) begin
            $display("[ERROR] Test abortado - dump de registros:");
            dump_regs();
            tests_failed++;
            return;
        end

        // Drenar pipeline: esperar que stall_mem lleve 8 ciclos quieto
        // (cubre LWs que entran a MEM varios ciclos despues del HALT)
        begin
            int quiet;
             while (quiet < 8) begin
                @(posedge clk);
                if (!dut.stall_mem) quiet++;
                else quiet = 0;
            end
        end
        repeat (4) @(posedge clk);

        // ======================================
        // CHECK REGISTER PRINT
        // CAMBIAR SEGÚN TEST
        // ======================================

        // DEMO.CRAFT REGISTERS
        $display("\n  --- Registros clave ---");
        check_reg(11, 32'h00000005, "x11");
        check_reg( 3, 32'h00000005, "x3");
        check_reg( 5, 32'h00000005, "x5");
        check_reg( 2, 32'h00007ff0, "x2");  // stack pointer restaurado

        // ======================================
        // Sobreescribir los resultados CSV
        // ======================================

        begin
            real cpi;

            cpi = (instr_count != 0)
                ? (1.0 * cycle_count) / instr_count
                : 0.0;

            $fwrite(csv_fd,
                    "%s,%0d,%0d,%f\n",
                    test_name,
                    cycle_count,
                    instr_count,
                    cpi);

            $display("\n  --- Performance ---");
            $display("  Ciclos        : %0d", cycle_count-1);
            // -1 porque cycle_count para de contar hasta el ciclo después de que detecta el HALT
            // sería +3 si se quiere contar los ciclos del drenado
            $display("  Instrucciones : %0d", instr_count);
            $display("  CPI           : %f", cpi);
        end

    endtask

/*     // ==========================================
    // Memory debug 
    // ==========================================
    logic prev_stall_mem  = 0;
    logic prev_req_lw = 0;
    logic prev_req_sw  = 0;
    logic [2:0] prev_fsm  = 3'bx;
    int stall_cyc = 0;

    task automatic mem_snapshot(input string tag);
        $display("[%s t=%0t] FSM=%0d rq_full=%b rq_empty=%b lp=%b lp_nxt=%b rd_valid=%b stall=%b",
            tag, $time,
            dut.Memory.MemCtrl.FSM.state,
            dut.Memory.MemCtrl.rq_full,
            dut.Memory.MemCtrl.rq_empty,
            dut.Memory.MemCtrl.load_pending,
            dut.Memory.MemCtrl.load_pending_next,
            dut.Memory.MemCtrl.rd_valid,
            dut.stall_mem);
    endtask

    always @(posedge clk) begin
        if (!reset) begin
            // LW request - fire once on rising edge
            if (dut.Memory.MemCtrl.req && !dut.Memory.MemCtrl.we && !prev_req_lw) begin
                $display("[LW-REQ  t=%0t] addr=%08h", $time, dut.Memory.MemCtrl.addr);
                mem_snapshot("SNAP");
            end
            // SW request - fire once on rising edge
            if (dut.Memory.MemCtrl.req && dut.Memory.MemCtrl.we && !prev_req_sw)
                $display("[SW-REQ  t=%0t] addr=%08h wdata=%08h",
                         $time, dut.Memory.MemCtrl.addr, dut.Memory.MemCtrl.wdata);

            // stall_mem rising edge
            if (!prev_stall_mem && dut.stall_mem) begin
                $display("[STALL-UP t=%0t]", $time);
                stall_cyc = 0;
            end

            // stall_mem falling edge - LW done
            if (prev_stall_mem && !dut.stall_mem)
                $display("[LW-DONE t=%0t] rdata=%08h", $time, dut.Memory.rMemData);

            // Periodic snapshot while stalled (every 100 clk cycles)
            if (dut.stall_mem) begin
                stall_cyc++;
                if (stall_cyc % 50 == 0) begin
                    $display("[STALL   t=%0t] %0d cycles", $time, stall_cyc);
                    mem_snapshot("SNAP");
                end
            end

            // FSM state change
            if (dut.Memory.MemCtrl.FSM.state !== prev_fsm && prev_fsm !== 3'bx)
                $display("[FSM-CHG t=%0t] %0d->%0d  writes_done=%b wb_empty=%b wbd_busy=%b rq_empty=%b",
                         $time, prev_fsm, dut.Memory.MemCtrl.FSM.state,
                         dut.Memory.MemCtrl.writes_all_done,
                         dut.Memory.MemCtrl.wb_empty,
                         dut.Memory.MemCtrl.wbd_busy,
                         dut.Memory.MemCtrl.rq_empty);

            prev_stall_mem <= dut.stall_mem;
            prev_req_lw <= dut.Memory.MemCtrl.req && !dut.Memory.MemCtrl.we;
            prev_req_sw <= dut.Memory.MemCtrl.req &&  dut.Memory.MemCtrl.we;
            prev_fsm <= dut.Memory.MemCtrl.FSM.state;
        end
    end

    // RAM writes (clk_mem domain)
    always @(posedge dut.Memory.clk_mem) begin
        if (!reset && dut.Memory.MemCtrl.ram_we)
            $display("[RAM-WR  t=%0t] addr=%08h data=%08h",
                     $time, dut.Memory.MemCtrl.ram_addr, dut.Memory.MemCtrl.ram_wdata);
    end */

    initial begin
        $display("============================================================");
        $display("         CRAFT21 ARCHITECTURE TESTBENCH");
        $display("============================================================");

        // ======================================
        // Archivo Waves
        // ======================================

        $dumpfile("sim/waves/tb_topG.vcd");
        $dumpvars(0, tb_topG);

        // ======================================
        // Preparar archivo de tipo CSV
        // ======================================

        csv_fd = $fopen("outputs/reports/results.csv", "w");

        if (csv_fd == 0) begin
            $display("ERROR: no se pudo abrir CSV");
            $finish;
        end

        $fwrite(csv_fd, "Test Ejecutado,Ciclos,Instr,CPI\n");

        // ======================================
        // CARGAR ROM Y RAM
        // Se configura desde el make y el comando make
        // ======================================

        if (!$value$plusargs("FILE_ROM=%s", FILE_ROM)) begin
            $display("ERROR: no se pasó la ROM");
            $finish;
        end

        if (!$value$plusargs("FILE_RAM=%s", FILE_RAM)) begin
            $display("ERROR: no se pasó la RAM");
            $finish;
        end

        // ======================================
        // EJECUTAR TEST
        // run_test("nombre del test", FILE_ROM, FILE_RAM);
        // ======================================        

        run_test("while loop x<5 (return x=5)", FILE_ROM, FILE_RAM);

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

        $fclose(csv_fd); // cerrar el archivo csv
        $finish;
    end

    `undef REGS
    `undef PC
    `undef ROM
    `undef RAM

endmodule