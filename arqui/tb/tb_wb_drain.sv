`timescale 1ns/1ps

module tb_wb_drain;

logic clk_mem;
logic reset;
logic wb_empty;
logic [65:0] wb_data;
logic wb_ren;
logic mem_busy;
logic ram_we;
logic [31:0] ram_addr;
logic [1:0] ram_size;
logic [31:0] ram_wdata;
logic busy;

int pass_count = 0;
int fail_count = 0;

always #10 clk_mem = ~clk_mem;

wb_drain dut (
    .clk_mem (clk_mem),
    .reset (reset),
    .wb_empty (wb_empty),
    .wb_data (wb_data),
    .wb_ren (wb_ren),
    .mem_busy (mem_busy),
    .ram_we (ram_we),
    .ram_addr (ram_addr),
    .ram_size (ram_size),
    .ram_wdata (ram_wdata),
    .busy (busy)
);

localparam WRITE_CYCLES = 12;

// ============================================================
//  Helpers
// ============================================================
task step;
    @(posedge clk_mem); #1;
endtask

task chk(input string label, input logic got, input logic expected);
    if (got !== expected) begin
        $error("FAIL [%s]  got=%b  expected=%b", label, got, expected);
        fail_count++;
    end else
        pass_count++;
endtask

task chk32(input string label, input logic [31:0] got, input logic [31:0] expected);
    if (got !== expected) begin
        $error("FAIL [%s]  got=%08h  expected=%08h", label, got, expected);
        fail_count++;
    end else
        pass_count++;
endtask

task do_reset;
    reset = 1; wb_empty = 1; mem_busy = 0; wb_data = '0;
    repeat(3) step();
    reset = 0;
    repeat(2) step();
endtask

// ============================================================
//  TEST 1: Escritura + conteo de ciclos
//  Verifica datos latched, ram_we/busy durante WRITE_CYCLES
//  ciclos exactos, y wb_ren solo un ciclo en IDLE.
// ============================================================
task automatic test_basic_write;
    int cycle_count = 0;
    logic [31:0] exp_addr  = 32'hDEAD_BEEF;
    logic [1:0]  exp_size  = 2'b10;
    logic [31:0] exp_wdata = 32'hCAFE_1234;

    $display("\n--- TEST 1: Escritura ---");
    wb_empty = 0;
    mem_busy = 0;
    wb_data  = {exp_addr, exp_size, exp_wdata};

    // IDLE: wb_ren combinacional
    #1;
    $display("  IDLE     wb_ren=%b ram_we=%b busy=%b", wb_ren, ram_we, busy);
    chk("wb_ren en IDLE", wb_ren, 1'b1);

    // Entra a WRITE
    step();
    chk32("addr  latched", ram_addr,  exp_addr);
    chk32("wdata latched", ram_wdata, exp_wdata);
    chk ("ram_we inicio", ram_we, 1'b1);
    chk ("wb_ren bajo",   wb_ren, 1'b0);
    $display("  WRITE    wb_ren=%b ram_we=%b  addr=%08h  data=%08h",
             wb_ren, ram_we, ram_addr, ram_wdata);

    // El ciclo de IDLE donde wb_ren se afirma también cuenta
    // (drain = IDLE + WRITE = 1 + 11 = 12 ciclos de clk_mem)
    cycle_count = 1;
    while (ram_we) begin
        cycle_count++;
        step();
    end

    $display("  IDLE     wb_ren=%b ram_we=%b busy=%b", wb_ren, ram_we, busy);
    $display("  --> %0d ciclos de clk_mem  (esperado: %0d)", cycle_count, WRITE_CYCLES);
    chk("ram_we=0 al salir", ram_we,  1'b0);
    chk("busy=0  al salir",  busy,    1'b0);
    if (cycle_count == WRITE_CYCLES) pass_count++;
    else begin
        $error("FAIL [ciclos]  got=%0d  expected=%0d", cycle_count, WRITE_CYCLES);
        fail_count++;
    end

    wb_empty = 1;
    step();
endtask

// ============================================================
//  TEST 2: mem_busy bloquea IDLE → WRITE
//
//  Si falla, wb_drain puede escribir mientras la RAM está en
//  uso por un burst de lectura → escritura silenciosa perdida.
// ============================================================
task test_mem_busy_blocks;
    $display("\n--- TEST 2: mem_busy bloquea IDLE ---");

    wb_empty = 0;
    mem_busy = 1;
    wb_data  = {32'hAAAA_AAAA, 2'b10, 32'hBBBB_BBBB};

    repeat(3) begin
        step();
        chk("bloqueado/wb_ren", wb_ren, 1'b0);
        chk("bloqueado/ram_we", ram_we, 1'b0);
    end
    $display("  BLOCKED  wb_ren=%b ram_we=%b  (mem_busy=1)", wb_ren, ram_we);

    mem_busy = 0; #1;
    $display("  RELEASE  wb_ren=%b  (mem_busy=0, comb)", wb_ren);
    chk("wb_ren sube al liberar", wb_ren, 1'b1);

    step();
    $display("  WRITE    wb_ren=%b ram_we=%b busy=%b", wb_ren, ram_we, busy);
    chk("ram_we arranca", ram_we, 1'b1);

    repeat(WRITE_CYCLES - 1) step();
    wb_empty = 1;
    step();
    chk("ram_we=0 al terminar", ram_we, 1'b0);
endtask

// ============================================================
//  TEST 3: Reset asíncrono detiene escritura en curso
//
//  Verifica que ram_we y busy caen sin esperar clk_mem.
// ============================================================
task test_reset_mid_write;
    $display("\n--- TEST 3: Reset asincrono a mitad de escritura ---");

    wb_empty = 0;
    mem_busy = 0;
    wb_data  = {32'hFFFF_0000, 2'b10, 32'hDEAD_DEAD};

    step(); // entra a WRITE
    repeat(WRITE_CYCLES / 2) step();
    $display("  MID-WR   ram_we=%b busy=%b  (reset va a llegar)", ram_we, busy);
    chk("ram_we antes de reset", ram_we, 1'b1);

    wb_empty = 1;  // evitar que wb_ren se afirme al volver a IDLE
    reset = 1; #1;
    $display("  RESET=1  ram_we=%b busy=%b wb_ren=%b  (asincrono, sin clk)", ram_we, busy, wb_ren);
    chk("ram_we=0 async", ram_we, 1'b0);
    chk("busy=0  async",  busy,   1'b0);
    chk("wb_ren=0 async", wb_ren, 1'b0);
    reset = 0;
    step();
endtask

// ============================================================
//  MAIN
// ============================================================
initial begin
    $dumpfile("sim/waves/tb_wb_drain.vcd");
    $dumpvars(0, tb_wb_drain);

    clk_mem = 0; reset = 1;

    do_reset();
    test_basic_write();

    do_reset();
    test_mem_busy_blocks();

    do_reset();
    test_reset_mid_write();

    #50;
    $display("\n=== DONE: %0d passed, %0d failed ===", pass_count, fail_count);
    if (fail_count != 0) $fatal(1, "TESTBENCH FAILED");
    $finish;
end

endmodule
