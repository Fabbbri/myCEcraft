// ===================================================
// Divisior de clk
// ===================================================
module clk_divider (
    input  logic clk,
    input  logic reset,
    output logic clkdiv //50 MHz (100 ÷2)
);
    logic din;
    assign din = ~clkdiv;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin 
            clkdiv <= 1'b0;
        end
        else begin 
            clkdiv <= din;
        end
    end
endmodule