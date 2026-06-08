// ============================================================
//  refill_regs.sv
//  Dos bancos de registros de línea (256 bits)
//
//  reg_mem: se llena durante burst desde memoria (counter 0..7)
//  reg_l2:  se llena durante refill desde L2    (counter 0..7)
//
//  Ambos siempre leen.
//  fill_line_out: mux entre reg_mem y reg_l2 según hit_l2
// ============================================================

module refill_regs (
    input  logic        clk,
    input  logic        reset,

    // Escritura desde mem_controller (burst de RAM)
    input  logic        burst_active,       // 1 durante burst
    input  logic [2:0]  burst_counter,      // índice de palabra [0..7]
    input  logic [31:0] burst_rdata,        // palabra actual de data_ram

    // Escritura desde l2_cache (refill L1 en hit L2)
    // l2_cache entrega la palabra indexada por l2_word_offset
    input  logic        l2_refill_active,   // miss_l1 & hit_l2
    input  logic [2:0]  l2_word_counter,    // block offset [0..7] del set
    input  logic [31:0] l2_rdata,           // palabra de l2_cache en ese offset

    // Selector
    input  logic        hit_l2,             // 1 → usar reg_l2, 0 → usar reg_mem

    // Salida (siempre disponible, combinacional)
    output logic [255:0] fill_line_out,     // hacia l1_con y l2_con
    output logic         fill_line_ready    // línea completa (counter llegó a 7)
);

    logic [255:0] reg_mem;  // línea acumulada desde memoria
    logic [255:0] reg_l2;   // línea acumulada desde L2

    // ----------------------------------------------------------
    // Escritura reg_mem: cada ciclo de burst_active
    // ----------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset)
            reg_mem <= '0;
        else if (burst_active)
            reg_mem[burst_counter*32 +: 32] <= burst_rdata;
    end

    // ----------------------------------------------------------
    // Escritura reg_l2: cada ciclo de l2_refill_active
    // l2_cache es combinacional: para obtener cada palabra,
    // l2_word_counter se incrementa externamente (en l1_con)
    // y l2_rdata es la salida de data_mem[set][hit_way][offset]
    // ----------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset)
            reg_l2 <= '0;
        else if (l2_refill_active)
            reg_l2[l2_word_counter*32 +: 32] <= l2_rdata;
    end

    // ----------------------------------------------------------
    // Lectura: siempre disponible, mux por hit_l2
    // ----------------------------------------------------------
    assign fill_line_out = hit_l2 ? reg_l2 : reg_mem;

    // Línea lista cuando el último contador llegó a 7
    // Válido un ciclo después de capturar la última palabra
    assign fill_line_ready = hit_l2 ? (l2_word_counter  == 3'b111 && l2_refill_active)
                                    : (burst_counter     == 3'b111 && burst_active);

endmodule