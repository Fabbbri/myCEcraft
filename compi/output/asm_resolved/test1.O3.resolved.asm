; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x00A0
;   es_primo = 0x00AC
;   .L_ir_3_ir_cmp_true = 0x00D8
;   .L_ir_4_ir_cmp_end = 0x00DC
;   L_else_0 = 0x00F8
;   L_end_if_1 = 0x00F8
;   .L_ir_5_ir_cmp_true = 0x011C
;   .L_ir_6_ir_cmp_end = 0x0120
;   L_else_2 = 0x013C
;   L_end_if_3 = 0x013C
;   .L_ir_7_ir_cmp_true = 0x0180
;   .L_ir_8_ir_cmp_end = 0x0184
;   L_else_4 = 0x01B0
;   L_end_if_5 = 0x01B0
;   .L_ir_2_es_primo_end = 0x01E8
;   sume = 0x01F8
;   L_for_start_6 = 0x022C
;   .L_ir_10_ir_cmp_true = 0x0240
;   .L_ir_11_ir_cmp_end = 0x0244
;   L_else_8 = 0x02D0
;   L_end_if_9 = 0x02D0
;   L_for_end_7 = 0x02F4
;   .L_ir_9_sume_end = 0x0300

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0088 jal -> sume (addr=0x01F8, offset=368)
;   pc=0x009C jal -> .L_ir_1_main_end (addr=0x00A0, offset=4)
;   pc=0x00D0 bge -> .L_ir_3_ir_cmp_true (addr=0x00D8, offset=8)
;   pc=0x00D4 jal -> .L_ir_4_ir_cmp_end (addr=0x00DC, offset=8)
;   pc=0x00E4 beq -> L_else_0 (addr=0x00F8, offset=20)
;   pc=0x00F0 jal -> .L_ir_2_es_primo_end (addr=0x01E8, offset=248)
;   pc=0x00F4 jal -> L_end_if_1 (addr=0x00F8, offset=4)
;   pc=0x0114 blt -> .L_ir_5_ir_cmp_true (addr=0x011C, offset=8)
;   pc=0x0118 jal -> .L_ir_6_ir_cmp_end (addr=0x0120, offset=8)
;   pc=0x0128 beq -> L_else_2 (addr=0x013C, offset=20)
;   pc=0x0134 jal -> .L_ir_2_es_primo_end (addr=0x01E8, offset=180)
;   pc=0x0138 jal -> L_end_if_3 (addr=0x013C, offset=4)
;   pc=0x0178 beq -> .L_ir_7_ir_cmp_true (addr=0x0180, offset=8)
;   pc=0x017C jal -> .L_ir_8_ir_cmp_end (addr=0x0184, offset=8)
;   pc=0x019C beq -> L_else_4 (addr=0x01B0, offset=20)
;   pc=0x01A8 jal -> .L_ir_2_es_primo_end (addr=0x01E8, offset=64)
;   pc=0x01AC jal -> L_end_if_5 (addr=0x01B0, offset=4)
;   pc=0x01D0 jal -> es_primo (addr=0x00AC, offset=-292)
;   pc=0x01E4 jal -> .L_ir_2_es_primo_end (addr=0x01E8, offset=4)
;   pc=0x0238 blt -> .L_ir_10_ir_cmp_true (addr=0x0240, offset=8)
;   pc=0x023C jal -> .L_ir_11_ir_cmp_end (addr=0x0244, offset=8)
;   pc=0x024C beq -> L_for_end_7 (addr=0x02F4, offset=168)
;   pc=0x027C jal -> es_primo (addr=0x00AC, offset=-464)
;   pc=0x028C beq -> L_else_8 (addr=0x02D0, offset=68)
;   pc=0x02CC jal -> L_end_if_9 (addr=0x02D0, offset=4)
;   pc=0x02F0 jal -> L_for_start_6 (addr=0x022C, offset=-196)
;   pc=0x02FC jal -> .L_ir_9_sume_end (addr=0x0300, offset=4)

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
    addiSigned x2, x2, -52                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 52                                    ; pc=0x002C

    addi x3, x0, 1                                      ; pc=0x0030
    sw x3, -40(x17) ; lista[0]                          ; pc=0x0034
    addi x4, x0, 2                                      ; pc=0x0038
    sw x4, -36(x17) ; lista[1]                          ; pc=0x003C
    addi x5, x0, 3                                      ; pc=0x0040
    sw x5, -32(x17) ; lista[2]                          ; pc=0x0044
    addi x6, x0, 4                                      ; pc=0x0048
    sw x6, -28(x17) ; lista[3]                          ; pc=0x004C
    addi x7, x0, 5                                      ; pc=0x0050
    sw x7, -24(x17) ; lista[4]                          ; pc=0x0054
    addi x8, x0, 6                                      ; pc=0x0058
    sw x8, -20(x17) ; lista[5]                          ; pc=0x005C
    addi x9, x0, 7                                      ; pc=0x0060
    sw x9, -16(x17) ; lista[6]                          ; pc=0x0064
    addi x10, x0, 8                                     ; pc=0x0068
    sw x10, -12(x17) ; lista[7]                         ; pc=0x006C
    addi x3, x0, 9                                      ; pc=0x0070
    sw x3, -8(x17) ; lista[8]                           ; pc=0x0074
    addi x4, x0, 11                                     ; pc=0x0078
    sw x4, -4(x17) ; lista[9]                           ; pc=0x007C
    addiSigned x5, x17, -40                             ; pc=0x0080
    add x11, x5, x0                                     ; pc=0x0084
    jal x1, 368                                         ; pc=0x0088 ; target=sume ; addr=0x01F8
    add x7, x11, x0                                     ; pc=0x008C
    sw x7, -44(x17) ; t14__x7                           ; pc=0x0090
    lw x7, -44(x17) ; t14__x7                           ; pc=0x0094
    add x11, x7, x0                                     ; pc=0x0098
    jal x0, 4                                           ; pc=0x009C ; target=.L_ir_1_main_end ; addr=0x00A0
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00A0
    addi x2, x2, 52                                     ; pc=0x00A4
    freeze                                              ; pc=0x00A8

es_primo:
    ; prologue
    addiSigned x2, x2, -64                              ; pc=0x00AC
    sw x1, 0(x2)                                        ; pc=0x00B0
    sw x17, 4(x2)                                       ; pc=0x00B4
    addi x17, x2, 64                                    ; pc=0x00B8

    sw x11, -4(x17) ; parametro n                       ; pc=0x00BC
    sw x12, -8(x17) ; parametro divisor                 ; pc=0x00C0

    lw x6, -4(x17) ; n                                  ; pc=0x00C4
    addi x8, x0, 1                                      ; pc=0x00C8
    addi x3, x0, 0                                      ; pc=0x00CC
    bge x8, x6, 8                                       ; pc=0x00D0 ; target=.L_ir_3_ir_cmp_true ; addr=0x00D8
    jal x0, 8                                           ; pc=0x00D4 ; target=.L_ir_4_ir_cmp_end ; addr=0x00DC
.L_ir_3_ir_cmp_true:
    addi x3, x0, 1                                      ; pc=0x00D8
.L_ir_4_ir_cmp_end:
    sw x3, -20(x17) ; t0__x3                            ; pc=0x00DC
    lw x3, -20(x17) ; t0__x3                            ; pc=0x00E0
    beq x3, x0, 20                                      ; pc=0x00E4 ; target=L_else_0 ; addr=0x00F8
    addi x9, x0, 0                                      ; pc=0x00E8
    add x11, x9, x0                                     ; pc=0x00EC
    jal x0, 248                                         ; pc=0x00F0 ; target=.L_ir_2_es_primo_end ; addr=0x01E8
    jal x0, 4                                           ; pc=0x00F4 ; target=L_end_if_1 ; addr=0x00F8
L_else_0:
L_end_if_1:
    lw x10, -8(x17) ; divisor                           ; pc=0x00F8
    lw x4, -8(x17) ; divisor                            ; pc=0x00FC
    mul x5, x10, x4                                     ; pc=0x0100
    sw x5, -24(x17) ; t1__x4                            ; pc=0x0104
    lw x4, -24(x17) ; t1__x4                            ; pc=0x0108
    lw x7, -4(x17) ; n                                  ; pc=0x010C
    addi x5, x0, 0                                      ; pc=0x0110
    blt x7, x4, 8                                       ; pc=0x0114 ; target=.L_ir_5_ir_cmp_true ; addr=0x011C
    jal x0, 8                                           ; pc=0x0118 ; target=.L_ir_6_ir_cmp_end ; addr=0x0120
.L_ir_5_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x011C
.L_ir_6_ir_cmp_end:
    sw x5, -28(x17) ; t2__x5                            ; pc=0x0120
    lw x5, -28(x17) ; t2__x5                            ; pc=0x0124
    beq x5, x0, 20                                      ; pc=0x0128 ; target=L_else_2 ; addr=0x013C
    addi x8, x0, 1                                      ; pc=0x012C
    add x11, x8, x0                                     ; pc=0x0130
    jal x0, 180                                         ; pc=0x0134 ; target=.L_ir_2_es_primo_end ; addr=0x01E8
    jal x0, 4                                           ; pc=0x0138 ; target=L_end_if_3 ; addr=0x013C
L_else_2:
L_end_if_3:
    lw x6, -4(x17) ; n                                  ; pc=0x013C
    lw x3, -8(x17) ; divisor                            ; pc=0x0140
    div x9, x6, x3                                      ; pc=0x0144
    sw x9, -32(x17) ; t3__x6                            ; pc=0x0148
    lw x6, -32(x17) ; t3__x6                            ; pc=0x014C
    sw x6, -36(x17) ; cociente__v1__x7                  ; pc=0x0150
    lw x7, -36(x17) ; cociente__v1__x7                  ; pc=0x0154
    lw x10, -8(x17) ; divisor                           ; pc=0x0158
    mul x8, x7, x10                                     ; pc=0x015C
    sw x8, -40(x17) ; t4__x8                            ; pc=0x0160
    lw x8, -40(x17) ; t4__x8                            ; pc=0x0164
    sw x8, -44(x17) ; producto__v1__x9                  ; pc=0x0168
    lw x9, -44(x17) ; producto__v1__x9                  ; pc=0x016C
    lw x4, -4(x17) ; n                                  ; pc=0x0170
    addi x10, x0, 0                                     ; pc=0x0174
    beq x9, x4, 8                                       ; pc=0x0178 ; target=.L_ir_7_ir_cmp_true ; addr=0x0180
    jal x0, 8                                           ; pc=0x017C ; target=.L_ir_8_ir_cmp_end ; addr=0x0184
.L_ir_7_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x0180
.L_ir_8_ir_cmp_end:
    sw x10, -48(x17) ; t5__x10                          ; pc=0x0184
    lw x7, -36(x17) ; cociente__v1__x7                  ; pc=0x0188
    sw x7, -12(x17) ; cociente                          ; pc=0x018C
    lw x9, -44(x17) ; producto__v1__x9                  ; pc=0x0190
    sw x9, -16(x17) ; producto                          ; pc=0x0194
    lw x10, -48(x17) ; t5__x10                          ; pc=0x0198
    beq x10, x0, 20                                     ; pc=0x019C ; target=L_else_4 ; addr=0x01B0
    addi x5, x0, 0                                      ; pc=0x01A0
    add x11, x5, x0                                     ; pc=0x01A4
    jal x0, 64                                          ; pc=0x01A8 ; target=.L_ir_2_es_primo_end ; addr=0x01E8
    jal x0, 4                                           ; pc=0x01AC ; target=L_end_if_5 ; addr=0x01B0
L_else_4:
L_end_if_5:
    lw x3, -8(x17) ; divisor                            ; pc=0x01B0
    addi x6, x0, 1                                      ; pc=0x01B4
    add x8, x3, x6                                      ; pc=0x01B8
    sw x8, -52(x17) ; t6__x3                            ; pc=0x01BC
    lw x4, -4(x17) ; n                                  ; pc=0x01C0
    add x11, x4, x0                                     ; pc=0x01C4
    lw x3, -52(x17) ; t6__x3                            ; pc=0x01C8
    add x12, x3, x0                                     ; pc=0x01CC
    jal x1, -292                                        ; pc=0x01D0 ; target=es_primo ; addr=0x00AC
    add x4, x11, x0                                     ; pc=0x01D4
    sw x4, -56(x17) ; t7__x4                            ; pc=0x01D8
    lw x4, -56(x17) ; t7__x4                            ; pc=0x01DC
    add x11, x4, x0                                     ; pc=0x01E0
    jal x0, 4                                           ; pc=0x01E4 ; target=.L_ir_2_es_primo_end ; addr=0x01E8
.L_ir_2_es_primo_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x01E8
    lw x17, 4(x2)                                       ; pc=0x01EC
    addi x2, x2, 64                                     ; pc=0x01F0
    jalr x1, 0                                          ; pc=0x01F4

sume:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x01F8
    sw x1, 0(x2)                                        ; pc=0x01FC
    sw x17, 4(x2)                                       ; pc=0x0200
    addi x17, x2, 60                                    ; pc=0x0204

    sw x11, -4(x17) ; parametro lista                   ; pc=0x0208

    addi x7, x0, 0                                      ; pc=0x020C
    sw x7, -16(x17) ; suma__v1__x5                      ; pc=0x0210
    addi x9, x0, 0                                      ; pc=0x0214
    sw x9, -20(x17) ; i__v1__x6                         ; pc=0x0218
    lw x5, -16(x17) ; suma__v1__x5                      ; pc=0x021C
    sw x5, -8(x17) ; suma                               ; pc=0x0220
    lw x6, -20(x17) ; i__v1__x6                         ; pc=0x0224
    sw x6, -12(x17) ; i                                 ; pc=0x0228
L_for_start_6:
    lw x10, -12(x17) ; i                                ; pc=0x022C
    addi x8, x0, 10                                     ; pc=0x0230
    addi x7, x0, 0                                      ; pc=0x0234
    blt x10, x8, 8                                      ; pc=0x0238 ; target=.L_ir_10_ir_cmp_true ; addr=0x0240
    jal x0, 8                                           ; pc=0x023C ; target=.L_ir_11_ir_cmp_end ; addr=0x0244
.L_ir_10_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0240
.L_ir_11_ir_cmp_end:
    sw x7, -24(x17) ; t8__x7                            ; pc=0x0244
    lw x7, -24(x17) ; t8__x7                            ; pc=0x0248
    beq x7, x0, 168                                     ; pc=0x024C ; target=L_for_end_7 ; addr=0x02F4
    lw x3, -12(x17) ; i                                 ; pc=0x0250
    add x4, x3, x3                                      ; pc=0x0254
    add x4, x4, x4                                      ; pc=0x0258
    lw x9, -4(x17) ; base ref lista                     ; pc=0x025C
    add x9, x9, x4                                      ; pc=0x0260
    lw x5, 0(x9)                                        ; pc=0x0264
    sw x5, -28(x17) ; t9__x8                            ; pc=0x0268
    lw x8, -28(x17) ; t9__x8                            ; pc=0x026C
    add x11, x8, x0                                     ; pc=0x0270
    addi x6, x0, 2                                      ; pc=0x0274
    add x12, x6, x0                                     ; pc=0x0278
    jal x1, -464                                        ; pc=0x027C ; target=es_primo ; addr=0x00AC
    add x9, x11, x0                                     ; pc=0x0280
    sw x9, -32(x17) ; t10__x9                           ; pc=0x0284
    lw x9, -32(x17) ; t10__x9                           ; pc=0x0288
    beq x9, x0, 68                                      ; pc=0x028C ; target=L_else_8 ; addr=0x02D0
    lw x10, -12(x17) ; i                                ; pc=0x0290
    add x7, x10, x10                                    ; pc=0x0294
    add x7, x7, x7                                      ; pc=0x0298
    lw x4, -4(x17) ; base ref lista                     ; pc=0x029C
    add x4, x4, x7                                      ; pc=0x02A0
    lw x3, 0(x4)                                        ; pc=0x02A4
    sw x3, -36(x17) ; t11__x10                          ; pc=0x02A8
    lw x5, -8(x17) ; suma                               ; pc=0x02AC
    lw x10, -36(x17) ; t11__x10                         ; pc=0x02B0
    add x3, x5, x10                                     ; pc=0x02B4
    sw x3, -40(x17) ; t12__x3                           ; pc=0x02B8
    lw x3, -40(x17) ; t12__x3                           ; pc=0x02BC
    sw x3, -44(x17) ; suma__v2__x4                      ; pc=0x02C0
    lw x4, -44(x17) ; suma__v2__x4                      ; pc=0x02C4
    sw x4, -8(x17) ; suma                               ; pc=0x02C8
    jal x0, 4                                           ; pc=0x02CC ; target=L_end_if_9 ; addr=0x02D0
L_else_8:
L_end_if_9:
    lw x8, -12(x17) ; i                                 ; pc=0x02D0
    addi x6, x0, 1                                      ; pc=0x02D4
    add x5, x8, x6                                      ; pc=0x02D8
    sw x5, -48(x17) ; t13__x5                           ; pc=0x02DC
    lw x5, -48(x17) ; t13__x5                           ; pc=0x02E0
    sw x5, -52(x17) ; i__v2__x6                         ; pc=0x02E4
    lw x6, -52(x17) ; i__v2__x6                         ; pc=0x02E8
    sw x6, -12(x17) ; i                                 ; pc=0x02EC
    jal x0, -196                                        ; pc=0x02F0 ; target=L_for_start_6 ; addr=0x022C
L_for_end_7:
    lw x9, -8(x17) ; suma                               ; pc=0x02F4
    add x11, x9, x0                                     ; pc=0x02F8
    jal x0, 4                                           ; pc=0x02FC ; target=.L_ir_9_sume_end ; addr=0x0300
.L_ir_9_sume_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0300
    lw x17, 4(x2)                                       ; pc=0x0304
    addi x2, x2, 60                                     ; pc=0x0308
    jalr x1, 0                                          ; pc=0x030C