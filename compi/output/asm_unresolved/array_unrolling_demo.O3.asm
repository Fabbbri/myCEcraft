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
    addiSigned x2, x2, -112                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 112                                   ; pc=0x002C

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
    blt x3, x10, .L_ir_2_ir_cmp_true                    ; pc=0x0090
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0094
.L_ir_2_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0098
.L_ir_3_ir_cmp_end:
    add x4, x5, x0 ; promote t5__x3                     ; pc=0x009C
    beq x4, x0, L_for_end_1                             ; pc=0x00A0
    add x6, x3, x3                                      ; pc=0x00A4
    add x6, x6, x6                                      ; pc=0x00A8
    addiSigned x7, x17, -40                             ; pc=0x00AC
    add x7, x7, x6                                      ; pc=0x00B0
    lw x8, 0(x7)                                        ; pc=0x00B4
    sw x8, -52(x17) ; t6__x4                            ; pc=0x00B8
    lw x9, -52(x17) ; t6__x4                            ; pc=0x00BC
    addi x5, x0, 1                                      ; pc=0x00C0
    add x10, x9, x5                                     ; pc=0x00C4
    sw x10, -56(x17) ; t7__x5                           ; pc=0x00C8
    lw x5, -56(x17) ; t7__x5                            ; pc=0x00CC
    add x6, x3, x3                                      ; pc=0x00D0
    add x6, x6, x6                                      ; pc=0x00D4
    addiSigned x7, x17, -40                             ; pc=0x00D8
    add x7, x7, x6                                      ; pc=0x00DC
    sw x5, 0(x7)                                        ; pc=0x00E0
    addi x8, x0, 1                                      ; pc=0x00E4
    add x10, x3, x8                                     ; pc=0x00E8
    add x9, x10, x10                                    ; pc=0x00EC
    add x9, x9, x9                                      ; pc=0x00F0
    addiSigned x6, x17, -40                             ; pc=0x00F4
    add x6, x6, x9                                      ; pc=0x00F8
    lw x7, 0(x6)                                        ; pc=0x00FC
    sw x7, -60(x17) ; t8__x6                            ; pc=0x0100
    lw x6, -60(x17) ; t8__x6                            ; pc=0x0104
    addi x5, x0, 1                                      ; pc=0x0108
    add x7, x6, x5                                      ; pc=0x010C
    sw x7, -64(x17) ; t9__x7                            ; pc=0x0110
    lw x7, -64(x17) ; t9__x7                            ; pc=0x0114
    addi x8, x0, 1                                      ; pc=0x0118
    add x9, x3, x8                                      ; pc=0x011C
    add x10, x9, x9                                     ; pc=0x0120
    add x10, x10, x10                                   ; pc=0x0124
    addiSigned x5, x17, -40                             ; pc=0x0128
    add x5, x5, x10                                     ; pc=0x012C
    sw x7, 0(x5)                                        ; pc=0x0130
    addi x6, x0, 2                                      ; pc=0x0134
    add x8, x3, x6                                      ; pc=0x0138
    add x10, x8, x8                                     ; pc=0x013C
    add x10, x10, x10                                   ; pc=0x0140
    addiSigned x9, x17, -40                             ; pc=0x0144
    add x9, x9, x10                                     ; pc=0x0148
    lw x5, 0(x9)                                        ; pc=0x014C
    sw x5, -68(x17) ; t10__x8                           ; pc=0x0150
    lw x8, -68(x17) ; t10__x8                           ; pc=0x0154
    addi x7, x0, 1                                      ; pc=0x0158
    add x9, x8, x7                                      ; pc=0x015C
    sw x9, -72(x17) ; t11__x9                           ; pc=0x0160
    lw x9, -72(x17) ; t11__x9                           ; pc=0x0164
    addi x6, x0, 2                                      ; pc=0x0168
    add x10, x3, x6                                     ; pc=0x016C
    add x5, x10, x10                                    ; pc=0x0170
    add x5, x5, x5                                      ; pc=0x0174
    addiSigned x7, x17, -40                             ; pc=0x0178
    add x7, x7, x5                                      ; pc=0x017C
    sw x9, 0(x7)                                        ; pc=0x0180
    addi x8, x0, 3                                      ; pc=0x0184
    add x6, x3, x8                                      ; pc=0x0188
    add x5, x6, x6                                      ; pc=0x018C
    add x5, x5, x5                                      ; pc=0x0190
    addiSigned x10, x17, -40                            ; pc=0x0194
    add x10, x10, x5                                    ; pc=0x0198
    lw x7, 0(x10)                                       ; pc=0x019C
    sw x7, -76(x17) ; t12__x10                          ; pc=0x01A0
    lw x10, -76(x17) ; t12__x10                         ; pc=0x01A4
    addi x9, x0, 1                                      ; pc=0x01A8
    add x8, x10, x9                                     ; pc=0x01AC
    sw x8, -80(x17) ; t13__x3                           ; pc=0x01B0
    lw x5, -80(x17) ; t13__x3                           ; pc=0x01B4
    addi x6, x0, 3                                      ; pc=0x01B8
    add x7, x3, x6                                      ; pc=0x01BC
    add x8, x7, x7                                      ; pc=0x01C0
    add x8, x8, x8                                      ; pc=0x01C4
    addiSigned x9, x17, -40                             ; pc=0x01C8
    add x9, x9, x8                                      ; pc=0x01CC
    sw x5, 0(x9)                                        ; pc=0x01D0
    addi x10, x0, 4                                     ; pc=0x01D4
    add x6, x3, x10                                     ; pc=0x01D8
    add x3, x6, x0 ; promote i                          ; pc=0x01DC
    jal x0, L_for_start_0                               ; pc=0x01E0
L_for_end_1:
    addi x8, x0, 8                                      ; pc=0x01E4
    add x7, x8, x8                                      ; pc=0x01E8
    add x7, x7, x7                                      ; pc=0x01EC
    addiSigned x9, x17, -40                             ; pc=0x01F0
    add x9, x9, x7                                      ; pc=0x01F4
    lw x5, 0(x9)                                        ; pc=0x01F8
    sw x5, -88(x17) ; t15__x5                           ; pc=0x01FC
    lw x5, -88(x17) ; t15__x5                           ; pc=0x0200
    addi x6, x0, 1                                      ; pc=0x0204
    add x10, x5, x6                                     ; pc=0x0208
    sw x10, -92(x17) ; t16__x6                          ; pc=0x020C
    lw x6, -92(x17) ; t16__x6                           ; pc=0x0210
    addi x7, x0, 8                                      ; pc=0x0214
    add x8, x7, x7                                      ; pc=0x0218
    add x8, x8, x8                                      ; pc=0x021C
    addiSigned x9, x17, -40                             ; pc=0x0220
    add x9, x9, x8                                      ; pc=0x0224
    sw x6, 0(x9)                                        ; pc=0x0228
    addi x10, x0, 9                                     ; pc=0x022C
    add x5, x10, x10                                    ; pc=0x0230
    add x5, x5, x5                                      ; pc=0x0234
    addiSigned x8, x17, -40                             ; pc=0x0238
    add x8, x8, x5                                      ; pc=0x023C
    lw x7, 0(x8)                                        ; pc=0x0240
    sw x7, -96(x17) ; t18__x7                           ; pc=0x0244
    lw x7, -96(x17) ; t18__x7                           ; pc=0x0248
    addi x9, x0, 1                                      ; pc=0x024C
    add x8, x7, x9                                      ; pc=0x0250
    sw x8, -100(x17) ; t19__x8                          ; pc=0x0254
    lw x8, -100(x17) ; t19__x8                          ; pc=0x0258
    addi x6, x0, 9                                      ; pc=0x025C
    add x5, x6, x6                                      ; pc=0x0260
    add x5, x5, x5                                      ; pc=0x0264
    addiSigned x10, x17, -40                            ; pc=0x0268
    add x10, x10, x5                                    ; pc=0x026C
    sw x8, 0(x10)                                       ; pc=0x0270
    addi x9, x0, 9                                      ; pc=0x0274
    add x7, x9, x9                                      ; pc=0x0278
    add x7, x7, x7                                      ; pc=0x027C
    addiSigned x5, x17, -40                             ; pc=0x0280
    add x5, x5, x7                                      ; pc=0x0284
    lw x6, 0(x5)                                        ; pc=0x0288
    sw x6, -104(x17) ; t4__x9                           ; pc=0x028C
    lw x9, -104(x17) ; t4__x9                           ; pc=0x0290
    add x11, x9, x0                                     ; pc=0x0294
    jal x0, .L_ir_1_main_end                            ; pc=0x0298
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x029C
    addi x2, x2, 112                                    ; pc=0x02A0
    freeze                                              ; pc=0x02A4