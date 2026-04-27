; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

main:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 16                                    ; pc=0x000C

    addi x3, x0, 0                                      ; pc=0x0010
    sw x3, -4(x17) ; x                                  ; pc=0x0014

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0018
    addi x4, x0, 5                                      ; pc=0x001C
    bge x3, x4, .L1_while_end                           ; pc=0x0020
    lw x4, -4(x17) ; x                                  ; pc=0x0024
    addi x3, x0, 1                                      ; pc=0x0028
    add x5, x4, x3                                      ; pc=0x002C
    sw x5, -4(x17) ; x                                  ; pc=0x0030
    jal x0, .L0_while_start                             ; pc=0x0034
.L1_while_end:

    lw x5, -4(x17) ; x                                  ; pc=0x0038
    add x11, x5, x0                                     ; pc=0x003C
    jal x0, .L_codegen_0_main_end                       ; pc=0x0040
.L_codegen_0_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0044
    lw x17, 4(x2)                                       ; pc=0x0048
    addi x2, x2, 16                                     ; pc=0x004C
    jalr x1, 0                                          ; pc=0x0050