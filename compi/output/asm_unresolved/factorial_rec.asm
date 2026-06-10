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

    addi x3, x0, 5                                      ; pc=0x0030
    add x11, x3, x0                                     ; pc=0x0034
    jal x1, fact                                        ; pc=0x0038
    add x4, x11, x0                                     ; pc=0x003C
    sw x4, -4(x17) ; t4                                 ; pc=0x0040
    lw x5, -4(x17) ; t4                                 ; pc=0x0044
    add x11, x5, x0                                     ; pc=0x0048
    jal x0, .L_ir_1_main_end                            ; pc=0x004C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0050
    addi x2, x2, 12                                     ; pc=0x0054
    freeze                                              ; pc=0x0058

fact:
    ; prologue
    addiSigned x2, x2, -28                              ; pc=0x005C
    sw x1, 0(x2)                                        ; pc=0x0060
    sw x17, 4(x2)                                       ; pc=0x0064
    addi x17, x2, 28                                    ; pc=0x0068

    sw x11, -4(x17) ; parametro n                       ; pc=0x006C

    lw x6, -4(x17) ; n                                  ; pc=0x0070
    addi x7, x0, 1                                      ; pc=0x0074
    addi x8, x0, 0                                      ; pc=0x0078
    bge x7, x6, .L_ir_3_ir_cmp_true                     ; pc=0x007C
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x0080
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0084
.L_ir_4_ir_cmp_end:
    sw x8, -8(x17) ; t0                                 ; pc=0x0088
    lw x9, -8(x17) ; t0                                 ; pc=0x008C
    beq x9, x0, L_else_0                                ; pc=0x0090
    addi x10, x0, 1                                     ; pc=0x0094
    add x11, x10, x0                                    ; pc=0x0098
    jal x0, .L_ir_2_fact_end                            ; pc=0x009C
    jal x0, L_end_if_1                                  ; pc=0x00A0
L_else_0:
L_end_if_1:
    lw x3, -4(x17) ; n                                  ; pc=0x00A4
    addi x4, x0, 1                                      ; pc=0x00A8
    sub x5, x3, x4                                      ; pc=0x00AC
    sw x5, -12(x17) ; t1                                ; pc=0x00B0
    lw x8, -12(x17) ; t1                                ; pc=0x00B4
    add x11, x8, x0                                     ; pc=0x00B8
    jal x1, fact                                        ; pc=0x00BC
    add x7, x11, x0                                     ; pc=0x00C0
    sw x7, -16(x17) ; t2                                ; pc=0x00C4
    lw x6, -4(x17) ; n                                  ; pc=0x00C8
    lw x9, -16(x17) ; t2                                ; pc=0x00CC
    mul x10, x6, x9                                     ; pc=0x00D0
    sw x10, -20(x17) ; t3                               ; pc=0x00D4
    lw x5, -20(x17) ; t3                                ; pc=0x00D8
    add x11, x5, x0                                     ; pc=0x00DC
    jal x0, .L_ir_2_fact_end                            ; pc=0x00E0
.L_ir_2_fact_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00E4
    lw x17, 4(x2)                                       ; pc=0x00E8
    addi x2, x2, 28                                     ; pc=0x00EC
    jalr x1, 0                                          ; pc=0x00F0