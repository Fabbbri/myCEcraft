// ================================================
//  Manejo del puntero de escritura
// Dominio: wclk (clk_proc 100MHz)
// full=0: FIFO no lleno (reset arranca en 0)
// ================================================

module wptr_handler #(parameter PTR_WIDTH = 2)(
    input  logic wclk, reset, w_en,
    input  logic [PTR_WIDTH:0] g_rptr_sync,
    output logic [PTR_WIDTH:0] b_wptr, g_wptr,
    output logic full
);
    logic [PTR_WIDTH:0] b_wptr_next, g_wptr_next;
    logic wfull;

    // próximo valor binario: avanza si w_en y no lleno
    always_comb begin
        if (w_en && !full) begin
            b_wptr_next = b_wptr + 1;
        end
        else begin
            b_wptr_next = b_wptr; // se queda donde está
        end
    end

    // g_wptr_next: convierte b_wptr_next a código Gray.
    // Gray = binario XOR (binario >> 1)
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

    // avance de punteros - dominio wclk
    always_ff @(posedge wclk or posedge reset) begin
        if (reset) begin
            b_wptr <= '0;
            g_wptr <= '0;
        end else begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
        end
    end

    // full registrado — arranca en 0 (FIFO no lleno en reset)
    always_ff @(posedge wclk or posedge reset) begin
        if (reset) begin 
            full <= 1'b0;
        end else begin     
            full <= wfull;
        end
    end
    
    // full: wptr dio una vuelta completa sobre rptr
    // en Gray los 2 bits más significativo se invierten y el resto es igual
    assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

endmodule