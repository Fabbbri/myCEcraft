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
    addiSigned x2, x2, -8                               ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x1, 0(x2)                                        ; pc=0x0050
    sw x17, 4(x2)                                       ; pc=0x0054
    addi x17, x2, 8                                     ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064

    addi x3, x0, 5                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    add x11, x3, x0                                     ; pc=0x0078
    sleep ; stall RAW                                   ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    jal x1, fact                                        ; pc=0x0088
    sleep ; nop despues de control                      ; pc=0x008C
    sleep ; nop despues de control                      ; pc=0x0090
    add x3, x11, x0                                     ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    sleep ; stall RAW                                   ; pc=0x00A0
    add x11, x3, x0                                     ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    jal x0, .L_codegen_1_main_end                       ; pc=0x00B4
    sleep ; nop despues de control                      ; pc=0x00B8
    sleep ; nop despues de control                      ; pc=0x00BC
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sleep ; stall RAW                                   ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    addi x2, x2, 8                                      ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sleep ; stall RAW                                   ; pc=0x00D8
    sleep ; stall RAW                                   ; pc=0x00DC
    freeze                                              ; pc=0x00E0

fact:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    sleep ; stall RAW                                   ; pc=0x00F0
    sw x1, 0(x2)                                        ; pc=0x00F4
    sw x17, 4(x2)                                       ; pc=0x00F8
    addi x17, x2, 16                                    ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108

    sw x11, -4(x17) ; parámetro n                       ; pc=0x010C


    ; if
    lw x3, -4(x17) ; n                                  ; pc=0x0110
    sleep ; stall RAW                                   ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    addi x4, x0, 1                                      ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    blt x4, x3, .L0_if_else                             ; pc=0x0130
    sleep ; nop despues de control                      ; pc=0x0134
    sleep ; nop despues de control                      ; pc=0x0138
    addi x4, x0, 1                                      ; pc=0x013C
    sleep ; stall RAW                                   ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    add x11, x4, x0                                     ; pc=0x014C
    sleep ; stall RAW                                   ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    jal x0, .L_codegen_2_fact_end                       ; pc=0x015C
    sleep ; nop despues de control                      ; pc=0x0160
    sleep ; nop despues de control                      ; pc=0x0164
    jal x0, .L1_if_end                                  ; pc=0x0168
    sleep ; nop despues de control                      ; pc=0x016C
    sleep ; nop despues de control                      ; pc=0x0170
.L0_if_else:
.L1_if_end:

    lw x4, -4(x17) ; n                                  ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    sleep ; stall RAW                                   ; pc=0x017C
    sleep ; stall RAW                                   ; pc=0x0180
    lw x3, -4(x17) ; n                                  ; pc=0x0184
    sleep ; stall RAW                                   ; pc=0x0188
    sleep ; stall RAW                                   ; pc=0x018C
    sleep ; stall RAW                                   ; pc=0x0190
    addi x5, x0, 1                                      ; pc=0x0194
    sleep ; stall RAW                                   ; pc=0x0198
    sleep ; stall RAW                                   ; pc=0x019C
    sleep ; stall RAW                                   ; pc=0x01A0
    sub x6, x3, x5                                      ; pc=0x01A4
    sleep ; stall RAW                                   ; pc=0x01A8
    sleep ; stall RAW                                   ; pc=0x01AC
    sleep ; stall RAW                                   ; pc=0x01B0
    add x11, x6, x0                                     ; pc=0x01B4
    sleep ; stall RAW                                   ; pc=0x01B8
    sleep ; stall RAW                                   ; pc=0x01BC
    sleep ; stall RAW                                   ; pc=0x01C0
    jal x1, fact                                        ; pc=0x01C4
    sleep ; nop despues de control                      ; pc=0x01C8
    sleep ; nop despues de control                      ; pc=0x01CC
    add x6, x11, x0                                     ; pc=0x01D0
    sleep ; stall RAW                                   ; pc=0x01D4
    sleep ; stall RAW                                   ; pc=0x01D8
    sleep ; stall RAW                                   ; pc=0x01DC
    mul x5, x4, x6                                      ; pc=0x01E0
    sleep ; stall RAW                                   ; pc=0x01E4
    sleep ; stall RAW                                   ; pc=0x01E8
    sleep ; stall RAW                                   ; pc=0x01EC
    add x11, x5, x0                                     ; pc=0x01F0
    sleep ; stall RAW                                   ; pc=0x01F4
    sleep ; stall RAW                                   ; pc=0x01F8
    sleep ; stall RAW                                   ; pc=0x01FC
    jal x0, .L_codegen_2_fact_end                       ; pc=0x0200
    sleep ; nop despues de control                      ; pc=0x0204
    sleep ; nop despues de control                      ; pc=0x0208
.L_codegen_2_fact_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x020C
    sleep ; stall RAW                                   ; pc=0x0210
    sleep ; stall RAW                                   ; pc=0x0214
    sleep ; stall RAW                                   ; pc=0x0218
    lw x17, 4(x2)                                       ; pc=0x021C
    sleep ; stall RAW                                   ; pc=0x0220
    sleep ; stall RAW                                   ; pc=0x0224
    sleep ; stall RAW                                   ; pc=0x0228
    addi x2, x2, 16                                     ; pc=0x022C
    sleep ; stall RAW                                   ; pc=0x0230
    sleep ; stall RAW                                   ; pc=0x0234
    sleep ; stall RAW                                   ; pc=0x0238
    jalr x1, 0                                          ; pc=0x023C
    sleep ; nop despues de control                      ; pc=0x0240
    sleep ; nop despues de control                      ; pc=0x0244