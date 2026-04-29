module control_unit(
    input logic [3:0] opcode, // opcode 3:0
    input logic [3:0] func23, // func 23:20
    input logic func19, // func 19
    input logic [1:0] func15, // func 15:14

    output logic [4:0] alu_control,
    output logic we_reg, size,
    output logic imm_src2,
    output logic [1:0] imm_src, 
    output logic we_mem,
    output logic beq, bne, blt, bge, jump, 
    output logic w_regv, w_memv,
    output logic [1:0] result_src, alu_src,
    output logic neather_portal, neather_reset, neather_wreg_src
    // 18 señales de control
    // neather_mode es logica en DECODE (de registro secureMode)
    // tea_src = alu_control[0] es logica en DECODE (cable)
    // pc_enable = (-) stall es logica en ISSUE (decodificador)
);

// ========================================================================
//                          1 ALU_CONTROL [4:0]
// ========================================================================
assign alu_control  = (opcode == 4'b0000) ? {func23, func19} // TypeR
                    : (opcode == 4'b0001) ? {5'b00000} // TypeI
                    : (opcode == 4'b0010) ? {5'b00000} // Type SW/LW
                    : (opcode == 4'b0011) ? {5'b00000} // Type SB/LB
                    // 0100 Type J es x, no importa
                    // 0101 no usada
                    : (opcode == 4'b0110) ? {5'b00001} // Type B y Logv
                    // 0111 no usada
                    // 1000 no usada
                    // 1001 no usada
                    : (opcode == 4'b1010) ? {func23, func19} // Type RVault
                    : (opcode == 4'b1011) ? {func23, func19} // Change V (RV)
                    : (opcode == 4'b1100) ? {func23, func19} // Close V 
                    // 1101 no usada
                    : (opcode == 4'b1110) ? {5'b00000} // Type SW/LW V
                    : (opcode == 4'b1111) ? {5'b00000} // Type Imm V
                    : 5'b0; // el resto no importa

// ========================================================================
//                         2 WE_REG [0]
// ========================================================================
assign we_reg       = (opcode == 4'b0000 && func23 == 4'b0101 && func19 == 1'b1) ? 1'b0 // FREEZE
                    : (opcode == 4'b0000 && func23 == 4'b0110 && func19 == 1'b0) ? 1'b0 // SLEEP ... casos excepción primero
                    : (opcode == 4'b0000) ? 1'b1 // TypeR
                    : (opcode == 4'b0001) ? 1'b1 // TypeI
                    : (opcode == 4'b0010 && func19 == 1'b0) ? 1'b0 // Type SW
                    : (opcode == 4'b0010 && func19 == 1'b1) ? 1'b1 // Type LW
                    : (opcode == 4'b0011 && func19 == 1'b0) ? 1'b0 // Type SB
                    : (opcode == 4'b0011 && func19 == 1'b1) ? 1'b1 // Type LB
                    : (opcode == 4'b0100 && func19 == 1'b0) ? 1'b0 // Type JAL
                    : (opcode == 4'b0100 && func19 == 1'b1) ? 1'b1 // Type JALR
                    // 0101 no usada
                    : (opcode == 4'b0110) ? 1'b0 // Type B y Logv
                    // 0111 no usada
                    // 1000 no usada
                    // 1001 no usada
                    : (opcode == 4'b1010) ? 1'b1 // Type RVault
                    : (opcode == 4'b1011) ? 1'b0// Change V (RV)
                    : (opcode == 4'b1100) ? 1'b0 // Close V 
                    // 1101 no usada
                    : (opcode == 4'b1110) ? 1'b0 // Type SW/LW V
                    : (opcode == 4'b1111) ? 1'b0 // Type Imm V
                    : 1'b0; // el resto no importa

// ========================================================================
//                          3 SIZE [0]
// ========================================================================

assign size         = (opcode == 4'b0010) ? 1'b1 // STORE o LOAD WORD
                    : (opcode == 4'b0011) ? 1'b0 // STORE o LOAD BYTE
                    : 1'b1; // el resto no importa

// ========================================================================
//                         4 imm_src2 [2]
// ========================================================================

assign imm_src2     = (opcode == 4'b0001 && func15 == 2'b01) ? 1'b0 // addiHIGH
                    : (opcode == 4'b0001) ? 1'b1 // resto de Type I
                    : (opcode == 4'b0010 && func19 == 1'b0) ? 1'b0 // SW
                    : (opcode == 4'b0010 && func19 == 1'b1) ? 1'b1 // LW
                    : (opcode == 4'b0011 && func19 == 1'b0) ? 1'b0 // SB
                    : (opcode == 4'b0011 && func19 == 1'b1) ? 1'b1 // LB
                    : (opcode == 4'b0100 && func19 == 1'b0) ? 1'b0 // JAL
                    : (opcode == 4'b0100 && func19 == 1'b1) ? 1'b1 // JALR
                    : (opcode == 4'b0110) ? 1'b0 // Type B

                    : (opcode == 4'b1110 && func19 == 1'b0) ? 1'b0 // SWV
                    : (opcode == 4'b1110 && func19 == 1'b1) ? 1'b1 // LWV
                    : (opcode == 4'b1111 && func15 == 2'b01) ? 1'b0 // addiHIGHv
                    : (opcode == 4'b1111) ? 1'b1 // Type Imm v
                    : 1'b0; // el resto no importa

// ========================================================================
//                         5 imm_src [1:0]
// ========================================================================

assign imm_src      = (opcode == 4'b0001 && func15 == 2'b00) ? 2'b10 // addi
                    : (opcode == 4'b0001) ? 2'b11 // resto de Type I
                    : (opcode == 4'b0010 && func19 == 1'b0) ? 2'b01 // SW
                    : (opcode == 4'b0010 && func19 == 1'b1) ? 2'b00 // LW
                    : (opcode == 4'b0011 && func19 == 1'b0) ? 2'b01 // SB
                    : (opcode == 4'b0011 && func19 == 1'b1) ? 2'b00 // LB
                    : (opcode == 4'b0100 && func19 == 1'b0) ? 2'b00// JAL
                    : (opcode == 4'b0100 && func19 == 1'b1) ? 2'b01 // JALR
                    : (opcode == 4'b0110) ? 2'b10 // Type B

                    : (opcode == 4'b1110 && func19 == 1'b0) ? 2'b01 // SWV
                    : (opcode == 4'b1110 && func19 == 1'b1) ? 2'b00 // LWV
                    : (opcode == 4'b1111 && func15 == 2'b00) ? 2'b00 // addiLOWv
                    : (opcode == 4'b1111) ? 2'b11 // Type Imm v
                    : 2'b00; // el resto no importa

// ========================================================================
//                         6 WE_MEM [0]
// ========================================================================

assign we_mem       = (opcode == 4'b0010 && func19 == 1'b0) ? 1'b1 // SW
                    : (opcode == 4'b0010 && func19 == 1'b1) ? 1'b0 // LW
                    : (opcode == 4'b0011 && func19 == 1'b0) ? 1'b1 // SB
                    : (opcode == 4'b0011 && func19 == 1'b1) ? 1'b0 // LB
                    : 1'b0; // el resto NO ESCRIBE (0)

// ========================================================================
//                        7,8,9,10  Branches [0] y 11 JUMP [0]
// ========================================================================

assign beq  = (opcode == 4'b0110 && func23 == 4'b0000 && func19 == 1'b0) ? 1'b1 // beq
            : 1'b0;

assign bne  = (opcode == 4'b0110 && func23 == 4'b0000 && func19 == 1'b1) ? 1'b1 // bne
            : (opcode == 4'b0110 && func23 == 4'b0010 && func19 == 1'b0) ? 1'b1 // logvb
            : 1'b0;

assign blt  = (opcode == 4'b0110 && func23 == 4'b0001 && func19 == 1'b0) ? 1'b1 // blt
            : 1'b0;

assign bge  = (opcode == 4'b0110 && func23 == 4'b0001 && func19 == 1'b1) ? 1'b1 // bge
            : 1'b0;
            
assign jump = (opcode == 4'b0100) ? 1'b1 // jal y jalr
            : 1'b0;

// ========================================================================
//                         12 W_REGV [0]
// ========================================================================

assign w_regv   = (opcode == 4'b1011) ? 1'b1 // changev
                : (opcode == 4'b1110 && func19 == 1'b1) ? 1'b1 // lwv
                : (opcode == 4'b1111) ? 1'b1 // addiLOWv y addiHIGHv
                : 1'b0; // el resto NO escribe 

// ========================================================================
//                        13  W_MEMV [0]
// ========================================================================

assign w_memv   = (opcode == 4'b1110 && func19 == 1'b0) ? 1'b1 // swv
                : 1'b0; // el resto NO escribe 

// ========================================================================
//                        14  RESULT_SRC [1:0]
// ========================================================================

assign result_src   = (opcode == 4'b0010 && func19 == 1'b1) ? 2'b01 // LW
                    : (opcode == 4'b0011 && func19 == 1'b1) ? 2'b01 // LB
                    : (opcode == 4'b0100 && func19 == 1'b0) ? 2'b10 // jal hace ra = PC+4
                    : (opcode == 4'b0100 && func19 == 1'b1) ? 2'b00 // jar hace ra=ra+x0
                    : (opcode == 4'b1010) ? 2'b11 // TEA operations srlv y sllv
                    : 2'b00; // el resto es 00 o no importa

// ========================================================================
//                         15  ALU_SRC [1:0]
// ========================================================================

assign alu_src  = (opcode == 4'b0001) ? 2'b11 // Type Imm
                : (opcode == 4'b0010) ? 2'b11 // Type SW/LW
                : (opcode == 4'b0011) ? 2'b11 // Type SB/LB
                : (opcode == 4'b0011 && func19 == 1'b1) ? 2'b00 // CAMBIAR
                : (opcode == 4'b0100) ? 2'b11 // Type JALR porque hace ra = ra + imm ... JAL no es xx
                : (opcode == 4'b0110) ? 2'b00 // Type BRANCH
                : (opcode == 4'b1010) ? 2'b01 // Type TEA (RVault)
                : (opcode == 4'b1110) ? 2'b10 // Type SWv/LWv Vault
                : 2'b00; // el resto es 00 o no importa
    
// ========================================================================
//                         16  NEATHER_PORTAL [0]
// ========================================================================

assign neather_portal   = (opcode == 4'b0110 && func23 == 4'b0010 && func19 == 1'b0) ? 1'b1
                        : 1'b0; // el resto NO PUEDE activar el portal

// ========================================================================
//                         17  NEATHER_RESET [0]
// ========================================================================

assign neather_reset    = (opcode == 4'b1100) ? 1'b1
                        : 1'b0; // el resto NO puede cerrar el portal

// ========================================================================
//                         18  NEATHER_WREG_SRC [0]
// ========================================================================

assign neather_wreg_src = (opcode == 4'b1110 && func19 == 1'b1) ? 1'b1
                        : 1'b0; // el resto no importa o es 0

endmodule