// ================================================
// Manejo del puntero de lectura
// Dominio: rclk (clk_mem 50MHz)
// empty=1: FIFO vacío (reset arranca en 1)
// empty: compara g_rptr_next con wptr sincronizado
// ================================================

module rptr_handler #(parameter PTR_WIDTH = 2)(
    input  logic rclk, reset, r_en,
    input  logic [PTR_WIDTH:0] g_wptr_sync,
    output logic [PTR_WIDTH:0] b_rptr, g_rptr,
    output logic empty
);
    logic [PTR_WIDTH:0] b_rptr_next, g_rptr_next;
    logic rempty;

    // próximo valor binario: avanza si r_en y no vacío
    always_comb begin
        if (r_en && !empty) begin
            b_rptr_next = b_rptr + 1;
        end else begin
            b_rptr_next = b_rptr;
        end
    end

    // g_rptr_next: convierte b_rptr_next a código Gray.
    // Gray = binario XOR (binario >> 1)
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;

    // empty: rptr alcanzó al wptr sincronizado
    assign rempty = (g_wptr_sync == g_rptr_next);

    // avance de punteros - dominio rclk
    always_ff @(posedge rclk or posedge reset) begin
        if (reset) begin
            b_rptr <= '0;
            g_rptr <= '0;
        end else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end
    
    // empty registrado - arranca en 1 (FIFO vacío en reset)
    always_ff @(posedge rclk or posedge reset) begin
        if (reset) begin
            empty <= 1'b1;
        end else begin
            empty <= rempty;
        end
    end
    
endmodule