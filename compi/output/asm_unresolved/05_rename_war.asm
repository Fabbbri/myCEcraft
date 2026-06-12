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
    addiSigned x2, x2, -32                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 32                                    ; pc=0x002C

    addi x7, x0, 7                                      ; pc=0x0030
    add x3, x7, x0 ; promote dato                       ; pc=0x0034
    addi x8, x0, 3                                      ; pc=0x0038
    mul x9, x3, x8                                      ; pc=0x003C
    add x4, x9, x0 ; promote viejo                      ; pc=0x0040
    addi x10, x0, 2                                     ; pc=0x0044
    add x3, x10, x0 ; promote dato                      ; pc=0x0048
    addi x7, x0, 5                                      ; pc=0x004C
    mul x9, x3, x7                                      ; pc=0x0050
    add x5, x9, x0 ; promote nuevo                      ; pc=0x0054
    add x8, x4, x5                                      ; pc=0x0058
    sw x8, -24(x17) ; t2                                ; pc=0x005C
    lw x10, -24(x17) ; t2                               ; pc=0x0060
    add x11, x10, x0                                    ; pc=0x0064
    jal x0, .L_ir_1_main_end                            ; pc=0x0068
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x006C
    addi x2, x2, 32                                     ; pc=0x0070
    freeze                                              ; pc=0x0074