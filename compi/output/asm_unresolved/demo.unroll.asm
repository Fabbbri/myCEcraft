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
    addiSigned x2, x2, -24                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 24                                    ; pc=0x002C

    addi x7, x0, 0                                      ; pc=0x0030
    add x3, x7, x0 ; promote x                          ; pc=0x0034
L_while_start_0:
    addi x8, x0, 4                                      ; pc=0x0038
    addi x9, x0, 0                                      ; pc=0x003C
    blt x3, x8, .L_ir_2_ir_cmp_true                     ; pc=0x0040
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0044
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0048
.L_ir_3_ir_cmp_end:
    add x4, x9, x0 ; promote t2                         ; pc=0x004C
    beq x4, x0, L_while_end_1                           ; pc=0x0050
    addi x10, x0, 2                                     ; pc=0x0054
    add x7, x3, x10                                     ; pc=0x0058
    add x3, x7, x0 ; promote x                          ; pc=0x005C
    jal x0, L_while_start_0                             ; pc=0x0060
L_while_end_1:
    addi x9, x0, 1                                      ; pc=0x0064
    add x8, x3, x9                                      ; pc=0x0068
    add x3, x8, x0 ; promote x                          ; pc=0x006C
    add x11, x3, x0                                     ; pc=0x0070
    jal x0, .L_ir_1_main_end                            ; pc=0x0074
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0078
    addi x2, x2, 24                                     ; pc=0x007C
    freeze                                              ; pc=0x0080