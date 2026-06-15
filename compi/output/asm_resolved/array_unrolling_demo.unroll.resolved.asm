; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_for_start_0 = 0x0088
;   .L_ir_2_ir_cmp_true = 0x0098
;   .L_ir_3_ir_cmp_end = 0x009C
;   L_for_end_1 = 0x01E4
;   .L_ir_1_main_end = 0x02B4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0090 blt -> .L_ir_2_ir_cmp_true (addr=0x0098, offset=8)
;   pc=0x0094 jal -> .L_ir_3_ir_cmp_end (addr=0x009C, offset=8)
;   pc=0x00A0 beq -> L_for_end_1 (addr=0x01E4, offset=324)
;   pc=0x01E0 jal -> L_for_start_0 (addr=0x0088, offset=-344)
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
    addiSigned x2, x2, -120                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 120                                   ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    sw x5, -40(x17) ; datos[0]                          ; pc=0x0034
    addi x6, x0, 1                                      ; pc=0x0038
    sw x6, -36(x17) ; datos[1]                          ; pc=0x003C
    addi x7, x0, 2                                      ; pc=0x0040
    sw x7, -32(x17) ; datos[2]                          ; pc=0x0044
    addi x8, x0, 3                                      ; pc=0x0048
    sw x8, -28(x17) ; datos[3]                          ; pc=0x004C
    addi x9, x0, 4                                      ; pc=0x0050
    sw x9, -24(x17) ; datos[4]                          ; pc=0x0054
    addi x10, x0, 5                                     ; pc=0x0058
    sw x10, -20(x17) ; datos[5]                         ; pc=0x005C
    addi x5, x0, 6                                      ; pc=0x0060
    sw x5, -16(x17) ; datos[6]                          ; pc=0x0064
    addi x6, x0, 7                                      ; pc=0x0068
    sw x6, -12(x17) ; datos[7]                          ; pc=0x006C
    addi x7, x0, 8                                      ; pc=0x0070
    sw x7, -8(x17) ; datos[8]                           ; pc=0x0074
    addi x8, x0, 9                                      ; pc=0x0078
    sw x8, -4(x17) ; datos[9]                           ; pc=0x007C
    addi x9, x0, 0                                      ; pc=0x0080
    add x3, x9, x0 ; promote i                          ; pc=0x0084
L_for_start_0:
    addi x10, x0, 8                                     ; pc=0x0088
    addi x5, x0, 0                                      ; pc=0x008C
    blt x3, x10, 8                                      ; pc=0x0090 ; target=.L_ir_2_ir_cmp_true ; addr=0x0098
    jal x0, 8                                           ; pc=0x0094 ; target=.L_ir_3_ir_cmp_end ; addr=0x009C
.L_ir_2_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0098
.L_ir_3_ir_cmp_end:
    add x4, x5, x0 ; promote t5                         ; pc=0x009C
    beq x4, x0, 324                                     ; pc=0x00A0 ; target=L_for_end_1 ; addr=0x01E4
    add x6, x3, x3                                      ; pc=0x00A4
    add x6, x6, x6                                      ; pc=0x00A8
    addiSigned x7, x17, -40                             ; pc=0x00AC
    add x7, x7, x6                                      ; pc=0x00B0
    lw x8, 0(x7)                                        ; pc=0x00B4
    sw x8, -52(x17) ; t6                                ; pc=0x00B8
    lw x9, -52(x17) ; t6                                ; pc=0x00BC
    addi x5, x0, 1                                      ; pc=0x00C0
    add x10, x9, x5                                     ; pc=0x00C4
    sw x10, -56(x17) ; t7                               ; pc=0x00C8
    lw x6, -56(x17) ; t7                                ; pc=0x00CC
    add x7, x3, x3                                      ; pc=0x00D0
    add x7, x7, x7                                      ; pc=0x00D4
    addiSigned x8, x17, -40                             ; pc=0x00D8
    add x8, x8, x7                                      ; pc=0x00DC
    sw x6, 0(x8)                                        ; pc=0x00E0
    addi x10, x0, 1                                     ; pc=0x00E4
    add x5, x3, x10                                     ; pc=0x00E8
    add x9, x5, x5                                      ; pc=0x00EC
    add x9, x9, x9                                      ; pc=0x00F0
    addiSigned x7, x17, -40                             ; pc=0x00F4
    add x7, x7, x9                                      ; pc=0x00F8
    lw x8, 0(x7)                                        ; pc=0x00FC
    sw x8, -60(x17) ; t8                                ; pc=0x0100
    lw x6, -60(x17) ; t8                                ; pc=0x0104
    addi x10, x0, 1                                     ; pc=0x0108
    add x9, x6, x10                                     ; pc=0x010C
    sw x9, -64(x17) ; t9                                ; pc=0x0110
    lw x5, -64(x17) ; t9                                ; pc=0x0114
    addi x7, x0, 1                                      ; pc=0x0118
    add x8, x3, x7                                      ; pc=0x011C
    add x9, x8, x8                                      ; pc=0x0120
    add x9, x9, x9                                      ; pc=0x0124
    addiSigned x10, x17, -40                            ; pc=0x0128
    add x10, x10, x9                                    ; pc=0x012C
    sw x5, 0(x10)                                       ; pc=0x0130
    addi x6, x0, 2                                      ; pc=0x0134
    add x7, x3, x6                                      ; pc=0x0138
    add x9, x7, x7                                      ; pc=0x013C
    add x9, x9, x9                                      ; pc=0x0140
    addiSigned x8, x17, -40                             ; pc=0x0144
    add x8, x8, x9                                      ; pc=0x0148
    lw x10, 0(x8)                                       ; pc=0x014C
    sw x10, -68(x17) ; t10                              ; pc=0x0150
    lw x5, -68(x17) ; t10                               ; pc=0x0154
    addi x6, x0, 1                                      ; pc=0x0158
    add x9, x5, x6                                      ; pc=0x015C
    sw x9, -72(x17) ; t11                               ; pc=0x0160
    lw x7, -72(x17) ; t11                               ; pc=0x0164
    addi x8, x0, 2                                      ; pc=0x0168
    add x10, x3, x8                                     ; pc=0x016C
    add x9, x10, x10                                    ; pc=0x0170
    add x9, x9, x9                                      ; pc=0x0174
    addiSigned x6, x17, -40                             ; pc=0x0178
    add x6, x6, x9                                      ; pc=0x017C
    sw x7, 0(x6)                                        ; pc=0x0180
    addi x5, x0, 3                                      ; pc=0x0184
    add x8, x3, x5                                      ; pc=0x0188
    add x9, x8, x8                                      ; pc=0x018C
    add x9, x9, x9                                      ; pc=0x0190
    addiSigned x10, x17, -40                            ; pc=0x0194
    add x10, x10, x9                                    ; pc=0x0198
    lw x6, 0(x10)                                       ; pc=0x019C
    sw x6, -76(x17) ; t12                               ; pc=0x01A0
    lw x7, -76(x17) ; t12                               ; pc=0x01A4
    addi x5, x0, 1                                      ; pc=0x01A8
    add x9, x7, x5                                      ; pc=0x01AC
    sw x9, -80(x17) ; t13                               ; pc=0x01B0
    lw x8, -80(x17) ; t13                               ; pc=0x01B4
    addi x10, x0, 3                                     ; pc=0x01B8
    add x6, x3, x10                                     ; pc=0x01BC
    add x9, x6, x6                                      ; pc=0x01C0
    add x9, x9, x9                                      ; pc=0x01C4
    addiSigned x5, x17, -40                             ; pc=0x01C8
    add x5, x5, x9                                      ; pc=0x01CC
    sw x8, 0(x5)                                        ; pc=0x01D0
    addi x7, x0, 4                                      ; pc=0x01D4
    add x10, x3, x7                                     ; pc=0x01D8
    add x3, x10, x0 ; promote i                         ; pc=0x01DC
    jal x0, -344                                        ; pc=0x01E0 ; target=L_for_start_0 ; addr=0x0088
L_for_end_1:
    addi x9, x0, 8                                      ; pc=0x01E4
    add x6, x9, x9                                      ; pc=0x01E8
    add x6, x6, x6                                      ; pc=0x01EC
    addiSigned x5, x17, -40                             ; pc=0x01F0
    add x5, x5, x6                                      ; pc=0x01F4
    lw x8, 0(x5)                                        ; pc=0x01F8
    sw x8, -88(x17) ; t15                               ; pc=0x01FC
    lw x10, -88(x17) ; t15                              ; pc=0x0200
    addi x7, x0, 1                                      ; pc=0x0204
    add x6, x10, x7                                     ; pc=0x0208
    sw x6, -92(x17) ; t16                               ; pc=0x020C
    lw x9, -92(x17) ; t16                               ; pc=0x0210
    addi x5, x0, 8                                      ; pc=0x0214
    add x8, x5, x5                                      ; pc=0x0218
    add x8, x8, x8                                      ; pc=0x021C
    addiSigned x6, x17, -40                             ; pc=0x0220
    add x6, x6, x8                                      ; pc=0x0224
    sw x9, 0(x6)                                        ; pc=0x0228
    addi x7, x0, 1                                      ; pc=0x022C
    add x10, x3, x7                                     ; pc=0x0230
    add x3, x10, x0 ; promote i                         ; pc=0x0234
    addi x8, x0, 9                                      ; pc=0x0238
    add x5, x8, x8                                      ; pc=0x023C
    add x5, x5, x5                                      ; pc=0x0240
    addiSigned x6, x17, -40                             ; pc=0x0244
    add x6, x6, x5                                      ; pc=0x0248
    lw x9, 0(x6)                                        ; pc=0x024C
    sw x9, -100(x17) ; t18                              ; pc=0x0250
    lw x10, -100(x17) ; t18                             ; pc=0x0254
    addi x7, x0, 1                                      ; pc=0x0258
    add x5, x10, x7                                     ; pc=0x025C
    sw x5, -104(x17) ; t19                              ; pc=0x0260
    lw x8, -104(x17) ; t19                              ; pc=0x0264
    addi x6, x0, 9                                      ; pc=0x0268
    add x9, x6, x6                                      ; pc=0x026C
    add x9, x9, x9                                      ; pc=0x0270
    addiSigned x5, x17, -40                             ; pc=0x0274
    add x5, x5, x9                                      ; pc=0x0278
    sw x8, 0(x5)                                        ; pc=0x027C
    addi x7, x0, 1                                      ; pc=0x0280
    add x10, x3, x7                                     ; pc=0x0284
    add x3, x10, x0 ; promote i                         ; pc=0x0288
    addi x9, x0, 9                                      ; pc=0x028C
    add x6, x9, x9                                      ; pc=0x0290
    add x6, x6, x6                                      ; pc=0x0294
    addiSigned x5, x17, -40                             ; pc=0x0298
    add x5, x5, x6                                      ; pc=0x029C
    lw x8, 0(x5)                                        ; pc=0x02A0
    sw x8, -112(x17) ; t4                               ; pc=0x02A4
    lw x10, -112(x17) ; t4                              ; pc=0x02A8
    add x11, x10, x0                                    ; pc=0x02AC
    jal x0, 4                                           ; pc=0x02B0 ; target=.L_ir_1_main_end ; addr=0x02B4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x02B4
    addi x2, x2, 120                                    ; pc=0x02B8
    freeze                                              ; pc=0x02BC