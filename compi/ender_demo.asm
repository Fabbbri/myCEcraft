; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

main:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 8                                     ; pc=0x000C

    portalv x3, x4, 0 ; enderopen                       ; pc=0x0010
    addiLOWv v1, v0, 38563 ; key[0] low                 ; pc=0x0014
    addiHIGHv v1, v1, 35 ; key[0] high                  ; pc=0x0018
    swv v1, 0(v0) ; key[0]                              ; pc=0x001C
    addiLOWv v1, v0, 1234 ; key[1] low                  ; pc=0x0020
    addiHIGHv v1, v1, 0 ; key[1] high                   ; pc=0x0024
    swv v1, 4(v0) ; key[1]                              ; pc=0x0028
    addiLOWv v1, v0, 13234 ; key[2] low                 ; pc=0x002C
    addiHIGHv v1, v1, 0 ; key[2] high                   ; pc=0x0030
    swv v1, 8(v0) ; key[2]                              ; pc=0x0034
    addiLOWv v1, v0, 124 ; key[3] low                   ; pc=0x0038
    addiHIGHv v1, v1, 0 ; key[3] high                   ; pc=0x003C
    swv v1, 12(v0) ; key[3]                             ; pc=0x0040
    addiLOWv v2, v0, 0x1234 ; enderlow                  ; pc=0x0044
    addiHIGHv v2, v2, 0xABCD ; enderhigh                ; pc=0x0048
    changev v2, v1 ; enderkey                           ; pc=0x004C
    lwv v3, 0(v0) ; enderload                           ; pc=0x0050
    swv v3, 4(v0) ; enderstore                          ; pc=0x0054
    closev ; enderclose                                 ; pc=0x0058
    addi x3, x0, 0                                      ; pc=0x005C
    add x11, x3, x0                                     ; pc=0x0060
    jal x0, .L_codegen_0_main_end                       ; pc=0x0064
.L_codegen_0_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0068
    lw x17, 4(x2)                                       ; pc=0x006C
    addi x2, x2, 8                                      ; pc=0x0070
    jalr x1, 0                                          ; pc=0x0074