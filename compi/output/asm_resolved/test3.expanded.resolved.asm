; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L_codegen_1_main_end = 0x007C
;   maximo_lista = 0x0088
;   .L0_for_start = 0x00DC
;   .L_codegen_3_cmp_true = 0x0120
;   .L_codegen_4_cmp_end = 0x0124
;   .L2_if_else = 0x0144
;   .L3_if_end = 0x0144
;   .L1_for_end = 0x0158
;   .L_codegen_2_maximo_lista_end = 0x0164
;   sumeMayores = 0x0174
;   .L_codegen_6_cmp_true = 0x01C8
;   .L_codegen_7_cmp_end = 0x01CC
;   .L4_while_start = 0x01D0
;   .L_codegen_8_cmp_true = 0x0218
;   .L_codegen_9_cmp_end = 0x021C
;   .L6_if_else = 0x0244
;   .L7_if_end = 0x0244
;   .L_codegen_10_cmp_true = 0x02A0
;   .L_codegen_11_cmp_end = 0x02A4
;   .L8_if_else = 0x02CC
;   .L9_if_end = 0x02EC
;   .L_codegen_12_cmp_true = 0x0308
;   .L_codegen_13_cmp_end = 0x030C
;   .L5_while_end = 0x0314
;   .L_codegen_5_sumeMayores_end = 0x037C

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x006C jal -> sumeMayores (addr=0x0174, offset=264)
;   pc=0x0078 jal -> .L_codegen_1_main_end (addr=0x007C, offset=4)
;   pc=0x00EC bge -> .L1_for_end (addr=0x0158, offset=108)
;   pc=0x0118 blt -> .L_codegen_3_cmp_true (addr=0x0120, offset=8)
;   pc=0x011C jal -> .L_codegen_4_cmp_end (addr=0x0124, offset=8)
;   pc=0x0134 beq -> .L2_if_else (addr=0x0144, offset=16)
;   pc=0x0140 jal -> .L3_if_end (addr=0x0144, offset=4)
;   pc=0x0154 jal -> .L0_for_start (addr=0x00DC, offset=-120)
;   pc=0x0160 jal -> .L_codegen_2_maximo_lista_end (addr=0x0164, offset=4)
;   pc=0x01C0 blt -> .L_codegen_6_cmp_true (addr=0x01C8, offset=8)
;   pc=0x01C4 jal -> .L_codegen_7_cmp_end (addr=0x01CC, offset=8)
;   pc=0x01DC beq -> .L5_while_end (addr=0x0314, offset=312)
;   pc=0x01F0 jal -> maximo_lista (addr=0x0088, offset=-360)
;   pc=0x0210 beq -> .L_codegen_8_cmp_true (addr=0x0218, offset=8)
;   pc=0x0214 jal -> .L_codegen_9_cmp_end (addr=0x021C, offset=8)
;   pc=0x022C beq -> .L6_if_else (addr=0x0244, offset=24)
;   pc=0x0240 jal -> .L7_if_end (addr=0x0244, offset=4)
;   pc=0x0298 blt -> .L_codegen_10_cmp_true (addr=0x02A0, offset=8)
;   pc=0x029C jal -> .L_codegen_11_cmp_end (addr=0x02A4, offset=8)
;   pc=0x02B4 beq -> .L8_if_else (addr=0x02CC, offset=24)
;   pc=0x02C8 jal -> .L9_if_end (addr=0x02EC, offset=36)
;   pc=0x0300 blt -> .L_codegen_12_cmp_true (addr=0x0308, offset=8)
;   pc=0x0304 jal -> .L_codegen_13_cmp_end (addr=0x030C, offset=8)
;   pc=0x0310 jal -> .L4_while_start (addr=0x01D0, offset=-320)
;   pc=0x0378 jal -> .L_codegen_5_sumeMayores_end (addr=0x037C, offset=4)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.data
suma: ; addr=0x8000
    .word 0
multiplicacion: ; addr=0x8004
    .word 1
resultado: ; addr=0x8008
    .word 0
    .word 0

.text

    ; @EnterCraftWorld
    portalv x0, x0, 24                                  ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x0018
    lwv v0, 0(v0)                                       ; pc=0x0004
    sleep ; stall RAW                                   ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0014
.L_codegen_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0018
    addi x2, x2, 0x7FF0                                 ; pc=0x001C

    ; prologue
    addiSigned x2, x2, -48                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 48                                    ; pc=0x002C

    addi x3, x0, 10                                     ; pc=0x0030
    sw x3, -20(x17) ; lista[0]                          ; pc=0x0034
    addi x3, x0, 2                                      ; pc=0x0038
    sw x3, -16(x17) ; lista[1]                          ; pc=0x003C
    addi x3, x0, 3                                      ; pc=0x0040
    sw x3, -12(x17) ; lista[2]                          ; pc=0x0044
    addi x3, x0, 4                                      ; pc=0x0048
    sw x3, -8(x17) ; lista[3]                           ; pc=0x004C
    addi x3, x0, 5                                      ; pc=0x0050
    sw x3, -4(x17) ; lista[4]                           ; pc=0x0054
    addiSigned x3, x17, -20                             ; pc=0x0058
    ; base lista
    add x11, x3, x0                                     ; pc=0x005C
    addiHIGH x3, x0, 0                                  ; pc=0x0060
    addi x3, x3, 32776                                  ; pc=0x0064
    ; base resultado
    add x12, x3, x0                                     ; pc=0x0068
    jal x1, 264                                         ; pc=0x006C ; target=sumeMayores ; addr=0x0174
    add x3, x11, x0                                     ; pc=0x0070
    add x11, x3, x0                                     ; pc=0x0074
    jal x0, 4                                           ; pc=0x0078 ; target=.L_codegen_1_main_end ; addr=0x007C
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x007C
    addi x2, x2, 48                                     ; pc=0x0080
    freeze                                              ; pc=0x0084

maximo_lista:
    ; prologue
    addiSigned x2, x2, -40                              ; pc=0x0088
    sw x1, 0(x2)                                        ; pc=0x008C
    sw x17, 4(x2)                                       ; pc=0x0090
    addi x17, x2, 40                                    ; pc=0x0094

    sw x11, -4(x17) ; parámetro lista                   ; pc=0x0098
    sw x12, -8(x17) ; parámetro largo                   ; pc=0x009C

    addi x3, x0, 0                                      ; pc=0x00A0
    add x4, x3, x3                                      ; pc=0x00A4
    add x4, x4, x4                                      ; pc=0x00A8
    lw x5, -4(x17) ; base ref lista                     ; pc=0x00AC
    add x5, x5, x4                                      ; pc=0x00B0
    lw x4, 0(x5)                                        ; pc=0x00B4
    sw x4, -12(x17) ; maximo                            ; pc=0x00B8
    addi x4, x0, 0                                      ; pc=0x00BC
    sw x4, -16(x17) ; num                               ; pc=0x00C0
    addi x4, x0, 0                                      ; pc=0x00C4
    sw x4, -20(x17) ; esMayor                           ; pc=0x00C8
    lw x4, -8(x17) ; largo                              ; pc=0x00CC
    sw x4, -24(x17) ; limite                            ; pc=0x00D0

    ; for
    addi x4, x0, 0                                      ; pc=0x00D4
    sw x4, -28(x17) ; i                                 ; pc=0x00D8
.L0_for_start:
    lw x4, -28(x17) ; i                                 ; pc=0x00DC
    lw x5, -24(x17) ; limite                            ; pc=0x00E0
    addi x3, x0, 0                                      ; pc=0x00E4
    add x6, x5, x3                                      ; pc=0x00E8
    bge x4, x6, 108                                     ; pc=0x00EC ; target=.L1_for_end ; addr=0x0158
    lw x6, -28(x17) ; i                                 ; pc=0x00F0
    add x4, x6, x6                                      ; pc=0x00F4
    add x4, x4, x4                                      ; pc=0x00F8
    lw x3, -4(x17) ; base ref lista                     ; pc=0x00FC
    add x3, x3, x4                                      ; pc=0x0100
    lw x4, 0(x3)                                        ; pc=0x0104
    sw x4, -16(x17) ; num                               ; pc=0x0108
    lw x4, -16(x17) ; num                               ; pc=0x010C
    lw x3, -12(x17) ; maximo                            ; pc=0x0110
    addi x6, x0, 0                                      ; pc=0x0114
    blt x3, x4, 8                                       ; pc=0x0118 ; target=.L_codegen_3_cmp_true ; addr=0x0120
    jal x0, 8                                           ; pc=0x011C ; target=.L_codegen_4_cmp_end ; addr=0x0124
.L_codegen_3_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0120
.L_codegen_4_cmp_end:
    sw x6, -20(x17) ; esMayor                           ; pc=0x0124

    ; if
    lw x6, -20(x17) ; esMayor                           ; pc=0x0128
    addi x3, x0, 0                                      ; pc=0x012C
    add x4, x6, x3                                      ; pc=0x0130
    beq x4, x0, 16                                      ; pc=0x0134 ; target=.L2_if_else ; addr=0x0144
    lw x4, -16(x17) ; num                               ; pc=0x0138
    sw x4, -12(x17) ; maximo                            ; pc=0x013C
    jal x0, 4                                           ; pc=0x0140 ; target=.L3_if_end ; addr=0x0144
.L2_if_else:
.L3_if_end:

    lw x4, -28(x17) ; i                                 ; pc=0x0144
    addi x3, x0, 1                                      ; pc=0x0148
    add x6, x4, x3                                      ; pc=0x014C
    sw x6, -28(x17) ; i                                 ; pc=0x0150
    jal x0, -120                                        ; pc=0x0154 ; target=.L0_for_start ; addr=0x00DC
.L1_for_end:

    lw x6, -12(x17) ; maximo                            ; pc=0x0158
    add x11, x6, x0                                     ; pc=0x015C
    jal x0, 4                                           ; pc=0x0160 ; target=.L_codegen_2_maximo_lista_end ; addr=0x0164
.L_codegen_2_maximo_lista_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0164
    lw x17, 4(x2)                                       ; pc=0x0168
    addi x2, x2, 40                                     ; pc=0x016C
    jalr x1, 0                                          ; pc=0x0170

sumeMayores:
    ; prologue
    addiSigned x2, x2, -36                              ; pc=0x0174
    sw x1, 0(x2)                                        ; pc=0x0178
    sw x17, 4(x2)                                       ; pc=0x017C
    addi x17, x2, 36                                    ; pc=0x0180

    sw x11, -4(x17) ; parámetro lista                   ; pc=0x0184
    sw x12, -8(x17) ; parámetro salida                  ; pc=0x0188

    addi x6, x0, 0                                      ; pc=0x018C
    sw x6, -12(x17) ; valorMaximo                       ; pc=0x0190
    addi x6, x0, 0                                      ; pc=0x0194
    sw x6, -16(x17) ; seguir                            ; pc=0x0198
    addi x6, x0, 0                                      ; pc=0x019C
    sw x6, -20(x17) ; esDiez                            ; pc=0x01A0
    addi x6, x0, 0                                      ; pc=0x01A4
    sw x6, -24(x17) ; esGrande                          ; pc=0x01A8
    addiHIGH x3, x0, 0                                  ; pc=0x01AC
    addi x3, x3, 32768                                  ; pc=0x01B0
    lw x6, 0(x3) ; suma                                 ; pc=0x01B4
    addi x3, x0, 100                                    ; pc=0x01B8
    addi x4, x0, 0                                      ; pc=0x01BC
    blt x6, x3, 8                                       ; pc=0x01C0 ; target=.L_codegen_6_cmp_true ; addr=0x01C8
    jal x0, 8                                           ; pc=0x01C4 ; target=.L_codegen_7_cmp_end ; addr=0x01CC
.L_codegen_6_cmp_true:
    addi x4, x0, 1                                      ; pc=0x01C8
.L_codegen_7_cmp_end:
    sw x4, -16(x17) ; seguir                            ; pc=0x01CC

.L4_while_start:
    lw x4, -16(x17) ; seguir                            ; pc=0x01D0
    addi x3, x0, 0                                      ; pc=0x01D4
    add x6, x4, x3                                      ; pc=0x01D8
    beq x6, x0, 312                                     ; pc=0x01DC ; target=.L5_while_end ; addr=0x0314
    lw x6, -4(x17) ; base ref lista                     ; pc=0x01E0
    add x11, x6, x0                                     ; pc=0x01E4
    addi x6, x0, 5                                      ; pc=0x01E8
    add x12, x6, x0                                     ; pc=0x01EC
    jal x1, -360                                        ; pc=0x01F0 ; target=maximo_lista ; addr=0x0088
    add x6, x11, x0                                     ; pc=0x01F4
    sw x6, -12(x17) ; valorMaximo                       ; pc=0x01F8
    lw x6, -12(x17) ; valorMaximo                       ; pc=0x01FC
    addi x3, x0, 2                                      ; pc=0x0200
    div x4, x6, x3                                      ; pc=0x0204
    addi x3, x0, 5                                      ; pc=0x0208
    addi x6, x0, 0                                      ; pc=0x020C
    beq x4, x3, 8                                       ; pc=0x0210 ; target=.L_codegen_8_cmp_true ; addr=0x0218
    jal x0, 8                                           ; pc=0x0214 ; target=.L_codegen_9_cmp_end ; addr=0x021C
.L_codegen_8_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0218
.L_codegen_9_cmp_end:
    sw x6, -20(x17) ; esDiez                            ; pc=0x021C

    ; if
    lw x6, -20(x17) ; esDiez                            ; pc=0x0220
    addi x3, x0, 0                                      ; pc=0x0224
    add x4, x6, x3                                      ; pc=0x0228
    beq x4, x0, 24                                      ; pc=0x022C ; target=.L6_if_else ; addr=0x0244
    lw x4, -12(x17) ; valorMaximo                       ; pc=0x0230
    addi x3, x0, 2                                      ; pc=0x0234
    mul x6, x4, x3                                      ; pc=0x0238
    sw x6, -12(x17) ; valorMaximo                       ; pc=0x023C
    jal x0, 4                                           ; pc=0x0240 ; target=.L7_if_end ; addr=0x0244
.L6_if_else:
.L7_if_end:

    addiHIGH x3, x0, 0                                  ; pc=0x0244
    addi x3, x3, 32768                                  ; pc=0x0248
    lw x6, 0(x3) ; suma                                 ; pc=0x024C
    lw x3, -12(x17) ; valorMaximo                       ; pc=0x0250
    add x4, x6, x3                                      ; pc=0x0254
    addiHIGH x3, x0, 0                                  ; pc=0x0258
    addi x3, x3, 32768                                  ; pc=0x025C
    sw x4, 0(x3) ; suma                                 ; pc=0x0260
    addiHIGH x3, x0, 0                                  ; pc=0x0264
    addi x3, x3, 32772                                  ; pc=0x0268
    lw x4, 0(x3) ; multiplicacion                       ; pc=0x026C
    lw x3, -12(x17) ; valorMaximo                       ; pc=0x0270
    mul x6, x4, x3                                      ; pc=0x0274
    addiHIGH x3, x0, 0                                  ; pc=0x0278
    addi x3, x3, 32772                                  ; pc=0x027C
    sw x6, 0(x3) ; multiplicacion                       ; pc=0x0280
    addiHIGH x3, x0, 0                                  ; pc=0x0284
    addi x3, x3, 32772                                  ; pc=0x0288
    lw x6, 0(x3) ; multiplicacion                       ; pc=0x028C
    addi x3, x0, 500                                    ; pc=0x0290
    addi x4, x0, 0                                      ; pc=0x0294
    blt x3, x6, 8                                       ; pc=0x0298 ; target=.L_codegen_10_cmp_true ; addr=0x02A0
    jal x0, 8                                           ; pc=0x029C ; target=.L_codegen_11_cmp_end ; addr=0x02A4
.L_codegen_10_cmp_true:
    addi x4, x0, 1                                      ; pc=0x02A0
.L_codegen_11_cmp_end:
    sw x4, -24(x17) ; esGrande                          ; pc=0x02A4

    ; if
    lw x4, -24(x17) ; esGrande                          ; pc=0x02A8
    addi x3, x0, 0                                      ; pc=0x02AC
    add x6, x4, x3                                      ; pc=0x02B0
    beq x6, x0, 24                                      ; pc=0x02B4 ; target=.L8_if_else ; addr=0x02CC
    addi x6, x0, 10                                     ; pc=0x02B8
    addiHIGH x3, x0, 0                                  ; pc=0x02BC
    addi x3, x3, 32772                                  ; pc=0x02C0
    sw x6, 0(x3) ; multiplicacion                       ; pc=0x02C4
    jal x0, 36                                          ; pc=0x02C8 ; target=.L9_if_end ; addr=0x02EC
.L8_if_else:
    addiHIGH x3, x0, 0                                  ; pc=0x02CC
    addi x3, x3, 32772                                  ; pc=0x02D0
    lw x6, 0(x3) ; multiplicacion                       ; pc=0x02D4
    addi x3, x0, 10                                     ; pc=0x02D8
    sub x4, x6, x3                                      ; pc=0x02DC
    addiHIGH x3, x0, 0                                  ; pc=0x02E0
    addi x3, x3, 32772                                  ; pc=0x02E4
    sw x4, 0(x3) ; multiplicacion                       ; pc=0x02E8
.L9_if_end:

    addiHIGH x3, x0, 0                                  ; pc=0x02EC
    addi x3, x3, 32768                                  ; pc=0x02F0
    lw x4, 0(x3) ; suma                                 ; pc=0x02F4
    addi x3, x0, 100                                    ; pc=0x02F8
    addi x6, x0, 0                                      ; pc=0x02FC
    blt x4, x3, 8                                       ; pc=0x0300 ; target=.L_codegen_12_cmp_true ; addr=0x0308
    jal x0, 8                                           ; pc=0x0304 ; target=.L_codegen_13_cmp_end ; addr=0x030C
.L_codegen_12_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0308
.L_codegen_13_cmp_end:
    sw x6, -16(x17) ; seguir                            ; pc=0x030C
    jal x0, -320                                        ; pc=0x0310 ; target=.L4_while_start ; addr=0x01D0
.L5_while_end:

    addiHIGH x3, x0, 0                                  ; pc=0x0314
    addi x3, x3, 32768                                  ; pc=0x0318
    lw x6, 0(x3) ; suma                                 ; pc=0x031C
    addi x3, x0, 0                                      ; pc=0x0320
    add x4, x3, x3                                      ; pc=0x0324
    add x4, x4, x4                                      ; pc=0x0328
    lw x5, -8(x17) ; base ref salida                    ; pc=0x032C
    add x5, x5, x4                                      ; pc=0x0330
    sw x6, 0(x5)                                        ; pc=0x0334
    addiHIGH x5, x0, 0                                  ; pc=0x0338
    addi x5, x5, 32772                                  ; pc=0x033C
    lw x6, 0(x5) ; multiplicacion                       ; pc=0x0340
    addi x5, x0, 1                                      ; pc=0x0344
    add x4, x5, x5                                      ; pc=0x0348
    add x4, x4, x4                                      ; pc=0x034C
    lw x3, -8(x17) ; base ref salida                    ; pc=0x0350
    add x3, x3, x4                                      ; pc=0x0354
    sw x6, 0(x3)                                        ; pc=0x0358
    addi x6, x0, 0                                      ; pc=0x035C
    add x3, x6, x6                                      ; pc=0x0360
    add x3, x3, x3                                      ; pc=0x0364
    lw x4, -8(x17) ; base ref salida                    ; pc=0x0368
    add x4, x4, x3                                      ; pc=0x036C
    lw x3, 0(x4)                                        ; pc=0x0370
    add x11, x3, x0                                     ; pc=0x0374
    jal x0, 4                                           ; pc=0x0378 ; target=.L_codegen_5_sumeMayores_end ; addr=0x037C
.L_codegen_5_sumeMayores_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x037C
    lw x17, 4(x2)                                       ; pc=0x0380
    addi x2, x2, 36                                     ; pc=0x0384
    jalr x1, 0                                          ; pc=0x0388