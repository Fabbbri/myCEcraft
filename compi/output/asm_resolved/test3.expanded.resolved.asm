; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0080
;   maximo_lista = 0x008C
;   L_for_start_0 = 0x00E8
;   .L_ir_3_ir_cmp_true = 0x0108
;   .L_ir_4_ir_cmp_end = 0x010C
;   .L_ir_5_ir_cmp_true = 0x0148
;   .L_ir_6_ir_cmp_end = 0x014C
;   L_else_2 = 0x0174
;   L_end_if_3 = 0x0174
;   L_for_end_1 = 0x0184
;   .L_ir_2_maximo_lista_end = 0x01CC
;   sumeMayores = 0x01DC
;   .L_ir_8_ir_cmp_true = 0x0230
;   .L_ir_9_ir_cmp_end = 0x0234
;   L_while_start_4 = 0x0238
;   .L_ir_10_ir_cmp_true = 0x0298
;   .L_ir_11_ir_cmp_end = 0x029C
;   L_else_6 = 0x02C8
;   L_end_if_7 = 0x02C8
;   .L_ir_12_ir_cmp_true = 0x031C
;   .L_ir_13_ir_cmp_end = 0x0320
;   L_else_8 = 0x0350
;   L_end_if_9 = 0x0370
;   .L_ir_14_ir_cmp_true = 0x038C
;   .L_ir_15_ir_cmp_end = 0x0390
;   L_while_end_5 = 0x0398
;   .L_ir_7_sumeMayores_end = 0x0408

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x006C jal -> sumeMayores (addr=0x01DC, offset=368)
;   pc=0x007C jal -> .L_ir_1_main_end (addr=0x0080, offset=4)
;   pc=0x0100 blt -> .L_ir_3_ir_cmp_true (addr=0x0108, offset=8)
;   pc=0x0104 jal -> .L_ir_4_ir_cmp_end (addr=0x010C, offset=8)
;   pc=0x0114 beq -> L_for_end_1 (addr=0x0184, offset=112)
;   pc=0x0140 blt -> .L_ir_5_ir_cmp_true (addr=0x0148, offset=8)
;   pc=0x0144 jal -> .L_ir_6_ir_cmp_end (addr=0x014C, offset=8)
;   pc=0x0164 beq -> L_else_2 (addr=0x0174, offset=16)
;   pc=0x0170 jal -> L_end_if_3 (addr=0x0174, offset=4)
;   pc=0x0180 jal -> L_for_start_0 (addr=0x00E8, offset=-152)
;   pc=0x0188 jal -> .L_ir_2_maximo_lista_end (addr=0x01CC, offset=68)
;   pc=0x0228 blt -> .L_ir_8_ir_cmp_true (addr=0x0230, offset=8)
;   pc=0x022C jal -> .L_ir_9_ir_cmp_end (addr=0x0234, offset=8)
;   pc=0x0248 beq -> L_while_end_5 (addr=0x0398, offset=336)
;   pc=0x0264 jal -> maximo_lista (addr=0x008C, offset=-472)
;   pc=0x0290 beq -> .L_ir_10_ir_cmp_true (addr=0x0298, offset=8)
;   pc=0x0294 jal -> .L_ir_11_ir_cmp_end (addr=0x029C, offset=8)
;   pc=0x02B4 beq -> L_else_6 (addr=0x02C8, offset=20)
;   pc=0x02C4 jal -> L_end_if_7 (addr=0x02C8, offset=4)
;   pc=0x0314 blt -> .L_ir_12_ir_cmp_true (addr=0x031C, offset=8)
;   pc=0x0318 jal -> .L_ir_13_ir_cmp_end (addr=0x0320, offset=8)
;   pc=0x0338 beq -> L_else_8 (addr=0x0350, offset=24)
;   pc=0x034C jal -> L_end_if_9 (addr=0x0370, offset=36)
;   pc=0x0384 blt -> .L_ir_14_ir_cmp_true (addr=0x038C, offset=8)
;   pc=0x0388 jal -> .L_ir_15_ir_cmp_end (addr=0x0390, offset=8)
;   pc=0x0394 jal -> L_while_start_4 (addr=0x0238, offset=-348)
;   pc=0x0404 jal -> .L_ir_7_sumeMayores_end (addr=0x0408, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
suma: ; addr=0x8000
    .space 4
multiplicacion: ; addr=0x8004
    .space 4
resultado: ; addr=0x8008
    .space 8

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
    addiSigned x2, x2, -32                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 32                                    ; pc=0x002C

    addi x4, x0, 10                                     ; pc=0x0030
    sw x4, -20(x17) ; lista[0]                          ; pc=0x0034
    addi x5, x0, 2                                      ; pc=0x0038
    sw x5, -16(x17) ; lista[1]                          ; pc=0x003C
    addi x6, x0, 3                                      ; pc=0x0040
    sw x6, -12(x17) ; lista[2]                          ; pc=0x0044
    addi x7, x0, 4                                      ; pc=0x0048
    sw x7, -8(x17) ; lista[3]                           ; pc=0x004C
    addi x8, x0, 5                                      ; pc=0x0050
    sw x8, -4(x17) ; lista[4]                           ; pc=0x0054
    addiSigned x9, x17, -20                             ; pc=0x0058
    add x11, x9, x0                                     ; pc=0x005C
    addiHIGH x10, x0, 0                                 ; pc=0x0060
    addi x10, x10, 32776                                ; pc=0x0064
    add x12, x10, x0                                    ; pc=0x0068
    jal x1, 368                                         ; pc=0x006C ; target=sumeMayores ; addr=0x01DC
    add x4, x11, x0                                     ; pc=0x0070
    add x3, x4, x0 ; promote t21                        ; pc=0x0074
    add x11, x3, x0                                     ; pc=0x0078
    jal x0, 4                                           ; pc=0x007C ; target=.L_ir_1_main_end ; addr=0x0080
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0080
    addi x2, x2, 32                                     ; pc=0x0084
    freeze                                              ; pc=0x0088

maximo_lista:
    ; prologue
    addiSigned x2, x2, -64                              ; pc=0x008C
    sw x1, 0(x2)                                        ; pc=0x0090
    sw x17, 4(x2)                                       ; pc=0x0094
    addi x17, x2, 64                                    ; pc=0x0098

    sw x11, -4(x17) ; parametro lista                   ; pc=0x009C
    sw x12, -8(x17) ; parametro largo                   ; pc=0x00A0

    addi x5, x0, 0                                      ; pc=0x00A4
    add x6, x5, x5                                      ; pc=0x00A8
    add x6, x6, x6                                      ; pc=0x00AC
    lw x7, -4(x17) ; base ref lista                     ; pc=0x00B0
    add x7, x7, x6                                      ; pc=0x00B4
    lw x8, 0(x7)                                        ; pc=0x00B8
    sw x8, -32(x17) ; t0                                ; pc=0x00BC
    lw x9, -32(x17) ; t0                                ; pc=0x00C0
    add x4, x9, x0 ; promote maximo                     ; pc=0x00C4
    addi x10, x0, 0                                     ; pc=0x00C8
    sw x10, -16(x17) ; num                              ; pc=0x00CC
    addi x6, x0, 0                                      ; pc=0x00D0
    sw x6, -20(x17) ; esMayor                           ; pc=0x00D4
    lw x5, -8(x17) ; largo                              ; pc=0x00D8
    sw x5, -24(x17) ; limite                            ; pc=0x00DC
    addi x7, x0, 0                                      ; pc=0x00E0
    add x3, x7, x0 ; promote i                          ; pc=0x00E4
L_for_start_0:
    lw x8, -24(x17) ; limite                            ; pc=0x00E8
    addi x9, x0, 0                                      ; pc=0x00EC
    add x10, x8, x9                                     ; pc=0x00F0
    sw x10, -36(x17) ; t1                               ; pc=0x00F4
    lw x6, -36(x17) ; t1                                ; pc=0x00F8
    addi x5, x0, 0                                      ; pc=0x00FC
    blt x3, x6, 8                                       ; pc=0x0100 ; target=.L_ir_3_ir_cmp_true ; addr=0x0108
    jal x0, 8                                           ; pc=0x0104 ; target=.L_ir_4_ir_cmp_end ; addr=0x010C
.L_ir_3_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0108
.L_ir_4_ir_cmp_end:
    sw x5, -40(x17) ; t2                                ; pc=0x010C
    lw x7, -40(x17) ; t2                                ; pc=0x0110
    beq x7, x0, 112                                     ; pc=0x0114 ; target=L_for_end_1 ; addr=0x0184
    add x10, x3, x3                                     ; pc=0x0118
    add x10, x10, x10                                   ; pc=0x011C
    lw x9, -4(x17) ; base ref lista                     ; pc=0x0120
    add x9, x9, x10                                     ; pc=0x0124
    lw x8, 0(x9)                                        ; pc=0x0128
    sw x8, -44(x17) ; t3                                ; pc=0x012C
    lw x5, -44(x17) ; t3                                ; pc=0x0130
    sw x5, -16(x17) ; num                               ; pc=0x0134
    lw x6, -16(x17) ; num                               ; pc=0x0138
    addi x7, x0, 0                                      ; pc=0x013C
    blt x4, x6, 8                                       ; pc=0x0140 ; target=.L_ir_5_ir_cmp_true ; addr=0x0148
    jal x0, 8                                           ; pc=0x0144 ; target=.L_ir_6_ir_cmp_end ; addr=0x014C
.L_ir_5_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0148
.L_ir_6_ir_cmp_end:
    sw x7, -20(x17) ; esMayor                           ; pc=0x014C
    lw x10, -20(x17) ; esMayor                          ; pc=0x0150
    addi x9, x0, 0                                      ; pc=0x0154
    add x8, x10, x9                                     ; pc=0x0158
    sw x8, -52(x17) ; t5                                ; pc=0x015C
    lw x5, -52(x17) ; t5                                ; pc=0x0160
    beq x5, x0, 16                                      ; pc=0x0164 ; target=L_else_2 ; addr=0x0174
    lw x7, -16(x17) ; num                               ; pc=0x0168
    add x4, x7, x0 ; promote maximo                     ; pc=0x016C
    jal x0, 4                                           ; pc=0x0170 ; target=L_end_if_3 ; addr=0x0174
L_else_2:
L_end_if_3:
    addi x6, x0, 1                                      ; pc=0x0174
    add x8, x3, x6                                      ; pc=0x0178
    add x3, x8, x0 ; promote i                          ; pc=0x017C
    jal x0, -152                                        ; pc=0x0180 ; target=L_for_start_0 ; addr=0x00E8
L_for_end_1:
    add x11, x4, x0                                     ; pc=0x0184
    jal x0, 68                                          ; pc=0x0188 ; target=.L_ir_2_maximo_lista_end ; addr=0x01CC
    addi x9, x0, 0                                      ; pc=0x018C
    addiHIGH x10, x0, 0                                 ; pc=0x0190
    addi x10, x10, 32768                                ; pc=0x0194
    sw x9, 0(x10) ; suma                                ; pc=0x0198
    addi x5, x0, 1                                      ; pc=0x019C
    addiHIGH x7, x0, 0                                  ; pc=0x01A0
    addi x7, x7, 32772                                  ; pc=0x01A4
    sw x5, 0(x7) ; multiplicacion                       ; pc=0x01A8
    addi x8, x0, 0                                      ; pc=0x01AC
    addiHIGH x6, x0, 0                                  ; pc=0x01B0
    addi x6, x6, 32776                                  ; pc=0x01B4
    sw x8, 0(x6) ; resultado[0]                         ; pc=0x01B8
    addi x10, x0, 0                                     ; pc=0x01BC
    addiHIGH x9, x0, 0                                  ; pc=0x01C0
    addi x9, x9, 32780                                  ; pc=0x01C4
    sw x10, 0(x9) ; resultado[1]                        ; pc=0x01C8
.L_ir_2_maximo_lista_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x01CC
    lw x17, 4(x2)                                       ; pc=0x01D0
    addi x2, x2, 64                                     ; pc=0x01D4
    jalr x1, 0                                          ; pc=0x01D8

sumeMayores:
    ; prologue
    addiSigned x2, x2, -88                              ; pc=0x01DC
    sw x1, 0(x2)                                        ; pc=0x01E0
    sw x17, 4(x2)                                       ; pc=0x01E4
    addi x17, x2, 88                                    ; pc=0x01E8

    sw x11, -4(x17) ; parametro lista                   ; pc=0x01EC
    sw x12, -8(x17) ; parametro salida                  ; pc=0x01F0

    addi x5, x0, 0                                      ; pc=0x01F4
    add x3, x5, x0 ; promote valorMaximo                ; pc=0x01F8
    addi x6, x0, 0                                      ; pc=0x01FC
    add x4, x6, x0 ; promote seguir                     ; pc=0x0200
    addi x7, x0, 0                                      ; pc=0x0204
    sw x7, -20(x17) ; esDiez                            ; pc=0x0208
    addi x8, x0, 0                                      ; pc=0x020C
    sw x8, -24(x17) ; esGrande                          ; pc=0x0210
    addiHIGH x10, x0, 0                                 ; pc=0x0214
    addi x10, x10, 32768                                ; pc=0x0218
    lw x9, 0(x10) ; suma                                ; pc=0x021C
    addi x5, x0, 100                                    ; pc=0x0220
    addi x6, x0, 0                                      ; pc=0x0224
    blt x9, x5, 8                                       ; pc=0x0228 ; target=.L_ir_8_ir_cmp_true ; addr=0x0230
    jal x0, 8                                           ; pc=0x022C ; target=.L_ir_9_ir_cmp_end ; addr=0x0234
.L_ir_8_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0230
.L_ir_9_ir_cmp_end:
    add x4, x6, x0 ; promote seguir                     ; pc=0x0234
L_while_start_4:
    addi x7, x0, 0                                      ; pc=0x0238
    add x8, x4, x7                                      ; pc=0x023C
    sw x8, -32(x17) ; t8                                ; pc=0x0240
    lw x10, -32(x17) ; t8                               ; pc=0x0244
    beq x10, x0, 336                                    ; pc=0x0248 ; target=L_while_end_5 ; addr=0x0398
    lw x6, -4(x17) ; base ref lista                     ; pc=0x024C
    add x11, x6, x0                                     ; pc=0x0250
    addi x5, x0, 5                                      ; pc=0x0254
    add x12, x5, x0                                     ; pc=0x0258
    sw x4, -16(x17) ; seguir                            ; pc=0x025C
    sw x3, -12(x17) ; valorMaximo                       ; pc=0x0260
    jal x1, -472                                        ; pc=0x0264 ; target=maximo_lista ; addr=0x008C
    add x9, x11, x0                                     ; pc=0x0268
    sw x9, -36(x17) ; t9                                ; pc=0x026C
    lw x8, -36(x17) ; t9                                ; pc=0x0270
    add x3, x8, x0 ; promote valorMaximo                ; pc=0x0274
    addi x7, x0, 2                                      ; pc=0x0278
    div x10, x3, x7                                     ; pc=0x027C
    sw x10, -40(x17) ; t10                              ; pc=0x0280
    lw x6, -40(x17) ; t10                               ; pc=0x0284
    addi x5, x0, 5                                      ; pc=0x0288
    addi x9, x0, 0                                      ; pc=0x028C
    beq x6, x5, 8                                       ; pc=0x0290 ; target=.L_ir_10_ir_cmp_true ; addr=0x0298
    jal x0, 8                                           ; pc=0x0294 ; target=.L_ir_11_ir_cmp_end ; addr=0x029C
.L_ir_10_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0298
.L_ir_11_ir_cmp_end:
    sw x9, -20(x17) ; esDiez                            ; pc=0x029C
    lw x8, -20(x17) ; esDiez                            ; pc=0x02A0
    addi x10, x0, 0                                     ; pc=0x02A4
    add x7, x8, x10                                     ; pc=0x02A8
    sw x7, -48(x17) ; t12                               ; pc=0x02AC
    lw x9, -48(x17) ; t12                               ; pc=0x02B0
    beq x9, x0, 20                                      ; pc=0x02B4 ; target=L_else_6 ; addr=0x02C8
    addi x5, x0, 2                                      ; pc=0x02B8
    mul x6, x3, x5                                      ; pc=0x02BC
    add x3, x6, x0 ; promote valorMaximo                ; pc=0x02C0
    jal x0, 4                                           ; pc=0x02C4 ; target=L_end_if_7 ; addr=0x02C8
L_else_6:
L_end_if_7:
    addiHIGH x10, x0, 0                                 ; pc=0x02C8
    addi x10, x10, 32768                                ; pc=0x02CC
    lw x7, 0(x10) ; suma                                ; pc=0x02D0
    add x8, x7, x3                                      ; pc=0x02D4
    addiHIGH x9, x0, 0                                  ; pc=0x02D8
    addi x9, x9, 32768                                  ; pc=0x02DC
    sw x8, 0(x9) ; suma                                 ; pc=0x02E0
    addiHIGH x5, x0, 0                                  ; pc=0x02E4
    addi x5, x5, 32772                                  ; pc=0x02E8
    lw x6, 0(x5) ; multiplicacion                       ; pc=0x02EC
    mul x10, x6, x3                                     ; pc=0x02F0
    addiHIGH x9, x0, 0                                  ; pc=0x02F4
    addi x9, x9, 32772                                  ; pc=0x02F8
    sw x10, 0(x9) ; multiplicacion                      ; pc=0x02FC
    addiHIGH x7, x0, 0                                  ; pc=0x0300
    addi x7, x7, 32772                                  ; pc=0x0304
    lw x8, 0(x7) ; multiplicacion                       ; pc=0x0308
    addi x5, x0, 500                                    ; pc=0x030C
    addi x9, x0, 0                                      ; pc=0x0310
    blt x5, x8, 8                                       ; pc=0x0314 ; target=.L_ir_12_ir_cmp_true ; addr=0x031C
    jal x0, 8                                           ; pc=0x0318 ; target=.L_ir_13_ir_cmp_end ; addr=0x0320
.L_ir_12_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x031C
.L_ir_13_ir_cmp_end:
    sw x9, -24(x17) ; esGrande                          ; pc=0x0320
    lw x10, -24(x17) ; esGrande                         ; pc=0x0324
    addi x6, x0, 0                                      ; pc=0x0328
    add x7, x10, x6                                     ; pc=0x032C
    sw x7, -68(x17) ; t17                               ; pc=0x0330
    lw x9, -68(x17) ; t17                               ; pc=0x0334
    beq x9, x0, 24                                      ; pc=0x0338 ; target=L_else_8 ; addr=0x0350
    addi x5, x0, 10                                     ; pc=0x033C
    addiHIGH x8, x0, 0                                  ; pc=0x0340
    addi x8, x8, 32772                                  ; pc=0x0344
    sw x5, 0(x8) ; multiplicacion                       ; pc=0x0348
    jal x0, 36                                          ; pc=0x034C ; target=L_end_if_9 ; addr=0x0370
L_else_8:
    addiHIGH x6, x0, 0                                  ; pc=0x0350
    addi x6, x6, 32772                                  ; pc=0x0354
    lw x7, 0(x6) ; multiplicacion                       ; pc=0x0358
    addi x10, x0, 10                                    ; pc=0x035C
    sub x9, x7, x10                                     ; pc=0x0360
    addiHIGH x8, x0, 0                                  ; pc=0x0364
    addi x8, x8, 32772                                  ; pc=0x0368
    sw x9, 0(x8) ; multiplicacion                       ; pc=0x036C
L_end_if_9:
    addiHIGH x6, x0, 0                                  ; pc=0x0370
    addi x6, x6, 32768                                  ; pc=0x0374
    lw x5, 0(x6) ; suma                                 ; pc=0x0378
    addi x8, x0, 100                                    ; pc=0x037C
    addi x9, x0, 0                                      ; pc=0x0380
    blt x5, x8, 8                                       ; pc=0x0384 ; target=.L_ir_14_ir_cmp_true ; addr=0x038C
    jal x0, 8                                           ; pc=0x0388 ; target=.L_ir_15_ir_cmp_end ; addr=0x0390
.L_ir_14_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x038C
.L_ir_15_ir_cmp_end:
    add x4, x9, x0 ; promote seguir                     ; pc=0x0390
    jal x0, -348                                        ; pc=0x0394 ; target=L_while_start_4 ; addr=0x0238
L_while_end_5:
    addiHIGH x7, x0, 0                                  ; pc=0x0398
    addi x7, x7, 32768                                  ; pc=0x039C
    lw x10, 0(x7) ; suma                                ; pc=0x03A0
    addi x6, x0, 0                                      ; pc=0x03A4
    add x9, x6, x6                                      ; pc=0x03A8
    add x9, x9, x9                                      ; pc=0x03AC
    lw x8, -8(x17) ; base ref salida                    ; pc=0x03B0
    add x8, x8, x9                                      ; pc=0x03B4
    sw x10, 0(x8)                                       ; pc=0x03B8
    addiHIGH x7, x0, 0                                  ; pc=0x03BC
    addi x7, x7, 32772                                  ; pc=0x03C0
    lw x5, 0(x7) ; multiplicacion                       ; pc=0x03C4
    addi x9, x0, 1                                      ; pc=0x03C8
    add x6, x9, x9                                      ; pc=0x03CC
    add x6, x6, x6                                      ; pc=0x03D0
    lw x8, -8(x17) ; base ref salida                    ; pc=0x03D4
    add x8, x8, x6                                      ; pc=0x03D8
    sw x5, 0(x8)                                        ; pc=0x03DC
    addi x10, x0, 0                                     ; pc=0x03E0
    add x7, x10, x10                                    ; pc=0x03E4
    add x7, x7, x7                                      ; pc=0x03E8
    lw x6, -8(x17) ; base ref salida                    ; pc=0x03EC
    add x6, x6, x7                                      ; pc=0x03F0
    lw x9, 0(x6)                                        ; pc=0x03F4
    sw x9, -80(x17) ; t20                               ; pc=0x03F8
    lw x8, -80(x17) ; t20                               ; pc=0x03FC
    add x11, x8, x0                                     ; pc=0x0400
    jal x0, 4                                           ; pc=0x0404 ; target=.L_ir_7_sumeMayores_end ; addr=0x0408
.L_ir_7_sumeMayores_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0408
    lw x17, 4(x2)                                       ; pc=0x040C
    addi x2, x2, 88                                     ; pc=0x0410
    jalr x1, 0                                          ; pc=0x0414