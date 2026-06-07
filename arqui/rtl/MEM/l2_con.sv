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

    // Hacia l2_cache: fill
    output logic fill_en,
    output logic [1:0] fill_way_out,
    output logic [6:0] fill_set,
    output logic [19:0] fill_tag,
    output logic [255:0] fill_line_out,

    // Hacia l2_cache: invalidacion
    output logic inv_en,
    output logic inv_way,
    output logic [6:0] inv_set,

    // Hacia l2_cache: store
    output logic        store_en,
    output logic [31:0] store_addr_out,
    output logic [31:0] store_data_out,

    // Hacia CPU/pipeline
    output logic [31:0] dato_cpu,
    output logic        stall,          // stall al pipeline durante acceso L2

    // Hacia mem_con
    output logic        miss_l2_out,
    output logic        hit_l2_out,
    output logic        is_write_out,
    output logic [31:0] wdata_out,
    output logic [31:0] addr_out,
    output logic [1:0]  size_out,
    output logic        wb_write_out,   // write buffer drena a memoria
    output logic [31:0] wb_addr_out,
    output logic [31:0] wb_data_out,
    output logic [1:0]  wb_size_out

);

// ==========================================================
// Address breakdown
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
// Despacho inmediato de stores (no entran a request queue)
// ==========================================================

// Store: se despacha en el mismo ciclo que llega
logic dispatch_store;
assign dispatch_store = hit_l1 & is_write;

// Hacia mem_con: store siempre escribe a memoria (write-through)
// mem_con tiene su propio write buffer, solo le pasamos el dato
assign is_write_out = dispatch_store;
assign wdata_out    = wdata;
assign addr_out     = addr;
assign size_out     = size;

// Hacia l2_cache: store en background si hay hit en L2
// hit_l2 es combinacional, se resuelve en el mismo ciclo
assign store_en       = dispatch_store & hit_l2;
assign store_addr_out = addr;
assign store_data_out = wdata;

// Pipeline NO genera stall en store
// (el stall solo aplica a loads que entran a la request queue)

// ==========================================================
// Request Queue: SOLO para loads
// ==========================================================
logic rq_push;
assign rq_push = miss_l1 & ~is_write & ~rq_full;  // ← solo loads

// ... resto del FIFO igual que antes ...

// Stall: solo durante acceso de load en curso o cola llena
assign stall = (state == ACCESS) || (rq_full & ~is_write);

// ==========================================================
// WayReg: FIFO de reemplazo para L1 (64 sets, 2-way)
// ==========================================================
logic way_to_fill;
logic replace = ((~hit_l2 && (block_offset_counter == 3'b111)) && ~hit_l1) | is_write;

set_reg #(.NUM_SETS(128), .NUM_WAYS(4)) WayReg (
    .clk (clk),
    .reset (reset),
    .set (addr_set),
    .fill_en (replace),
    .way_out (way_to_fill)
);

// ==========================================================
// Hit / Miss, datos para write-through mem
// ==========================================================
assign hit_l2_out = hit_l2;
assign miss_l2_out = ~hit_l2;
assign is_write_out = is_write;
assign wdata_out = wdata;
assign addr_out = addr;
assign size_out  = size;

// Dato al CPU: válido solo en hit 
// pipeline en stall durante miss
assign dato_cpu = l2_data_out;

// ==========================================================
// fill_en = ((~hit_l2 && (block_offset_counter == 3'b111)) && ~hit_l1)
// Se activa al final del burst (counter==7) durante un miss.
// ==========================================================
assign fill_en = ((~hit_l2 && (block_offset_counter == 3'b111)) && ~hit_l1);
assign fill_way_out = way_to_fill;
assign fill_set = addr_set;
assign fill_tag = addr_tag;
assign fill_line_out = fill_line;

// ==========================================================
// Invalidación: load miss antes del refill
// Stores no invalidan: write-through actualiza L1 en hit 
// y en miss simplemente escribe a memoria (no-write-allocate).
// ==========================================================
assign inv_en = ~is_write & ~hit_l2;
assign inv_way = way_to_fill;
assign inv_set = addr_set;

endmodule 


    // Hacia mem_con
    output logic        miss_l2_out,
    output logic        hit_l2_out,
    output logic        is_write_out,
    output logic [31:0] wdata_out,
    output logic [31:0] addr_out,
    output logic [1:0]  size_out,
    output logic        wb_write_out,   // write buffer drena a memoria
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
logic [2:0]  addr_block;

assign addr_tag   = addr[31:12];
assign addr_set   = addr[11:5];
assign addr_block = addr[4:2];

// ==========================================================
// Tipos de entrada a la Request Queue
// ==========================================================
typedef struct packed {
    logic        is_write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [1:0]  size;
} req_entry_t;

// ==========================================================
// Request Queue: FIFO de 8 entradas
// Acepta requests del pipeline (reads y writes)
// ==========================================================
localparam int RQ_DEPTH = 8;
localparam int RQ_PTR   = 3;

req_entry_t rq_mem  [0:RQ_DEPTH-1];
logic [RQ_PTR-1:0] rq_wptr, rq_rptr;
logic [RQ_PTR:0]   rq_count;  // un bit extra para distinguir full/empty

logic rq_full, rq_empty;
assign rq_full  = (rq_count == RQ_DEPTH);
assign rq_empty = (rq_count == 0);

// Enqueue: llega request del pipeline cuando hay miss en L1
logic rq_push, rq_pop;
assign rq_push = miss_l1 & ~rq_full;

always_ff @(posedge clk) begin
    if (reset) begin
        rq_wptr  <= '0;
        rq_rptr  <= '0;
        rq_count <= '0;
    end else begin
        if (rq_push && !rq_pop) begin
            rq_mem[rq_wptr] <= '{is_write, addr, wdata, size};
            rq_wptr  <= rq_wptr + 1;
            rq_count <= rq_count + 1;
        end else if (!rq_push && rq_pop) begin
            rq_rptr  <= rq_rptr + 1;
            rq_count <= rq_count - 1;
        end else if (rq_push && rq_pop) begin
            rq_mem[rq_wptr] <= '{is_write, addr, wdata, size};
            rq_wptr  <= rq_wptr + 1;
            // count no cambia: entra uno y sale uno
        end
    end
end

// Request al frente de la cola
req_entry_t rq_head;
assign rq_head = rq_mem[rq_rptr];

// ==========================================================
// Write Buffer: FIFO de 8 entradas
// Absorbe writes para drenarlos a memoria en background
// ==========================================================
localparam int WB_DEPTH = 8;
localparam int WB_PTR   = 3;

req_entry_t wb_mem  [0:WB_DEPTH-1];
logic [WB_PTR-1:0] wb_wptr, wb_rptr;
logic [WB_PTR:0]   wb_count;

logic wb_full, wb_empty;
assign wb_full  = (wb_count == WB_DEPTH);
assign wb_empty = (wb_count == 0);

// Push al write buffer cuando se despacha un write de la request queue
logic wb_push, wb_drain;

always_ff @(posedge clk) begin
    if (reset) begin
        wb_wptr  <= '0;
        wb_rptr  <= '0;
        wb_count <= '0;
    end else begin
        if (wb_push && !wb_drain) begin
            wb_mem[wb_wptr] <= rq_head;
            wb_wptr  <= wb_wptr + 1;
            wb_count <= wb_count + 1;
        end else if (!wb_push && wb_drain) begin
            wb_rptr  <= wb_rptr + 1;
            wb_count <= wb_count - 1;
        end else if (wb_push && wb_drain) begin
            wb_mem[wb_wptr] <= rq_head;
            wb_wptr  <= wb_wptr + 1;
            // count no cambia
        end
    end
end

// Salida del write buffer hacia mem_con
req_entry_t wb_head;
assign wb_head = wb_mem[wb_rptr];

// ==========================================================
// FSM de acceso a L2 (8 ciclos de latencia)
// ==========================================================
typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ACCESS  = 2'b01,   // contando 8 ciclos
    DONE    = 2'b10
} l2_state_t;

l2_state_t state, next_state;
logic [3:0] cycle_cnt;         // cuenta 0..7
logic       serving_write;     // 1 si el acceso actual es un write

always_ff @(posedge clk) begin
    if (reset) begin
        state         <= IDLE;
        cycle_cnt     <= '0;
        serving_write <= '0;
    end else begin
        state <= next_state;
        if (state == ACCESS)
            cycle_cnt <= cycle_cnt + 1;
        else
            cycle_cnt <= '0;

        // Registrar tipo de acceso al inicio
        if (state == IDLE && !rq_empty)
            serving_write <= rq_head.is_write;
    end
end

// ==========================================================
// Lógica de transición de la FSM
// ==========================================================
always_comb begin
    next_state = state;
    case (state)
        IDLE:    if (!rq_empty)            next_state = ACCESS;
        ACCESS:  if (cycle_cnt == 4'd7)    next_state = DONE;
        DONE:                              next_state = IDLE;
        default:                           next_state = IDLE;
    endcase
end

// ==========================================================
// Señales de control derivadas de la FSM
// ==========================================================

// Pop de la request queue al terminar el acceso
assign rq_pop = (state == DONE);

// Push al write buffer: cuando terminamos de servir un write
assign wb_push = (state == DONE) && serving_write;

// Drain del write buffer a memoria: un write por ciclo en background
// Solo drena si no estamos sirviendo un read (prioridad al pipeline)
assign wb_drain = !wb_empty && (state == IDLE);

// Stall al pipeline: mientras hay acceso en curso o cola llena
assign stall = (state == ACCESS) || rq_full;

// ==========================================================
// WayReg FIFO de reemplazo (L2: 128 sets, 4-way)
// ==========================================================
logic [1:0] way_to_fill;
logic       replace;
assign replace = (state == DONE) && !serving_write && !hit_l2;

set_reg #(.NUM_SETS(128), .NUM_WAYS(4)) WayReg (
    .clk     (clk),
    .reset   (reset),
    .set     (addr_set),
    .fill_en (replace),
    .way_out (way_to_fill)
);

// ==========================================================
// Señales hacia l2_cache
// ==========================================================

// Fill: al final del burst en read miss
assign fill_en       = (block_offset_counter == 3'b111) & ~hit_l2 & ~serving_write;
assign fill_way_out  = way_to_fill;
assign fill_set      = addr_set;
assign fill_tag      = addr_tag;
assign fill_line_out = fill_line;

// Invalidación: solo en read miss
assign inv_en  = ~serving_write & ~hit_l2 & (state == IDLE) & !rq_empty;
assign inv_way = way_to_fill;
assign inv_set = addr_set;

// Store: write-through en L2
assign store_en       = (state == DONE) && serving_write;
assign store_addr_out = rq_head.addr;
assign store_data_out = rq_head.wdata;

// ==========================================================
// Hacia CPU
// ==========================================================
assign dato_cpu = l2_data_out;

// ==========================================================
// Hacia mem_con
// ==========================================================
assign hit_l2_out  = hit_l2;
assign miss_l2_out = ~hit_l2;
assign is_write_out = serving_write;
assign wdata_out    = rq_head.wdata;
assign addr_out     = rq_head.addr;
assign size_out     = rq_head.size;

// Write buffer drenando a memoria en background
assign wb_write_out = wb_drain;
assign wb_addr_out  = wb_head.addr;
assign wb_data_out  = wb_head.wdata;
assign wb_size_out  = wb_head.size;

endmodule