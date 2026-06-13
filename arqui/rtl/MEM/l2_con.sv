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
//  fill_line viene de refill_regs y se pasa directo a l2_cache
// ============================================================

module l2_con (
    input  logic        clk,
    input  logic        reset,

    // backpressure del mem_controller: si su cola esta llena, el drain
    // debe esperar (un commit con cola llena pierde la escritura)
    input  logic        mem_busy,

    // Desde l1_con
    input  logic        is_write,
    input  logic        miss_l1,
    input  logic        hit_l1,
    input  logic [31:0] addr,
    input  logic [1:0]  size,
    input  logic [31:0] wdata,

    // Burst desde mem_controller
    input  logic [2:0]  burst_counter,
    input  logic        burst_active,

    // fill_line acumulada desde refill_regs
    input  logic [255:0] fill_line,

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
    output logic [31:0] addr_out,
    output logic [1:0]  size_out,

    // Hacia mem_con: write-through (WB drain completado)
    output logic        wb_write_out,
    output logic [31:0] wb_addr_out,
    output logic [31:0] wb_data_out,
    output logic [1:0]  wb_size_out
);

// ==========================================================
// Typedefs
// ==========================================================
typedef enum logic [1:0] {
    IDLE   = 2'b00,
    ACCESS = 2'b01,
    DONE   = 2'b10
} load_state_t;

typedef enum logic [1:0] {
    WB_IDLE   = 2'b00,
    WB_DRAIN  = 2'b01,
    WB_COMMIT = 2'b10
} wb_state_t;

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
// ==========================================================
logic [1:0] way_to_fill;
logic       way_replace;
logic [6:0] active_set;

logic [31:0] wb_addr;
wb_state_t   wb_state;

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

// Declaración adelantada: rq_push referencia load_state que se declara
// más abajo en la FSM. Icarus requiere que la declaración preceda al uso.
load_state_t load_state, load_next;
logic [3:0]  load_cnt;

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

// Un solo request en vuelo: encolar solo con la cola vacia y FSM en IDLE.
// Evita duplicados durante el stall (miss_l1 sostenido) y reintenta solo
// si el load sigue pendiente tras servirse la entrada anterior.
assign rq_push = miss_l1 & ~is_write & ~rq_full
               & (load_state == IDLE)
               & rq_empty;

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

// un push por store: si el store queda retenido en MEM por un stall,
// el nivel sostenido empujaba copias duplicadas al write buffer
logic        wb_pushed;
logic [31:0] wb_last_addr;
always_ff @(posedge clk) begin
    if (reset) begin
        wb_pushed    <= 1'b0;
        wb_last_addr <= '0;
    end else if (wb_push) begin
        wb_pushed    <= 1'b1;
        wb_last_addr <= addr;
    end else if (~(miss_l1 & is_write)) begin
        wb_pushed    <= 1'b0;
    end
end

assign wb_push = miss_l1 & is_write & ~wb_full
               & (~wb_pushed | (addr != wb_last_addr));

// ==========================================================
// FSM Load: IDLE → ACCESS (8 ciclos) → DONE
// ==========================================================

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
        // wb_empty: drenar stores pendientes antes de leer (orden RAW
        // hacia memoria; sin esto un load puede leer RAM vieja)
        IDLE:    if (!rq_empty && wb_empty)  load_next = ACCESS;
        // hit L2: se sirve tras el hit time (8 ciclos).
        // miss L2: esperar el fill real del burst (fill_en); salir a los
        // 8 ciclos fijos popeaba el request antes de servirlo y el load
        // re-encolaba duplicados cuyos bursts tardios envenenaban L1
        ACCESS:  if (load_cnt >= 4'd7 && hit_l2) load_next = DONE;
                 else if (fill_en)               load_next = DONE;
        DONE:    if (~burst_active)          load_next = IDLE;
        default:                             load_next = IDLE;
    endcase
end

// pop de UN ciclo: DONE puede durar varios ciclos (espera ~burst_active)
// y un pop sostenido des-balancea la cola
logic rq_pop_d;
always_ff @(posedge clk) begin
    if (reset) rq_pop_d <= 1'b0;
    else       rq_pop_d <= (load_state == DONE);
end

assign rq_pop = (load_state == DONE) & ~rq_pop_d & ~rq_empty;

// ==========================================================
// FSM Write Buffer Drain: WB_IDLE → WB_DRAIN (7 ciclos) → WB_COMMIT
// Bloqueada mientras load_state == ACCESS
// ==========================================================
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
        // mem_busy: reintenta hasta que el mem_controller acepte el push
        WB_DRAIN: if (wb_cnt == 3'd6 && !mem_busy)
                      wb_next = WB_COMMIT;
        WB_COMMIT:    wb_next = WB_IDLE;
        default:      wb_next = WB_IDLE;
    endcase
end

assign wb_pop = (wb_state == WB_COMMIT);

// ==========================================================
// Señales hacia l2_cache
// ==========================================================
// fill_en debe activarse UN CICLO DESPUÉS de burst_counter==7.
// En el ciclo donde burst_counter==7, refill_regs todavía está capturando
// la última palabra (always_ff escribe en posedge). Si fill_en fuera
// combinacional en ese ciclo, fill_line_out[255:224] tendría el valor anterior.
logic burst_last_d;
always_ff @(posedge clk)
    burst_last_d <= (burst_counter == 3'b111) & burst_active & ~hit_l2;

assign fill_en = burst_last_d;
assign fill_way_out  = way_to_fill;
assign fill_set      = rq_addr[11:5];
assign fill_tag      = rq_addr[31:12];
assign fill_line_out = fill_line;

assign way_replace = fill_en
                   | (wb_state == WB_COMMIT & hit_l2_wb);

// inv_en: solo en el ciclo exacto de transición IDLE→ACCESS
// (evita invalidar en IDLE genérico antes de que la FSM haya verificado hit)
assign inv_en  = (load_state == IDLE) & (load_next == ACCESS) & ~hit_l2;
assign inv_way = way_to_fill;
assign inv_set = rq_addr[11:5];

assign store_en       = (wb_state == WB_COMMIT) & hit_l2_wb;
assign store_addr_out = wb_addr;
assign store_data_out = wb_wdata;

// ==========================================================
// Hacia CPU/pipeline
// ==========================================================
assign dato_cpu = l2_data_out;
// is_write & wb_full: un store con write buffer lleno debe esperar,
// si no el push se pierde y la escritura nunca llega a memoria.
// load miss con WB no vacio: drenar antes de confiar en hit_l2/RAM
// (orden read-after-write hacia abajo)
assign stall    = (load_state == ACCESS) | rq_full
                | (is_write & wb_full)
                | (miss_l1 & ~is_write & ~wb_empty);

// ==========================================================
// Hacia mem_con
// ==========================================================
// Gateado por ACCESS: solo válido cuando la FSM tiene una request en vuelo.
// Evita que mem_controller arranque en ciclo 0 por caché fría (hit_l2=0).
assign miss_l2_out = (load_state == ACCESS) & ~hit_l2;
assign addr_out    = rq_addr;
assign size_out    = rq_size;

assign wb_write_out = (wb_state == WB_COMMIT);
assign wb_addr_out  = wb_addr;
assign wb_data_out  = wb_wdata;
assign wb_size_out  = wb_size;

endmodule