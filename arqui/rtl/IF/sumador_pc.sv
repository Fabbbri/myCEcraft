module sumador_pc(
    input  logic [31:0] addr,       // entrada (address actual)
    output logic [31:0] pcplus4
);                                  

logic [31:0] wired4;
assign wired4 = 32'd4;

assign pcplus4 = addr + wired4; // PC+4

endmodule