; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L0_while_start = 0x0038
;   .L2_if_else = 0x0074
;   .L3_if_end = 0x0074
;   .L1_while_end = 0x0078
;   .L_codegen_1_main_end = 0x0084

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0040 bge -> .L1_while_end (addr=0x0078, offset=56)
;   pc=0x005C bge -> .L2_if_else (addr=0x0074, offset=24)
;   pc=0x0070 jal -> .L3_if_end (addr=0x0074, offset=4)
;   pc=0x0074 jal -> .L0_while_start (addr=0x0038, offset=-60)
;   pc=0x0080 jal -> .L_codegen_1_main_end (addr=0x0084, offset=4)

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
    addiSigned x2, x2, -16                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 16                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -4(x17) ; x                                  ; pc=0x0034

.L0_while_start:
    lw x4, -4(x17) ; x                                  ; pc=0x0038
    addi x5, x0, 5                                      ; pc=0x003C
    bge x4, x5, 56                                      ; pc=0x0040 ; target=.L1_while_end ; addr=0x0078
    lw x6, -4(x17) ; x                                  ; pc=0x0044
    addi x7, x0, 1                                      ; pc=0x0048
    add x8, x6, x7                                      ; pc=0x004C
    sw x8, -4(x17) ; x                                  ; pc=0x0050

    ; if
    lw x9, -4(x17) ; x                                  ; pc=0x0054
    addi x10, x0, 5                                     ; pc=0x0058
    bge x9, x10, 24                                     ; pc=0x005C ; target=.L2_if_else ; addr=0x0074
    lw x3, -4(x17) ; x                                  ; pc=0x0060
    addi x4, x0, 1                                      ; pc=0x0064
    add x5, x3, x4                                      ; pc=0x0068
    sw x5, -4(x17) ; x                                  ; pc=0x006C
    jal x0, 4                                           ; pc=0x0070 ; target=.L3_if_end ; addr=0x0074
.L2_if_else:
.L3_if_end:

    jal x0, -60                                         ; pc=0x0074 ; target=.L0_while_start ; addr=0x0038
.L1_while_end:

    lw x6, -4(x17) ; x                                  ; pc=0x0078
    add x11, x6, x0                                     ; pc=0x007C
    jal x0, 4                                           ; pc=0x0080 ; target=.L_codegen_1_main_end ; addr=0x0084
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0084
    addi x2, x2, 16                                     ; pc=0x0088
    freeze                                              ; pc=0x008C