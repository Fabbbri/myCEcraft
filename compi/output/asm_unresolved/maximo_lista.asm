; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.text

maximo_lista:
    ; prologue
    addiSigned x2, x2, -64                              ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 64                                    ; pc=0x000C

    sw x11, -4(x17) ; parametro lista                   ; pc=0x0010
    sw x12, -8(x17) ; parametro largo                   ; pc=0x0014

    addi x5, x0, 0                                      ; pc=0x0018
    add x6, x5, x5                                      ; pc=0x001C
    add x6, x6, x6                                      ; pc=0x0020
    lw x7, -4(x17) ; base ref lista                     ; pc=0x0024
    add x7, x7, x6                                      ; pc=0x0028
    lw x8, 0(x7)                                        ; pc=0x002C
    sw x8, -32(x17) ; t0                                ; pc=0x0030
    lw x9, -32(x17) ; t0                                ; pc=0x0034
    add x4, x9, x0 ; promote maximo                     ; pc=0x0038
    addi x10, x0, 0                                     ; pc=0x003C
    sw x10, -16(x17) ; num                              ; pc=0x0040
    addi x6, x0, 0                                      ; pc=0x0044
    sw x6, -20(x17) ; esMayor                           ; pc=0x0048
    lw x5, -8(x17) ; largo                              ; pc=0x004C
    sw x5, -24(x17) ; limite                            ; pc=0x0050
    addi x7, x0, 0                                      ; pc=0x0054
    add x3, x7, x0 ; promote i                          ; pc=0x0058
L_for_start_0:
    lw x8, -24(x17) ; limite                            ; pc=0x005C
    addi x9, x0, 0                                      ; pc=0x0060
    add x10, x8, x9                                     ; pc=0x0064
    sw x10, -36(x17) ; t1                               ; pc=0x0068
    lw x6, -36(x17) ; t1                                ; pc=0x006C
    addi x5, x0, 0                                      ; pc=0x0070
    blt x3, x6, .L_ir_1_ir_cmp_true                     ; pc=0x0074
    jal x0, .L_ir_2_ir_cmp_end                          ; pc=0x0078
.L_ir_1_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x007C
.L_ir_2_ir_cmp_end:
    sw x5, -40(x17) ; t2                                ; pc=0x0080
    lw x7, -40(x17) ; t2                                ; pc=0x0084
    beq x7, x0, L_for_end_1                             ; pc=0x0088
    add x10, x3, x3                                     ; pc=0x008C
    add x10, x10, x10                                   ; pc=0x0090
    lw x9, -4(x17) ; base ref lista                     ; pc=0x0094
    add x9, x9, x10                                     ; pc=0x0098
    lw x8, 0(x9)                                        ; pc=0x009C
    sw x8, -44(x17) ; t3                                ; pc=0x00A0
    lw x5, -44(x17) ; t3                                ; pc=0x00A4
    sw x5, -16(x17) ; num                               ; pc=0x00A8
    lw x6, -16(x17) ; num                               ; pc=0x00AC
    addi x7, x0, 0                                      ; pc=0x00B0
    blt x4, x6, .L_ir_3_ir_cmp_true                     ; pc=0x00B4
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x00B8
.L_ir_3_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x00BC
.L_ir_4_ir_cmp_end:
    sw x7, -20(x17) ; esMayor                           ; pc=0x00C0
    lw x10, -20(x17) ; esMayor                          ; pc=0x00C4
    addi x9, x0, 0                                      ; pc=0x00C8
    add x8, x10, x9                                     ; pc=0x00CC
    sw x8, -52(x17) ; t5                                ; pc=0x00D0
    lw x5, -52(x17) ; t5                                ; pc=0x00D4
    beq x5, x0, L_else_2                                ; pc=0x00D8
    lw x7, -16(x17) ; num                               ; pc=0x00DC
    add x4, x7, x0 ; promote maximo                     ; pc=0x00E0
    jal x0, L_end_if_3                                  ; pc=0x00E4
L_else_2:
L_end_if_3:
    addi x6, x0, 1                                      ; pc=0x00E8
    add x8, x3, x6                                      ; pc=0x00EC
    add x3, x8, x0 ; promote i                          ; pc=0x00F0
    jal x0, L_for_start_0                               ; pc=0x00F4
L_for_end_1:
    add x11, x4, x0                                     ; pc=0x00F8
    jal x0, .L_ir_0_maximo_lista_end                    ; pc=0x00FC
.L_ir_0_maximo_lista_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0100
    lw x17, 4(x2)                                       ; pc=0x0104
    addi x2, x2, 64                                     ; pc=0x0108
    jalr x1, 0                                          ; pc=0x010C

    ; final de programa
    freeze                                              ; pc=0x0110