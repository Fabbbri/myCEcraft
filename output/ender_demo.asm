; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    lwv v0, 0(v0)                                       ; pc=0x0004
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0008
    sw x1, 0(x2)                                        ; pc=0x000C
    sw x17, 4(x2)                                       ; pc=0x0010
    addi x17, x2, 8                                     ; pc=0x0014

    portalv x3, x4, 0 ; enderopen                       ; pc=0x0018
    addiLOWv v1, v0, 38563 ; key[0] low                 ; pc=0x001C
    addiHIGHv v1, v1, 35 ; key[0] high                  ; pc=0x0020
    swv v1, 0(v0) ; key[0]                              ; pc=0x0024
    addiLOWv v1, v0, 1234 ; key[1] low                  ; pc=0x0028
    addiHIGHv v1, v1, 0 ; key[1] high                   ; pc=0x002C
    swv v1, 4(v0) ; key[1]                              ; pc=0x0030
    addiLOWv v1, v0, 13234 ; key[2] low                 ; pc=0x0034
    addiHIGHv v1, v1, 0 ; key[2] high                   ; pc=0x0038
    swv v1, 8(v0) ; key[2]                              ; pc=0x003C
    addiLOWv v1, v0, 124 ; key[3] low                   ; pc=0x0040
    addiHIGHv v1, v1, 0 ; key[3] high                   ; pc=0x0044
    swv v1, 12(v0) ; key[3]                             ; pc=0x0048
    addiLOWv v2, v0, 0x1234 ; enderlow                  ; pc=0x004C
    addiHIGHv v2, v2, 0xABCD ; enderhigh                ; pc=0x0050
    changev v2, v1 ; enderkey                           ; pc=0x0054
    lwv v3, 0(v0) ; enderload                           ; pc=0x0058
    swv v3, 4(v0) ; enderstore                          ; pc=0x005C
    closev ; enderclose                                 ; pc=0x0060
    addi x3, x0, 0                                      ; pc=0x0064
    add x11, x3, x0                                     ; pc=0x0068
    jal x0, .L_codegen_1_main_end                       ; pc=0x006C
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0070
    lw x17, 4(x2)                                       ; pc=0x0074
    addi x2, x2, 8                                      ; pc=0x0078
    jalr x1, 0                                          ; pc=0x007C