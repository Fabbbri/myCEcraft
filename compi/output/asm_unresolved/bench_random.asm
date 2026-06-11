; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    lwv v0, 0(v0)                                       ; pc=0x0004
    sleep ; stall RAW                                   ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0014
.L_codegen_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0018
    addi x2, x2, 0x7FF0                                 ; pc=0x001C

    ; prologue
    addiSigned x2, x2, -3848                            ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 3848                                  ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -1920(x17) ; arr                             ; pc=0x0034
    addi x3, x0, 0                                      ; pc=0x0038
    sw x3, -1924(x17) ; i                               ; pc=0x003C
    addi x3, x0, 0                                      ; pc=0x0040
    sw x3, -1928(x17) ; idx                             ; pc=0x0044
    addi x3, x0, 0                                      ; pc=0x0048
    sw x3, -1932(x17) ; suma                            ; pc=0x004C

.L0_while_start:
    lw x3, -1924(x17) ; i                               ; pc=0x0050
    addi x4, x0, 480                                    ; pc=0x0054
    bge x3, x4, .L1_while_end                           ; pc=0x0058
    lw x4, -1924(x17) ; i                               ; pc=0x005C
    lw x3, -1924(x17) ; i                               ; pc=0x0060
    add x5, x3, x3                                      ; pc=0x0064
    add x5, x5, x5                                      ; pc=0x0068
    addiSigned x6, x17, -1920                           ; pc=0x006C
    ; base arr
    add x6, x6, x5                                      ; pc=0x0070
    sw x4, 0(x6)                                        ; pc=0x0074
    lw x4, -1924(x17) ; i                               ; pc=0x0078
    addi x6, x0, 1                                      ; pc=0x007C
    add x5, x4, x6                                      ; pc=0x0080
    sw x5, -1924(x17) ; i                               ; pc=0x0084
    jal x0, .L0_while_start                             ; pc=0x0088
.L1_while_end:

    addi x5, x0, 0                                      ; pc=0x008C
    sw x5, -1924(x17) ; i                               ; pc=0x0090
    addi x5, x0, 0                                      ; pc=0x0094
    sw x5, -1928(x17) ; idx                             ; pc=0x0098

.L2_while_start:
    lw x5, -1924(x17) ; i                               ; pc=0x009C
    addi x6, x0, 480                                    ; pc=0x00A0
    bge x5, x6, .L3_while_end                           ; pc=0x00A4
    lw x6, -1932(x17) ; suma                            ; pc=0x00A8
    lw x5, -1928(x17) ; idx                             ; pc=0x00AC
    add x4, x5, x5                                      ; pc=0x00B0
    add x4, x4, x4                                      ; pc=0x00B4
    addiSigned x3, x17, -1920                           ; pc=0x00B8
    ; base arr
    add x3, x3, x4                                      ; pc=0x00BC
    lw x4, 0(x3)                                        ; pc=0x00C0
    add x3, x6, x4                                      ; pc=0x00C4
    sw x3, -1932(x17) ; suma                            ; pc=0x00C8
    lw x3, -1928(x17) ; idx                             ; pc=0x00CC
    addi x4, x0, 341                                    ; pc=0x00D0
    add x6, x3, x4                                      ; pc=0x00D4
    sw x6, -1928(x17) ; idx                             ; pc=0x00D8

    ; if
    lw x6, -1928(x17) ; idx                             ; pc=0x00DC
    addi x4, x0, 480                                    ; pc=0x00E0
    blt x6, x4, .L4_if_else                             ; pc=0x00E4
    lw x4, -1928(x17) ; idx                             ; pc=0x00E8
    addi x6, x0, 480                                    ; pc=0x00EC
    sub x3, x4, x6                                      ; pc=0x00F0
    sw x3, -1928(x17) ; idx                             ; pc=0x00F4
    jal x0, .L5_if_end                                  ; pc=0x00F8
.L4_if_else:
.L5_if_end:

    lw x3, -1924(x17) ; i                               ; pc=0x00FC
    addi x6, x0, 1                                      ; pc=0x0100
    add x4, x3, x6                                      ; pc=0x0104
    sw x4, -1924(x17) ; i                               ; pc=0x0108
    jal x0, .L2_while_start                             ; pc=0x010C
.L3_while_end:

    lw x4, -1932(x17) ; suma                            ; pc=0x0110
    add x11, x4, x0                                     ; pc=0x0114
    jal x0, .L_codegen_1_main_end                       ; pc=0x0118
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x011C
    addi x2, x2, 3848                                   ; pc=0x0120
    freeze                                              ; pc=0x0124