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
    addiSigned x2, x2, -20                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 20                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -4(x17) ; x                                  ; pc=0x0034
L_while_start_0:
    lw x4, -4(x17) ; x                                  ; pc=0x0038
    addi x5, x0, 20                                     ; pc=0x003C
    addi x6, x0, 0                                      ; pc=0x0040
    blt x4, x5, .L_ir_2_ir_cmp_true                     ; pc=0x0044
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0048
.L_ir_2_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x004C
.L_ir_3_ir_cmp_end:
    sw x6, -8(x17) ; t2                                 ; pc=0x0050
    lw x7, -8(x17) ; t2                                 ; pc=0x0054
    beq x7, x0, L_while_end_1                           ; pc=0x0058
    lw x8, -4(x17) ; x                                  ; pc=0x005C
    addi x9, x0, 10                                     ; pc=0x0060
    add x10, x8, x9                                     ; pc=0x0064
    sw x10, -12(x17) ; t3                               ; pc=0x0068
    lw x3, -12(x17) ; t3                                ; pc=0x006C
    sw x3, -4(x17) ; x                                  ; pc=0x0070
    jal x0, L_while_start_0                             ; pc=0x0074
L_while_end_1:
    lw x6, -4(x17) ; x                                  ; pc=0x0078
    add x11, x6, x0                                     ; pc=0x007C
    jal x0, .L_ir_1_main_end                            ; pc=0x0080
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0084
    addi x2, x2, 20                                     ; pc=0x0088
    freeze                                              ; pc=0x008C