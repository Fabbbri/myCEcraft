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
    addiSigned x2, x2, -72                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 72                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -32(x17) ; arr                               ; pc=0x0034
    addi x3, x0, 42                                     ; pc=0x0038
    addi x4, x0, 0                                      ; pc=0x003C
    add x5, x4, x4                                      ; pc=0x0040
    add x5, x5, x5                                      ; pc=0x0044
    addiSigned x6, x17, -32                             ; pc=0x0048
    ; base arr
    add x6, x6, x5                                      ; pc=0x004C
    sw x3, 0(x6)                                        ; pc=0x0050
    addi x3, x0, 0                                      ; pc=0x0054
    add x6, x3, x3                                      ; pc=0x0058
    add x6, x6, x6                                      ; pc=0x005C
    addiSigned x5, x17, -32                             ; pc=0x0060
    ; base arr
    add x5, x5, x6                                      ; pc=0x0064
    lw x6, 0(x5)                                        ; pc=0x0068
    add x11, x6, x0                                     ; pc=0x006C
    jal x0, .L_codegen_1_main_end                       ; pc=0x0070
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0074
    addi x2, x2, 72                                     ; pc=0x0078
    freeze                                              ; pc=0x007C