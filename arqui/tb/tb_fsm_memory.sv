`timescale 1ns/1ps

module tb_fsm_memory;

// ============================================================
//  Señales
// ============================================================
logic clk_mem, reset;
logic rq_full, rq_empty;
logic wb_full, wb_empty;
logic wb_conflict;
logic is_write;
logic rq_ren, wb_wen, burst_addr, burst_active;
logic [3:0] burst_count;
logic rd_valid;
logic [2:0] debug;

int pass_count = 0;
int fail_count = 0;

// ============================================================
//  Reloj 50 MHz
// ============================================================
always #10 clk_mem = ~clk_mem;

// ============================================================
//  DUT
// ============================================================
fsm_memory dut (
    .clk_mem (clk_mem),
    .reset (reset),
    .rq_full (rq_full),
    .rq_empty (rq_empty),
    .wb_full  (wb_full),
    .wb_empty (wb_empty),   
    .wb_conflict (wb_conflict),
    .is_write (is_write),
    .rq_ren (rq_ren),
    .wb_wen (wb_wen),
    .burst_addr (burst_addr),
    .burst_count (burst_count),
    .rd_valid (rd_valid),
    .burst_active(burst_active),
    .debug (debug)
);

// ============================================================
//  Localparams
// ============================================================
localparam BURST_LEN = 8;
localparam PROC_WAIT = 2;

// ============================================================
//  Helpers
// ===========================================================
function automatic string state_name(input logic [2:0] s);
    case (s)
        3'd0: state_name = "INIT";
        3'd2: state_name = "REQUEST";
        3'd3: state_name = "ENQUEUE_WRITE";
        3'd4: state_name = "BURST";
        3'd5: state_name = "WAIT_PROC";
        default: state_name = "UNKNOWN";
    endcase
endfunction

task print;
    $display("T=%0t | state=%s | rq_ren=%b wb_wen=%b burst_active=%b rd_valid=%b burst_count=%0d",
        $time, state_name(debug), rq_ren, wb_wen, burst_active, rd_valid, burst_count);
endtask

task chk(input string label, input logic got, input logic expected);
    if (got !== expected) begin
        $error("FAIL [%s] T=%0t got=%b expected=%b", label, $time, got, expected);
        fail_count++;
    end
    else begin
        pass_count++;
    end
endtask

task do_reset;
    reset = 1;
    repeat(4) @(posedge clk_mem);
    reset = 0;
    repeat(2) @(posedge clk_mem);
endtask

// ============================================================
//  TEST 1: READ
// ============================================================
task test_read;
    rq_empty = 0;
    rq_full = 0;
    is_write = 0;
    wb_empty = 1;
    wb_full = 0;
    wb_conflict = 0;

    // ========================================================
    // REQUEST
    // ========================================================
    @(posedge clk_mem); 
        #1;
    print();
    chk("T1 REQUEST/rq_ren", rq_ren, 1'b1);
    chk("T1 REQUEST/wb_wen", wb_wen, 1'b0);
    chk("T1 REQUEST/burst_active", burst_active, 1'b0);
    chk("T1 REQUEST/rd_valid", rd_valid, 1'b0);

    // ========================================================
    // BURST
    // ========================================================
    @(posedge clk_mem); 
    #1;
    print();
    chk("T1 BURST/burst_active", burst_active, 1'b1);
    chk("T1 BURST/rd_valid", rd_valid, 1'b1);
    chk("T1 BURST/rq_ren", rq_ren, 1'b0);
    chk("T1 BURST/wb_wen", wb_wen, 1'b0);

    // ========================================================
    // resto de burst cycles
    // ========================================================
    repeat(BURST_LEN-1) begin
        @(posedge clk_mem); 
    #1;
        print();
        chk("T1 BURST_LOOP/burst_active", burst_active, 1'b1);
        chk("T1 BURST_LOOP/rd_valid", rd_valid, 1'b1);
        chk("T1 BURST_LOOP/rq_ren", rq_ren, 1'b0);
        chk("T1 BURST_LOOP/wb_wen", wb_wen, 1'b0);
    end

    // ========================================================
    // WAIT_PROC
    // ========================================================
    repeat(PROC_WAIT) begin
        @(posedge clk_mem); 
    #1;
        print();
        chk("T1 WAIT/rd_valid", rd_valid, 1'b1);
        chk("T1 WAIT/burst_active", burst_active, 1'b0);
        chk("T1 WAIT/rq_ren", rq_ren, 1'b0);
        chk("T1 WAIT/wb_wen", wb_wen, 1'b0);
    end

    // ========================================================
    // INIT
    // ========================================================
    rq_empty = 1;
    @(posedge clk_mem); 
    #1;
    print();

    chk("T1 INIT/rd_valid", rd_valid, 1'b0);
    chk("T1 INIT/burst_active", burst_active, 1'b0);
    chk("T1 INIT/rq_ren", rq_ren, 1'b0);
endtask

// ============================================================
//  TEST 2: WRITE
// ============================================================
task test_write;

    rq_empty = 0;
    rq_full = 0;
    is_write = 1;
    wb_empty = 0;
    wb_full = 0;
    wb_conflict = 0;
    // REQUEST
    @(posedge clk_mem); 
    #1;
    print();
    chk("T2 REQUEST/rq_ren", rq_ren, 1'b1);
    // ENQUEUE_WRITE
    @(posedge clk_mem); 
    #1;
    print();
    chk("T2 ENQUEUE/wb_wen", wb_wen, 1'b1);
    chk("T2 ENQUEUE/rq_ren", rq_ren, 1'b0);
    chk("T2 ENQUEUE/burst_active", burst_active, 1'b0);
    chk("T2 ENQUEUE/rd_valid", rd_valid, 1'b0);
    // INIT
    @(posedge clk_mem); 
    #1;
    print();
    chk("T2 INIT/wb_wen", wb_wen, 1'b0);
    chk("T2 INIT/rq_ren", rq_ren, 1'b0);
    rq_empty = 1;
    wb_empty = 1;
endtask

// ============================================================
//  TEST 3: wb_full stall
// ============================================================
task test_stall_wb;

    rq_empty = 0;
    rq_full = 0;
    is_write = 1;
    wb_full = 1;
    wb_empty = 0;
    wb_conflict = 0;

    // REQUEST stall
    repeat(3) begin
        @(posedge clk_mem); 
    #1;
        print();

        chk("T3 STALL/rq_ren", rq_ren, 1'b0);
        chk("T3 STALL/wb_wen", wb_wen, 1'b0);
        chk("T3 STALL/burst_active", burst_active, 1'b0);
    end

    // release wb
    wb_full  = 0;
    wb_empty = 1;
    // ENQUEUE_WRITE
    @(posedge clk_mem); 
    #1;
    print();
    chk("T3 ENQUEUE/wb_wen", wb_wen, 1'b1);
    chk("T3 ENQUEUE/rq_ren", rq_ren, 1'b0);
    // INIT
    @(posedge clk_mem); 
    #1;
    print();
    chk("T3 INIT/wb_wen", wb_wen, 1'b0);
    rq_empty = 1;

endtask

// ============================================================
//  TEST 4: READ blocked in INIT while wb_full=1
// ============================================================
task test_read_stall_init;

    rq_empty = 0;
    rq_full  = 0;
    is_write  = 0;
    wb_empty  = 1;
    wb_full = 1;   // WB lleno -> stall incluso para reads
    wb_conflict = 0;

    // INIT stall (wb lleno)
    repeat(3) begin
        @(posedge clk_mem);
    #1;
        print();
        chk("T4 INIT_STALL/rq_ren", rq_ren, 1'b0);
        chk("T4 INIT_STALL/burst_active", burst_active, 1'b0);
        chk("T4 INIT_STALL/rd_valid", rd_valid,  1'b0);
    end

    // WB drena
    wb_full = 0;
    // REQUEST
    @(posedge clk_mem);
    #1;
    print();

    chk("T4 REQUEST/rq_ren", rq_ren,  1'b1);
    chk("T4 REQUEST/burst_active", burst_active, 1'b0);
    chk("T4 REQUEST/rd_valid", rd_valid, 1'b0);

    rq_empty = 1;

    repeat(BURST_LEN + PROC_WAIT + 3)
        @(posedge clk_mem);
    #1;
endtask



// ============================================================
//  TEST 5: RESET during BURST
// ============================================================
task test_reset_mid_burst;

    rq_empty = 0;
    rq_full  = 0;
    is_write = 0;
    wb_empty = 1;
    wb_full  = 0;
    wb_conflict = 0;

    // REQUEST
    @(posedge clk_mem); 
    #1;
    // BURST
    @(posedge clk_mem); 
    #1;
    repeat(3)
    @(posedge clk_mem); 
    #1;

    $display("=== MID BURST ===");
    print();

    chk("T5 MID/burst_active", burst_active, 1'b1);
    chk("T5 MID/rd_valid",rd_valid, 1'b1);

    // async reset
    reset = 1;
        #1;
    reset = 0;
    rq_empty = 1;

    @(posedge clk_mem); 
    #1;

    $display("=== POST RESET ===");
    print();

    chk("T5 RESET/burst_active", burst_active, 1'b0);
    chk("T5 RESET/rd_valid", rd_valid, 1'b0);
    chk("T5 RESET/rq_ren", rq_ren, 1'b0);
    chk("T5 RESET/wb_wen", wb_wen,  1'b0);
endtask

// ============================================================
//  MAIN
// ============================================================
initial begin

    $dumpfile("fsm_memory.vcd");
    $dumpvars(0, tb_fsm_memory);

    clk_mem = 0;
    reset  = 1;
    rq_full = 0;
    rq_empty = 1;
    wb_full = 0;
    wb_empty = 1;
    wb_conflict = 0;
    is_write = 0;

    do_reset();

    $display("\n=== TEST 1: READ ===");
    test_read();

    repeat(2) @(posedge clk_mem); 
    #1;

    $display("\n=== TEST 2: WRITE ===");
    test_write();

    repeat(2) @(posedge clk_mem); 
    #1;

    $display("\n=== TEST 3: WB STALL ===");
    test_stall_wb();

    repeat(2) @(posedge clk_mem); 
    #1;

    $display("\n=== TEST 4: READ INIT STALL ===");
    test_read_stall_init();

    repeat(2) @(posedge clk_mem); 
    #1;

    $display("\n=== TEST 5: RESET MID BURST ===");
    test_reset_mid_burst();

    repeat(2) @(posedge clk_mem);
    #1;

    #50;

    $display(
        "\n=== DONE: %0d passed, %0d failed ===",
        pass_count,
        fail_count
    );

    if (fail_count != 0)
        $fatal(1, "TESTBENCH FAILED");

    $finish;
end

endmodule