module mux31_2(
    input logic [31:0] in1, in2, in3, in4,
    input logic [1:0] src,

    output logic [31:0] out
);

assign out =  (src == 2'b00)? (in1)
            : (src == 2'b01)? (in2)
            : (src == 2'b10)? (in3)
            : (src == 2'b11)? (in4)

endmodule