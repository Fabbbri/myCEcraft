; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_2_ir_cmp_true = 0x00C0
;   .L_ir_3_ir_cmp_end = 0x00C4
;   L_else_2 = 0x00EC
;   L_end_if_3 = 0x00EC
;   .L_ir_1_main_end = 0x00F8
;   seleccionar = 0x0104
;   .L_ir_5_ir_cmp_true = 0x0128
;   .L_ir_6_ir_cmp_end = 0x012C
;   L_else_0 = 0x0140
;   L_end_if_1 = 0x0140
;   .L_ir_4_seleccionar_end = 0x0148

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x009C jal -> seleccionar (addr=0x0104, offset=104)
;   pc=0x00B8 beq -> .L_ir_2_ir_cmp_true (addr=0x00C0, offset=8)
;   pc=0x00BC jal -> .L_ir_3_ir_cmp_end (addr=0x00C4, offset=8)
;   pc=0x00CC beq -> L_else_2 (addr=0x00EC, offset=32)
;   pc=0x00E4 jal -> .L_ir_1_main_end (addr=0x00F8, offset=20)
;   pc=0x00E8 jal -> L_end_if_3 (addr=0x00EC, offset=4)
;   pc=0x00F4 jal -> .L_ir_1_main_end (addr=0x00F8, offset=4)
;   pc=0x0120 blt -> .L_ir_5_ir_cmp_true (addr=0x0128, offset=8)
;   pc=0x0124 jal -> .L_ir_6_ir_cmp_end (addr=0x012C, offset=8)
;   pc=0x0130 beq -> L_else_0 (addr=0x0140, offset=16)
;   pc=0x0138 jal -> .L_ir_4_seleccionar_end (addr=0x0148, offset=16)
;   pc=0x013C jal -> L_end_if_1 (addr=0x0140, offset=4)
;   pc=0x0144 jal -> .L_ir_4_seleccionar_end (addr=0x0148, offset=4)

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
    addiSigned x2, x2, -60                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 60                                    ; pc=0x002C

    addi x5, x0, 8                                      ; pc=0x0030
    sw x5, -12(x17) ; datos[0]                          ; pc=0x0034
    addi x6, x0, 21                                     ; pc=0x0038
    sw x6, -8(x17) ; datos[1]                           ; pc=0x003C
    addi x7, x0, 13                                     ; pc=0x0040
    sw x7, -4(x17) ; datos[2]                           ; pc=0x0044
    addi x8, x0, 1                                      ; pc=0x0048
    add x9, x8, x8                                      ; pc=0x004C
    add x9, x9, x9                                      ; pc=0x0050
    addiSigned x10, x17, -12                            ; pc=0x0054
    add x10, x10, x9                                    ; pc=0x0058
    lw x5, 0(x10)                                       ; pc=0x005C
    sw x5, -32(x17) ; t1                                ; pc=0x0060
    lw x6, -32(x17) ; t1                                ; pc=0x0064
    sw x6, -16(x17) ; cargado                           ; pc=0x0068
    addi x7, x0, 5                                      ; pc=0x006C
    addi x9, x0, 6                                      ; pc=0x0070
    add x8, x7, x9                                      ; pc=0x0074
    add x3, x8, x0 ; promote independiente              ; pc=0x0078
    lw x10, -16(x17) ; cargado                          ; pc=0x007C
    addi x5, x0, 1                                      ; pc=0x0080
    add x6, x10, x5                                     ; pc=0x0084
    sw x6, -24(x17) ; candidato                         ; pc=0x0088
    lw x8, -24(x17) ; candidato                         ; pc=0x008C
    add x11, x8, x0                                     ; pc=0x0090
    add x12, x3, x0                                     ; pc=0x0094
    sw x3, -20(x17) ; independiente                     ; pc=0x0098
    jal x1, 104                                         ; pc=0x009C ; target=seleccionar ; addr=0x0104
    add x9, x11, x0                                     ; pc=0x00A0
    sw x9, -44(x17) ; t4                                ; pc=0x00A4
    lw x7, -44(x17) ; t4                                ; pc=0x00A8
    add x4, x7, x0 ; promote elegido                    ; pc=0x00AC
    addi x6, x0, 22                                     ; pc=0x00B0
    addi x5, x0, 0                                      ; pc=0x00B4
    beq x4, x6, 8                                       ; pc=0x00B8 ; target=.L_ir_2_ir_cmp_true ; addr=0x00C0
    jal x0, 8                                           ; pc=0x00BC ; target=.L_ir_3_ir_cmp_end ; addr=0x00C4
.L_ir_2_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x00C0
.L_ir_3_ir_cmp_end:
    sw x5, -48(x17) ; t5                                ; pc=0x00C4
    lw x10, -48(x17) ; t5                               ; pc=0x00C8
    beq x10, x0, 32                                     ; pc=0x00CC ; target=L_else_2 ; addr=0x00EC
    lw x3, -20(x17) ; independiente                     ; pc=0x00D0
    add x8, x4, x3                                      ; pc=0x00D4
    sw x8, -52(x17) ; t6                                ; pc=0x00D8
    lw x9, -52(x17) ; t6                                ; pc=0x00DC
    add x11, x9, x0                                     ; pc=0x00E0
    jal x0, 20                                          ; pc=0x00E4 ; target=.L_ir_1_main_end ; addr=0x00F8
    jal x0, 4                                           ; pc=0x00E8 ; target=L_end_if_3 ; addr=0x00EC
L_else_2:
L_end_if_3:
    addi x7, x0, 0                                      ; pc=0x00EC
    add x11, x7, x0                                     ; pc=0x00F0
    jal x0, 4                                           ; pc=0x00F4 ; target=.L_ir_1_main_end ; addr=0x00F8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00F8
    addi x2, x2, 60                                     ; pc=0x00FC
    freeze                                              ; pc=0x0100

seleccionar:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0104
    sw x1, 0(x2)                                        ; pc=0x0108
    sw x17, 4(x2)                                       ; pc=0x010C
    addi x17, x2, 20                                    ; pc=0x0110

    add x3, x11, x0 ; parametro promovido valor         ; pc=0x0114
    add x4, x12, x0 ; parametro promovido respaldo      ; pc=0x0118

    addi x6, x0, 0                                      ; pc=0x011C
    blt x3, x4, 8                                       ; pc=0x0120 ; target=.L_ir_5_ir_cmp_true ; addr=0x0128
    jal x0, 8                                           ; pc=0x0124 ; target=.L_ir_6_ir_cmp_end ; addr=0x012C
.L_ir_5_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0128
.L_ir_6_ir_cmp_end:
    add x5, x6, x0 ; promote t0                         ; pc=0x012C
    beq x5, x0, 16                                      ; pc=0x0130 ; target=L_else_0 ; addr=0x0140
    add x11, x4, x0                                     ; pc=0x0134
    jal x0, 16                                          ; pc=0x0138 ; target=.L_ir_4_seleccionar_end ; addr=0x0148
    jal x0, 4                                           ; pc=0x013C ; target=L_end_if_1 ; addr=0x0140
L_else_0:
L_end_if_1:
    add x11, x3, x0                                     ; pc=0x0140
    jal x0, 4                                           ; pc=0x0144 ; target=.L_ir_4_seleccionar_end ; addr=0x0148
.L_ir_4_seleccionar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0148
    lw x17, 4(x2)                                       ; pc=0x014C
    addi x2, x2, 20                                     ; pc=0x0150
    jalr x1, 0                                          ; pc=0x0154