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
    addiSigned x2, x2, -120                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 120                                   ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -40(x17) ; datos[0]                          ; pc=0x0034
    addi x4, x0, 1                                      ; pc=0x0038
    sw x4, -36(x17) ; datos[1]                          ; pc=0x003C
    addi x5, x0, 2                                      ; pc=0x0040
    sw x5, -32(x17) ; datos[2]                          ; pc=0x0044
    addi x6, x0, 3                                      ; pc=0x0048
    sw x6, -28(x17) ; datos[3]                          ; pc=0x004C
    addi x7, x0, 4                                      ; pc=0x0050
    sw x7, -24(x17) ; datos[4]                          ; pc=0x0054
    addi x8, x0, 5                                      ; pc=0x0058
    sw x8, -20(x17) ; datos[5]                          ; pc=0x005C
    addi x9, x0, 6                                      ; pc=0x0060
    sw x9, -16(x17) ; datos[6]                          ; pc=0x0064
    addi x10, x0, 7                                     ; pc=0x0068
    sw x10, -12(x17) ; datos[7]                         ; pc=0x006C
    addi x3, x0, 8                                      ; pc=0x0070
    sw x3, -8(x17) ; datos[8]                           ; pc=0x0074
    addi x4, x0, 9                                      ; pc=0x0078
    sw x4, -4(x17) ; datos[9]                           ; pc=0x007C
    addi x5, x0, 0                                      ; pc=0x0080
    sw x5, -48(x17) ; i__v1__x3                         ; pc=0x0084
    lw x3, -48(x17) ; i__v1__x3                         ; pc=0x0088
    sw x3, -44(x17) ; i                                 ; pc=0x008C
L_for_start_0:
    lw x6, -44(x17) ; i                                 ; pc=0x0090
    addi x7, x0, 8                                      ; pc=0x0094
    addi x4, x0, 0                                      ; pc=0x0098
    blt x6, x7, .L_ir_2_ir_cmp_true                     ; pc=0x009C
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x00A0
.L_ir_2_ir_cmp_true:
    addi x4, x0, 1                                      ; pc=0x00A4
.L_ir_3_ir_cmp_end:
    sw x4, -52(x17) ; t5__x4                            ; pc=0x00A8
    lw x4, -52(x17) ; t5__x4                            ; pc=0x00AC
    beq x4, x0, L_for_end_1                             ; pc=0x00B0
    lw x8, -44(x17) ; i                                 ; pc=0x00B4
    add x9, x8, x8                                      ; pc=0x00B8
    add x9, x9, x9                                      ; pc=0x00BC
    addiSigned x10, x17, -40                            ; pc=0x00C0
    add x10, x10, x9                                    ; pc=0x00C4
    lw x5, 0(x10)                                       ; pc=0x00C8
    sw x5, -56(x17) ; t6__x5                            ; pc=0x00CC
    lw x5, -56(x17) ; t6__x5                            ; pc=0x00D0
    addi x3, x0, 1                                      ; pc=0x00D4
    add x6, x5, x3                                      ; pc=0x00D8
    sw x6, -60(x17) ; t7__x6                            ; pc=0x00DC
    lw x6, -60(x17) ; t7__x6                            ; pc=0x00E0
    lw x7, -44(x17) ; i                                 ; pc=0x00E4
    add x4, x7, x7                                      ; pc=0x00E8
    add x4, x4, x4                                      ; pc=0x00EC
    addiSigned x9, x17, -40                             ; pc=0x00F0
    add x9, x9, x4                                      ; pc=0x00F4
    sw x6, 0(x9)                                        ; pc=0x00F8
    lw x8, -44(x17) ; i                                 ; pc=0x00FC
    addi x10, x0, 1                                     ; pc=0x0100
    add x3, x8, x10                                     ; pc=0x0104
    add x5, x3, x3                                      ; pc=0x0108
    add x5, x5, x5                                      ; pc=0x010C
    addiSigned x4, x17, -40                             ; pc=0x0110
    add x4, x4, x5                                      ; pc=0x0114
    lw x7, 0(x4)                                        ; pc=0x0118
    sw x7, -64(x17) ; t8__x7                            ; pc=0x011C
    lw x7, -64(x17) ; t8__x7                            ; pc=0x0120
    addi x9, x0, 1                                      ; pc=0x0124
    add x8, x7, x9                                      ; pc=0x0128
    sw x8, -68(x17) ; t9__x8                            ; pc=0x012C
    lw x8, -68(x17) ; t9__x8                            ; pc=0x0130
    lw x6, -44(x17) ; i                                 ; pc=0x0134
    addi x10, x0, 1                                     ; pc=0x0138
    add x5, x6, x10                                     ; pc=0x013C
    add x3, x5, x5                                      ; pc=0x0140
    add x3, x3, x3                                      ; pc=0x0144
    addiSigned x4, x17, -40                             ; pc=0x0148
    add x4, x4, x3                                      ; pc=0x014C
    sw x8, 0(x4)                                        ; pc=0x0150
    lw x9, -44(x17) ; i                                 ; pc=0x0154
    addi x7, x0, 2                                      ; pc=0x0158
    add x10, x9, x7                                     ; pc=0x015C
    add x6, x10, x10                                    ; pc=0x0160
    add x6, x6, x6                                      ; pc=0x0164
    addiSigned x3, x17, -40                             ; pc=0x0168
    add x3, x3, x6                                      ; pc=0x016C
    lw x5, 0(x3)                                        ; pc=0x0170
    sw x5, -72(x17) ; t10__x9                           ; pc=0x0174
    lw x9, -72(x17) ; t10__x9                           ; pc=0x0178
    addi x4, x0, 1                                      ; pc=0x017C
    add x10, x9, x4                                     ; pc=0x0180
    sw x10, -76(x17) ; t11__x10                         ; pc=0x0184
    lw x10, -76(x17) ; t11__x10                         ; pc=0x0188
    lw x8, -44(x17) ; i                                 ; pc=0x018C
    addi x7, x0, 2                                      ; pc=0x0190
    add x6, x8, x7                                      ; pc=0x0194
    add x3, x6, x6                                      ; pc=0x0198
    add x3, x3, x3                                      ; pc=0x019C
    addiSigned x5, x17, -40                             ; pc=0x01A0
    add x5, x5, x3                                      ; pc=0x01A4
    sw x10, 0(x5)                                       ; pc=0x01A8
    lw x4, -44(x17) ; i                                 ; pc=0x01AC
    addi x9, x0, 3                                      ; pc=0x01B0
    add x7, x4, x9                                      ; pc=0x01B4
    add x8, x7, x7                                      ; pc=0x01B8
    add x8, x8, x8                                      ; pc=0x01BC
    addiSigned x3, x17, -40                             ; pc=0x01C0
    add x3, x3, x8                                      ; pc=0x01C4
    lw x6, 0(x3)                                        ; pc=0x01C8
    sw x6, -80(x17) ; t12__x3                           ; pc=0x01CC
    lw x3, -80(x17) ; t12__x3                           ; pc=0x01D0
    addi x5, x0, 1                                      ; pc=0x01D4
    add x4, x3, x5                                      ; pc=0x01D8
    sw x4, -84(x17) ; t13__x4                           ; pc=0x01DC
    lw x4, -84(x17) ; t13__x4                           ; pc=0x01E0
    lw x10, -44(x17) ; i                                ; pc=0x01E4
    addi x9, x0, 3                                      ; pc=0x01E8
    add x8, x10, x9                                     ; pc=0x01EC
    add x7, x8, x8                                      ; pc=0x01F0
    add x7, x7, x7                                      ; pc=0x01F4
    addiSigned x6, x17, -40                             ; pc=0x01F8
    add x6, x6, x7                                      ; pc=0x01FC
    sw x4, 0(x6)                                        ; pc=0x0200
    lw x5, -44(x17) ; i                                 ; pc=0x0204
    addi x3, x0, 4                                      ; pc=0x0208
    add x9, x5, x3                                      ; pc=0x020C
    sw x9, -88(x17) ; t14__x5                           ; pc=0x0210
    lw x5, -88(x17) ; t14__x5                           ; pc=0x0214
    sw x5, -92(x17) ; i__v2__x6                         ; pc=0x0218
    lw x6, -92(x17) ; i__v2__x6                         ; pc=0x021C
    sw x6, -44(x17) ; i                                 ; pc=0x0220
    jal x0, L_for_start_0                               ; pc=0x0224
L_for_end_1:
    addi x10, x0, 8                                     ; pc=0x0228
    add x7, x10, x10                                    ; pc=0x022C
    add x7, x7, x7                                      ; pc=0x0230
    addiSigned x8, x17, -40                             ; pc=0x0234
    add x8, x8, x7                                      ; pc=0x0238
    lw x4, 0(x8)                                        ; pc=0x023C
    sw x4, -96(x17) ; t15__x7                           ; pc=0x0240
    lw x7, -96(x17) ; t15__x7                           ; pc=0x0244
    addi x9, x0, 1                                      ; pc=0x0248
    add x8, x7, x9                                      ; pc=0x024C
    sw x8, -100(x17) ; t16__x8                          ; pc=0x0250
    lw x8, -100(x17) ; t16__x8                          ; pc=0x0254
    addi x3, x0, 8                                      ; pc=0x0258
    add x5, x3, x3                                      ; pc=0x025C
    add x5, x5, x5                                      ; pc=0x0260
    addiSigned x6, x17, -40                             ; pc=0x0264
    add x6, x6, x5                                      ; pc=0x0268
    sw x8, 0(x6)                                        ; pc=0x026C
    addi x10, x0, 9                                     ; pc=0x0270
    add x4, x10, x10                                    ; pc=0x0274
    add x4, x4, x4                                      ; pc=0x0278
    addiSigned x9, x17, -40                             ; pc=0x027C
    add x9, x9, x4                                      ; pc=0x0280
    lw x7, 0(x9)                                        ; pc=0x0284
    sw x7, -104(x17) ; t18__x9                          ; pc=0x0288
    lw x9, -104(x17) ; t18__x9                          ; pc=0x028C
    addi x5, x0, 1                                      ; pc=0x0290
    add x10, x9, x5                                     ; pc=0x0294
    sw x10, -108(x17) ; t19__x10                        ; pc=0x0298
    lw x10, -108(x17) ; t19__x10                        ; pc=0x029C
    addi x3, x0, 9                                      ; pc=0x02A0
    add x6, x3, x3                                      ; pc=0x02A4
    add x6, x6, x6                                      ; pc=0x02A8
    addiSigned x8, x17, -40                             ; pc=0x02AC
    add x8, x8, x6                                      ; pc=0x02B0
    sw x10, 0(x8)                                       ; pc=0x02B4
    addi x4, x0, 9                                      ; pc=0x02B8
    add x7, x4, x4                                      ; pc=0x02BC
    add x7, x7, x7                                      ; pc=0x02C0
    addiSigned x5, x17, -40                             ; pc=0x02C4
    add x5, x5, x7                                      ; pc=0x02C8
    lw x9, 0(x5)                                        ; pc=0x02CC
    sw x9, -112(x17) ; t4__x3                           ; pc=0x02D0
    lw x3, -112(x17) ; t4__x3                           ; pc=0x02D4
    add x11, x3, x0                                     ; pc=0x02D8
    jal x0, .L_ir_1_main_end                            ; pc=0x02DC
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x02E0
    addi x2, x2, 120                                    ; pc=0x02E4
    freeze                                              ; pc=0x02E8