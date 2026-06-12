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
    addiSigned x2, x2, -60                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 60                                    ; pc=0x002C

    addi x7, x0, 4                                      ; pc=0x0030
    add x4, x7, x0 ; promote a                          ; pc=0x0034
    addi x8, x0, 3                                      ; pc=0x0038
    add x3, x8, x0 ; promote b                          ; pc=0x003C
    add x9, x4, x3                                      ; pc=0x0040
    add x5, x9, x0 ; promote previo                     ; pc=0x0044
    addi x10, x0, 5                                     ; pc=0x0048
    add x7, x3, x10                                     ; pc=0x004C
    add x4, x7, x0 ; promote a                          ; pc=0x0050
    addi x8, x0, 2                                      ; pc=0x0054
    mul x9, x3, x8                                      ; pc=0x0058
    sw x9, -32(x17) ; t2                                ; pc=0x005C
    lw x7, -32(x17) ; t2                                ; pc=0x0060
    add x10, x4, x7                                     ; pc=0x0064
    add x6, x10, x0 ; promote medio                     ; pc=0x0068
    addi x9, x0, 1                                      ; pc=0x006C
    add x8, x4, x9                                      ; pc=0x0070
    add x3, x8, x0 ; promote b                          ; pc=0x0074
    addi x10, x0, 2                                     ; pc=0x0078
    add x7, x3, x10                                     ; pc=0x007C
    sw x7, -20(x17) ; final                             ; pc=0x0080
    add x8, x5, x6                                      ; pc=0x0084
    sw x8, -48(x17) ; t6                                ; pc=0x0088
    lw x9, -48(x17) ; t6                                ; pc=0x008C
    lw x7, -20(x17) ; final                             ; pc=0x0090
    add x10, x9, x7                                     ; pc=0x0094
    sw x10, -52(x17) ; t7                               ; pc=0x0098
    lw x8, -52(x17) ; t7                                ; pc=0x009C
    add x11, x8, x0                                     ; pc=0x00A0
    jal x0, .L_ir_1_main_end                            ; pc=0x00A4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00A8
    addi x2, x2, 60                                     ; pc=0x00AC
    freeze                                              ; pc=0x00B0