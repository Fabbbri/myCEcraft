module if_id_pipe (
    input  logic clk,
    input  logic reset,

    input  logic [31:0] instr_in,
    input  logic [31:0] pc_in, addr_in,

    output logic [31:0] instr_out, addr_out,
    output logic [31:0] pc_out
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        instr_out <= 32'b0;
        pc_out    <= 32'b0;
        addr_out <= 32'b0;
    end else begin
        instr_out <= instr_in;
        pc_out    <= pc_in;
        addr_out <= addr_in;

    end
end

endmodule