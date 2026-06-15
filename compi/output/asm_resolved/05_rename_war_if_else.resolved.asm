; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_for_start_2 = 0x0040
;   .L_ir_2_ir_cmp_true = 0x0050
;   .L_ir_3_ir_cmp_end = 0x0054
;   L_for_end_3 = 0x00B0
;   .L_ir_1_main_end = 0x00B8
;   clasificar = 0x00C4
;   .L_ir_5_ir_cmp_true = 0x00E8
;   .L_ir_6_ir_cmp_end = 0x00EC
;   L_else_0 = 0x0108
;   L_end_if_1 = 0x0118
;   .L_ir_4_clasificar_end = 0x0118

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0048 bge -> .L_ir_2_ir_cmp_true (addr=0x0050, offset=8)
;   pc=0x004C jal -> .L_ir_3_ir_cmp_end (addr=0x0054, offset=8)
;   pc=0x0058 beq -> L_for_end_3 (addr=0x00B0, offset=88)
;   pc=0x0080 jal -> clasificar (addr=0x00C4, offset=68)
;   pc=0x00AC jal -> L_for_start_2 (addr=0x0040, offset=-108)
;   pc=0x00B4 jal -> .L_ir_1_main_end (addr=0x00B8, offset=4)
;   pc=0x00E0 blt -> .L_ir_5_ir_cmp_true (addr=0x00E8, offset=8)
;   pc=0x00E4 jal -> .L_ir_6_ir_cmp_end (addr=0x00EC, offset=8)
;   pc=0x00F0 beq -> L_else_0 (addr=0x0108, offset=24)
;   pc=0x0100 jal -> .L_ir_4_clasificar_end (addr=0x0118, offset=24)
;   pc=0x0104 jal -> L_end_if_1 (addr=0x0118, offset=20)
;   pc=0x0114 jal -> .L_ir_4_clasificar_end (addr=0x0118, offset=4)

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
    addiSigned x2, x2, -36                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 36                                    ; pc=0x002C

    addi x7, x0, 0                                      ; pc=0x0030
    add x4, x7, x0 ; promote total                      ; pc=0x0034
    addi x8, x0, 1                                      ; pc=0x0038
    add x3, x8, x0 ; promote i                          ; pc=0x003C
L_for_start_2:
    addi x9, x0, 6                                      ; pc=0x0040
    addi x10, x0, 0                                     ; pc=0x0044
    bge x9, x3, 8                                       ; pc=0x0048 ; target=.L_ir_2_ir_cmp_true ; addr=0x0050
    jal x0, 8                                           ; pc=0x004C ; target=.L_ir_3_ir_cmp_end ; addr=0x0054
.L_ir_2_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x0050
.L_ir_3_ir_cmp_end:
    add x5, x10, x0 ; promote t3                        ; pc=0x0054
    beq x5, x0, 88                                      ; pc=0x0058 ; target=L_for_end_3 ; addr=0x00B0
    addi x7, x0, 2                                      ; pc=0x005C
    add x8, x3, x7                                      ; pc=0x0060
    add x6, x8, x0 ; promote t4                         ; pc=0x0064
    add x11, x3, x0                                     ; pc=0x0068
    add x12, x6, x0                                     ; pc=0x006C
    sw x3, -8(x17) ; i                                  ; pc=0x0070
    sw x5, -12(x17) ; spill t3                          ; pc=0x0074
    sw x6, -16(x17) ; spill t4                          ; pc=0x0078
    sw x4, -4(x17) ; total                              ; pc=0x007C
    jal x1, 68                                          ; pc=0x0080 ; target=clasificar ; addr=0x00C4
    add x10, x11, x0                                    ; pc=0x0084
    sw x10, -20(x17) ; t5                               ; pc=0x0088
    lw x4, -4(x17) ; total                              ; pc=0x008C
    lw x9, -20(x17) ; t5                                ; pc=0x0090
    add x8, x4, x9                                      ; pc=0x0094
    add x4, x8, x0 ; promote total                      ; pc=0x0098
    lw x3, -8(x17) ; i                                  ; pc=0x009C
    addi x7, x0, 1                                      ; pc=0x00A0
    add x10, x3, x7                                     ; pc=0x00A4
    add x3, x10, x0 ; promote i                         ; pc=0x00A8
    jal x0, -108                                        ; pc=0x00AC ; target=L_for_start_2 ; addr=0x0040
L_for_end_3:
    add x11, x4, x0                                     ; pc=0x00B0
    jal x0, 4                                           ; pc=0x00B4 ; target=.L_ir_1_main_end ; addr=0x00B8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00B8
    addi x2, x2, 36                                     ; pc=0x00BC
    freeze                                              ; pc=0x00C0

clasificar:
    ; prologue
    addiSigned x2, x2, -28                              ; pc=0x00C4
    sw x1, 0(x2)                                        ; pc=0x00C8
    sw x17, 4(x2)                                       ; pc=0x00CC
    addi x17, x2, 28                                    ; pc=0x00D0

    add x4, x11, x0 ; parametro promovido x             ; pc=0x00D4
    add x3, x12, x0 ; parametro promovido lim           ; pc=0x00D8

    addi x7, x0, 0                                      ; pc=0x00DC
    blt x4, x3, 8                                       ; pc=0x00E0 ; target=.L_ir_5_ir_cmp_true ; addr=0x00E8
    jal x0, 8                                           ; pc=0x00E4 ; target=.L_ir_6_ir_cmp_end ; addr=0x00EC
.L_ir_5_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x00E8
.L_ir_6_ir_cmp_end:
    add x5, x7, x0 ; promote t0                         ; pc=0x00EC
    beq x5, x0, 24                                      ; pc=0x00F0 ; target=L_else_0 ; addr=0x0108
    add x8, x4, x3                                      ; pc=0x00F4
    add x6, x8, x0 ; promote t1                         ; pc=0x00F8
    add x11, x6, x0                                     ; pc=0x00FC
    jal x0, 24                                          ; pc=0x0100 ; target=.L_ir_4_clasificar_end ; addr=0x0118
    jal x0, 20                                          ; pc=0x0104 ; target=L_end_if_1 ; addr=0x0118
L_else_0:
    add x9, x3, x4                                      ; pc=0x0108
    add x3, x9, x0 ; promote lim                        ; pc=0x010C
    add x11, x3, x0                                     ; pc=0x0110
    jal x0, 4                                           ; pc=0x0114 ; target=.L_ir_4_clasificar_end ; addr=0x0118
L_end_if_1:
.L_ir_4_clasificar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0118
    lw x17, 4(x2)                                       ; pc=0x011C
    addi x2, x2, 28                                     ; pc=0x0120
    jalr x1, 0                                          ; pc=0x0124