; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.text

factorial:
    ; prologue
    addiSigned x2, x2, -32                              ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 32                                    ; pc=0x000C

    add x5, x11, x0 ; parametro promovido n             ; pc=0x0010

    addi x7, x0, 1                                      ; pc=0x0014
    add x4, x7, x0 ; promote resultado                  ; pc=0x0018
    addi x8, x0, 1                                      ; pc=0x001C
    add x3, x8, x0 ; promote i                          ; pc=0x0020
L_while_start_0:
    addi x9, x0, 0                                      ; pc=0x0024
    bge x5, x3, .L_ir_1_ir_cmp_true                     ; pc=0x0028
    jal x0, .L_ir_2_ir_cmp_end                          ; pc=0x002C
.L_ir_1_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0030
.L_ir_2_ir_cmp_end:
    add x6, x9, x0 ; promote t0                         ; pc=0x0034
    beq x6, x0, L_while_end_1                           ; pc=0x0038
    mul x10, x4, x3                                     ; pc=0x003C
    add x4, x10, x0 ; promote resultado                 ; pc=0x0040
    addi x7, x0, 1                                      ; pc=0x0044
    add x8, x3, x7                                      ; pc=0x0048
    add x3, x8, x0 ; promote i                          ; pc=0x004C
    jal x0, L_while_start_0                             ; pc=0x0050
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x0054
    jal x0, .L_ir_0_factorial_end                       ; pc=0x0058
.L_ir_0_factorial_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x005C
    lw x17, 4(x2)                                       ; pc=0x0060
    addi x2, x2, 32                                     ; pc=0x0064
    jalr x1, 0                                          ; pc=0x0068

    ; final de programa
    freeze                                              ; pc=0x006C