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
    nop
    nop
    nop
    sw x1, 0(x2)                                        ; pc=0x0010
    sw x17, 4(x2)                                       ; pc=0x0014
    addi x17, x2, 16                                    ; pc=0x0018

    addi x3, x0, 0                                      ; pc=0x001C
    nop
    nop
    nop
    sw x3, -4(x17) ; x                                  ; pc=0x0020
    addi x3, x0, 12                                     ; pc=0x0024
    addi x4, x0, 1                                      ; pc=0x0028
    nop
    nop
    add x5, x3, x4                                      ; pc=0x002C
    nop
    nop
    nop
    sw x5, -4(x17) ; x                                  ; pc=0x0030
    lw x5, -4(x17) ; x                                  ; pc=0x0034
    nop
    nop
    nop
    add x11, x5, x0                                     ; pc=0x0038
    jal x0, .L_codegen_1_main_end                       ; pc=0x003C
    sleep ; nop despues de control                      ; pc=0x0040
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0044
    nop
    lw x17, 4(x2)                                       ; pc=0x0048
    addi x2, x2, 16                                     ; pc=0x004C
    jalr x1, 0                                          ; pc=0x0050
    sleep ; nop despues de control                      ; pc=0x0054