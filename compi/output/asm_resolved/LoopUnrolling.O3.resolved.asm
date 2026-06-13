; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0094
;   procesar_bloques = 0x00A0
;   L_for_start_0 = 0x00C4
;   .L_ir_3_ir_cmp_true = 0x00D4
;   .L_ir_4_ir_cmp_end = 0x00D8
;   L_for_start_2 = 0x00EC
;   .L_ir_5_ir_cmp_true = 0x0100
;   .L_ir_6_ir_cmp_end = 0x0104
;   L_for_end_3 = 0x0194
;   L_for_end_1 = 0x01E4
;   .L_ir_2_procesar_bloques_end = 0x01EC

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0080 jal -> procesar_bloques (addr=0x00A0, offset=32)
;   pc=0x0090 jal -> .L_ir_1_main_end (addr=0x0094, offset=4)
;   pc=0x00CC blt -> .L_ir_3_ir_cmp_true (addr=0x00D4, offset=8)
;   pc=0x00D0 jal -> .L_ir_4_ir_cmp_end (addr=0x00D8, offset=8)
;   pc=0x00E0 beq -> L_for_end_1 (addr=0x01E4, offset=260)
;   pc=0x00F8 blt -> .L_ir_5_ir_cmp_true (addr=0x0100, offset=8)
;   pc=0x00FC jal -> .L_ir_6_ir_cmp_end (addr=0x0104, offset=8)
;   pc=0x010C beq -> L_for_end_3 (addr=0x0194, offset=136)
;   pc=0x0190 jal -> L_for_start_2 (addr=0x00EC, offset=-164)
;   pc=0x01E0 jal -> L_for_start_0 (addr=0x00C4, offset=-284)
;   pc=0x01E8 jal -> .L_ir_2_procesar_bloques_end (addr=0x01EC, offset=4)

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
    jal x1, 32                                          ; pc=0x0080 ; target=procesar_bloques ; addr=0x00A0
    add x8, x11, x0                                     ; pc=0x0084
    add x3, x8, x0 ; promote t9__x8                     ; pc=0x0088
    add x11, x3, x0                                     ; pc=0x008C
    jal x0, 4                                           ; pc=0x0090 ; target=.L_ir_1_main_end ; addr=0x0094
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0094
    addi x2, x2, 48                                     ; pc=0x0098
    freeze                                              ; pc=0x009C

procesar_bloques:
    ; prologue
    addiSigned x2, x2, -80                              ; pc=0x00A0
    sw x1, 0(x2)                                        ; pc=0x00A4
    sw x17, 4(x2)                                       ; pc=0x00A8
    addi x17, x2, 80                                    ; pc=0x00AC

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x00B0

    addi x5, x0, 0                                      ; pc=0x00B4
    add x3, x5, x0 ; promote total                      ; pc=0x00B8
    addi x6, x0, 0                                      ; pc=0x00BC
    add x4, x6, x0 ; promote b                          ; pc=0x00C0
L_for_start_0:
    addi x7, x0, 3                                      ; pc=0x00C4
    addi x8, x0, 0                                      ; pc=0x00C8
    blt x4, x7, 8                                       ; pc=0x00CC ; target=.L_ir_3_ir_cmp_true ; addr=0x00D4
    jal x0, 8                                           ; pc=0x00D0 ; target=.L_ir_4_ir_cmp_end ; addr=0x00D8
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x00D4
.L_ir_4_ir_cmp_end:
    sw x8, -20(x17) ; t0__x3                            ; pc=0x00D8
    lw x9, -20(x17) ; t0__x3                            ; pc=0x00DC
    beq x9, x0, 260                                     ; pc=0x00E0 ; target=L_for_end_1 ; addr=0x01E4
    addi x10, x0, 0                                     ; pc=0x00E4
    sw x10, -16(x17) ; i                                ; pc=0x00E8
L_for_start_2:
    lw x5, -16(x17) ; i                                 ; pc=0x00EC
    addi x6, x0, 2                                      ; pc=0x00F0
    addi x8, x0, 0                                      ; pc=0x00F4
    blt x5, x6, 8                                       ; pc=0x00F8 ; target=.L_ir_5_ir_cmp_true ; addr=0x0100
    jal x0, 8                                           ; pc=0x00FC ; target=.L_ir_6_ir_cmp_end ; addr=0x0104
.L_ir_5_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0100
.L_ir_6_ir_cmp_end:
    sw x8, -24(x17) ; t10__x4                           ; pc=0x0104
    lw x7, -24(x17) ; t10__x4                           ; pc=0x0108
    beq x7, x0, 136                                     ; pc=0x010C ; target=L_for_end_3 ; addr=0x0194
    lw x9, -28(x17) ; t3                                ; pc=0x0110
    add x10, x9, x9                                     ; pc=0x0114
    add x10, x10, x10                                   ; pc=0x0118
    lw x8, -4(x17) ; base ref bloques                   ; pc=0x011C
    add x8, x8, x10                                     ; pc=0x0120
    lw x6, 0(x8)                                        ; pc=0x0124
    sw x6, -32(x17) ; t13__x5                           ; pc=0x0128
    lw x5, -28(x17) ; t3                                ; pc=0x012C
    add x7, x5, x5                                      ; pc=0x0130
    add x7, x7, x7                                      ; pc=0x0134
    lw x10, -4(x17) ; base ref bloques                  ; pc=0x0138
    add x10, x10, x7                                    ; pc=0x013C
    lw x9, 0(x10)                                       ; pc=0x0140
    sw x9, -36(x17) ; t18__x8                           ; pc=0x0144
    lw x5, -32(x17) ; t13__x5                           ; pc=0x0148
    addi x8, x0, 2                                      ; pc=0x014C
    mul x6, x5, x8                                      ; pc=0x0150
    sw x6, -40(x17) ; t14__x6                           ; pc=0x0154
    lw x6, -40(x17) ; t14__x6                           ; pc=0x0158
    add x7, x3, x6                                      ; pc=0x015C
    add x3, x7, x0 ; promote total                      ; pc=0x0160
    lw x8, -36(x17) ; t18__x8                           ; pc=0x0164
    addi x10, x0, 2                                     ; pc=0x0168
    mul x9, x8, x10                                     ; pc=0x016C
    sw x9, -48(x17) ; t19__x9                           ; pc=0x0170
    lw x9, -48(x17) ; t19__x9                           ; pc=0x0174
    add x5, x3, x9                                      ; pc=0x0178
    add x3, x5, x0 ; promote total                      ; pc=0x017C
    lw x7, -16(x17) ; i                                 ; pc=0x0180
    addi x6, x0, 2                                      ; pc=0x0184
    add x10, x7, x6                                     ; pc=0x0188
    sw x10, -16(x17) ; i                                ; pc=0x018C
    jal x0, -164                                        ; pc=0x0190 ; target=L_for_start_2 ; addr=0x00EC
L_for_end_3:
    lw x8, -28(x17) ; t3                                ; pc=0x0194
    add x5, x8, x8                                      ; pc=0x0198
    add x5, x5, x5                                      ; pc=0x019C
    lw x9, -4(x17) ; base ref bloques                   ; pc=0x01A0
    add x9, x9, x5                                      ; pc=0x01A4
    lw x10, 0(x9)                                       ; pc=0x01A8
    sw x10, -60(x17) ; t24__x4                          ; pc=0x01AC
    addi x6, x0, 1                                      ; pc=0x01B0
    add x7, x4, x6                                      ; pc=0x01B4
    sw x7, -64(x17) ; t8__x7                            ; pc=0x01B8
    lw x5, -60(x17) ; t24__x4                           ; pc=0x01BC
    addi x8, x0, 2                                      ; pc=0x01C0
    mul x9, x5, x8                                      ; pc=0x01C4
    sw x9, -68(x17) ; t25__x5                           ; pc=0x01C8
    lw x5, -68(x17) ; t25__x5                           ; pc=0x01CC
    add x10, x3, x5                                     ; pc=0x01D0
    add x3, x10, x0 ; promote total                     ; pc=0x01D4
    lw x7, -64(x17) ; t8__x7                            ; pc=0x01D8
    add x4, x7, x0 ; promote b                          ; pc=0x01DC
    jal x0, -284                                        ; pc=0x01E0 ; target=L_for_start_0 ; addr=0x00C4
L_for_end_1:
    add x11, x3, x0                                     ; pc=0x01E4
    jal x0, 4                                           ; pc=0x01E8 ; target=.L_ir_2_procesar_bloques_end ; addr=0x01EC
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x01EC
    lw x17, 4(x2)                                       ; pc=0x01F0
    addi x2, x2, 80                                     ; pc=0x01F4
    jalr x1, 0                                          ; pc=0x01F8