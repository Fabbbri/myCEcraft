// ================================================
// FIFO asíncrono con cruce de dominio
// de reloj (CDC) entre clk_proc (100MHz)
// y clk_mem (50MHz). 
// ================================================

module async_fifo #(parameter DEPTH = 4, parameter DATA_WIDTH = 67, parameter PTR_WIDTH = 2)(
    // write side - clk_proc 100MHz
    input logic wclk, wrst,
    input logic w_en,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic full,

    // read side - clk_mem 50MHz
    input logic rclk, rrst,
    input logic r_en,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic empty
);
// punteros Gray que cruzan CDC entre dominios
logic [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
// punteros binarios y Gray en sus dominios
logic [PTR_WIDTH:0] b_wptr, g_wptr;
logic [PTR_WIDTH:0] b_rptr, g_rptr;

// ==========================================================
//                    SYNCHRONIZER
//          sync wptr -> rclk (para calcular empty)
// ==========================================================

synchronizer #(PTR_WIDTH) sync_wptr (
    .clk(rclk), 
    .reset(rrst),
    .d_in(g_wptr),
    .d_out(g_wptr_sync)
);

// ==========================================================
//                    SYNCHRONIZER
//        sync rptr -> wclk (para calcular full)
// ==========================================================

synchronizer #(PTR_WIDTH) sync_rptr (
    .clk(wclk), 
    .reset(wrst),
    .d_in(g_rptr),
    .d_out(g_rptr_sync)
);

// ==========================================================
//                Write pointer handler
// ==========================================================

// genera b_wptr, g_wptr y full - dominio wclk
wptr_handler #(PTR_WIDTH) wptr_h (
    .wclk(wclk), 
    .reset(wrst), 
    .w_en(w_en),
    .g_rptr_sync(g_rptr_sync),
    .b_wptr(b_wptr), 
    .g_wptr(g_wptr),
    .full(full)
);

// ==========================================================
//                Read pointer handler
// ==========================================================

// genera b_rptr, g_rptr y empty - dominio rclk
rptr_handler #(PTR_WIDTH) rptr_h (
    .rclk(rclk), 
    .reset(rrst), 
    .r_en(r_en),
    .g_wptr_sync(g_wptr_sync),
    .b_rptr(b_rptr), 
    .g_rptr(g_rptr),
    .empty(empty)
);

// ==========================================================
//                     FIFO Array
// ==========================================================

// wclk escribe en fifo[b_wptr], rclk lee de fifo[b_rptr]
fifo_array #(DEPTH, DATA_WIDTH, PTR_WIDTH) fifom (
    .wclk(wclk), 
    .w_en(w_en),
    .rclk(rclk), 
    .r_en(r_en),
    .b_wptr(b_wptr), 
    .b_rptr(b_rptr),
    .data_in(data_in),
    .full(full), 
    .empty(empty),
    .data_out(data_out)
);

endmodule