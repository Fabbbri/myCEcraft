; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_for_start_0 = 0x0048
;   .L_ir_2_ir_cmp_true = 0x0058
;   .L_ir_3_ir_cmp_end = 0x005C
;   L_for_end_1 = 0x00C4
;   .L_ir_1_main_end = 0x00D8

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0050 blt -> .L_ir_2_ir_cmp_true (addr=0x0058, offset=8)
;   pc=0x0054 jal -> .L_ir_3_ir_cmp_end (addr=0x005C, offset=8)
;   pc=0x0060 beq -> L_for_end_1 (addr=0x00C4, offset=100)
;   pc=0x00C0 jal -> L_for_start_0 (addr=0x0048, offset=-120)
;   pc=0x00D4 jal -> .L_ir_1_main_end (addr=0x00D8, offset=4)

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
    addiSigned x2, x2, -56                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 56                                    ; pc=0x002C

    addi x7, x0, 0                                      ; pc=0x0030
    add x4, x7, x0 ; promote suma_a                     ; pc=0x0034
    addi x8, x0, 0                                      ; pc=0x0038
    add x5, x8, x0 ; promote suma_b                     ; pc=0x003C
    addi x9, x0, 0                                      ; pc=0x0040
    add x3, x9, x0 ; promote i                          ; pc=0x0044
L_for_start_0:
    addi x10, x0, 8                                     ; pc=0x0048
    addi x7, x0, 0                                      ; pc=0x004C
    blt x3, x10, 8                                      ; pc=0x0050 ; target=.L_ir_2_ir_cmp_true ; addr=0x0058
    jal x0, 8                                           ; pc=0x0054 ; target=.L_ir_3_ir_cmp_end ; addr=0x005C
.L_ir_2_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0058
.L_ir_3_ir_cmp_end:
    add x6, x7, x0 ; promote t6__x3                     ; pc=0x005C
    beq x6, x0, 100                                     ; pc=0x0060 ; target=L_for_end_1 ; addr=0x00C4
    add x8, x4, x3                                      ; pc=0x0064
    add x4, x8, x0 ; promote suma_a                     ; pc=0x0068
    add x9, x5, x3                                      ; pc=0x006C
    sw x9, -24(x17) ; t8__x5                            ; pc=0x0070
    lw x7, -24(x17) ; t8__x5                            ; pc=0x0074
    addi x10, x0, 1                                     ; pc=0x0078
    add x8, x7, x10                                     ; pc=0x007C
    add x5, x8, x0 ; promote suma_b                     ; pc=0x0080
    addi x9, x0, 2                                      ; pc=0x0084
    add x8, x3, x9                                      ; pc=0x0088
    add x10, x4, x8                                     ; pc=0x008C
    add x4, x10, x0 ; promote suma_a                    ; pc=0x0090
    addi x7, x0, 2                                      ; pc=0x0094
    add x9, x3, x7                                      ; pc=0x0098
    add x8, x5, x9                                      ; pc=0x009C
    sw x8, -36(x17) ; t11__x8                           ; pc=0x00A0
    lw x8, -36(x17) ; t11__x8                           ; pc=0x00A4
    addi x10, x0, 1                                     ; pc=0x00A8
    add x7, x8, x10                                     ; pc=0x00AC
    add x5, x7, x0 ; promote suma_b                     ; pc=0x00B0
    addi x9, x0, 4                                      ; pc=0x00B4
    add x7, x3, x9                                      ; pc=0x00B8
    add x3, x7, x0 ; promote i                          ; pc=0x00BC
    jal x0, -120                                        ; pc=0x00C0 ; target=L_for_start_0 ; addr=0x0048
L_for_end_1:
    add x10, x4, x5                                     ; pc=0x00C4
    sw x10, -48(x17) ; t5__x3                           ; pc=0x00C8
    lw x8, -48(x17) ; t5__x3                            ; pc=0x00CC
    add x11, x8, x0                                     ; pc=0x00D0
    jal x0, 4                                           ; pc=0x00D4 ; target=.L_ir_1_main_end ; addr=0x00D8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00D8
    addi x2, x2, 56                                     ; pc=0x00DC
    freeze                                              ; pc=0x00E0