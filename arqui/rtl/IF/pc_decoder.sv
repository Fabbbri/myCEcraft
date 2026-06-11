module pc_decoder(
    input logic [8:0] pcDEC, // 9 bits: Instr[23:19],Instr[3:0]
    output logic pc_enable
);

assign pc_enable =  (pcDEC == 9'b01100_0000) ? 1'b0 // FREEZE = 01100 0000 
                    : 1'b1; // pc_enable sigue activo con el resto 

endmodule