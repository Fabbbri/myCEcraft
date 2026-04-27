; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   main = 0x0000
;   .L_codegen_1_while_start = 0x0020
;   .L_codegen_5_if_else = 0x0068
;   .L_codegen_6_if_end = 0x0078
;   .L_codegen_3_if_else = 0x007C
;   .L_codegen_4_if_end = 0x008C
;   .L_codegen_2_while_end = 0x00A0
;   .L_codegen_0_main_end = 0x00AC

; Referencias resueltas
;   pc=0x0028 bge -> .L_codegen_2_while_end (addr=0x00A0, offset=120)
;   pc=0x0034 bge -> .L_codegen_3_if_else (addr=0x007C, offset=72)
;   pc=0x0050 bne -> .L_codegen_5_if_else (addr=0x0068, offset=24)
;   pc=0x0064 jal -> .L_codegen_6_if_end (addr=0x0078, offset=20)
;   pc=0x0078 jal -> .L_codegen_4_if_end (addr=0x008C, offset=20)
;   pc=0x009C jal -> .L_codegen_1_while_start (addr=0x0020, offset=-124)
;   pc=0x00A8 jal -> .L_codegen_0_main_end (addr=0x00AC, offset=4)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

main:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0000
    sw x1, 0(x2)                                        ; pc=0x0004
    sw x17, 4(x2)                                       ; pc=0x0008
    addi x17, x2, 20                                    ; pc=0x000C

    addi x3, x0, 0                                      ; pc=0x0010
    sw x3, -4(x17) ; x                                  ; pc=0x0014
    addi x3, x0, 0                                      ; pc=0x0018
    sw x3, -8(x17) ; y                                  ; pc=0x001C

.L_codegen_1_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0020
    addi x4, x0, 3                                      ; pc=0x0024
    bge x3, x4, 120                                     ; pc=0x0028 ; target=.L_codegen_2_while_end ; addr=0x00A0

    ; if
    lw x4, -8(x17) ; y                                  ; pc=0x002C
    addi x3, x0, 2                                      ; pc=0x0030
    bge x4, x3, 72                                      ; pc=0x0034 ; target=.L_codegen_3_if_else ; addr=0x007C
    lw x3, -8(x17) ; y                                  ; pc=0x0038
    addi x4, x0, 1                                      ; pc=0x003C
    add x5, x3, x4                                      ; pc=0x0040
    sw x5, -8(x17) ; y                                  ; pc=0x0044

    ; if
    lw x5, -4(x17) ; x                                  ; pc=0x0048
    addi x4, x0, 1                                      ; pc=0x004C
    bne x5, x4, 24                                      ; pc=0x0050 ; target=.L_codegen_5_if_else ; addr=0x0068
    lw x4, -8(x17) ; y                                  ; pc=0x0054
    addi x5, x0, 2                                      ; pc=0x0058
    add x3, x4, x5                                      ; pc=0x005C
    sw x3, -8(x17) ; y                                  ; pc=0x0060
    jal x0, 20                                          ; pc=0x0064 ; target=.L_codegen_6_if_end ; addr=0x0078
.L_codegen_5_if_else:
    lw x3, -8(x17) ; y                                  ; pc=0x0068
    addi x5, x0, 3                                      ; pc=0x006C
    add x4, x3, x5                                      ; pc=0x0070
    sw x4, -8(x17) ; y                                  ; pc=0x0074
.L_codegen_6_if_end:

    jal x0, 20                                          ; pc=0x0078 ; target=.L_codegen_4_if_end ; addr=0x008C
.L_codegen_3_if_else:
    lw x4, -8(x17) ; y                                  ; pc=0x007C
    addi x5, x0, 1                                      ; pc=0x0080
    sub x3, x4, x5                                      ; pc=0x0084
    sw x3, -8(x17) ; y                                  ; pc=0x0088
.L_codegen_4_if_end:

    lw x3, -4(x17) ; x                                  ; pc=0x008C
    addi x5, x0, 1                                      ; pc=0x0090
    add x4, x3, x5                                      ; pc=0x0094
    sw x4, -4(x17) ; x                                  ; pc=0x0098
    jal x0, -124                                        ; pc=0x009C ; target=.L_codegen_1_while_start ; addr=0x0020
.L_codegen_2_while_end:

    lw x4, -8(x17) ; y                                  ; pc=0x00A0
    add x11, x4, x0                                     ; pc=0x00A4
    jal x0, 4                                           ; pc=0x00A8 ; target=.L_codegen_0_main_end ; addr=0x00AC
.L_codegen_0_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00AC
    lw x17, 4(x2)                                       ; pc=0x00B0
    addi x2, x2, 20                                     ; pc=0x00B4
    jalr x1, 0                                          ; pc=0x00B8