module orgate5(
    input logic in1, in2, in3, in4, in5,

    output logic out
);

logic temp12;
logic temp34;
logic temp_aux;

assign temp12 = in1 | in2;
assign temp34 = in3 | in4;

assign temp_aux = temp12 | temp34;

assign out = temp_aux | in5;

endmodule