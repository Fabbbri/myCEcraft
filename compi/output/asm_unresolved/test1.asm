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
    addiSigned x2, x2, -52                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 52                                    ; pc=0x002C

    addi x4, x0, 1                                      ; pc=0x0030
    sw x4, -40(x17) ; lista[0]                          ; pc=0x0034
    addi x5, x0, 2                                      ; pc=0x0038
    sw x5, -36(x17) ; lista[1]                          ; pc=0x003C
    addi x6, x0, 3                                      ; pc=0x0040
    sw x6, -32(x17) ; lista[2]                          ; pc=0x0044
    addi x7, x0, 4                                      ; pc=0x0048
    sw x7, -28(x17) ; lista[3]                          ; pc=0x004C
    addi x8, x0, 5                                      ; pc=0x0050
    sw x8, -24(x17) ; lista[4]                          ; pc=0x0054
    addi x9, x0, 6                                      ; pc=0x0058
    sw x9, -20(x17) ; lista[5]                          ; pc=0x005C
    addi x10, x0, 7                                     ; pc=0x0060
    sw x10, -16(x17) ; lista[6]                         ; pc=0x0064
    addi x4, x0, 8                                      ; pc=0x0068
    sw x4, -12(x17) ; lista[7]                          ; pc=0x006C
    addi x5, x0, 9                                      ; pc=0x0070
    sw x5, -8(x17) ; lista[8]                           ; pc=0x0074
    addi x6, x0, 11                                     ; pc=0x0078
    sw x6, -4(x17) ; lista[9]                           ; pc=0x007C
    addiSigned x7, x17, -40                             ; pc=0x0080
    add x11, x7, x0                                     ; pc=0x0084
    jal x1, sume                                        ; pc=0x0088
    add x8, x11, x0                                     ; pc=0x008C
    add x3, x8, x0 ; promote t14                        ; pc=0x0090
    add x11, x3, x0                                     ; pc=0x0094
    jal x0, .L_ir_1_main_end                            ; pc=0x0098
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x009C
    addi x2, x2, 52                                     ; pc=0x00A0
    freeze                                              ; pc=0x00A4

es_primo:
    ; prologue
    addiSigned x2, x2, -56                              ; pc=0x00A8
    sw x1, 0(x2)                                        ; pc=0x00AC
    sw x17, 4(x2)                                       ; pc=0x00B0
    addi x17, x2, 56                                    ; pc=0x00B4

    add x3, x11, x0 ; parametro promovido n             ; pc=0x00B8
    add x4, x12, x0 ; parametro promovido divisor       ; pc=0x00BC

    addi x7, x0, 1                                      ; pc=0x00C0
    addi x8, x0, 0                                      ; pc=0x00C4
    bge x7, x3, .L_ir_3_ir_cmp_true                     ; pc=0x00C8
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x00CC
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x00D0
.L_ir_4_ir_cmp_end:
    sw x8, -20(x17) ; t0                                ; pc=0x00D4
    lw x9, -20(x17) ; t0                                ; pc=0x00D8
    beq x9, x0, L_else_0                                ; pc=0x00DC
    addi x10, x0, 0                                     ; pc=0x00E0
    add x11, x10, x0                                    ; pc=0x00E4
    jal x0, .L_ir_2_es_primo_end                        ; pc=0x00E8
    jal x0, L_end_if_1                                  ; pc=0x00EC
L_else_0:
L_end_if_1:
    mul x8, x4, x4                                      ; pc=0x00F0
    sw x8, -24(x17) ; t1                                ; pc=0x00F4
    lw x7, -24(x17) ; t1                                ; pc=0x00F8
    addi x9, x0, 0                                      ; pc=0x00FC
    blt x3, x7, .L_ir_5_ir_cmp_true                     ; pc=0x0100
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x0104
.L_ir_5_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0108
.L_ir_6_ir_cmp_end:
    sw x9, -28(x17) ; t2                                ; pc=0x010C
    lw x10, -28(x17) ; t2                               ; pc=0x0110
    beq x10, x0, L_else_2                               ; pc=0x0114
    addi x8, x0, 1                                      ; pc=0x0118
    add x11, x8, x0                                     ; pc=0x011C
    jal x0, .L_ir_2_es_primo_end                        ; pc=0x0120
    jal x0, L_end_if_3                                  ; pc=0x0124
L_else_2:
L_end_if_3:
    div x9, x3, x4                                      ; pc=0x0128
    add x5, x9, x0 ; promote cociente                   ; pc=0x012C
    mul x7, x5, x4                                      ; pc=0x0130
    add x6, x7, x0 ; promote producto                   ; pc=0x0134
    addi x10, x0, 0                                     ; pc=0x0138
    beq x6, x3, .L_ir_7_ir_cmp_true                     ; pc=0x013C
    jal x0, .L_ir_8_ir_cmp_end                          ; pc=0x0140
.L_ir_7_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x0144
.L_ir_8_ir_cmp_end:
    sw x10, -40(x17) ; t5                               ; pc=0x0148
    lw x8, -40(x17) ; t5                                ; pc=0x014C
    beq x8, x0, L_else_4                                ; pc=0x0150
    addi x9, x0, 0                                      ; pc=0x0154
    add x11, x9, x0                                     ; pc=0x0158
    jal x0, .L_ir_2_es_primo_end                        ; pc=0x015C
    jal x0, L_end_if_5                                  ; pc=0x0160
L_else_4:
L_end_if_5:
    addi x7, x0, 1                                      ; pc=0x0164
    add x10, x4, x7                                     ; pc=0x0168
    sw x10, -44(x17) ; t6                               ; pc=0x016C
    add x11, x3, x0                                     ; pc=0x0170
    lw x8, -44(x17) ; t6                                ; pc=0x0174
    add x12, x8, x0                                     ; pc=0x0178
    sw x5, -12(x17) ; cociente                          ; pc=0x017C
    sw x4, -8(x17) ; divisor                            ; pc=0x0180
    sw x3, -4(x17) ; n                                  ; pc=0x0184
    sw x6, -16(x17) ; producto                          ; pc=0x0188
    jal x1, es_primo                                    ; pc=0x018C
    add x9, x11, x0                                     ; pc=0x0190
    sw x9, -48(x17) ; t7                                ; pc=0x0194
    lw x10, -48(x17) ; t7                               ; pc=0x0198
    add x11, x10, x0                                    ; pc=0x019C
    jal x0, .L_ir_2_es_primo_end                        ; pc=0x01A0
.L_ir_2_es_primo_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x01A4
    lw x17, 4(x2)                                       ; pc=0x01A8
    addi x2, x2, 56                                     ; pc=0x01AC
    jalr x1, 0                                          ; pc=0x01B0

sume:
    ; prologue
    addiSigned x2, x2, -44                              ; pc=0x01B4
    sw x1, 0(x2)                                        ; pc=0x01B8
    sw x17, 4(x2)                                       ; pc=0x01BC
    addi x17, x2, 44                                    ; pc=0x01C0

    sw x11, -4(x17) ; parametro lista                   ; pc=0x01C4

    addi x5, x0, 0                                      ; pc=0x01C8
    add x4, x5, x0 ; promote suma                       ; pc=0x01CC
    addi x6, x0, 0                                      ; pc=0x01D0
    add x3, x6, x0 ; promote i                          ; pc=0x01D4
L_for_start_6:
    addi x7, x0, 10                                     ; pc=0x01D8
    addi x8, x0, 0                                      ; pc=0x01DC
    blt x3, x7, .L_ir_10_ir_cmp_true                    ; pc=0x01E0
    jal x0, .L_ir_11_ir_cmp_end                         ; pc=0x01E4
.L_ir_10_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x01E8
.L_ir_11_ir_cmp_end:
    sw x8, -16(x17) ; t8                                ; pc=0x01EC
    lw x9, -16(x17) ; t8                                ; pc=0x01F0
    beq x9, x0, L_for_end_7                             ; pc=0x01F4
    add x10, x3, x3                                     ; pc=0x01F8
    add x10, x10, x10                                   ; pc=0x01FC
    lw x5, -4(x17) ; base ref lista                     ; pc=0x0200
    add x5, x5, x10                                     ; pc=0x0204
    lw x6, 0(x5)                                        ; pc=0x0208
    sw x6, -20(x17) ; t9                                ; pc=0x020C
    lw x8, -20(x17) ; t9                                ; pc=0x0210
    add x11, x8, x0                                     ; pc=0x0214
    addi x7, x0, 2                                      ; pc=0x0218
    add x12, x7, x0                                     ; pc=0x021C
    sw x3, -12(x17) ; i                                 ; pc=0x0220
    sw x4, -8(x17) ; suma                               ; pc=0x0224
    jal x1, es_primo                                    ; pc=0x0228
    add x9, x11, x0                                     ; pc=0x022C
    sw x9, -24(x17) ; t10                               ; pc=0x0230
    lw x10, -24(x17) ; t10                              ; pc=0x0234
    beq x10, x0, L_else_8                               ; pc=0x0238
    lw x3, -12(x17) ; i                                 ; pc=0x023C
    add x5, x3, x3                                      ; pc=0x0240
    add x5, x5, x5                                      ; pc=0x0244
    lw x6, -4(x17) ; base ref lista                     ; pc=0x0248
    add x6, x6, x5                                      ; pc=0x024C
    lw x8, 0(x6)                                        ; pc=0x0250
    sw x8, -28(x17) ; t11                               ; pc=0x0254
    lw x4, -8(x17) ; suma                               ; pc=0x0258
    lw x7, -28(x17) ; t11                               ; pc=0x025C
    add x9, x4, x7                                      ; pc=0x0260
    add x4, x9, x0 ; promote suma                       ; pc=0x0264
    jal x0, L_end_if_9                                  ; pc=0x0268
L_else_8:
L_end_if_9:
    addi x10, x0, 1                                     ; pc=0x026C
    add x5, x3, x10                                     ; pc=0x0270
    add x3, x5, x0 ; promote i                          ; pc=0x0274
    jal x0, L_for_start_6                               ; pc=0x0278
L_for_end_7:
    add x11, x4, x0                                     ; pc=0x027C
    jal x0, .L_ir_9_sume_end                            ; pc=0x0280
.L_ir_9_sume_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0284
    lw x17, 4(x2)                                       ; pc=0x0288
    addi x2, x2, 44                                     ; pc=0x028C
    jalr x1, 0                                          ; pc=0x0290