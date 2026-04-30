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

    addi x3, x0, 0                                      ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sleep ; stall RAW                                   ; pc=0x0050
    sw x3, -4(x17) ; x                                  ; pc=0x0054

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064
    addi x4, x0, 5                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    bge x3, x4, .L1_while_end                           ; pc=0x0078
    sleep ; nop despues de control                      ; pc=0x007C
    lw x4, -4(x17) ; x                                  ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    sleep ; stall RAW                                   ; pc=0x008C
    addi x3, x0, 1                                      ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    add x5, x4, x3                                      ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sw x5, -4(x17) ; x                                  ; pc=0x00B0
    jal x0, .L0_while_start                             ; pc=0x00B4
    sleep ; nop despues de control                      ; pc=0x00B8
.L1_while_end:

    lw x5, -4(x17) ; x                                  ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sleep ; stall RAW                                   ; pc=0x00C8
    add x11, x5, x0                                     ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sleep ; stall RAW                                   ; pc=0x00D8
    jal x0, .L_codegen_1_main_end                       ; pc=0x00DC
    sleep ; nop despues de control                      ; pc=0x00E0
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    sleep ; stall RAW                                   ; pc=0x00F0
    lw x17, 4(x2)                                       ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    addi x2, x2, 16                                     ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    jalr x1, 0                                          ; pc=0x0114
    sleep ; nop despues de control                      ; pc=0x0118