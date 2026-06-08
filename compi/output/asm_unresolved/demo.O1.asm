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
    addiSigned x2, x2, -16                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 16                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -4(x17) ; x                                  ; pc=0x0034

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0038
    addi x4, x0, 4                                      ; pc=0x003C
    bge x3, x4, .L1_while_end                           ; pc=0x0040
    lw x4, -4(x17) ; x                                  ; pc=0x0044
    addi x3, x0, 2                                      ; pc=0x0048
    add x5, x4, x3                                      ; pc=0x004C
    sw x5, -4(x17) ; x                                  ; pc=0x0050
    jal x0, .L0_while_start                             ; pc=0x0054
.L1_while_end:

    lw x5, -4(x17) ; x                                  ; pc=0x0058
    addi x3, x0, 1                                      ; pc=0x005C
    add x4, x5, x3                                      ; pc=0x0060
    sw x4, -4(x17) ; x                                  ; pc=0x0064
    lw x4, -4(x17) ; x                                  ; pc=0x0068
    add x11, x4, x0                                     ; pc=0x006C
    jal x0, .L_codegen_1_main_end                       ; pc=0x0070
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0074
    addi x2, x2, 16                                     ; pc=0x0078
    freeze                                              ; pc=0x007C