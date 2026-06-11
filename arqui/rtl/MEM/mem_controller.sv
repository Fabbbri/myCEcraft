// ============================================================
//  Controlador de memoria principal.
// ============================================================

module mem_controller (
    input  logic        reset,
    input  logic        clk,
    input  logic        clk_mem,

    input  logic        req,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [1:0]  size,
    input  logic [31:0] wdata,

    output logic        ram_we,
    output logic [1:0]  ram_size,
    output logic [31:0] ram_addr,
    output logic [31:0] ram_wdata,
    input  logic [31:0] ram_rdata,

    output logic        stall_mem,

    input  logic        hit_l2,
    input  logic        miss_l2,

    output logic        burst_mode,
    output logic [2:0]  burst_mode_counter,
    output logic [31:0] burst_rdata
);

// ==========================================================
//  REQUEST QUEUE  (async: escribe en clk, lee en clk_mem)
// ==========================================================
logic        rq_full;
logic        rq_empty;
logic        rq_wr_en;
logic        rq_rd_en;
logic [66:0] rq_data_in;
logic [66:0] rq_data_out;

// FIX: eliminado load_pending del guard de rq_wr_en
// El stall de pipeline (stall_l2) ya evita encolar requests duplicadas
assign rq_wr_en   = req && !rq_full;
assign rq_data_in = {we, addr, size, wdata};

async_fifo #(
    .DEPTH      (8),
    .DATA_WIDTH (67),
    .PTR_WIDTH  (3)
) request_queue (
    .wclk     (clk),
    .wrst     (reset),
    .w_en     (rq_wr_en),
    .data_in  (rq_data_in),
    .full     (rq_full),
    .rclk     (clk_mem),
    .rrst     (reset),
    .r_en     (rq_rd_en),
    .data_out (rq_data_out),
    .empty    (rq_empty)
);

logic        rq_is_write;
logic [31:0] rq_addr;
logic [1:0]  rq_size;
logic [31:0] rq_wdata;

assign rq_is_write = rq_data_out[66];
assign rq_addr     = rq_data_out[65:34];
assign rq_size     = rq_data_out[33:32];
assign rq_wdata    = rq_data_out[31:0];

logic [31:0] lat_req_addr;
logic [1:0]  lat_req_size;
logic [31:0] lat_req_wdata;

always_ff @(posedge clk_mem or posedge reset)
    if (reset) begin
        lat_req_addr  <= '0;
        lat_req_size  <= '0;
        lat_req_wdata <= '0;
    end else if (rq_rd_en) begin
        lat_req_addr  <= rq_addr;
        lat_req_size  <= rq_size;
        lat_req_wdata <= rq_wdata;
    end

// ==========================================================
//  WRITE BUFFER  (síncrono en clk_mem)
// ==========================================================
logic        wb_full;
logic        wb_empty;
logic        wb_wr_en;
logic        wb_rd_en;
logic [65:0] wb_data_in;
logic [65:0] wb_data_out;

assign wb_data_in = {lat_req_addr, lat_req_size, lat_req_wdata};

fifo #(
    .WIDTH (66),
    .DEPTH (8)
) write_buffer (
    .clk      (clk_mem),
    .reset    (reset),
    .data_in  (wb_data_in),
    .wr_en    (wb_wr_en),
    .full     (wb_full),
    .data_out (wb_data_out),
    .rd_en    (wb_rd_en),
    .empty    (wb_empty)
);

// ==========================================================
//  CONFLICT DETECTION
// ==========================================================
logic wbd_busy;
logic wb_conflict;
assign wb_conflict = !wb_empty || wbd_busy;

// ==========================================================
//  FSM
// ==========================================================
logic       rq_ren;
logic       wb_wen;
logic       burst_addr;
logic [3:0] burst_count;
logic       rd_valid;
logic       burst_active;
logic [2:0] fsm_debug;

fsm_memory FSM (
    .clk_mem     (clk_mem),
    .reset       (reset),
    .rq_full     (rq_full),
    .rq_empty    (rq_empty),
    .wb_full     (wb_full),
    .wb_empty    (!wbd_busy),
    .wb_conflict (wb_conflict),
    .is_write    (rq_is_write),
    .hit_l2      (hit_l2),
    .miss_l2     (miss_l2),
    .rq_ren      (rq_ren),
    .wb_wen      (wb_wen),
    .burst_addr  (burst_addr),
    .burst_count (burst_count),
    .rd_valid    (rd_valid),
    .burst_active(burst_active),
    .debug       (fsm_debug)
);

assign rq_rd_en = rq_ren;
assign wb_wr_en = wb_wen;

// ==========================================================
//  WB DRAIN
// ==========================================================
logic        wbd_we;
logic [1:0]  wbd_size;
logic [31:0] wbd_wdata;
logic [31:0] wbd_addr;

wb_drain WB_DRAIN (
    .clk_mem  (clk_mem),
    .reset    (reset),
    .wb_empty (wb_empty),
    .wb_data  (wb_data_out),
    .wb_ren   (wb_rd_en),
    .mem_busy (burst_active),
    .ram_we   (wbd_we),
    .ram_addr (wbd_addr),
    .ram_size (wbd_size),
    .ram_wdata(wbd_wdata),
    .busy     (wbd_busy)
);

// ==========================================================
//  MUX → data_ram
// ==========================================================
always_comb
    if (burst_addr)
        // base de LINEA (32B alineada): el burst debe traer la linea
        // completa, no 8 palabras desde la direccion del load
        ram_addr = {lat_req_addr[31:5], 5'b00000} + (burst_count << 2);
    else
        ram_addr = wbd_addr;

assign ram_size  = burst_addr ? lat_req_size  : wbd_size;
assign ram_wdata = burst_addr ? lat_req_wdata : wbd_wdata;
assign ram_we    = !burst_addr && wbd_we;

// ==========================================================
//  Salidas burst hacia l2_con
// ==========================================================
assign burst_mode         = burst_active;
assign burst_mode_counter = burst_count[2:0];
assign burst_rdata        = burst_active ? ram_rdata : 32'b0;

// ==========================================================
//  Stall → pipeline
//  FIX: eliminado load_pending. El stall del pipeline lo maneja
//  stall_l2 (load_state==ACCESS en l2_con). Aquí solo stalleamos
//  si las colas están llenas (backpressure real).
// ==========================================================
assign stall_mem = rq_full | wb_full;

endmodule