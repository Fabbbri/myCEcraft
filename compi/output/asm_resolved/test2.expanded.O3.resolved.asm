; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0090
;   maximo_lista = 0x009C
;   L_for_start_0 = 0x0100
;   .L_ir_3_ir_cmp_true = 0x0124
;   .L_ir_4_ir_cmp_end = 0x0128
;   .L_ir_5_ir_cmp_true = 0x016C
;   .L_ir_6_ir_cmp_end = 0x0170
;   L_else_2 = 0x01B8
;   L_end_if_3 = 0x01B8
;   L_for_end_1 = 0x01DC
;   .L_ir_2_maximo_lista_end = 0x01E8

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0078 jal -> maximo_lista (addr=0x009C, offset=36)
;   pc=0x008C jal -> .L_ir_1_main_end (addr=0x0090, offset=4)
;   pc=0x011C blt -> .L_ir_3_ir_cmp_true (addr=0x0124, offset=8)
;   pc=0x0120 jal -> .L_ir_4_ir_cmp_end (addr=0x0128, offset=8)
;   pc=0x0130 beq -> L_for_end_1 (addr=0x01DC, offset=172)
;   pc=0x0164 blt -> .L_ir_5_ir_cmp_true (addr=0x016C, offset=8)
;   pc=0x0168 jal -> .L_ir_6_ir_cmp_end (addr=0x0170, offset=8)
;   pc=0x01A0 beq -> L_else_2 (addr=0x01B8, offset=24)
;   pc=0x01B4 jal -> L_end_if_3 (addr=0x01B8, offset=4)
;   pc=0x01D8 jal -> L_for_start_0 (addr=0x0100, offset=-216)
;   pc=0x01E4 jal -> .L_ir_2_maximo_lista_end (addr=0x01E8, offset=4)

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

    addi x3, x0, 3                                      ; pc=0x0030
    sw x3, -28(x17) ; lista[0]                          ; pc=0x0034
    addi x4, x0, 4                                      ; pc=0x0038
    sw x4, -24(x17) ; lista[1]                          ; pc=0x003C
    addi x5, x0, 5                                      ; pc=0x0040
    sw x5, -20(x17) ; lista[2]                          ; pc=0x0044
    addi x6, x0, 24                                     ; pc=0x0048
    sw x6, -16(x17) ; lista[3]                          ; pc=0x004C
    addi x7, x0, 5                                      ; pc=0x0050
    sw x7, -12(x17) ; lista[4]                          ; pc=0x0054
    addi x8, x0, 65                                     ; pc=0x0058
    sw x8, -8(x17) ; lista[5]                           ; pc=0x005C
    addi x9, x0, 46                                     ; pc=0x0060
    sw x9, -4(x17) ; lista[6]                           ; pc=0x0064
    addiSigned x10, x17, -28                            ; pc=0x0068
    add x11, x10, x0                                    ; pc=0x006C
    addi x3, x0, 7                                      ; pc=0x0070
    add x12, x3, x0                                     ; pc=0x0074
    jal x1, 36                                          ; pc=0x0078 ; target=maximo_lista ; addr=0x009C
    add x9, x11, x0                                     ; pc=0x007C
    sw x9, -32(x17) ; t7__x9                            ; pc=0x0080
    lw x9, -32(x17) ; t7__x9                            ; pc=0x0084
    add x11, x9, x0                                     ; pc=0x0088
    jal x0, 4                                           ; pc=0x008C ; target=.L_ir_1_main_end ; addr=0x0090
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0090
    addi x2, x2, 40                                     ; pc=0x0094
    freeze                                              ; pc=0x0098

maximo_lista:
    ; prologue
    addiSigned x2, x2, -92                              ; pc=0x009C
    sw x1, 0(x2)                                        ; pc=0x00A0
    sw x17, 4(x2)                                       ; pc=0x00A4
    addi x17, x2, 92                                    ; pc=0x00A8

    sw x11, -4(x17) ; parametro lista                   ; pc=0x00AC
    sw x12, -8(x17) ; parametro largo                   ; pc=0x00B0

    addi x4, x0, 0                                      ; pc=0x00B4
    add x5, x4, x4                                      ; pc=0x00B8
    add x5, x5, x5                                      ; pc=0x00BC
    lw x6, -4(x17) ; base ref lista                     ; pc=0x00C0
    add x6, x6, x5                                      ; pc=0x00C4
    lw x7, 0(x6)                                        ; pc=0x00C8
    sw x7, -32(x17) ; t0__x3                            ; pc=0x00CC
    lw x8, -8(x17) ; largo                              ; pc=0x00D0
    sw x8, -36(x17) ; limite__v1__x5                    ; pc=0x00D4
    lw x3, -32(x17) ; t0__x3                            ; pc=0x00D8
    sw x3, -40(x17) ; maximo__v1__x4                    ; pc=0x00DC
    addi x10, x0, 0                                     ; pc=0x00E0
    sw x10, -44(x17) ; i__v1__x6                        ; pc=0x00E4
    lw x4, -40(x17) ; maximo__v1__x4                    ; pc=0x00E8
    sw x4, -12(x17) ; maximo                            ; pc=0x00EC
    lw x5, -36(x17) ; limite__v1__x5                    ; pc=0x00F0
    sw x5, -24(x17) ; limite                            ; pc=0x00F4
    lw x6, -44(x17) ; i__v1__x6                         ; pc=0x00F8
    sw x6, -28(x17) ; i                                 ; pc=0x00FC
L_for_start_0:
    lw x9, -24(x17) ; limite                            ; pc=0x0100
    addi x7, x0, 0                                      ; pc=0x0104
    add x8, x9, x7                                      ; pc=0x0108
    sw x8, -48(x17) ; t1__x7                            ; pc=0x010C
    lw x3, -28(x17) ; i                                 ; pc=0x0110
    lw x7, -48(x17) ; t1__x7                            ; pc=0x0114
    addi x8, x0, 0                                      ; pc=0x0118
    blt x3, x7, 8                                       ; pc=0x011C ; target=.L_ir_3_ir_cmp_true ; addr=0x0124
    jal x0, 8                                           ; pc=0x0120 ; target=.L_ir_4_ir_cmp_end ; addr=0x0128
.L_ir_3_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0124
.L_ir_4_ir_cmp_end:
    sw x8, -52(x17) ; t2__x8                            ; pc=0x0128
    lw x8, -52(x17) ; t2__x8                            ; pc=0x012C
    beq x8, x0, 172                                     ; pc=0x0130 ; target=L_for_end_1 ; addr=0x01DC
    lw x10, -28(x17) ; i                                ; pc=0x0134
    add x4, x10, x10                                    ; pc=0x0138
    add x4, x4, x4                                      ; pc=0x013C
    lw x5, -4(x17) ; base ref lista                     ; pc=0x0140
    add x5, x5, x4                                      ; pc=0x0144
    lw x6, 0(x5)                                        ; pc=0x0148
    sw x6, -56(x17) ; t3__x9                            ; pc=0x014C
    lw x9, -56(x17) ; t3__x9                            ; pc=0x0150
    sw x9, -60(x17) ; num__v1__x10                      ; pc=0x0154
    lw x10, -60(x17) ; num__v1__x10                     ; pc=0x0158
    lw x7, -12(x17) ; maximo                            ; pc=0x015C
    addi x3, x0, 0                                      ; pc=0x0160
    blt x7, x10, 8                                      ; pc=0x0164 ; target=.L_ir_5_ir_cmp_true ; addr=0x016C
    jal x0, 8                                           ; pc=0x0168 ; target=.L_ir_6_ir_cmp_end ; addr=0x0170
.L_ir_5_ir_cmp_true:
    addi x3, x0, 1                                      ; pc=0x016C
.L_ir_6_ir_cmp_end:
    sw x3, -64(x17) ; t4__x3                            ; pc=0x0170
    lw x3, -64(x17) ; t4__x3                            ; pc=0x0174
    sw x3, -68(x17) ; esMayor__v1__x4                   ; pc=0x0178
    lw x4, -68(x17) ; esMayor__v1__x4                   ; pc=0x017C
    addi x8, x0, 0                                      ; pc=0x0180
    add x5, x4, x8                                      ; pc=0x0184
    sw x5, -72(x17) ; t5__x5                            ; pc=0x0188
    lw x10, -60(x17) ; num__v1__x10                     ; pc=0x018C
    sw x10, -16(x17) ; num                              ; pc=0x0190
    lw x4, -68(x17) ; esMayor__v1__x4                   ; pc=0x0194
    sw x4, -20(x17) ; esMayor                           ; pc=0x0198
    lw x5, -72(x17) ; t5__x5                            ; pc=0x019C
    beq x5, x0, 24                                      ; pc=0x01A0 ; target=L_else_2 ; addr=0x01B8
    lw x6, -16(x17) ; num                               ; pc=0x01A4
    sw x6, -76(x17) ; maximo__v2__x6                    ; pc=0x01A8
    lw x6, -76(x17) ; maximo__v2__x6                    ; pc=0x01AC
    sw x6, -12(x17) ; maximo                            ; pc=0x01B0
    jal x0, 4                                           ; pc=0x01B4 ; target=L_end_if_3 ; addr=0x01B8
L_else_2:
L_end_if_3:
    lw x9, -28(x17) ; i                                 ; pc=0x01B8
    addi x7, x0, 1                                      ; pc=0x01BC
    add x3, x9, x7                                      ; pc=0x01C0
    sw x3, -80(x17) ; t6__x7                            ; pc=0x01C4
    lw x7, -80(x17) ; t6__x7                            ; pc=0x01C8
    sw x7, -84(x17) ; i__v2__x8                         ; pc=0x01CC
    lw x8, -84(x17) ; i__v2__x8                         ; pc=0x01D0
    sw x8, -28(x17) ; i                                 ; pc=0x01D4
    jal x0, -216                                        ; pc=0x01D8 ; target=L_for_start_0 ; addr=0x0100
L_for_end_1:
    lw x10, -12(x17) ; maximo                           ; pc=0x01DC
    add x11, x10, x0                                    ; pc=0x01E0
    jal x0, 4                                           ; pc=0x01E4 ; target=.L_ir_2_maximo_lista_end ; addr=0x01E8
.L_ir_2_maximo_lista_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x01E8
    lw x17, 4(x2)                                       ; pc=0x01EC
    addi x2, x2, 92                                     ; pc=0x01F0
    jalr x1, 0                                          ; pc=0x01F4