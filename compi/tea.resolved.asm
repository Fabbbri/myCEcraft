; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   main = 0x0000
;   .L_codegen_0_main_end = 0x0028
;   tea_encrypt = 0x0038
;   .L0_for_start = 0x0094
;   .L1_for_end = 0x0150
;   .L_codegen_1_tea_encrypt_end = 0x0188

; Referencias resueltas
;   pc=0x0018 jal -> tea_encrypt (addr=0x0038, offset=32)
;   pc=0x0024 jal -> .L_codegen_0_main_end (addr=0x0028, offset=4)
;   pc=0x009C bge -> .L1_for_end (addr=0x0150, offset=180)
;   pc=0x014C jal -> .L0_for_start (addr=0x0094, offset=-184)

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

main:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 8                                     ; pc=0x000C

    addi x3, x0, 4112                                   ; pc=0x0010
    ; base buffer
    add x11, x3, x0                                     ; pc=0x0014
    jal x1, 32                                          ; pc=0x0018 ; target=tea_encrypt ; addr=0x0038
    addi x3, x0, 0                                      ; pc=0x001C
    add x11, x3, x0                                     ; pc=0x0020
    jal x0, 4                                           ; pc=0x0024 ; target=.L_codegen_0_main_end ; addr=0x0028
.L_codegen_0_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0028
    lw x17, 4(x2)                                       ; pc=0x002C
    addi x2, x2, 8                                      ; pc=0x0030
    jalr x1, 0                                          ; pc=0x0034

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -40                              ; pc=0x0038
    sw x1, 0(x2)                                        ; pc=0x003C
    sw x17, 4(x2)                                       ; pc=0x0040
    addi x17, x2, 40                                    ; pc=0x0044

    sw x11, 8(x17) ; parámetro v                        ; pc=0x0048

    addi x3, x0, 0                                      ; pc=0x004C
    add x4, x3, x3                                      ; pc=0x0050
    add x4, x4, x4                                      ; pc=0x0054
    lw x5, 8(x17) ; base ref v                          ; pc=0x0058
    add x5, x5, x4                                      ; pc=0x005C
    lw x4, 0(x5)                                        ; pc=0x0060
    sw x4, -4(x17) ; v0                                 ; pc=0x0064
    addi x4, x0, 1                                      ; pc=0x0068
    add x5, x4, x4                                      ; pc=0x006C
    add x5, x5, x5                                      ; pc=0x0070
    lw x3, 8(x17) ; base ref v                          ; pc=0x0074
    add x3, x3, x5                                      ; pc=0x0078
    lw x5, 0(x3)                                        ; pc=0x007C
    sw x5, -8(x17) ; v1                                 ; pc=0x0080
    addi x5, x0, 0                                      ; pc=0x0084
    sw x5, -12(x17) ; sum                               ; pc=0x0088

    ; for
    addi x5, x0, 0                                      ; pc=0x008C
    sw x5, -16(x17) ; i                                 ; pc=0x0090
.L0_for_start:
    lw x5, -16(x17) ; i                                 ; pc=0x0094
    addi x3, x0, 32                                     ; pc=0x0098
    bge x5, x3, 180                                     ; pc=0x009C ; target=.L1_for_end ; addr=0x0150
    lw x3, -12(x17) ; sum                               ; pc=0x00A0
    addi x4, x0, 4120                                   ; pc=0x00A4
    lw x5, 0(x4) ; DELTA                                ; pc=0x00A8
    add x4, x3, x5                                      ; pc=0x00AC
    sw x4, -12(x17) ; sum                               ; pc=0x00B0
    lw x4, -8(x17) ; v1                                 ; pc=0x00B4
    addi x5, x0, 0                                      ; pc=0x00B8
    add x3, x5, x5                                      ; pc=0x00BC
    add x3, x3, x3                                      ; pc=0x00C0
    addi x6, x0, 4096                                   ; pc=0x00C4
    ; base key
    add x6, x6, x3                                      ; pc=0x00C8
    lw x3, 0(x6)                                        ; pc=0x00CC
    addi x5, x0, 4                                      ; pc=0x00D0
    sll x6, x4, x5                                      ; pc=0x00D4
    add x6, x6, x3                                      ; pc=0x00D8
    sw x6, -20(x17) ; aux                               ; pc=0x00DC
    lw x6, -8(x17) ; v1                                 ; pc=0x00E0
    lw x3, -12(x17) ; sum                               ; pc=0x00E4
    add x4, x6, x3                                      ; pc=0x00E8
    sw x4, -24(x17) ; aux2                              ; pc=0x00EC
    lw x4, -8(x17) ; v1                                 ; pc=0x00F0
    addi x3, x0, 1                                      ; pc=0x00F4
    add x6, x3, x3                                      ; pc=0x00F8
    add x6, x6, x6                                      ; pc=0x00FC
    addi x5, x0, 4096                                   ; pc=0x0100
    ; base key
    add x5, x5, x6                                      ; pc=0x0104
    lw x6, 0(x5)                                        ; pc=0x0108
    addi x3, x0, 5                                      ; pc=0x010C
    srl x5, x4, x3                                      ; pc=0x0110
    add x5, x5, x6                                      ; pc=0x0114
    sw x5, -28(x17) ; aux3                              ; pc=0x0118
    lw x5, -4(x17) ; v0                                 ; pc=0x011C
    lw x6, -20(x17) ; aux                               ; pc=0x0120
    lw x4, -24(x17) ; aux2                              ; pc=0x0124
    xor x3, x6, x4                                      ; pc=0x0128
    lw x4, -28(x17) ; aux3                              ; pc=0x012C
    xor x6, x3, x4                                      ; pc=0x0130
    add x4, x5, x6                                      ; pc=0x0134
    sw x4, -4(x17) ; v0                                 ; pc=0x0138
    lw x4, -16(x17) ; i                                 ; pc=0x013C
    addi x6, x0, 1                                      ; pc=0x0140
    add x5, x4, x6                                      ; pc=0x0144
    sw x5, -16(x17) ; i                                 ; pc=0x0148
    jal x0, -184                                        ; pc=0x014C ; target=.L0_for_start ; addr=0x0094
.L1_for_end:

    lw x5, -4(x17) ; v0                                 ; pc=0x0150
    addi x6, x0, 0                                      ; pc=0x0154
    add x4, x6, x6                                      ; pc=0x0158
    add x4, x4, x4                                      ; pc=0x015C
    lw x3, 8(x17) ; base ref v                          ; pc=0x0160
    add x3, x3, x4                                      ; pc=0x0164
    sw x5, 0(x3)                                        ; pc=0x0168
    lw x5, -8(x17) ; v1                                 ; pc=0x016C
    addi x3, x0, 1                                      ; pc=0x0170
    add x4, x3, x3                                      ; pc=0x0174
    add x4, x4, x4                                      ; pc=0x0178
    lw x6, 8(x17) ; base ref v                          ; pc=0x017C
    add x6, x6, x4                                      ; pc=0x0180
    sw x5, 0(x6)                                        ; pc=0x0184
.L_codegen_1_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0188
    lw x17, 4(x2)                                       ; pc=0x018C
    addi x2, x2, 40                                     ; pc=0x0190
    jalr x1, 0                                          ; pc=0x0194