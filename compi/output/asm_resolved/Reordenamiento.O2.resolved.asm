; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0084
;   analizar_sensor = 0x0090
;   L_while_start_0 = 0x00B4
;   .L_ir_3_ir_cmp_true = 0x00C4
;   .L_ir_4_ir_cmp_end = 0x00C8
;   .L_ir_5_ir_cmp_true = 0x011C
;   .L_ir_6_ir_cmp_end = 0x0120
;   L_else_2 = 0x016C
;   L_end_if_3 = 0x016C
;   L_while_end_1 = 0x017C
;   .L_ir_2_analizar_sensor_end = 0x0184

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0070 jal -> analizar_sensor (addr=0x0090, offset=32)
;   pc=0x0080 jal -> .L_ir_1_main_end (addr=0x0084, offset=4)
;   pc=0x00BC blt -> .L_ir_3_ir_cmp_true (addr=0x00C4, offset=8)
;   pc=0x00C0 jal -> .L_ir_4_ir_cmp_end (addr=0x00C8, offset=8)
;   pc=0x00D0 beq -> L_while_end_1 (addr=0x017C, offset=172)
;   pc=0x0114 blt -> .L_ir_5_ir_cmp_true (addr=0x011C, offset=8)
;   pc=0x0118 jal -> .L_ir_6_ir_cmp_end (addr=0x0120, offset=8)
;   pc=0x0128 beq -> L_else_2 (addr=0x016C, offset=68)
;   pc=0x0168 jal -> L_end_if_3 (addr=0x016C, offset=4)
;   pc=0x0178 jal -> L_while_start_0 (addr=0x00B4, offset=-196)
;   pc=0x0180 jal -> .L_ir_2_analizar_sensor_end (addr=0x0184, offset=4)

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
    jal x1, 32                                          ; pc=0x0070 ; target=analizar_sensor ; addr=0x0090
    add x5, x11, x0                                     ; pc=0x0074
    add x3, x5, x0 ; promote t9                         ; pc=0x0078
    add x11, x3, x0                                     ; pc=0x007C
    jal x0, 4                                           ; pc=0x0080 ; target=.L_ir_1_main_end ; addr=0x0084
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0084
    addi x2, x2, 40                                     ; pc=0x0088
    freeze                                              ; pc=0x008C

analizar_sensor:
    ; prologue
    addiSigned x2, x2, -76                              ; pc=0x0090
    sw x1, 0(x2)                                        ; pc=0x0094
    sw x17, 4(x2)                                       ; pc=0x0098
    addi x17, x2, 76                                    ; pc=0x009C

    sw x11, -4(x17) ; parametro datos                   ; pc=0x00A0

    addi x5, x0, 0                                      ; pc=0x00A4
    add x3, x5, x0 ; promote i                          ; pc=0x00A8
    addi x6, x0, 0                                      ; pc=0x00AC
    add x4, x6, x0 ; promote total                      ; pc=0x00B0
L_while_start_0:
    addi x7, x0, 7                                      ; pc=0x00B4
    addi x8, x0, 0                                      ; pc=0x00B8
    blt x3, x7, 8                                       ; pc=0x00BC ; target=.L_ir_3_ir_cmp_true ; addr=0x00C4
    jal x0, 8                                           ; pc=0x00C0 ; target=.L_ir_4_ir_cmp_end ; addr=0x00C8
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x00C4
.L_ir_4_ir_cmp_end:
    sw x8, -36(x17) ; t0                                ; pc=0x00C8
    lw x9, -36(x17) ; t0                                ; pc=0x00CC
    beq x9, x0, 172                                     ; pc=0x00D0 ; target=L_while_end_1 ; addr=0x017C
    add x10, x3, x3                                     ; pc=0x00D4
    add x10, x10, x10                                   ; pc=0x00D8
    lw x5, -4(x17) ; base ref datos                     ; pc=0x00DC
    add x5, x5, x10                                     ; pc=0x00E0
    lw x6, 0(x5)                                        ; pc=0x00E4
    sw x6, -40(x17) ; t1                                ; pc=0x00E8
    addi x8, x0, 100                                    ; pc=0x00EC
    mul x7, x3, x8                                      ; pc=0x00F0
    sw x7, -44(x17) ; t2                                ; pc=0x00F4
    lw x9, -40(x17) ; t1                                ; pc=0x00F8
    sw x9, -16(x17) ; lectura                           ; pc=0x00FC
    lw x10, -44(x17) ; t2                               ; pc=0x0100
    sw x10, -20(x17) ; log                              ; pc=0x0104
    lw x5, -16(x17) ; lectura                           ; pc=0x0108
    addi x6, x0, 50                                     ; pc=0x010C
    addi x7, x0, 0                                      ; pc=0x0110
    blt x6, x5, 8                                       ; pc=0x0114 ; target=.L_ir_5_ir_cmp_true ; addr=0x011C
    jal x0, 8                                           ; pc=0x0118 ; target=.L_ir_6_ir_cmp_end ; addr=0x0120
.L_ir_5_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x011C
.L_ir_6_ir_cmp_end:
    sw x7, -48(x17) ; t6                                ; pc=0x0120
    lw x8, -48(x17) ; t6                                ; pc=0x0124
    beq x8, x0, 68                                      ; pc=0x0128 ; target=L_else_2 ; addr=0x016C
    lw x9, -16(x17) ; lectura                           ; pc=0x012C
    addi x10, x0, 2                                     ; pc=0x0130
    mul x7, x9, x10                                     ; pc=0x0134
    sw x7, -24(x17) ; promedio                          ; pc=0x0138
    lw x6, -24(x17) ; promedio                          ; pc=0x013C
    addi x5, x0, 10                                     ; pc=0x0140
    add x8, x6, x5                                      ; pc=0x0144
    sw x8, -28(x17) ; ajuste                            ; pc=0x0148
    lw x7, -28(x17) ; ajuste                            ; pc=0x014C
    addi x10, x0, 3                                     ; pc=0x0150
    mul x9, x7, x10                                     ; pc=0x0154
    sw x9, -32(x17) ; resultado                         ; pc=0x0158
    lw x8, -32(x17) ; resultado                         ; pc=0x015C
    add x5, x4, x8                                      ; pc=0x0160
    add x4, x5, x0 ; promote total                      ; pc=0x0164
    jal x0, 4                                           ; pc=0x0168 ; target=L_end_if_3 ; addr=0x016C
L_else_2:
L_end_if_3:
    addi x6, x0, 1                                      ; pc=0x016C
    add x9, x3, x6                                      ; pc=0x0170
    add x3, x9, x0 ; promote i                          ; pc=0x0174
    jal x0, -196                                        ; pc=0x0178 ; target=L_while_start_0 ; addr=0x00B4
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x017C
    jal x0, 4                                           ; pc=0x0180 ; target=.L_ir_2_analizar_sensor_end ; addr=0x0184
.L_ir_2_analizar_sensor_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0184
    lw x17, 4(x2)                                       ; pc=0x0188
    addi x2, x2, 76                                     ; pc=0x018C
    jalr x1, 0                                          ; pc=0x0190