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
;   .L_ir_3_ir_cmp_true = 0x0150
;   .L_ir_4_ir_cmp_end = 0x0154
;   L_for_start_2 = 0x0168
;   .L_ir_5_ir_cmp_true = 0x0178
;   .L_ir_6_ir_cmp_end = 0x017C
;   L_for_end_3 = 0x02D0
;   L_for_end_1 = 0x02E4
;   .L_ir_2_procesar_bloques_end = 0x02EC

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00F8 jal -> procesar_bloques (addr=0x0118, offset=32)
;   pc=0x0108 jal -> .L_ir_1_main_end (addr=0x010C, offset=4)
;   pc=0x0148 blt -> .L_ir_3_ir_cmp_true (addr=0x0150, offset=8)
;   pc=0x014C jal -> .L_ir_4_ir_cmp_end (addr=0x0154, offset=8)
;   pc=0x015C beq -> L_for_end_1 (addr=0x02E4, offset=392)
;   pc=0x0170 blt -> .L_ir_5_ir_cmp_true (addr=0x0178, offset=8)
;   pc=0x0174 jal -> .L_ir_6_ir_cmp_end (addr=0x017C, offset=8)
;   pc=0x0184 beq -> L_for_end_3 (addr=0x02D0, offset=332)
;   pc=0x02CC jal -> L_for_start_2 (addr=0x0168, offset=-356)
;   pc=0x02E0 jal -> L_for_start_0 (addr=0x013C, offset=-420)
;   pc=0x02E8 jal -> .L_ir_2_procesar_bloques_end (addr=0x02EC, offset=4)

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
    addiSigned x2, x2, -108                             ; pc=0x0118
    sw x1, 0(x2)                                        ; pc=0x011C
    sw x17, 4(x2)                                       ; pc=0x0120
    addi x17, x2, 108                                   ; pc=0x0124

    sw x11, -4(x17) ; parametro bloques                 ; pc=0x0128

    addi x5, x0, 0                                      ; pc=0x012C
    add x3, x5, x0 ; promote total                      ; pc=0x0130
    addi x6, x0, 0                                      ; pc=0x0134
    sw x6, -12(x17) ; b                                 ; pc=0x0138
L_for_start_0:
    lw x7, -12(x17) ; b                                 ; pc=0x013C
    addi x8, x0, 3                                      ; pc=0x0140
    addi x9, x0, 0                                      ; pc=0x0144
    blt x7, x8, 8                                       ; pc=0x0148 ; target=.L_ir_3_ir_cmp_true ; addr=0x0150
    jal x0, 8                                           ; pc=0x014C ; target=.L_ir_4_ir_cmp_end ; addr=0x0154
.L_ir_3_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0150
.L_ir_4_ir_cmp_end:
    sw x9, -20(x17) ; t0                                ; pc=0x0154
    lw x10, -20(x17) ; t0                               ; pc=0x0158
    beq x10, x0, 392                                    ; pc=0x015C ; target=L_for_end_1 ; addr=0x02E4
    addi x5, x0, 0                                      ; pc=0x0160
    add x4, x5, x0 ; promote i                          ; pc=0x0164
L_for_start_2:
    addi x6, x0, 8                                      ; pc=0x0168
    addi x9, x0, 0                                      ; pc=0x016C
    blt x4, x6, 8                                       ; pc=0x0170 ; target=.L_ir_5_ir_cmp_true ; addr=0x0178
    jal x0, 8                                           ; pc=0x0174 ; target=.L_ir_6_ir_cmp_end ; addr=0x017C
.L_ir_5_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0178
.L_ir_6_ir_cmp_end:
    sw x9, -24(x17) ; t10                               ; pc=0x017C
    lw x8, -24(x17) ; t10                               ; pc=0x0180
    beq x8, x0, 332                                     ; pc=0x0184 ; target=L_for_end_3 ; addr=0x02D0
    lw x7, -12(x17) ; b                                 ; pc=0x0188
    addi x10, x0, 8                                     ; pc=0x018C
    mul x5, x7, x10                                     ; pc=0x0190
    sw x5, -28(x17) ; t11                               ; pc=0x0194
    lw x9, -28(x17) ; t11                               ; pc=0x0198
    add x6, x9, x4                                      ; pc=0x019C
    sw x6, -32(x17) ; t12                               ; pc=0x01A0
    lw x8, -32(x17) ; t12                               ; pc=0x01A4
    add x5, x8, x8                                      ; pc=0x01A8
    add x5, x5, x5                                      ; pc=0x01AC
    lw x10, -4(x17) ; base ref bloques                  ; pc=0x01B0
    add x10, x10, x5                                    ; pc=0x01B4
    lw x7, 0(x10)                                       ; pc=0x01B8
    sw x7, -36(x17) ; t13                               ; pc=0x01BC
    lw x6, -36(x17) ; t13                               ; pc=0x01C0
    addi x9, x0, 2                                      ; pc=0x01C4
    mul x5, x6, x9                                      ; pc=0x01C8
    sw x5, -40(x17) ; t14                               ; pc=0x01CC
    lw x8, -40(x17) ; t14                               ; pc=0x01D0
    add x10, x3, x8                                     ; pc=0x01D4
    add x3, x10, x0 ; promote total                     ; pc=0x01D8
    lw x7, -28(x17) ; t11                               ; pc=0x01DC
    addi x5, x0, 1                                      ; pc=0x01E0
    add x9, x4, x5                                      ; pc=0x01E4
    add x6, x7, x9                                      ; pc=0x01E8
    sw x6, -48(x17) ; t16                               ; pc=0x01EC
    lw x10, -48(x17) ; t16                              ; pc=0x01F0
    add x8, x10, x10                                    ; pc=0x01F4
    add x8, x8, x8                                      ; pc=0x01F8
    lw x5, -4(x17) ; base ref bloques                   ; pc=0x01FC
    add x5, x5, x8                                      ; pc=0x0200
    lw x6, 0(x5)                                        ; pc=0x0204
    sw x6, -52(x17) ; t17                               ; pc=0x0208
    lw x9, -52(x17) ; t17                               ; pc=0x020C
    addi x7, x0, 2                                      ; pc=0x0210
    mul x8, x9, x7                                      ; pc=0x0214
    sw x8, -56(x17) ; t18                               ; pc=0x0218
    lw x10, -56(x17) ; t18                              ; pc=0x021C
    add x5, x3, x10                                     ; pc=0x0220
    add x3, x5, x0 ; promote total                      ; pc=0x0224
    lw x6, -28(x17) ; t11                               ; pc=0x0228
    addi x8, x0, 2                                      ; pc=0x022C
    add x7, x4, x8                                      ; pc=0x0230
    add x9, x6, x7                                      ; pc=0x0234
    sw x9, -64(x17) ; t20                               ; pc=0x0238
    lw x5, -64(x17) ; t20                               ; pc=0x023C
    add x10, x5, x5                                     ; pc=0x0240
    add x10, x10, x10                                   ; pc=0x0244
    lw x8, -4(x17) ; base ref bloques                   ; pc=0x0248
    add x8, x8, x10                                     ; pc=0x024C
    lw x9, 0(x8)                                        ; pc=0x0250
    sw x9, -68(x17) ; t21                               ; pc=0x0254
    lw x7, -68(x17) ; t21                               ; pc=0x0258
    addi x6, x0, 2                                      ; pc=0x025C
    mul x10, x7, x6                                     ; pc=0x0260
    sw x10, -72(x17) ; t22                              ; pc=0x0264
    lw x5, -72(x17) ; t22                               ; pc=0x0268
    add x8, x3, x5                                      ; pc=0x026C
    add x3, x8, x0 ; promote total                      ; pc=0x0270
    lw x9, -28(x17) ; t11                               ; pc=0x0274
    addi x10, x0, 3                                     ; pc=0x0278
    add x6, x4, x10                                     ; pc=0x027C
    add x7, x9, x6                                      ; pc=0x0280
    sw x7, -80(x17) ; t24                               ; pc=0x0284
    lw x8, -80(x17) ; t24                               ; pc=0x0288
    add x5, x8, x8                                      ; pc=0x028C
    add x5, x5, x5                                      ; pc=0x0290
    lw x10, -4(x17) ; base ref bloques                  ; pc=0x0294
    add x10, x10, x5                                    ; pc=0x0298
    lw x7, 0(x10)                                       ; pc=0x029C
    sw x7, -84(x17) ; t25                               ; pc=0x02A0
    lw x6, -84(x17) ; t25                               ; pc=0x02A4
    addi x9, x0, 2                                      ; pc=0x02A8
    mul x5, x6, x9                                      ; pc=0x02AC
    sw x5, -88(x17) ; t26                               ; pc=0x02B0
    lw x8, -88(x17) ; t26                               ; pc=0x02B4
    add x10, x3, x8                                     ; pc=0x02B8
    add x3, x10, x0 ; promote total                     ; pc=0x02BC
    addi x7, x0, 4                                      ; pc=0x02C0
    add x5, x4, x7                                      ; pc=0x02C4
    add x4, x5, x0 ; promote i                          ; pc=0x02C8
    jal x0, -356                                        ; pc=0x02CC ; target=L_for_start_2 ; addr=0x0168
L_for_end_3:
    lw x9, -12(x17) ; b                                 ; pc=0x02D0
    addi x6, x0, 1                                      ; pc=0x02D4
    add x10, x9, x6                                     ; pc=0x02D8
    sw x10, -12(x17) ; b                                ; pc=0x02DC
    jal x0, -420                                        ; pc=0x02E0 ; target=L_for_start_0 ; addr=0x013C
L_for_end_1:
    add x11, x3, x0                                     ; pc=0x02E4
    jal x0, 4                                           ; pc=0x02E8 ; target=.L_ir_2_procesar_bloques_end ; addr=0x02EC
.L_ir_2_procesar_bloques_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x02EC
    lw x17, 4(x2)                                       ; pc=0x02F0
    addi x2, x2, 108                                    ; pc=0x02F4
    jalr x1, 0                                          ; pc=0x02F8