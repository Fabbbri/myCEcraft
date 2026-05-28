// ============================================================
//  Controlador de memoria principal.
// ============================================================

module mem_controller (
    input logic reset,
    input logic clk,      // 100 MHz - pipeline
    input logic clk_mem,  //  50 MHz - FSM y RAM

    // entrada desde el pipeline
    input logic req,
    input logic we,
    input logic [31:0] addr,
    input logic [1:0] size,
    input logic [31:0] wdata,

    // interfaz con data_ram
    output logic ram_we,
    output logic [1:0]  ram_size,
    output logic [31:0] ram_addr,
    output logic [31:0] ram_wdata,

    // stall -> hazard unit
    output logic stall_mem
);

// ==========================================================
//                  REQUEST QUEUE
//  { we[0], addr[31:0], size[1:0], wdata[31:0] } = 67 bits
//  escribe en clk (pipeline), lee en clk_mem (FSM)
// ==========================================================
logic rq_full;
logic rq_empty;
logic rq_wr_en;
logic rq_rd_en;
logic [66:0] rq_data_in;
logic [66:0] rq_data_out;

logic load_pending;

assign rq_wr_en = req && !rq_full && !load_pending;
assign rq_data_in = {we, addr, size, wdata};

async_fifo #(.DEPTH (8), .DATA_WIDTH (67), .PTR_WIDTH  (3)) request_queue (
    .wclk (clk),
    .wrst (reset),
    .w_en (rq_wr_en),
    .data_in (rq_data_in),
    .full (rq_full),
    .rclk (clk_mem),
    .rrst (reset),
    .r_en (rq_rd_en),
    .data_out(rq_data_out),
    .empty (rq_empty)
);

logic rq_is_write;
logic [31:0] rq_addr;
logic [1:0] rq_size;
logic [31:0] rq_wdata;

assign rq_is_write = rq_data_out[66];
assign rq_addr = rq_data_out[65:34];
assign rq_size = rq_data_out[33:32];
assign rq_wdata  = rq_data_out[31:0];

// Latch activo en clk_mem - captura la request ANTES de que b_rptr avance
logic [31:0] lat_req_addr;
logic [1:0]  lat_req_size;
logic [31:0] lat_req_wdata;

always_ff @(posedge clk_mem or posedge reset)
    if (reset) begin
        lat_req_addr <= '0;
        lat_req_size <= '0;
        lat_req_wdata <= '0;
    end else if (rq_rd_en) begin
        lat_req_addr <= rq_addr;
        lat_req_size <= rq_size;
        lat_req_wdata <= rq_wdata;
    end

// ==========================================================
//                  WRITE BUFFER
//  { addr[31:0], size[1:0], wdata[31:0] } = 66 bits
//  síncrona en clk_mem - FSM escribe, wb_drain drena
// ==========================================================
logic wb_full;
logic wb_empty;
logic wb_wr_en;
logic wb_rd_en;
logic [65:0] wb_data_in;
logic [65:0] wb_data_out;

assign wb_data_in = {lat_req_addr, lat_req_size, lat_req_wdata};

fifo #(.WIDTH (66), .DEPTH (8)) write_buffer (
    .clk (clk_mem),
    .reset (reset),
    .data_in (wb_data_in),
    .wr_en (wb_wr_en),
    .full (wb_full),
    .data_out(wb_data_out),
    .rd_en (wb_rd_en),
    .empty (wb_empty)
);

// ==========================================================
//                  CONFLICT DETECTION
// LW espera si hay escrituras pendientes en el Write Buffer o si el drain
// está activo en la zona del burst [rq_addr, rq_addr + BURST_BYTES).
// ==========================================================
logic wbd_busy;
logic wb_conflict;
assign wb_conflict = !wb_empty || wbd_busy;

// ==========================================================
//                       FSM
// ==========================================================
logic rq_ren;
logic wb_wen;
logic burst_addr;
logic [3:0] burst_count;
logic rd_valid;
logic burst_active;
logic [2:0] fsm_debug;

fsm_memory FSM (
    .clk_mem (clk_mem),
    .reset (reset),
    .rq_full (rq_full),
    .rq_empty (rq_empty),
    .wb_full (wb_full),
    .wb_empty (!wbd_busy),   
    .wb_conflict (wb_conflict),
    .is_write (rq_is_write),
    .rq_ren (rq_ren),
    .wb_wen (wb_wen),
    .burst_addr (burst_addr),
    .burst_count (burst_count),
    .rd_valid (rd_valid),
    .burst_active(burst_active),
    .debug (fsm_debug)
);

assign rq_rd_en = rq_ren;
assign wb_wr_en = wb_wen;

// ==========================================================
//                  WB DRAIN
//  Drena el write buffer a RAM 
//  Se bloquea cuando burst_active=1 (memoria en uso).
// ==========================================================
logic wbd_we;
logic [1:0] wbd_size;
logic [31:0] wbd_wdata;
logic [31:0] wbd_addr;

wb_drain WB_DRAIN (
    .clk_mem (clk_mem),
    .reset (reset),
    .wb_empty (wb_empty),
    .wb_data (wb_data_out),
    .wb_ren (wb_rd_en),
    .mem_busy (burst_active),
    .ram_we (wbd_we),
    .ram_addr (wbd_addr),
    .ram_size (wbd_size),
    .ram_wdata (wbd_wdata),
    .busy (wbd_busy)
);

// ==========================================================
//                  MUX -> data_ram
//  Burst de lectura tiene prioridad sobre el drain de escritura
// ==========================================================
always_comb
    if (burst_addr)
        ram_addr = lat_req_addr + (burst_count << 2);
    else
        ram_addr = wbd_addr;

assign ram_size = burst_addr ? lat_req_size : wbd_size;
assign ram_wdata = burst_addr ? lat_req_wdata : wbd_wdata;
assign ram_we = !burst_addr && wbd_we;

// ==========================================================
//                  Load pending
//  load_pending_next: es 1 al encolar un read (LW), baja cuando
//  burst_addr && burst_count==0 indica que el dato ya está listo
//  en rMemData (data_ram es combinacional).
//
//  stall_mem usa load_pending_next para stalllar en el mismo ciclo que se
//  encola la lectura, evitando que el LW avance a Write Back sin dato.
// ==========================================================
logic load_pending_next;
assign load_pending_next = (rq_wr_en && !rq_data_in[66]) ? 1'b1 :
                           (burst_addr && burst_count == '0) ? 1'b0 : load_pending;

always_ff @(posedge clk or posedge reset)
    if (reset) load_pending <= 1'b0;
    else  load_pending <= load_pending_next;

// ==========================================================
//                  Stall -> pipeline
// ==========================================================
assign stall_mem = rq_full | wb_full | load_pending_next;

endmodule
