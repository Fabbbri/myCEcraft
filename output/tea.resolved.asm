; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0008
;   main = 0x0008
;   .L_codegen_1_main_end = 0x0030
;   tea_encrypt = 0x0040
;   .L0_for_start = 0x009C
;   .L1_for_end = 0x0158
;   .L_codegen_2_tea_encrypt_end = 0x0190

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0008, offset=8)
;   pc=0x0020 jal -> tea_encrypt (addr=0x0040, offset=32)
;   pc=0x002C jal -> .L_codegen_1_main_end (addr=0x0030, offset=4)
;   pc=0x00A4 bge -> .L1_for_end (addr=0x0158, offset=180)
;   pc=0x0154 jal -> .L0_for_start (addr=0x009C, offset=-184)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.data
key: ; addr=0x1000
    .word 0
    .word 1
    .word 2
    .word 3
buffer: ; addr=0x1010
    .word 0
    .word 0
DELTA: ; addr=0x1018
    .word 0x9E3779B9

.text

    ; @EnterCraftWorld
    portalv x0, x0, 8                                   ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x0008
    lwv v0, 0(v0)                                       ; pc=0x0004
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0008
    sw x1, 0(x2)                                        ; pc=0x000C
    sw x17, 4(x2)                                       ; pc=0x0010
    addi x17, x2, 8                                     ; pc=0x0014

    addi x3, x0, 4112                                   ; pc=0x0018
    ; base buffer
    add x11, x3, x0                                     ; pc=0x001C
    jal x1, 32                                          ; pc=0x0020 ; target=tea_encrypt ; addr=0x0040
    addi x3, x0, 0                                      ; pc=0x0024
    add x11, x3, x0                                     ; pc=0x0028
    jal x0, 4                                           ; pc=0x002C ; target=.L_codegen_1_main_end ; addr=0x0030
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0030
    lw x17, 4(x2)                                       ; pc=0x0034
    addi x2, x2, 8                                      ; pc=0x0038
    jalr x1, 0                                          ; pc=0x003C

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -40                              ; pc=0x0040
    sw x1, 0(x2)                                        ; pc=0x0044
    sw x17, 4(x2)                                       ; pc=0x0048
    addi x17, x2, 40                                    ; pc=0x004C

    sw x11, 8(x17) ; parámetro v                        ; pc=0x0050

    addi x3, x0, 0                                      ; pc=0x0054
    add x4, x3, x3                                      ; pc=0x0058
    add x4, x4, x4                                      ; pc=0x005C
    lw x5, 8(x17) ; base ref v                          ; pc=0x0060
    add x5, x5, x4                                      ; pc=0x0064
    lw x4, 0(x5)                                        ; pc=0x0068
    sw x4, -4(x17) ; v0                                 ; pc=0x006C
    addi x4, x0, 1                                      ; pc=0x0070
    add x5, x4, x4                                      ; pc=0x0074
    add x5, x5, x5                                      ; pc=0x0078
    lw x3, 8(x17) ; base ref v                          ; pc=0x007C
    add x3, x3, x5                                      ; pc=0x0080
    lw x5, 0(x3)                                        ; pc=0x0084
    sw x5, -8(x17) ; v1                                 ; pc=0x0088
    addi x5, x0, 0                                      ; pc=0x008C
    sw x5, -12(x17) ; sum                               ; pc=0x0090

    ; for
    addi x5, x0, 0                                      ; pc=0x0094
    sw x5, -16(x17) ; i                                 ; pc=0x0098
.L0_for_start:
    lw x5, -16(x17) ; i                                 ; pc=0x009C
    addi x3, x0, 32                                     ; pc=0x00A0
    bge x5, x3, 180                                     ; pc=0x00A4 ; target=.L1_for_end ; addr=0x0158
    lw x3, -12(x17) ; sum                               ; pc=0x00A8
    addi x4, x0, 4120                                   ; pc=0x00AC
    lw x5, 0(x4) ; DELTA                                ; pc=0x00B0
    add x4, x3, x5                                      ; pc=0x00B4
    sw x4, -12(x17) ; sum                               ; pc=0x00B8
    lw x4, -8(x17) ; v1                                 ; pc=0x00BC
    addi x5, x0, 0                                      ; pc=0x00C0
    add x3, x5, x5                                      ; pc=0x00C4
    add x3, x3, x3                                      ; pc=0x00C8
    addi x6, x0, 4096                                   ; pc=0x00CC
    ; base key
    add x6, x6, x3                                      ; pc=0x00D0
    lw x3, 0(x6)                                        ; pc=0x00D4
    addi x5, x0, 4                                      ; pc=0x00D8
    sll x6, x4, x5                                      ; pc=0x00DC
    add x6, x6, x3                                      ; pc=0x00E0
    sw x6, -20(x17) ; aux                               ; pc=0x00E4
    lw x6, -8(x17) ; v1                                 ; pc=0x00E8
    lw x3, -12(x17) ; sum                               ; pc=0x00EC
    add x4, x6, x3                                      ; pc=0x00F0
    sw x4, -24(x17) ; aux2                              ; pc=0x00F4
    lw x4, -8(x17) ; v1                                 ; pc=0x00F8
    addi x3, x0, 1                                      ; pc=0x00FC
    add x6, x3, x3                                      ; pc=0x0100
    add x6, x6, x6                                      ; pc=0x0104
    addi x5, x0, 4096                                   ; pc=0x0108
    ; base key
    add x5, x5, x6                                      ; pc=0x010C
    lw x6, 0(x5)                                        ; pc=0x0110
    addi x3, x0, 5                                      ; pc=0x0114
    srl x5, x4, x3                                      ; pc=0x0118
    add x5, x5, x6                                      ; pc=0x011C
    sw x5, -28(x17) ; aux3                              ; pc=0x0120
    lw x5, -4(x17) ; v0                                 ; pc=0x0124
    lw x6, -20(x17) ; aux                               ; pc=0x0128
    lw x4, -24(x17) ; aux2                              ; pc=0x012C
    xor x3, x6, x4                                      ; pc=0x0130
    lw x4, -28(x17) ; aux3                              ; pc=0x0134
    xor x6, x3, x4                                      ; pc=0x0138
    add x4, x5, x6                                      ; pc=0x013C
    sw x4, -4(x17) ; v0                                 ; pc=0x0140
    lw x4, -16(x17) ; i                                 ; pc=0x0144
    addi x6, x0, 1                                      ; pc=0x0148
    add x5, x4, x6                                      ; pc=0x014C
    sw x5, -16(x17) ; i                                 ; pc=0x0150
    jal x0, -184                                        ; pc=0x0154 ; target=.L0_for_start ; addr=0x009C
.L1_for_end:

    lw x5, -4(x17) ; v0                                 ; pc=0x0158
    addi x6, x0, 0                                      ; pc=0x015C
    add x4, x6, x6                                      ; pc=0x0160
    add x4, x4, x4                                      ; pc=0x0164
    lw x3, 8(x17) ; base ref v                          ; pc=0x0168
    add x3, x3, x4                                      ; pc=0x016C
    sw x5, 0(x3)                                        ; pc=0x0170
    lw x5, -8(x17) ; v1                                 ; pc=0x0174
    addi x3, x0, 1                                      ; pc=0x0178
    add x4, x3, x3                                      ; pc=0x017C
    add x4, x4, x4                                      ; pc=0x0180
    lw x6, 8(x17) ; base ref v                          ; pc=0x0184
    add x6, x6, x4                                      ; pc=0x0188
    sw x5, 0(x6)                                        ; pc=0x018C
.L_codegen_2_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0190
    lw x17, 4(x2)                                       ; pc=0x0194
    addi x2, x2, 40                                     ; pc=0x0198
    jalr x1, 0                                          ; pc=0x019C