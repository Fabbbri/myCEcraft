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
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0018
    sleep ; stall RAW                                   ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sw x1, 0(x2)                                        ; pc=0x0028
    sw x17, 4(x2)                                       ; pc=0x002C
    addi x17, x2, 20                                    ; pc=0x0030
    sleep ; stall RAW                                   ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C

    addi x3, x0, 0                                      ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x3, -4(x17) ; x                                  ; pc=0x0050
    addi x3, x0, 0                                      ; pc=0x0054
    sleep ; stall RAW                                   ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sw x3, -8(x17) ; y                                  ; pc=0x0064

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    addi x4, x0, 3                                      ; pc=0x0078
    sleep ; stall RAW                                   ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    bge x3, x4, .L1_while_end                           ; pc=0x0088
    sleep ; nop despues de control                      ; pc=0x008C

    ; if
    lw x4, -8(x17) ; y                                  ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    addi x3, x0, 2                                      ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    bge x4, x3, .L2_if_else                             ; pc=0x00B0
    sleep ; nop despues de control                      ; pc=0x00B4
    lw x3, -8(x17) ; y                                  ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    addi x4, x0, 1                                      ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    add x5, x3, x4                                      ; pc=0x00D8
    sleep ; stall RAW                                   ; pc=0x00DC
    sleep ; stall RAW                                   ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sw x5, -8(x17) ; y                                  ; pc=0x00E8

    ; if
    lw x5, -4(x17) ; x                                  ; pc=0x00EC
    sleep ; stall RAW                                   ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    addi x4, x0, 1                                      ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    bne x5, x4, .L4_if_else                             ; pc=0x010C
    sleep ; nop despues de control                      ; pc=0x0110
    lw x4, -8(x17) ; y                                  ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    addi x5, x0, 2                                      ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    add x3, x4, x5                                      ; pc=0x0134
    sleep ; stall RAW                                   ; pc=0x0138
    sleep ; stall RAW                                   ; pc=0x013C
    sleep ; stall RAW                                   ; pc=0x0140
    sw x3, -8(x17) ; y                                  ; pc=0x0144
    jal x0, .L5_if_end                                  ; pc=0x0148
    sleep ; nop despues de control                      ; pc=0x014C
.L4_if_else:
    lw x3, -8(x17) ; y                                  ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    sleep ; stall RAW                                   ; pc=0x015C
    addi x5, x0, 3                                      ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    sleep ; stall RAW                                   ; pc=0x0168
    sleep ; stall RAW                                   ; pc=0x016C
    add x4, x3, x5                                      ; pc=0x0170
    sleep ; stall RAW                                   ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    sleep ; stall RAW                                   ; pc=0x017C
    sw x4, -8(x17) ; y                                  ; pc=0x0180
.L5_if_end:

    jal x0, .L3_if_end                                  ; pc=0x0184
    sleep ; nop despues de control                      ; pc=0x0188
.L2_if_else:
    lw x4, -8(x17) ; y                                  ; pc=0x018C
    sleep ; stall RAW                                   ; pc=0x0190
    sleep ; stall RAW                                   ; pc=0x0194
    sleep ; stall RAW                                   ; pc=0x0198
    addi x5, x0, 1                                      ; pc=0x019C
    sleep ; stall RAW                                   ; pc=0x01A0
    sleep ; stall RAW                                   ; pc=0x01A4
    sleep ; stall RAW                                   ; pc=0x01A8
    sub x3, x4, x5                                      ; pc=0x01AC
    sleep ; stall RAW                                   ; pc=0x01B0
    sleep ; stall RAW                                   ; pc=0x01B4
    sleep ; stall RAW                                   ; pc=0x01B8
    sw x3, -8(x17) ; y                                  ; pc=0x01BC
.L3_if_end:

    lw x3, -4(x17) ; x                                  ; pc=0x01C0
    sleep ; stall RAW                                   ; pc=0x01C4
    sleep ; stall RAW                                   ; pc=0x01C8
    sleep ; stall RAW                                   ; pc=0x01CC
    addi x5, x0, 1                                      ; pc=0x01D0
    sleep ; stall RAW                                   ; pc=0x01D4
    sleep ; stall RAW                                   ; pc=0x01D8
    sleep ; stall RAW                                   ; pc=0x01DC
    add x4, x3, x5                                      ; pc=0x01E0
    sleep ; stall RAW                                   ; pc=0x01E4
    sleep ; stall RAW                                   ; pc=0x01E8
    sleep ; stall RAW                                   ; pc=0x01EC
    sw x4, -4(x17) ; x                                  ; pc=0x01F0
    jal x0, .L0_while_start                             ; pc=0x01F4
    sleep ; nop despues de control                      ; pc=0x01F8
.L1_while_end:

    lw x4, -8(x17) ; y                                  ; pc=0x01FC
    sleep ; stall RAW                                   ; pc=0x0200
    sleep ; stall RAW                                   ; pc=0x0204
    sleep ; stall RAW                                   ; pc=0x0208
    add x11, x4, x0                                     ; pc=0x020C
    sleep ; stall RAW                                   ; pc=0x0210
    sleep ; stall RAW                                   ; pc=0x0214
    sleep ; stall RAW                                   ; pc=0x0218
    jal x0, .L_codegen_1_main_end                       ; pc=0x021C
    sleep ; nop despues de control                      ; pc=0x0220
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0224
    sleep ; stall RAW                                   ; pc=0x0228
    sleep ; stall RAW                                   ; pc=0x022C
    sleep ; stall RAW                                   ; pc=0x0230
    lw x17, 4(x2)                                       ; pc=0x0234
    sleep ; stall RAW                                   ; pc=0x0238
    sleep ; stall RAW                                   ; pc=0x023C
    sleep ; stall RAW                                   ; pc=0x0240
    addi x2, x2, 20                                     ; pc=0x0244
    sleep ; stall RAW                                   ; pc=0x0248
    sleep ; stall RAW                                   ; pc=0x024C
    sleep ; stall RAW                                   ; pc=0x0250
    jalr x1, 0                                          ; pc=0x0254
    sleep ; nop despues de control                      ; pc=0x0258