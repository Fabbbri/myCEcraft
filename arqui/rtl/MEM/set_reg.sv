// ============================================================
//  Registro de política de reemplazo FIFO por set (Paramtrizable para L1 y L2)
//  Mantiene un puntero por set que indica el way a reemplazar.
//  Para L1: NUM_SETS=64, NUM_WAYS=2  (WAY_BITS=1)
//  Para L2: NUM_SETS=128, NUM_WAYS=4  (WAY_BITS=2)
// ============================================================

module set_reg #(
    parameter int NUM_SETS = 64,
    parameter int NUM_WAYS = 2
) (
    input logic clk,
    input logic reset,

    input logic [$clog2(NUM_SETS)-1:0] set,      // set a consultar/actualizar
    input logic fill_en,  // 1 cuando se escribe una linea nueva
    //clog sirve para calcular el numero de bits (parametrizable). Ej: 2 ways -> 1 bits; 4 ways -> 2 bits
    output logic [$clog2(NUM_WAYS)-1:0]  way_out  // way a usar para ese set
);

    localparam int WAY_BITS = $clog2(NUM_WAYS);

    logic [WAY_BITS-1:0] fifo_ptr [NUM_SETS-1:0];

    // Lectura combinacional del puntero actual del set
    assign way_out = fifo_ptr[set];

    // Escritura: avanza el puntero del set cuando se hace fill
    //  2-way: 0->1->0->1  (1 bit)
    //  4-way: 00->01->10->11->00  (2 bits)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (integer s = 0; s < NUM_SETS; s = s + 1)
                fifo_ptr[s] <= '0;
        end else if (fill_en) begin
            if (fifo_ptr[set] == WAY_BITS'(NUM_WAYS - 1))
                fifo_ptr[set] <= '0;
            else
                fifo_ptr[set] <= fifo_ptr[set] + 1'b1;
        end
    end

endmodule
