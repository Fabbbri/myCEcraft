; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x0050
;   .L_ir_2_ir_cmp_true = 0x0060
;   .L_ir_3_ir_cmp_end = 0x0064
;   L_while_end_1 = 0x009C
;   .L_ir_1_main_end = 0x00A4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0058 blt -> .L_ir_2_ir_cmp_true (addr=0x0060, offset=8)
;   pc=0x005C jal -> .L_ir_3_ir_cmp_end (addr=0x0064, offset=8)
;   pc=0x006C beq -> L_while_end_1 (addr=0x009C, offset=48)
;   pc=0x0098 jal -> L_while_start_0 (addr=0x0050, offset=-72)
;   pc=0x00A0 jal -> .L_ir_1_main_end (addr=0x00A4, offset=4)

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

    addi x7, x0, 0                                      ; pc=0x0030
    add x3, x7, x0 ; promote i                          ; pc=0x0034
    addi x8, x0, 0                                      ; pc=0x0038
    add x5, x8, x0 ; promote suma                       ; pc=0x003C
    addi x9, x0, 1                                      ; pc=0x0040
    add x6, x9, x0 ; promote mezcla                     ; pc=0x0044
    addi x10, x0, 0                                     ; pc=0x0048
    add x4, x10, x0 ; promote total                     ; pc=0x004C
L_while_start_0:
    addi x7, x0, 8                                      ; pc=0x0050
    addi x8, x0, 0                                      ; pc=0x0054
    blt x3, x7, 8                                       ; pc=0x0058 ; target=.L_ir_2_ir_cmp_true ; addr=0x0060
    jal x0, 8                                           ; pc=0x005C ; target=.L_ir_3_ir_cmp_end ; addr=0x0064
.L_ir_2_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0060
.L_ir_3_ir_cmp_end:
    sw x8, -20(x17) ; t0                                ; pc=0x0064
    lw x9, -20(x17) ; t0                                ; pc=0x0068
    beq x9, x0, 48                                      ; pc=0x006C ; target=L_while_end_1 ; addr=0x009C
    add x10, x5, x3                                     ; pc=0x0070
    add x5, x10, x0 ; promote suma                      ; pc=0x0074
    addi x8, x0, 2                                      ; pc=0x0078
    mul x7, x6, x8                                      ; pc=0x007C
    add x6, x7, x0 ; promote mezcla                     ; pc=0x0080
    add x9, x4, x5                                      ; pc=0x0084
    add x4, x9, x0 ; promote total                      ; pc=0x0088
    addi x10, x0, 1                                     ; pc=0x008C
    add x7, x3, x10                                     ; pc=0x0090
    add x3, x7, x0 ; promote i                          ; pc=0x0094
    jal x0, -72                                         ; pc=0x0098 ; target=L_while_start_0 ; addr=0x0050
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x009C
    jal x0, 4                                           ; pc=0x00A0 ; target=.L_ir_1_main_end ; addr=0x00A4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00A4
    addi x2, x2, 44                                     ; pc=0x00A8
    freeze                                              ; pc=0x00AC