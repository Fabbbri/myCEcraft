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

    addi x3, x0, 3                                      ; pc=0x0030
    add x11, x3, x0                                     ; pc=0x0034
    jal x1, suma2                                       ; pc=0x0038
    add x4, x11, x0                                     ; pc=0x003C
    add x6, x4, x0 ; promote t3__x6                     ; pc=0x0040
    add x11, x6, x0                                     ; pc=0x0044
    jal x0, .L_ir_1_main_end                            ; pc=0x0048
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x004C
    addi x2, x2, 12                                     ; pc=0x0050
    freeze                                              ; pc=0x0054

suma1:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x0058
    sw x1, 0(x2)                                        ; pc=0x005C
    sw x17, 4(x2)                                       ; pc=0x0060
    addi x17, x2, 16                                    ; pc=0x0064

    add x3, x11, x0 ; parametro promovido x             ; pc=0x0068

    addi x5, x0, 1                                      ; pc=0x006C
    add x6, x3, x5                                      ; pc=0x0070
    add x4, x6, x0 ; promote t0__x3                     ; pc=0x0074
    add x11, x4, x0                                     ; pc=0x0078
    jal x0, .L_ir_2_suma1_end                           ; pc=0x007C
.L_ir_2_suma1_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0080
    lw x17, 4(x2)                                       ; pc=0x0084
    addi x2, x2, 16                                     ; pc=0x0088
    jalr x1, 0                                          ; pc=0x008C

suma2:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0090
    sw x1, 0(x2)                                        ; pc=0x0094
    sw x17, 4(x2)                                       ; pc=0x0098
    addi x17, x2, 20                                    ; pc=0x009C

    add x3, x11, x0 ; parametro promovido x             ; pc=0x00A0

    add x11, x3, x0                                     ; pc=0x00A4
    sw x3, -4(x17) ; x                                  ; pc=0x00A8
    jal x1, suma1                                       ; pc=0x00AC
    add x6, x11, x0                                     ; pc=0x00B0
    add x4, x6, x0 ; promote t1__x4                     ; pc=0x00B4
    addi x7, x0, 1                                      ; pc=0x00B8
    add x8, x4, x7                                      ; pc=0x00BC
    add x5, x8, x0 ; promote t2__x5                     ; pc=0x00C0
    add x11, x5, x0                                     ; pc=0x00C4
    jal x0, .L_ir_3_suma2_end                           ; pc=0x00C8
.L_ir_3_suma2_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00CC
    lw x17, 4(x2)                                       ; pc=0x00D0
    addi x2, x2, 20                                     ; pc=0x00D4
    jalr x1, 0                                          ; pc=0x00D8