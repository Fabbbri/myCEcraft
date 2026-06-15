`timescale 1ns/1ps

module tb_async_fifo;

parameter DATA_WIDTH = 67;
parameter DEPTH = 4;
parameter PTR_WIDTH = 2;

logic [DATA_WIDTH-1:0] data_out;
logic full, empty;
logic [DATA_WIDTH-1:0] data_in;
logic w_en, wclk, wrst;
logic r_en, rclk, rrst;

always #5  wclk = ~wclk;
always #10 rclk = ~rclk;

async_fifo #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .PTR_WIDTH(PTR_WIDTH)
) dut (
    .wclk(wclk), .wrst(wrst), .w_en(w_en),
    .data_in(data_in), .full(full),
    .rclk(rclk), .rrst(rrst), .r_en(r_en),
    .data_out(data_out), .empty(empty)
);

task write_one(input logic [DATA_WIDTH-1:0] d);
    @(posedge wclk);
    data_in = d;
    w_en = 1;
    @(posedge wclk);
    w_en  = 0;
    repeat(6) @(posedge rclk);
    $display("T=%0t | WRITE | we=%b size=%02b addr=%h wdata=%h | full=%b",
             $time, d[66], d[65:64], d[63:32], d[31:0], full);
endtask

task read_one;
    logic [DATA_WIDTH-1:0] rd_data;
    @(posedge rclk);
    rd_data = data_out;
    r_en = 1;
    @(posedge rclk);
    r_en = 0;
    repeat(3) @(posedge wclk);
    @(posedge rclk);
    $display("T=%0t | READ  | we=%b size=%02b addr=%h wdata=%h | empty=%b",
             $time, rd_data[66], rd_data[65:64], rd_data[63:32], rd_data[31:0], empty);
endtask

initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars(0, tb_async_fifo);

    wclk = 0; rclk = 0;
    wrst = 1; rrst = 1;
    w_en = 0; r_en = 0;
    data_in = 0;

    // reset escalonado — primero suelta wclk, luego rclk
    repeat(20) @(posedge wclk);
    repeat(20) @(posedge rclk);
    wrst = 0;
    repeat(5) @(posedge rclk);
    rrst = 0;
    repeat(5) @(posedge rclk);

    // --- escribir 1 dato y leer ---
    $display("\n--- Escribir LW y leer ---");
    write_one({1'b0, 2'b10, 32'h0000_1000, 32'h0000_0000});
    read_one;

    // --- llenar FIFO ---
    $display("\n--- Escribir FIFO (4 entradas) ---");
    write_one({1'b1, 2'b10, 32'h0000_2000, 32'hDDDD_BFBF});
    write_one({1'b0, 2'b00, 32'h0000_3004, 32'h0000_0000});
    write_one({1'b1, 2'b00, 32'h0000_4008, 32'h0000_00FF});
    write_one({1'b0, 2'b10, 32'hCCBF_0000, 32'h0000_0000});
    $display("T=%0t | full=%b (debe ser 1)", $time, full);

    // --- leer todo ---
    $display("\n--- Leer los 4 datos ---");
    read_one;
    read_one;
    read_one;
    read_one;
    $display("T=%0t | empty=%b (debe ser 1)", $time, empty);


    #50;
    $finish;
end

endmodule