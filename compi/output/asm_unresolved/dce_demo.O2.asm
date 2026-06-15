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
    addiSigned x2, x2, -36                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 36                                    ; pc=0x002C

    addi x7, x0, 1                                      ; pc=0x0030
    add x3, x7, x0 ; promote x                          ; pc=0x0034
    addi x8, x0, 2                                      ; pc=0x0038
    add x4, x8, x0 ; promote y                          ; pc=0x003C
    add x9, x3, x4                                      ; pc=0x0040
    add x5, x9, x0 ; promote z                          ; pc=0x0044
    addi x10, x0, 4                                     ; pc=0x0048
    add x7, x5, x10                                     ; pc=0x004C
    add x6, x7, x0 ; promote vivo                       ; pc=0x0050
    add x11, x6, x0                                     ; pc=0x0054
    jal x0, .L_ir_1_main_end                            ; pc=0x0058
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x005C
    addi x2, x2, 36                                     ; pc=0x0060
    freeze                                              ; pc=0x0064