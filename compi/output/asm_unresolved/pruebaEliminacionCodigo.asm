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
    addiSigned x2, x2, -216                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 216                                   ; pc=0x002C

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
    sw x5, -52(x17) ; total_operaciones                 ; pc=0x0094
    addi x6, x0, 0                                      ; pc=0x0098
    sw x6, -56(x17) ; suma                              ; pc=0x009C
    addi x7, x0, 0                                      ; pc=0x00A0
    sw x7, -60(x17) ; temporal_externo                  ; pc=0x00A4
    addi x8, x0, 0                                      ; pc=0x00A8
    sw x8, -64(x17) ; basura1                           ; pc=0x00AC
    addi x9, x0, 0                                      ; pc=0x00B0
    sw x9, -68(x17) ; basura2                           ; pc=0x00B4
    addi x10, x0, 0                                     ; pc=0x00B8
    sw x10, -72(x17) ; basura3                          ; pc=0x00BC
    addi x5, x0, 0                                      ; pc=0x00C0
    add x3, x5, x0 ; promote i                          ; pc=0x00C4
L_for_start_0:
    addi x6, x0, 2                                      ; pc=0x00C8
    addi x7, x0, 0                                      ; pc=0x00CC
    blt x3, x6, .L_ir_2_ir_cmp_true                     ; pc=0x00D0
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x00D4
.L_ir_2_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x00D8
.L_ir_3_ir_cmp_end:
    sw x7, -96(x17) ; t0                                ; pc=0x00DC
    lw x8, -96(x17) ; t0                                ; pc=0x00E0
    beq x8, x0, L_for_end_1                             ; pc=0x00E4
    addi x9, x0, 100                                    ; pc=0x00E8
    mul x10, x3, x9                                     ; pc=0x00EC
    sw x10, -60(x17) ; temporal_externo                 ; pc=0x00F0
    addi x5, x0, 0                                      ; pc=0x00F4
    add x4, x5, x0 ; promote j                          ; pc=0x00F8
L_for_start_2:
    addi x7, x0, 2                                      ; pc=0x00FC
    addi x6, x0, 0                                      ; pc=0x0100
    blt x4, x7, .L_ir_4_ir_cmp_true                     ; pc=0x0104
    jal x0, .L_ir_5_ir_cmp_end                          ; pc=0x0108
.L_ir_4_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x010C
.L_ir_5_ir_cmp_end:
    sw x6, -104(x17) ; t2                               ; pc=0x0110
    lw x8, -104(x17) ; t2                               ; pc=0x0114
    beq x8, x0, L_for_end_3                             ; pc=0x0118
    add x10, x3, x4                                     ; pc=0x011C
    sw x10, -64(x17) ; basura1                          ; pc=0x0120
    addi x9, x0, 0                                      ; pc=0x0124
    sw x9, -56(x17) ; suma                              ; pc=0x0128
    addi x5, x0, 0                                      ; pc=0x012C
    sw x5, -84(x17) ; k                                 ; pc=0x0130
L_for_start_4:
    lw x6, -84(x17) ; k                                 ; pc=0x0134
    addi x7, x0, 2                                      ; pc=0x0138
    addi x8, x0, 0                                      ; pc=0x013C
    blt x6, x7, .L_ir_6_ir_cmp_true                     ; pc=0x0140
    jal x0, .L_ir_7_ir_cmp_end                          ; pc=0x0144
.L_ir_6_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0148
.L_ir_7_ir_cmp_end:
    sw x8, -112(x17) ; t4                               ; pc=0x014C
    lw x10, -112(x17) ; t4                              ; pc=0x0150
    beq x10, x0, L_for_end_5                            ; pc=0x0154
    lw x9, -84(x17) ; k                                 ; pc=0x0158
    addi x5, x0, 50                                     ; pc=0x015C
    mul x8, x9, x5                                      ; pc=0x0160
    sw x8, -68(x17) ; basura2                           ; pc=0x0164
    addi x7, x0, 2                                      ; pc=0x0168
    mul x6, x3, x7                                      ; pc=0x016C
    sw x6, -120(x17) ; t6                               ; pc=0x0170
    lw x10, -120(x17) ; t6                              ; pc=0x0174
    lw x8, -84(x17) ; k                                 ; pc=0x0178
    add x5, x10, x8                                     ; pc=0x017C
    sw x5, -124(x17) ; t7                               ; pc=0x0180
    lw x9, -124(x17) ; t7                               ; pc=0x0184
    add x6, x9, x9                                      ; pc=0x0188
    add x6, x6, x6                                      ; pc=0x018C
    addiSigned x7, x17, -16                             ; pc=0x0190
    add x7, x7, x6                                      ; pc=0x0194
    lw x5, 0(x7)                                        ; pc=0x0198
    sw x5, -128(x17) ; t8                               ; pc=0x019C
    lw x8, -84(x17) ; k                                 ; pc=0x01A0
    addi x10, x0, 2                                     ; pc=0x01A4
    mul x6, x8, x10                                     ; pc=0x01A8
    sw x6, -132(x17) ; t9                               ; pc=0x01AC
    lw x9, -132(x17) ; t9                               ; pc=0x01B0
    add x7, x9, x4                                      ; pc=0x01B4
    sw x7, -136(x17) ; t10                              ; pc=0x01B8
    lw x5, -136(x17) ; t10                              ; pc=0x01BC
    add x6, x5, x5                                      ; pc=0x01C0
    add x6, x6, x6                                      ; pc=0x01C4
    addiSigned x10, x17, -32                            ; pc=0x01C8
    add x10, x10, x6                                    ; pc=0x01CC
    lw x8, 0(x10)                                       ; pc=0x01D0
    sw x8, -140(x17) ; t11                              ; pc=0x01D4
    lw x7, -128(x17) ; t8                               ; pc=0x01D8
    lw x9, -140(x17) ; t11                              ; pc=0x01DC
    mul x6, x7, x9                                      ; pc=0x01E0
    sw x6, -144(x17) ; t12                              ; pc=0x01E4
    lw x5, -56(x17) ; suma                              ; pc=0x01E8
    lw x10, -144(x17) ; t12                             ; pc=0x01EC
    add x8, x5, x10                                     ; pc=0x01F0
    sw x8, -56(x17) ; suma                              ; pc=0x01F4
    lw x6, -52(x17) ; total_operaciones                 ; pc=0x01F8
    addi x9, x0, 1                                      ; pc=0x01FC
    add x7, x6, x9                                      ; pc=0x0200
    sw x7, -52(x17) ; total_operaciones                 ; pc=0x0204
    lw x8, -84(x17) ; k                                 ; pc=0x0208
    addi x10, x0, 1                                     ; pc=0x020C
    add x5, x8, x10                                     ; pc=0x0210
    sw x5, -84(x17) ; k                                 ; pc=0x0214
    jal x0, L_for_start_4                               ; pc=0x0218
L_for_end_5:
    addi x7, x0, 2                                      ; pc=0x021C
    mul x9, x3, x7                                      ; pc=0x0220
    sw x9, -160(x17) ; t16                              ; pc=0x0224
    lw x6, -160(x17) ; t16                              ; pc=0x0228
    add x5, x6, x4                                      ; pc=0x022C
    sw x5, -164(x17) ; t17                              ; pc=0x0230
    lw x10, -56(x17) ; suma                             ; pc=0x0234
    lw x8, -164(x17) ; t17                              ; pc=0x0238
    add x9, x8, x8                                      ; pc=0x023C
    add x9, x9, x9                                      ; pc=0x0240
    addiSigned x7, x17, -48                             ; pc=0x0244
    add x7, x7, x9                                      ; pc=0x0248
    sw x10, 0(x7)                                       ; pc=0x024C
    lw x5, -56(x17) ; suma                              ; pc=0x0250
    addi x6, x0, 999                                    ; pc=0x0254
    mul x9, x5, x6                                      ; pc=0x0258
    sw x9, -72(x17) ; basura3                           ; pc=0x025C
    addi x8, x0, 1                                      ; pc=0x0260
    add x7, x4, x8                                      ; pc=0x0264
    add x4, x7, x0 ; promote j                          ; pc=0x0268
    jal x0, L_for_start_2                               ; pc=0x026C
L_for_end_3:
    addi x10, x0, 1                                     ; pc=0x0270
    add x9, x3, x10                                     ; pc=0x0274
    add x3, x9, x0 ; promote i                          ; pc=0x0278
    jal x0, L_for_start_0                               ; pc=0x027C
L_for_end_1:
    lw x6, -52(x17) ; total_operaciones                 ; pc=0x0280
    sw x6, -88(x17) ; estadistica                       ; pc=0x0284
    lw x5, -88(x17) ; estadistica                       ; pc=0x0288
    addi x7, x0, 2                                      ; pc=0x028C
    mul x8, x5, x7                                      ; pc=0x0290
    sw x8, -92(x17) ; desperdicio                       ; pc=0x0294
    addi x9, x0, 0                                      ; pc=0x0298
    add x10, x9, x9                                     ; pc=0x029C
    add x10, x10, x10                                   ; pc=0x02A0
    addiSigned x6, x17, -48                             ; pc=0x02A4
    add x6, x6, x10                                     ; pc=0x02A8
    lw x8, 0(x6)                                        ; pc=0x02AC
    sw x8, -184(x17) ; t22                              ; pc=0x02B0
    addi x7, x0, 1                                      ; pc=0x02B4
    add x5, x7, x7                                      ; pc=0x02B8
    add x5, x5, x5                                      ; pc=0x02BC
    addiSigned x10, x17, -48                            ; pc=0x02C0
    add x10, x10, x5                                    ; pc=0x02C4
    lw x9, 0(x10)                                       ; pc=0x02C8
    sw x9, -188(x17) ; t23                              ; pc=0x02CC
    lw x6, -184(x17) ; t22                              ; pc=0x02D0
    lw x8, -188(x17) ; t23                              ; pc=0x02D4
    add x5, x6, x8                                      ; pc=0x02D8
    sw x5, -192(x17) ; t24                              ; pc=0x02DC
    addi x7, x0, 2                                      ; pc=0x02E0
    add x10, x7, x7                                     ; pc=0x02E4
    add x10, x10, x10                                   ; pc=0x02E8
    addiSigned x9, x17, -48                             ; pc=0x02EC
    add x9, x9, x10                                     ; pc=0x02F0
    lw x5, 0(x9)                                        ; pc=0x02F4
    sw x5, -196(x17) ; t25                              ; pc=0x02F8
    lw x8, -192(x17) ; t24                              ; pc=0x02FC
    lw x6, -196(x17) ; t25                              ; pc=0x0300
    add x10, x8, x6                                     ; pc=0x0304
    sw x10, -200(x17) ; t26                             ; pc=0x0308
    addi x7, x0, 3                                      ; pc=0x030C
    add x9, x7, x7                                      ; pc=0x0310
    add x9, x9, x9                                      ; pc=0x0314
    addiSigned x5, x17, -48                             ; pc=0x0318
    add x5, x5, x9                                      ; pc=0x031C
    lw x10, 0(x5)                                       ; pc=0x0320
    sw x10, -204(x17) ; t27                             ; pc=0x0324
    lw x6, -200(x17) ; t26                              ; pc=0x0328
    lw x8, -204(x17) ; t27                              ; pc=0x032C
    add x9, x6, x8                                      ; pc=0x0330
    sw x9, -208(x17) ; t28                              ; pc=0x0334
    lw x7, -208(x17) ; t28                              ; pc=0x0338
    add x11, x7, x0                                     ; pc=0x033C
    jal x0, .L_ir_1_main_end                            ; pc=0x0340
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0344
    addi x2, x2, 216                                    ; pc=0x0348
    freeze                                              ; pc=0x034C