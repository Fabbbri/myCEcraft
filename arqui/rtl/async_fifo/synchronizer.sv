// ================================================
//  Sincronizador 2FF para CDC
// Evita metaestabilidad al cruzar dominios de reloj
// ================================================
module synchronizer #(parameter WIDTH = 3)(
    input logic clk,
    input logic reset, // activo ALTO
    input logic [WIDTH:0] d_in,
    output logic [WIDTH:0] d_out
);
    logic [WIDTH:0] q1;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q1 <= '0;
            d_out <= '0;
        end else begin
            q1 <= d_in;
            d_out <= q1;
        end
    end
endmodule