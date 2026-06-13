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
    addiSigned x2, x2, -48                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 48                                    ; pc=0x002C

    addi x4, x0, 1                                      ; pc=0x0030
    sw x4, -36(x17) ; datos[0]                          ; pc=0x0034
    addi x5, x0, 2                                      ; pc=0x0038
    sw x5, -32(x17) ; datos[1]                          ; pc=0x003C
    addi x6, x0, 3                                      ; pc=0x0040
    sw x6, -28(x17) ; datos[2]                          ; pc=0x0044
    addi x7, x0, 4                                      ; pc=0x0048
    sw x7, -24(x17) ; datos[3]                          ; pc=0x004C
    addi x8, x0, 5                                      ; pc=0x0050
    sw x8, -20(x17) ; datos[4]                          ; pc=0x0054
    addi x9, x0, 6                                      ; pc=0x0058
    sw x9, -16(x17) ; datos[5]                          ; pc=0x005C
    addi x10, x0, 7                                     ; pc=0x0060
    sw x10, -12(x17) ; datos[6]                         ; pc=0x0064
    addi x4, x0, 8                                      ; pc=0x0068
    sw x4, -8(x17) ; datos[7]                           ; pc=0x006C
    addi x5, x0, 9                                      ; pc=0x0070
    sw x5, -4(x17) ; datos[8]                           ; pc=0x0074
    addiSigned x6, x17, -36                             ; pc=0x0078
    add x11, x6, x0                                     ; pc=0x007C
    jal x1, procesar_bloques                            ; pc=0x0080
    add x7, x11, x0                                     ; pc=0x0084
    add x3, x7, x0 ; promote t9__x7                     ; pc=0x0088
    add x11, x3, x0                                     ; pc=0x008C
    jal x0, .L_ir_1_main_end                            ; pc=0x0090
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0094
    addi x2, x2, 48                                     ; pc=0x0098
    freeze                                              ; pc=0x009C

procesar_bloques:
    ; prologue
    addiSigned x2, x2, -108                             ; pc=0x00A0
    sw x1, 0(x2)                                        ; pc=0x00A4
    sw x17, 4(x2)                                       ; pc=0x00A8
    addi x17, x2, 108                                   ; pc=0x00AC

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x00B0

    addi x5, x0, 0                                      ; pc=0x00B4
    add x3, x5, x0 ; promote total                      ; pc=0x00B8
    addi x6, x0, 0                                      ; pc=0x00BC
    sw x6, -12(x17) ; b                                 ; pc=0x00C0
L_for_start_0:
    lw x7, -12(x17) ; b                                 ; pc=0x00C4
    addi x8, x0, 3                                      ; pc=0x00C8
    addi x9, x0, 0                                      ; pc=0x00CC
    blt x7, x8, .L_ir_3_ir_cmp_true                     ; pc=0x00D0
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x00D4
.L_ir_3_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x00D8
.L_ir_4_ir_cmp_end:
    sw x9, -20(x17) ; t0__x3                            ; pc=0x00DC
    lw x10, -20(x17) ; t0__x3                           ; pc=0x00E0
    beq x10, x0, L_for_end_1                            ; pc=0x00E4
    addi x5, x0, 0                                      ; pc=0x00E8
    add x4, x5, x0 ; promote i                          ; pc=0x00EC
L_for_start_2:
    addi x6, x0, 2                                      ; pc=0x00F0
    addi x9, x0, 0                                      ; pc=0x00F4
    blt x4, x6, .L_ir_5_ir_cmp_true                     ; pc=0x00F8
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x00FC
.L_ir_5_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0100
.L_ir_6_ir_cmp_end:
    sw x9, -24(x17) ; t10__x4                           ; pc=0x0104
    lw x8, -24(x17) ; t10__x4                           ; pc=0x0108
    beq x8, x0, L_for_end_3                             ; pc=0x010C
    lw x7, -12(x17) ; b                                 ; pc=0x0110
    addi x10, x0, 3                                     ; pc=0x0114
    mul x5, x7, x10                                     ; pc=0x0118
    sw x5, -28(x17) ; t11__x5                           ; pc=0x011C
    lw x5, -28(x17) ; t11__x5                           ; pc=0x0120
    add x6, x5, x4                                      ; pc=0x0124
    sw x6, -32(x17) ; t12__x6                           ; pc=0x0128
    lw x9, -36(x17) ; t3                                ; pc=0x012C
    add x8, x9, x9                                      ; pc=0x0130
    add x8, x8, x8                                      ; pc=0x0134
    lw x10, -4(x17) ; base ref bloques                  ; pc=0x0138
    add x10, x10, x8                                    ; pc=0x013C
    lw x7, 0(x10)                                       ; pc=0x0140
    sw x7, -40(x17) ; t13__x7                           ; pc=0x0144
    lw x7, -40(x17) ; t13__x7                           ; pc=0x0148
    addi x6, x0, 2                                      ; pc=0x014C
    mul x8, x7, x6                                      ; pc=0x0150
    sw x8, -44(x17) ; t14__x8                           ; pc=0x0154
    lw x8, -44(x17) ; t14__x8                           ; pc=0x0158
    add x5, x3, x8                                      ; pc=0x015C
    add x3, x5, x0 ; promote total                      ; pc=0x0160
    lw x9, -12(x17) ; b                                 ; pc=0x0164
    addi x10, x0, 3                                     ; pc=0x0168
    mul x6, x9, x10                                     ; pc=0x016C
    sw x6, -52(x17) ; t16__x10                          ; pc=0x0170
    lw x10, -52(x17) ; t16__x10                         ; pc=0x0174
    addi x7, x0, 1                                      ; pc=0x0178
    add x5, x4, x7                                      ; pc=0x017C
    add x8, x10, x5                                     ; pc=0x0180
    sw x8, -56(x17) ; t17__x3                           ; pc=0x0184
    lw x6, -36(x17) ; t3                                ; pc=0x0188
    add x9, x6, x6                                      ; pc=0x018C
    add x9, x9, x9                                      ; pc=0x0190
    lw x7, -4(x17) ; base ref bloques                   ; pc=0x0194
    add x7, x7, x9                                      ; pc=0x0198
    lw x8, 0(x7)                                        ; pc=0x019C
    sw x8, -60(x17) ; t18__x4                           ; pc=0x01A0
    lw x5, -60(x17) ; t18__x4                           ; pc=0x01A4
    addi x10, x0, 2                                     ; pc=0x01A8
    mul x9, x5, x10                                     ; pc=0x01AC
    sw x9, -64(x17) ; t19__x5                           ; pc=0x01B0
    lw x5, -64(x17) ; t19__x5                           ; pc=0x01B4
    add x6, x3, x5                                      ; pc=0x01B8
    add x3, x6, x0 ; promote total                      ; pc=0x01BC
    addi x7, x0, 2                                      ; pc=0x01C0
    add x8, x4, x7                                      ; pc=0x01C4
    add x4, x8, x0 ; promote i                          ; pc=0x01C8
    jal x0, L_for_start_2                               ; pc=0x01CC
L_for_end_3:
    lw x9, -12(x17) ; b                                 ; pc=0x01D0
    addi x10, x0, 3                                     ; pc=0x01D4
    mul x8, x9, x10                                     ; pc=0x01D8
    sw x8, -76(x17) ; t22__x8                           ; pc=0x01DC
    lw x8, -76(x17) ; t22__x8                           ; pc=0x01E0
    addi x6, x0, 2                                      ; pc=0x01E4
    add x9, x8, x6                                      ; pc=0x01E8
    sw x9, -80(x17) ; t23__x9                           ; pc=0x01EC
    lw x5, -36(x17) ; t3                                ; pc=0x01F0
    add x7, x5, x5                                      ; pc=0x01F4
    add x7, x7, x7                                      ; pc=0x01F8
    lw x10, -4(x17) ; base ref bloques                  ; pc=0x01FC
    add x10, x10, x7                                    ; pc=0x0200
    lw x9, 0(x10)                                       ; pc=0x0204
    sw x9, -84(x17) ; t24__x10                          ; pc=0x0208
    lw x10, -84(x17) ; t24__x10                         ; pc=0x020C
    addi x6, x0, 2                                      ; pc=0x0210
    mul x8, x10, x6                                     ; pc=0x0214
    sw x8, -88(x17) ; t25__x3                           ; pc=0x0218
    lw x7, -88(x17) ; t25__x3                           ; pc=0x021C
    add x5, x3, x7                                      ; pc=0x0220
    add x3, x5, x0 ; promote total                      ; pc=0x0224
    addi x9, x0, 1                                      ; pc=0x0228
    add x8, x4, x9                                      ; pc=0x022C
    add x4, x8, x0 ; promote i                          ; pc=0x0230
    lw x6, -12(x17) ; b                                 ; pc=0x0234
    addi x10, x0, 1                                     ; pc=0x0238
    add x5, x6, x10                                     ; pc=0x023C
    sw x5, -12(x17) ; b                                 ; pc=0x0240
    jal x0, L_for_start_0                               ; pc=0x0244
L_for_end_1:
    add x11, x3, x0                                     ; pc=0x0248
    jal x0, .L_ir_2_procesar_bloques_end                ; pc=0x024C
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0250
    lw x17, 4(x2)                                       ; pc=0x0254
    addi x2, x2, 108                                    ; pc=0x0258
    jalr x1, 0                                          ; pc=0x025C