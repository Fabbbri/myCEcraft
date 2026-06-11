// ===================================================
// Parámetros:
//   WIDTH -> ancho del dato
//   DEPTH -> número de entradas (potencia de 2)
// Puertos de entrada/salida:
//   clk -> reloj
//   reset -> reset asíncrono activo alto
//   data_in -> dato a escribir
//   wr_en -> habilita escritura
//   rd_en -> habilita lectura
//   data_out -> dato leído
//   full -> FIFO lleno
//   empty -> FIFO vacío
// ===================================================

module fifo #(
    parameter WIDTH = 32,
    parameter DEPTH = 4
)(
    // clock y reset
    input logic clk,
    input logic reset,

    // escritura
    input logic [WIDTH-1:0] data_in,
    input logic   wr_en,
    output logic  full,

    // lectura
    output logic [WIDTH-1:0] data_out,
    input logic   rd_en,
    output logic  empty
);

localparam ADDR_WIDTH = $clog2(DEPTH);
// ===================================================
// Señales internas
// ===================================================
logic [ADDR_WIDTH-1:0] wptr, rptr;
logic last_was_read;

// ===================================================
// Arreglo de memoria
// ===================================================
logic [WIDTH-1:0] mem [0:DEPTH-1];

// ===================================================
// Escritura
// ===================================================
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        wptr <= '0;
    end else begin
        if (wr_en && !full) begin
            mem[wptr] <= data_in;
            wptr <= wptr + 1'b1;
        end
    end
end

// ===================================================
// Lectura
// ===================================================
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        rptr <= '0;
    end else begin
        if (rd_en && !empty) begin
            rptr <= rptr + 1'b1;
        end
    end
end

// Dato en la salida
assign data_out = mem[rptr];

// ===================================================
// Tracker de última operación
// ===================================================
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        last_was_read <= 1'b1; // arranca vacío
    end else begin
        if (rd_en && !empty)
            last_was_read <= 1'b1;
        else if (wr_en && !full)
            last_was_read <= 1'b0;
    end
end

// ===================================================
// Flags full y empty
// ===================================================
assign full = (wptr == rptr) && !last_was_read;
assign empty = (wptr == rptr) && last_was_read;

endmodule