; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_ir_0_enderExit                   ; pc=0x0000
    lwv v0, 0(v0)                                       ; pc=0x0004
    sleep ; stall RAW                                   ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0014
.L_ir_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0018
    addi x2, x2, 0x7FF0                                 ; pc=0x001C

    ; prologue
    addiSigned x2, x2, -1088                            ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 1088                                  ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    sw x5, -1024(x17) ; arr                             ; pc=0x0034
    addi x6, x0, 0                                      ; pc=0x0038
    add x3, x6, x0 ; promote i                          ; pc=0x003C
    addi x7, x0, 0                                      ; pc=0x0040
    add x4, x7, x0 ; promote suma                       ; pc=0x0044
L_while_start_0:
    addi x8, x0, 256                                    ; pc=0x0048
    addi x9, x0, 0                                      ; pc=0x004C
    blt x3, x8, .L_ir_2_ir_cmp_true                     ; pc=0x0050
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0054
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0058
.L_ir_3_ir_cmp_end:
    sw x9, -1036(x17) ; t6__x3                          ; pc=0x005C
    lw x10, -1036(x17) ; t6__x3                         ; pc=0x0060
    beq x10, x0, L_while_end_1                          ; pc=0x0064
    add x5, x3, x3                                      ; pc=0x0068
    add x5, x5, x5                                      ; pc=0x006C
    addiSigned x6, x17, -1024                           ; pc=0x0070
    add x6, x6, x5                                      ; pc=0x0074
    sw x3, 0(x6)                                        ; pc=0x0078
    addi x7, x0, 8                                      ; pc=0x007C
    add x9, x3, x7                                      ; pc=0x0080
    addi x8, x0, 8                                      ; pc=0x0084
    add x10, x3, x8                                     ; pc=0x0088
    add x5, x10, x10                                    ; pc=0x008C
    add x5, x5, x5                                      ; pc=0x0090
    addiSigned x6, x17, -1024                           ; pc=0x0094
    add x6, x6, x5                                      ; pc=0x0098
    sw x9, 0(x6)                                        ; pc=0x009C
    addi x7, x0, 16                                     ; pc=0x00A0
    add x8, x3, x7                                      ; pc=0x00A4
    addi x5, x0, 16                                     ; pc=0x00A8
    add x10, x3, x5                                     ; pc=0x00AC
    add x6, x10, x10                                    ; pc=0x00B0
    add x6, x6, x6                                      ; pc=0x00B4
    addiSigned x9, x17, -1024                           ; pc=0x00B8
    add x9, x9, x6                                      ; pc=0x00BC
    sw x8, 0(x9)                                        ; pc=0x00C0
    addi x7, x0, 24                                     ; pc=0x00C4
    add x5, x3, x7                                      ; pc=0x00C8
    addi x6, x0, 24                                     ; pc=0x00CC
    add x10, x3, x6                                     ; pc=0x00D0
    add x9, x10, x10                                    ; pc=0x00D4
    add x9, x9, x9                                      ; pc=0x00D8
    addiSigned x8, x17, -1024                           ; pc=0x00DC
    add x8, x8, x9                                      ; pc=0x00E0
    sw x5, 0(x8)                                        ; pc=0x00E4
    addi x7, x0, 32                                     ; pc=0x00E8
    add x6, x3, x7                                      ; pc=0x00EC
    addi x9, x0, 32                                     ; pc=0x00F0
    add x10, x3, x9                                     ; pc=0x00F4
    add x8, x10, x10                                    ; pc=0x00F8
    add x8, x8, x8                                      ; pc=0x00FC
    addiSigned x5, x17, -1024                           ; pc=0x0100
    add x5, x5, x8                                      ; pc=0x0104
    sw x6, 0(x5)                                        ; pc=0x0108
    addi x7, x0, 40                                     ; pc=0x010C
    add x9, x3, x7                                      ; pc=0x0110
    addi x8, x0, 40                                     ; pc=0x0114
    add x10, x3, x8                                     ; pc=0x0118
    add x5, x10, x10                                    ; pc=0x011C
    add x5, x5, x5                                      ; pc=0x0120
    addiSigned x6, x17, -1024                           ; pc=0x0124
    add x6, x6, x5                                      ; pc=0x0128
    sw x9, 0(x6)                                        ; pc=0x012C
    addi x7, x0, 48                                     ; pc=0x0130
    add x8, x3, x7                                      ; pc=0x0134
    addi x5, x0, 48                                     ; pc=0x0138
    add x10, x3, x5                                     ; pc=0x013C
    add x6, x10, x10                                    ; pc=0x0140
    add x6, x6, x6                                      ; pc=0x0144
    addiSigned x9, x17, -1024                           ; pc=0x0148
    add x9, x9, x6                                      ; pc=0x014C
    sw x8, 0(x9)                                        ; pc=0x0150
    addi x7, x0, 56                                     ; pc=0x0154
    add x5, x3, x7                                      ; pc=0x0158
    addi x6, x0, 56                                     ; pc=0x015C
    add x10, x3, x6                                     ; pc=0x0160
    add x9, x10, x10                                    ; pc=0x0164
    add x9, x9, x9                                      ; pc=0x0168
    addiSigned x8, x17, -1024                           ; pc=0x016C
    add x8, x8, x9                                      ; pc=0x0170
    sw x5, 0(x8)                                        ; pc=0x0174
    addi x7, x0, 64                                     ; pc=0x0178
    add x6, x3, x7                                      ; pc=0x017C
    add x3, x6, x0 ; promote i                          ; pc=0x0180
    jal x0, L_while_start_0                             ; pc=0x0184
L_while_end_1:
    addi x9, x0, 0                                      ; pc=0x0188
    add x3, x9, x0 ; promote i                          ; pc=0x018C
L_while_start_2:
    addi x10, x0, 256                                   ; pc=0x0190
    addi x5, x0, 0                                      ; pc=0x0194
    blt x3, x10, .L_ir_4_ir_cmp_true                    ; pc=0x0198
    jal x0, .L_ir_5_ir_cmp_end                          ; pc=0x019C
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x01A0
.L_ir_5_ir_cmp_end:
    sw x5, -1044(x17) ; t8__x5                          ; pc=0x01A4
    lw x5, -1044(x17) ; t8__x5                          ; pc=0x01A8
    beq x5, x0, L_while_end_3                           ; pc=0x01AC
    add x8, x3, x3                                      ; pc=0x01B0
    add x8, x8, x8                                      ; pc=0x01B4
    addiSigned x6, x17, -1024                           ; pc=0x01B8
    add x6, x6, x8                                      ; pc=0x01BC
    lw x7, 0(x6)                                        ; pc=0x01C0
    sw x7, -1048(x17) ; t9__x6                          ; pc=0x01C4
    addi x9, x0, 8                                      ; pc=0x01C8
    add x10, x3, x9                                     ; pc=0x01CC
    add x5, x10, x10                                    ; pc=0x01D0
    add x5, x5, x5                                      ; pc=0x01D4
    addiSigned x8, x17, -1024                           ; pc=0x01D8
    add x8, x8, x5                                      ; pc=0x01DC
    lw x6, 0(x8)                                        ; pc=0x01E0
    sw x6, -1052(x17) ; t11__x8                         ; pc=0x01E4
    lw x6, -1048(x17) ; t9__x6                          ; pc=0x01E8
    add x7, x4, x6                                      ; pc=0x01EC
    add x4, x7, x0 ; promote suma                       ; pc=0x01F0
    lw x8, -1052(x17) ; t11__x8                         ; pc=0x01F4
    add x9, x4, x8                                      ; pc=0x01F8
    add x4, x9, x0 ; promote suma                       ; pc=0x01FC
    addi x5, x0, 16                                     ; pc=0x0200
    add x10, x3, x5                                     ; pc=0x0204
    add x7, x10, x10                                    ; pc=0x0208
    add x7, x7, x7                                      ; pc=0x020C
    addiSigned x6, x17, -1024                           ; pc=0x0210
    add x6, x6, x7                                      ; pc=0x0214
    lw x9, 0(x6)                                        ; pc=0x0218
    sw x9, -1064(x17) ; t13__x10                        ; pc=0x021C
    addi x8, x0, 24                                     ; pc=0x0220
    add x5, x3, x8                                      ; pc=0x0224
    add x7, x5, x5                                      ; pc=0x0228
    add x7, x7, x7                                      ; pc=0x022C
    addiSigned x10, x17, -1024                          ; pc=0x0230
    add x10, x10, x7                                    ; pc=0x0234
    lw x6, 0(x10)                                       ; pc=0x0238
    sw x6, -1068(x17) ; t15__x4                         ; pc=0x023C
    lw x10, -1064(x17) ; t13__x10                       ; pc=0x0240
    add x9, x4, x10                                     ; pc=0x0244
    add x4, x9, x0 ; promote suma                       ; pc=0x0248
    lw x8, -1068(x17) ; t15__x4                         ; pc=0x024C
    add x7, x4, x8                                      ; pc=0x0250
    add x4, x7, x0 ; promote suma                       ; pc=0x0254
    addi x5, x0, 32                                     ; pc=0x0258
    add x6, x3, x5                                      ; pc=0x025C
    add x3, x6, x0 ; promote i                          ; pc=0x0260
    jal x0, L_while_start_2                             ; pc=0x0264
L_while_end_3:
    add x11, x4, x0                                     ; pc=0x0268
    jal x0, .L_ir_1_main_end                            ; pc=0x026C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0270
    addi x2, x2, 1088                                   ; pc=0x0274
    freeze                                              ; pc=0x0278