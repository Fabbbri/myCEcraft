// ============================================================
//  Performance Monitor Unit (PMU)
// ------------------------------------------------------------
//  Contadores acumulativos de rendimiento. Cuentan desde que se
//  suelta el reset hasta que el programa congela (freeze=pc_en==0).
//  Reemplazan en hardware lo que antes acumulaban los testbenches
//  (tb_topG / tb_general_dump) mirando estas mismas senales.
//
//  La logica (deteccion de acceso nuevo + clasificacion L1->L2->RAM)
//  es identica a la que tenian las TBs, portada a RTL sintetizable.
// ============================================================

module perf_counters (
    input  logic        clk,
    input  logic        reset,
    input  logic        freeze,       // pc_en==0: el programa termino -> congela contadores

    // ---- pipeline ----
    input  logic [31:0] instrDE,       // instruccion en EX
    input  logic        flushE,
    input  logic        stallE,
    input  logic        flushD,        // flush por branch tomado (ctrl stall)
    input  logic        stall_mem,     // pipeline congelado por memoria

    // ---- tipo de op de memoria en MEM ----
    input  logic [1:0]  result_src,    // 01 = load
    input  logic        we_mem,        // 1  = store
    input  logic [31:0] alu_result,    // direccion del acceso

    // ---- eventos de cache / memoria ----
    input  logic        hit_l1,
    input  logic        hit_l2,
    input  logic        hit_l2_wb,
    input  logic        wb_commit,     // pulso por cada store drenado a L2 (wb_state==COMMIT)
    input  logic        burst_active,  // burst de lectura en curso (bus RAM ocupado)
    input  logic        ram_we,        // escritura a RAM en curso

    // ---- totales (lectura por el testbench / SW) ----
    output logic [31:0] cycles,
    output logic [31:0] instr,
    output logic [31:0] stall_mem_cyc,
    output logic [31:0] ctrl_stalls,
    output logic [31:0] l1_reads,
    output logic [31:0] l1_writes,
    output logic [31:0] l1_rd_hits,
    output logic [31:0] l1_rd_miss,
    output logic [31:0] l1_wr_hits,
    output logic [31:0] l1_wr_miss,
    output logic [31:0] l2_acc,
    output logic [31:0] l2_reads,
    output logic [31:0] l2_writes,
    output logic [31:0] l2_hits,
    output logic [31:0] l2_miss,
    output logic [31:0] mem_acc,
    output logic [31:0] mem_bursts,
    output logic [31:0] mem_xfer_cyc
);

    localparam logic [31:0] NOP = 32'h00580000;

    // running: 1 desde el reset hasta el primer freeze del programa
    logic running;

    // ---- op de memoria real en MEM (load=result_src 01, store=we_mem) ----
    wire mem_rd_op = (result_src == 2'b01);
    wire mem_wr_op = we_mem;
    wire mem_op    = mem_rd_op | mem_wr_op;

    // ---- acceso nuevo: cambia direccion o tipo respecto al ciclo anterior
    //      (durante un stall el pipeline retiene la misma op en MEM: no recontar) ----
    logic        prev_mem_op;
    logic        prev_wr;
    logic [31:0] prev_addr;
    logic        prev_burst;

    wire new_access = mem_op && !(prev_mem_op &&
                                  prev_addr == alu_result &&
                                  prev_wr   == mem_wr_op);

    // ---- instruccion retirada (no-NOP que pasa EX sin flush/stall) ----
    wire instr_retired = (instrDE != NOP) && !flushE && !stallE;

    // ============================================================
    //  Incrementos combinacionales del ciclo
    //  l2_acc/l2_hits/l2_miss/mem_acc pueden subir hasta 2 en un mismo
    //  ciclo (load-miss de L1 + store drenado a L2 a la vez): por eso se
    //  calculan como deltas y se suman una sola vez (evita perder un ++).
    // ============================================================
    logic       inc_l1_reads, inc_l1_writes;
    logic       inc_l1_rd_hits, inc_l1_rd_miss, inc_l1_wr_hits, inc_l1_wr_miss;
    logic       inc_l2_reads, inc_l2_writes;
    logic [1:0] inc_l2_acc, inc_l2_hits, inc_l2_miss, inc_mem_acc;

    always_comb begin
        inc_l1_reads   = 1'b0; inc_l1_writes  = 1'b0;
        inc_l1_rd_hits = 1'b0; inc_l1_rd_miss = 1'b0;
        inc_l1_wr_hits = 1'b0; inc_l1_wr_miss = 1'b0;
        inc_l2_reads   = 1'b0; inc_l2_writes  = 1'b0;
        inc_l2_acc = 2'd0; inc_l2_hits = 2'd0; inc_l2_miss = 2'd0; inc_mem_acc = 2'd0;

        // L1: clasificar en el primer ciclo de cada acceso
        if (new_access) begin
            if (mem_wr_op) begin
                inc_l1_writes = 1'b1;
                if (hit_l1) inc_l1_wr_hits = 1'b1; else inc_l1_wr_miss = 1'b1;
            end else begin
                inc_l1_reads = 1'b1;
                if (hit_l1) begin
                    inc_l1_rd_hits = 1'b1;
                end else begin
                    inc_l1_rd_miss = 1'b1;
                    // load miss de L1 -> baja a L2
                    inc_l2_acc   = inc_l2_acc + 2'd1;
                    inc_l2_reads = 1'b1;
                    if (hit_l2) inc_l2_hits = inc_l2_hits + 2'd1;
                    else begin
                        inc_l2_miss = inc_l2_miss + 2'd1;
                        inc_mem_acc = inc_mem_acc + 2'd1;   // L2 miss -> burst a RAM
                    end
                end
            end
        end

        // L2 writes: un commit (1 ciclo) por store drenado; write-through -> RAM
        if (wb_commit) begin
            inc_l2_acc    = inc_l2_acc + 2'd1;
            inc_l2_writes = 1'b1;
            if (hit_l2_wb) inc_l2_hits = inc_l2_hits + 2'd1;
            else           inc_l2_miss = inc_l2_miss + 2'd1;
            inc_mem_acc   = inc_mem_acc + 2'd1;
        end
    end

    // ============================================================
    //  Acumulacion sincronica
    // ============================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            running       <= 1'b1;
            cycles        <= 32'd0;  instr         <= 32'd0;
            stall_mem_cyc <= 32'd0;  ctrl_stalls   <= 32'd0;
            l1_reads      <= 32'd0;  l1_writes     <= 32'd0;
            l1_rd_hits    <= 32'd0;  l1_rd_miss    <= 32'd0;
            l1_wr_hits    <= 32'd0;  l1_wr_miss    <= 32'd0;
            l2_acc        <= 32'd0;  l2_reads      <= 32'd0;  l2_writes <= 32'd0;
            l2_hits       <= 32'd0;  l2_miss       <= 32'd0;
            mem_acc       <= 32'd0;  mem_bursts    <= 32'd0;  mem_xfer_cyc <= 32'd0;
            prev_mem_op   <= 1'b0;   prev_wr       <= 1'b0;
            prev_addr     <= 32'd0;  prev_burst    <= 1'b0;
        end else begin
            if (freeze) running <= 1'b0;

            if (running) begin
                cycles <= cycles + 32'd1;
                if (instr_retired) instr <= instr + 32'd1;

                l1_reads   <= l1_reads   + inc_l1_reads;
                l1_writes  <= l1_writes  + inc_l1_writes;
                l1_rd_hits <= l1_rd_hits + inc_l1_rd_hits;
                l1_rd_miss <= l1_rd_miss + inc_l1_rd_miss;
                l1_wr_hits <= l1_wr_hits + inc_l1_wr_hits;
                l1_wr_miss <= l1_wr_miss + inc_l1_wr_miss;

                l2_acc    <= l2_acc    + inc_l2_acc;
                l2_reads  <= l2_reads  + inc_l2_reads;
                l2_writes <= l2_writes + inc_l2_writes;
                l2_hits   <= l2_hits   + inc_l2_hits;
                l2_miss   <= l2_miss   + inc_l2_miss;
                mem_acc   <= mem_acc   + inc_mem_acc;

                if (burst_active && !prev_burst)  mem_bursts   <= mem_bursts   + 32'd1;
                if (stall_mem)                    stall_mem_cyc <= stall_mem_cyc + 32'd1;
                if (flushD)                       ctrl_stalls  <= ctrl_stalls  + 32'd1;
                if (burst_active || ram_we)       mem_xfer_cyc <= mem_xfer_cyc + 32'd1;
            end

            // estado de deteccion de acceso nuevo (se actualiza siempre)
            prev_mem_op <= mem_op;
            prev_wr     <= mem_wr_op;
            prev_addr   <= alu_result;
            prev_burst  <= burst_active;
        end
    end

endmodule
