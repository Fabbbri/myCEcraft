`timescale 1ns/1ps

module tb_instr_rom;

// =====================================================
//  DUT ports
// =====================================================
logic        clk   = 0;
logic        stall = 0;
logic [31:0] addr;
logic [31:0] instr;

// =====================================================
//  Clock  (10 ns period)
// =====================================================
always #5 clk = ~clk;

// =====================================================
//  DUT
// =====================================================
instr_rom #(.DEPTH(16)) dut (
    .clk   (clk),
    .stall (stall),
    .addr  (addr),
    .instr (instr)
);

// =====================================================
//  Helpers
// =====================================================
task automatic tick;
    @(posedge clk); #1;
endtask

task automatic check;
    input [31:0] got, expected;
    input [63:0] label; // just a tag value, printed in hex
    if (got === expected)
        $display("[PASS] addr=%08h  instr=%08h", label[31:0], got);
    else
        $display("[FAIL] addr=%08h  got=%08h  expected=%08h",
                 label[31:0], got, expected);
endtask

// =====================================================
//  Test sequence
// =====================================================
initial begin
    $dumpfile("sim/waves/tb_instr_rom.vcd");
    $dumpvars(0, tb_instr_rom);

    $display("============================================");
    $display("  tb_instr_rom — ROM síncrona");
    $display("============================================");

    // --------------------------------------------------
    // TEST 1: latencia de 1 ciclo
    // Presenta addr en ciclo N, instr llega en ciclo N+1
    // --------------------------------------------------
    $display("\n--- TEST 1: latencia 1 ciclo ---");

    addr = 32'h0000_0000;   // word 0 → memory[0]
    tick;                   // flanco: ROM registra addr=0
    // instr ya tiene la salida de memory[0]
    check(instr, dut.memory[0], 64'h0);

    addr = 32'h0000_0004;   // word 1 → memory[1]
    tick;
    check(instr, dut.memory[1], 64'h4);

    addr = 32'h0000_0008;   // word 2 → memory[2]
    tick;
    check(instr, dut.memory[2], 64'h8);

    // --------------------------------------------------
    // TEST 2: dirección fuera de rango → NOP
    // --------------------------------------------------
    $display("\n--- TEST 2: dirección fuera de rango ---");

    addr = 32'hFFFF_FFFC;   // muy por arriba de DEPTH=16
    tick;
    check(instr, 32'h0058_0000, 64'hFFFFFFFC); // NOP en Craft21

    // --------------------------------------------------
    // TEST 3: stall — instr no cambia aunque addr cambie
    // --------------------------------------------------
    $display("\n--- TEST 3: stall ---");

    addr  = 32'h0000_000C;   // word 3
    stall = 0;
    tick;                    // flanco: captura word 3
    // en este tick instr = memory[2] (el anterior)
    // el siguiente tick mostrará memory[3]

    stall = 1;               // freeze instr
    addr  = 32'h0000_0010;   // word 4 — NO debe capturarse
    tick;
    $display("[STALL] instr=%08h  (debe ser memory[3]=%08h)  match=%s",
             instr, dut.memory[3],
             (instr === dut.memory[3]) ? "OK" : "FAIL");

    addr = 32'h0000_0014;    // word 5 — todavía stalleado
    tick;
    $display("[STALL] instr=%08h  (debe seguir memory[3]=%08h)  match=%s",
             instr, dut.memory[3],
             (instr === dut.memory[3]) ? "OK" : "FAIL");

    stall = 0;               // libera stall
    tick;                    // ahora captura word 5 (addr=14)
    tick;                    // entrega word 5
    $display("[POST-STALL] instr=%08h  (debe ser memory[5]=%08h)  match=%s",
             instr, dut.memory[5],
             (instr === dut.memory[5]) ? "OK" : "FAIL");

    // --------------------------------------------------
    // TEST 4: acceso secuencial completo (words 0..7)
    // --------------------------------------------------
    $display("\n--- TEST 4: barrido secuencial words 0-7 ---");

    stall = 0;
    begin : sweep
        integer i;
        for (i = 0; i < 8; i = i + 1) begin
            addr = i * 4;
            tick;
        end
        // ahora recoge las 8 respuestas (cada tick entregó la word anterior)
        // rehacer para mostrar:
        for (i = 0; i < 8; i = i + 1) begin
            addr = i * 4;
            @(posedge clk); #1;
            check(instr, dut.memory[i], i * 4);
        end
    end

    $display("\n============================================");
    $display("  Fin de tb_instr_rom");
    $display("============================================");
    $finish;
end

endmodule