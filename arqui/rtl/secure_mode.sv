module secure_mode(
    input logic clk,
    input logic neather_portal,
    input logic reset,
    output logic sm
);

always_ff @(posedge clk or podedge reset) begin
    if (resetl) begin
        sm <= 1'b0;
    end else if (neather_portal) begin
        sm <= 1'b1;
    end else begin
        sm <= sm;
    end
end

endmodule