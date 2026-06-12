; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_ir_0_enderExit                   ; pc=0x0000
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
    addi x6, x0, 5                                      ; pc=0x0064
    addi x7, x0, 6                                      ; pc=0x0068
    add x9, x6, x7                                      ; pc=0x006C
    sw x9, -36(x17) ; t2                                ; pc=0x0070
    lw x8, -32(x17) ; t1                                ; pc=0x0074
    sw x8, -16(x17) ; cargado                           ; pc=0x0078
    lw x10, -36(x17) ; t2                               ; pc=0x007C
    add x3, x10, x0 ; promote independiente             ; pc=0x0080
    lw x5, -16(x17) ; cargado                           ; pc=0x0084
    addi x9, x0, 1                                      ; pc=0x0088
    add x7, x5, x9                                      ; pc=0x008C
    sw x7, -24(x17) ; candidato                         ; pc=0x0090
    lw x6, -24(x17) ; candidato                         ; pc=0x0094
    add x11, x6, x0                                     ; pc=0x0098
    add x12, x3, x0                                     ; pc=0x009C
    sw x3, -20(x17) ; independiente                     ; pc=0x00A0
    jal x1, seleccionar                                 ; pc=0x00A4
    add x8, x11, x0                                     ; pc=0x00A8
    sw x8, -44(x17) ; t4                                ; pc=0x00AC
    lw x10, -44(x17) ; t4                               ; pc=0x00B0
    add x4, x10, x0 ; promote elegido                   ; pc=0x00B4
    addi x7, x0, 22                                     ; pc=0x00B8
    addi x9, x0, 0                                      ; pc=0x00BC
    beq x4, x7, .L_ir_2_ir_cmp_true                     ; pc=0x00C0
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x00C4
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x00C8
.L_ir_3_ir_cmp_end:
    sw x9, -48(x17) ; t5                                ; pc=0x00CC
    lw x5, -48(x17) ; t5                                ; pc=0x00D0
    beq x5, x0, L_else_2                                ; pc=0x00D4
    lw x3, -20(x17) ; independiente                     ; pc=0x00D8
    add x6, x4, x3                                      ; pc=0x00DC
    sw x6, -52(x17) ; t6                                ; pc=0x00E0
    lw x8, -52(x17) ; t6                                ; pc=0x00E4
    add x11, x8, x0                                     ; pc=0x00E8
    jal x0, .L_ir_1_main_end                            ; pc=0x00EC
    jal x0, L_end_if_3                                  ; pc=0x00F0
L_else_2:
L_end_if_3:
    addi x10, x0, 0                                     ; pc=0x00F4
    add x11, x10, x0                                    ; pc=0x00F8
    jal x0, .L_ir_1_main_end                            ; pc=0x00FC
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0100
    addi x2, x2, 60                                     ; pc=0x0104
    freeze                                              ; pc=0x0108

seleccionar:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x010C
    sw x1, 0(x2)                                        ; pc=0x0110
    sw x17, 4(x2)                                       ; pc=0x0114
    addi x17, x2, 20                                    ; pc=0x0118

    add x3, x11, x0 ; parametro promovido valor         ; pc=0x011C
    add x4, x12, x0 ; parametro promovido respaldo      ; pc=0x0120

    addi x6, x0, 0                                      ; pc=0x0124
    blt x3, x4, .L_ir_5_ir_cmp_true                     ; pc=0x0128
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x012C
.L_ir_5_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0130
.L_ir_6_ir_cmp_end:
    add x5, x6, x0 ; promote t0                         ; pc=0x0134
    beq x5, x0, L_else_0                                ; pc=0x0138
    add x11, x4, x0                                     ; pc=0x013C
    jal x0, .L_ir_4_seleccionar_end                     ; pc=0x0140
    jal x0, L_end_if_1                                  ; pc=0x0144
L_else_0:
L_end_if_1:
    add x11, x3, x0                                     ; pc=0x0148
    jal x0, .L_ir_4_seleccionar_end                     ; pc=0x014C
.L_ir_4_seleccionar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0150
    lw x17, 4(x2)                                       ; pc=0x0154
    addi x2, x2, 20                                     ; pc=0x0158
    jalr x1, 0                                          ; pc=0x015C