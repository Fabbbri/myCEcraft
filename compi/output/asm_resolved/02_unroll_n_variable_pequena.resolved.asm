; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x0048
;   .L_ir_2_ir_cmp_true = 0x0054
;   .L_ir_3_ir_cmp_end = 0x0058
;   L_while_end_1 = 0x0078
;   .L_ir_1_main_end = 0x0080

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x004C blt -> .L_ir_2_ir_cmp_true (addr=0x0054, offset=8)
;   pc=0x0050 jal -> .L_ir_3_ir_cmp_end (addr=0x0058, offset=8)
;   pc=0x005C beq -> L_while_end_1 (addr=0x0078, offset=28)
;   pc=0x0074 jal -> L_while_start_0 (addr=0x0048, offset=-44)
;   pc=0x007C jal -> .L_ir_1_main_end (addr=0x0080, offset=4)

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
    addiSigned x2, x2, -32                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 32                                    ; pc=0x002C

    addi x7, x0, 6                                      ; pc=0x0030
    add x5, x7, x0 ; promote n                          ; pc=0x0034
    addi x8, x0, 0                                      ; pc=0x0038
    add x3, x8, x0 ; promote i                          ; pc=0x003C
    addi x9, x0, 0                                      ; pc=0x0040
    add x4, x9, x0 ; promote suma                       ; pc=0x0044
L_while_start_0:
    addi x10, x0, 0                                     ; pc=0x0048
    blt x3, x5, 8                                       ; pc=0x004C ; target=.L_ir_2_ir_cmp_true ; addr=0x0054
    jal x0, 8                                           ; pc=0x0050 ; target=.L_ir_3_ir_cmp_end ; addr=0x0058
.L_ir_2_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x0054
.L_ir_3_ir_cmp_end:
    add x6, x10, x0 ; promote t0                        ; pc=0x0058
    beq x6, x0, 28                                      ; pc=0x005C ; target=L_while_end_1 ; addr=0x0078
    add x7, x4, x3                                      ; pc=0x0060
    add x4, x7, x0 ; promote suma                       ; pc=0x0064
    addi x8, x0, 1                                      ; pc=0x0068
    add x9, x3, x8                                      ; pc=0x006C
    add x3, x9, x0 ; promote i                          ; pc=0x0070
    jal x0, -44                                         ; pc=0x0074 ; target=L_while_start_0 ; addr=0x0048
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x0078
    jal x0, 4                                           ; pc=0x007C ; target=.L_ir_1_main_end ; addr=0x0080
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0080
    addi x2, x2, 32                                     ; pc=0x0084
    freeze                                              ; pc=0x0088