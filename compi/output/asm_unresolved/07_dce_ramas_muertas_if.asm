; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
estado: ; addr=0x8000
    .word 0

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
    addiSigned x2, x2, -84                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 84                                    ; pc=0x002C

    addi x7, x0, 7                                      ; pc=0x0030
    add x3, x7, x0 ; promote base                       ; pc=0x0034
    addi x8, x0, 0                                      ; pc=0x0038
    addi x9, x0, 0                                      ; pc=0x003C
    blt x8, x3, .L_ir_2_ir_cmp_true                     ; pc=0x0040
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0044
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0048
.L_ir_3_ir_cmp_end:
    sw x9, -40(x17) ; t1                                ; pc=0x004C
    lw x10, -40(x17) ; t1                               ; pc=0x0050
    beq x10, x0, L_else_0                               ; pc=0x0054
    addi x7, x0, 3                                      ; pc=0x0058
    add x9, x3, x7                                      ; pc=0x005C
    add x4, x9, x0 ; promote m1                         ; pc=0x0060
    add x8, x4, x4                                      ; pc=0x0064
    add x5, x8, x0 ; promote m2                         ; pc=0x0068
    add x10, x5, x4                                     ; pc=0x006C
    sw x10, -16(x17) ; m3                               ; pc=0x0070
    lw x9, -16(x17) ; m3                                ; pc=0x0074
    add x7, x9, x5                                      ; pc=0x0078
    sw x7, -20(x17) ; m4                                ; pc=0x007C
    jal x0, L_end_if_1                                  ; pc=0x0080
L_else_0:
    addi x8, x0, 9                                      ; pc=0x0084
    add x10, x3, x8                                     ; pc=0x0088
    add x6, x10, x0 ; promote n1                        ; pc=0x008C
    add x7, x6, x6                                      ; pc=0x0090
    sw x7, -28(x17) ; n2                                ; pc=0x0094
    lw x9, -28(x17) ; n2                                ; pc=0x0098
    add x10, x9, x6                                     ; pc=0x009C
    sw x10, -32(x17) ; n3                               ; pc=0x00A0
    lw x8, -32(x17) ; n3                                ; pc=0x00A4
    lw x7, -28(x17) ; n2                                ; pc=0x00A8
    add x10, x8, x7                                     ; pc=0x00AC
    sw x10, -36(x17) ; n4                               ; pc=0x00B0
L_end_if_1:
    addi x9, x0, 5                                      ; pc=0x00B4
    add x11, x9, x0                                     ; pc=0x00B8
    sw x3, -4(x17) ; base                               ; pc=0x00BC
    sw x4, -8(x17) ; m1                                 ; pc=0x00C0
    sw x5, -12(x17) ; m2                                ; pc=0x00C4
    sw x6, -24(x17) ; n1                                ; pc=0x00C8
    jal x1, marcar                                      ; pc=0x00CC
    add x10, x11, x0                                    ; pc=0x00D0
    sw x10, -76(x17) ; t10                              ; pc=0x00D4
    addiHIGH x8, x0, 0                                  ; pc=0x00D8
    addi x8, x8, 32768                                  ; pc=0x00DC
    lw x7, 0(x8) ; estado                               ; pc=0x00E0
    add x11, x7, x0                                     ; pc=0x00E4
    jal x0, .L_ir_1_main_end                            ; pc=0x00E8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00EC
    addi x2, x2, 84                                     ; pc=0x00F0
    freeze                                              ; pc=0x00F4

marcar:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x00F8
    sw x1, 0(x2)                                        ; pc=0x00FC
    sw x17, 4(x2)                                       ; pc=0x0100
    addi x17, x2, 16                                    ; pc=0x0104

    add x3, x11, x0 ; parametro promovido v             ; pc=0x0108

    addiHIGH x6, x0, 0                                  ; pc=0x010C
    addi x6, x6, 32768                                  ; pc=0x0110
    lw x5, 0(x6) ; estado                               ; pc=0x0114
    add x7, x5, x3                                      ; pc=0x0118
    addiHIGH x8, x0, 0                                  ; pc=0x011C
    addi x8, x8, 32768                                  ; pc=0x0120
    sw x7, 0(x8) ; estado                               ; pc=0x0124
    addiHIGH x10, x0, 0                                 ; pc=0x0128
    addi x10, x10, 32768                                ; pc=0x012C
    lw x9, 0(x10) ; estado                              ; pc=0x0130
    add x11, x9, x0                                     ; pc=0x0134
    jal x0, .L_ir_4_marcar_end                          ; pc=0x0138
.L_ir_4_marcar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x013C
    lw x17, 4(x2)                                       ; pc=0x0140
    addi x2, x2, 16                                     ; pc=0x0144
    jalr x1, 0                                          ; pc=0x0148