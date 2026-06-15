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
    addiSigned x2, x2, -192                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 192                                   ; pc=0x002C

    addi x5, x0, 1                                      ; pc=0x0030
    sw x5, -16(x17) ; A[0]                              ; pc=0x0034
    addi x6, x0, 2                                      ; pc=0x0038
    sw x6, -12(x17) ; A[1]                              ; pc=0x003C
    addi x7, x0, 3                                      ; pc=0x0040
    sw x7, -8(x17) ; A[2]                               ; pc=0x0044
    addi x8, x0, 4                                      ; pc=0x0048
    sw x8, -4(x17) ; A[3]                               ; pc=0x004C
    addi x9, x0, 5                                      ; pc=0x0050
    sw x9, -32(x17) ; B[0]                              ; pc=0x0054
    addi x10, x0, 6                                     ; pc=0x0058
    sw x10, -28(x17) ; B[1]                             ; pc=0x005C
    addi x5, x0, 7                                      ; pc=0x0060
    sw x5, -24(x17) ; B[2]                              ; pc=0x0064
    addi x6, x0, 8                                      ; pc=0x0068
    sw x6, -20(x17) ; B[3]                              ; pc=0x006C
    addi x7, x0, 0                                      ; pc=0x0070
    sw x7, -48(x17) ; C[0]                              ; pc=0x0074
    addi x8, x0, 0                                      ; pc=0x0078
    sw x8, -44(x17) ; C[1]                              ; pc=0x007C
    addi x9, x0, 0                                      ; pc=0x0080
    sw x9, -40(x17) ; C[2]                              ; pc=0x0084
    addi x10, x0, 0                                     ; pc=0x0088
    sw x10, -36(x17) ; C[3]                             ; pc=0x008C
    addi x5, x0, 0                                      ; pc=0x0090
    add x3, x5, x0 ; promote i                          ; pc=0x0094
L_for_start_0:
    addi x6, x0, 2                                      ; pc=0x0098
    addi x7, x0, 0                                      ; pc=0x009C
    blt x3, x6, .L_ir_2_ir_cmp_true                     ; pc=0x00A0
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x00A4
.L_ir_2_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x00A8
.L_ir_3_ir_cmp_end:
    sw x7, -96(x17) ; t0                                ; pc=0x00AC
    lw x8, -96(x17) ; t0                                ; pc=0x00B0
    beq x8, x0, L_for_end_1                             ; pc=0x00B4
    addi x9, x0, 0                                      ; pc=0x00B8
    add x4, x9, x0 ; promote j                          ; pc=0x00BC
L_for_start_2:
    addi x10, x0, 2                                     ; pc=0x00C0
    addi x5, x0, 0                                      ; pc=0x00C4
    blt x4, x10, .L_ir_4_ir_cmp_true                    ; pc=0x00C8
    jal x0, .L_ir_5_ir_cmp_end                          ; pc=0x00CC
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x00D0
.L_ir_5_ir_cmp_end:
    sw x5, -100(x17) ; t2                               ; pc=0x00D4
    lw x7, -100(x17) ; t2                               ; pc=0x00D8
    beq x7, x0, L_for_end_3                             ; pc=0x00DC
    addi x6, x0, 0                                      ; pc=0x00E0
    sw x6, -56(x17) ; suma                              ; pc=0x00E4
    addi x8, x0, 0                                      ; pc=0x00E8
    sw x8, -84(x17) ; k                                 ; pc=0x00EC
L_for_start_4:
    lw x9, -84(x17) ; k                                 ; pc=0x00F0
    addi x5, x0, 2                                      ; pc=0x00F4
    addi x10, x0, 0                                     ; pc=0x00F8
    blt x9, x5, .L_ir_6_ir_cmp_true                     ; pc=0x00FC
    jal x0, .L_ir_7_ir_cmp_end                          ; pc=0x0100
.L_ir_6_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x0104
.L_ir_7_ir_cmp_end:
    sw x10, -104(x17) ; t4                              ; pc=0x0108
    lw x7, -104(x17) ; t4                               ; pc=0x010C
    beq x7, x0, L_for_end_5                             ; pc=0x0110
    addi x6, x0, 2                                      ; pc=0x0114
    mul x8, x3, x6                                      ; pc=0x0118
    sw x8, -108(x17) ; t6                               ; pc=0x011C
    lw x10, -108(x17) ; t6                              ; pc=0x0120
    lw x5, -84(x17) ; k                                 ; pc=0x0124
    add x9, x10, x5                                     ; pc=0x0128
    sw x9, -112(x17) ; t7                               ; pc=0x012C
    lw x7, -112(x17) ; t7                               ; pc=0x0130
    add x8, x7, x7                                      ; pc=0x0134
    add x8, x8, x8                                      ; pc=0x0138
    addiSigned x6, x17, -16                             ; pc=0x013C
    add x6, x6, x8                                      ; pc=0x0140
    lw x9, 0(x6)                                        ; pc=0x0144
    sw x9, -116(x17) ; t8                               ; pc=0x0148
    lw x5, -84(x17) ; k                                 ; pc=0x014C
    addi x10, x0, 2                                     ; pc=0x0150
    mul x8, x5, x10                                     ; pc=0x0154
    sw x8, -120(x17) ; t9                               ; pc=0x0158
    lw x7, -120(x17) ; t9                               ; pc=0x015C
    add x6, x7, x4                                      ; pc=0x0160
    sw x6, -124(x17) ; t10                              ; pc=0x0164
    lw x9, -124(x17) ; t10                              ; pc=0x0168
    add x8, x9, x9                                      ; pc=0x016C
    add x8, x8, x8                                      ; pc=0x0170
    addiSigned x10, x17, -32                            ; pc=0x0174
    add x10, x10, x8                                    ; pc=0x0178
    lw x5, 0(x10)                                       ; pc=0x017C
    sw x5, -128(x17) ; t11                              ; pc=0x0180
    lw x6, -116(x17) ; t8                               ; pc=0x0184
    lw x7, -128(x17) ; t11                              ; pc=0x0188
    mul x8, x6, x7                                      ; pc=0x018C
    sw x8, -132(x17) ; t12                              ; pc=0x0190
    lw x9, -56(x17) ; suma                              ; pc=0x0194
    lw x10, -132(x17) ; t12                             ; pc=0x0198
    add x5, x9, x10                                     ; pc=0x019C
    sw x5, -56(x17) ; suma                              ; pc=0x01A0
    lw x8, -84(x17) ; k                                 ; pc=0x01A4
    addi x7, x0, 1                                      ; pc=0x01A8
    add x6, x8, x7                                      ; pc=0x01AC
    sw x6, -84(x17) ; k                                 ; pc=0x01B0
    jal x0, L_for_start_4                               ; pc=0x01B4
L_for_end_5:
    addi x5, x0, 2                                      ; pc=0x01B8
    mul x10, x3, x5                                     ; pc=0x01BC
    sw x10, -144(x17) ; t16                             ; pc=0x01C0
    lw x9, -144(x17) ; t16                              ; pc=0x01C4
    add x6, x9, x4                                      ; pc=0x01C8
    sw x6, -148(x17) ; t17                              ; pc=0x01CC
    lw x7, -56(x17) ; suma                              ; pc=0x01D0
    lw x8, -148(x17) ; t17                              ; pc=0x01D4
    add x10, x8, x8                                     ; pc=0x01D8
    add x10, x10, x10                                   ; pc=0x01DC
    addiSigned x5, x17, -48                             ; pc=0x01E0
    add x5, x5, x10                                     ; pc=0x01E4
    sw x7, 0(x5)                                        ; pc=0x01E8
    addi x6, x0, 1                                      ; pc=0x01EC
    add x9, x4, x6                                      ; pc=0x01F0
    add x4, x9, x0 ; promote j                          ; pc=0x01F4
    jal x0, L_for_start_2                               ; pc=0x01F8
L_for_end_3:
    addi x10, x0, 1                                     ; pc=0x01FC
    add x8, x3, x10                                     ; pc=0x0200
    add x3, x8, x0 ; promote i                          ; pc=0x0204
    jal x0, L_for_start_0                               ; pc=0x0208
L_for_end_1:
    addi x5, x0, 0                                      ; pc=0x020C
    add x7, x5, x5                                      ; pc=0x0210
    add x7, x7, x7                                      ; pc=0x0214
    addiSigned x9, x17, -48                             ; pc=0x0218
    add x9, x9, x7                                      ; pc=0x021C
    lw x6, 0(x9)                                        ; pc=0x0220
    sw x6, -160(x17) ; t22                              ; pc=0x0224
    addi x8, x0, 1                                      ; pc=0x0228
    add x10, x8, x8                                     ; pc=0x022C
    add x10, x10, x10                                   ; pc=0x0230
    addiSigned x7, x17, -48                             ; pc=0x0234
    add x7, x7, x10                                     ; pc=0x0238
    lw x5, 0(x7)                                        ; pc=0x023C
    sw x5, -164(x17) ; t23                              ; pc=0x0240
    lw x9, -160(x17) ; t22                              ; pc=0x0244
    lw x6, -164(x17) ; t23                              ; pc=0x0248
    add x10, x9, x6                                     ; pc=0x024C
    sw x10, -168(x17) ; t24                             ; pc=0x0250
    addi x8, x0, 2                                      ; pc=0x0254
    add x7, x8, x8                                      ; pc=0x0258
    add x7, x7, x7                                      ; pc=0x025C
    addiSigned x5, x17, -48                             ; pc=0x0260
    add x5, x5, x7                                      ; pc=0x0264
    lw x10, 0(x5)                                       ; pc=0x0268
    sw x10, -172(x17) ; t25                             ; pc=0x026C
    lw x6, -168(x17) ; t24                              ; pc=0x0270
    lw x9, -172(x17) ; t25                              ; pc=0x0274
    add x7, x6, x9                                      ; pc=0x0278
    sw x7, -176(x17) ; t26                              ; pc=0x027C
    addi x8, x0, 3                                      ; pc=0x0280
    add x5, x8, x8                                      ; pc=0x0284
    add x5, x5, x5                                      ; pc=0x0288
    addiSigned x10, x17, -48                            ; pc=0x028C
    add x10, x10, x5                                    ; pc=0x0290
    lw x7, 0(x10)                                       ; pc=0x0294
    sw x7, -180(x17) ; t27                              ; pc=0x0298
    lw x9, -176(x17) ; t26                              ; pc=0x029C
    lw x6, -180(x17) ; t27                              ; pc=0x02A0
    add x5, x9, x6                                      ; pc=0x02A4
    sw x5, -184(x17) ; t28                              ; pc=0x02A8
    lw x8, -184(x17) ; t28                              ; pc=0x02AC
    add x11, x8, x0                                     ; pc=0x02B0
    jal x0, .L_ir_1_main_end                            ; pc=0x02B4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x02B8
    addi x2, x2, 192                                    ; pc=0x02BC
    freeze                                              ; pc=0x02C0