; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x010C
;   procesar_bloques = 0x0118
;   L_for_start_0 = 0x013C
;   .L_ir_3_ir_cmp_true = 0x014C
;   .L_ir_4_ir_cmp_end = 0x0150
;   L_for_start_2 = 0x0164
;   .L_ir_5_ir_cmp_true = 0x0174
;   .L_ir_6_ir_cmp_end = 0x0178
;   L_for_end_3 = 0x01E8
;   L_for_end_1 = 0x01F8
;   .L_ir_2_procesar_bloques_end = 0x0204

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00F8 jal -> procesar_bloques (addr=0x0118, offset=32)
;   pc=0x0108 jal -> .L_ir_1_main_end (addr=0x010C, offset=4)
;   pc=0x0144 blt -> .L_ir_3_ir_cmp_true (addr=0x014C, offset=8)
;   pc=0x0148 jal -> .L_ir_4_ir_cmp_end (addr=0x0150, offset=8)
;   pc=0x0158 beq -> L_for_end_1 (addr=0x01F8, offset=160)
;   pc=0x016C blt -> .L_ir_5_ir_cmp_true (addr=0x0174, offset=8)
;   pc=0x0170 jal -> .L_ir_6_ir_cmp_end (addr=0x0178, offset=8)
;   pc=0x0180 beq -> L_for_end_3 (addr=0x01E8, offset=104)
;   pc=0x01E4 jal -> L_for_start_2 (addr=0x0164, offset=-128)
;   pc=0x01F4 jal -> L_for_start_0 (addr=0x013C, offset=-184)
;   pc=0x0200 jal -> .L_ir_2_procesar_bloques_end (addr=0x0204, offset=4)

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
    addiSigned x2, x2, -108                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 108                                   ; pc=0x002C

    addi x4, x0, 1                                      ; pc=0x0030
    sw x4, -96(x17) ; datos[0]                          ; pc=0x0034
    addi x5, x0, 2                                      ; pc=0x0038
    sw x5, -92(x17) ; datos[1]                          ; pc=0x003C
    addi x6, x0, 3                                      ; pc=0x0040
    sw x6, -88(x17) ; datos[2]                          ; pc=0x0044
    addi x7, x0, 4                                      ; pc=0x0048
    sw x7, -84(x17) ; datos[3]                          ; pc=0x004C
    addi x8, x0, 5                                      ; pc=0x0050
    sw x8, -80(x17) ; datos[4]                          ; pc=0x0054
    addi x9, x0, 6                                      ; pc=0x0058
    sw x9, -76(x17) ; datos[5]                          ; pc=0x005C
    addi x10, x0, 7                                     ; pc=0x0060
    sw x10, -72(x17) ; datos[6]                         ; pc=0x0064
    addi x4, x0, 8                                      ; pc=0x0068
    sw x4, -68(x17) ; datos[7]                          ; pc=0x006C
    addi x5, x0, 9                                      ; pc=0x0070
    sw x5, -64(x17) ; datos[8]                          ; pc=0x0074
    addi x6, x0, 10                                     ; pc=0x0078
    sw x6, -60(x17) ; datos[9]                          ; pc=0x007C
    addi x7, x0, 11                                     ; pc=0x0080
    sw x7, -56(x17) ; datos[10]                         ; pc=0x0084
    addi x8, x0, 12                                     ; pc=0x0088
    sw x8, -52(x17) ; datos[11]                         ; pc=0x008C
    addi x9, x0, 13                                     ; pc=0x0090
    sw x9, -48(x17) ; datos[12]                         ; pc=0x0094
    addi x10, x0, 14                                    ; pc=0x0098
    sw x10, -44(x17) ; datos[13]                        ; pc=0x009C
    addi x4, x0, 15                                     ; pc=0x00A0
    sw x4, -40(x17) ; datos[14]                         ; pc=0x00A4
    addi x5, x0, 16                                     ; pc=0x00A8
    sw x5, -36(x17) ; datos[15]                         ; pc=0x00AC
    addi x6, x0, 17                                     ; pc=0x00B0
    sw x6, -32(x17) ; datos[16]                         ; pc=0x00B4
    addi x7, x0, 18                                     ; pc=0x00B8
    sw x7, -28(x17) ; datos[17]                         ; pc=0x00BC
    addi x8, x0, 19                                     ; pc=0x00C0
    sw x8, -24(x17) ; datos[18]                         ; pc=0x00C4
    addi x9, x0, 20                                     ; pc=0x00C8
    sw x9, -20(x17) ; datos[19]                         ; pc=0x00CC
    addi x10, x0, 21                                    ; pc=0x00D0
    sw x10, -16(x17) ; datos[20]                        ; pc=0x00D4
    addi x4, x0, 22                                     ; pc=0x00D8
    sw x4, -12(x17) ; datos[21]                         ; pc=0x00DC
    addi x5, x0, 23                                     ; pc=0x00E0
    sw x5, -8(x17) ; datos[22]                          ; pc=0x00E4
    addi x6, x0, 24                                     ; pc=0x00E8
    sw x6, -4(x17) ; datos[23]                          ; pc=0x00EC
    addiSigned x7, x17, -96                             ; pc=0x00F0
    add x11, x7, x0                                     ; pc=0x00F4
    jal x1, 32                                          ; pc=0x00F8 ; target=procesar_bloques ; addr=0x0118
    add x8, x11, x0                                     ; pc=0x00FC
    add x3, x8, x0 ; promote t9                         ; pc=0x0100
    add x11, x3, x0                                     ; pc=0x0104
    jal x0, 4                                           ; pc=0x0108 ; target=.L_ir_1_main_end ; addr=0x010C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x010C
    addi x2, x2, 108                                    ; pc=0x0110
    freeze                                              ; pc=0x0114

procesar_bloques:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x0118
    sw x1, 0(x2)                                        ; pc=0x011C
    sw x17, 4(x2)                                       ; pc=0x0120
    addi x17, x2, 60                                    ; pc=0x0124

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x0128

    addi x5, x0, 0                                      ; pc=0x012C
    sw x5, -8(x17) ; total                              ; pc=0x0130
    addi x6, x0, 0                                      ; pc=0x0134
    add x3, x6, x0 ; promote b                          ; pc=0x0138
L_for_start_0:
    addi x7, x0, 3                                      ; pc=0x013C
    addi x8, x0, 0                                      ; pc=0x0140
    blt x3, x7, 8                                       ; pc=0x0144 ; target=.L_ir_3_ir_cmp_true ; addr=0x014C
    jal x0, 8                                           ; pc=0x0148 ; target=.L_ir_4_ir_cmp_end ; addr=0x0150
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x014C
.L_ir_4_ir_cmp_end:
    sw x8, -20(x17) ; t0                                ; pc=0x0150
    lw x9, -20(x17) ; t0                                ; pc=0x0154
    beq x9, x0, 160                                     ; pc=0x0158 ; target=L_for_end_1 ; addr=0x01F8
    addi x10, x0, 0                                     ; pc=0x015C
    add x4, x10, x0 ; promote i                         ; pc=0x0160
L_for_start_2:
    addi x5, x0, 8                                      ; pc=0x0164
    addi x6, x0, 0                                      ; pc=0x0168
    blt x4, x5, 8                                       ; pc=0x016C ; target=.L_ir_5_ir_cmp_true ; addr=0x0174
    jal x0, 8                                           ; pc=0x0170 ; target=.L_ir_6_ir_cmp_end ; addr=0x0178
.L_ir_5_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0174
.L_ir_6_ir_cmp_end:
    sw x6, -24(x17) ; t1                                ; pc=0x0178
    lw x8, -24(x17) ; t1                                ; pc=0x017C
    beq x8, x0, 104                                     ; pc=0x0180 ; target=L_for_end_3 ; addr=0x01E8
    addi x7, x0, 8                                      ; pc=0x0184
    mul x9, x3, x7                                      ; pc=0x0188
    sw x9, -28(x17) ; t2                                ; pc=0x018C
    lw x10, -28(x17) ; t2                               ; pc=0x0190
    add x6, x10, x4                                     ; pc=0x0194
    sw x6, -32(x17) ; t3                                ; pc=0x0198
    lw x5, -32(x17) ; t3                                ; pc=0x019C
    add x8, x5, x5                                      ; pc=0x01A0
    add x8, x8, x8                                      ; pc=0x01A4
    lw x9, -4(x17) ; base ref bloques                   ; pc=0x01A8
    add x9, x9, x8                                      ; pc=0x01AC
    lw x7, 0(x9)                                        ; pc=0x01B0
    sw x7, -36(x17) ; t4                                ; pc=0x01B4
    lw x6, -36(x17) ; t4                                ; pc=0x01B8
    addi x10, x0, 2                                     ; pc=0x01BC
    mul x8, x6, x10                                     ; pc=0x01C0
    sw x8, -40(x17) ; t5                                ; pc=0x01C4
    lw x5, -8(x17) ; total                              ; pc=0x01C8
    lw x9, -40(x17) ; t5                                ; pc=0x01CC
    add x7, x5, x9                                      ; pc=0x01D0
    sw x7, -8(x17) ; total                              ; pc=0x01D4
    addi x8, x0, 1                                      ; pc=0x01D8
    add x10, x4, x8                                     ; pc=0x01DC
    add x4, x10, x0 ; promote i                         ; pc=0x01E0
    jal x0, -128                                        ; pc=0x01E4 ; target=L_for_start_2 ; addr=0x0164
L_for_end_3:
    addi x6, x0, 1                                      ; pc=0x01E8
    add x7, x3, x6                                      ; pc=0x01EC
    add x3, x7, x0 ; promote b                          ; pc=0x01F0
    jal x0, -184                                        ; pc=0x01F4 ; target=L_for_start_0 ; addr=0x013C
L_for_end_1:
    lw x9, -8(x17) ; total                              ; pc=0x01F8
    add x11, x9, x0                                     ; pc=0x01FC
    jal x0, 4                                           ; pc=0x0200 ; target=.L_ir_2_procesar_bloques_end ; addr=0x0204
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0204
    lw x17, 4(x2)                                       ; pc=0x0208
    addi x2, x2, 60                                     ; pc=0x020C
    jalr x1, 0                                          ; pc=0x0210