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
    add x3, x7, x0 ; promote t9                         ; pc=0x0088
    add x11, x3, x0                                     ; pc=0x008C
    jal x0, .L_ir_1_main_end                            ; pc=0x0090
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0094
    addi x2, x2, 48                                     ; pc=0x0098
    freeze                                              ; pc=0x009C

procesar_bloques:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x00A0
    sw x1, 0(x2)                                        ; pc=0x00A4
    sw x17, 4(x2)                                       ; pc=0x00A8
    addi x17, x2, 60                                    ; pc=0x00AC

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x00B0

    addi x5, x0, 0                                      ; pc=0x00B4
    sw x5, -8(x17) ; total                              ; pc=0x00B8
    addi x6, x0, 0                                      ; pc=0x00BC
    add x3, x6, x0 ; promote b                          ; pc=0x00C0
L_for_start_0:
    addi x7, x0, 3                                      ; pc=0x00C4
    addi x8, x0, 0                                      ; pc=0x00C8
    blt x3, x7, .L_ir_3_ir_cmp_true                     ; pc=0x00CC
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x00D0
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x00D4
.L_ir_4_ir_cmp_end:
    sw x8, -20(x17) ; t0                                ; pc=0x00D8
    lw x9, -20(x17) ; t0                                ; pc=0x00DC
    beq x9, x0, L_for_end_1                             ; pc=0x00E0
    addi x10, x0, 0                                     ; pc=0x00E4
    add x4, x10, x0 ; promote i                         ; pc=0x00E8
L_for_start_2:
    addi x5, x0, 3                                      ; pc=0x00EC
    addi x6, x0, 0                                      ; pc=0x00F0
    blt x4, x5, .L_ir_5_ir_cmp_true                     ; pc=0x00F4
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x00F8
.L_ir_5_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x00FC
.L_ir_6_ir_cmp_end:
    sw x6, -24(x17) ; t1                                ; pc=0x0100
    lw x8, -24(x17) ; t1                                ; pc=0x0104
    beq x8, x0, L_for_end_3                             ; pc=0x0108
    addi x7, x0, 3                                      ; pc=0x010C
    mul x9, x3, x7                                      ; pc=0x0110
    sw x9, -28(x17) ; t2                                ; pc=0x0114
    lw x10, -28(x17) ; t2                               ; pc=0x0118
    add x6, x10, x4                                     ; pc=0x011C
    sw x6, -32(x17) ; t3                                ; pc=0x0120
    lw x5, -32(x17) ; t3                                ; pc=0x0124
    add x8, x5, x5                                      ; pc=0x0128
    add x8, x8, x8                                      ; pc=0x012C
    lw x9, -4(x17) ; base ref bloques                   ; pc=0x0130
    add x9, x9, x8                                      ; pc=0x0134
    lw x7, 0(x9)                                        ; pc=0x0138
    sw x7, -36(x17) ; t4                                ; pc=0x013C
    addi x6, x0, 1                                      ; pc=0x0140
    add x10, x4, x6                                     ; pc=0x0144
    sw x10, -40(x17) ; t7                               ; pc=0x0148
    lw x8, -36(x17) ; t4                                ; pc=0x014C
    addi x5, x0, 2                                      ; pc=0x0150
    mul x9, x8, x5                                      ; pc=0x0154
    sw x9, -44(x17) ; t5                                ; pc=0x0158
    lw x7, -8(x17) ; total                              ; pc=0x015C
    lw x10, -44(x17) ; t5                               ; pc=0x0160
    add x6, x7, x10                                     ; pc=0x0164
    sw x6, -8(x17) ; total                              ; pc=0x0168
    lw x9, -40(x17) ; t7                                ; pc=0x016C
    add x4, x9, x0 ; promote i                          ; pc=0x0170
    jal x0, L_for_start_2                               ; pc=0x0174
L_for_end_3:
    addi x5, x0, 1                                      ; pc=0x0178
    add x8, x3, x5                                      ; pc=0x017C
    add x3, x8, x0 ; promote b                          ; pc=0x0180
    jal x0, L_for_start_0                               ; pc=0x0184
L_for_end_1:
    lw x6, -8(x17) ; total                              ; pc=0x0188
    add x11, x6, x0                                     ; pc=0x018C
    jal x0, .L_ir_2_procesar_bloques_end                ; pc=0x0190
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0194
    lw x17, 4(x2)                                       ; pc=0x0198
    addi x2, x2, 60                                     ; pc=0x019C
    jalr x1, 0                                          ; pc=0x01A0