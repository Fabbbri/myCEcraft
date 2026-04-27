; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0008
;   main = 0x0008
;   .L0_while_start = 0x0028
;   .L4_if_else = 0x0070
;   .L5_if_end = 0x0080
;   .L2_if_else = 0x0084
;   .L3_if_end = 0x0094
;   .L1_while_end = 0x00A8
;   .L_codegen_1_main_end = 0x00B4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0008, offset=8)
;   pc=0x0030 bge -> .L1_while_end (addr=0x00A8, offset=120)
;   pc=0x003C bge -> .L2_if_else (addr=0x0084, offset=72)
;   pc=0x0058 bne -> .L4_if_else (addr=0x0070, offset=24)
;   pc=0x006C jal -> .L5_if_end (addr=0x0080, offset=20)
;   pc=0x0080 jal -> .L3_if_end (addr=0x0094, offset=20)
;   pc=0x00A4 jal -> .L0_while_start (addr=0x0028, offset=-124)
;   pc=0x00B0 jal -> .L_codegen_1_main_end (addr=0x00B4, offset=4)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, 8                                   ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x0008
    lwv v0, 0(v0)                                       ; pc=0x0004
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0008
    sw x1, 0(x2)                                        ; pc=0x000C
    sw x17, 4(x2)                                       ; pc=0x0010
    addi x17, x2, 20                                    ; pc=0x0014

    addi x3, x0, 0                                      ; pc=0x0018
    sw x3, -4(x17) ; x                                  ; pc=0x001C
    addi x3, x0, 0                                      ; pc=0x0020
    sw x3, -8(x17) ; y                                  ; pc=0x0024

.L0_while_start:
    lw x3, -4(x17) ; x                                  ; pc=0x0028
    addi x4, x0, 3                                      ; pc=0x002C
    bge x3, x4, 120                                     ; pc=0x0030 ; target=.L1_while_end ; addr=0x00A8

    ; if
    lw x4, -8(x17) ; y                                  ; pc=0x0034
    addi x3, x0, 2                                      ; pc=0x0038
    bge x4, x3, 72                                      ; pc=0x003C ; target=.L2_if_else ; addr=0x0084
    lw x3, -8(x17) ; y                                  ; pc=0x0040
    addi x4, x0, 1                                      ; pc=0x0044
    add x5, x3, x4                                      ; pc=0x0048
    sw x5, -8(x17) ; y                                  ; pc=0x004C

    ; if
    lw x5, -4(x17) ; x                                  ; pc=0x0050
    addi x4, x0, 1                                      ; pc=0x0054
    bne x5, x4, 24                                      ; pc=0x0058 ; target=.L4_if_else ; addr=0x0070
    lw x4, -8(x17) ; y                                  ; pc=0x005C
    addi x5, x0, 2                                      ; pc=0x0060
    add x3, x4, x5                                      ; pc=0x0064
    sw x3, -8(x17) ; y                                  ; pc=0x0068
    jal x0, 20                                          ; pc=0x006C ; target=.L5_if_end ; addr=0x0080
.L4_if_else:
    lw x3, -8(x17) ; y                                  ; pc=0x0070
    addi x5, x0, 3                                      ; pc=0x0074
    add x4, x3, x5                                      ; pc=0x0078
    sw x4, -8(x17) ; y                                  ; pc=0x007C
.L5_if_end:

    jal x0, 20                                          ; pc=0x0080 ; target=.L3_if_end ; addr=0x0094
.L2_if_else:
    lw x4, -8(x17) ; y                                  ; pc=0x0084
    addi x5, x0, 1                                      ; pc=0x0088
    sub x3, x4, x5                                      ; pc=0x008C
    sw x3, -8(x17) ; y                                  ; pc=0x0090
.L3_if_end:

    lw x3, -4(x17) ; x                                  ; pc=0x0094
    addi x5, x0, 1                                      ; pc=0x0098
    add x4, x3, x5                                      ; pc=0x009C
    sw x4, -4(x17) ; x                                  ; pc=0x00A0
    jal x0, -124                                        ; pc=0x00A4 ; target=.L0_while_start ; addr=0x0028
.L1_while_end:

    lw x4, -8(x17) ; y                                  ; pc=0x00A8
    add x11, x4, x0                                     ; pc=0x00AC
    jal x0, 4                                           ; pc=0x00B0 ; target=.L_codegen_1_main_end ; addr=0x00B4
.L_codegen_1_main_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00B4
    lw x17, 4(x2)                                       ; pc=0x00B8
    addi x2, x2, 20                                     ; pc=0x00BC
    jalr x1, 0                                          ; pc=0x00C0