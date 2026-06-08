; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L0_while_start = 0x0038
;   .L1_while_end = 0x0058
;   .L_codegen_1_main_end = 0x0064

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0040 bge -> .L1_while_end (addr=0x0058, offset=24)
;   pc=0x0054 jal -> .L0_while_start (addr=0x0038, offset=-28)
;   pc=0x0060 jal -> .L_codegen_1_main_end (addr=0x0064, offset=4)

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
    lw x3, -4(x17) ; x                                  ; pc=0x0038
    addi x4, x0, 5                                      ; pc=0x003C
    bge x3, x4, 24                                      ; pc=0x0040 ; target=.L1_while_end ; addr=0x0058
    lw x4, -4(x17) ; x                                  ; pc=0x0044
    addi x3, x0, 1                                      ; pc=0x0048
    add x5, x4, x3                                      ; pc=0x004C
    sw x5, -4(x17) ; x                                  ; pc=0x0050
    jal x0, -28                                         ; pc=0x0054 ; target=.L0_while_start ; addr=0x0038
.L1_while_end:

    lw x5, -4(x17) ; x                                  ; pc=0x0058
    add x11, x5, x0                                     ; pc=0x005C
    jal x0, 4                                           ; pc=0x0060 ; target=.L_codegen_1_main_end ; addr=0x0064
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0064
    addi x2, x2, 16                                     ; pc=0x0068
    freeze                                              ; pc=0x006C