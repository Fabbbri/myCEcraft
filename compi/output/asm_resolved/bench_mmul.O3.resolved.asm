; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x0050
;   .L_ir_2_ir_cmp_true = 0x0060
;   .L_ir_3_ir_cmp_end = 0x0064
;   L_while_end_1 = 0x0288
;   L_while_start_2 = 0x0298
;   .L_ir_4_ir_cmp_true = 0x02A8
;   .L_ir_5_ir_cmp_end = 0x02AC
;   L_while_start_4 = 0x02C0
;   .L_ir_6_ir_cmp_true = 0x02D4
;   .L_ir_7_ir_cmp_end = 0x02D8
;   L_while_start_6 = 0x02FC
;   .L_ir_8_ir_cmp_true = 0x0310
;   .L_ir_9_ir_cmp_end = 0x0314
;   L_while_end_7 = 0x03C4
;   L_while_end_5 = 0x0404
;   L_while_end_3 = 0x0424
;   L_while_start_8 = 0x0434
;   .L_ir_10_ir_cmp_true = 0x0444
;   .L_ir_11_ir_cmp_end = 0x0448
;   L_while_end_9 = 0x050C
;   .L_ir_1_main_end = 0x0514

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0058 blt -> .L_ir_2_ir_cmp_true (addr=0x0060, offset=8)
;   pc=0x005C jal -> .L_ir_3_ir_cmp_end (addr=0x0064, offset=8)
;   pc=0x006C beq -> L_while_end_1 (addr=0x0288, offset=540)
;   pc=0x0284 jal -> L_while_start_0 (addr=0x0050, offset=-564)
;   pc=0x02A0 blt -> .L_ir_4_ir_cmp_true (addr=0x02A8, offset=8)
;   pc=0x02A4 jal -> .L_ir_5_ir_cmp_end (addr=0x02AC, offset=8)
;   pc=0x02B4 beq -> L_while_end_3 (addr=0x0424, offset=368)
;   pc=0x02CC blt -> .L_ir_6_ir_cmp_true (addr=0x02D4, offset=8)
;   pc=0x02D0 jal -> .L_ir_7_ir_cmp_end (addr=0x02D8, offset=8)
;   pc=0x02E0 beq -> L_while_end_5 (addr=0x0404, offset=292)
;   pc=0x0308 blt -> .L_ir_8_ir_cmp_true (addr=0x0310, offset=8)
;   pc=0x030C jal -> .L_ir_9_ir_cmp_end (addr=0x0314, offset=8)
;   pc=0x031C beq -> L_while_end_7 (addr=0x03C4, offset=168)
;   pc=0x03C0 jal -> L_while_start_6 (addr=0x02FC, offset=-196)
;   pc=0x0400 jal -> L_while_start_4 (addr=0x02C0, offset=-320)
;   pc=0x0420 jal -> L_while_start_2 (addr=0x0298, offset=-392)
;   pc=0x043C blt -> .L_ir_10_ir_cmp_true (addr=0x0444, offset=8)
;   pc=0x0440 jal -> .L_ir_11_ir_cmp_end (addr=0x0448, offset=8)
;   pc=0x0450 beq -> L_while_end_9 (addr=0x050C, offset=188)
;   pc=0x0508 jal -> L_while_start_8 (addr=0x0434, offset=-212)
;   pc=0x0510 jal -> .L_ir_1_main_end (addr=0x0514, offset=4)

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
    addiSigned x2, x2, -912                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 912                                   ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    sw x5, -256(x17) ; a                                ; pc=0x0034
    addi x6, x0, 0                                      ; pc=0x0038
    sw x6, -512(x17) ; b                                ; pc=0x003C
    addi x7, x0, 0                                      ; pc=0x0040
    sw x7, -768(x17) ; c                                ; pc=0x0044
    addi x8, x0, 0                                      ; pc=0x0048
    add x3, x8, x0 ; promote i                          ; pc=0x004C
L_while_start_0:
    addi x9, x0, 64                                     ; pc=0x0050
    addi x10, x0, 0                                     ; pc=0x0054
    blt x3, x9, 8                                       ; pc=0x0058 ; target=.L_ir_2_ir_cmp_true ; addr=0x0060
    jal x0, 8                                           ; pc=0x005C ; target=.L_ir_3_ir_cmp_end ; addr=0x0064
.L_ir_2_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x0060
.L_ir_3_ir_cmp_end:
    sw x10, -800(x17) ; t21__x3                         ; pc=0x0064
    lw x5, -800(x17) ; t21__x3                          ; pc=0x0068
    beq x5, x0, 540                                     ; pc=0x006C ; target=L_while_end_1 ; addr=0x0288
    add x6, x3, x3                                      ; pc=0x0070
    add x6, x6, x6                                      ; pc=0x0074
    addiSigned x7, x17, -256                            ; pc=0x0078
    add x7, x7, x6                                      ; pc=0x007C
    sw x3, 0(x7)                                        ; pc=0x0080
    addi x8, x0, 1                                      ; pc=0x0084
    add x10, x3, x3                                     ; pc=0x0088
    add x10, x10, x10                                   ; pc=0x008C
    addiSigned x9, x17, -512                            ; pc=0x0090
    add x9, x9, x10                                     ; pc=0x0094
    sw x8, 0(x9)                                        ; pc=0x0098
    addi x5, x0, 1                                      ; pc=0x009C
    add x6, x3, x5                                      ; pc=0x00A0
    addi x7, x0, 1                                      ; pc=0x00A4
    add x10, x3, x7                                     ; pc=0x00A8
    add x9, x10, x10                                    ; pc=0x00AC
    add x9, x9, x9                                      ; pc=0x00B0
    addiSigned x8, x17, -256                            ; pc=0x00B4
    add x8, x8, x9                                      ; pc=0x00B8
    sw x6, 0(x8)                                        ; pc=0x00BC
    addi x5, x0, 1                                      ; pc=0x00C0
    addi x7, x0, 1                                      ; pc=0x00C4
    add x9, x3, x7                                      ; pc=0x00C8
    add x10, x9, x9                                     ; pc=0x00CC
    add x10, x10, x10                                   ; pc=0x00D0
    addiSigned x8, x17, -512                            ; pc=0x00D4
    add x8, x8, x10                                     ; pc=0x00D8
    sw x5, 0(x8)                                        ; pc=0x00DC
    addi x6, x0, 2                                      ; pc=0x00E0
    add x7, x3, x6                                      ; pc=0x00E4
    addi x10, x0, 2                                     ; pc=0x00E8
    add x9, x3, x10                                     ; pc=0x00EC
    add x8, x9, x9                                      ; pc=0x00F0
    add x8, x8, x8                                      ; pc=0x00F4
    addiSigned x5, x17, -256                            ; pc=0x00F8
    add x5, x5, x8                                      ; pc=0x00FC
    sw x7, 0(x5)                                        ; pc=0x0100
    addi x6, x0, 1                                      ; pc=0x0104
    addi x10, x0, 2                                     ; pc=0x0108
    add x8, x3, x10                                     ; pc=0x010C
    add x9, x8, x8                                      ; pc=0x0110
    add x9, x9, x9                                      ; pc=0x0114
    addiSigned x5, x17, -512                            ; pc=0x0118
    add x5, x5, x9                                      ; pc=0x011C
    sw x6, 0(x5)                                        ; pc=0x0120
    addi x7, x0, 3                                      ; pc=0x0124
    add x10, x3, x7                                     ; pc=0x0128
    addi x9, x0, 3                                      ; pc=0x012C
    add x8, x3, x9                                      ; pc=0x0130
    add x5, x8, x8                                      ; pc=0x0134
    add x5, x5, x5                                      ; pc=0x0138
    addiSigned x6, x17, -256                            ; pc=0x013C
    add x6, x6, x5                                      ; pc=0x0140
    sw x10, 0(x6)                                       ; pc=0x0144
    addi x7, x0, 1                                      ; pc=0x0148
    addi x9, x0, 3                                      ; pc=0x014C
    add x5, x3, x9                                      ; pc=0x0150
    add x8, x5, x5                                      ; pc=0x0154
    add x8, x8, x8                                      ; pc=0x0158
    addiSigned x6, x17, -512                            ; pc=0x015C
    add x6, x6, x8                                      ; pc=0x0160
    sw x7, 0(x6)                                        ; pc=0x0164
    addi x10, x0, 4                                     ; pc=0x0168
    add x9, x3, x10                                     ; pc=0x016C
    addi x8, x0, 4                                      ; pc=0x0170
    add x5, x3, x8                                      ; pc=0x0174
    add x6, x5, x5                                      ; pc=0x0178
    add x6, x6, x6                                      ; pc=0x017C
    addiSigned x7, x17, -256                            ; pc=0x0180
    add x7, x7, x6                                      ; pc=0x0184
    sw x9, 0(x7)                                        ; pc=0x0188
    addi x10, x0, 1                                     ; pc=0x018C
    addi x8, x0, 4                                      ; pc=0x0190
    add x6, x3, x8                                      ; pc=0x0194
    add x5, x6, x6                                      ; pc=0x0198
    add x5, x5, x5                                      ; pc=0x019C
    addiSigned x7, x17, -512                            ; pc=0x01A0
    add x7, x7, x5                                      ; pc=0x01A4
    sw x10, 0(x7)                                       ; pc=0x01A8
    addi x9, x0, 5                                      ; pc=0x01AC
    add x8, x3, x9                                      ; pc=0x01B0
    addi x5, x0, 5                                      ; pc=0x01B4
    add x6, x3, x5                                      ; pc=0x01B8
    add x7, x6, x6                                      ; pc=0x01BC
    add x7, x7, x7                                      ; pc=0x01C0
    addiSigned x10, x17, -256                           ; pc=0x01C4
    add x10, x10, x7                                    ; pc=0x01C8
    sw x8, 0(x10)                                       ; pc=0x01CC
    addi x9, x0, 1                                      ; pc=0x01D0
    addi x5, x0, 5                                      ; pc=0x01D4
    add x7, x3, x5                                      ; pc=0x01D8
    add x6, x7, x7                                      ; pc=0x01DC
    add x6, x6, x6                                      ; pc=0x01E0
    addiSigned x10, x17, -512                           ; pc=0x01E4
    add x10, x10, x6                                    ; pc=0x01E8
    sw x9, 0(x10)                                       ; pc=0x01EC
    addi x8, x0, 6                                      ; pc=0x01F0
    add x5, x3, x8                                      ; pc=0x01F4
    addi x6, x0, 6                                      ; pc=0x01F8
    add x7, x3, x6                                      ; pc=0x01FC
    add x10, x7, x7                                     ; pc=0x0200
    add x10, x10, x10                                   ; pc=0x0204
    addiSigned x9, x17, -256                            ; pc=0x0208
    add x9, x9, x10                                     ; pc=0x020C
    sw x5, 0(x9)                                        ; pc=0x0210
    addi x8, x0, 1                                      ; pc=0x0214
    addi x6, x0, 6                                      ; pc=0x0218
    add x10, x3, x6                                     ; pc=0x021C
    add x7, x10, x10                                    ; pc=0x0220
    add x7, x7, x7                                      ; pc=0x0224
    addiSigned x9, x17, -512                            ; pc=0x0228
    add x9, x9, x7                                      ; pc=0x022C
    sw x8, 0(x9)                                        ; pc=0x0230
    addi x5, x0, 7                                      ; pc=0x0234
    add x6, x3, x5                                      ; pc=0x0238
    addi x7, x0, 7                                      ; pc=0x023C
    add x10, x3, x7                                     ; pc=0x0240
    add x9, x10, x10                                    ; pc=0x0244
    add x9, x9, x9                                      ; pc=0x0248
    addiSigned x8, x17, -256                            ; pc=0x024C
    add x8, x8, x9                                      ; pc=0x0250
    sw x6, 0(x8)                                        ; pc=0x0254
    addi x5, x0, 1                                      ; pc=0x0258
    addi x7, x0, 7                                      ; pc=0x025C
    add x9, x3, x7                                      ; pc=0x0260
    add x10, x9, x9                                     ; pc=0x0264
    add x10, x10, x10                                   ; pc=0x0268
    addiSigned x8, x17, -512                            ; pc=0x026C
    add x8, x8, x10                                     ; pc=0x0270
    sw x5, 0(x8)                                        ; pc=0x0274
    addi x6, x0, 8                                      ; pc=0x0278
    add x7, x3, x6                                      ; pc=0x027C
    add x3, x7, x0 ; promote i                          ; pc=0x0280
    jal x0, -564                                        ; pc=0x0284 ; target=L_while_start_0 ; addr=0x0050
L_while_end_1:
    addi x10, x0, 0                                     ; pc=0x0288
    add x3, x10, x0 ; promote i                         ; pc=0x028C
    addi x9, x0, 0                                      ; pc=0x0290
    sw x9, -784(x17) ; ia                               ; pc=0x0294
L_while_start_2:
    addi x8, x0, 8                                      ; pc=0x0298
    addi x5, x0, 0                                      ; pc=0x029C
    blt x3, x8, 8                                       ; pc=0x02A0 ; target=.L_ir_4_ir_cmp_true ; addr=0x02A8
    jal x0, 8                                           ; pc=0x02A4 ; target=.L_ir_5_ir_cmp_end ; addr=0x02AC
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x02A8
.L_ir_5_ir_cmp_end:
    sw x5, -808(x17) ; t2__x5                           ; pc=0x02AC
    lw x5, -808(x17) ; t2__x5                           ; pc=0x02B0
    beq x5, x0, 368                                     ; pc=0x02B4 ; target=L_while_end_3 ; addr=0x0424
    addi x7, x0, 0                                      ; pc=0x02B8
    sw x7, -776(x17) ; j                                ; pc=0x02BC
L_while_start_4:
    lw x6, -776(x17) ; j                                ; pc=0x02C0
    addi x10, x0, 8                                     ; pc=0x02C4
    addi x9, x0, 0                                      ; pc=0x02C8
    blt x6, x10, 8                                      ; pc=0x02CC ; target=.L_ir_6_ir_cmp_true ; addr=0x02D4
    jal x0, 8                                           ; pc=0x02D0 ; target=.L_ir_7_ir_cmp_end ; addr=0x02D8
.L_ir_6_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x02D4
.L_ir_7_ir_cmp_end:
    sw x9, -812(x17) ; t3__x6                           ; pc=0x02D8
    lw x6, -812(x17) ; t3__x6                           ; pc=0x02DC
    beq x6, x0, 292                                     ; pc=0x02E0 ; target=L_while_end_5 ; addr=0x0404
    addi x8, x0, 0                                      ; pc=0x02E4
    sw x8, -792(x17) ; acc                              ; pc=0x02E8
    addi x5, x0, 0                                      ; pc=0x02EC
    sw x5, -780(x17) ; k                                ; pc=0x02F0
    addi x7, x0, 0                                      ; pc=0x02F4
    sw x7, -788(x17) ; kb                               ; pc=0x02F8
L_while_start_6:
    lw x9, -780(x17) ; k                                ; pc=0x02FC
    addi x10, x0, 8                                     ; pc=0x0300
    addi x7, x0, 0                                      ; pc=0x0304
    blt x9, x10, 8                                      ; pc=0x0308 ; target=.L_ir_8_ir_cmp_true ; addr=0x0310
    jal x0, 8                                           ; pc=0x030C ; target=.L_ir_9_ir_cmp_end ; addr=0x0314
.L_ir_8_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0310
.L_ir_9_ir_cmp_end:
    sw x7, -816(x17) ; t4__x7                           ; pc=0x0314
    lw x7, -816(x17) ; t4__x7                           ; pc=0x0318
    beq x7, x0, 168                                     ; pc=0x031C ; target=L_while_end_7 ; addr=0x03C4
    lw x6, -784(x17) ; ia                               ; pc=0x0320
    lw x8, -780(x17) ; k                                ; pc=0x0324
    add x5, x6, x8                                      ; pc=0x0328
    sw x5, -820(x17) ; t5__x8                           ; pc=0x032C
    lw x8, -820(x17) ; t5__x8                           ; pc=0x0330
    add x10, x8, x8                                     ; pc=0x0334
    add x10, x10, x10                                   ; pc=0x0338
    addiSigned x9, x17, -256                            ; pc=0x033C
    add x9, x9, x10                                     ; pc=0x0340
    lw x7, 0(x9)                                        ; pc=0x0344
    sw x7, -824(x17) ; t6__x9                           ; pc=0x0348
    lw x5, -788(x17) ; kb                               ; pc=0x034C
    lw x6, -776(x17) ; j                                ; pc=0x0350
    add x10, x5, x6                                     ; pc=0x0354
    sw x10, -828(x17) ; t7__x10                         ; pc=0x0358
    lw x10, -828(x17) ; t7__x10                         ; pc=0x035C
    add x8, x10, x10                                    ; pc=0x0360
    add x8, x8, x8                                      ; pc=0x0364
    addiSigned x9, x17, -512                            ; pc=0x0368
    add x9, x9, x8                                      ; pc=0x036C
    lw x7, 0(x9)                                        ; pc=0x0370
    sw x7, -832(x17) ; t8__x3                           ; pc=0x0374
    lw x6, -780(x17) ; k                                ; pc=0x0378
    addi x5, x0, 1                                      ; pc=0x037C
    add x8, x6, x5                                      ; pc=0x0380
    sw x8, -836(x17) ; t11__x6                          ; pc=0x0384
    lw x9, -824(x17) ; t6__x9                           ; pc=0x0388
    lw x10, -832(x17) ; t8__x3                          ; pc=0x038C
    mul x7, x9, x10                                     ; pc=0x0390
    sw x7, -840(x17) ; t9__x4                           ; pc=0x0394
    lw x8, -792(x17) ; acc                              ; pc=0x0398
    lw x5, -840(x17) ; t9__x4                           ; pc=0x039C
    add x6, x8, x5                                      ; pc=0x03A0
    sw x6, -792(x17) ; acc                              ; pc=0x03A4
    lw x6, -836(x17) ; t11__x6                          ; pc=0x03A8
    sw x6, -780(x17) ; k                                ; pc=0x03AC
    lw x7, -788(x17) ; kb                               ; pc=0x03B0
    addi x10, x0, 8                                     ; pc=0x03B4
    add x9, x7, x10                                     ; pc=0x03B8
    sw x9, -788(x17) ; kb                               ; pc=0x03BC
    jal x0, -196                                        ; pc=0x03C0 ; target=L_while_start_6 ; addr=0x02FC
L_while_end_7:
    lw x5, -784(x17) ; ia                               ; pc=0x03C4
    lw x8, -776(x17) ; j                                ; pc=0x03C8
    add x6, x5, x8                                      ; pc=0x03CC
    sw x6, -852(x17) ; t13__x8                          ; pc=0x03D0
    lw x9, -792(x17) ; acc                              ; pc=0x03D4
    lw x8, -852(x17) ; t13__x8                          ; pc=0x03D8
    add x10, x8, x8                                     ; pc=0x03DC
    add x10, x10, x10                                   ; pc=0x03E0
    addiSigned x7, x17, -768                            ; pc=0x03E4
    add x7, x7, x10                                     ; pc=0x03E8
    sw x9, 0(x7)                                        ; pc=0x03EC
    lw x6, -776(x17) ; j                                ; pc=0x03F0
    addi x5, x0, 1                                      ; pc=0x03F4
    add x10, x6, x5                                     ; pc=0x03F8
    sw x10, -776(x17) ; j                               ; pc=0x03FC
    jal x0, -320                                        ; pc=0x0400 ; target=L_while_start_4 ; addr=0x02C0
L_while_end_5:
    addi x8, x0, 1                                      ; pc=0x0404
    add x7, x3, x8                                      ; pc=0x0408
    add x3, x7, x0 ; promote i                          ; pc=0x040C
    lw x9, -784(x17) ; ia                               ; pc=0x0410
    addi x10, x0, 8                                     ; pc=0x0414
    add x5, x9, x10                                     ; pc=0x0418
    sw x5, -784(x17) ; ia                               ; pc=0x041C
    jal x0, -392                                        ; pc=0x0420 ; target=L_while_start_2 ; addr=0x0298
L_while_end_3:
    addi x6, x0, 0                                      ; pc=0x0424
    add x4, x6, x0 ; promote suma                       ; pc=0x0428
    addi x7, x0, 0                                      ; pc=0x042C
    add x3, x7, x0 ; promote i                          ; pc=0x0430
L_while_start_8:
    addi x8, x0, 64                                     ; pc=0x0434
    addi x5, x0, 0                                      ; pc=0x0438
    blt x3, x8, 8                                       ; pc=0x043C ; target=.L_ir_10_ir_cmp_true ; addr=0x0444
    jal x0, 8                                           ; pc=0x0440 ; target=.L_ir_11_ir_cmp_end ; addr=0x0448
.L_ir_10_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0444
.L_ir_11_ir_cmp_end:
    sw x5, -868(x17) ; t23__x4                          ; pc=0x0448
    lw x10, -868(x17) ; t23__x4                         ; pc=0x044C
    beq x10, x0, 188                                    ; pc=0x0450 ; target=L_while_end_9 ; addr=0x050C
    add x9, x3, x3                                      ; pc=0x0454
    add x9, x9, x9                                      ; pc=0x0458
    addiSigned x6, x17, -768                            ; pc=0x045C
    add x6, x6, x9                                      ; pc=0x0460
    lw x7, 0(x6)                                        ; pc=0x0464
    sw x7, -872(x17) ; t24__x5                          ; pc=0x0468
    addi x5, x0, 1                                      ; pc=0x046C
    add x8, x3, x5                                      ; pc=0x0470
    add x10, x8, x8                                     ; pc=0x0474
    add x10, x10, x10                                   ; pc=0x0478
    addiSigned x9, x17, -768                            ; pc=0x047C
    add x9, x9, x10                                     ; pc=0x0480
    lw x6, 0(x9)                                        ; pc=0x0484
    sw x6, -876(x17) ; t26__x7                          ; pc=0x0488
    lw x5, -872(x17) ; t24__x5                          ; pc=0x048C
    add x7, x4, x5                                      ; pc=0x0490
    add x4, x7, x0 ; promote suma                       ; pc=0x0494
    lw x7, -876(x17) ; t26__x7                          ; pc=0x0498
    add x10, x4, x7                                     ; pc=0x049C
    add x4, x10, x0 ; promote suma                      ; pc=0x04A0
    addi x8, x0, 2                                      ; pc=0x04A4
    add x9, x3, x8                                      ; pc=0x04A8
    add x6, x9, x9                                      ; pc=0x04AC
    add x6, x6, x6                                      ; pc=0x04B0
    addiSigned x5, x17, -768                            ; pc=0x04B4
    add x5, x5, x6                                      ; pc=0x04B8
    lw x10, 0(x5)                                       ; pc=0x04BC
    sw x10, -888(x17) ; t28__x9                         ; pc=0x04C0
    addi x7, x0, 3                                      ; pc=0x04C4
    add x8, x3, x7                                      ; pc=0x04C8
    add x6, x8, x8                                      ; pc=0x04CC
    add x6, x6, x6                                      ; pc=0x04D0
    addiSigned x9, x17, -768                            ; pc=0x04D4
    add x9, x9, x6                                      ; pc=0x04D8
    lw x5, 0(x9)                                        ; pc=0x04DC
    sw x5, -892(x17) ; t30__x3                          ; pc=0x04E0
    lw x9, -888(x17) ; t28__x9                          ; pc=0x04E4
    add x10, x4, x9                                     ; pc=0x04E8
    add x4, x10, x0 ; promote suma                      ; pc=0x04EC
    lw x7, -892(x17) ; t30__x3                          ; pc=0x04F0
    add x6, x4, x7                                      ; pc=0x04F4
    add x4, x6, x0 ; promote suma                       ; pc=0x04F8
    addi x8, x0, 4                                      ; pc=0x04FC
    add x5, x3, x8                                      ; pc=0x0500
    add x3, x5, x0 ; promote i                          ; pc=0x0504
    jal x0, -212                                        ; pc=0x0508 ; target=L_while_start_8 ; addr=0x0434
L_while_end_9:
    add x11, x4, x0                                     ; pc=0x050C
    jal x0, 4                                           ; pc=0x0510 ; target=.L_ir_1_main_end ; addr=0x0514
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0514
    addi x2, x2, 912                                    ; pc=0x0518
    freeze                                              ; pc=0x051C