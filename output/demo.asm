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
    addiSigned x2, x2, -16                              ; pc=0x0018
    sleep ; stall RAW                                   ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sw x1, 0(x2)                                        ; pc=0x0028
    sw x17, 4(x2)                                       ; pc=0x002C
    addi x17, x2, 16                                    ; pc=0x0030
    sleep ; stall RAW                                   ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C

    addi x3, x0, 0                                      ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x3, -4(x17) ; x                                  ; pc=0x0050

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0054
    sleep ; stall RAW                                   ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    addi x4, x0, 5                                      ; pc=0x0064
    sleep ; stall RAW                                   ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    bge x3, x4, .L1_while_end                           ; pc=0x0074
    sleep ; nop despues de control                      ; pc=0x0078
    lw x4, -4(x17) ; x                                  ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    addi x3, x0, 1                                      ; pc=0x008C
    sleep ; stall RAW                                   ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    add x5, x4, x3                                      ; pc=0x009C
    sleep ; stall RAW                                   ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sw x5, -4(x17) ; x                                  ; pc=0x00AC
    jal x0, .L0_while_start                             ; pc=0x00B0
    sleep ; nop despues de control                      ; pc=0x00B4
.L1_while_end:

    lw x5, -4(x17) ; x                                  ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    add x11, x5, x0                                     ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    jal x0, .L_codegen_1_main_end                       ; pc=0x00D8
    sleep ; nop despues de control                      ; pc=0x00DC
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    lw x17, 4(x2)                                       ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    addi x2, x2, 16                                     ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    jalr x1, 0                                          ; pc=0x0110
    sleep ; nop despues de control                      ; pc=0x0114