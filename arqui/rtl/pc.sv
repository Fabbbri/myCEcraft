module pc(
    input logic clk,
    input logic pc_enable,
    input logic reset,
    input logic [31:0] new_addr,

    output logic [31:0] addr
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        addr <= 32'b0;
    end else if (pc_enable) begin
        addr <= new_addr;
    end else begin
        addr <= addr;
    end
end

endmodule