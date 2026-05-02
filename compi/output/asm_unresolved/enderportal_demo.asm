; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    sleep ; nop despues de control                      ; pc=0x0004
    lwv v0, 0(v0)                                       ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    sleep ; stall RAW                                   ; pc=0x0014
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0018
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sleep ; stall RAW                                   ; pc=0x0028
    sw x1, 0(x2)                                        ; pc=0x002C
    sw x17, 4(x2)                                       ; pc=0x0030
    addi x17, x2, 16                                    ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C
    sleep ; stall RAW                                   ; pc=0x0040

    addi x3, x0, 12441                                  ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sleep ; stall RAW                                   ; pc=0x0050
    sw x3, -4(x17) ; num                                ; pc=0x0054
    addi x3, x0, 2121                                   ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064
    addiHIGH x4, x0, 0                                  ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    add x3, x3, x4                                      ; pc=0x0078
    sleep ; stall RAW                                   ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    portalv x3, v0, .L_codegen_2_endchange ; enderPortal ; pc=0x0088
    sleep ; nop despues de control                      ; pc=0x008C
    lw x3, -4(x17) ; num                                ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    addiHIGH x4, x0, 0                                  ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    addi x4, x4, 65535                                  ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    sleep ; stall RAW                                   ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    and x5, x3, x4                                      ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sleep ; stall RAW                                   ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    addi x6, x0, 16                                     ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sleep ; stall RAW                                   ; pc=0x00D8
    sleep ; stall RAW                                   ; pc=0x00DC
    srl x7, x3, x6                                      ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    changev v0, x5, x7 ; enderchange                    ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    swv v0, 0(v0)                                       ; pc=0x0100
    closev ; enderclose                                 ; pc=0x0104
.L_codegen_2_endchange:
    addi x3, x0, 0                                      ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    sleep ; stall RAW                                   ; pc=0x0114
    add x11, x3, x0                                     ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    jal x0, .L_codegen_1_main_end                       ; pc=0x0128
    sleep ; nop despues de control                      ; pc=0x012C
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0130
    sleep ; stall RAW                                   ; pc=0x0134
    sleep ; stall RAW                                   ; pc=0x0138
    sleep ; stall RAW                                   ; pc=0x013C
    addi x2, x2, 16                                     ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    sleep ; stall RAW                                   ; pc=0x014C
    addiHIGH x1, x0, 0xDEAD                             ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    sleep ; stall RAW                                   ; pc=0x015C
    jalr x1, 0                                          ; pc=0x0160
    sleep ; nop despues de control                      ; pc=0x0164