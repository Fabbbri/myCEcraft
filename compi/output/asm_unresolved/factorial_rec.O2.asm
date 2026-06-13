; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_ir_0_enderExit                   ; pc=0x0000
    lwv v0, 0(v0)                                       ; pc=0x0004
    sleep ; stall RAW                                   ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0014
.L_ir_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0018
    addi x2, x2, 0x7FF0                                 ; pc=0x001C

    ; prologue
    addiSigned x2, x2, -12                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 12                                    ; pc=0x002C

    addi x4, x0, 5                                      ; pc=0x0030
    add x11, x4, x0                                     ; pc=0x0034
    jal x1, fact                                        ; pc=0x0038
    add x5, x11, x0                                     ; pc=0x003C
    add x3, x5, x0 ; promote t4                         ; pc=0x0040
    add x11, x3, x0                                     ; pc=0x0044
    jal x0, .L_ir_1_main_end                            ; pc=0x0048
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x004C
    addi x2, x2, 12                                     ; pc=0x0050
    freeze                                              ; pc=0x0054

fact:
    ; prologue
    addiSigned x2, x2, -28                              ; pc=0x0058
    sw x1, 0(x2)                                        ; pc=0x005C
    sw x17, 4(x2)                                       ; pc=0x0060
    addi x17, x2, 28                                    ; pc=0x0064

    add x3, x11, x0 ; parametro promovido n             ; pc=0x0068

    addi x7, x0, 1                                      ; pc=0x006C
    addi x8, x0, 0                                      ; pc=0x0070
    bge x7, x3, .L_ir_3_ir_cmp_true                     ; pc=0x0074
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x0078
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x007C
.L_ir_4_ir_cmp_end:
    add x4, x8, x0 ; promote t0                         ; pc=0x0080
    beq x4, x0, L_else_0                                ; pc=0x0084
    addi x9, x0, 1                                      ; pc=0x0088
    add x11, x9, x0                                     ; pc=0x008C
    jal x0, .L_ir_2_fact_end                            ; pc=0x0090
    jal x0, L_end_if_1                                  ; pc=0x0094
L_else_0:
L_end_if_1:
    addi x10, x0, 1                                     ; pc=0x0098
    sub x8, x3, x10                                     ; pc=0x009C
    add x5, x8, x0 ; promote t1                         ; pc=0x00A0
    add x11, x5, x0                                     ; pc=0x00A4
    sw x3, -4(x17) ; n                                  ; pc=0x00A8
    sw x4, -8(x17) ; spill t0                           ; pc=0x00AC
    sw x5, -12(x17) ; spill t1                          ; pc=0x00B0
    jal x1, fact                                        ; pc=0x00B4
    add x7, x11, x0                                     ; pc=0x00B8
    add x6, x7, x0 ; promote t2                         ; pc=0x00BC
    lw x3, -4(x17) ; n                                  ; pc=0x00C0
    mul x9, x3, x6                                      ; pc=0x00C4
    sw x9, -20(x17) ; t3                                ; pc=0x00C8
    lw x8, -20(x17) ; t3                                ; pc=0x00CC
    add x11, x8, x0                                     ; pc=0x00D0
    jal x0, .L_ir_2_fact_end                            ; pc=0x00D4
.L_ir_2_fact_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00D8
    lw x17, 4(x2)                                       ; pc=0x00DC
    addi x2, x2, 28                                     ; pc=0x00E0
    jalr x1, 0                                          ; pc=0x00E4