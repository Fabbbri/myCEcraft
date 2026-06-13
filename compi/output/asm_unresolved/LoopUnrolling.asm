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
    addiSigned x2, x2, -140                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 140                                   ; pc=0x002C

    addi x4, x0, 1                                      ; pc=0x0030
    sw x4, -128(x17) ; datos[0]                         ; pc=0x0034
    addi x5, x0, 2                                      ; pc=0x0038
    sw x5, -124(x17) ; datos[1]                         ; pc=0x003C
    addi x6, x0, 3                                      ; pc=0x0040
    sw x6, -120(x17) ; datos[2]                         ; pc=0x0044
    addi x7, x0, 4                                      ; pc=0x0048
    sw x7, -116(x17) ; datos[3]                         ; pc=0x004C
    addi x8, x0, 5                                      ; pc=0x0050
    sw x8, -112(x17) ; datos[4]                         ; pc=0x0054
    addi x9, x0, 6                                      ; pc=0x0058
    sw x9, -108(x17) ; datos[5]                         ; pc=0x005C
    addi x10, x0, 7                                     ; pc=0x0060
    sw x10, -104(x17) ; datos[6]                        ; pc=0x0064
    addi x4, x0, 8                                      ; pc=0x0068
    sw x4, -100(x17) ; datos[7]                         ; pc=0x006C
    addi x5, x0, 9                                      ; pc=0x0070
    sw x5, -96(x17) ; datos[8]                          ; pc=0x0074
    addi x6, x0, 10                                     ; pc=0x0078
    sw x6, -92(x17) ; datos[9]                          ; pc=0x007C
    addi x7, x0, 11                                     ; pc=0x0080
    sw x7, -88(x17) ; datos[10]                         ; pc=0x0084
    addi x8, x0, 12                                     ; pc=0x0088
    sw x8, -84(x17) ; datos[11]                         ; pc=0x008C
    addi x9, x0, 13                                     ; pc=0x0090
    sw x9, -80(x17) ; datos[12]                         ; pc=0x0094
    addi x10, x0, 14                                    ; pc=0x0098
    sw x10, -76(x17) ; datos[13]                        ; pc=0x009C
    addi x4, x0, 15                                     ; pc=0x00A0
    sw x4, -72(x17) ; datos[14]                         ; pc=0x00A4
    addi x5, x0, 16                                     ; pc=0x00A8
    sw x5, -68(x17) ; datos[15]                         ; pc=0x00AC
    addi x6, x0, 17                                     ; pc=0x00B0
    sw x6, -64(x17) ; datos[16]                         ; pc=0x00B4
    addi x7, x0, 18                                     ; pc=0x00B8
    sw x7, -60(x17) ; datos[17]                         ; pc=0x00BC
    addi x8, x0, 19                                     ; pc=0x00C0
    sw x8, -56(x17) ; datos[18]                         ; pc=0x00C4
    addi x9, x0, 20                                     ; pc=0x00C8
    sw x9, -52(x17) ; datos[19]                         ; pc=0x00CC
    addi x10, x0, 21                                    ; pc=0x00D0
    sw x10, -48(x17) ; datos[20]                        ; pc=0x00D4
    addi x4, x0, 22                                     ; pc=0x00D8
    sw x4, -44(x17) ; datos[21]                         ; pc=0x00DC
    addi x5, x0, 23                                     ; pc=0x00E0
    sw x5, -40(x17) ; datos[22]                         ; pc=0x00E4
    addi x6, x0, 24                                     ; pc=0x00E8
    sw x6, -36(x17) ; datos[23]                         ; pc=0x00EC
    addi x7, x0, 25                                     ; pc=0x00F0
    sw x7, -32(x17) ; datos[24]                         ; pc=0x00F4
    addi x8, x0, 26                                     ; pc=0x00F8
    sw x8, -28(x17) ; datos[25]                         ; pc=0x00FC
    addi x9, x0, 27                                     ; pc=0x0100
    sw x9, -24(x17) ; datos[26]                         ; pc=0x0104
    addi x10, x0, 28                                    ; pc=0x0108
    sw x10, -20(x17) ; datos[27]                        ; pc=0x010C
    addi x4, x0, 29                                     ; pc=0x0110
    sw x4, -16(x17) ; datos[28]                         ; pc=0x0114
    addi x5, x0, 30                                     ; pc=0x0118
    sw x5, -12(x17) ; datos[29]                         ; pc=0x011C
    addi x6, x0, 31                                     ; pc=0x0120
    sw x6, -8(x17) ; datos[30]                          ; pc=0x0124
    addi x7, x0, 32                                     ; pc=0x0128
    sw x7, -4(x17) ; datos[31]                          ; pc=0x012C
    addiSigned x8, x17, -128                            ; pc=0x0130
    add x11, x8, x0                                     ; pc=0x0134
    jal x1, procesar_bloques                            ; pc=0x0138
    add x9, x11, x0                                     ; pc=0x013C
    add x3, x9, x0 ; promote t9                         ; pc=0x0140
    add x11, x3, x0                                     ; pc=0x0144
    jal x0, .L_ir_1_main_end                            ; pc=0x0148
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x014C
    addi x2, x2, 140                                    ; pc=0x0150
    freeze                                              ; pc=0x0154

procesar_bloques:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x0158
    sw x1, 0(x2)                                        ; pc=0x015C
    sw x17, 4(x2)                                       ; pc=0x0160
    addi x17, x2, 60                                    ; pc=0x0164

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x0168

    addi x5, x0, 0                                      ; pc=0x016C
    sw x5, -8(x17) ; total                              ; pc=0x0170
    addi x6, x0, 0                                      ; pc=0x0174
    add x3, x6, x0 ; promote b                          ; pc=0x0178
L_for_start_0:
    addi x7, x0, 4                                      ; pc=0x017C
    addi x8, x0, 0                                      ; pc=0x0180
    blt x3, x7, .L_ir_3_ir_cmp_true                     ; pc=0x0184
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x0188
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x018C
.L_ir_4_ir_cmp_end:
    sw x8, -20(x17) ; t0                                ; pc=0x0190
    lw x9, -20(x17) ; t0                                ; pc=0x0194
    beq x9, x0, L_for_end_1                             ; pc=0x0198
    addi x10, x0, 0                                     ; pc=0x019C
    add x4, x10, x0 ; promote i                         ; pc=0x01A0
L_for_start_2:
    addi x5, x0, 8                                      ; pc=0x01A4
    addi x6, x0, 0                                      ; pc=0x01A8
    blt x4, x5, .L_ir_5_ir_cmp_true                     ; pc=0x01AC
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x01B0
.L_ir_5_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x01B4
.L_ir_6_ir_cmp_end:
    sw x6, -24(x17) ; t1                                ; pc=0x01B8
    lw x8, -24(x17) ; t1                                ; pc=0x01BC
    beq x8, x0, L_for_end_3                             ; pc=0x01C0
    addi x7, x0, 8                                      ; pc=0x01C4
    mul x9, x3, x7                                      ; pc=0x01C8
    sw x9, -28(x17) ; t2                                ; pc=0x01CC
    lw x10, -28(x17) ; t2                               ; pc=0x01D0
    add x6, x10, x4                                     ; pc=0x01D4
    sw x6, -32(x17) ; t3                                ; pc=0x01D8
    lw x5, -32(x17) ; t3                                ; pc=0x01DC
    add x8, x5, x5                                      ; pc=0x01E0
    add x8, x8, x8                                      ; pc=0x01E4
    lw x9, -4(x17) ; base ref bloques                   ; pc=0x01E8
    add x9, x9, x8                                      ; pc=0x01EC
    lw x7, 0(x9)                                        ; pc=0x01F0
    sw x7, -36(x17) ; t4                                ; pc=0x01F4
    lw x6, -36(x17) ; t4                                ; pc=0x01F8
    addi x10, x0, 2                                     ; pc=0x01FC
    mul x8, x6, x10                                     ; pc=0x0200
    sw x8, -40(x17) ; t5                                ; pc=0x0204
    lw x5, -8(x17) ; total                              ; pc=0x0208
    lw x9, -40(x17) ; t5                                ; pc=0x020C
    add x7, x5, x9                                      ; pc=0x0210
    sw x7, -8(x17) ; total                              ; pc=0x0214
    addi x8, x0, 1                                      ; pc=0x0218
    add x10, x4, x8                                     ; pc=0x021C
    add x4, x10, x0 ; promote i                         ; pc=0x0220
    jal x0, L_for_start_2                               ; pc=0x0224
L_for_end_3:
    addi x6, x0, 1                                      ; pc=0x0228
    add x7, x3, x6                                      ; pc=0x022C
    add x3, x7, x0 ; promote b                          ; pc=0x0230
    jal x0, L_for_start_0                               ; pc=0x0234
L_for_end_1:
    lw x9, -8(x17) ; total                              ; pc=0x0238
    add x11, x9, x0                                     ; pc=0x023C
    jal x0, .L_ir_2_procesar_bloques_end                ; pc=0x0240
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0244
    lw x17, 4(x2)                                       ; pc=0x0248
    addi x2, x2, 60                                     ; pc=0x024C
    jalr x1, 0                                          ; pc=0x0250