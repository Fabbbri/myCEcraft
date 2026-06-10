; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L_codegen_1_main_end = 0x0088
;   maximo_lista = 0x0094
;   .L0_for_start = 0x00E8
;   .L_codegen_3_cmp_true = 0x012C
;   .L_codegen_4_cmp_end = 0x0130
;   .L2_if_else = 0x0150
;   .L3_if_end = 0x0150
;   .L1_for_end = 0x0164
;   .L_codegen_2_maximo_lista_end = 0x0170

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0078 jal -> maximo_lista (addr=0x0094, offset=28)
;   pc=0x0084 jal -> .L_codegen_1_main_end (addr=0x0088, offset=4)
;   pc=0x00F8 bge -> .L1_for_end (addr=0x0164, offset=108)
;   pc=0x0124 blt -> .L_codegen_3_cmp_true (addr=0x012C, offset=8)
;   pc=0x0128 jal -> .L_codegen_4_cmp_end (addr=0x0130, offset=8)
;   pc=0x0140 beq -> .L2_if_else (addr=0x0150, offset=16)
;   pc=0x014C jal -> .L3_if_end (addr=0x0150, offset=4)
;   pc=0x0160 jal -> .L0_for_start (addr=0x00E8, offset=-120)
;   pc=0x016C jal -> .L_codegen_2_maximo_lista_end (addr=0x0170, offset=4)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, 24                                  ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x0018
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
    addiSigned x2, x2, -64                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 64                                    ; pc=0x002C

    addi x3, x0, 3                                      ; pc=0x0030
    sw x3, -28(x17) ; lista[0]                          ; pc=0x0034
    addi x3, x0, 4                                      ; pc=0x0038
    sw x3, -24(x17) ; lista[1]                          ; pc=0x003C
    addi x3, x0, 5                                      ; pc=0x0040
    sw x3, -20(x17) ; lista[2]                          ; pc=0x0044
    addi x3, x0, 24                                     ; pc=0x0048
    sw x3, -16(x17) ; lista[3]                          ; pc=0x004C
    addi x3, x0, 5                                      ; pc=0x0050
    sw x3, -12(x17) ; lista[4]                          ; pc=0x0054
    addi x3, x0, 65                                     ; pc=0x0058
    sw x3, -8(x17) ; lista[5]                           ; pc=0x005C
    addi x3, x0, 46                                     ; pc=0x0060
    sw x3, -4(x17) ; lista[6]                           ; pc=0x0064
    addiSigned x3, x17, -28                             ; pc=0x0068
    ; base lista
    add x11, x3, x0                                     ; pc=0x006C
    addi x3, x0, 7                                      ; pc=0x0070
    add x12, x3, x0                                     ; pc=0x0074
    jal x1, 28                                          ; pc=0x0078 ; target=maximo_lista ; addr=0x0094
    add x3, x11, x0                                     ; pc=0x007C
    add x11, x3, x0                                     ; pc=0x0080
    jal x0, 4                                           ; pc=0x0084 ; target=.L_codegen_1_main_end ; addr=0x0088
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0088
    addi x2, x2, 64                                     ; pc=0x008C
    freeze                                              ; pc=0x0090

maximo_lista:
    ; prologue
    addiSigned x2, x2, -40                              ; pc=0x0094
    sw x1, 0(x2)                                        ; pc=0x0098
    sw x17, 4(x2)                                       ; pc=0x009C
    addi x17, x2, 40                                    ; pc=0x00A0

    sw x11, -4(x17) ; parámetro lista                   ; pc=0x00A4
    sw x12, -8(x17) ; parámetro largo                   ; pc=0x00A8

    addi x3, x0, 0                                      ; pc=0x00AC
    add x4, x3, x3                                      ; pc=0x00B0
    add x4, x4, x4                                      ; pc=0x00B4
    lw x5, -4(x17) ; base ref lista                     ; pc=0x00B8
    add x5, x5, x4                                      ; pc=0x00BC
    lw x4, 0(x5)                                        ; pc=0x00C0
    sw x4, -12(x17) ; maximo                            ; pc=0x00C4
    addi x4, x0, 0                                      ; pc=0x00C8
    sw x4, -16(x17) ; num                               ; pc=0x00CC
    addi x4, x0, 0                                      ; pc=0x00D0
    sw x4, -20(x17) ; esMayor                           ; pc=0x00D4
    lw x4, -8(x17) ; largo                              ; pc=0x00D8
    sw x4, -24(x17) ; limite                            ; pc=0x00DC

    ; for
    addi x4, x0, 0                                      ; pc=0x00E0
    sw x4, -28(x17) ; i                                 ; pc=0x00E4
.L0_for_start:
    lw x4, -28(x17) ; i                                 ; pc=0x00E8
    lw x5, -24(x17) ; limite                            ; pc=0x00EC
    addi x3, x0, 0                                      ; pc=0x00F0
    add x6, x5, x3                                      ; pc=0x00F4
    bge x4, x6, 108                                     ; pc=0x00F8 ; target=.L1_for_end ; addr=0x0164
    lw x6, -28(x17) ; i                                 ; pc=0x00FC
    add x4, x6, x6                                      ; pc=0x0100
    add x4, x4, x4                                      ; pc=0x0104
    lw x3, -4(x17) ; base ref lista                     ; pc=0x0108
    add x3, x3, x4                                      ; pc=0x010C
    lw x4, 0(x3)                                        ; pc=0x0110
    sw x4, -16(x17) ; num                               ; pc=0x0114
    lw x4, -16(x17) ; num                               ; pc=0x0118
    lw x3, -12(x17) ; maximo                            ; pc=0x011C
    addi x6, x0, 0                                      ; pc=0x0120
    blt x3, x4, 8                                       ; pc=0x0124 ; target=.L_codegen_3_cmp_true ; addr=0x012C
    jal x0, 8                                           ; pc=0x0128 ; target=.L_codegen_4_cmp_end ; addr=0x0130
.L_codegen_3_cmp_true:
    addi x6, x0, 1                                      ; pc=0x012C
.L_codegen_4_cmp_end:
    sw x6, -20(x17) ; esMayor                           ; pc=0x0130

    ; if
    lw x6, -20(x17) ; esMayor                           ; pc=0x0134
    addi x3, x0, 0                                      ; pc=0x0138
    add x4, x6, x3                                      ; pc=0x013C
    beq x4, x0, 16                                      ; pc=0x0140 ; target=.L2_if_else ; addr=0x0150
    lw x4, -16(x17) ; num                               ; pc=0x0144
    sw x4, -12(x17) ; maximo                            ; pc=0x0148
    jal x0, 4                                           ; pc=0x014C ; target=.L3_if_end ; addr=0x0150
.L2_if_else:
.L3_if_end:

    lw x4, -28(x17) ; i                                 ; pc=0x0150
    addi x3, x0, 1                                      ; pc=0x0154
    add x6, x4, x3                                      ; pc=0x0158
    sw x6, -28(x17) ; i                                 ; pc=0x015C
    jal x0, -120                                        ; pc=0x0160 ; target=.L0_for_start ; addr=0x00E8
.L1_for_end:

    lw x6, -12(x17) ; maximo                            ; pc=0x0164
    add x11, x6, x0                                     ; pc=0x0168
    jal x0, 4                                           ; pc=0x016C ; target=.L_codegen_2_maximo_lista_end ; addr=0x0170
.L_codegen_2_maximo_lista_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0170
    lw x17, 4(x2)                                       ; pc=0x0174
    addi x2, x2, 40                                     ; pc=0x0178
    jalr x1, 0                                          ; pc=0x017C