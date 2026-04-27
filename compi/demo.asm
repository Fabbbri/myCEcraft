; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

main:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 20                                    ; pc=0x000C

    addi x3, x0, 0                                      ; pc=0x0010
    sw x3, -4(x17) ; total                              ; pc=0x0014

    ; for
    addi x3, x0, 0                                      ; pc=0x0018
    sw x3, -8(x17) ; i                                  ; pc=0x001C
.L_codegen_1_for_start:
    lw x3, -8(x17) ; i                                  ; pc=0x0020
    addi x4, x0, 5                                      ; pc=0x0024
    bge x3, x4, .L_codegen_2_for_end                    ; pc=0x0028
    lw x4, -4(x17) ; total                              ; pc=0x002C
    lw x3, -8(x17) ; i                                  ; pc=0x0030
    add x5, x4, x3                                      ; pc=0x0034
    sw x5, -4(x17) ; total                              ; pc=0x0038
    lw x5, -8(x17) ; i                                  ; pc=0x003C
    addi x3, x0, 1                                      ; pc=0x0040
    add x4, x5, x3                                      ; pc=0x0044
    sw x4, -8(x17) ; i                                  ; pc=0x0048
    jal x0, .L_codegen_1_for_start                      ; pc=0x004C
.L_codegen_2_for_end:

    lw x4, -4(x17) ; total                              ; pc=0x0050
    add x11, x4, x0                                     ; pc=0x0054
    jal x0, .L_codegen_0_main_end                       ; pc=0x0058
.L_codegen_0_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x005C
    lw x17, 4(x2)                                       ; pc=0x0060
    addi x2, x2, 20                                     ; pc=0x0064
    jalr x1, 0                                          ; pc=0x0068