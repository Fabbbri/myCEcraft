; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x008C
;   maximo_lista = 0x0098
;   L_for_start_0 = 0x00F4
;   .L_ir_3_ir_cmp_true = 0x0114
;   .L_ir_4_ir_cmp_end = 0x0118
;   .L_ir_5_ir_cmp_true = 0x0154
;   .L_ir_6_ir_cmp_end = 0x0158
;   L_else_2 = 0x0180
;   L_end_if_3 = 0x0180
;   L_for_end_1 = 0x0190
;   .L_ir_2_maximo_lista_end = 0x0198

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0078 jal -> maximo_lista (addr=0x0098, offset=32)
;   pc=0x0088 jal -> .L_ir_1_main_end (addr=0x008C, offset=4)
;   pc=0x010C blt -> .L_ir_3_ir_cmp_true (addr=0x0114, offset=8)
;   pc=0x0110 jal -> .L_ir_4_ir_cmp_end (addr=0x0118, offset=8)
;   pc=0x0120 beq -> L_for_end_1 (addr=0x0190, offset=112)
;   pc=0x014C blt -> .L_ir_5_ir_cmp_true (addr=0x0154, offset=8)
;   pc=0x0150 jal -> .L_ir_6_ir_cmp_end (addr=0x0158, offset=8)
;   pc=0x0170 beq -> L_else_2 (addr=0x0180, offset=16)
;   pc=0x017C jal -> L_end_if_3 (addr=0x0180, offset=4)
;   pc=0x018C jal -> L_for_start_0 (addr=0x00F4, offset=-152)
;   pc=0x0194 jal -> .L_ir_2_maximo_lista_end (addr=0x0198, offset=4)

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

    addi x4, x0, 3                                      ; pc=0x0030
    sw x4, -28(x17) ; lista[0]                          ; pc=0x0034
    addi x5, x0, 4                                      ; pc=0x0038
    sw x5, -24(x17) ; lista[1]                          ; pc=0x003C
    addi x6, x0, 5                                      ; pc=0x0040
    sw x6, -20(x17) ; lista[2]                          ; pc=0x0044
    addi x7, x0, 24                                     ; pc=0x0048
    sw x7, -16(x17) ; lista[3]                          ; pc=0x004C
    addi x8, x0, 5                                      ; pc=0x0050
    sw x8, -12(x17) ; lista[4]                          ; pc=0x0054
    addi x9, x0, 65                                     ; pc=0x0058
    sw x9, -8(x17) ; lista[5]                           ; pc=0x005C
    addi x10, x0, 46                                    ; pc=0x0060
    sw x10, -4(x17) ; lista[6]                          ; pc=0x0064
    addiSigned x4, x17, -28                             ; pc=0x0068
    add x11, x4, x0                                     ; pc=0x006C
    addi x5, x0, 7                                      ; pc=0x0070
    add x12, x5, x0                                     ; pc=0x0074
    jal x1, 32                                          ; pc=0x0078 ; target=maximo_lista ; addr=0x0098
    add x6, x11, x0                                     ; pc=0x007C
    add x3, x6, x0 ; promote t7                         ; pc=0x0080
    add x11, x3, x0                                     ; pc=0x0084
    jal x0, 4                                           ; pc=0x0088 ; target=.L_ir_1_main_end ; addr=0x008C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x008C
    addi x2, x2, 40                                     ; pc=0x0090
    freeze                                              ; pc=0x0094

maximo_lista:
    ; prologue
    addiSigned x2, x2, -64                              ; pc=0x0098
    sw x1, 0(x2)                                        ; pc=0x009C
    sw x17, 4(x2)                                       ; pc=0x00A0
    addi x17, x2, 64                                    ; pc=0x00A4

    sw x11, -4(x17) ; parametro lista                   ; pc=0x00A8
    sw x12, -8(x17) ; parametro largo                   ; pc=0x00AC

    addi x5, x0, 0                                      ; pc=0x00B0
    add x6, x5, x5                                      ; pc=0x00B4
    add x6, x6, x6                                      ; pc=0x00B8
    lw x7, -4(x17) ; base ref lista                     ; pc=0x00BC
    add x7, x7, x6                                      ; pc=0x00C0
    lw x8, 0(x7)                                        ; pc=0x00C4
    sw x8, -32(x17) ; t0                                ; pc=0x00C8
    lw x9, -32(x17) ; t0                                ; pc=0x00CC
    add x4, x9, x0 ; promote maximo                     ; pc=0x00D0
    addi x10, x0, 0                                     ; pc=0x00D4
    sw x10, -16(x17) ; num                              ; pc=0x00D8
    addi x6, x0, 0                                      ; pc=0x00DC
    sw x6, -20(x17) ; esMayor                           ; pc=0x00E0
    lw x5, -8(x17) ; largo                              ; pc=0x00E4
    sw x5, -24(x17) ; limite                            ; pc=0x00E8
    addi x7, x0, 0                                      ; pc=0x00EC
    add x3, x7, x0 ; promote i                          ; pc=0x00F0
L_for_start_0:
    lw x8, -24(x17) ; limite                            ; pc=0x00F4
    addi x9, x0, 0                                      ; pc=0x00F8
    add x10, x8, x9                                     ; pc=0x00FC
    sw x10, -36(x17) ; t1                               ; pc=0x0100
    lw x6, -36(x17) ; t1                                ; pc=0x0104
    addi x5, x0, 0                                      ; pc=0x0108
    blt x3, x6, 8                                       ; pc=0x010C ; target=.L_ir_3_ir_cmp_true ; addr=0x0114
    jal x0, 8                                           ; pc=0x0110 ; target=.L_ir_4_ir_cmp_end ; addr=0x0118
.L_ir_3_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0114
.L_ir_4_ir_cmp_end:
    sw x5, -40(x17) ; t2                                ; pc=0x0118
    lw x7, -40(x17) ; t2                                ; pc=0x011C
    beq x7, x0, 112                                     ; pc=0x0120 ; target=L_for_end_1 ; addr=0x0190
    add x10, x3, x3                                     ; pc=0x0124
    add x10, x10, x10                                   ; pc=0x0128
    lw x9, -4(x17) ; base ref lista                     ; pc=0x012C
    add x9, x9, x10                                     ; pc=0x0130
    lw x8, 0(x9)                                        ; pc=0x0134
    sw x8, -44(x17) ; t3                                ; pc=0x0138
    lw x5, -44(x17) ; t3                                ; pc=0x013C
    sw x5, -16(x17) ; num                               ; pc=0x0140
    lw x6, -16(x17) ; num                               ; pc=0x0144
    addi x7, x0, 0                                      ; pc=0x0148
    blt x4, x6, 8                                       ; pc=0x014C ; target=.L_ir_5_ir_cmp_true ; addr=0x0154
    jal x0, 8                                           ; pc=0x0150 ; target=.L_ir_6_ir_cmp_end ; addr=0x0158
.L_ir_5_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0154
.L_ir_6_ir_cmp_end:
    sw x7, -20(x17) ; esMayor                           ; pc=0x0158
    lw x10, -20(x17) ; esMayor                          ; pc=0x015C
    addi x9, x0, 0                                      ; pc=0x0160
    add x8, x10, x9                                     ; pc=0x0164
    sw x8, -52(x17) ; t5                                ; pc=0x0168
    lw x5, -52(x17) ; t5                                ; pc=0x016C
    beq x5, x0, 16                                      ; pc=0x0170 ; target=L_else_2 ; addr=0x0180
    lw x7, -16(x17) ; num                               ; pc=0x0174
    add x4, x7, x0 ; promote maximo                     ; pc=0x0178
    jal x0, 4                                           ; pc=0x017C ; target=L_end_if_3 ; addr=0x0180
L_else_2:
L_end_if_3:
    addi x6, x0, 1                                      ; pc=0x0180
    add x8, x3, x6                                      ; pc=0x0184
    add x3, x8, x0 ; promote i                          ; pc=0x0188
    jal x0, -152                                        ; pc=0x018C ; target=L_for_start_0 ; addr=0x00F4
L_for_end_1:
    add x11, x4, x0                                     ; pc=0x0190
    jal x0, 4                                           ; pc=0x0194 ; target=.L_ir_2_maximo_lista_end ; addr=0x0198
.L_ir_2_maximo_lista_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0198
    lw x17, 4(x2)                                       ; pc=0x019C
    addi x2, x2, 64                                     ; pc=0x01A0
    jalr x1, 0                                          ; pc=0x01A4