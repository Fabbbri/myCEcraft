; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    sleep ; nop despues de control                      ; pc=0x0004
    lwv v0, 0(v0)                                       ; pc=0x0008
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x000C
    sw x1, 0(x2)                                        ; pc=0x0010
    sw x17, 4(x2)                                       ; pc=0x0014
    addi x17, x2, 16                                    ; pc=0x0018

    addi x3, x0, 12441                                  ; pc=0x001C
    sw x3, -4(x17) ; num                                ; pc=0x0020
    addi x3, x0, 2121                                   ; pc=0x0024
    addiHIGH x4, x0, 0                                  ; pc=0x0028
    add x3, x3, x4                                      ; pc=0x002C
    portalv x3, x0, .L_codegen_2_endchange ; enderPortal ; pc=0x0030
    sleep ; nop despues de control                      ; pc=0x0034
    lw x3, -4(x17) ; num                                ; pc=0x0038
    addiHIGH x4, x0, 0                                  ; pc=0x003C
    addi x4, x4, 65535                                  ; pc=0x0040
    and x5, x3, x4                                      ; pc=0x0044
    addi x6, x0, 16                                     ; pc=0x0048
    srl x7, x3, x6                                      ; pc=0x004C
    changev v0, x5, x7 ; enderchange                    ; pc=0x0050
    swv v0, 0(v0)                                       ; pc=0x0054
    closev ; enderclose                                 ; pc=0x0058
.L_codegen_2_endchange:
    addi x3, x0, 0                                      ; pc=0x005C
    add x11, x3, x0                                     ; pc=0x0060
    jal x0, .L_codegen_1_main_end                       ; pc=0x0064
    sleep ; nop despues de control                      ; pc=0x0068
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x006C
    lw x17, 4(x2)                                       ; pc=0x0070
    addi x2, x2, 16                                     ; pc=0x0074
    jalr x1, 0                                          ; pc=0x0078
    sleep ; nop despues de control                      ; pc=0x007C