module mux31(
    input logic [31:0] in1,
    input logic [31:0] in2,
    input logic src,
    output logic [31:0] out
);

assign out = (src)? in2
            : in1;

endmodule