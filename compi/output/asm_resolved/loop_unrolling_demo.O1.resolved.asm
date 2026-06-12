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
;   L_while_end_1 = 0x0108
;   .L_ir_1_main_end = 0x0110

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0058 blt -> .L_ir_2_ir_cmp_true (addr=0x0060, offset=8)
;   pc=0x005C jal -> .L_ir_3_ir_cmp_end (addr=0x0064, offset=8)
;   pc=0x006C beq -> L_while_end_1 (addr=0x0108, offset=156)
;   pc=0x0104 jal -> L_while_start_0 (addr=0x0050, offset=-180)
;   pc=0x010C jal -> .L_ir_1_main_end (addr=0x0110, offset=4)

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
    addiSigned x2, x2, -80                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 80                                    ; pc=0x002C

    addi x7, x0, 0                                      ; pc=0x0030
    add x6, x7, x0 ; promote i                          ; pc=0x0034
    addi x8, x0, 0                                      ; pc=0x0038
    add x3, x8, x0 ; promote suma                       ; pc=0x003C
    addi x9, x0, 1                                      ; pc=0x0040
    add x5, x9, x0 ; promote mezcla                     ; pc=0x0044
    addi x10, x0, 0                                     ; pc=0x0048
    add x4, x10, x0 ; promote total                     ; pc=0x004C
L_while_start_0:
    addi x7, x0, 8                                      ; pc=0x0050
    addi x8, x0, 0                                      ; pc=0x0054
    blt x6, x7, 8                                       ; pc=0x0058 ; target=.L_ir_2_ir_cmp_true ; addr=0x0060
    jal x0, 8                                           ; pc=0x005C ; target=.L_ir_3_ir_cmp_end ; addr=0x0064
.L_ir_2_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0060
.L_ir_3_ir_cmp_end:
    sw x8, -20(x17) ; t5__x3                            ; pc=0x0064
    lw x9, -20(x17) ; t5__x3                            ; pc=0x0068
    beq x9, x0, 156                                     ; pc=0x006C ; target=L_while_end_1 ; addr=0x0108
    add x10, x3, x6                                     ; pc=0x0070
    add x3, x10, x0 ; promote suma                      ; pc=0x0074
    addi x8, x0, 2                                      ; pc=0x0078
    mul x7, x5, x8                                      ; pc=0x007C
    add x5, x7, x0 ; promote mezcla                     ; pc=0x0080
    add x9, x4, x3                                      ; pc=0x0084
    add x4, x9, x0 ; promote total                      ; pc=0x0088
    addi x10, x0, 1                                     ; pc=0x008C
    add x7, x6, x10                                     ; pc=0x0090
    add x8, x3, x7                                      ; pc=0x0094
    add x3, x8, x0 ; promote suma                       ; pc=0x0098
    addi x9, x0, 2                                      ; pc=0x009C
    mul x10, x5, x9                                     ; pc=0x00A0
    add x5, x10, x0 ; promote mezcla                    ; pc=0x00A4
    add x8, x4, x3                                      ; pc=0x00A8
    add x4, x8, x0 ; promote total                      ; pc=0x00AC
    addi x7, x0, 2                                      ; pc=0x00B0
    add x10, x6, x7                                     ; pc=0x00B4
    add x9, x3, x10                                     ; pc=0x00B8
    add x3, x9, x0 ; promote suma                       ; pc=0x00BC
    addi x8, x0, 2                                      ; pc=0x00C0
    mul x7, x5, x8                                      ; pc=0x00C4
    add x5, x7, x0 ; promote mezcla                     ; pc=0x00C8
    add x9, x4, x3                                      ; pc=0x00CC
    add x4, x9, x0 ; promote total                      ; pc=0x00D0
    addi x10, x0, 3                                     ; pc=0x00D4
    add x7, x6, x10                                     ; pc=0x00D8
    add x8, x3, x7                                      ; pc=0x00DC
    add x3, x8, x0 ; promote suma                       ; pc=0x00E0
    addi x9, x0, 2                                      ; pc=0x00E4
    mul x10, x5, x9                                     ; pc=0x00E8
    add x5, x10, x0 ; promote mezcla                    ; pc=0x00EC
    add x8, x4, x3                                      ; pc=0x00F0
    add x4, x8, x0 ; promote total                      ; pc=0x00F4
    addi x7, x0, 4                                      ; pc=0x00F8
    add x10, x6, x7                                     ; pc=0x00FC
    add x6, x10, x0 ; promote i                         ; pc=0x0100
    jal x0, -180                                        ; pc=0x0104 ; target=L_while_start_0 ; addr=0x0050
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x0108
    jal x0, 4                                           ; pc=0x010C ; target=.L_ir_1_main_end ; addr=0x0110
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0110
    addi x2, x2, 80                                     ; pc=0x0114
    freeze                                              ; pc=0x0118