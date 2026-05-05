; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    sleep ; nop despues de control                      ; pc=0x0004
    sleep ; nop despues de control                      ; pc=0x0008
    lwv v0, 0(v0)                                       ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    sleep ; stall RAW                                   ; pc=0x0014
    sleep ; stall RAW                                   ; pc=0x0018
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x001C
.L_codegen_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sleep ; stall RAW                                   ; pc=0x0028
    sleep ; stall RAW                                   ; pc=0x002C
    addi x2, x2, 0x7FF0                                 ; pc=0x0030
    sleep ; stall RAW                                   ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C

    ; prologue
    addiSigned x2, x2, -28                              ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x1, 0(x2)                                        ; pc=0x0050
    sw x17, 4(x2)                                       ; pc=0x0054
    addi x17, x2, 28                                    ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064

    addi x3, x0, 2                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sw x3, -4(x17) ; a                                  ; pc=0x0078
    addi x3, x0, 3                                      ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    sw x3, -8(x17) ; b                                  ; pc=0x008C
    lw x3, -4(x17) ; a                                  ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    lw x4, -8(x17) ; b                                  ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    add x5, x3, x4                                      ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    sleep ; stall RAW                                   ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    add x11, x5, x0                                     ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sleep ; stall RAW                                   ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    jal x1, factorial                                   ; pc=0x00D0
    sleep ; nop despues de control                      ; pc=0x00D4
    sleep ; nop despues de control                      ; pc=0x00D8
    add x5, x11, x0                                     ; pc=0x00DC
    sleep ; stall RAW                                   ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sw x5, -12(x17) ; r1                                ; pc=0x00EC
    lw x5, -4(x17) ; a                                  ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    addi x4, x0, 1                                      ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    add x3, x5, x4                                      ; pc=0x0110
    sleep ; stall RAW                                   ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    add x11, x3, x0                                     ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    jal x1, factorial                                   ; pc=0x0130
    sleep ; nop despues de control                      ; pc=0x0134
    sleep ; nop despues de control                      ; pc=0x0138
    add x3, x11, x0                                     ; pc=0x013C
    sleep ; stall RAW                                   ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    sw x3, -16(x17) ; r2                                ; pc=0x014C
    lw x3, -12(x17) ; r1                                ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    sleep ; stall RAW                                   ; pc=0x015C
    lw x4, -16(x17) ; r2                                ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    sleep ; stall RAW                                   ; pc=0x0168
    sleep ; stall RAW                                   ; pc=0x016C
    add x5, x3, x4                                      ; pc=0x0170
    sleep ; stall RAW                                   ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    sleep ; stall RAW                                   ; pc=0x017C
    add x11, x5, x0                                     ; pc=0x0180
    sleep ; stall RAW                                   ; pc=0x0184
    sleep ; stall RAW                                   ; pc=0x0188
    sleep ; stall RAW                                   ; pc=0x018C
    jal x0, .L_codegen_1_main_end                       ; pc=0x0190
    sleep ; nop despues de control                      ; pc=0x0194
    sleep ; nop despues de control                      ; pc=0x0198
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x019C
    sleep ; stall RAW                                   ; pc=0x01A0
    sleep ; stall RAW                                   ; pc=0x01A4
    sleep ; stall RAW                                   ; pc=0x01A8
    addi x2, x2, 28                                     ; pc=0x01AC
    sleep ; stall RAW                                   ; pc=0x01B0
    sleep ; stall RAW                                   ; pc=0x01B4
    sleep ; stall RAW                                   ; pc=0x01B8
    freeze                                              ; pc=0x01BC

factorial:
    ; prologue
    addiSigned x2, x2, -24                              ; pc=0x01C0
    sleep ; stall RAW                                   ; pc=0x01C4
    sleep ; stall RAW                                   ; pc=0x01C8
    sleep ; stall RAW                                   ; pc=0x01CC
    sw x1, 0(x2)                                        ; pc=0x01D0
    sw x17, 4(x2)                                       ; pc=0x01D4
    addi x17, x2, 24                                    ; pc=0x01D8
    sleep ; stall RAW                                   ; pc=0x01DC
    sleep ; stall RAW                                   ; pc=0x01E0
    sleep ; stall RAW                                   ; pc=0x01E4

    sw x11, -4(x17) ; parámetro n                       ; pc=0x01E8

    addi x5, x0, 1                                      ; pc=0x01EC
    sleep ; stall RAW                                   ; pc=0x01F0
    sleep ; stall RAW                                   ; pc=0x01F4
    sleep ; stall RAW                                   ; pc=0x01F8
    sw x5, -8(x17) ; resultado                          ; pc=0x01FC
    addi x5, x0, 1                                      ; pc=0x0200
    sleep ; stall RAW                                   ; pc=0x0204
    sleep ; stall RAW                                   ; pc=0x0208
    sleep ; stall RAW                                   ; pc=0x020C
    sw x5, -12(x17) ; i                                 ; pc=0x0210

.L0_while_start:
    lw x5, -12(x17) ; i                                 ; pc=0x0214
    sleep ; stall RAW                                   ; pc=0x0218
    sleep ; stall RAW                                   ; pc=0x021C
    sleep ; stall RAW                                   ; pc=0x0220
    lw x4, -4(x17) ; n                                  ; pc=0x0224
    sleep ; stall RAW                                   ; pc=0x0228
    sleep ; stall RAW                                   ; pc=0x022C
    sleep ; stall RAW                                   ; pc=0x0230
    blt x4, x5, .L1_while_end                           ; pc=0x0234
    sleep ; nop despues de control                      ; pc=0x0238
    sleep ; nop despues de control                      ; pc=0x023C
    lw x4, -8(x17) ; resultado                          ; pc=0x0240
    sleep ; stall RAW                                   ; pc=0x0244
    sleep ; stall RAW                                   ; pc=0x0248
    sleep ; stall RAW                                   ; pc=0x024C
    lw x5, -12(x17) ; i                                 ; pc=0x0250
    sleep ; stall RAW                                   ; pc=0x0254
    sleep ; stall RAW                                   ; pc=0x0258
    sleep ; stall RAW                                   ; pc=0x025C
    mul x3, x4, x5                                      ; pc=0x0260
    sleep ; stall RAW                                   ; pc=0x0264
    sleep ; stall RAW                                   ; pc=0x0268
    sleep ; stall RAW                                   ; pc=0x026C
    sw x3, -8(x17) ; resultado                          ; pc=0x0270
    lw x3, -12(x17) ; i                                 ; pc=0x0274
    sleep ; stall RAW                                   ; pc=0x0278
    sleep ; stall RAW                                   ; pc=0x027C
    sleep ; stall RAW                                   ; pc=0x0280
    addi x5, x0, 1                                      ; pc=0x0284
    sleep ; stall RAW                                   ; pc=0x0288
    sleep ; stall RAW                                   ; pc=0x028C
    sleep ; stall RAW                                   ; pc=0x0290
    add x4, x3, x5                                      ; pc=0x0294
    sleep ; stall RAW                                   ; pc=0x0298
    sleep ; stall RAW                                   ; pc=0x029C
    sleep ; stall RAW                                   ; pc=0x02A0
    sw x4, -12(x17) ; i                                 ; pc=0x02A4
    jal x0, .L0_while_start                             ; pc=0x02A8
    sleep ; nop despues de control                      ; pc=0x02AC
    sleep ; nop despues de control                      ; pc=0x02B0
.L1_while_end:

    lw x4, -8(x17) ; resultado                          ; pc=0x02B4
    sleep ; stall RAW                                   ; pc=0x02B8
    sleep ; stall RAW                                   ; pc=0x02BC
    sleep ; stall RAW                                   ; pc=0x02C0
    add x11, x4, x0                                     ; pc=0x02C4
    sleep ; stall RAW                                   ; pc=0x02C8
    sleep ; stall RAW                                   ; pc=0x02CC
    sleep ; stall RAW                                   ; pc=0x02D0
    jal x0, .L_codegen_2_factorial_end                  ; pc=0x02D4
    sleep ; nop despues de control                      ; pc=0x02D8
    sleep ; nop despues de control                      ; pc=0x02DC
.L_codegen_2_factorial_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x02E0
    sleep ; stall RAW                                   ; pc=0x02E4
    sleep ; stall RAW                                   ; pc=0x02E8
    sleep ; stall RAW                                   ; pc=0x02EC
    lw x17, 4(x2)                                       ; pc=0x02F0
    sleep ; stall RAW                                   ; pc=0x02F4
    sleep ; stall RAW                                   ; pc=0x02F8
    sleep ; stall RAW                                   ; pc=0x02FC
    addi x2, x2, 24                                     ; pc=0x0300
    sleep ; stall RAW                                   ; pc=0x0304
    sleep ; stall RAW                                   ; pc=0x0308
    sleep ; stall RAW                                   ; pc=0x030C
    jalr x1, 0                                          ; pc=0x0310
    sleep ; nop despues de control                      ; pc=0x0314
    sleep ; nop despues de control                      ; pc=0x0318