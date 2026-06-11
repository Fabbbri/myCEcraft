`timescale 1ns/1ps

module tb_topG;

    string FILE_ROM;
    string FILE_RAM;
    string TEST_NAME;
    logic [31:0] expect_x11;
    bit          use_expect;
    longint cycle_count;
    longint instr_count;
    integer csv_fd;

    // ==========================================
    // Parametros
    // ==========================================

    parameter int          MAX_CYCLES = 20000;
    parameter logic [31:0] HALT_PC    = 32'h0000006C;

    // PC del freeze (halt): cada programa compilado lo tiene en una
    // direccion distinta; se puede sobreescribir con +HALT_PC=<hex>
    logic [31:0] halt_pc = HALT_PC;
    int          max_cycles = MAX_CYCLES;

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
    `define ROM   dut.Issue.ROM.memory
    `define RAM   dut.Memory.NormalRam.mem

    // ==========================================
    // Contadores
    // ==========================================

    localparam logic [31:0] NOP = 32'h00580000;
    logic halt_detected = 0;

    always @(posedge clk) begin
        if (`PC === halt_pc) halt_detected <= 1;
        if (!reset && !halt_detected)
            cycle_count++;
    end

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
    // Contadores de cache (muestreo no invasivo de señales del dut)
    // ==========================================

    // op de memoria real en MEM: load = result_src==01, store = we_mem
    // (hit_l1/miss_l1 son combinacionales sobre alu_result aunque no haya
    //  acceso real; hay que filtrar por el tipo de instruccion en MEM)
    wire mem_rd_op = (dut.Memory.result_src == 2'b01);
    wire mem_wr_op = (dut.Memory.we_mem === 1'b1);
    wire mem_op    = mem_rd_op | mem_wr_op;

    longint l1_reads,   l1_writes;
    longint l1_rd_hits, l1_rd_miss, l1_wr_hits, l1_wr_miss;
    longint l2_acc,     l2_hits,    l2_miss;
    longint mem_acc,    mem_bursts;

    // acceso nuevo = cambia direccion o tipo respecto al ciclo anterior
    // (durante stall el pipeline retiene la misma op en MEM: no recontar)
    logic        prev_mem_op = 0;
    logic        prev_wr     = 0;
    logic [31:0] prev_addr   = '0;
    logic        prev_burst  = 0;

    wire new_access = mem_op && !(prev_mem_op &&
                                  prev_addr == dut.Memory.alu_result &&
                                  prev_wr   == mem_wr_op);

    always @(posedge clk) begin
        if (!reset && !halt_detected) begin
            // L1: clasificar en el primer ciclo de cada acceso
            if (new_access) begin
                if (mem_wr_op) begin
                    l1_writes++;
                    if (dut.Memory.hit_l1) l1_wr_hits++; else l1_wr_miss++;
                end else begin
                    l1_reads++;
                    if (dut.Memory.hit_l1) l1_rd_hits++; else l1_rd_miss++;
                    // L2 read: cada load miss de L1 baja a L2; en este ciclo
                    // alu_result es la direccion del load y hit_l2 el veredicto
                    if (!dut.Memory.hit_l1) begin
                        l2_acc++;
                        if (dut.Memory.hit_l2) begin
                            l2_hits++;
                        end else begin
                            l2_miss++;
                            mem_acc++;   // load miss en L2 -> burst a RAM
                        end
                    end
                end
            end

            // L2 writes: un WB_COMMIT (1 ciclo) por store drenado
            if (dut.Memory.L2Con.wb_state == 2'b10) begin
                l2_acc++;
                if (dut.Memory.hit_l2_wb) l2_hits++; else l2_miss++;
                mem_acc++;       // write-through: todo store drenado va a RAM
            end

            // diagnostico: bursts reales en el bus (incluye trafico no atribuible)
            if (dut.Memory.burst_active && !prev_burst)
                mem_bursts++;
        end

        prev_mem_op  <= mem_op && !reset;
        prev_wr      <= mem_wr_op;
        prev_addr    <= dut.Memory.alu_result;
        prev_burst   <= dut.Memory.burst_active;
    end

    // DEBUG temporal: trafico hacia/desde RAM y write path
    logic dbg_on = 0;
    initial if ($value$plusargs("DBG=%d", dbg_on)) begin end
    always @(posedge clk) begin
        if (dbg_on && !reset) begin
            if (dut.Memory.wb_write)
                $display("[DBG t=%0t] wb_write addr=%h data=%h size=%b",
                    $time, dut.Memory.wb_addr_mem, dut.Memory.wb_data_mem, dut.Memory.wb_size_mem);
            if (dut.Memory.MemCtrl.rq_wr_en)
                $display("[DBG t=%0t] rq_push we=%b addr=%h wdata=%h",
                    $time, dut.Memory.MemCtrl.rq_data_in[66],
                    dut.Memory.MemCtrl.rq_data_in[65:34], dut.Memory.MemCtrl.rq_data_in[31:0]);
            if (dut.Memory.ram_we)
                $display("[DBG t=%0t] RAM_WR addr=%h data=%h size=%b",
                    $time, dut.Memory.ram_addr, dut.Memory.ram_wdata, dut.Memory.ram_size);
            if (dut.Memory.burst_active)
                $display("[DBG t=%0t] BURST cnt=%0d addr=%h rdata=%h",
                    $time, dut.Memory.burst_counter, dut.Memory.ram_addr, dut.Memory.burst_rdata);
            if (mem_rd_op && !dut.stall_mem)
                $display("[DBG t=%0t] LOAD_DONE addr=%h hit_l1=%b hit_l2=%b rdata=%h",
                    $time, dut.Memory.alu_result, dut.Memory.hit_l1,
                    dut.Memory.hit_l2, dut.Memory.rMemData);
            if (dut.Memory.L2Con.rq_push)
                $display("[DBG t=%0t] L2RQ_PUSH addr=%h we_mem=%b rsrc=%b PC=%h",
                    $time, dut.Memory.alu_result, dut.Memory.we_mem,
                    dut.Memory.result_src, `PC);
            if (dut.Memory.L2Con.wb_push)
                $display("[DBG t=%0t] L2WB_PUSH addr=%h data=%h full=%b",
                    $time, dut.Memory.alu_result, dut.Memory.rd2,
                    dut.Memory.L2Con.wb_full);
            if (dut.Memory.we_mem && !dut.Memory.L2Con.wb_push)
                $display("[DBG t=%0t] ST_BLOCK addr=%h full=%b pushed=%b last=%h stall=%b",
                    $time, dut.Memory.alu_result, dut.Memory.L2Con.wb_full,
                    dut.Memory.L2Con.wb_pushed, dut.Memory.L2Con.wb_last_addr,
                    dut.stall_mem);
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
    // Task: diagnóstico de stall
    // ==========================================
    task automatic stall_diag(input string tag);
        $display("[%s t=%0t] stall_mem=%b stall_l2=%b stall_mc=%b | rq_full_l2=%b rq_empty_l2=%b load_state=%0d | rq_full_mc=%b wb_full_mc=%b | miss_l1=%b miss_l2=%b hit_l1=%b hit_l2=%b | stallIF=%b stallE=%b stallM=%b stallW=%b",
            tag, $time,
            dut.stall_mem,
            dut.Memory.stall_l2,
            dut.Memory.stall_mc,
            dut.Memory.L2Con.rq_full,
            dut.Memory.L2Con.rq_empty,
            dut.Memory.L2Con.load_state,
            dut.Memory.MemCtrl.rq_full,
            dut.Memory.MemCtrl.wb_full,
            dut.Memory.miss_l1,
            dut.Memory.miss_l2,
            dut.Memory.hit_l1,
            dut.Memory.hit_l2,
            dut.stallIF,
            dut.stallE,
            dut.stallM,
            dut.stallW);
    endtask

    // ==========================================
    // Monitor continuo de stall (primeros 20 ciclos tras reset)
    // ==========================================
    int mon_cycles = 0;
    logic mon_active = 0;

    always @(posedge clk) begin
        if (mon_active) begin
            mon_cycles++;
            if (mon_cycles <= 20) begin
                $display("[MON c=%02d] PC=%08h stall_mem=%b stall_l2=%b stall_mc=%b load_state=%0d miss_l1=%b miss_l2=%b hit_l2=%b rq_full_l2=%b",
                    mon_cycles,
                    `PC,
                    dut.stall_mem,
                    dut.Memory.stall_l2,
                    dut.Memory.stall_mc,
                    dut.Memory.L2Con.load_state,
                    dut.Memory.miss_l1,
                    dut.Memory.miss_l2,
                    dut.Memory.hit_l2,
                    dut.Memory.L2Con.rq_full);
            end else begin
                mon_active = 0;
            end
        end
    end

    // ==========================================
    //  Task: Esperar fin de programa
    // ==========================================
    task automatic wait_for_finish(output bit timed_out);
        int cycles;
        bit done;
        timed_out = 0;
        cycles    = 0;
        done      = 0;

        // while+flag en lugar de return: Icarus no soporta return en tasks
        while (!done) begin
            @(posedge clk);
            cycles++;

            if (`PC === halt_pc) begin
                $display("[INFO]  HALT en PC=%h  (ciclo %0d)", `PC, cycles);
                done = 1;
            end
            else if (cycles >= max_cycles) begin
                $display("[ERROR] Timeout tras %0d ciclos - último PC: %h",
                          max_cycles, `PC);
                timed_out = 1;
                done = 1;
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
        for (int i = 0; i < (16384-1); i++)
            `ROM[i] = 32'h00580000;
        $readmemh(rom_file, `ROM);
        $display("[LOAD]  %s", rom_file);

        $readmemh(ram_file, `RAM);
        $display("[LOAD] %s", ram_file);
        apply_reset();

        // Activar monitor de los primeros 20 ciclos
        mon_cycles = 0;
        mon_active = 1;

        // Snapshot inmediato post-reset
        stall_diag("POST-RST");
    endtask

    // ==========================================
    //  Task: reporte de metricas (CSV + stdout parseable)
    // ==========================================
    task automatic report_metrics(input string test_name);
        real cpi, l1_hr, l1_mr, l2_hr, l2_mr;
        longint l1_total;

        cpi = (instr_count != 0)
            ? (1.0 * cycle_count) / instr_count
            : 0.0;

        l1_total = l1_reads + l1_writes;
        l1_hr = (l1_total != 0) ? 100.0 * (l1_rd_hits + l1_wr_hits) / l1_total : 0.0;
        l1_mr = (l1_total != 0) ? 100.0 - l1_hr : 0.0;
        l2_hr = (l2_acc != 0) ? 100.0 * l2_hits / l2_acc : 0.0;
        l2_mr = (l2_acc != 0) ? 100.0 - l2_hr : 0.0;

        $fwrite(csv_fd,
                "%s,%0d,%0d,%f,%0d,%0d,%0d,%0d,%0d,%0d,%.2f,%.2f,%0d,%0d,%0d,%.2f,%.2f,%0d\n",
                test_name, cycle_count, instr_count, cpi,
                l1_reads, l1_writes,
                l1_rd_hits, l1_rd_miss, l1_wr_hits, l1_wr_miss,
                l1_hr, l1_mr,
                l2_acc, l2_hits, l2_miss, l2_hr, l2_mr,
                mem_acc);

        $display("\n  --- Performance ---");
        $display("  Ciclos        : %0d", cycle_count-1);
        $display("  Instrucciones : %0d", instr_count);
        $display("  CPI           : %f", cpi);
        $display("  L1: reads=%0d writes=%0d | rd h/m=%0d/%0d wr h/m=%0d/%0d | hit=%.2f%%",
                 l1_reads, l1_writes, l1_rd_hits, l1_rd_miss,
                 l1_wr_hits, l1_wr_miss, l1_hr);
        $display("  L2: acc=%0d hits=%0d miss=%0d | hit=%.2f%%",
                 l2_acc, l2_hits, l2_miss, l2_hr);
        $display("  Mem: accesos=%0d (bursts en bus=%0d)", mem_acc, mem_bursts);

        // linea parseable para scripts/benchmarks.py
        $display("[METRICS] name=%s|cycles=%0d|instr=%0d|cpi=%f|l1_reads=%0d|l1_writes=%0d|l1_rd_hits=%0d|l1_rd_miss=%0d|l1_wr_hits=%0d|l1_wr_miss=%0d|l1_hit_rate=%.2f|l1_miss_rate=%.2f|l2_acc=%0d|l2_hits=%0d|l2_miss=%0d|l2_hit_rate=%.2f|l2_miss_rate=%.2f|mem_acc=%0d|mem_bursts=%0d",
                 test_name, cycle_count, instr_count, cpi,
                 l1_reads, l1_writes, l1_rd_hits, l1_rd_miss,
                 l1_wr_hits, l1_wr_miss, l1_hr, l1_mr,
                 l2_acc, l2_hits, l2_miss, l2_hr, l2_mr,
                 mem_acc, mem_bursts);
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

        cycle_count = 0;
        instr_count = 0;
        halt_detected = 0;

        l1_reads = 0; l1_writes = 0;
        l1_rd_hits = 0; l1_rd_miss = 0; l1_wr_hits = 0; l1_wr_miss = 0;
        l2_acc = 0; l2_hits = 0; l2_miss = 0;
        mem_acc = 0; mem_bursts = 0;

        load_and_reset(rom_file, ram_file);
        wait_for_finish(timed_out);

        if (timed_out) begin
            $display("[ERROR] Test abortado - dump de registros:");
            // Snapshot final en timeout
            stall_diag("TIMEOUT");
            dump_regs();
            tests_failed++;
        end
        else begin
            begin
                int quiet;
                quiet = 0;
                while (quiet < 8) begin
                    @(posedge clk);
                    if (!dut.stall_mem) quiet++;
                    else quiet = 0;
                end
            end
            repeat (4) @(posedge clk);

            if (use_expect) begin
                // benchmark generico: el resultado queda en x11
                $display("\n  --- Registro de resultado ---");
                check_reg(11, expect_x11, "x11");
            end
            else begin
                // checks del programa default (while 0-5)
                $display("\n  --- Registros clave ---");
                check_reg(11, 32'h00000005, "x11");
                check_reg( 3, 32'h00000005, "x3");
                check_reg( 5, 32'h00000005, "x5");
                check_reg( 2, 32'h00007ff0, "x2");
            end

            dump_regs();
            report_metrics(test_name);
        end

    endtask

    initial begin
        $display("============================================================");
        $display("         CRAFT21 ARCHITECTURE TESTBENCH");
        $display("============================================================");

        $dumpfile("sim/waves/tb_topG.vcd");
        $dumpvars(0, tb_topG);

        csv_fd = $fopen("outputs/reports/results.csv", "w");

        if (csv_fd == 0) begin
            $display("ERROR: no se pudo abrir CSV");
            $finish;
        end

        $fwrite(csv_fd, "Test Ejecutado,Ciclos,Instr,CPI,L1_Reads,L1_Writes,L1_Read_Hits,L1_Read_Misses,L1_Write_Hits,L1_Write_Misses,L1_Hit_Rate,L1_Miss_Rate,L2_Accesses,L2_Hits,L2_Misses,L2_Hit_Rate,L2_Miss_Rate,Memory_Accesses\n");

        if (!$value$plusargs("FILE_ROM=%s", FILE_ROM)) begin
            $display("ERROR: no se pasó la ROM");
            $finish;
        end

        if (!$value$plusargs("FILE_RAM=%s", FILE_RAM)) begin
            $display("ERROR: no se pasó la RAM");
            $finish;
        end

        // opcionales: nombre del test y valor esperado en x11 (benchmarks)
        if (!$value$plusargs("TEST_NAME=%s", TEST_NAME))
            TEST_NAME = "while loop x<5 (return x=5)";
        use_expect = $value$plusargs("EXPECT_X11=%h", expect_x11) ? 1'b1 : 1'b0;
        if ($value$plusargs("HALT_PC=%h", halt_pc)) begin end
        if ($value$plusargs("MAX_CYCLES=%d", max_cycles)) begin end

        run_test(TEST_NAME, FILE_ROM, FILE_RAM);

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

        $fclose(csv_fd);
        $finish;
    end

    `undef REGS
    `undef PC
    `undef ROM
    `undef RAM

endmodule