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
    addiSigned x2, x2, -56                              ; pc=0x0018
    sleep ; stall RAW                                   ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sw x1, 0(x2)                                        ; pc=0x0028
    sw x17, 4(x2)                                       ; pc=0x002C
    addi x17, x2, 56                                    ; pc=0x0030
    sleep ; stall RAW                                   ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C

    addi x3, x0, 3                                      ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x3, -24(x17) ; datos[0]                          ; pc=0x0050
    addi x3, x0, 7                                      ; pc=0x0054
    sleep ; stall RAW                                   ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sw x3, -20(x17) ; datos[1]                          ; pc=0x0064
    addi x3, x0, 2                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sw x3, -16(x17) ; datos[2]                          ; pc=0x0078
    addi x3, x0, 9                                      ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    sw x3, -12(x17) ; datos[3]                          ; pc=0x008C
    addi x3, x0, 5                                      ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    sw x3, -8(x17) ; datos[4]                           ; pc=0x00A0
    addi x3, x0, 1                                      ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    sw x3, -4(x17) ; datos[5]                           ; pc=0x00B4
    addi x3, x0, 9                                      ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sw x3, -28(x17) ; objetivo                          ; pc=0x00C8
    addi x3, x0, 0                                      ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sleep ; stall RAW                                   ; pc=0x00D8
    sw x3, -32(x17) ; i                                 ; pc=0x00DC
    addi x3, x0, 1                                      ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    sub x4, x0, x3                                      ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sw x4, -36(x17) ; pos                               ; pc=0x0100

.L0_while_start:
    lw x4, -32(x17) ; i                                 ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    addi x3, x0, 6                                      ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    bge x4, x3, .L1_while_end                           ; pc=0x0124
    sleep ; nop despues de control                      ; pc=0x0128

    ; if
    lw x3, -32(x17) ; i                                 ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    sleep ; stall RAW                                   ; pc=0x0134
    sleep ; stall RAW                                   ; pc=0x0138
    add x4, x3, x3                                      ; pc=0x013C
    sleep ; stall RAW                                   ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    add x4, x4, x4                                      ; pc=0x014C
    sleep ; stall RAW                                   ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    addiSigned x5, x17, -24                             ; pc=0x015C
    sleep ; stall RAW                                   ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    sleep ; stall RAW                                   ; pc=0x0168
    ; base datos
    add x5, x5, x4                                      ; pc=0x016C
    sleep ; stall RAW                                   ; pc=0x0170
    sleep ; stall RAW                                   ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    lw x4, 0(x5)                                        ; pc=0x017C
    sleep ; stall RAW                                   ; pc=0x0180
    sleep ; stall RAW                                   ; pc=0x0184
    sleep ; stall RAW                                   ; pc=0x0188
    lw x5, -28(x17) ; objetivo                          ; pc=0x018C
    sleep ; stall RAW                                   ; pc=0x0190
    sleep ; stall RAW                                   ; pc=0x0194
    sleep ; stall RAW                                   ; pc=0x0198
    bne x4, x5, .L2_if_else                             ; pc=0x019C
    sleep ; nop despues de control                      ; pc=0x01A0
    lw x5, -32(x17) ; i                                 ; pc=0x01A4
    sleep ; stall RAW                                   ; pc=0x01A8
    sleep ; stall RAW                                   ; pc=0x01AC
    sleep ; stall RAW                                   ; pc=0x01B0
    sw x5, -36(x17) ; pos                               ; pc=0x01B4
    addi x5, x0, 6                                      ; pc=0x01B8
    sleep ; stall RAW                                   ; pc=0x01BC
    sleep ; stall RAW                                   ; pc=0x01C0
    sleep ; stall RAW                                   ; pc=0x01C4
    sw x5, -32(x17) ; i                                 ; pc=0x01C8
    jal x0, .L3_if_end                                  ; pc=0x01CC
    sleep ; nop despues de control                      ; pc=0x01D0
.L2_if_else:
    lw x5, -32(x17) ; i                                 ; pc=0x01D4
    sleep ; stall RAW                                   ; pc=0x01D8
    sleep ; stall RAW                                   ; pc=0x01DC
    sleep ; stall RAW                                   ; pc=0x01E0
    addi x4, x0, 1                                      ; pc=0x01E4
    sleep ; stall RAW                                   ; pc=0x01E8
    sleep ; stall RAW                                   ; pc=0x01EC
    sleep ; stall RAW                                   ; pc=0x01F0
    add x3, x5, x4                                      ; pc=0x01F4
    sleep ; stall RAW                                   ; pc=0x01F8
    sleep ; stall RAW                                   ; pc=0x01FC
    sleep ; stall RAW                                   ; pc=0x0200
    sw x3, -32(x17) ; i                                 ; pc=0x0204
.L3_if_end:

    jal x0, .L0_while_start                             ; pc=0x0208
    sleep ; nop despues de control                      ; pc=0x020C
.L1_while_end:

    lw x3, -36(x17) ; pos                               ; pc=0x0210
    sleep ; stall RAW                                   ; pc=0x0214
    sleep ; stall RAW                                   ; pc=0x0218
    sleep ; stall RAW                                   ; pc=0x021C
    add x11, x3, x0                                     ; pc=0x0220
    sleep ; stall RAW                                   ; pc=0x0224
    sleep ; stall RAW                                   ; pc=0x0228
    sleep ; stall RAW                                   ; pc=0x022C
    jal x0, .L_codegen_1_main_end                       ; pc=0x0230
    sleep ; nop despues de control                      ; pc=0x0234
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0238
    sleep ; stall RAW                                   ; pc=0x023C
    sleep ; stall RAW                                   ; pc=0x0240
    sleep ; stall RAW                                   ; pc=0x0244
    lw x17, 4(x2)                                       ; pc=0x0248
    sleep ; stall RAW                                   ; pc=0x024C
    sleep ; stall RAW                                   ; pc=0x0250
    sleep ; stall RAW                                   ; pc=0x0254
    addi x2, x2, 56                                     ; pc=0x0258
    sleep ; stall RAW                                   ; pc=0x025C
    sleep ; stall RAW                                   ; pc=0x0260
    sleep ; stall RAW                                   ; pc=0x0264
    jalr x1, 0                                          ; pc=0x0268
    sleep ; nop despues de control                      ; pc=0x026C