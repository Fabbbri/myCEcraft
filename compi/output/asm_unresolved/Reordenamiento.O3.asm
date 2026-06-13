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
    addiSigned x2, x2, -40                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 40                                    ; pc=0x002C

    addi x4, x0, 10                                     ; pc=0x0030
    sw x4, -28(x17) ; datos[0]                          ; pc=0x0034
    addi x5, x0, 20                                     ; pc=0x0038
    sw x5, -24(x17) ; datos[1]                          ; pc=0x003C
    addi x6, x0, 30                                     ; pc=0x0040
    sw x6, -20(x17) ; datos[2]                          ; pc=0x0044
    addi x7, x0, 40                                     ; pc=0x0048
    sw x7, -16(x17) ; datos[3]                          ; pc=0x004C
    addi x8, x0, 50                                     ; pc=0x0050
    sw x8, -12(x17) ; datos[4]                          ; pc=0x0054
    addi x9, x0, 60                                     ; pc=0x0058
    sw x9, -8(x17) ; datos[5]                           ; pc=0x005C
    addi x10, x0, 70                                    ; pc=0x0060
    sw x10, -4(x17) ; datos[6]                          ; pc=0x0064
    addiSigned x4, x17, -28                             ; pc=0x0068
    add x11, x4, x0                                     ; pc=0x006C
    jal x1, analizar_sensor                             ; pc=0x0070
    add x5, x11, x0                                     ; pc=0x0074
    add x3, x5, x0 ; promote t9__x3                     ; pc=0x0078
    add x11, x3, x0                                     ; pc=0x007C
    jal x0, .L_ir_1_main_end                            ; pc=0x0080
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0084
    addi x2, x2, 40                                     ; pc=0x0088
    freeze                                              ; pc=0x008C

analizar_sensor:
    ; prologue
    addiSigned x2, x2, -72                              ; pc=0x0090
    sw x1, 0(x2)                                        ; pc=0x0094
    sw x17, 4(x2)                                       ; pc=0x0098
    addi x17, x2, 72                                    ; pc=0x009C

    sw x11, -4(x17) ; parametro datos                   ; pc=0x00A0

    addi x5, x0, 0                                      ; pc=0x00A4
    add x3, x5, x0 ; promote i                          ; pc=0x00A8
    addi x6, x0, 0                                      ; pc=0x00AC
    add x4, x6, x0 ; promote total                      ; pc=0x00B0
L_while_start_0:
    addi x7, x0, 7                                      ; pc=0x00B4
    addi x8, x0, 0                                      ; pc=0x00B8
    blt x3, x7, .L_ir_3_ir_cmp_true                     ; pc=0x00BC
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x00C0
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x00C4
.L_ir_4_ir_cmp_end:
    sw x8, -36(x17) ; t0__x3                            ; pc=0x00C8
    lw x9, -36(x17) ; t0__x3                            ; pc=0x00CC
    beq x9, x0, L_while_end_1                           ; pc=0x00D0
    add x10, x3, x3                                     ; pc=0x00D4
    add x10, x10, x10                                   ; pc=0x00D8
    lw x5, -4(x17) ; base ref datos                     ; pc=0x00DC
    add x5, x5, x10                                     ; pc=0x00E0
    lw x6, 0(x5)                                        ; pc=0x00E4
    sw x6, -40(x17) ; t1__x4                            ; pc=0x00E8
    lw x8, -40(x17) ; t1__x4                            ; pc=0x00EC
    sw x8, -16(x17) ; lectura                           ; pc=0x00F0
    lw x7, -16(x17) ; lectura                           ; pc=0x00F4
    addi x9, x0, 2                                      ; pc=0x00F8
    mul x10, x7, x9                                     ; pc=0x00FC
    sw x10, -24(x17) ; promedio                         ; pc=0x0100
    lw x5, -24(x17) ; promedio                          ; pc=0x0104
    addi x6, x0, 10                                     ; pc=0x0108
    add x8, x5, x6                                      ; pc=0x010C
    sw x8, -28(x17) ; ajuste                            ; pc=0x0110
    lw x10, -28(x17) ; ajuste                           ; pc=0x0114
    addi x9, x0, 3                                      ; pc=0x0118
    mul x7, x10, x9                                     ; pc=0x011C
    sw x7, -32(x17) ; resultado                         ; pc=0x0120
    lw x8, -16(x17) ; lectura                           ; pc=0x0124
    addi x6, x0, 50                                     ; pc=0x0128
    addi x5, x0, 0                                      ; pc=0x012C
    blt x6, x8, .L_ir_5_ir_cmp_true                     ; pc=0x0130
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x0134
.L_ir_5_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0138
.L_ir_6_ir_cmp_end:
    sw x5, -56(x17) ; t6__x8                            ; pc=0x013C
    lw x8, -56(x17) ; t6__x8                            ; pc=0x0140
    beq x8, x0, L_else_2                                ; pc=0x0144
    lw x7, -32(x17) ; resultado                         ; pc=0x0148
    add x9, x4, x7                                      ; pc=0x014C
    add x4, x9, x0 ; promote total                      ; pc=0x0150
    jal x0, L_end_if_3                                  ; pc=0x0154
L_else_2:
L_end_if_3:
    addi x10, x0, 1                                     ; pc=0x0158
    add x5, x3, x10                                     ; pc=0x015C
    add x3, x5, x0 ; promote i                          ; pc=0x0160
    jal x0, L_while_start_0                             ; pc=0x0164
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x0168
    jal x0, .L_ir_2_analizar_sensor_end                 ; pc=0x016C
.L_ir_2_analizar_sensor_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0170
    lw x17, 4(x2)                                       ; pc=0x0174
    addi x2, x2, 72                                     ; pc=0x0178
    jalr x1, 0                                          ; pc=0x017C