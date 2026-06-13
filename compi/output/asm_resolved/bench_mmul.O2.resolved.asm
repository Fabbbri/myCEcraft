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
;   L_while_end_1 = 0x00AC
;   L_while_start_2 = 0x00BC
;   .L_ir_4_ir_cmp_true = 0x00CC
;   .L_ir_5_ir_cmp_end = 0x00D0
;   L_while_start_4 = 0x00E4
;   .L_ir_6_ir_cmp_true = 0x00F4
;   .L_ir_7_ir_cmp_end = 0x00F8
;   L_while_start_6 = 0x011C
;   .L_ir_8_ir_cmp_true = 0x0130
;   .L_ir_9_ir_cmp_end = 0x0134
;   L_while_end_7 = 0x01E0
;   L_while_end_5 = 0x0218
;   L_while_end_3 = 0x0238
;   L_while_start_8 = 0x0248
;   .L_ir_10_ir_cmp_true = 0x0258
;   .L_ir_11_ir_cmp_end = 0x025C
;   L_while_end_9 = 0x02A8
;   .L_ir_1_main_end = 0x02B4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0058 blt -> .L_ir_2_ir_cmp_true (addr=0x0060, offset=8)
;   pc=0x005C jal -> .L_ir_3_ir_cmp_end (addr=0x0064, offset=8)
;   pc=0x006C beq -> L_while_end_1 (addr=0x00AC, offset=64)
;   pc=0x00A8 jal -> L_while_start_0 (addr=0x0050, offset=-88)
;   pc=0x00C4 blt -> .L_ir_4_ir_cmp_true (addr=0x00CC, offset=8)
;   pc=0x00C8 jal -> .L_ir_5_ir_cmp_end (addr=0x00D0, offset=8)
;   pc=0x00D8 beq -> L_while_end_3 (addr=0x0238, offset=352)
;   pc=0x00EC blt -> .L_ir_6_ir_cmp_true (addr=0x00F4, offset=8)
;   pc=0x00F0 jal -> .L_ir_7_ir_cmp_end (addr=0x00F8, offset=8)
;   pc=0x0100 beq -> L_while_end_5 (addr=0x0218, offset=280)
;   pc=0x0128 blt -> .L_ir_8_ir_cmp_true (addr=0x0130, offset=8)
;   pc=0x012C jal -> .L_ir_9_ir_cmp_end (addr=0x0134, offset=8)
;   pc=0x013C beq -> L_while_end_7 (addr=0x01E0, offset=164)
;   pc=0x01DC jal -> L_while_start_6 (addr=0x011C, offset=-192)
;   pc=0x0214 jal -> L_while_start_4 (addr=0x00E4, offset=-304)
;   pc=0x0234 jal -> L_while_start_2 (addr=0x00BC, offset=-376)
;   pc=0x0250 blt -> .L_ir_10_ir_cmp_true (addr=0x0258, offset=8)
;   pc=0x0254 jal -> .L_ir_11_ir_cmp_end (addr=0x025C, offset=8)
;   pc=0x0264 beq -> L_while_end_9 (addr=0x02A8, offset=68)
;   pc=0x02A4 jal -> L_while_start_8 (addr=0x0248, offset=-92)
;   pc=0x02B0 jal -> .L_ir_1_main_end (addr=0x02B4, offset=4)

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
    addiSigned x2, x2, -888                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 888                                   ; pc=0x002C

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
    sw x10, -800(x17) ; t0                              ; pc=0x0064
    lw x5, -800(x17) ; t0                               ; pc=0x0068
    beq x5, x0, 64                                      ; pc=0x006C ; target=L_while_end_1 ; addr=0x00AC
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
    add x3, x6, x0 ; promote i                          ; pc=0x00A4
    jal x0, -88                                         ; pc=0x00A8 ; target=L_while_start_0 ; addr=0x0050
L_while_end_1:
    addi x7, x0, 0                                      ; pc=0x00AC
    add x3, x7, x0 ; promote i                          ; pc=0x00B0
    addi x10, x0, 0                                     ; pc=0x00B4
    sw x10, -784(x17) ; ia                              ; pc=0x00B8
L_while_start_2:
    addi x9, x0, 8                                      ; pc=0x00BC
    addi x8, x0, 0                                      ; pc=0x00C0
    blt x3, x9, 8                                       ; pc=0x00C4 ; target=.L_ir_4_ir_cmp_true ; addr=0x00CC
    jal x0, 8                                           ; pc=0x00C8 ; target=.L_ir_5_ir_cmp_end ; addr=0x00D0
.L_ir_4_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x00CC
.L_ir_5_ir_cmp_end:
    sw x8, -808(x17) ; t2                               ; pc=0x00D0
    lw x6, -808(x17) ; t2                               ; pc=0x00D4
    beq x6, x0, 352                                     ; pc=0x00D8 ; target=L_while_end_3 ; addr=0x0238
    addi x5, x0, 0                                      ; pc=0x00DC
    add x4, x5, x0 ; promote j                          ; pc=0x00E0
L_while_start_4:
    addi x7, x0, 8                                      ; pc=0x00E4
    addi x10, x0, 0                                     ; pc=0x00E8
    blt x4, x7, 8                                       ; pc=0x00EC ; target=.L_ir_6_ir_cmp_true ; addr=0x00F4
    jal x0, 8                                           ; pc=0x00F0 ; target=.L_ir_7_ir_cmp_end ; addr=0x00F8
.L_ir_6_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x00F4
.L_ir_7_ir_cmp_end:
    sw x10, -812(x17) ; t3                              ; pc=0x00F8
    lw x8, -812(x17) ; t3                               ; pc=0x00FC
    beq x8, x0, 280                                     ; pc=0x0100 ; target=L_while_end_5 ; addr=0x0218
    addi x9, x0, 0                                      ; pc=0x0104
    sw x9, -792(x17) ; acc                              ; pc=0x0108
    addi x6, x0, 0                                      ; pc=0x010C
    sw x6, -780(x17) ; k                                ; pc=0x0110
    addi x5, x0, 0                                      ; pc=0x0114
    sw x5, -788(x17) ; kb                               ; pc=0x0118
L_while_start_6:
    lw x10, -780(x17) ; k                               ; pc=0x011C
    addi x7, x0, 8                                      ; pc=0x0120
    addi x8, x0, 0                                      ; pc=0x0124
    blt x10, x7, 8                                      ; pc=0x0128 ; target=.L_ir_8_ir_cmp_true ; addr=0x0130
    jal x0, 8                                           ; pc=0x012C ; target=.L_ir_9_ir_cmp_end ; addr=0x0134
.L_ir_8_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0130
.L_ir_9_ir_cmp_end:
    sw x8, -816(x17) ; t4                               ; pc=0x0134
    lw x9, -816(x17) ; t4                               ; pc=0x0138
    beq x9, x0, 164                                     ; pc=0x013C ; target=L_while_end_7 ; addr=0x01E0
    lw x6, -784(x17) ; ia                               ; pc=0x0140
    lw x5, -780(x17) ; k                                ; pc=0x0144
    add x8, x6, x5                                      ; pc=0x0148
    sw x8, -820(x17) ; t5                               ; pc=0x014C
    lw x7, -820(x17) ; t5                               ; pc=0x0150
    add x10, x7, x7                                     ; pc=0x0154
    add x10, x10, x10                                   ; pc=0x0158
    addiSigned x9, x17, -256                            ; pc=0x015C
    add x9, x9, x10                                     ; pc=0x0160
    lw x8, 0(x9)                                        ; pc=0x0164
    sw x8, -824(x17) ; t6                               ; pc=0x0168
    lw x5, -788(x17) ; kb                               ; pc=0x016C
    add x6, x5, x4                                      ; pc=0x0170
    sw x6, -828(x17) ; t7                               ; pc=0x0174
    lw x10, -828(x17) ; t7                              ; pc=0x0178
    add x7, x10, x10                                    ; pc=0x017C
    add x7, x7, x7                                      ; pc=0x0180
    addiSigned x9, x17, -512                            ; pc=0x0184
    add x9, x9, x7                                      ; pc=0x0188
    lw x8, 0(x9)                                        ; pc=0x018C
    sw x8, -832(x17) ; t8                               ; pc=0x0190
    lw x6, -780(x17) ; k                                ; pc=0x0194
    addi x5, x0, 1                                      ; pc=0x0198
    add x7, x6, x5                                      ; pc=0x019C
    sw x7, -836(x17) ; t11                              ; pc=0x01A0
    lw x10, -824(x17) ; t6                              ; pc=0x01A4
    lw x9, -832(x17) ; t8                               ; pc=0x01A8
    mul x8, x10, x9                                     ; pc=0x01AC
    sw x8, -840(x17) ; t9                               ; pc=0x01B0
    lw x7, -792(x17) ; acc                              ; pc=0x01B4
    lw x5, -840(x17) ; t9                               ; pc=0x01B8
    add x6, x7, x5                                      ; pc=0x01BC
    sw x6, -792(x17) ; acc                              ; pc=0x01C0
    lw x8, -836(x17) ; t11                              ; pc=0x01C4
    sw x8, -780(x17) ; k                                ; pc=0x01C8
    lw x9, -788(x17) ; kb                               ; pc=0x01CC
    addi x10, x0, 8                                     ; pc=0x01D0
    add x6, x9, x10                                     ; pc=0x01D4
    sw x6, -788(x17) ; kb                               ; pc=0x01D8
    jal x0, -192                                        ; pc=0x01DC ; target=L_while_start_6 ; addr=0x011C
L_while_end_7:
    lw x5, -784(x17) ; ia                               ; pc=0x01E0
    add x7, x5, x4                                      ; pc=0x01E4
    sw x7, -852(x17) ; t13                              ; pc=0x01E8
    lw x8, -792(x17) ; acc                              ; pc=0x01EC
    lw x6, -852(x17) ; t13                              ; pc=0x01F0
    add x10, x6, x6                                     ; pc=0x01F4
    add x10, x10, x10                                   ; pc=0x01F8
    addiSigned x9, x17, -768                            ; pc=0x01FC
    add x9, x9, x10                                     ; pc=0x0200
    sw x8, 0(x9)                                        ; pc=0x0204
    addi x7, x0, 1                                      ; pc=0x0208
    add x5, x4, x7                                      ; pc=0x020C
    add x4, x5, x0 ; promote j                          ; pc=0x0210
    jal x0, -304                                        ; pc=0x0214 ; target=L_while_start_4 ; addr=0x00E4
L_while_end_5:
    addi x10, x0, 1                                     ; pc=0x0218
    add x6, x3, x10                                     ; pc=0x021C
    add x3, x6, x0 ; promote i                          ; pc=0x0220
    lw x9, -784(x17) ; ia                               ; pc=0x0224
    addi x8, x0, 8                                      ; pc=0x0228
    add x5, x9, x8                                      ; pc=0x022C
    sw x5, -784(x17) ; ia                               ; pc=0x0230
    jal x0, -376                                        ; pc=0x0234 ; target=L_while_start_2 ; addr=0x00BC
L_while_end_3:
    addi x7, x0, 0                                      ; pc=0x0238
    sw x7, -796(x17) ; suma                             ; pc=0x023C
    addi x6, x0, 0                                      ; pc=0x0240
    add x3, x6, x0 ; promote i                          ; pc=0x0244
L_while_start_8:
    addi x10, x0, 64                                    ; pc=0x0248
    addi x5, x0, 0                                      ; pc=0x024C
    blt x3, x10, 8                                      ; pc=0x0250 ; target=.L_ir_10_ir_cmp_true ; addr=0x0258
    jal x0, 8                                           ; pc=0x0254 ; target=.L_ir_11_ir_cmp_end ; addr=0x025C
.L_ir_10_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0258
.L_ir_11_ir_cmp_end:
    sw x5, -868(x17) ; t17                              ; pc=0x025C
    lw x8, -868(x17) ; t17                              ; pc=0x0260
    beq x8, x0, 68                                      ; pc=0x0264 ; target=L_while_end_9 ; addr=0x02A8
    add x9, x3, x3                                      ; pc=0x0268
    add x9, x9, x9                                      ; pc=0x026C
    addiSigned x7, x17, -768                            ; pc=0x0270
    add x7, x7, x9                                      ; pc=0x0274
    lw x6, 0(x7)                                        ; pc=0x0278
    sw x6, -872(x17) ; t18                              ; pc=0x027C
    addi x5, x0, 1                                      ; pc=0x0280
    add x10, x3, x5                                     ; pc=0x0284
    sw x10, -876(x17) ; t20                             ; pc=0x0288
    lw x8, -796(x17) ; suma                             ; pc=0x028C
    lw x9, -872(x17) ; t18                              ; pc=0x0290
    add x7, x8, x9                                      ; pc=0x0294
    sw x7, -796(x17) ; suma                             ; pc=0x0298
    lw x6, -876(x17) ; t20                              ; pc=0x029C
    add x3, x6, x0 ; promote i                          ; pc=0x02A0
    jal x0, -92                                         ; pc=0x02A4 ; target=L_while_start_8 ; addr=0x0248
L_while_end_9:
    lw x10, -796(x17) ; suma                            ; pc=0x02A8
    add x11, x10, x0                                    ; pc=0x02AC
    jal x0, 4                                           ; pc=0x02B0 ; target=.L_ir_1_main_end ; addr=0x02B4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x02B4
    addi x2, x2, 888                                    ; pc=0x02B8
    freeze                                              ; pc=0x02BC