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
;   .L_ir_4_ir_cmp_true = 0x00C8
;   .L_ir_5_ir_cmp_end = 0x00CC
;   L_else_2 = 0x00E8
;   L_end_if_3 = 0x00F4
;   L_while_end_1 = 0x00F8
;   .L_ir_1_main_end = 0x0100

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0084 blt -> .L_ir_2_ir_cmp_true (addr=0x008C, offset=8)
;   pc=0x0088 jal -> .L_ir_3_ir_cmp_end (addr=0x0090, offset=8)
;   pc=0x0098 beq -> L_while_end_1 (addr=0x00F8, offset=96)
;   pc=0x00C0 beq -> .L_ir_4_ir_cmp_true (addr=0x00C8, offset=8)
;   pc=0x00C4 jal -> .L_ir_5_ir_cmp_end (addr=0x00CC, offset=8)
;   pc=0x00D4 beq -> L_else_2 (addr=0x00E8, offset=20)
;   pc=0x00E4 jal -> L_end_if_3 (addr=0x00F4, offset=16)
;   pc=0x00F4 jal -> L_while_start_0 (addr=0x007C, offset=-120)
;   pc=0x00FC jal -> .L_ir_1_main_end (addr=0x0100, offset=4)

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
    sw x5, -28(x17) ; objetivo                          ; pc=0x0064
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
    sw x10, -44(x17) ; t1                               ; pc=0x0090
    lw x5, -44(x17) ; t1                                ; pc=0x0094
    beq x5, x0, 96                                      ; pc=0x0098 ; target=L_while_end_1 ; addr=0x00F8
    add x6, x3, x3                                      ; pc=0x009C
    add x6, x6, x6                                      ; pc=0x00A0
    addiSigned x8, x17, -24                             ; pc=0x00A4
    add x8, x8, x6                                      ; pc=0x00A8
    lw x7, 0(x8)                                        ; pc=0x00AC
    sw x7, -48(x17) ; t2                                ; pc=0x00B0
    lw x10, -48(x17) ; t2                               ; pc=0x00B4
    lw x9, -28(x17) ; objetivo                          ; pc=0x00B8
    addi x5, x0, 0                                      ; pc=0x00BC
    beq x10, x9, 8                                      ; pc=0x00C0 ; target=.L_ir_4_ir_cmp_true ; addr=0x00C8
    jal x0, 8                                           ; pc=0x00C4 ; target=.L_ir_5_ir_cmp_end ; addr=0x00CC
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x00C8
.L_ir_5_ir_cmp_end:
    sw x5, -52(x17) ; t3                                ; pc=0x00CC
    lw x6, -52(x17) ; t3                                ; pc=0x00D0
    beq x6, x0, 20                                      ; pc=0x00D4 ; target=L_else_2 ; addr=0x00E8
    add x4, x3, x0 ; promote pos                        ; pc=0x00D8
    addi x8, x0, 6                                      ; pc=0x00DC
    add x3, x8, x0 ; promote i                          ; pc=0x00E0
    jal x0, 16                                          ; pc=0x00E4 ; target=L_end_if_3 ; addr=0x00F4
L_else_2:
    addi x7, x0, 1                                      ; pc=0x00E8
    add x5, x3, x7                                      ; pc=0x00EC
    add x3, x5, x0 ; promote i                          ; pc=0x00F0
L_end_if_3:
    jal x0, -120                                        ; pc=0x00F4 ; target=L_while_start_0 ; addr=0x007C
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x00F8
    jal x0, 4                                           ; pc=0x00FC ; target=.L_ir_1_main_end ; addr=0x0100
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0100
    addi x2, x2, 64                                     ; pc=0x0104
    freeze                                              ; pc=0x0108