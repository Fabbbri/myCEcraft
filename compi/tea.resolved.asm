; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   tea_encrypt = 0x0000
;   .L_codegen_1_for_start = 0x005C
;   .L_codegen_2_for_end = 0x0118
;   .L_codegen_0_tea_encrypt_end = 0x0150
;   main = 0x0160
;   .L_codegen_3_main_end = 0x0188

; Referencias resueltas
;   pc=0x0064 bge -> .L_codegen_2_for_end (addr=0x0118, offset=180)
;   pc=0x0114 jal -> .L_codegen_1_for_start (addr=0x005C, offset=-184)
;   pc=0x0178 jal -> tea_encrypt (addr=0x0000, offset=-376)
;   pc=0x0184 jal -> .L_codegen_3_main_end (addr=0x0188, offset=4)

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

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -40                              ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 40                                    ; pc=0x000C

    sw x11, 8(x17) ; parámetro v                        ; pc=0x0010

    addi x3, x0, 0                                      ; pc=0x0014
    add x4, x3, x3                                      ; pc=0x0018
    add x4, x4, x4                                      ; pc=0x001C
    lw x5, 8(x17) ; base ref v                          ; pc=0x0020
    add x5, x5, x4                                      ; pc=0x0024
    lw x4, 0(x5)                                        ; pc=0x0028
    sw x4, -4(x17) ; v0                                 ; pc=0x002C
    addi x4, x0, 1                                      ; pc=0x0030
    add x5, x4, x4                                      ; pc=0x0034
    add x5, x5, x5                                      ; pc=0x0038
    lw x3, 8(x17) ; base ref v                          ; pc=0x003C
    add x3, x3, x5                                      ; pc=0x0040
    lw x5, 0(x3)                                        ; pc=0x0044
    sw x5, -8(x17) ; v1                                 ; pc=0x0048
    addi x5, x0, 0                                      ; pc=0x004C
    sw x5, -12(x17) ; sum                               ; pc=0x0050

    ; for
    addi x5, x0, 0                                      ; pc=0x0054
    sw x5, -16(x17) ; i                                 ; pc=0x0058
.L_codegen_1_for_start:
    lw x5, -16(x17) ; i                                 ; pc=0x005C
    addi x3, x0, 32                                     ; pc=0x0060
    bge x5, x3, 180                                     ; pc=0x0064 ; target=.L_codegen_2_for_end ; addr=0x0118
    lw x3, -12(x17) ; sum                               ; pc=0x0068
    addi x4, x0, 4120                                   ; pc=0x006C
    lw x5, 0(x4) ; DELTA                                ; pc=0x0070
    add x4, x3, x5                                      ; pc=0x0074
    sw x4, -12(x17) ; sum                               ; pc=0x0078
    lw x4, -8(x17) ; v1                                 ; pc=0x007C
    addi x5, x0, 0                                      ; pc=0x0080
    add x3, x5, x5                                      ; pc=0x0084
    add x3, x3, x3                                      ; pc=0x0088
    addi x6, x0, 4096                                   ; pc=0x008C
    ; base key
    add x6, x6, x3                                      ; pc=0x0090
    lw x3, 0(x6)                                        ; pc=0x0094
    addi x5, x0, 4                                      ; pc=0x0098
    sll x6, x4, x5                                      ; pc=0x009C
    add x6, x6, x3                                      ; pc=0x00A0
    sw x6, -20(x17) ; aux                               ; pc=0x00A4
    lw x6, -8(x17) ; v1                                 ; pc=0x00A8
    lw x3, -12(x17) ; sum                               ; pc=0x00AC
    add x4, x6, x3                                      ; pc=0x00B0
    sw x4, -24(x17) ; aux2                              ; pc=0x00B4
    lw x4, -8(x17) ; v1                                 ; pc=0x00B8
    addi x3, x0, 1                                      ; pc=0x00BC
    add x6, x3, x3                                      ; pc=0x00C0
    add x6, x6, x6                                      ; pc=0x00C4
    addi x5, x0, 4096                                   ; pc=0x00C8
    ; base key
    add x5, x5, x6                                      ; pc=0x00CC
    lw x6, 0(x5)                                        ; pc=0x00D0
    addi x3, x0, 5                                      ; pc=0x00D4
    srl x5, x4, x3                                      ; pc=0x00D8
    add x5, x5, x6                                      ; pc=0x00DC
    sw x5, -28(x17) ; aux3                              ; pc=0x00E0
    lw x5, -4(x17) ; v0                                 ; pc=0x00E4
    lw x6, -20(x17) ; aux                               ; pc=0x00E8
    lw x4, -24(x17) ; aux2                              ; pc=0x00EC
    xor x3, x6, x4                                      ; pc=0x00F0
    lw x4, -28(x17) ; aux3                              ; pc=0x00F4
    xor x6, x3, x4                                      ; pc=0x00F8
    add x4, x5, x6                                      ; pc=0x00FC
    sw x4, -4(x17) ; v0                                 ; pc=0x0100
    lw x4, -16(x17) ; i                                 ; pc=0x0104
    addi x6, x0, 1                                      ; pc=0x0108
    add x5, x4, x6                                      ; pc=0x010C
    sw x5, -16(x17) ; i                                 ; pc=0x0110
    jal x0, -184                                        ; pc=0x0114 ; target=.L_codegen_1_for_start ; addr=0x005C
.L_codegen_2_for_end:

    lw x5, -4(x17) ; v0                                 ; pc=0x0118
    addi x6, x0, 0                                      ; pc=0x011C
    add x4, x6, x6                                      ; pc=0x0120
    add x4, x4, x4                                      ; pc=0x0124
    lw x3, 8(x17) ; base ref v                          ; pc=0x0128
    add x3, x3, x4                                      ; pc=0x012C
    sw x5, 0(x3)                                        ; pc=0x0130
    lw x5, -8(x17) ; v1                                 ; pc=0x0134
    addi x3, x0, 1                                      ; pc=0x0138
    add x4, x3, x3                                      ; pc=0x013C
    add x4, x4, x4                                      ; pc=0x0140
    lw x6, 8(x17) ; base ref v                          ; pc=0x0144
    add x6, x6, x4                                      ; pc=0x0148
    sw x5, 0(x6)                                        ; pc=0x014C
.L_codegen_0_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0150
    lw x17, 4(x2)                                       ; pc=0x0154
    addi x2, x2, 40                                     ; pc=0x0158
    jalr x1, 0                                          ; pc=0x015C

main:
    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0160
    sw x1, 0(x2)                                        ; pc=0x0164
    sw x17, 4(x2)                                       ; pc=0x0168
    addi x17, x2, 8                                     ; pc=0x016C

    addi x5, x0, 4112                                   ; pc=0x0170
    ; base buffer
    add x11, x5, x0                                     ; pc=0x0174
    jal x1, -376                                        ; pc=0x0178 ; target=tea_encrypt ; addr=0x0000
    addi x5, x0, 0                                      ; pc=0x017C
    add x11, x5, x0                                     ; pc=0x0180
    jal x0, 4                                           ; pc=0x0184 ; target=.L_codegen_3_main_end ; addr=0x0188
.L_codegen_3_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0188
    lw x17, 4(x2)                                       ; pc=0x018C
    addi x2, x2, 8                                      ; pc=0x0190
    jalr x1, 0                                          ; pc=0x0194