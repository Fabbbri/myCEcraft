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
    addiSigned x2, x2, -16                              ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x1, 0(x2)                                        ; pc=0x0050
    sw x17, 4(x2)                                       ; pc=0x0054
    addi x17, x2, 16                                    ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064

    addi x3, x0, 0                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sw x3, -4(x17) ; x                                  ; pc=0x0078

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    addi x4, x0, 5                                      ; pc=0x008C
    sleep ; stall RAW                                   ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    bge x3, x4, .L1_while_end                           ; pc=0x009C
    sleep ; nop despues de control                      ; pc=0x00A0
    sleep ; nop despues de control                      ; pc=0x00A4
    lw x4, -4(x17) ; x                                  ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    addi x3, x0, 1                                      ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    add x5, x4, x3                                      ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sw x5, -4(x17) ; x                                  ; pc=0x00D8
    jal x0, .L0_while_start                             ; pc=0x00DC
    sleep ; nop despues de control                      ; pc=0x00E0
    sleep ; nop despues de control                      ; pc=0x00E4
.L1_while_end:

    lw x5, -4(x17) ; x                                  ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    sleep ; stall RAW                                   ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    add x11, x5, x0                                     ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    jal x0, .L_codegen_1_main_end                       ; pc=0x0108
    sleep ; nop despues de control                      ; pc=0x010C
    sleep ; nop despues de control                      ; pc=0x0110
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    addi x2, x2, 16                                     ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    freeze                                              ; pc=0x0134