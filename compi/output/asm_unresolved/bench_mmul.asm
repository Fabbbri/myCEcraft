; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    lwv v0, 0(v0)                                       ; pc=0x0004
    sleep ; stall RAW                                   ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0014
.L_codegen_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0018
    addi x2, x2, 0x7FF0                                 ; pc=0x001C

    ; prologue
    addiSigned x2, x2, -1032                            ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 1032                                  ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -256(x17) ; a                                ; pc=0x0034
    addi x3, x0, 0                                      ; pc=0x0038
    sw x3, -512(x17) ; b                                ; pc=0x003C
    addi x3, x0, 0                                      ; pc=0x0040
    sw x3, -768(x17) ; c                                ; pc=0x0044
    addi x3, x0, 0                                      ; pc=0x0048
    sw x3, -772(x17) ; i                                ; pc=0x004C
    addi x3, x0, 0                                      ; pc=0x0050
    sw x3, -776(x17) ; j                                ; pc=0x0054
    addi x3, x0, 0                                      ; pc=0x0058
    sw x3, -780(x17) ; k                                ; pc=0x005C
    addi x3, x0, 0                                      ; pc=0x0060
    sw x3, -784(x17) ; ia                               ; pc=0x0064
    addi x3, x0, 0                                      ; pc=0x0068
    sw x3, -788(x17) ; kb                               ; pc=0x006C
    addi x3, x0, 0                                      ; pc=0x0070
    sw x3, -792(x17) ; acc                              ; pc=0x0074
    addi x3, x0, 0                                      ; pc=0x0078
    sw x3, -796(x17) ; suma                             ; pc=0x007C

.L0_while_start:
    lw x3, -772(x17) ; i                                ; pc=0x0080
    addi x4, x0, 64                                     ; pc=0x0084
    bge x3, x4, .L1_while_end                           ; pc=0x0088
    lw x4, -772(x17) ; i                                ; pc=0x008C
    lw x3, -772(x17) ; i                                ; pc=0x0090
    add x5, x3, x3                                      ; pc=0x0094
    add x5, x5, x5                                      ; pc=0x0098
    addiSigned x6, x17, -256                            ; pc=0x009C
    ; base a
    add x6, x6, x5                                      ; pc=0x00A0
    sw x4, 0(x6)                                        ; pc=0x00A4
    addi x4, x0, 1                                      ; pc=0x00A8
    lw x6, -772(x17) ; i                                ; pc=0x00AC
    add x5, x6, x6                                      ; pc=0x00B0
    add x5, x5, x5                                      ; pc=0x00B4
    addiSigned x3, x17, -512                            ; pc=0x00B8
    ; base b
    add x3, x3, x5                                      ; pc=0x00BC
    sw x4, 0(x3)                                        ; pc=0x00C0
    lw x4, -772(x17) ; i                                ; pc=0x00C4
    addi x3, x0, 1                                      ; pc=0x00C8
    add x5, x4, x3                                      ; pc=0x00CC
    sw x5, -772(x17) ; i                                ; pc=0x00D0
    jal x0, .L0_while_start                             ; pc=0x00D4
.L1_while_end:

    addi x5, x0, 0                                      ; pc=0x00D8
    sw x5, -772(x17) ; i                                ; pc=0x00DC
    addi x5, x0, 0                                      ; pc=0x00E0
    sw x5, -784(x17) ; ia                               ; pc=0x00E4

.L2_while_start:
    lw x5, -772(x17) ; i                                ; pc=0x00E8
    addi x3, x0, 8                                      ; pc=0x00EC
    bge x5, x3, .L3_while_end                           ; pc=0x00F0
    addi x3, x0, 0                                      ; pc=0x00F4
    sw x3, -776(x17) ; j                                ; pc=0x00F8

.L4_while_start:
    lw x3, -776(x17) ; j                                ; pc=0x00FC
    addi x5, x0, 8                                      ; pc=0x0100
    bge x3, x5, .L5_while_end                           ; pc=0x0104
    addi x5, x0, 0                                      ; pc=0x0108
    sw x5, -792(x17) ; acc                              ; pc=0x010C
    addi x5, x0, 0                                      ; pc=0x0110
    sw x5, -780(x17) ; k                                ; pc=0x0114
    addi x5, x0, 0                                      ; pc=0x0118
    sw x5, -788(x17) ; kb                               ; pc=0x011C

.L6_while_start:
    lw x5, -780(x17) ; k                                ; pc=0x0120
    addi x3, x0, 8                                      ; pc=0x0124
    bge x5, x3, .L7_while_end                           ; pc=0x0128
    lw x3, -792(x17) ; acc                              ; pc=0x012C
    lw x5, -784(x17) ; ia                               ; pc=0x0130
    lw x4, -780(x17) ; k                                ; pc=0x0134
    add x6, x5, x4                                      ; pc=0x0138
    add x4, x6, x6                                      ; pc=0x013C
    add x4, x4, x4                                      ; pc=0x0140
    addiSigned x5, x17, -256                            ; pc=0x0144
    ; base a
    add x5, x5, x4                                      ; pc=0x0148
    lw x4, 0(x5)                                        ; pc=0x014C
    lw x5, -788(x17) ; kb                               ; pc=0x0150
    lw x6, -776(x17) ; j                                ; pc=0x0154
    add x7, x5, x6                                      ; pc=0x0158
    add x6, x7, x7                                      ; pc=0x015C
    add x6, x6, x6                                      ; pc=0x0160
    addiSigned x5, x17, -512                            ; pc=0x0164
    ; base b
    add x5, x5, x6                                      ; pc=0x0168
    lw x6, 0(x5)                                        ; pc=0x016C
    mul x5, x4, x6                                      ; pc=0x0170
    add x6, x3, x5                                      ; pc=0x0174
    sw x6, -792(x17) ; acc                              ; pc=0x0178
    lw x6, -780(x17) ; k                                ; pc=0x017C
    addi x5, x0, 1                                      ; pc=0x0180
    add x3, x6, x5                                      ; pc=0x0184
    sw x3, -780(x17) ; k                                ; pc=0x0188
    lw x3, -788(x17) ; kb                               ; pc=0x018C
    addi x5, x0, 8                                      ; pc=0x0190
    add x6, x3, x5                                      ; pc=0x0194
    sw x6, -788(x17) ; kb                               ; pc=0x0198
    jal x0, .L6_while_start                             ; pc=0x019C
.L7_while_end:

    lw x6, -792(x17) ; acc                              ; pc=0x01A0
    lw x5, -784(x17) ; ia                               ; pc=0x01A4
    lw x3, -776(x17) ; j                                ; pc=0x01A8
    add x4, x5, x3                                      ; pc=0x01AC
    add x3, x4, x4                                      ; pc=0x01B0
    add x3, x3, x3                                      ; pc=0x01B4
    addiSigned x5, x17, -768                            ; pc=0x01B8
    ; base c
    add x5, x5, x3                                      ; pc=0x01BC
    sw x6, 0(x5)                                        ; pc=0x01C0
    lw x6, -776(x17) ; j                                ; pc=0x01C4
    addi x5, x0, 1                                      ; pc=0x01C8
    add x3, x6, x5                                      ; pc=0x01CC
    sw x3, -776(x17) ; j                                ; pc=0x01D0
    jal x0, .L4_while_start                             ; pc=0x01D4
.L5_while_end:

    lw x3, -772(x17) ; i                                ; pc=0x01D8
    addi x5, x0, 1                                      ; pc=0x01DC
    add x6, x3, x5                                      ; pc=0x01E0
    sw x6, -772(x17) ; i                                ; pc=0x01E4
    lw x6, -784(x17) ; ia                               ; pc=0x01E8
    addi x5, x0, 8                                      ; pc=0x01EC
    add x3, x6, x5                                      ; pc=0x01F0
    sw x3, -784(x17) ; ia                               ; pc=0x01F4
    jal x0, .L2_while_start                             ; pc=0x01F8
.L3_while_end:

    addi x3, x0, 0                                      ; pc=0x01FC
    sw x3, -796(x17) ; suma                             ; pc=0x0200
    addi x3, x0, 0                                      ; pc=0x0204
    sw x3, -772(x17) ; i                                ; pc=0x0208

.L8_while_start:
    lw x3, -772(x17) ; i                                ; pc=0x020C
    addi x5, x0, 64                                     ; pc=0x0210
    bge x3, x5, .L9_while_end                           ; pc=0x0214
    lw x5, -796(x17) ; suma                             ; pc=0x0218
    lw x3, -772(x17) ; i                                ; pc=0x021C
    add x6, x3, x3                                      ; pc=0x0220
    add x6, x6, x6                                      ; pc=0x0224
    addiSigned x4, x17, -768                            ; pc=0x0228
    ; base c
    add x4, x4, x6                                      ; pc=0x022C
    lw x6, 0(x4)                                        ; pc=0x0230
    add x4, x5, x6                                      ; pc=0x0234
    sw x4, -796(x17) ; suma                             ; pc=0x0238
    lw x4, -772(x17) ; i                                ; pc=0x023C
    addi x6, x0, 1                                      ; pc=0x0240
    add x5, x4, x6                                      ; pc=0x0244
    sw x5, -772(x17) ; i                                ; pc=0x0248
    jal x0, .L8_while_start                             ; pc=0x024C
.L9_while_end:

    lw x5, -796(x17) ; suma                             ; pc=0x0250
    add x11, x5, x0                                     ; pc=0x0254
    jal x0, .L_codegen_1_main_end                       ; pc=0x0258
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x025C
    addi x2, x2, 1032                                   ; pc=0x0260
    freeze                                              ; pc=0x0264