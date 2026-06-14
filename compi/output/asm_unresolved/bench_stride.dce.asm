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
    addiSigned x2, x2, -1064                            ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 1064                                  ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    sw x5, -1024(x17) ; arr                             ; pc=0x0034
    addi x6, x0, 0                                      ; pc=0x0038
    add x3, x6, x0 ; promote i                          ; pc=0x003C
    addi x7, x0, 0                                      ; pc=0x0040
    add x4, x7, x0 ; promote suma                       ; pc=0x0044
L_while_start_0:
    addi x8, x0, 256                                    ; pc=0x0048
    addi x9, x0, 0                                      ; pc=0x004C
    blt x3, x8, .L_ir_2_ir_cmp_true                     ; pc=0x0050
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0054
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0058
.L_ir_3_ir_cmp_end:
    sw x9, -1036(x17) ; t0                              ; pc=0x005C
    lw x10, -1036(x17) ; t0                             ; pc=0x0060
    beq x10, x0, L_while_end_1                          ; pc=0x0064
    add x5, x3, x3                                      ; pc=0x0068
    add x5, x5, x5                                      ; pc=0x006C
    addiSigned x6, x17, -1024                           ; pc=0x0070
    add x6, x6, x5                                      ; pc=0x0074
    sw x3, 0(x6)                                        ; pc=0x0078
    addi x7, x0, 8                                      ; pc=0x007C
    add x9, x3, x7                                      ; pc=0x0080
    add x3, x9, x0 ; promote i                          ; pc=0x0084
    jal x0, L_while_start_0                             ; pc=0x0088
L_while_end_1:
    addi x8, x0, 0                                      ; pc=0x008C
    add x3, x8, x0 ; promote i                          ; pc=0x0090
L_while_start_2:
    addi x10, x0, 256                                   ; pc=0x0094
    addi x5, x0, 0                                      ; pc=0x0098
    blt x3, x10, .L_ir_4_ir_cmp_true                    ; pc=0x009C
    jal x0, .L_ir_5_ir_cmp_end                          ; pc=0x00A0
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x00A4
.L_ir_5_ir_cmp_end:
    sw x5, -1044(x17) ; t2                              ; pc=0x00A8
    lw x6, -1044(x17) ; t2                              ; pc=0x00AC
    beq x6, x0, L_while_end_3                           ; pc=0x00B0
    add x9, x3, x3                                      ; pc=0x00B4
    add x9, x9, x9                                      ; pc=0x00B8
    addiSigned x7, x17, -1024                           ; pc=0x00BC
    add x7, x7, x9                                      ; pc=0x00C0
    lw x8, 0(x7)                                        ; pc=0x00C4
    sw x8, -1048(x17) ; t3                              ; pc=0x00C8
    lw x5, -1048(x17) ; t3                              ; pc=0x00CC
    add x10, x4, x5                                     ; pc=0x00D0
    add x4, x10, x0 ; promote suma                      ; pc=0x00D4
    addi x6, x0, 8                                      ; pc=0x00D8
    add x9, x3, x6                                      ; pc=0x00DC
    add x3, x9, x0 ; promote i                          ; pc=0x00E0
    jal x0, L_while_start_2                             ; pc=0x00E4
L_while_end_3:
    add x11, x4, x0                                     ; pc=0x00E8
    jal x0, .L_ir_1_main_end                            ; pc=0x00EC
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00F0
    addi x2, x2, 1064                                   ; pc=0x00F4
    freeze                                              ; pc=0x00F8