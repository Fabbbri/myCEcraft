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
    addiSigned x2, x2, -64                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 64                                    ; pc=0x002C

    addi x5, x0, 4                                      ; pc=0x0030
    sw x5, -8(x17) ; datos[0]                           ; pc=0x0034
    addi x6, x0, 9                                      ; pc=0x0038
    sw x6, -4(x17) ; datos[1]                           ; pc=0x003C
    addi x7, x0, 0                                      ; pc=0x0040
    add x8, x7, x7                                      ; pc=0x0044
    add x8, x8, x8                                      ; pc=0x0048
    addiSigned x9, x17, -8                              ; pc=0x004C
    add x9, x9, x8                                      ; pc=0x0050
    lw x10, 0(x9)                                       ; pc=0x0054
    sw x10, -32(x17) ; t3                               ; pc=0x0058
    addi x5, x0, 6                                      ; pc=0x005C
    sw x5, -16(x17) ; b                                 ; pc=0x0060
    lw x6, -32(x17) ; t3                                ; pc=0x0064
    sw x6, -12(x17) ; a                                 ; pc=0x0068
    addi x8, x0, 7                                      ; pc=0x006C
    addi x7, x0, 2                                      ; pc=0x0070
    mul x9, x8, x7                                      ; pc=0x0074
    add x4, x9, x0 ; promote independiente              ; pc=0x0078
    lw x10, -12(x17) ; a                                ; pc=0x007C
    lw x5, -16(x17) ; b                                 ; pc=0x0080
    add x6, x10, x5                                     ; pc=0x0084
    sw x6, -24(x17) ; combinado                         ; pc=0x0088
    lw x9, -24(x17) ; combinado                         ; pc=0x008C
    add x11, x9, x0                                     ; pc=0x0090
    sw x4, -20(x17) ; independiente                     ; pc=0x0094
    jal x1, ajustar                                     ; pc=0x0098
    add x7, x11, x0                                     ; pc=0x009C
    sw x7, -44(x17) ; t6                                ; pc=0x00A0
    lw x8, -44(x17) ; t6                                ; pc=0x00A4
    add x3, x8, x0 ; promote resultado                  ; pc=0x00A8
    addi x6, x0, 10                                     ; pc=0x00AC
    addi x5, x0, 0                                      ; pc=0x00B0
    blt x6, x3, .L_ir_2_ir_cmp_true                     ; pc=0x00B4
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x00B8
.L_ir_2_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x00BC
.L_ir_3_ir_cmp_end:
    sw x5, -48(x17) ; t7                                ; pc=0x00C0
    lw x10, -48(x17) ; t7                               ; pc=0x00C4
    beq x10, x0, L_else_2                               ; pc=0x00C8
    lw x4, -20(x17) ; independiente                     ; pc=0x00CC
    add x9, x3, x4                                      ; pc=0x00D0
    sw x9, -52(x17) ; t8                                ; pc=0x00D4
    lw x7, -52(x17) ; t8                                ; pc=0x00D8
    add x11, x7, x0                                     ; pc=0x00DC
    jal x0, .L_ir_1_main_end                            ; pc=0x00E0
    jal x0, L_end_if_3                                  ; pc=0x00E4
L_else_2:
    sub x8, x4, x3                                      ; pc=0x00E8
    sw x8, -56(x17) ; t9                                ; pc=0x00EC
    lw x5, -56(x17) ; t9                                ; pc=0x00F0
    add x11, x5, x0                                     ; pc=0x00F4
    jal x0, .L_ir_1_main_end                            ; pc=0x00F8
L_end_if_3:
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00FC
    addi x2, x2, 64                                     ; pc=0x0100
    freeze                                              ; pc=0x0104

ajustar:
    ; prologue
    addiSigned x2, x2, -24                              ; pc=0x0108
    sw x1, 0(x2)                                        ; pc=0x010C
    sw x17, 4(x2)                                       ; pc=0x0110
    addi x17, x2, 24                                    ; pc=0x0114

    add x3, x11, x0 ; parametro promovido valor         ; pc=0x0118

    addi x7, x0, 10                                     ; pc=0x011C
    addi x8, x0, 0                                      ; pc=0x0120
    blt x7, x3, .L_ir_5_ir_cmp_true                     ; pc=0x0124
    jal x0, .L_ir_6_ir_cmp_end                          ; pc=0x0128
.L_ir_5_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x012C
.L_ir_6_ir_cmp_end:
    add x4, x8, x0 ; promote t0                         ; pc=0x0130
    beq x4, x0, L_else_0                                ; pc=0x0134
    addi x9, x0, 3                                      ; pc=0x0138
    sub x10, x3, x9                                     ; pc=0x013C
    add x5, x10, x0 ; promote t1                        ; pc=0x0140
    add x11, x5, x0                                     ; pc=0x0144
    jal x0, .L_ir_4_ajustar_end                         ; pc=0x0148
    jal x0, L_end_if_1                                  ; pc=0x014C
L_else_0:
    addi x8, x0, 3                                      ; pc=0x0150
    add x7, x3, x8                                      ; pc=0x0154
    add x6, x7, x0 ; promote t2                         ; pc=0x0158
    add x11, x6, x0                                     ; pc=0x015C
    jal x0, .L_ir_4_ajustar_end                         ; pc=0x0160
L_end_if_1:
.L_ir_4_ajustar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0164
    lw x17, 4(x2)                                       ; pc=0x0168
    addi x2, x2, 24                                     ; pc=0x016C
    jalr x1, 0                                          ; pc=0x0170