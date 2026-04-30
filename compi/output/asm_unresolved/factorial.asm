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
    addiSigned x2, x2, -24                              ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sleep ; stall RAW                                   ; pc=0x0028
    sw x1, 0(x2)                                        ; pc=0x002C
    sw x17, 4(x2)                                       ; pc=0x0030
    addi x17, x2, 24                                    ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C
    sleep ; stall RAW                                   ; pc=0x0040

    addi x3, x0, 5                                      ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sleep ; stall RAW                                   ; pc=0x0050
    sw x3, -4(x17) ; n                                  ; pc=0x0054
    addi x3, x0, 1                                      ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064
    sw x3, -8(x17) ; resultado                          ; pc=0x0068
    addi x3, x0, 1                                      ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sleep ; stall RAW                                   ; pc=0x0078
    sw x3, -12(x17) ; i                                 ; pc=0x007C

.L0_while_start:
    lw x3, -12(x17) ; i                                 ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    sleep ; stall RAW                                   ; pc=0x008C
    lw x4, -4(x17) ; n                                  ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    blt x4, x3, .L1_while_end                           ; pc=0x00A0
    sleep ; nop despues de control                      ; pc=0x00A4
    lw x4, -8(x17) ; resultado                          ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    lw x3, -12(x17) ; i                                 ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    mul x5, x4, x3                                      ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sw x5, -8(x17) ; resultado                          ; pc=0x00D8
    lw x5, -12(x17) ; i                                 ; pc=0x00DC
    sleep ; stall RAW                                   ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    addi x3, x0, 1                                      ; pc=0x00EC
    sleep ; stall RAW                                   ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    add x4, x5, x3                                      ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sw x4, -12(x17) ; i                                 ; pc=0x010C
    jal x0, .L0_while_start                             ; pc=0x0110
    sleep ; nop despues de control                      ; pc=0x0114
.L1_while_end:

    lw x4, -8(x17) ; resultado                          ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    add x11, x4, x0                                     ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    sleep ; stall RAW                                   ; pc=0x0134
    jal x0, .L_codegen_1_main_end                       ; pc=0x0138
    sleep ; nop despues de control                      ; pc=0x013C
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    sleep ; stall RAW                                   ; pc=0x014C
    lw x17, 4(x2)                                       ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    sleep ; stall RAW                                   ; pc=0x015C
    addi x2, x2, 24                                     ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    sleep ; stall RAW                                   ; pc=0x0168
    sleep ; stall RAW                                   ; pc=0x016C
    jalr x1, 0                                          ; pc=0x0170
    sleep ; nop despues de control                      ; pc=0x0174