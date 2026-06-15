// ============================================================
// Máquina de estados del controlador de memoria principal (50 MHz).
// ============================================================

module fsm_memory (
    input logic clk_mem,
    input logic reset,

    // estado de las colas
    input  logic rq_full,
    input  logic rq_empty,
    input  logic wb_full,
    input  logic wb_empty,   // 1 = wb_drain está idle (no escribiendo a RAM)
    input  logic wb_conflict, // 1 = dirección del read pendiente coincide con WB

    // tipo de request de la queue
    input  logic is_write,
    input  logic hit_l2,   // L2 hit -> saltar BURST, volver a INIT
    input  logic miss_l2,  // L2 miss -> ir a BURST (RAM)

    // control de request queue
    output logic rq_ren,

    // control de write buffer (solo enqueue)
    output logic wb_wen,

    // control de burst (reads)
    output logic burst_addr,   // 1 = rq_addr + burst_count*4
    output logic [3:0] burst_count,

    // dato al pipeline
    output logic rd_valid,

    // indica que la memoria está en uso por un burst de lectura
    output logic burst_active,

    output logic [2:0] debug
);

// ============================================================
//  Constantes
// ============================================================
localparam logic [3:0] BURST_LEN = 4'd8;
localparam logic [3:0] PROC_WAIT = 4'd2;

// ============================================================
//  Codificación estados
// ============================================================
typedef enum logic [2:0] {
    INIT = 3'd0,
    REQUEST = 3'd2,
    ENQUEUE_WRITE  = 3'd3,
    BURST = 3'd4,
    WAIT_PROC = 3'd5
} state_t;

state_t state, next_state;

// ============================================================
//  Señales internas de contadores
// ============================================================
logic [3:0] cycle_count;

logic burst_clr, burst_en;
logic proc_clr,  proc_en;

// ============================================================
//  Instancias de contadores
// ============================================================
counter #(.MAX(BURST_LEN)) burst_ctr (
    .clk (clk_mem),
    .reset (reset),
    .clear (burst_clr),
    .en (burst_en),
    .count (burst_count)
);

counter #(.MAX(PROC_WAIT)) proc_ctr (
    .clk (clk_mem),
    .reset (reset),
    .clear (proc_clr),
    .en (proc_en),
    .count (cycle_count)
);

// ============================================================
//  Estado actual
// ============================================================
always_ff @(posedge clk_mem or posedge reset)
    if (reset) state <= INIT;
    else state <= next_state;

// ============================================================
//  Próximo estado
// ============================================================
always_comb
    case (state)
        INIT:
            // Reads proceden si drain idle y sin conflicto de dirección en WB.
            if (!rq_empty && (is_write || (!wb_full && !wb_conflict))) next_state = REQUEST;
            else next_state = INIT;

        REQUEST:
            if (!is_write) begin
                if (hit_l2) next_state = INIT; 
                else next_state = BURST;
            end
            else if (!wb_full) next_state = ENQUEUE_WRITE;
            else  next_state = REQUEST;

        ENQUEUE_WRITE:
            next_state = INIT;

        BURST:
            if (burst_count == BURST_LEN - 1) next_state = WAIT_PROC;
            else next_state = BURST;

        WAIT_PROC:
            if (cycle_count == PROC_WAIT - 1) next_state = INIT;
            else next_state = WAIT_PROC;

        default: next_state = INIT;
    endcase

// ============================================================
//  Control de contadores
// ============================================================
assign burst_clr = (state == INIT) || (state == REQUEST);
assign burst_en  = (state == BURST);

assign proc_clr = (state == INIT);
assign proc_en  = (state == WAIT_PROC);

// ============================================================
//  Control de request queue
//  Pop si es lectura, o si es escritura y WB tiene espacio
// ============================================================
assign rq_ren = (state == REQUEST) && (!is_write || !wb_full);

// ============================================================
//  Control de write buffer - solo enqueue (drain lo hace wb_drain)
// ============================================================
assign wb_wen = (state == ENQUEUE_WRITE);

// ============================================================
//  Control de burst (reads)
// ============================================================
assign burst_addr = (state == BURST);
assign burst_active = (state == BURST);

// ============================================================
//  Dato al pipeline
//  rd_valid debe estar en 1 DURANTE los ciclos del BURST,
//  Baja una vez que salimos de BURST.
// ============================================================
assign rd_valid = (state == BURST) || (state == WAIT_PROC);

assign debug = state;

endmodule
