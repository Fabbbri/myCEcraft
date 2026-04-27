; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    lwv v0, 0(v0)                                       ; pc=0x0004
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x0008
    sw x1, 0(x2)                                        ; pc=0x000C
    sw x17, 4(x2)                                       ; pc=0x0010
    addi x17, x2, 16                                    ; pc=0x0014

    addi x3, x0, 0                                      ; pc=0x0018
    sw x3, -4(x17) ; x                                  ; pc=0x001C

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0020
    addi x4, x0, 5                                      ; pc=0x0024
    bge x3, x4, .L1_while_end                           ; pc=0x0028
    lw x4, -4(x17) ; x                                  ; pc=0x002C
    addi x3, x0, 1                                      ; pc=0x0030
    add x5, x4, x3                                      ; pc=0x0034
    sw x5, -4(x17) ; x                                  ; pc=0x0038
    jal x0, .L0_while_start                             ; pc=0x003C
.L1_while_end:

    lw x5, -4(x17) ; x                                  ; pc=0x0040
    add x11, x5, x0                                     ; pc=0x0044
    jal x0, .L_codegen_1_main_end                       ; pc=0x0048
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x004C
    lw x17, 4(x2)                                       ; pc=0x0050
    addi x2, x2, 16                                     ; pc=0x0054
    jalr x1, 0                                          ; pc=0x0058