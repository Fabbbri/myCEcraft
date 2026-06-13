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
    addiSigned x2, x2, -268                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 268                                   ; pc=0x002C

    addi x4, x0, 10                                     ; pc=0x0030
    sw x4, -256(x17) ; datos[0]                         ; pc=0x0034
    addi x5, x0, 20                                     ; pc=0x0038
    sw x5, -252(x17) ; datos[1]                         ; pc=0x003C
    addi x6, x0, 30                                     ; pc=0x0040
    sw x6, -248(x17) ; datos[2]                         ; pc=0x0044
    addi x7, x0, 40                                     ; pc=0x0048
    sw x7, -244(x17) ; datos[3]                         ; pc=0x004C
    addi x8, x0, 50                                     ; pc=0x0050
    sw x8, -240(x17) ; datos[4]                         ; pc=0x0054
    addi x9, x0, 60                                     ; pc=0x0058
    sw x9, -236(x17) ; datos[5]                         ; pc=0x005C
    addi x10, x0, 70                                    ; pc=0x0060
    sw x10, -232(x17) ; datos[6]                        ; pc=0x0064
    addi x4, x0, 80                                     ; pc=0x0068
    sw x4, -228(x17) ; datos[7]                         ; pc=0x006C
    addi x5, x0, 15                                     ; pc=0x0070
    sw x5, -224(x17) ; datos[8]                         ; pc=0x0074
    addi x6, x0, 25                                     ; pc=0x0078
    sw x6, -220(x17) ; datos[9]                         ; pc=0x007C
    addi x7, x0, 35                                     ; pc=0x0080
    sw x7, -216(x17) ; datos[10]                        ; pc=0x0084
    addi x8, x0, 45                                     ; pc=0x0088
    sw x8, -212(x17) ; datos[11]                        ; pc=0x008C
    addi x9, x0, 55                                     ; pc=0x0090
    sw x9, -208(x17) ; datos[12]                        ; pc=0x0094
    addi x10, x0, 65                                    ; pc=0x0098
    sw x10, -204(x17) ; datos[13]                       ; pc=0x009C
    addi x4, x0, 75                                     ; pc=0x00A0
    sw x4, -200(x17) ; datos[14]                        ; pc=0x00A4
    addi x5, x0, 85                                     ; pc=0x00A8
    sw x5, -196(x17) ; datos[15]                        ; pc=0x00AC
    addi x6, x0, 11                                     ; pc=0x00B0
    sw x6, -192(x17) ; datos[16]                        ; pc=0x00B4
    addi x7, x0, 22                                     ; pc=0x00B8
    sw x7, -188(x17) ; datos[17]                        ; pc=0x00BC
    addi x8, x0, 33                                     ; pc=0x00C0
    sw x8, -184(x17) ; datos[18]                        ; pc=0x00C4
    addi x9, x0, 44                                     ; pc=0x00C8
    sw x9, -180(x17) ; datos[19]                        ; pc=0x00CC
    addi x10, x0, 55                                    ; pc=0x00D0
    sw x10, -176(x17) ; datos[20]                       ; pc=0x00D4
    addi x4, x0, 66                                     ; pc=0x00D8
    sw x4, -172(x17) ; datos[21]                        ; pc=0x00DC
    addi x5, x0, 77                                     ; pc=0x00E0
    sw x5, -168(x17) ; datos[22]                        ; pc=0x00E4
    addi x6, x0, 88                                     ; pc=0x00E8
    sw x6, -164(x17) ; datos[23]                        ; pc=0x00EC
    addi x7, x0, 12                                     ; pc=0x00F0
    sw x7, -160(x17) ; datos[24]                        ; pc=0x00F4
    addi x8, x0, 24                                     ; pc=0x00F8
    sw x8, -156(x17) ; datos[25]                        ; pc=0x00FC
    addi x9, x0, 36                                     ; pc=0x0100
    sw x9, -152(x17) ; datos[26]                        ; pc=0x0104
    addi x10, x0, 48                                    ; pc=0x0108
    sw x10, -148(x17) ; datos[27]                       ; pc=0x010C
    addi x4, x0, 60                                     ; pc=0x0110
    sw x4, -144(x17) ; datos[28]                        ; pc=0x0114
    addi x5, x0, 72                                     ; pc=0x0118
    sw x5, -140(x17) ; datos[29]                        ; pc=0x011C
    addi x6, x0, 84                                     ; pc=0x0120
    sw x6, -136(x17) ; datos[30]                        ; pc=0x0124
    addi x7, x0, 96                                     ; pc=0x0128
    sw x7, -132(x17) ; datos[31]                        ; pc=0x012C
    addi x8, x0, 100                                    ; pc=0x0130
    sw x8, -128(x17) ; datos[32]                        ; pc=0x0134
    addi x9, x0, 200                                    ; pc=0x0138
    sw x9, -124(x17) ; datos[33]                        ; pc=0x013C
    addi x10, x0, 150                                   ; pc=0x0140
    sw x10, -120(x17) ; datos[34]                       ; pc=0x0144
    addi x4, x0, 250                                    ; pc=0x0148
    sw x4, -116(x17) ; datos[35]                        ; pc=0x014C
    addi x5, x0, 120                                    ; pc=0x0150
    sw x5, -112(x17) ; datos[36]                        ; pc=0x0154
    addi x6, x0, 180                                    ; pc=0x0158
    sw x6, -108(x17) ; datos[37]                        ; pc=0x015C
    addi x7, x0, 140                                    ; pc=0x0160
    sw x7, -104(x17) ; datos[38]                        ; pc=0x0164
    addi x8, x0, 160                                    ; pc=0x0168
    sw x8, -100(x17) ; datos[39]                        ; pc=0x016C
    addi x9, x0, 90                                     ; pc=0x0170
    sw x9, -96(x17) ; datos[40]                         ; pc=0x0174
    addi x10, x0, 110                                   ; pc=0x0178
    sw x10, -92(x17) ; datos[41]                        ; pc=0x017C
    addi x4, x0, 130                                    ; pc=0x0180
    sw x4, -88(x17) ; datos[42]                         ; pc=0x0184
    addi x5, x0, 170                                    ; pc=0x0188
    sw x5, -84(x17) ; datos[43]                         ; pc=0x018C
    addi x6, x0, 190                                    ; pc=0x0190
    sw x6, -80(x17) ; datos[44]                         ; pc=0x0194
    addi x7, x0, 210                                    ; pc=0x0198
    sw x7, -76(x17) ; datos[45]                         ; pc=0x019C
    addi x8, x0, 230                                    ; pc=0x01A0
    sw x8, -72(x17) ; datos[46]                         ; pc=0x01A4
    addi x9, x0, 70                                     ; pc=0x01A8
    sw x9, -68(x17) ; datos[47]                         ; pc=0x01AC
    addi x10, x0, 5                                     ; pc=0x01B0
    sw x10, -64(x17) ; datos[48]                        ; pc=0x01B4
    addi x4, x0, 15                                     ; pc=0x01B8
    sw x4, -60(x17) ; datos[49]                         ; pc=0x01BC
    addi x5, x0, 25                                     ; pc=0x01C0
    sw x5, -56(x17) ; datos[50]                         ; pc=0x01C4
    addi x6, x0, 35                                     ; pc=0x01C8
    sw x6, -52(x17) ; datos[51]                         ; pc=0x01CC
    addi x7, x0, 45                                     ; pc=0x01D0
    sw x7, -48(x17) ; datos[52]                         ; pc=0x01D4
    addi x8, x0, 55                                     ; pc=0x01D8
    sw x8, -44(x17) ; datos[53]                         ; pc=0x01DC
    addi x9, x0, 65                                     ; pc=0x01E0
    sw x9, -40(x17) ; datos[54]                         ; pc=0x01E4
    addi x10, x0, 75                                    ; pc=0x01E8
    sw x10, -36(x17) ; datos[55]                        ; pc=0x01EC
    addi x4, x0, 8                                      ; pc=0x01F0
    sw x4, -32(x17) ; datos[56]                         ; pc=0x01F4
    addi x5, x0, 16                                     ; pc=0x01F8
    sw x5, -28(x17) ; datos[57]                         ; pc=0x01FC
    addi x6, x0, 24                                     ; pc=0x0200
    sw x6, -24(x17) ; datos[58]                         ; pc=0x0204
    addi x7, x0, 32                                     ; pc=0x0208
    sw x7, -20(x17) ; datos[59]                         ; pc=0x020C
    addi x8, x0, 40                                     ; pc=0x0210
    sw x8, -16(x17) ; datos[60]                         ; pc=0x0214
    addi x9, x0, 48                                     ; pc=0x0218
    sw x9, -12(x17) ; datos[61]                         ; pc=0x021C
    addi x10, x0, 56                                    ; pc=0x0220
    sw x10, -8(x17) ; datos[62]                         ; pc=0x0224
    addi x4, x0, 64                                     ; pc=0x0228
    sw x4, -4(x17) ; datos[63]                          ; pc=0x022C
    addiSigned x5, x17, -256                            ; pc=0x0230
    add x11, x5, x0                                     ; pc=0x0234
    jal x1, procesar_bloques                            ; pc=0x0238
    add x6, x11, x0                                     ; pc=0x023C
    add x3, x6, x0 ; promote t9                         ; pc=0x0240
    add x11, x3, x0                                     ; pc=0x0244
    jal x0, .L_ir_1_main_end                            ; pc=0x0248
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x024C
    addi x2, x2, 268                                    ; pc=0x0250
    freeze                                              ; pc=0x0254

procesar_bloques:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x0258
    sw x1, 0(x2)                                        ; pc=0x025C
    sw x17, 4(x2)                                       ; pc=0x0260
    addi x17, x2, 60                                    ; pc=0x0264

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x0268

    addi x5, x0, 0                                      ; pc=0x026C
    sw x5, -8(x17) ; total                              ; pc=0x0270
    addi x6, x0, 0                                      ; pc=0x0274
    add x3, x6, x0 ; promote b                          ; pc=0x0278
L_for_start_0:
    addi x7, x0, 8                                      ; pc=0x027C
    addi x8, x0, 0                                      ; pc=0x0280
    blt x3, x7, .L_ir_3_ir_cmp_true                     ; pc=0x0284
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x0288
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x028C
.L_ir_4_ir_cmp_end:
    sw x8, -20(x17) ; t0                                ; pc=0x0290
    lw x9, -20(x17) ; t0                                ; pc=0x0294
    beq x9, x0, L_for_end_1                             ; pc=0x0298
    addi x10, x0, 0                                     ; pc=0x029C
    add x4, x10, x0 ; promote i                         ; pc=0x02A0
L_for_start_2:
    addi x5, x0, 8                                      ; pc=0x02A4
    addi x6, x0, 0                                      ; pc=0x02A8
    blt x4, x5, .L_ir_5_ir_cmp_true                     ; pc=0x02AC
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x02B0
.L_ir_5_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x02B4
.L_ir_6_ir_cmp_end:
    sw x6, -24(x17) ; t1                                ; pc=0x02B8
    lw x8, -24(x17) ; t1                                ; pc=0x02BC
    beq x8, x0, L_for_end_3                             ; pc=0x02C0
    addi x7, x0, 8                                      ; pc=0x02C4
    mul x9, x3, x7                                      ; pc=0x02C8
    sw x9, -28(x17) ; t2                                ; pc=0x02CC
    lw x10, -28(x17) ; t2                               ; pc=0x02D0
    add x6, x10, x4                                     ; pc=0x02D4
    sw x6, -32(x17) ; t3                                ; pc=0x02D8
    lw x5, -32(x17) ; t3                                ; pc=0x02DC
    add x8, x5, x5                                      ; pc=0x02E0
    add x8, x8, x8                                      ; pc=0x02E4
    lw x9, -4(x17) ; base ref bloques                   ; pc=0x02E8
    add x9, x9, x8                                      ; pc=0x02EC
    lw x7, 0(x9)                                        ; pc=0x02F0
    sw x7, -36(x17) ; t4                                ; pc=0x02F4
    lw x6, -36(x17) ; t4                                ; pc=0x02F8
    addi x10, x0, 2                                     ; pc=0x02FC
    mul x8, x6, x10                                     ; pc=0x0300
    sw x8, -40(x17) ; t5                                ; pc=0x0304
    lw x5, -8(x17) ; total                              ; pc=0x0308
    lw x9, -40(x17) ; t5                                ; pc=0x030C
    add x7, x5, x9                                      ; pc=0x0310
    sw x7, -8(x17) ; total                              ; pc=0x0314
    addi x8, x0, 1                                      ; pc=0x0318
    add x10, x4, x8                                     ; pc=0x031C
    add x4, x10, x0 ; promote i                         ; pc=0x0320
    jal x0, L_for_start_2                               ; pc=0x0324
L_for_end_3:
    addi x6, x0, 1                                      ; pc=0x0328
    add x7, x3, x6                                      ; pc=0x032C
    add x3, x7, x0 ; promote b                          ; pc=0x0330
    jal x0, L_for_start_0                               ; pc=0x0334
L_for_end_1:
    lw x9, -8(x17) ; total                              ; pc=0x0338
    add x11, x9, x0                                     ; pc=0x033C
    jal x0, .L_ir_2_procesar_bloques_end                ; pc=0x0340
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0344
    lw x17, 4(x2)                                       ; pc=0x0348
    addi x2, x2, 60                                     ; pc=0x034C
    jalr x1, 0                                          ; pc=0x0350