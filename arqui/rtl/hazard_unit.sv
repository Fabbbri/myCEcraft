module hazard_unit(
    input logic [4:0] rs1DE, rs1EX,
    input logic [4:0] rs2DE, rs2EX,
    input logic [4:0] rdEX, rdMEM, rdWB,
    input logic result_src_0, pc_src_exOUT, we_reg_mem, we_reg_wb,

    output logic [1:0] forwardA, forwardB,
    output logic stallIF, stallD,
    output logic flushD, flushE
);
// 11 señales de entrada, 6 señales de salida

// ========================================================================
//                          FORWARDING
// Evita stalls/nops cuando el resultado aún no llegó al register file, 
// pero ya está disponible en otra etapa del pipe.

// forwardA: controla el mux del operando A en EX
// forwardB: controla el mux del operando B en EX

// MEM tiene prioridad sobre WB si ambos coinciden.
// ========================================================================

// ForwardA
assign forwardA     = ((rs1EX == rdMEM) && (rdMEM != 0) && we_reg_mem) ? 2'b10 
                    : ((rs1EX == rdWB)  && (rdWB  != 0) && we_reg_wb)  ? 2'b01 
                    : 2'b00 ;

// ForwardB
assign forwardB     = ((rs2EX == rdMEM) && (rdMEM != 0) && we_reg_mem) ? 2'b10 
                    : ((rs2EX == rdWB)  && (rdWB  != 0) && we_reg_wb)  ? 2'b01 
                    : 2'b00 ;

// ========================================================================
//                          STALLS (LW-ALU)
// Con los dos forwarding instrucciones tipo LW-ALU requieren un nop
// ========================================================================

logic stall;
assign stall = result_src_0 && // indica que es un load
               (rdEX != 0)  && // no es el registro x0
               ((rdEX == rs1DE) || (rdEX == rs2DE)); // algún operando de DE depende de rdEX

// Si los 3 no se cumplen a la vez, entonces no es un RAW o bien es un ALU-ALU

assign stallIF = stall;
assign stallD = stall;

// ========================================================================
//                          FLUSH
// Para riesgos de control, es necesario limpiar las instrucciones incorrectas
// ========================================================================

assign flushD = pc_src_exOUT;
assign flushE = stall | pc_src_exOUT;

endmodule 