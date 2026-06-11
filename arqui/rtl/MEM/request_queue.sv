// ============================================================
//  request_queue.sv
//  Cola de requests de LOAD hacia L2
//  Los stores NO entran aquí, van directo al write_buffer
//  Instanciado desde l2_con
// ============================================================

module request_queue #(
    parameter int DEPTH = 8
)(
    input  logic        clk,
    input  logic        reset,

    // Enqueue (desde l2_con, solo loads)
    input  logic        push,
    input  logic [31:0] addr_in,
    input  logic [1:0]  size_in,

    // Dequeue
    input  logic        pop,

    // Cabeza de la cola
    output logic [31:0] addr_out,
    output logic [1:0]  size_out,

    // Estado
    output logic        full,
    output logic        empty
);

    // Empaquetar entrada: { addr(32), size(2) } = 34 bits
    localparam int DATA_W = 34;

    logic [DATA_W-1:0] din, dout;
    assign din = {addr_in, size_in};

    sync_fifo #(
        .DATA_WIDTH (DATA_W),
        .DEPTH      (DEPTH)
    ) fifo (
        .clk   (clk),
        .reset (reset),
        .push  (push),
        .din   (din),
        .pop   (pop),
        .dout  (dout),
        .full  (full),
        .empty (empty)
    );

    assign addr_out = dout[33:2];
    assign size_out = dout[1:0];

endmodule