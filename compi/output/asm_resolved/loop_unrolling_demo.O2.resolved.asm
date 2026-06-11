; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x0050
;   .L_ir_2_ir_cmp_true = 0x0064
;   .L_ir_3_ir_cmp_end = 0x0068
;   L_while_end_1 = 0x00D8
;   .L_ir_1_main_end = 0x00E4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x005C blt -> .L_ir_2_ir_cmp_true (addr=0x0064, offset=8)
;   pc=0x0060 jal -> .L_ir_3_ir_cmp_end (addr=0x0068, offset=8)
;   pc=0x0070 beq -> L_while_end_1 (addr=0x00D8, offset=104)
;   pc=0x00D4 jal -> L_while_start_0 (addr=0x0050, offset=-132)
;   pc=0x00E0 jal -> .L_ir_1_main_end (addr=0x00E4, offset=4)

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
    addiSigned x2, x2, -44                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 44                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -4(x17) ; i                                  ; pc=0x0034
    addi x4, x0, 0                                      ; pc=0x0038
    sw x4, -8(x17) ; suma                               ; pc=0x003C
    addi x5, x0, 1                                      ; pc=0x0040
    sw x5, -12(x17) ; mezcla                            ; pc=0x0044
    addi x6, x0, 0                                      ; pc=0x0048
    sw x6, -16(x17) ; total                             ; pc=0x004C
L_while_start_0:
    lw x7, -4(x17) ; i                                  ; pc=0x0050
    addi x8, x0, 8                                      ; pc=0x0054
    addi x9, x0, 0                                      ; pc=0x0058
    blt x7, x8, 8                                       ; pc=0x005C ; target=.L_ir_2_ir_cmp_true ; addr=0x0064
    jal x0, 8                                           ; pc=0x0060 ; target=.L_ir_3_ir_cmp_end ; addr=0x0068
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0064
.L_ir_3_ir_cmp_end:
    sw x9, -20(x17) ; t0                                ; pc=0x0068
    lw x10, -20(x17) ; t0                               ; pc=0x006C
    beq x10, x0, 104                                    ; pc=0x0070 ; target=L_while_end_1 ; addr=0x00D8
    lw x3, -8(x17) ; suma                               ; pc=0x0074
    lw x4, -4(x17) ; i                                  ; pc=0x0078
    add x5, x3, x4                                      ; pc=0x007C
    sw x5, -24(x17) ; t1                                ; pc=0x0080
    lw x6, -24(x17) ; t1                                ; pc=0x0084
    sw x6, -8(x17) ; suma                               ; pc=0x0088
    lw x9, -12(x17) ; mezcla                            ; pc=0x008C
    addi x8, x0, 2                                      ; pc=0x0090
    mul x7, x9, x8                                      ; pc=0x0094
    sw x7, -28(x17) ; t2                                ; pc=0x0098
    lw x10, -28(x17) ; t2                               ; pc=0x009C
    sw x10, -12(x17) ; mezcla                           ; pc=0x00A0
    lw x5, -16(x17) ; total                             ; pc=0x00A4
    lw x4, -8(x17) ; suma                               ; pc=0x00A8
    add x3, x5, x4                                      ; pc=0x00AC
    sw x3, -32(x17) ; t3                                ; pc=0x00B0
    lw x6, -32(x17) ; t3                                ; pc=0x00B4
    sw x6, -16(x17) ; total                             ; pc=0x00B8
    lw x7, -4(x17) ; i                                  ; pc=0x00BC
    addi x8, x0, 1                                      ; pc=0x00C0
    add x9, x7, x8                                      ; pc=0x00C4
    sw x9, -36(x17) ; t4                                ; pc=0x00C8
    lw x10, -36(x17) ; t4                               ; pc=0x00CC
    sw x10, -4(x17) ; i                                 ; pc=0x00D0
    jal x0, -132                                        ; pc=0x00D4 ; target=L_while_start_0 ; addr=0x0050
L_while_end_1:
    lw x3, -16(x17) ; total                             ; pc=0x00D8
    add x11, x3, x0                                     ; pc=0x00DC
    jal x0, 4                                           ; pc=0x00E0 ; target=.L_ir_1_main_end ; addr=0x00E4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00E4
    addi x2, x2, 44                                     ; pc=0x00E8
    freeze                                              ; pc=0x00EC