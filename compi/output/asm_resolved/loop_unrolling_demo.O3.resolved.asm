; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x0070
;   .L_ir_2_ir_cmp_true = 0x0084
;   .L_ir_3_ir_cmp_end = 0x0088
;   L_while_end_1 = 0x0208
;   .L_ir_1_main_end = 0x0214

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x007C blt -> .L_ir_2_ir_cmp_true (addr=0x0084, offset=8)
;   pc=0x0080 jal -> .L_ir_3_ir_cmp_end (addr=0x0088, offset=8)
;   pc=0x0090 beq -> L_while_end_1 (addr=0x0208, offset=376)
;   pc=0x0204 jal -> L_while_start_0 (addr=0x0070, offset=-404)
;   pc=0x0210 jal -> .L_ir_1_main_end (addr=0x0214, offset=4)

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
    addiSigned x2, x2, -148                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 148                                   ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -20(x17) ; i__v1__x3                         ; pc=0x0034
    addi x4, x0, 0                                      ; pc=0x0038
    sw x4, -24(x17) ; suma__v1__x4                      ; pc=0x003C
    addi x5, x0, 1                                      ; pc=0x0040
    sw x5, -28(x17) ; mezcla__v1__x5                    ; pc=0x0044
    addi x6, x0, 0                                      ; pc=0x0048
    sw x6, -32(x17) ; total__v1__x6                     ; pc=0x004C
    lw x3, -20(x17) ; i__v1__x3                         ; pc=0x0050
    sw x3, -4(x17) ; i                                  ; pc=0x0054
    lw x4, -24(x17) ; suma__v1__x4                      ; pc=0x0058
    sw x4, -8(x17) ; suma                               ; pc=0x005C
    lw x5, -28(x17) ; mezcla__v1__x5                    ; pc=0x0060
    sw x5, -12(x17) ; mezcla                            ; pc=0x0064
    lw x6, -32(x17) ; total__v1__x6                     ; pc=0x0068
    sw x6, -16(x17) ; total                             ; pc=0x006C
L_while_start_0:
    lw x7, -4(x17) ; i                                  ; pc=0x0070
    addi x8, x0, 8                                      ; pc=0x0074
    addi x9, x0, 0                                      ; pc=0x0078
    blt x7, x8, 8                                       ; pc=0x007C ; target=.L_ir_2_ir_cmp_true ; addr=0x0084
    jal x0, 8                                           ; pc=0x0080 ; target=.L_ir_3_ir_cmp_end ; addr=0x0088
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0084
.L_ir_3_ir_cmp_end:
    sw x9, -36(x17) ; t5__x7                            ; pc=0x0088
    lw x7, -36(x17) ; t5__x7                            ; pc=0x008C
    beq x7, x0, 376                                     ; pc=0x0090 ; target=L_while_end_1 ; addr=0x0208
    lw x10, -8(x17) ; suma                              ; pc=0x0094
    lw x3, -4(x17) ; i                                  ; pc=0x0098
    add x8, x10, x3                                     ; pc=0x009C
    sw x8, -40(x17) ; t6__x8                            ; pc=0x00A0
    lw x8, -40(x17) ; t6__x8                            ; pc=0x00A4
    sw x8, -44(x17) ; suma__v2__x9                      ; pc=0x00A8
    lw x4, -12(x17) ; mezcla                            ; pc=0x00AC
    addi x5, x0, 2                                      ; pc=0x00B0
    mul x10, x4, x5                                     ; pc=0x00B4
    sw x10, -48(x17) ; t7__x10                          ; pc=0x00B8
    lw x10, -48(x17) ; t7__x10                          ; pc=0x00BC
    sw x10, -52(x17) ; mezcla__v2__x3                   ; pc=0x00C0
    lw x6, -16(x17) ; total                             ; pc=0x00C4
    lw x9, -44(x17) ; suma__v2__x9                      ; pc=0x00C8
    add x4, x6, x9                                      ; pc=0x00CC
    sw x4, -56(x17) ; t8__x4                            ; pc=0x00D0
    lw x4, -56(x17) ; t8__x4                            ; pc=0x00D4
    sw x4, -60(x17) ; total__v2__x5                     ; pc=0x00D8
    lw x9, -44(x17) ; suma__v2__x9                      ; pc=0x00DC
    lw x7, -4(x17) ; i                                  ; pc=0x00E0
    addi x3, x0, 1                                      ; pc=0x00E4
    add x8, x7, x3                                      ; pc=0x00E8
    add x6, x9, x8                                      ; pc=0x00EC
    sw x6, -64(x17) ; t9__x6                            ; pc=0x00F0
    lw x6, -64(x17) ; t9__x6                            ; pc=0x00F4
    sw x6, -68(x17) ; suma__v3__x7                      ; pc=0x00F8
    lw x3, -52(x17) ; mezcla__v2__x3                    ; pc=0x00FC
    addi x5, x0, 2                                      ; pc=0x0100
    mul x8, x3, x5                                      ; pc=0x0104
    sw x8, -72(x17) ; t10__x8                           ; pc=0x0108
    lw x8, -72(x17) ; t10__x8                           ; pc=0x010C
    sw x8, -76(x17) ; mezcla__v3__x9                    ; pc=0x0110
    lw x5, -60(x17) ; total__v2__x5                     ; pc=0x0114
    lw x7, -68(x17) ; suma__v3__x7                      ; pc=0x0118
    add x10, x5, x7                                     ; pc=0x011C
    sw x10, -80(x17) ; t11__x10                         ; pc=0x0120
    lw x10, -80(x17) ; t11__x10                         ; pc=0x0124
    sw x10, -84(x17) ; total__v3__x3                    ; pc=0x0128
    lw x7, -68(x17) ; suma__v3__x7                      ; pc=0x012C
    lw x4, -4(x17) ; i                                  ; pc=0x0130
    addi x9, x0, 2                                      ; pc=0x0134
    add x6, x4, x9                                      ; pc=0x0138
    add x4, x7, x6                                      ; pc=0x013C
    sw x4, -88(x17) ; t12__x4                           ; pc=0x0140
    lw x4, -88(x17) ; t12__x4                           ; pc=0x0144
    sw x4, -92(x17) ; suma__v4__x5                      ; pc=0x0148
    lw x9, -76(x17) ; mezcla__v3__x9                    ; pc=0x014C
    addi x3, x0, 2                                      ; pc=0x0150
    mul x6, x9, x3                                      ; pc=0x0154
    sw x6, -96(x17) ; t13__x6                           ; pc=0x0158
    lw x6, -96(x17) ; t13__x6                           ; pc=0x015C
    sw x6, -100(x17) ; mezcla__v4__x7                   ; pc=0x0160
    lw x3, -84(x17) ; total__v3__x3                     ; pc=0x0164
    lw x5, -92(x17) ; suma__v4__x5                      ; pc=0x0168
    add x8, x3, x5                                      ; pc=0x016C
    sw x8, -104(x17) ; t14__x8                          ; pc=0x0170
    lw x8, -104(x17) ; t14__x8                          ; pc=0x0174
    sw x8, -108(x17) ; total__v4__x9                    ; pc=0x0178
    lw x5, -92(x17) ; suma__v4__x5                      ; pc=0x017C
    lw x10, -4(x17) ; i                                 ; pc=0x0180
    addi x7, x0, 3                                      ; pc=0x0184
    add x4, x10, x7                                     ; pc=0x0188
    add x10, x5, x4                                     ; pc=0x018C
    sw x10, -112(x17) ; t15__x10                        ; pc=0x0190
    lw x10, -112(x17) ; t15__x10                        ; pc=0x0194
    sw x10, -116(x17) ; suma__v5__x3                    ; pc=0x0198
    lw x7, -100(x17) ; mezcla__v4__x7                   ; pc=0x019C
    addi x9, x0, 2                                      ; pc=0x01A0
    mul x4, x7, x9                                      ; pc=0x01A4
    sw x4, -120(x17) ; t16__x4                          ; pc=0x01A8
    lw x4, -120(x17) ; t16__x4                          ; pc=0x01AC
    sw x4, -124(x17) ; mezcla__v5__x5                   ; pc=0x01B0
    lw x9, -108(x17) ; total__v4__x9                    ; pc=0x01B4
    lw x3, -116(x17) ; suma__v5__x3                     ; pc=0x01B8
    add x6, x9, x3                                      ; pc=0x01BC
    sw x6, -128(x17) ; t17__x6                          ; pc=0x01C0
    lw x6, -128(x17) ; t17__x6                          ; pc=0x01C4
    sw x6, -132(x17) ; total__v5__x7                    ; pc=0x01C8
    lw x8, -4(x17) ; i                                  ; pc=0x01CC
    addi x5, x0, 4                                      ; pc=0x01D0
    add x10, x8, x5                                     ; pc=0x01D4
    sw x10, -136(x17) ; t18__x8                         ; pc=0x01D8
    lw x8, -136(x17) ; t18__x8                          ; pc=0x01DC
    sw x8, -140(x17) ; i__v2__x9                        ; pc=0x01E0
    lw x3, -116(x17) ; suma__v5__x3                     ; pc=0x01E4
    sw x3, -8(x17) ; suma                               ; pc=0x01E8
    lw x5, -124(x17) ; mezcla__v5__x5                   ; pc=0x01EC
    sw x5, -12(x17) ; mezcla                            ; pc=0x01F0
    lw x7, -132(x17) ; total__v5__x7                    ; pc=0x01F4
    sw x7, -16(x17) ; total                             ; pc=0x01F8
    lw x9, -140(x17) ; i__v2__x9                        ; pc=0x01FC
    sw x9, -4(x17) ; i                                  ; pc=0x0200
    jal x0, -404                                        ; pc=0x0204 ; target=L_while_start_0 ; addr=0x0070
L_while_end_1:
    lw x4, -16(x17) ; total                             ; pc=0x0208
    add x11, x4, x0                                     ; pc=0x020C
    jal x0, 4                                           ; pc=0x0210 ; target=.L_ir_1_main_end ; addr=0x0214
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0214
    addi x2, x2, 148                                    ; pc=0x0218
    freeze                                              ; pc=0x021C