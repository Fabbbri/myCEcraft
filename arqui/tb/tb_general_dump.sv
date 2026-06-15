`timescale 1ns/1ps

module tb_general_dump;

    parameter int ROM_DEPTH = 4096;
    parameter int RAM_DEPTH = 65536;

    logic clk   = 0;
    logic reset = 0;

    string rom_hex;
    string data_hex;
    string vault_hex;
    string loader_hex;
    string out_prefix;
    int max_cycles;
    longint metric_cycles;
    longint metric_instructions;

    logic [7:0] loader_mem [0:RAM_DEPTH-1];

    top dut (.clk(clk), .reset(reset));
    defparam dut.Issue.ROM.DEPTH = ROM_DEPTH;

    always #5 clk = ~clk;

    `define REGS  dut.Decode.RegBank.regs
    `define VREGS dut.Decode.RegVBank.regs
    `define PC    dut.Issue.addr_aux
    `define ROM   dut.Issue.ROM.memory
    `define NRAM  dut.Memory.VaultRam.mem
    `define DRAM  dut.Memory.NormalRam.mem

    localparam logic [31:0] NOP = 32'h00580000;

    // ==========================================================
    //  Contadores de metricas (replica de tb_topG)
    //  pc_en==0 = instruccion FREEZE (halt); equivale al halt_pc
    //  de tb_topG. Los stalls usan stallIF, no pc_en, asi que el
    //  gating !halt_detected solo se apaga al terminar el programa.
    // ==========================================================
    integer csv_fd;
    // Contadores -> los lleva la PMU en hardware (dut.Perf.*). El testbench
    // ya no acumula: solo LEE los contadores en print_performance_metrics.
    // Se conservan estos espejos para no tocar el formato del CSV / [METRICS].
    longint l1_reads,   l1_writes;
    longint l1_rd_hits, l1_rd_miss, l1_wr_hits, l1_wr_miss;
    longint l2_acc,     l2_hits,    l2_miss;
    longint l2_reads,   l2_writes;
    longint mem_acc,    mem_bursts;
    longint stall_mem_cycles;
    longint ctrl_stalls;
    longint mem_xfer_cycles;

    function automatic logic [15:0] read_be16(input int address);
        read_be16 = {loader_mem[address], loader_mem[address + 1]};
    endfunction

    function automatic logic [31:0] read_be32(input int address);
        read_be32 = {
            loader_mem[address],
            loader_mem[address + 1],
            loader_mem[address + 2],
            loader_mem[address + 3]
        };
    endfunction

    task automatic apply_reset();
        reset = 1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        reset = 0;
    endtask

    task automatic clear_machine();
        for (int i = 0; i < ROM_DEPTH; i++) begin
            `ROM[i] = 32'h00580000;
        end

        for (int i = 0; i < RAM_DEPTH; i++) begin
            `DRAM[i] = 8'h00;
            `NRAM[i] = 8'h00;
            loader_mem[i] = 8'h00;
        end

        for (int i = 0; i < 32; i++) begin
            `REGS[i] = 32'h0;
            `VREGS[i] = 32'h0;
        end

        dut.Decode.SM.sm = 1'b0;
    endtask

    task automatic wait_for_finish(output bit timed_out);
        int cycles;
        int next_progress;

        timed_out = 0;
        cycles = 0;
        next_progress = 1000000;
        metric_cycles = 0;
        metric_instructions = 0;

        forever begin
            @(posedge clk);
            cycles++;
            // metric_cycles / metric_instructions ahora salen de la PMU
            // (se leen en print_performance_metrics); aqui solo control de loop.

            if (cycles >= next_progress) begin
                $display("[INFO]  Ejecutando... ciclo=%0d/%0d PC=%h",
                         cycles, max_cycles, `PC);
                next_progress += 1000000;
            end

            if (dut.Issue.pc_en === 1'b0) begin
                $display("[INFO]  FREEZE detectado en PC=%h (ciclo aprox %0d)",
                         `PC, cycles);
                return;
            end

            if (cycles >= max_cycles) begin
                $display("[ERROR] Timeout tras %0d ciclos - ultimo PC: %h",
                         max_cycles, `PC);
                timed_out = 1;
                return;
            end
        end
    endtask

    task automatic print_performance_metrics();
        real cpi, l1_hr, l1_mr, l2_hr, l2_mr, bw_util;
        longint l1_total;
        string  test_name;

        test_name = out_prefix;

        // Leer los contadores de la PMU (hardware). La PMU cuenta libre desde
        // el reset; el conteo historico del TB arrancaba 1 ciclo despues (dentro
        // de wait_for_finish), de ahi el -1 (igual que eff_cycles en tb_topG).
        metric_cycles       = (dut.Perf.cycles > 0) ? dut.Perf.cycles - 1 : 0;
        metric_instructions = dut.Perf.instr;
        stall_mem_cycles    = dut.Perf.stall_mem_cyc;
        ctrl_stalls         = dut.Perf.ctrl_stalls;
        l1_reads   = dut.Perf.l1_reads;    l1_writes  = dut.Perf.l1_writes;
        l1_rd_hits = dut.Perf.l1_rd_hits;  l1_rd_miss = dut.Perf.l1_rd_miss;
        l1_wr_hits = dut.Perf.l1_wr_hits;  l1_wr_miss = dut.Perf.l1_wr_miss;
        l2_acc     = dut.Perf.l2_acc;      l2_reads   = dut.Perf.l2_reads;
        l2_writes  = dut.Perf.l2_writes;
        l2_hits    = dut.Perf.l2_hits;     l2_miss    = dut.Perf.l2_miss;
        mem_acc    = dut.Perf.mem_acc;     mem_bursts = dut.Perf.mem_bursts;
        mem_xfer_cycles = dut.Perf.mem_xfer_cyc;

        cpi = (metric_instructions != 0)
            ? (1.0 * metric_cycles) / metric_instructions
            : 0.0;

        l1_total = l1_reads + l1_writes;
        l1_hr = (l1_total != 0) ? 100.0 * (l1_rd_hits + l1_wr_hits) / l1_total : 0.0;
        l1_mr = (l1_total != 0) ? 100.0 - l1_hr : 0.0;
        l2_hr = (l2_acc != 0) ? 100.0 * l2_hits / l2_acc : 0.0;
        l2_mr = (l2_acc != 0) ? 100.0 - l2_hr : 0.0;
        bw_util = (metric_cycles != 0) ? 100.0 * mem_xfer_cycles / metric_cycles : 0.0;

        if (csv_fd != 0) begin
            $fwrite(csv_fd,
                    "%s,%0d,%0d,%f,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%.2f,%.2f,%0d,%0d,%0d,%.2f,%.2f,%0d,%0d,%.2f\n",
                    test_name, metric_cycles, metric_instructions, cpi,
                    stall_mem_cycles, ctrl_stalls,
                    l1_reads, l1_writes,
                    l1_rd_hits, l1_rd_miss, l1_wr_hits, l1_wr_miss,
                    l1_hr, l1_mr,
                    l2_acc, l2_hits, l2_miss, l2_hr, l2_mr,
                    mem_acc, mem_xfer_cycles, bw_util);
        end

        $display("\n  --- Metricas de rendimiento ---");
        $display("  Ciclos        : %0d", metric_cycles);
        $display("  Instrucciones : %0d", metric_instructions);
        $display("  CPI           : %f", cpi);
        $display("  Stalls mem    : %0d ciclos | flush control: %0d", stall_mem_cycles, ctrl_stalls);
        $display("  L1: reads=%0d writes=%0d | rd h/m=%0d/%0d wr h/m=%0d/%0d | hit=%.2f%%",
                 l1_reads, l1_writes, l1_rd_hits, l1_rd_miss,
                 l1_wr_hits, l1_wr_miss, l1_hr);
        $display("  L2: acc=%0d hits=%0d miss=%0d | hit=%.2f%%",
                 l2_acc, l2_hits, l2_miss, l2_hr);
        $display("  Mem: accesos=%0d xfer=%0d ciclos bw=%.2f%% (bursts=%0d)",
                 mem_acc, mem_xfer_cycles, bw_util, mem_bursts);
        $display("  --------------------------------");

        // linea parseable para scripts/benchmarks.py
        $display("[METRICS] name=%s|cycles=%0d|instr=%0d|cpi=%f|stall_mem_cyc=%0d|ctrl_stalls=%0d|l1_reads=%0d|l1_writes=%0d|l1_rd_hits=%0d|l1_rd_miss=%0d|l1_wr_hits=%0d|l1_wr_miss=%0d|l1_hit_rate=%.2f|l1_miss_rate=%.2f|l2_acc=%0d|l2_hits=%0d|l2_miss=%0d|l2_hit_rate=%.2f|l2_miss_rate=%.2f|mem_acc=%0d|mem_xfer_cyc=%0d|bw_util=%.2f|mem_bursts=%0d|l2_reads=%0d|l2_writes=%0d",
                 test_name, metric_cycles, metric_instructions, cpi,
                 stall_mem_cycles, ctrl_stalls,
                 l1_reads, l1_writes, l1_rd_hits, l1_rd_miss,
                 l1_wr_hits, l1_wr_miss, l1_hr, l1_mr,
                 l2_acc, l2_hits, l2_miss, l2_hr, l2_mr,
                 mem_acc, mem_xfer_cycles, bw_util, mem_bursts,
                 l2_reads, l2_writes);
    endtask

    function automatic bit memory_hierarchy_idle();
        memory_hierarchy_idle =
            (dut.stall_mem === 1'b0) &&
            (dut.Memory.L2Con.rq_empty === 1'b1) &&
            (dut.Memory.L2Con.wb_empty === 1'b1) &&
            (dut.Memory.L2Con.load_state == 2'b00) &&
            (dut.Memory.L2Con.wb_state == 2'b00) &&
            (dut.Memory.MemCtrl.rq_empty === 1'b1) &&
            (dut.Memory.MemCtrl.wb_empty === 1'b1) &&
            (dut.Memory.MemCtrl.wbd_busy === 1'b0) &&
            (dut.Memory.burst_active === 1'b0) &&
            (dut.Memory.ram_we === 1'b0);
    endfunction

    task automatic wait_for_memory_drain(output bit timed_out);
        int cycles;
        int quiet_cycles;

        cycles = 0;
        quiet_cycles = 0;
        timed_out = 0;

        // FREEZE detiene fetch, pero stores anteriores pueden seguir en los
        // buffers write-through de L2 y del controlador de memoria.
        while (quiet_cycles < 8) begin
            @(posedge clk);
            cycles++;

            if (memory_hierarchy_idle())
                quiet_cycles++;
            else
                quiet_cycles = 0;

            if (cycles >= max_cycles) begin
                $display("[ERROR] Timeout drenando la jerarquia de memoria");
                $display("        L2 rq_empty=%b wb_empty=%b load_state=%0d wb_state=%0d",
                         dut.Memory.L2Con.rq_empty,
                         dut.Memory.L2Con.wb_empty,
                         dut.Memory.L2Con.load_state,
                         dut.Memory.L2Con.wb_state);
                $display("        MC rq_empty=%b wb_empty=%b wbd_busy=%b burst=%b ram_we=%b",
                         dut.Memory.MemCtrl.rq_empty,
                         dut.Memory.MemCtrl.wb_empty,
                         dut.Memory.MemCtrl.wbd_busy,
                         dut.Memory.burst_active,
                         dut.Memory.ram_we);
                timed_out = 1;
                return;
            end
        end

        $display("[INFO]  Jerarquia de memoria drenada (%0d ciclos)", cycles);
    endtask

    task automatic load_raw_hex();
        $readmemh(rom_hex, `ROM);
        $readmemh(data_hex, `DRAM);
        $readmemh(vault_hex, `NRAM);

        $display("[LOAD]  ROM   : %s", rom_hex);
        $display("[LOAD]  DATA  : %s", data_hex);
        $display("[LOAD]  VAULT : %s", vault_hex);
    endtask

    task automatic load_myce_loader(output bit failed);
        logic [15:0] version;
        logic [15:0] header_size;
        logic [31:0] entry_point;
        logic [31:0] text_offset;
        logic [31:0] text_size;
        logic [31:0] data_offset;
        logic [31:0] data_size;
        logic [31:0] text_base;
        logic [31:0] data_base;
        logic [31:0] instruction_count;
        logic [31:0] flags;

        failed = 0;

        $readmemh(loader_hex, loader_mem);
        $readmemh(vault_hex, `NRAM);

        version = read_be16(4);
        header_size = read_be16(6);
        entry_point = read_be32(8);
        text_offset = read_be32(12);
        text_size = read_be32(16);
        data_offset = read_be32(20);
        data_size = read_be32(24);
        text_base = read_be32(28);
        data_base = read_be32(32);
        instruction_count = read_be32(36);
        flags = read_be32(40);

        if (loader_mem[0] !== 8'h4D ||
            loader_mem[1] !== 8'h59 ||
            loader_mem[2] !== 8'h43 ||
            loader_mem[3] !== 8'h45 ||
            version !== 16'd1 ||
            header_size !== 16'd44 ||
            entry_point !== 32'h00000000 ||
            text_offset !== 32'd44 ||
            text_base !== 32'h00000000 ||
            data_base + data_size > RAM_DEPTH ||
            text_offset + text_size > RAM_DEPTH ||
            data_offset + data_size > RAM_DEPTH ||
            instruction_count > ROM_DEPTH ||
            text_size != instruction_count * 4 ||
            flags !== 32'h00000000) begin
            failed = 1;
            $display("[ERROR] Header MYCE invalido o imagen no cabe");
            $display("        version=%0d header=%0d entry=%h flags=%h",
                     version, header_size, entry_point, flags);
            $display("        text_offset=%0d text_size=%0d instr=%0d",
                     text_offset, text_size, instruction_count);
            $display("        data_offset=%0d data_size=%0d data_base=%h",
                     data_offset, data_size, data_base);
            return;
        end

        for (int i = 0; i < instruction_count; i++) begin
            int base;
            base = text_offset + (i * 4);
            `ROM[i] = {
                loader_mem[base],
                loader_mem[base + 1],
                loader_mem[base + 2],
                loader_mem[base + 3]
            };
        end

        for (int i = 0; i < data_size; i++) begin
            `DRAM[data_base + i] = loader_mem[data_offset + i];
        end

        $display("[LOAD]  LOADER: %s", loader_hex);
        $display("[LOAD]  ROM   : %0d instrucciones desde offset 0x%08h",
                 instruction_count, text_offset);
        $display("[LOAD]  DATA  : %0d bytes hacia DRAM[0x%04h]",
                 data_size, data_base[15:0]);
        $display("[LOAD]  VAULT : %s", vault_hex);
    endtask

    task automatic dump_regs_to_file(input string path);
        int fd;
        fd = $fopen(path, "w");
        if (fd == 0) begin
            $display("[WARN]  No se pudo abrir %s", path);
            return;
        end

        $fdisplay(fd, "PC = %08h", `PC);
        for (int i = 0; i < 32; i++) begin
            $fdisplay(fd, "x%02d = %08h", i, `REGS[i]);
        end
        $fdisplay(fd, "");
        for (int i = 0; i < 32; i++) begin
            $fdisplay(fd, "v%02d = %08h", i, `VREGS[i]);
        end
        $fclose(fd);
    endtask

    task automatic dump_outputs();
        string dram_path;
        string vault_path;
        string rom_path;
        string regs_path;

        dram_path = $sformatf("outputs/%0s_dram.hex", out_prefix);
        vault_path = $sformatf("outputs/%0s_vault.hex", out_prefix);
        rom_path = $sformatf("outputs/%0s_rom.hex", out_prefix);
        regs_path = $sformatf("outputs/%0s_regs.txt", out_prefix);

        $writememh(dram_path, `DRAM);
        $writememh(vault_path, `NRAM);
        $writememh(rom_path, `ROM);
        dump_regs_to_file(regs_path);

        $display("[DUMP]  DRAM  -> %s", dram_path);
        $display("[DUMP]  Vault -> %s", vault_path);
        $display("[DUMP]  ROM   -> %s", rom_path);
        $display("[DUMP]  Regs  -> %s", regs_path);
    endtask

    task automatic dump_nonzero_regs();
        $display("\n  --- Banco de registros no cero ---");
        for (int i = 0; i < 32; i++) begin
            if (`REGS[i] !== 32'h0) begin
                $display("    x%02d = %h", i, `REGS[i]);
            end
        end
        $display("  ----------------------------------");
    endtask

    initial begin
        bit timed_out;
        bit load_failed;
        bit drain_timed_out;

        rom_hex = "programs/program.hex";
        data_hex = "programs/data.hex";
        vault_hex = "programs/neather.hex";
        loader_hex = "";
        out_prefix = "general";
        max_cycles = 1000000;

        if ($value$plusargs("ROM=%s", rom_hex)) begin end
        if ($value$plusargs("DATA=%s", data_hex)) begin end
        if ($value$plusargs("VAULT=%s", vault_hex)) begin end
        if ($value$plusargs("LOADER=%s", loader_hex)) begin end
        if ($value$plusargs("OUT=%s", out_prefix)) begin end
        if ($value$plusargs("MAX_CYCLES=%d", max_cycles)) begin end

        if ($test$plusargs("waves")) begin
            $dumpfile("sim/waves/tb_general_dump.vcd");
            $dumpvars(0, tb_general_dump);
        end else begin
            $display("[INFO]  VCD desactivado; use VVP_FLAGS=+waves para generar ondas.");
        end

        $display("============================================================");
        $display("          CRAFT21 GENERAL MEMORY DUMP TESTBENCH");
        $display("============================================================");

        csv_fd = $fopen($sformatf("outputs/%0s_metrics.csv", out_prefix), "w");
        if (csv_fd == 0)
            $display("[WARN]  No se pudo abrir el CSV de metricas");
        else
            $fwrite(csv_fd, "Test Ejecutado,Ciclos,Instr,CPI,Stalls_Mem,Stalls_Control,L1_Reads,L1_Writes,L1_Read_Hits,L1_Read_Misses,L1_Write_Hits,L1_Write_Misses,L1_Hit_Rate,L1_Miss_Rate,L2_Accesses,L2_Hits,L2_Misses,L2_Hit_Rate,L2_Miss_Rate,Memory_Accesses,Mem_Transfer_Cycles,BW_Util\n");

        clear_machine();

        load_failed = 0;
        if (loader_hex != "") begin
            load_myce_loader(load_failed);
        end else begin
            load_raw_hex();
        end

        if (!load_failed) begin
            apply_reset();
            @(negedge clk);
            dut.Decode.SM.sm = 1'b0;
            wait_for_finish(timed_out);
            if (!timed_out)
                wait_for_memory_drain(drain_timed_out);
            else
                drain_timed_out = 0;
        end else begin
            timed_out = 0;
            drain_timed_out = 0;
        end

        if (timed_out || drain_timed_out) begin
            $display("[ERROR] Test abortado por timeout");
        end

        if (!load_failed)
            print_performance_metrics();

        dump_nonzero_regs();
        dump_outputs();

        $display("============================================================");
        $display("  FIN TB GENERAL");
        $display("============================================================\n");

        if (csv_fd != 0) $fclose(csv_fd);
        $finish;
    end

    `undef REGS
    `undef VREGS
    `undef PC
    `undef ROM
    `undef NRAM
    `undef DRAM

endmodule
