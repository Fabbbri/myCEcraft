module if_id_pipe (
    input  logic clk,
    input  logic reset,

    input  logic [31:0] instr_in,
    input  logic [31:0] pc_in, addr_in,

    // Hazard Unit
    input logic stallD, flushD,

    output logic [31:0] instr_out, addr_out,
    output logic [31:0] pc_out
);

assign instr_out = instr_in; // Stall y nop se hacen en ROM

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out    <= 32'b0;
        addr_out  <= 32'b0;
    end else if (flushD) begin
        pc_out    <= 32'b0;
        addr_out  <= 32'b0;
    end else if (stallD) begin
        pc_out    <= pc_out;
        addr_out  <= addr_out;
    end else begin
        pc_out    <= pc_in;
        addr_out  <= addr_in;
    end
end

endmodule