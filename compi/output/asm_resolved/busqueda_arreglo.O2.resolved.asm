; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x007C
;   .L_ir_2_ir_cmp_true = 0x008C
;   .L_ir_3_ir_cmp_end = 0x0090
;   .L_ir_4_ir_cmp_true = 0x00BC
;   .L_ir_5_ir_cmp_end = 0x00C0
;   L_else_2 = 0x00D8
;   L_end_if_3 = 0x00E4
;   L_while_end_1 = 0x00E8
;   .L_ir_1_main_end = 0x00F0

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0084 blt -> .L_ir_2_ir_cmp_true (addr=0x008C, offset=8)
;   pc=0x0088 jal -> .L_ir_3_ir_cmp_end (addr=0x0090, offset=8)
;   pc=0x0094 beq -> L_while_end_1 (addr=0x00E8, offset=84)
;   pc=0x00B4 beq -> .L_ir_4_ir_cmp_true (addr=0x00BC, offset=8)
;   pc=0x00B8 jal -> .L_ir_5_ir_cmp_end (addr=0x00C0, offset=8)
;   pc=0x00C4 beq -> L_else_2 (addr=0x00D8, offset=20)
;   pc=0x00D4 jal -> L_end_if_3 (addr=0x00E4, offset=16)
;   pc=0x00E4 jal -> L_while_start_0 (addr=0x007C, offset=-104)
;   pc=0x00EC jal -> .L_ir_1_main_end (addr=0x00F0, offset=4)

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
    addiSigned x2, x2, -64                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 64                                    ; pc=0x002C

    addi x5, x0, 3                                      ; pc=0x0030
    sw x5, -24(x17) ; datos[0]                          ; pc=0x0034
    addi x6, x0, 7                                      ; pc=0x0038
    sw x6, -20(x17) ; datos[1]                          ; pc=0x003C
    addi x7, x0, 2                                      ; pc=0x0040
    sw x7, -16(x17) ; datos[2]                          ; pc=0x0044
    addi x8, x0, 9                                      ; pc=0x0048
    sw x8, -12(x17) ; datos[3]                          ; pc=0x004C
    addi x9, x0, 5                                      ; pc=0x0050
    sw x9, -8(x17) ; datos[4]                           ; pc=0x0054
    addi x10, x0, 1                                     ; pc=0x0058
    sw x10, -4(x17) ; datos[5]                          ; pc=0x005C
    addi x5, x0, 9                                      ; pc=0x0060
    add x20, x5, x0 ; promote objetivo                  ; pc=0x0064
    addi x6, x0, 0                                      ; pc=0x0068
    add x3, x6, x0 ; promote i                          ; pc=0x006C
    addi x7, x0, 1                                      ; pc=0x0070
    sub x8, x0, x7                                      ; pc=0x0074
    add x4, x8, x0 ; promote pos                        ; pc=0x0078
L_while_start_0:
    addi x9, x0, 6                                      ; pc=0x007C
    addi x10, x0, 0                                     ; pc=0x0080
    blt x3, x9, 8                                       ; pc=0x0084 ; target=.L_ir_2_ir_cmp_true ; addr=0x008C
    jal x0, 8                                           ; pc=0x0088 ; target=.L_ir_3_ir_cmp_end ; addr=0x0090
.L_ir_2_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x008C
.L_ir_3_ir_cmp_end:
    add x22, x10, x0 ; promote t1                       ; pc=0x0090
    beq x22, x0, 84                                     ; pc=0x0094 ; target=L_while_end_1 ; addr=0x00E8
    add x5, x3, x3                                      ; pc=0x0098
    add x5, x5, x5                                      ; pc=0x009C
    addiSigned x6, x17, -24                             ; pc=0x00A0
    add x6, x6, x5                                      ; pc=0x00A4
    lw x8, 0(x6)                                        ; pc=0x00A8
    add x23, x8, x0 ; promote t2                        ; pc=0x00AC
    addi x7, x0, 0                                      ; pc=0x00B0
    beq x23, x20, 8                                     ; pc=0x00B4 ; target=.L_ir_4_ir_cmp_true ; addr=0x00BC
    jal x0, 8                                           ; pc=0x00B8 ; target=.L_ir_5_ir_cmp_end ; addr=0x00C0
.L_ir_4_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x00BC
.L_ir_5_ir_cmp_end:
    add x24, x7, x0 ; promote t3                        ; pc=0x00C0
    beq x24, x0, 20                                     ; pc=0x00C4 ; target=L_else_2 ; addr=0x00D8
    add x4, x3, x0 ; promote pos                        ; pc=0x00C8
    addi x10, x0, 6                                     ; pc=0x00CC
    add x3, x10, x0 ; promote i                         ; pc=0x00D0
    jal x0, 16                                          ; pc=0x00D4 ; target=L_end_if_3 ; addr=0x00E4
L_else_2:
    addi x9, x0, 1                                      ; pc=0x00D8
    add x5, x3, x9                                      ; pc=0x00DC
    add x3, x5, x0 ; promote i                          ; pc=0x00E0
L_end_if_3:
    jal x0, -104                                        ; pc=0x00E4 ; target=L_while_start_0 ; addr=0x007C
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x00E8
    jal x0, 4                                           ; pc=0x00EC ; target=.L_ir_1_main_end ; addr=0x00F0
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00F0
    addi x2, x2, 64                                     ; pc=0x00F4
    freeze                                              ; pc=0x00F8