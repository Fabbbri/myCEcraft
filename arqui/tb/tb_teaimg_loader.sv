`timescale 1ns/1ps
`include "tb/teaimg_config.svh"

`ifndef TEAIMG_BUFFER_COUNT
`define TEAIMG_BUFFER_COUNT 3
`endif

`ifndef TEAIMG_DECRYPT_ONLY
`define TEAIMG_DECRYPT_ONLY 0
`endif

module tb_teaimg_loader;

    parameter int MAX_CYCLES = 500000 + (`TEAIMG_IMAGE_WORDS * 12000);
    parameter int ROM_DEPTH  = 4096;
    parameter int RAM_DEPTH  = 65536;

    localparam LOADER_HEX = "programs/teaimg_loader.hex";
    localparam IMAGE_HEX  = "programs/teaimg_input.hex";
    localparam VAULT_HEX  = "programs/neather.hex";

    localparam int IMAGE_BYTES      = `TEAIMG_IMAGE_BYTES;
    localparam int IMAGE_SOURCE_BYTES = `TEAIMG_SOURCE_BYTES;
    localparam int IMAGE_WORDS      = `TEAIMG_IMAGE_WORDS;
    localparam int IMAGE_BUFFER_COUNT = `TEAIMG_BUFFER_COUNT;
    localparam bit DECRYPT_ONLY     = (`TEAIMG_DECRYPT_ONLY != 0);
    localparam int IMAGE_ORIG_BASE  = 16'h8010;
    localparam int IMAGE_ENC_BASE   = IMAGE_ORIG_BASE + IMAGE_BYTES;
    localparam int IMAGE_DEC_BASE   = IMAGE_ENC_BASE + IMAGE_BYTES;
    localparam int IMAGE_OUTPUT_BASE = DECRYPT_ONLY ? IMAGE_ORIG_BASE : IMAGE_DEC_BASE;
    localparam int BLOCK_BASE       = IMAGE_ORIG_BASE + (IMAGE_BYTES * IMAGE_BUFFER_COUNT);
    localparam int BLOCK_BYTES      = 8;

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

    task automatic wait_for_finish(output bit timed_out);
        int cycles;
        timed_out = 0;
        cycles = 0;

        forever begin
            @(posedge clk);
            cycles++;

            if (dut.Issue.pc_en === 1'b0) begin
                $display("[INFO]  FREEZE detectado en PC=%h (ciclo %0d)", `PC, cycles);
                repeat (5) @(posedge clk);
                return;
            end

            if (cycles >= MAX_CYCLES) begin
                $display("[ERROR] Timeout tras %0d ciclos - ultimo PC: %h", MAX_CYCLES, `PC);
                timed_out = 1;
                return;
            end
        end
    endtask

    task automatic check_reg(input int idx, input logic [31:0] expected, input string name);
        logic [31:0] got;
        got = `REGS[idx];
        if (got === expected) begin
            tests_passed++;
            $display("  [PASS] %-12s (x%02d) = %h", name, idx, got);
        end else begin
            tests_failed++;
            $display("  [FAIL] %-12s (x%02d) esperado=%h obtenido=%h", name, idx, expected, got);
        end
    endtask

    task automatic check_header(
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
            data_size >= (32'd36 + (IMAGE_BYTES * IMAGE_BUFFER_COUNT))
        ) begin
            tests_passed++;
            $display("  [PASS] Header MYCE valido: text=%0d bytes data=%0d bytes",
                     text_size, data_size);
        end else begin
            tests_failed++;
            $display("  [FAIL] Header MYCE invalido");
            $display("         version=%0d header=%0d entry=%h", version, header_size, entry_point);
            $display("         text_offset=%0d text_size=%0d data_offset=%0d data_size=%0d",
                     text_offset, text_size, data_offset, data_size);
            $display("         text_base=%h data_base=%h instr=%0d",
                     text_base, data_base, instruction_count);
        end
    endtask

    task automatic check_image_roundtrip();
        int dec_mismatches;
        int enc_equal_bytes;

        dec_mismatches = 0;
        enc_equal_bytes = 0;

        for (int i = 0; i < IMAGE_BYTES; i++) begin
            if (`DRAM[IMAGE_DEC_BASE + i] !== `DRAM[IMAGE_ORIG_BASE + i]) begin
                if (dec_mismatches < 8) begin
                    $display(
                        "  [FAIL] IMG DEC byte[%0d] esperado=%02h obtenido=%02h",
                        i,
                        `DRAM[IMAGE_ORIG_BASE + i],
                        `DRAM[IMAGE_DEC_BASE + i]
                    );
                end
                dec_mismatches++;
            end

            if (`DRAM[IMAGE_ENC_BASE + i] === `DRAM[IMAGE_ORIG_BASE + i]) begin
                enc_equal_bytes++;
            end
        end

        if (dec_mismatches == 0) begin
            tests_passed++;
            $display("  [PASS] Imagen descifrada == imagen original (%0d bytes)", IMAGE_BYTES);
        end else begin
            tests_failed++;
            $display("  [FAIL] Imagen descifrada difiere en %0d byte(s)", dec_mismatches);
        end

        if (enc_equal_bytes < IMAGE_BYTES) begin
            tests_passed++;
            $display(
                "  [PASS] Imagen cifrada difiere del original (%0d/%0d bytes iguales)",
                enc_equal_bytes,
                IMAGE_BYTES
            );
        end else begin
            tests_failed++;
            $display("  [FAIL] Imagen cifrada quedo igual al original");
        end
    endtask

    task automatic check_loader_unchanged_regions();
        int mismatches;
        int checked;

        mismatches = 0;
        checked = 0;

        for (int i = 0; i < loader_data_size; i++) begin
            int address;
            address = loader_data_base + i;

            if ((address >= IMAGE_ORIG_BASE &&
                 address < IMAGE_ORIG_BASE + (IMAGE_BYTES * IMAGE_BUFFER_COUNT)) ||
                (address >= BLOCK_BASE && address < BLOCK_BASE + BLOCK_BYTES)) begin
                continue;
            end

            checked++;
            if (`DRAM[address] !== loader_mem[loader_data_offset + i]) begin
                if (mismatches < 8) begin
                    $display(
                        "  [FAIL] DATA byte DRAM[%04h] esperado=%02h obtenido=%02h",
                        address,
                        loader_mem[loader_data_offset + i],
                        `DRAM[address]
                    );
                end
                mismatches++;
            end
        end

        if (mismatches == 0) begin
            tests_passed++;
            $display("  [PASS] Regiones no modificadas coinciden con loader (%0d bytes)", checked);
        end else begin
            tests_failed++;
            $display("  [FAIL] Regiones no modificadas tienen %0d diferencia(s)", mismatches);
        end
    endtask

    task automatic dump_outputs();
        $writememh("outputs/teaimg_salida.hex", `DRAM);
        $writememh("outputs/teaimg_vault.hex", `NRAM);
        $writememh("outputs/teaimg_descifrada.hex", `DRAM, IMAGE_OUTPUT_BASE, IMAGE_OUTPUT_BASE + IMAGE_BYTES - 1);
        if (!DECRYPT_ONLY) begin
            $writememh("outputs/teaimg_original.hex", `DRAM, IMAGE_ORIG_BASE, IMAGE_ORIG_BASE + IMAGE_BYTES - 1);
            $writememh("outputs/teaimg_cifrada.hex", `DRAM, IMAGE_ENC_BASE, IMAGE_ENC_BASE + IMAGE_BYTES - 1);
        end
        $display("[DUMP]  DRAM completa       -> outputs/teaimg_salida.hex");
        $display("[DUMP]  Vault completa      -> outputs/teaimg_vault.hex");
        if (!DECRYPT_ONLY) begin
            $display("[DUMP]  Imagen original     -> outputs/teaimg_original.hex");
            $display("[DUMP]  Imagen cifrada      -> outputs/teaimg_cifrada.hex");
        end
        $display("[DUMP]  Datos descifrados   -> outputs/teaimg_descifrada.hex");
        $display("[INFO]  Para extraer bytes reales use size=%0d", IMAGE_SOURCE_BYTES);
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

        loader_data_offset = data_offset;
        loader_data_size = data_size;
        loader_data_base = data_base;

        check_header(
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
            $display("[ERROR] teaimg_loader.hex no cabe o tiene flags inesperados");
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

        $readmemh(IMAGE_HEX, `DRAM);

        $display("[LOAD]  LOADER: %s", LOADER_HEX);
        $display("[LOAD]  IMAGE : %s -> DRAM[0x%04h..0x%04h]",
                  IMAGE_HEX, IMAGE_ORIG_BASE, IMAGE_ORIG_BASE + IMAGE_BYTES - 1);
        $display("[LOAD]  ROM   : %0d instrucciones desde offset 0x%08h",
                  instruction_count, text_offset);
        $display("[LOAD]  DATA  : %0d bytes hacia DRAM[0x%04h]",
                  data_size, data_base[15:0]);
        $display("[LOAD]  VAULT : %s", VAULT_HEX);
    endtask

    task automatic load_and_reset(output bit load_failed);
        #1;
        load_loader_image(load_failed);
        if (load_failed) begin
            return;
        end

        apply_reset();

        @(negedge clk);
        dut.Decode.SM.sm = 1'b0;
    endtask

    initial begin
        bit timed_out;
        bit load_failed;

        if ($test$plusargs("waves")) begin
            $dumpfile("sim/waves/tb_teaimg_loader.vcd");
            $dumpvars(0, tb_teaimg_loader);
        end else begin
            $display("[INFO]  VCD desactivado; use VVP_FLAGS=+waves para generar ondas.");
        end

        $display("============================================================");
        $display("       CRAFT21 TEA IMAGE LOADER TESTBENCH");
        $display("============================================================");

        $display("\n============================================================");
        if (DECRYPT_ONLY) begin
            $display("  TEST: teaimg.craft descifra archivo cifrado");
        end else begin
            $display("  TEST: teaimg.craft cifra y descifra imagen embebida");
        end
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

            $display("\n  --- Verificacion de imagen ---");
            if (DECRYPT_ONLY) begin
                tests_passed++;
                $display("  [PASS] Modo decrypt-only finalizo sin error de programa");
            end else begin
                check_image_roundtrip();
            end
            check_loader_unchanged_regions();
            $display(
                "  [INFO] Entrada:    DRAM[%04h..%04h]",
                IMAGE_ORIG_BASE,
                IMAGE_ORIG_BASE + IMAGE_BYTES - 1
            );
            if (!DECRYPT_ONLY) begin
                $display(
                    "  [INFO] Cifrada:    DRAM[%04h..%04h]",
                    IMAGE_ENC_BASE,
                    IMAGE_ENC_BASE + IMAGE_BYTES - 1
                );
            end
            $display(
                "  [INFO] Salida:     DRAM[%04h..%04h]",
                IMAGE_OUTPUT_BASE,
                IMAGE_OUTPUT_BASE + IMAGE_BYTES - 1
            );
        end

        dump_outputs();

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
