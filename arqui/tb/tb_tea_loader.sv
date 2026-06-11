`timescale 1ns/1ps

module tb_tea_loader;

    parameter int MAX_CYCLES = 200000;
    parameter int ROM_DEPTH  = 2048;
    parameter int RAM_DEPTH  = 65536;

    localparam LOADER_HEX = "programs/tea_loader.hex";
    localparam VAULT_HEX  = "programs/neather.hex";

    localparam int KEY_BASE       = 16'h8000;
    localparam int PLAIN_BASE     = 16'h8010;
    localparam int CIPHER_BASE    = 16'h8018;
    localparam int ROUNDTRIP_BASE = 16'h8020;
    localparam int DELTA_ADDR     = 16'h8028;
    localparam int SUM_INIT_ADDR  = 16'h802C;

    logic clk   = 0;
    logic reset = 0;
    int tests_passed = 0;
    int tests_failed = 0;

    logic [7:0] loader_mem [0:RAM_DEPTH-1];
    int loader_data_offset = 0;
    int loader_data_size = 0;
    int loader_data_base = 0;

    top dut (.clk(clk), .reset(reset));
    defparam dut.Issue.ROM.DEPTH = ROM_DEPTH;

    always #5 clk = ~clk;

    `define REGS  dut.Decode.RegBank.regs
    `define VREGS dut.Decode.RegVBank.regs
    `define PC    dut.Issue.addr_aux
    `define ROM   dut.Issue.ROM.memory
    `define NRAM  dut.Memory.VaultRam.mem
    `define DRAM  dut.Memory.NormalRam.mem

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

    task automatic wait_for_finish(output bit timed_out);
        // begin:body + disable en lugar de return (compat Icarus)
        begin : wf_body
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
                disable wf_body;
            end

            if (cycles >= MAX_CYCLES) begin
                $display("[ERROR] Timeout tras %0d ciclos - ultimo PC: %h",
                          MAX_CYCLES, `PC);
                timed_out = 1;
                disable wf_body;
            end
        end
        end
    endtask

    task automatic check_reg(
        input int          idx,
        input logic [31:0] expected,
        input string       name
    );
        logic [31:0] got;
        got = `REGS[idx];
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] %-12s (x%02d) = %h", name, idx, got);
        end else begin
            tests_failed++;
            $display("  [FAIL] %-12s (x%02d) esperado=%h obtenido=%h",
                      name, idx, expected, got);
        end
    endtask

    task automatic check_dram_word(
        input int          offset,
        input logic [31:0] expected,
        input string       label
    );
        logic [31:0] got;
        got = {`DRAM[offset+3], `DRAM[offset+2],
               `DRAM[offset+1], `DRAM[offset]};
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] DRAM[%04h] = %h  (%s)", offset, got, label);
        end else begin
            tests_failed++;
            $display("  [FAIL] DRAM[%04h] esperado=%h obtenido=%h  (%s)",
                      offset, expected, got, label);
        end
    endtask

    task automatic check_nram_word(
        input int          offset,
        input logic [31:0] expected,
        input string       label
    );
        logic [31:0] got;
        got = {`NRAM[offset+3], `NRAM[offset+2],
               `NRAM[offset+1], `NRAM[offset]};
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] NRAM[%04h] = %h  (%s)", offset, got, label);
        end else begin
            tests_failed++;
            $display("  [FAIL] NRAM[%04h] esperado=%h obtenido=%h  (%s)",
                      offset, expected, got, label);
        end
    endtask

    task automatic check_loader_header(
        input logic [15:0] version,
        input logic [15:0] header_size,
        input logic [31:0] entry_point,
        input logic [31:0] text_offset,
        input logic [31:0] text_size,
        input logic [31:0] data_offset,
        input logic [31:0] data_size,
        input logic [31:0] text_base,
        input logic [31:0] data_base,
        input logic [31:0] instruction_count
    );
        if (
            loader_mem[0] === 8'h4D &&
            loader_mem[1] === 8'h59 &&
            loader_mem[2] === 8'h43 &&
            loader_mem[3] === 8'h45 &&
            version === 16'd1 &&
            header_size === 16'd44 &&
            entry_point === 32'h00000000 &&
            text_offset === 32'd44 &&
            text_base === 32'h00000000 &&
            data_base === 32'h00008000 &&
            text_size == instruction_count * 4 &&
            data_size >= 32'd48
        ) begin
            tests_passed++;
            $display("  [PASS] Header MYCE valido: text=%0d bytes data=%0d bytes",
                      text_size, data_size);
        end else begin
            tests_failed++;
            $display("  [FAIL] Header MYCE invalido");
            $display("         magic=%c%c%c%c version=%0d header=%0d entry=%h",
                     loader_mem[0], loader_mem[1], loader_mem[2], loader_mem[3],
                     version, header_size, entry_point);
            $display("         text_offset=%0d text_size=%0d data_offset=%0d data_size=%0d",
                     text_offset, text_size, data_offset, data_size);
            $display("         text_base=%h data_base=%h instr=%0d",
                     text_base, data_base, instruction_count);
        end
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

    function automatic bit is_tea_result_byte(input int address);
        is_tea_result_byte =
            (address >= CIPHER_BASE && address < CIPHER_BASE + 8) ||
            (address >= ROUNDTRIP_BASE && address < ROUNDTRIP_BASE + 8);
    endfunction

    task automatic check_loader_data_against_ram(
        input int data_offset,
        input int data_size,
        input int data_base
    );
        int checked;
        int skipped;
        int mismatches;

        checked = 0;
        skipped = 0;
        mismatches = 0;

        for (int i = 0; i < data_size; i++) begin
            int address;
            address = data_base + i;

            // if/else en lugar de continue: Icarus no lo soporta en loops
            if (is_tea_result_byte(address)) begin
                skipped++;
            end
            else begin
                checked++;
                if (`DRAM[address] !== loader_mem[data_offset + i]) begin
                    if (mismatches < 8) begin
                        $display(
                            "  [FAIL] DATA byte DRAM[%04h] esperado=%02h obtenido=%02h",
                            address,
                            loader_mem[data_offset + i],
                            `DRAM[address]
                        );
                    end
                    mismatches++;
                end
            end
        end

        if (mismatches == 0) begin
            tests_passed++;
            $display(
                "  [PASS] DATA loader == DRAM resultante en %0d bytes conservados (%0d bytes TEA saltados)",
                checked,
                skipped
            );
        end else begin
            tests_failed++;
            $display(
                "  [FAIL] DATA loader vs DRAM: %0d diferencias en %0d bytes revisados",
                mismatches,
                checked
            );
        end
    endtask

    task automatic check_recovered_block_against_loader(
        input int data_offset,
        input int data_base
    );
        int plain_offset;
        int cipher_offset;
        int mismatches;
        bit cipher_changed;

        plain_offset = data_offset + (PLAIN_BASE - data_base);
        cipher_offset = data_offset + (CIPHER_BASE - data_base);
        mismatches = 0;
        cipher_changed = 0;

        for (int i = 0; i < 8; i++) begin
            if (`DRAM[ROUNDTRIP_BASE + i] !== loader_mem[plain_offset + i]) begin
                mismatches++;
            end
            if (`DRAM[CIPHER_BASE + i] !== loader_mem[cipher_offset + i]) begin
                cipher_changed = 1;
            end
        end

        if (mismatches == 0) begin
            tests_passed++;
            $display(
                "  [PASS] Imagen/bloque recuperado en DRAM[%04h..%04h] coincide con plain original",
                ROUNDTRIP_BASE,
                ROUNDTRIP_BASE + 7
            );
        end else begin
            tests_failed++;
            $display(
                "  [FAIL] Bloque recuperado no coincide con plain original: %0d byte(s) distintos",
                mismatches
            );
        end

        if (cipher_changed) begin
            tests_passed++;
            $display(
                "  [PASS] Bloque cifrado en DRAM[%04h..%04h] cambio respecto al loader inicial",
                CIPHER_BASE,
                CIPHER_BASE + 7
            );
        end else begin
            tests_failed++;
            $display(
                "  [FAIL] Bloque cifrado no cambio respecto al loader inicial"
            );
        end
    endtask

    task automatic dump_result_memories();
        $writememh("outputs/salida.hex", `DRAM);
        $writememh("outputs/salidavault.hex", `NRAM);
        $writememh("outputs/salidacifrada.hex", `DRAM, CIPHER_BASE, CIPHER_BASE + 7);
        $writememh("outputs/salidarecuperada.hex", `DRAM, ROUNDTRIP_BASE, ROUNDTRIP_BASE + 7);
        $display("[DUMP]  DRAM  -> outputs/salida.hex");
        $display("[DUMP]  VAULT -> outputs/salidavault.hex");
        $display("[DUMP]  CIFR  -> outputs/salidacifrada.hex");
        $display("[DUMP]  RECV  -> outputs/salidarecuperada.hex");
    endtask

    task automatic load_loader_image(output bit load_failed);
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

        begin : lli_body
        load_failed = 0;

        for (int i = 0; i < RAM_DEPTH; i++) begin
            loader_mem[i] = 8'h00;
            `NRAM[i] = 8'h00;
            `DRAM[i] = 8'h00;
        end

        for (int i = 0; i < ROM_DEPTH; i++) begin
            `ROM[i] = 32'h00580000;
        end

        for (int i = 0; i < 32; i++) begin
            `REGS[i] = 32'h0;
            `VREGS[i] = 32'h0;
        end

        dut.Decode.SM.sm = 1'b0;

        $readmemh(LOADER_HEX, loader_mem);
        $readmemh(VAULT_HEX, `NRAM);

        version           = read_be16(4);
        header_size       = read_be16(6);
        entry_point       = read_be32(8);
        text_offset       = read_be32(12);
        text_size         = read_be32(16);
        data_offset       = read_be32(20);
        data_size         = read_be32(24);
        text_base         = read_be32(28);
        data_base         = read_be32(32);
        instruction_count = read_be32(36);
        flags             = read_be32(40);

        loader_data_offset = data_offset;
        loader_data_size = data_size;
        loader_data_base = data_base;

        check_loader_header(
            version,
            header_size,
            entry_point,
            text_offset,
            text_size,
            data_offset,
            data_size,
            text_base,
            data_base,
            instruction_count
        );

        if (text_offset + text_size > RAM_DEPTH ||
            data_offset + data_size > RAM_DEPTH ||
            data_base + data_size > RAM_DEPTH ||
            instruction_count > ROM_DEPTH ||
            flags !== 32'h00000000) begin
            tests_failed++;
            load_failed = 1;
            $display("[ERROR] tea_loader.hex no cabe o tiene flags inesperados");
            disable lli_body;
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

        $display("[LOAD]  LOADER: %s", LOADER_HEX);
        $display("[LOAD]  ROM   : %0d instrucciones desde offset 0x%08h",
                  instruction_count, text_offset);
        $display("[LOAD]  DATA  : %0d bytes hacia DRAM[0x%04h]",
                  data_size, data_base[15:0]);
        $display("[LOAD]  VAULT : %s", VAULT_HEX);
        end
    endtask

    task automatic load_and_reset(output bit load_failed);
        begin : lr_body
        #1;
        load_loader_image(load_failed);
        if (load_failed) begin
            disable lr_body;
        end

        apply_reset();

        @(negedge clk);
        dut.Decode.SM.sm = 1'b0;
        end
    endtask

    initial begin
        bit timed_out;
        bit load_failed;

        $dumpfile("sim/waves/tb_tea_loader.vcd");
        $dumpvars(0, tb_tea_loader);

        $display("============================================================");
        $display("      CRAFT21 TEA LOADER IMAGE TESTBENCH");
        $display("============================================================");

        $display("\n============================================================");
        $display("  TEST: tea.bin convertido por load_file.py a tea_loader.hex");
        $display("============================================================");

        load_and_reset(load_failed);
        if (!load_failed) begin
            wait_for_finish(timed_out);
        end else begin
            timed_out = 0;
        end

        if (load_failed) begin
            $display("[ERROR] Test abortado por imagen loader invalida");
            dump_nonzero_regs();
        end else if (timed_out) begin
            tests_failed++;
            $display("[ERROR] Test abortado por timeout");
            dump_nonzero_regs();
        end else begin
            $display("\n  --- Registros clave ---");
            check_reg(11, 32'h00000000, "return");
            check_reg( 2, 32'h00007FF0, "sp");
            check_reg( 0, 32'h00000000, "zero");

            $display("\n  --- Vault RAM ---");
            check_nram_word(16'h0000, 32'h00000000, "password bootstrap");

            $display("\n  --- Data RAM: estado inicial conservado ---");
            check_dram_word(KEY_BASE + 0, 32'h00000000, "key[0]");
            check_dram_word(KEY_BASE + 4, 32'h00000001, "key[1]");
            check_dram_word(KEY_BASE + 8, 32'h00000002, "key[2]");
            check_dram_word(KEY_BASE + 12, 32'h00000003, "key[3]");
            check_dram_word(PLAIN_BASE + 0, 32'h00000000, "plain[0]");
            check_dram_word(PLAIN_BASE + 4, 32'h00000000, "plain[1]");
            check_dram_word(DELTA_ADDR, 32'h9E3779B9, "DELTA");
            check_dram_word(SUM_INIT_ADDR, 32'hC6EF3720, "SUM_INIT");

            $display("\n  --- Data RAM: resultados TEA ---");
            check_dram_word(CIPHER_BASE + 0, 32'hFB0EED65, "cipher[0]");
            check_dram_word(CIPHER_BASE + 4, 32'h3892B421, "cipher[1]");
            check_dram_word(ROUNDTRIP_BASE + 0, 32'h00000000, "roundtrip[0]");
            check_dram_word(ROUNDTRIP_BASE + 4, 32'h00000000, "roundtrip[1]");

            $display("\n  --- Comparacion loader vs RAM resultante ---");
            check_loader_data_against_ram(
                loader_data_offset,
                loader_data_size,
                loader_data_base
            );
            check_recovered_block_against_loader(
                loader_data_offset,
                loader_data_base
            );
            $display(
                "  [INFO] Recuperado actual: DRAM[%04h..%04h] (roundtrip, 8 bytes)",
                ROUNDTRIP_BASE,
                ROUNDTRIP_BASE + 7
            );
        end

        dump_result_memories();

        $display("\n============================================================");
        $display("  REPORTE FINAL");
        $display("============================================================");
        $display("  PASADOS : %0d", tests_passed);
        $display("  FALLIDOS: %0d", tests_failed);
        $display("  Total   : %0d", tests_passed + tests_failed);

        if (tests_failed == 0) begin
            $display("  RESULTADO: ** ALL TESTS PASSED **");
        end else begin
            $display("  RESULTADO: ** %0d FALLO(S) **", tests_failed);
        end

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
