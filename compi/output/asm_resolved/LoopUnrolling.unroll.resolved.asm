; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x024C
;   procesar_bloques = 0x0258
;   L_for_start_0 = 0x027C
;   .L_ir_3_ir_cmp_true = 0x0290
;   .L_ir_4_ir_cmp_end = 0x0294
;   L_for_start_2 = 0x02A8
;   .L_ir_5_ir_cmp_true = 0x02B8
;   .L_ir_6_ir_cmp_end = 0x02BC
;   L_for_end_3 = 0x0410
;   L_for_end_1 = 0x0424
;   .L_ir_2_procesar_bloques_end = 0x042C

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0238 jal -> procesar_bloques (addr=0x0258, offset=32)
;   pc=0x0248 jal -> .L_ir_1_main_end (addr=0x024C, offset=4)
;   pc=0x0288 blt -> .L_ir_3_ir_cmp_true (addr=0x0290, offset=8)
;   pc=0x028C jal -> .L_ir_4_ir_cmp_end (addr=0x0294, offset=8)
;   pc=0x029C beq -> L_for_end_1 (addr=0x0424, offset=392)
;   pc=0x02B0 blt -> .L_ir_5_ir_cmp_true (addr=0x02B8, offset=8)
;   pc=0x02B4 jal -> .L_ir_6_ir_cmp_end (addr=0x02BC, offset=8)
;   pc=0x02C4 beq -> L_for_end_3 (addr=0x0410, offset=332)
;   pc=0x040C jal -> L_for_start_2 (addr=0x02A8, offset=-356)
;   pc=0x0420 jal -> L_for_start_0 (addr=0x027C, offset=-420)
;   pc=0x0428 jal -> .L_ir_2_procesar_bloques_end (addr=0x042C, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, 24                                  ; pc=0x0000 ; target=.L_ir_0_enderExit ; addr=0x0018
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
    jal x1, 32                                          ; pc=0x0238 ; target=procesar_bloques ; addr=0x0258
    add x6, x11, x0                                     ; pc=0x023C
    add x3, x6, x0 ; promote t9                         ; pc=0x0240
    add x11, x3, x0                                     ; pc=0x0244
    jal x0, 4                                           ; pc=0x0248 ; target=.L_ir_1_main_end ; addr=0x024C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x024C
    addi x2, x2, 268                                    ; pc=0x0250
    freeze                                              ; pc=0x0254

procesar_bloques:
    ; prologue
    addiSigned x2, x2, -108                             ; pc=0x0258
    sw x1, 0(x2)                                        ; pc=0x025C
    sw x17, 4(x2)                                       ; pc=0x0260
    addi x17, x2, 108                                   ; pc=0x0264

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x0268

    addi x5, x0, 0                                      ; pc=0x026C
    add x3, x5, x0 ; promote total                      ; pc=0x0270
    addi x6, x0, 0                                      ; pc=0x0274
    sw x6, -12(x17) ; b                                 ; pc=0x0278
L_for_start_0:
    lw x7, -12(x17) ; b                                 ; pc=0x027C
    addi x8, x0, 8                                      ; pc=0x0280
    addi x9, x0, 0                                      ; pc=0x0284
    blt x7, x8, 8                                       ; pc=0x0288 ; target=.L_ir_3_ir_cmp_true ; addr=0x0290
    jal x0, 8                                           ; pc=0x028C ; target=.L_ir_4_ir_cmp_end ; addr=0x0294
.L_ir_3_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0290
.L_ir_4_ir_cmp_end:
    sw x9, -20(x17) ; t0                                ; pc=0x0294
    lw x10, -20(x17) ; t0                               ; pc=0x0298
    beq x10, x0, 392                                    ; pc=0x029C ; target=L_for_end_1 ; addr=0x0424
    addi x5, x0, 0                                      ; pc=0x02A0
    add x4, x5, x0 ; promote i                          ; pc=0x02A4
L_for_start_2:
    addi x6, x0, 8                                      ; pc=0x02A8
    addi x9, x0, 0                                      ; pc=0x02AC
    blt x4, x6, 8                                       ; pc=0x02B0 ; target=.L_ir_5_ir_cmp_true ; addr=0x02B8
    jal x0, 8                                           ; pc=0x02B4 ; target=.L_ir_6_ir_cmp_end ; addr=0x02BC
.L_ir_5_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x02B8
.L_ir_6_ir_cmp_end:
    sw x9, -24(x17) ; t10                               ; pc=0x02BC
    lw x8, -24(x17) ; t10                               ; pc=0x02C0
    beq x8, x0, 332                                     ; pc=0x02C4 ; target=L_for_end_3 ; addr=0x0410
    lw x7, -12(x17) ; b                                 ; pc=0x02C8
    addi x10, x0, 8                                     ; pc=0x02CC
    mul x5, x7, x10                                     ; pc=0x02D0
    sw x5, -28(x17) ; t11                               ; pc=0x02D4
    lw x9, -28(x17) ; t11                               ; pc=0x02D8
    add x6, x9, x4                                      ; pc=0x02DC
    sw x6, -32(x17) ; t12                               ; pc=0x02E0
    lw x8, -32(x17) ; t12                               ; pc=0x02E4
    add x5, x8, x8                                      ; pc=0x02E8
    add x5, x5, x5                                      ; pc=0x02EC
    lw x10, -4(x17) ; base ref bloques                  ; pc=0x02F0
    add x10, x10, x5                                    ; pc=0x02F4
    lw x7, 0(x10)                                       ; pc=0x02F8
    sw x7, -36(x17) ; t13                               ; pc=0x02FC
    lw x6, -36(x17) ; t13                               ; pc=0x0300
    addi x9, x0, 2                                      ; pc=0x0304
    mul x5, x6, x9                                      ; pc=0x0308
    sw x5, -40(x17) ; t14                               ; pc=0x030C
    lw x8, -40(x17) ; t14                               ; pc=0x0310
    add x10, x3, x8                                     ; pc=0x0314
    add x3, x10, x0 ; promote total                     ; pc=0x0318
    lw x7, -28(x17) ; t11                               ; pc=0x031C
    addi x5, x0, 1                                      ; pc=0x0320
    add x9, x4, x5                                      ; pc=0x0324
    add x6, x7, x9                                      ; pc=0x0328
    sw x6, -48(x17) ; t16                               ; pc=0x032C
    lw x10, -48(x17) ; t16                              ; pc=0x0330
    add x8, x10, x10                                    ; pc=0x0334
    add x8, x8, x8                                      ; pc=0x0338
    lw x5, -4(x17) ; base ref bloques                   ; pc=0x033C
    add x5, x5, x8                                      ; pc=0x0340
    lw x6, 0(x5)                                        ; pc=0x0344
    sw x6, -52(x17) ; t17                               ; pc=0x0348
    lw x9, -52(x17) ; t17                               ; pc=0x034C
    addi x7, x0, 2                                      ; pc=0x0350
    mul x8, x9, x7                                      ; pc=0x0354
    sw x8, -56(x17) ; t18                               ; pc=0x0358
    lw x10, -56(x17) ; t18                              ; pc=0x035C
    add x5, x3, x10                                     ; pc=0x0360
    add x3, x5, x0 ; promote total                      ; pc=0x0364
    lw x6, -28(x17) ; t11                               ; pc=0x0368
    addi x8, x0, 2                                      ; pc=0x036C
    add x7, x4, x8                                      ; pc=0x0370
    add x9, x6, x7                                      ; pc=0x0374
    sw x9, -64(x17) ; t20                               ; pc=0x0378
    lw x5, -64(x17) ; t20                               ; pc=0x037C
    add x10, x5, x5                                     ; pc=0x0380
    add x10, x10, x10                                   ; pc=0x0384
    lw x8, -4(x17) ; base ref bloques                   ; pc=0x0388
    add x8, x8, x10                                     ; pc=0x038C
    lw x9, 0(x8)                                        ; pc=0x0390
    sw x9, -68(x17) ; t21                               ; pc=0x0394
    lw x7, -68(x17) ; t21                               ; pc=0x0398
    addi x6, x0, 2                                      ; pc=0x039C
    mul x10, x7, x6                                     ; pc=0x03A0
    sw x10, -72(x17) ; t22                              ; pc=0x03A4
    lw x5, -72(x17) ; t22                               ; pc=0x03A8
    add x8, x3, x5                                      ; pc=0x03AC
    add x3, x8, x0 ; promote total                      ; pc=0x03B0
    lw x9, -28(x17) ; t11                               ; pc=0x03B4
    addi x10, x0, 3                                     ; pc=0x03B8
    add x6, x4, x10                                     ; pc=0x03BC
    add x7, x9, x6                                      ; pc=0x03C0
    sw x7, -80(x17) ; t24                               ; pc=0x03C4
    lw x8, -80(x17) ; t24                               ; pc=0x03C8
    add x5, x8, x8                                      ; pc=0x03CC
    add x5, x5, x5                                      ; pc=0x03D0
    lw x10, -4(x17) ; base ref bloques                  ; pc=0x03D4
    add x10, x10, x5                                    ; pc=0x03D8
    lw x7, 0(x10)                                       ; pc=0x03DC
    sw x7, -84(x17) ; t25                               ; pc=0x03E0
    lw x6, -84(x17) ; t25                               ; pc=0x03E4
    addi x9, x0, 2                                      ; pc=0x03E8
    mul x5, x6, x9                                      ; pc=0x03EC
    sw x5, -88(x17) ; t26                               ; pc=0x03F0
    lw x8, -88(x17) ; t26                               ; pc=0x03F4
    add x10, x3, x8                                     ; pc=0x03F8
    add x3, x10, x0 ; promote total                     ; pc=0x03FC
    addi x7, x0, 4                                      ; pc=0x0400
    add x5, x4, x7                                      ; pc=0x0404
    add x4, x5, x0 ; promote i                          ; pc=0x0408
    jal x0, -356                                        ; pc=0x040C ; target=L_for_start_2 ; addr=0x02A8
L_for_end_3:
    lw x9, -12(x17) ; b                                 ; pc=0x0410
    addi x6, x0, 1                                      ; pc=0x0414
    add x10, x9, x6                                     ; pc=0x0418
    sw x10, -12(x17) ; b                                ; pc=0x041C
    jal x0, -420                                        ; pc=0x0420 ; target=L_for_start_0 ; addr=0x027C
L_for_end_1:
    add x11, x3, x0                                     ; pc=0x0424
    jal x0, 4                                           ; pc=0x0428 ; target=.L_ir_2_procesar_bloques_end ; addr=0x042C
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x042C
    lw x17, 4(x2)                                       ; pc=0x0430
    addi x2, x2, 108                                    ; pc=0x0434
    jalr x1, 0                                          ; pc=0x0438