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

suma1:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sleep ; stall RAW                                   ; pc=0x0028
    sw x1, 0(x2)                                        ; pc=0x002C
    sw x17, 4(x2)                                       ; pc=0x0030
    addi x17, x2, 8                                     ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C
    sleep ; stall RAW                                   ; pc=0x0040

    sw x11, 8(x17) ; parámetro x                        ; pc=0x0044

    lw x3, 8(x17) ; x                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sleep ; stall RAW                                   ; pc=0x0050
    sleep ; stall RAW                                   ; pc=0x0054
    addi x4, x0, 1                                      ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064
    add x5, x3, x4                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    add x11, x5, x0                                     ; pc=0x0078
    sleep ; stall RAW                                   ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    jal x0, .L_codegen_1_suma1_end                      ; pc=0x0088
    sleep ; nop despues de control                      ; pc=0x008C
.L_codegen_1_suma1_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    lw x17, 4(x2)                                       ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    addi x2, x2, 8                                      ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    sleep ; stall RAW                                   ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    jalr x1, 0                                          ; pc=0x00C0
    sleep ; nop despues de control                      ; pc=0x00C4

suma2:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sw x1, 0(x2)                                        ; pc=0x00D8
    sw x17, 4(x2)                                       ; pc=0x00DC
    addi x17, x2, 8                                     ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC

    sw x11, 8(x17) ; parámetro x                        ; pc=0x00F0

    lw x5, 8(x17) ; x                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    add x11, x5, x0                                     ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    jal x1, suma1                                       ; pc=0x0114
    sleep ; nop despues de control                      ; pc=0x0118
    add x5, x11, x0                                     ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    addi x4, x0, 1                                      ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    sleep ; stall RAW                                   ; pc=0x0134
    sleep ; stall RAW                                   ; pc=0x0138
    add x3, x5, x4                                      ; pc=0x013C
    sleep ; stall RAW                                   ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    add x11, x3, x0                                     ; pc=0x014C
    sleep ; stall RAW                                   ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    jal x0, .L_codegen_2_suma2_end                      ; pc=0x015C
    sleep ; nop despues de control                      ; pc=0x0160
.L_codegen_2_suma2_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0164
    sleep ; stall RAW                                   ; pc=0x0168
    sleep ; stall RAW                                   ; pc=0x016C
    sleep ; stall RAW                                   ; pc=0x0170
    lw x17, 4(x2)                                       ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    sleep ; stall RAW                                   ; pc=0x017C
    sleep ; stall RAW                                   ; pc=0x0180
    addi x2, x2, 8                                      ; pc=0x0184
    sleep ; stall RAW                                   ; pc=0x0188
    sleep ; stall RAW                                   ; pc=0x018C
    sleep ; stall RAW                                   ; pc=0x0190
    jalr x1, 0                                          ; pc=0x0194
    sleep ; nop despues de control                      ; pc=0x0198

    ; final de programa
    addiHIGH x1, x0, 0xDEAD                             ; pc=0x019C
    sleep ; stall RAW                                   ; pc=0x01A0
    sleep ; stall RAW                                   ; pc=0x01A4
    sleep ; stall RAW                                   ; pc=0x01A8
    jalr x1, 0                                          ; pc=0x01AC
    sleep ; nop despues de control                      ; pc=0x01B0