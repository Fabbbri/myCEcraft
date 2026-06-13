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
    addiSigned x2, x2, -60                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 60                                    ; pc=0x002C

    addi x5, x0, 5                                      ; pc=0x0030
    sw x5, -8(x17) ; datos[0]                           ; pc=0x0034
    addi x6, x0, 12                                     ; pc=0x0038
    sw x6, -4(x17) ; datos[1]                           ; pc=0x003C
    addi x7, x0, 0                                      ; pc=0x0040
    add x8, x7, x7                                      ; pc=0x0044
    add x8, x8, x8                                      ; pc=0x0048
    addiSigned x9, x17, -8                              ; pc=0x004C
    add x9, x9, x8                                      ; pc=0x0050
    lw x10, 0(x9)                                       ; pc=0x0054
    sw x10, -28(x17) ; t5                               ; pc=0x0058
    addi x5, x0, 5                                      ; pc=0x005C
    sw x5, -16(x17) ; y                                 ; pc=0x0060
    lw x6, -28(x17) ; t5                                ; pc=0x0064
    sw x6, -12(x17) ; x                                 ; pc=0x0068
    addi x8, x0, 9                                      ; pc=0x006C
    addi x7, x0, 4                                      ; pc=0x0070
    add x9, x8, x7                                      ; pc=0x0074
    add x4, x9, x0 ; promote independiente              ; pc=0x0078
    lw x10, -12(x17) ; x                                ; pc=0x007C
    add x11, x10, x0                                    ; pc=0x0080
    lw x5, -16(x17) ; y                                 ; pc=0x0084
    add x12, x5, x0                                     ; pc=0x0088
    sw x4, -20(x17) ; independiente                     ; pc=0x008C
    jal x1, combinar                                    ; pc=0x0090
    add x6, x11, x0                                     ; pc=0x0094
    sw x6, -36(x17) ; t7                                ; pc=0x0098
    lw x9, -36(x17) ; t7                                ; pc=0x009C
    add x3, x9, x0 ; promote valor                      ; pc=0x00A0
    lw x4, -20(x17) ; independiente                     ; pc=0x00A4
    addi x7, x0, 0                                      ; pc=0x00A8
    blt x4, x3, .L_ir_2_ir_cmp_true                     ; pc=0x00AC
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x00B0
.L_ir_2_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x00B4
.L_ir_3_ir_cmp_end:
    sw x7, -40(x17) ; t8                                ; pc=0x00B8
    lw x8, -40(x17) ; t8                                ; pc=0x00BC
    beq x8, x0, L_else_2                                ; pc=0x00C0
    lw x10, -12(x17) ; x                                ; pc=0x00C4
    addi x5, x0, 10                                     ; pc=0x00C8
    addi x6, x0, 0                                      ; pc=0x00CC
    blt x10, x5, .L_ir_4_ir_cmp_true                    ; pc=0x00D0
    jal x0, .L_ir_5_ir_cmp_end                          ; pc=0x00D4
.L_ir_4_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x00D8
.L_ir_5_ir_cmp_end:
    sw x6, -44(x17) ; t9                                ; pc=0x00DC
    lw x9, -44(x17) ; t9                                ; pc=0x00E0
    beq x9, x0, L_else_4                                ; pc=0x00E4
    add x7, x3, x4                                      ; pc=0x00E8
    sw x7, -48(x17) ; t10                               ; pc=0x00EC
    lw x8, -48(x17) ; t10                               ; pc=0x00F0
    add x11, x8, x0                                     ; pc=0x00F4
    jal x0, .L_ir_1_main_end                            ; pc=0x00F8
    jal x0, L_end_if_5                                  ; pc=0x00FC
L_else_4:
L_end_if_5:
    add x11, x3, x0                                     ; pc=0x0100
    jal x0, .L_ir_1_main_end                            ; pc=0x0104
    jal x0, L_end_if_3                                  ; pc=0x0108
L_else_2:
    sub x6, x4, x3                                      ; pc=0x010C
    sw x6, -52(x17) ; t11                               ; pc=0x0110
    lw x5, -52(x17) ; t11                               ; pc=0x0114
    add x11, x5, x0                                     ; pc=0x0118
    jal x0, .L_ir_1_main_end                            ; pc=0x011C
L_end_if_3:
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0120
    addi x2, x2, 60                                     ; pc=0x0124
    freeze                                              ; pc=0x0128

combinar:
    ; prologue
    addiSigned x2, x2, -44                              ; pc=0x012C
    sw x1, 0(x2)                                        ; pc=0x0130
    sw x17, 4(x2)                                       ; pc=0x0134
    addi x17, x2, 44                                    ; pc=0x0138

    add x5, x11, x0 ; parametro promovido a             ; pc=0x013C
    add x6, x12, x0 ; parametro promovido b             ; pc=0x0140

    addi x7, x0, 2                                      ; pc=0x0144
    mul x8, x5, x7                                      ; pc=0x0148
    add x3, x8, x0 ; promote parcial                    ; pc=0x014C
    addi x9, x0, 3                                      ; pc=0x0150
    add x10, x6, x9                                     ; pc=0x0154
    add x4, x10, x0 ; promote extra                     ; pc=0x0158
    addi x8, x0, 0                                      ; pc=0x015C
    beq x5, x6, .L_ir_7_ir_cmp_true                     ; pc=0x0160
    jal x0, .L_ir_8_ir_cmp_end                          ; pc=0x0164
.L_ir_7_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0168
.L_ir_8_ir_cmp_end:
    sw x8, -28(x17) ; t2                                ; pc=0x016C
    lw x7, -28(x17) ; t2                                ; pc=0x0170
    beq x7, x0, L_else_0                                ; pc=0x0174
    add x10, x3, x4                                     ; pc=0x0178
    sw x10, -32(x17) ; t3                               ; pc=0x017C
    lw x9, -32(x17) ; t3                                ; pc=0x0180
    add x11, x9, x0                                     ; pc=0x0184
    jal x0, .L_ir_6_combinar_end                        ; pc=0x0188
    jal x0, L_end_if_1                                  ; pc=0x018C
L_else_0:
L_end_if_1:
    sub x8, x3, x4                                      ; pc=0x0190
    sw x8, -36(x17) ; t4                                ; pc=0x0194
    lw x7, -36(x17) ; t4                                ; pc=0x0198
    add x11, x7, x0                                     ; pc=0x019C
    jal x0, .L_ir_6_combinar_end                        ; pc=0x01A0
.L_ir_6_combinar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x01A4
    lw x17, 4(x2)                                       ; pc=0x01A8
    addi x2, x2, 44                                     ; pc=0x01AC
    jalr x1, 0                                          ; pc=0x01B0