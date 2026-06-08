// ============================================================
//  write_buffer.sv
//  Buffer de stores hacia L2 y memoria
//  Los stores llegan aquí directamente desde el pipeline
//  Se drenan en background cuando no hay refill activo
//  Instanciado desde l2_con
// ============================================================

module write_buffer #(
    parameter int DEPTH = 8
)(
    input  logic        clk,
    input  logic        reset,

    // Push (store llega desde pipeline via l2_con)
    input  logic        push,
    input  logic [31:0] addr_in,
    input  logic [31:0] wdata_in,
    input  logic [1:0]  size_in,

    // Pop (cuando WB_COMMIT completa el drain)
    input  logic        pop,

    // Cabeza del buffer (combinacional)
    output logic [31:0] addr_out,
    output logic [31:0] wdata_out,
    output logic [1:0]  size_out,

    // Estado
    output logic        full,
    output logic        empty
);

    // Empaquetar entrada: { addr(32), wdata(32), size(2) } = 66 bits
    localparam int DATA_W = 66;

    logic [DATA_W-1:0] din, dout;
    assign din = {addr_in, wdata_in, size_in};

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

    assign addr_out  = dout[65:34];
    assign wdata_out = dout[33:2];
    assign size_out  = dout[1:0];

endmodule