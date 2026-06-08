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
// ============================================================

module l2_con(

    input logic clk, 
    input logic reset,

    // Datos que vienen de L1_con
    input logic is_write, miss_l1, hit_l1,
    input logic [31:0] addr,
    input logic [1:0] size,
    input logic [31:0] wdata,

    // Burst de memoria
    // Desde banco de registros (linea de refill)
    input logic [255:0] fill_line, // linea completa del burst
    // Desde mem_controller: contador de palabras del burst (0..7)
    input logic [2:0] block_offset_counter, // contador de palabras del burst (0..7)

    // Señales vienen de l2_cache
    input logic hit_l2,
    input logic [31:0] l2_data_out,
    // Desde l2_cache: hit evaluado con dirección del write buffer head
    // l2_cache expone un puerto de tag-lookup extra para el WB
    input  logic        hit_l2_wb,

    // Hacia l2_cache: fill
    output logic fill_en,
    output logic [1:0] fill_way_out,
    output logic [6:0] fill_set,
    output logic [19:0] fill_tag,
    output logic [255:0] fill_line_out,

    // Hacia l2_cache: invalidacion (load miss antes del refill)
    output logic        inv_en,
    output logic [1:0]  inv_way,
    output logic [6:0]  inv_set,

    // Hacia l2_cache: store
    output logic        store_en,
    output logic [31:0] store_addr_out,
    output logic [31:0] store_data_out,

    // Hacia CPU/pipeline
    output logic [31:0] dato_cpu,
    output logic        stall,          // stall al pipeline durante acceso L2

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
// addr[31:12] = tag (20 bits)
// addr[11:5] = set (7 bits)
// addr[4:2] = block offset (3 bits)
// addr[1:0] = byte offset (ignorado)
// ==========================================================
logic [19:0] addr_tag;
logic [6:0] addr_set;
logic [2:0] addr_block;

assign addr_tag = addr[31:12];
assign addr_set = addr[11:5];
assign addr_block = addr[4:2];

// ==========================================================
// WayReg: FIFO de reemplazo (128 sets, 4-way)
// Solo avanza en refill de load miss
// ==========================================================
logic [1:0] way_to_fill;
logic       way_replace;

// Set activo depende de quién necesita el WayReg
logic [6:0] active_set;

always_comb begin
    if (wb_state == WB_COMMIT)
        active_set = wb_addr[11:5];   // store drenando
    else
        active_set = addr_set;        // load del pipeline
end

set_reg #(.NUM_SETS(128), .NUM_WAYS(4)) WayReg (
    .clk     (clk),
    .reset   (reset),
    .set     (active_set),            // set correcto según contexto (mux)
    .fill_en (way_replace),
    .way_out (way_to_fill)
);

// ==========================================================
// Request Queue: solo loads (miss_l1 & ~is_write)
// ==========================================================
logic rq_push, rq_pop;
logic rq_full, rq_empty;
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
// Write Buffer: stores llegan aquí directamente
// ==========================================================
logic wb_push, wb_pop;
logic wb_full, wb_empty;
logic [31:0] wb_addr;
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

// Stores bypasan request_queue y van directo al write buffer
assign wb_push = miss_l1 & is_write & ~wb_full;

// ==========================================================
// FSM Load: IDLE → ACCESS (8 ciclos) → DONE
// ==========================================================
typedef enum logic [1:0] {
    IDLE   = 2'b00,
    ACCESS = 2'b01,
    DONE   = 2'b10
} load_state_t;

load_state_t load_state, load_next;
logic [3:0] load_cnt;

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
        IDLE:    if (!rq_empty)             load_next = ACCESS;
        ACCESS:  if (load_cnt == 4'd7)      load_next = DONE;
        DONE:                               load_next = IDLE;
        default:                            load_next = IDLE;
    endcase
end

// Pop de la request queue al terminar el acceso
assign rq_pop = (load_state == DONE);

// ==========================================================
// FSM Write Buffer Drain: WB_IDLE → WB_DRAIN (7 ciclos) → WB_COMMIT
// Bloqueada mientras load_state == ACCESS (evita colisión con refill)
// ==========================================================
typedef enum logic [1:0] {
    WB_IDLE   = 2'b00,
    WB_DRAIN  = 2'b01,
    WB_COMMIT = 2'b10
} wb_state_t;

wb_state_t wb_state, wb_next;
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
        WB_IDLE:   if (!wb_empty && (load_state != ACCESS) && ~fill_en)
                       wb_next = WB_DRAIN;

        WB_DRAIN:  if (wb_cnt == 3'd6)
                       wb_next = WB_COMMIT;

        WB_COMMIT:     wb_next = WB_IDLE;

        default:       wb_next = WB_IDLE;
    endcase
end

// Pop del write buffer al commitear
assign wb_pop = (wb_state == WB_COMMIT);

// ==========================================================
// Señales hacia l2_cache
// ==========================================================

// Fill: al final del burst en load miss
assign fill_en       = (block_offset_counter == 3'b111) & ~hit_l2 & (load_state == ACCESS);
assign fill_way_out  = way_to_fill;
assign fill_set      = addr_set;
assign fill_tag      = addr_tag;
assign fill_line_out = fill_line;

// WayReg avanza solo en refill real
assign way_replace = fill_en;

// Invalidación: load miss al inicio del acceso
assign inv_en  = (load_state == IDLE) & ~rq_empty & ~hit_l2;
assign inv_way = way_to_fill;
assign inv_set = addr_set;

// Store write-through desde WB: solo si hit en L2 (evaluado con wb_addr)
// Si miss en L2, no-write-allocate: solo va a memoria
assign store_en       = (wb_state == WB_COMMIT) & hit_l2_wb;
assign store_addr_out = wb_addr;
assign store_data_out = wb_wdata;

// ==========================================================
// Hacia CPU/pipeline
// ==========================================================
assign dato_cpu = l2_data_out;

// Stall: solo durante acceso de load o si request queue llena
assign stall = (load_state == ACCESS) | rq_full;

// ==========================================================
// Hacia mem_con: loads
// ==========================================================
assign hit_l2_out  = hit_l2;
assign miss_l2_out = ~hit_l2;
assign addr_out    = rq_addr;
assign size_out    = rq_size;

// Hacia mem_con: write-through al completar drain
// mem_con tiene su propio write buffer, solo le pasamos el dato
assign wb_write_out = (wb_state == WB_COMMIT);
assign wb_addr_out  = wb_addr;
assign wb_data_out  = wb_wdata;
assign wb_size_out  = wb_size;

endmodule