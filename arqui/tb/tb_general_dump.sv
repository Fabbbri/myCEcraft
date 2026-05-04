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

    logic [7:0] loader_mem [0:RAM_DEPTH-1];

    top dut (.clk(clk), .reset(reset));
    defparam dut.Issue.ROM.DEPTH = ROM_DEPTH;

    always #5 clk = ~clk;

    `define REGS  dut.Decode.RegBank.regs
    `define VREGS dut.Decode.RegVBank.regs
    `define PC    dut.Issue.addr_aux
    `define ROM   dut.Issue.ROM.memory
    `define NRAM  dut.mem.VaultRam.mem
    `define DRAM  dut.mem.NormalRam.mem

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

        forever begin
            repeat (1000) @(posedge clk);
            cycles += 1000;

            if (cycles >= next_progress) begin
                $display("[INFO]  Ejecutando... ciclo=%0d/%0d PC=%h",
                         cycles, max_cycles, `PC);
                next_progress += 1000000;
            end

            if (dut.Issue.pc_en === 1'b0) begin
                $display("[INFO]  FREEZE detectado en PC=%h (ciclo aprox %0d)",
                         `PC, cycles);
                repeat (5) @(posedge clk);
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
        end else begin
            timed_out = 0;
        end

        if (timed_out) begin
            $display("[ERROR] Test abortado por timeout");
        end

        dump_nonzero_regs();
        dump_outputs();

        $display("============================================================");
        $display("  FIN TB GENERAL");
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
