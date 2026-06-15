; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x0080
;   .L_ir_2_ir_cmp_true = 0x0090
;   .L_ir_3_ir_cmp_end = 0x0094
;   L_while_end_1 = 0x00DC
;   L_while_start_2 = 0x00EC
;   .L_ir_4_ir_cmp_true = 0x00FC
;   .L_ir_5_ir_cmp_end = 0x0100
;   L_while_start_4 = 0x0114
;   .L_ir_6_ir_cmp_true = 0x0124
;   .L_ir_7_ir_cmp_end = 0x0128
;   L_while_start_6 = 0x014C
;   .L_ir_8_ir_cmp_true = 0x0160
;   .L_ir_9_ir_cmp_end = 0x0164
;   L_while_end_7 = 0x0208
;   L_while_end_5 = 0x0240
;   L_while_end_3 = 0x0260
;   L_while_start_8 = 0x0270
;   .L_ir_10_ir_cmp_true = 0x0280
;   .L_ir_11_ir_cmp_end = 0x0284
;   L_while_end_9 = 0x02C8
;   .L_ir_1_main_end = 0x02D4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0088 blt -> .L_ir_2_ir_cmp_true (addr=0x0090, offset=8)
;   pc=0x008C jal -> .L_ir_3_ir_cmp_end (addr=0x0094, offset=8)
;   pc=0x009C beq -> L_while_end_1 (addr=0x00DC, offset=64)
;   pc=0x00D8 jal -> L_while_start_0 (addr=0x0080, offset=-88)
;   pc=0x00F4 blt -> .L_ir_4_ir_cmp_true (addr=0x00FC, offset=8)
;   pc=0x00F8 jal -> .L_ir_5_ir_cmp_end (addr=0x0100, offset=8)
;   pc=0x0108 beq -> L_while_end_3 (addr=0x0260, offset=344)
;   pc=0x011C blt -> .L_ir_6_ir_cmp_true (addr=0x0124, offset=8)
;   pc=0x0120 jal -> .L_ir_7_ir_cmp_end (addr=0x0128, offset=8)
;   pc=0x0130 beq -> L_while_end_5 (addr=0x0240, offset=272)
;   pc=0x0158 blt -> .L_ir_8_ir_cmp_true (addr=0x0160, offset=8)
;   pc=0x015C jal -> .L_ir_9_ir_cmp_end (addr=0x0164, offset=8)
;   pc=0x016C beq -> L_while_end_7 (addr=0x0208, offset=156)
;   pc=0x0204 jal -> L_while_start_6 (addr=0x014C, offset=-184)
;   pc=0x023C jal -> L_while_start_4 (addr=0x0114, offset=-296)
;   pc=0x025C jal -> L_while_start_2 (addr=0x00EC, offset=-368)
;   pc=0x0278 blt -> .L_ir_10_ir_cmp_true (addr=0x0280, offset=8)
;   pc=0x027C jal -> .L_ir_11_ir_cmp_end (addr=0x0284, offset=8)
;   pc=0x028C beq -> L_while_end_9 (addr=0x02C8, offset=60)
;   pc=0x02C4 jal -> L_while_start_8 (addr=0x0270, offset=-84)
;   pc=0x02D0 jal -> .L_ir_1_main_end (addr=0x02D4, offset=4)

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
    addi x9, x0, 0                                      ; pc=0x0050
    add x4, x9, x0 ; promote j                          ; pc=0x0054
    addi x10, x0, 0                                     ; pc=0x0058
    sw x10, -780(x17) ; k                               ; pc=0x005C
    addi x5, x0, 0                                      ; pc=0x0060
    sw x5, -784(x17) ; ia                               ; pc=0x0064
    addi x6, x0, 0                                      ; pc=0x0068
    sw x6, -788(x17) ; kb                               ; pc=0x006C
    addi x7, x0, 0                                      ; pc=0x0070
    sw x7, -792(x17) ; acc                              ; pc=0x0074
    addi x8, x0, 0                                      ; pc=0x0078
    sw x8, -796(x17) ; suma                             ; pc=0x007C
L_while_start_0:
    addi x9, x0, 64                                     ; pc=0x0080
    addi x10, x0, 0                                     ; pc=0x0084
    blt x3, x9, 8                                       ; pc=0x0088 ; target=.L_ir_2_ir_cmp_true ; addr=0x0090
    jal x0, 8                                           ; pc=0x008C ; target=.L_ir_3_ir_cmp_end ; addr=0x0094
.L_ir_2_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x0090
.L_ir_3_ir_cmp_end:
    sw x10, -800(x17) ; t0__x3                          ; pc=0x0094
    lw x5, -800(x17) ; t0__x3                           ; pc=0x0098
    beq x5, x0, 64                                      ; pc=0x009C ; target=L_while_end_1 ; addr=0x00DC
    add x6, x3, x3                                      ; pc=0x00A0
    add x6, x6, x6                                      ; pc=0x00A4
    addiSigned x7, x17, -256                            ; pc=0x00A8
    add x7, x7, x6                                      ; pc=0x00AC
    sw x3, 0(x7)                                        ; pc=0x00B0
    addi x8, x0, 1                                      ; pc=0x00B4
    add x10, x3, x3                                     ; pc=0x00B8
    add x10, x10, x10                                   ; pc=0x00BC
    addiSigned x9, x17, -512                            ; pc=0x00C0
    add x9, x9, x10                                     ; pc=0x00C4
    sw x8, 0(x9)                                        ; pc=0x00C8
    addi x5, x0, 1                                      ; pc=0x00CC
    add x6, x3, x5                                      ; pc=0x00D0
    add x3, x6, x0 ; promote i                          ; pc=0x00D4
    jal x0, -88                                         ; pc=0x00D8 ; target=L_while_start_0 ; addr=0x0080
L_while_end_1:
    addi x7, x0, 0                                      ; pc=0x00DC
    add x3, x7, x0 ; promote i                          ; pc=0x00E0
    addi x10, x0, 0                                     ; pc=0x00E4
    sw x10, -784(x17) ; ia                              ; pc=0x00E8
L_while_start_2:
    addi x9, x0, 8                                      ; pc=0x00EC
    addi x5, x0, 0                                      ; pc=0x00F0
    blt x3, x9, 8                                       ; pc=0x00F4 ; target=.L_ir_4_ir_cmp_true ; addr=0x00FC
    jal x0, 8                                           ; pc=0x00F8 ; target=.L_ir_5_ir_cmp_end ; addr=0x0100
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x00FC
.L_ir_5_ir_cmp_end:
    sw x5, -808(x17) ; t2__x5                           ; pc=0x0100
    lw x5, -808(x17) ; t2__x5                           ; pc=0x0104
    beq x5, x0, 344                                     ; pc=0x0108 ; target=L_while_end_3 ; addr=0x0260
    addi x8, x0, 0                                      ; pc=0x010C
    add x4, x8, x0 ; promote j                          ; pc=0x0110
L_while_start_4:
    addi x6, x0, 8                                      ; pc=0x0114
    addi x7, x0, 0                                      ; pc=0x0118
    blt x4, x6, 8                                       ; pc=0x011C ; target=.L_ir_6_ir_cmp_true ; addr=0x0124
    jal x0, 8                                           ; pc=0x0120 ; target=.L_ir_7_ir_cmp_end ; addr=0x0128
.L_ir_6_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0124
.L_ir_7_ir_cmp_end:
    sw x7, -812(x17) ; t3__x6                           ; pc=0x0128
    lw x6, -812(x17) ; t3__x6                           ; pc=0x012C
    beq x6, x0, 272                                     ; pc=0x0130 ; target=L_while_end_5 ; addr=0x0240
    addi x10, x0, 0                                     ; pc=0x0134
    sw x10, -792(x17) ; acc                             ; pc=0x0138
    addi x9, x0, 0                                      ; pc=0x013C
    sw x9, -780(x17) ; k                                ; pc=0x0140
    addi x5, x0, 0                                      ; pc=0x0144
    sw x5, -788(x17) ; kb                               ; pc=0x0148
L_while_start_6:
    lw x8, -780(x17) ; k                                ; pc=0x014C
    addi x7, x0, 8                                      ; pc=0x0150
    addi x6, x0, 0                                      ; pc=0x0154
    blt x8, x7, 8                                       ; pc=0x0158 ; target=.L_ir_8_ir_cmp_true ; addr=0x0160
    jal x0, 8                                           ; pc=0x015C ; target=.L_ir_9_ir_cmp_end ; addr=0x0164
.L_ir_8_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0160
.L_ir_9_ir_cmp_end:
    sw x6, -816(x17) ; t4__x7                           ; pc=0x0164
    lw x7, -816(x17) ; t4__x7                           ; pc=0x0168
    beq x7, x0, 156                                     ; pc=0x016C ; target=L_while_end_7 ; addr=0x0208
    lw x10, -784(x17) ; ia                              ; pc=0x0170
    lw x9, -780(x17) ; k                                ; pc=0x0174
    add x8, x10, x9                                     ; pc=0x0178
    sw x8, -820(x17) ; t5__x8                           ; pc=0x017C
    lw x8, -820(x17) ; t5__x8                           ; pc=0x0180
    add x5, x8, x8                                      ; pc=0x0184
    add x5, x5, x5                                      ; pc=0x0188
    addiSigned x6, x17, -256                            ; pc=0x018C
    add x6, x6, x5                                      ; pc=0x0190
    lw x7, 0(x6)                                        ; pc=0x0194
    sw x7, -824(x17) ; t6__x9                           ; pc=0x0198
    lw x9, -788(x17) ; kb                               ; pc=0x019C
    add x10, x9, x4                                     ; pc=0x01A0
    sw x10, -828(x17) ; t7__x10                         ; pc=0x01A4
    lw x10, -828(x17) ; t7__x10                         ; pc=0x01A8
    add x5, x10, x10                                    ; pc=0x01AC
    add x5, x5, x5                                      ; pc=0x01B0
    addiSigned x8, x17, -512                            ; pc=0x01B4
    add x8, x8, x5                                      ; pc=0x01B8
    lw x6, 0(x8)                                        ; pc=0x01BC
    sw x6, -832(x17) ; t8__x3                           ; pc=0x01C0
    lw x9, -824(x17) ; t6__x9                           ; pc=0x01C4
    lw x7, -832(x17) ; t8__x3                           ; pc=0x01C8
    mul x5, x9, x7                                      ; pc=0x01CC
    sw x5, -836(x17) ; t9__x4                           ; pc=0x01D0
    lw x10, -792(x17) ; acc                             ; pc=0x01D4
    lw x8, -836(x17) ; t9__x4                           ; pc=0x01D8
    add x6, x10, x8                                     ; pc=0x01DC
    sw x6, -792(x17) ; acc                              ; pc=0x01E0
    lw x5, -780(x17) ; k                                ; pc=0x01E4
    addi x7, x0, 1                                      ; pc=0x01E8
    add x9, x5, x7                                      ; pc=0x01EC
    sw x9, -780(x17) ; k                                ; pc=0x01F0
    lw x6, -788(x17) ; kb                               ; pc=0x01F4
    addi x8, x0, 8                                      ; pc=0x01F8
    add x10, x6, x8                                     ; pc=0x01FC
    sw x10, -788(x17) ; kb                              ; pc=0x0200
    jal x0, -184                                        ; pc=0x0204 ; target=L_while_start_6 ; addr=0x014C
L_while_end_7:
    lw x9, -784(x17) ; ia                               ; pc=0x0208
    add x8, x9, x4                                      ; pc=0x020C
    sw x8, -852(x17) ; t13__x8                          ; pc=0x0210
    lw x7, -792(x17) ; acc                              ; pc=0x0214
    lw x8, -852(x17) ; t13__x8                          ; pc=0x0218
    add x5, x8, x8                                      ; pc=0x021C
    add x5, x5, x5                                      ; pc=0x0220
    addiSigned x10, x17, -768                           ; pc=0x0224
    add x10, x10, x5                                    ; pc=0x0228
    sw x7, 0(x10)                                       ; pc=0x022C
    addi x6, x0, 1                                      ; pc=0x0230
    add x9, x4, x6                                      ; pc=0x0234
    add x4, x9, x0 ; promote j                          ; pc=0x0238
    jal x0, -296                                        ; pc=0x023C ; target=L_while_start_4 ; addr=0x0114
L_while_end_5:
    addi x5, x0, 1                                      ; pc=0x0240
    add x8, x3, x5                                      ; pc=0x0244
    add x3, x8, x0 ; promote i                          ; pc=0x0248
    lw x10, -784(x17) ; ia                              ; pc=0x024C
    addi x7, x0, 8                                      ; pc=0x0250
    add x9, x10, x7                                     ; pc=0x0254
    sw x9, -784(x17) ; ia                               ; pc=0x0258
    jal x0, -368                                        ; pc=0x025C ; target=L_while_start_2 ; addr=0x00EC
L_while_end_3:
    addi x6, x0, 0                                      ; pc=0x0260
    sw x6, -796(x17) ; suma                             ; pc=0x0264
    addi x8, x0, 0                                      ; pc=0x0268
    add x3, x8, x0 ; promote i                          ; pc=0x026C
L_while_start_8:
    addi x5, x0, 64                                     ; pc=0x0270
    addi x9, x0, 0                                      ; pc=0x0274
    blt x3, x5, 8                                       ; pc=0x0278 ; target=.L_ir_10_ir_cmp_true ; addr=0x0280
    jal x0, 8                                           ; pc=0x027C ; target=.L_ir_11_ir_cmp_end ; addr=0x0284
.L_ir_10_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0280
.L_ir_11_ir_cmp_end:
    sw x9, -868(x17) ; t17__x4                          ; pc=0x0284
    lw x7, -868(x17) ; t17__x4                          ; pc=0x0288
    beq x7, x0, 60                                      ; pc=0x028C ; target=L_while_end_9 ; addr=0x02C8
    add x10, x3, x3                                     ; pc=0x0290
    add x10, x10, x10                                   ; pc=0x0294
    addiSigned x6, x17, -768                            ; pc=0x0298
    add x6, x6, x10                                     ; pc=0x029C
    lw x8, 0(x6)                                        ; pc=0x02A0
    sw x8, -872(x17) ; t18__x5                          ; pc=0x02A4
    lw x9, -796(x17) ; suma                             ; pc=0x02A8
    lw x5, -872(x17) ; t18__x5                          ; pc=0x02AC
    add x7, x9, x5                                      ; pc=0x02B0
    sw x7, -796(x17) ; suma                             ; pc=0x02B4
    addi x10, x0, 1                                     ; pc=0x02B8
    add x6, x3, x10                                     ; pc=0x02BC
    add x3, x6, x0 ; promote i                          ; pc=0x02C0
    jal x0, -84                                         ; pc=0x02C4 ; target=L_while_start_8 ; addr=0x0270
L_while_end_9:
    lw x8, -796(x17) ; suma                             ; pc=0x02C8
    add x11, x8, x0                                     ; pc=0x02CC
    jal x0, 4                                           ; pc=0x02D0 ; target=.L_ir_1_main_end ; addr=0x02D4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x02D4
    addi x2, x2, 888                                    ; pc=0x02D8
    freeze                                              ; pc=0x02DC