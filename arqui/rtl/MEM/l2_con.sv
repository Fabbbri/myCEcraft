// ============================================================
//  l2_con.sv
//  Controlador de caché L2
//
//  FSM Load:       IDLE → ACCESS (8 ciclos) → DONE
//  FSM WB Drain:   WB_IDLE → WB_DRAIN (7 ciclos) → WB_COMMIT
//
//  Stores: bypass request_queue → van directo al write_buffer
//  Loads:  entran a request_queue → procesados por FSM Load
//
//  WB_DRAIN bloqueado mientras FSM Load está en ACCESS
//  (compilador garantiza no RAW, hardware solo evita colisión con refill)
//
//  fill_line se acumula internamente desde burst_rdata + burst_counter
//  (ya no llega como input externo)
// ============================================================

module l2_con (
    input  logic        clk,
    input  logic        reset,

    // Desde l1_con
    input  logic        is_write,
    input  logic        miss_l1,
    input  logic        hit_l1,
    input  logic [31:0] addr,
    input  logic [1:0]  size,
    input  logic [31:0] wdata,

    // Burst desde mem_controller
    // fill_line ya NO es input: se acumula aquí con burst_rdata
    input  logic [2:0]  burst_counter,  // índice de palabra [0..7]
    input  logic        burst_active,   // 1 durante burst de lectura
    input  logic [31:0] burst_rdata,    // palabra actual de data_ram

    // Desde l2_cache: lectura
    input  logic        hit_l2,
    input  logic [31:0] l2_data_out,

    // Desde l2_cache: hit evaluado con dirección del write buffer head
    input  logic        hit_l2_wb,

    // Hacia l2_cache: fill
    output logic         fill_en,
    output logic [1:0]   fill_way_out,
    output logic [6:0]   fill_set,
    output logic [19:0]  fill_tag,
    output logic [255:0] fill_line_out,

    // Hacia l2_cache: invalidacion (load miss antes del refill)
    output logic        inv_en,
    output logic [1:0]  inv_way,
    output logic [6:0]  inv_set,

    // Hacia l2_cache: store write-through (desde WB drain)
    output logic        store_en,
    output logic [31:0] store_addr_out,
    output logic [31:0] store_data_out,

    // Hacia CPU/pipeline
    output logic [31:0] dato_cpu,
    output logic        stall,

    // Hacia mem_con: loads
    output logic        miss_l2_out,
    output logic        hit_l2_out,
    output logic [31:0] addr_out,
    output logic [1:0]  size_out,

    // Hacia mem_con: write-through (WB drain completado)
    output logic        wb_write_out,
    output logic [31:0] wb_addr_out,
    output logic [31:0] wb_data_out,
    output logic [1:0]  wb_size_out
);

// ==========================================================
// Address breakdown (L2)
// addr[31:12] = tag  (20 bits)
// addr[11:5]  = set  (7 bits)
// addr[4:2]   = word (3 bits)
// addr[1:0]   = byte offset (ignorado)
// ==========================================================
logic [19:0] addr_tag;
logic [6:0]  addr_set;

assign addr_tag = addr[31:12];
assign addr_set = addr[11:5];

// ==========================================================
// WayReg: FIFO de reemplazo (128 sets, 4-way)
// active_set: mux entre addr_set (load) y wb_addr[11:5] (store drain)
// ==========================================================
logic [1:0] way_to_fill;
logic       way_replace;
logic [6:0] active_set;

// Declaraciones adelantadas necesarias para el mux
logic [31:0] wb_addr;
wb_state_t   wb_state; // forward declaration resuelta abajo

always_comb begin
    if (wb_state == WB_COMMIT)
        active_set = wb_addr[11:5];
    else
        active_set = addr_set;
end

set_reg #(
    .NUM_SETS (128),
    .NUM_WAYS (4)
) WayReg (
    .clk     (clk),
    .reset   (reset),
    .set     (active_set),
    .fill_en (way_replace),
    .way_out (way_to_fill)
);

// ==========================================================
// Request Queue: solo loads (miss_l1 & ~is_write)
// ==========================================================
logic        rq_push, rq_pop;
logic        rq_full, rq_empty;
logic [31:0] rq_addr;
logic [1:0]  rq_size;

request_queue #(
    .DEPTH (8)
) RQ (
    .clk      (clk),
    .reset    (reset),
    .push     (rq_push),
    .addr_in  (addr),
    .size_in  (size),
    .pop      (rq_pop),
    .addr_out (rq_addr),
    .size_out (rq_size),
    .full     (rq_full),
    .empty    (rq_empty)
);

assign rq_push = miss_l1 & ~is_write & ~rq_full;

// ==========================================================
// Write Buffer: stores llegan aquí directamente (bypass RQ)
// ==========================================================
logic        wb_push, wb_pop;
logic        wb_full, wb_empty;
logic [31:0] wb_wdata;
logic [1:0]  wb_size;

write_buffer #(
    .DEPTH (8)
) WB (
    .clk       (clk),
    .reset     (reset),
    .push      (wb_push),
    .addr_in   (addr),
    .wdata_in  (wdata),
    .size_in   (size),
    .pop       (wb_pop),
    .addr_out  (wb_addr),
    .wdata_out (wb_wdata),
    .size_out  (wb_size),
    .full      (wb_full),
    .empty     (wb_empty)
);

assign wb_push = miss_l1 & is_write & ~wb_full;

// ==========================================================
// Acumulador de fill_line desde burst_rdata
//
// En cada ciclo que burst_active=1, mem_controller pone en
// burst_rdata la palabra indexada por burst_counter.
// Se captura aquí y se arma la línea de 256 bits.
// Al ciclo burst_counter==7 la línea está completa y fill_en
// la escribe en l2_cache.
// ==========================================================
logic [255:0] fill_line_reg;

always_ff @(posedge clk) begin
    if (burst_active)
        fill_line_reg[burst_counter*32 +: 32] <= burst_rdata;
end

// ==========================================================
// FSM Load: IDLE → ACCESS (8 ciclos) → DONE
// ==========================================================
typedef enum logic [1:0] {
    IDLE   = 2'b00,
    ACCESS = 2'b01,
    DONE   = 2'b10
} load_state_t;

load_state_t load_state, load_next;
logic [3:0]  load_cnt;

always_ff @(posedge clk) begin
    if (reset) begin
        load_state <= IDLE;
        load_cnt   <= '0;
    end else begin
        load_state <= load_next;
        if (load_state == ACCESS)
            load_cnt <= load_cnt + 1'b1;
        else
            load_cnt <= '0;
    end
end

always_comb begin
    load_next = load_state;
    case (load_state)
        IDLE:    if (!rq_empty)          load_next = ACCESS;
        ACCESS:  if (load_cnt == 4'd7)   load_next = DONE;
        DONE:                            load_next = IDLE;
        default:                         load_next = IDLE;
    endcase
end

assign rq_pop = (load_state == DONE);

// ==========================================================
// FSM Write Buffer Drain: WB_IDLE → WB_DRAIN (7 ciclos) → WB_COMMIT
// Bloqueada mientras load_state == ACCESS
// ==========================================================
typedef enum logic [1:0] {
    WB_IDLE   = 2'b00,
    WB_DRAIN  = 2'b01,
    WB_COMMIT = 2'b10
} wb_state_t;

wb_state_t wb_next;
logic [2:0] wb_cnt;

always_ff @(posedge clk) begin
    if (reset) begin
        wb_state <= WB_IDLE;
        wb_cnt   <= '0;
    end else begin
        wb_state <= wb_next;
        if (wb_state == WB_DRAIN)
            wb_cnt <= wb_cnt + 1'b1;
        else
            wb_cnt <= '0;
    end
end

always_comb begin
    wb_next = wb_state;
    case (wb_state)
        WB_IDLE:  if (!wb_empty && (load_state != ACCESS) && ~fill_en)
                      wb_next = WB_DRAIN;
        WB_DRAIN: if (wb_cnt == 3'd6)
                      wb_next = WB_COMMIT;
        WB_COMMIT:    wb_next = WB_IDLE;
        default:      wb_next = WB_IDLE;
    endcase
end

assign wb_pop = (wb_state == WB_COMMIT);

// ==========================================================
// Señales hacia l2_cache
// ==========================================================

// Fill: al final del burst (counter==7) en load miss
// fill_line_reg ya tiene la línea completa en ese ciclo
assign fill_en       = (burst_counter == 3'b111) & burst_active & ~hit_l2;
assign fill_way_out  = way_to_fill;
assign fill_set      = rq_addr[11:5];   // set de la request que disparó el burst
assign fill_tag      = rq_addr[31:12];  // tag de la request
assign fill_line_out = fill_line_reg;

// WayReg avanza en refill o store hit
assign way_replace = fill_en
                   | (wb_state == WB_COMMIT & hit_l2_wb);

// Invalidación: load miss al inicio del acceso (un ciclo)
assign inv_en  = (load_state == IDLE) & ~rq_empty & ~hit_l2;
assign inv_way = way_to_fill;
assign inv_set = rq_addr[11:5];

// Store write-through: solo si hit en L2
assign store_en       = (wb_state == WB_COMMIT) & hit_l2_wb;
assign store_addr_out = wb_addr;
assign store_data_out = wb_wdata;

// ==========================================================
// Hacia CPU/pipeline
// ==========================================================
assign dato_cpu = l2_data_out;
assign stall    = (load_state == ACCESS) | rq_full;

// ==========================================================
// Hacia mem_con
// ==========================================================
assign hit_l2_out  = hit_l2;
assign miss_l2_out = ~hit_l2;
assign addr_out    = rq_addr;
assign size_out    = rq_size;

assign wb_write_out = (wb_state == WB_COMMIT);
assign wb_addr_out  = wb_addr;
assign wb_data_out  = wb_wdata;
assign wb_size_out  = wb_size;

endmodule