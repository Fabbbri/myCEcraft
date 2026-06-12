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
    addiSigned x2, x2, -12                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 12                                    ; pc=0x002C

    addi x4, x0, 2121                                   ; pc=0x0030
    add x3, x4, x0 ; promote password                   ; pc=0x0034
    portalv x3, v0, L_endchange_0 ; enderPortal         ; pc=0x0038
    addi x1, v0, 38563 ; key[0] low                     ; pc=0x003C
    addiHIGHv v1, x1, 35 ; key[0] high                  ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    swv v1, 0(v0) ; key[0]                              ; pc=0x0050
    addi x1, v0, 1234 ; key[1] low                      ; pc=0x0054
    addiHIGHv v1, x1, 0 ; key[1] high                   ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064
    swv v1, 4(v0) ; key[1]                              ; pc=0x0068
    addi x1, v0, 13234 ; key[2] low                     ; pc=0x006C
    addiHIGHv v1, x1, 0 ; key[2] high                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sleep ; stall RAW                                   ; pc=0x0078
    sleep ; stall RAW                                   ; pc=0x007C
    swv v1, 8(v0) ; key[2]                              ; pc=0x0080
    addi x1, v0, 124 ; key[3] low                       ; pc=0x0084
    addiHIGHv v1, x1, 0 ; key[3] high                   ; pc=0x0088
    sleep ; stall RAW                                   ; pc=0x008C
    sleep ; stall RAW                                   ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    swv v1, 12(v0) ; key[3]                             ; pc=0x0098
    addi x1, v0, 0x1234 ; enderlow                      ; pc=0x009C
    addiHIGHv v2, x1, 0xABCD ; enderhigh                ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    changev v2, v1 ; enderkey                           ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    sleep ; stall RAW                                   ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    lwv v3, 0(v0) ; enderload                           ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sleep ; stall RAW                                   ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    swv v3, 4(v0) ; enderstore                          ; pc=0x00D0
    closev ; enderclose                                 ; pc=0x00D4
L_endchange_0:
    addi x5, x0, 0                                      ; pc=0x00D8
    add x11, x5, x0                                     ; pc=0x00DC
    jal x0, .L_ir_1_main_end                            ; pc=0x00E0
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00E4
    addi x2, x2, 12                                     ; pc=0x00E8
    freeze                                              ; pc=0x00EC