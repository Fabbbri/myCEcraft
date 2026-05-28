module mux31_3(
    input logic [31:0] in1, in2, in3, in4,
    input logic [31:0] in5,
    input logic [1:0] src,
    input logic srcJ,

    output logic [31:0] out
);

logic src3;

assign src3 = {srcJ, src};

assign out =  (src == 3'b000) ? (in1)
            : (src == 3'b001) ? (in2)
            : (src == 3'b010) ? (in3)
            : (src == 3'b011) ? (in4)
            : (src == 3'b100) ? (in1)
            : (src == 3'b111) ? (in5)
            : (in1); // (src == 2'b11) ? es el ultimo caso, entonces es default


endmodule