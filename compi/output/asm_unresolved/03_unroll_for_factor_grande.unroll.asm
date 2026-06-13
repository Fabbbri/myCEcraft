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
    addiSigned x2, x2, -80                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 80                                    ; pc=0x002C

    addi x7, x0, 0                                      ; pc=0x0030
    add x4, x7, x0 ; promote par                        ; pc=0x0034
    addi x8, x0, 0                                      ; pc=0x0038
    add x5, x8, x0 ; promote impar                      ; pc=0x003C
    addi x9, x0, 0                                      ; pc=0x0040
    add x3, x9, x0 ; promote i                          ; pc=0x0044
L_for_start_0:
    addi x10, x0, 32                                    ; pc=0x0048
    addi x7, x0, 0                                      ; pc=0x004C
    blt x3, x10, .L_ir_2_ir_cmp_true                    ; pc=0x0050
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0054
.L_ir_2_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0058
.L_ir_3_ir_cmp_end:
    add x6, x7, x0 ; promote t6                         ; pc=0x005C
    beq x6, x0, L_for_end_1                             ; pc=0x0060
    add x8, x4, x3                                      ; pc=0x0064
    add x4, x8, x0 ; promote par                        ; pc=0x0068
    add x9, x5, x3                                      ; pc=0x006C
    sw x9, -24(x17) ; t8                                ; pc=0x0070
    lw x7, -24(x17) ; t8                                ; pc=0x0074
    addi x10, x0, 1                                     ; pc=0x0078
    add x8, x7, x10                                     ; pc=0x007C
    add x5, x8, x0 ; promote impar                      ; pc=0x0080
    addi x9, x0, 2                                      ; pc=0x0084
    add x8, x3, x9                                      ; pc=0x0088
    add x10, x4, x8                                     ; pc=0x008C
    add x4, x10, x0 ; promote par                       ; pc=0x0090
    addi x7, x0, 2                                      ; pc=0x0094
    add x9, x3, x7                                      ; pc=0x0098
    add x10, x5, x9                                     ; pc=0x009C
    sw x10, -36(x17) ; t11                              ; pc=0x00A0
    lw x8, -36(x17) ; t11                               ; pc=0x00A4
    addi x7, x0, 1                                      ; pc=0x00A8
    add x10, x8, x7                                     ; pc=0x00AC
    add x5, x10, x0 ; promote impar                     ; pc=0x00B0
    addi x9, x0, 4                                      ; pc=0x00B4
    add x10, x3, x9                                     ; pc=0x00B8
    add x7, x4, x10                                     ; pc=0x00BC
    add x4, x7, x0 ; promote par                        ; pc=0x00C0
    addi x8, x0, 4                                      ; pc=0x00C4
    add x9, x3, x8                                      ; pc=0x00C8
    add x7, x5, x9                                      ; pc=0x00CC
    sw x7, -48(x17) ; t14                               ; pc=0x00D0
    lw x10, -48(x17) ; t14                              ; pc=0x00D4
    addi x8, x0, 1                                      ; pc=0x00D8
    add x7, x10, x8                                     ; pc=0x00DC
    add x5, x7, x0 ; promote impar                      ; pc=0x00E0
    addi x9, x0, 6                                      ; pc=0x00E4
    add x7, x3, x9                                      ; pc=0x00E8
    add x8, x4, x7                                      ; pc=0x00EC
    add x4, x8, x0 ; promote par                        ; pc=0x00F0
    addi x10, x0, 6                                     ; pc=0x00F4
    add x9, x3, x10                                     ; pc=0x00F8
    add x8, x5, x9                                      ; pc=0x00FC
    sw x8, -60(x17) ; t17                               ; pc=0x0100
    lw x7, -60(x17) ; t17                               ; pc=0x0104
    addi x10, x0, 1                                     ; pc=0x0108
    add x8, x7, x10                                     ; pc=0x010C
    add x5, x8, x0 ; promote impar                      ; pc=0x0110
    addi x9, x0, 8                                      ; pc=0x0114
    add x8, x3, x9                                      ; pc=0x0118
    add x3, x8, x0 ; promote i                          ; pc=0x011C
    jal x0, L_for_start_0                               ; pc=0x0120
L_for_end_1:
    add x10, x4, x5                                     ; pc=0x0124
    sw x10, -72(x17) ; t5                               ; pc=0x0128
    lw x7, -72(x17) ; t5                                ; pc=0x012C
    add x11, x7, x0                                     ; pc=0x0130
    jal x0, .L_ir_1_main_end                            ; pc=0x0134
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0138
    addi x2, x2, 80                                     ; pc=0x013C
    freeze                                              ; pc=0x0140