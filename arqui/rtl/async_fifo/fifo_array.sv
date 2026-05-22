// ================================================
// Storage interno del async_fifo
// Array de DEPTH registros de DATA_WIDTH bits
// Escritura: síncrona a wclk en fifo[b_wptr]
// Lectura : combinacional desde fifo[b_rptr]
// ================================================

module fifo_array #(parameter DEPTH = 4, parameter DATA_WIDTH = 32, parameter PTR_WIDTH  = 2)(
    input logic wclk, w_en,
    input logic rclk, r_en,
    input logic [PTR_WIDTH:0] b_wptr, b_rptr,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic full, empty,
    output logic [DATA_WIDTH-1:0] data_out
);
    // ESTO ES EL ARRAY
    logic [DATA_WIDTH-1:0] fifo [0:DEPTH-1];

    // wclk escribe en la posición que apunta b_wptr
    logic [PTR_WIDTH-1:0] waddr;
    assign waddr = b_wptr[PTR_WIDTH-1:0];

    always_ff @(posedge wclk) begin
        if (w_en && !full) begin
            fifo[waddr] <= data_in;
        end
    end

    // rclk lee de la posición que apunta b_rptr
    // lectura combinacional
    assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]];

endmodule