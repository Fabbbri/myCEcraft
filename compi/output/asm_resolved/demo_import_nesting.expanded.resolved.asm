; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L_codegen_1_main_end = 0x0090
;   suma1 = 0x00C8
;   .L_codegen_2_suma1_end = 0x013C
;   suma2 = 0x0174
;   .L_codegen_3_suma2_end = 0x0210

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0060 jal -> suma2 (addr=0x0174, offset=276)
;   pc=0x0088 jal -> .L_codegen_1_main_end (addr=0x0090, offset=8)
;   pc=0x0134 jal -> .L_codegen_2_suma1_end (addr=0x013C, offset=8)
;   pc=0x01C0 jal -> suma1 (addr=0x00C8, offset=-248)
;   pc=0x0208 jal -> .L_codegen_3_suma2_end (addr=0x0210, offset=8)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, 24                                  ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x0018
    sleep ; nop despues de control                      ; pc=0x0004
    lwv v0, 0(v0)                                       ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    sleep ; stall RAW                                   ; pc=0x0014
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0018
    sleep ; stall RAW                                   ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sw x1, 0(x2)                                        ; pc=0x0028
    sw x17, 4(x2)                                       ; pc=0x002C
    addi x17, x2, 8                                     ; pc=0x0030
    sleep ; stall RAW                                   ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C

    addi x3, x0, 3                                      ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    add x11, x3, x0                                     ; pc=0x0050
    sleep ; stall RAW                                   ; pc=0x0054
    sleep ; stall RAW                                   ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    jal x1, 276                                         ; pc=0x0060 ; target=suma2 ; addr=0x0174
    sleep ; nop despues de control                      ; pc=0x0064
    add x3, x11, x0                                     ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    add x11, x3, x0                                     ; pc=0x0078
    sleep ; stall RAW                                   ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    jal x0, 8                                           ; pc=0x0088 ; target=.L_codegen_1_main_end ; addr=0x0090
    sleep ; nop despues de control                      ; pc=0x008C
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    lw x17, 4(x2)                                       ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    addi x2, x2, 8                                      ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    sleep ; stall RAW                                   ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    jalr x1, 0                                          ; pc=0x00C0
    sleep ; nop despues de control                      ; pc=0x00C4

suma1:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sw x1, 0(x2)                                        ; pc=0x00D8
    sw x17, 4(x2)                                       ; pc=0x00DC
    addi x17, x2, 8                                     ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC

    sw x11, 8(x17) ; parámetro x                        ; pc=0x00F0

    lw x3, 8(x17) ; x                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    addi x4, x0, 1                                      ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    add x5, x3, x4                                      ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    add x11, x5, x0                                     ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    jal x0, 8                                           ; pc=0x0134 ; target=.L_codegen_2_suma1_end ; addr=0x013C
    sleep ; nop despues de control                      ; pc=0x0138
.L_codegen_2_suma1_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x013C
    sleep ; stall RAW                                   ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    lw x17, 4(x2)                                       ; pc=0x014C
    sleep ; stall RAW                                   ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    addi x2, x2, 8                                      ; pc=0x015C
    sleep ; stall RAW                                   ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    sleep ; stall RAW                                   ; pc=0x0168
    jalr x1, 0                                          ; pc=0x016C
    sleep ; nop despues de control                      ; pc=0x0170

suma2:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    sleep ; stall RAW                                   ; pc=0x017C
    sleep ; stall RAW                                   ; pc=0x0180
    sw x1, 0(x2)                                        ; pc=0x0184
    sw x17, 4(x2)                                       ; pc=0x0188
    addi x17, x2, 8                                     ; pc=0x018C
    sleep ; stall RAW                                   ; pc=0x0190
    sleep ; stall RAW                                   ; pc=0x0194
    sleep ; stall RAW                                   ; pc=0x0198

    sw x11, 8(x17) ; parámetro x                        ; pc=0x019C

    lw x5, 8(x17) ; x                                   ; pc=0x01A0
    sleep ; stall RAW                                   ; pc=0x01A4
    sleep ; stall RAW                                   ; pc=0x01A8
    sleep ; stall RAW                                   ; pc=0x01AC
    add x11, x5, x0                                     ; pc=0x01B0
    sleep ; stall RAW                                   ; pc=0x01B4
    sleep ; stall RAW                                   ; pc=0x01B8
    sleep ; stall RAW                                   ; pc=0x01BC
    jal x1, -248                                        ; pc=0x01C0 ; target=suma1 ; addr=0x00C8
    sleep ; nop despues de control                      ; pc=0x01C4
    add x5, x11, x0                                     ; pc=0x01C8
    sleep ; stall RAW                                   ; pc=0x01CC
    sleep ; stall RAW                                   ; pc=0x01D0
    sleep ; stall RAW                                   ; pc=0x01D4
    addi x4, x0, 1                                      ; pc=0x01D8
    sleep ; stall RAW                                   ; pc=0x01DC
    sleep ; stall RAW                                   ; pc=0x01E0
    sleep ; stall RAW                                   ; pc=0x01E4
    add x3, x5, x4                                      ; pc=0x01E8
    sleep ; stall RAW                                   ; pc=0x01EC
    sleep ; stall RAW                                   ; pc=0x01F0
    sleep ; stall RAW                                   ; pc=0x01F4
    add x11, x3, x0                                     ; pc=0x01F8
    sleep ; stall RAW                                   ; pc=0x01FC
    sleep ; stall RAW                                   ; pc=0x0200
    sleep ; stall RAW                                   ; pc=0x0204
    jal x0, 8                                           ; pc=0x0208 ; target=.L_codegen_3_suma2_end ; addr=0x0210
    sleep ; nop despues de control                      ; pc=0x020C
.L_codegen_3_suma2_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0210
    sleep ; stall RAW                                   ; pc=0x0214
    sleep ; stall RAW                                   ; pc=0x0218
    sleep ; stall RAW                                   ; pc=0x021C
    lw x17, 4(x2)                                       ; pc=0x0220
    sleep ; stall RAW                                   ; pc=0x0224
    sleep ; stall RAW                                   ; pc=0x0228
    sleep ; stall RAW                                   ; pc=0x022C
    addi x2, x2, 8                                      ; pc=0x0230
    sleep ; stall RAW                                   ; pc=0x0234
    sleep ; stall RAW                                   ; pc=0x0238
    sleep ; stall RAW                                   ; pc=0x023C
    jalr x1, 0                                          ; pc=0x0240
    sleep ; nop despues de control                      ; pc=0x0244