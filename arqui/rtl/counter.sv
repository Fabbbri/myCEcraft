// ===================================================
//                Contador parametrico
// ===================================================
module counter #(
    parameter MAX = 9
)(
    input logic clk,
    input logic reset,
    input logic en,
    output logic [3:0] count  // 4 bits, cuenta hasta 15
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0;
        else if (en) begin
            if (count < MAX)
                count <= count + 1'b1;
        end
    end

endmodule