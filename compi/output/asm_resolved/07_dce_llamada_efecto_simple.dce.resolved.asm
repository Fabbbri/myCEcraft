; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0058
;   marcar = 0x0064
;   .L_ir_2_marcar_end = 0x00A8

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0038 jal -> marcar (addr=0x0064, offset=44)
;   pc=0x0054 jal -> .L_ir_1_main_end (addr=0x0058, offset=4)
;   pc=0x00A4 jal -> .L_ir_2_marcar_end (addr=0x00A8, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
estado: ; addr=0x8000
    .word 0

.text

    ; @EnterCraftWorld
    portalv x0, x0, 24                                  ; pc=0x0000 ; target=.L_ir_0_enderExit ; addr=0x0018
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
    addiSigned x2, x2, -24                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 24                                    ; pc=0x002C

    addi x4, x0, 5                                      ; pc=0x0030
    add x11, x4, x0                                     ; pc=0x0034
    jal x1, 44                                          ; pc=0x0038 ; target=marcar ; addr=0x0064
    add x5, x11, x0                                     ; pc=0x003C
    add x3, x5, x0 ; promote t2                         ; pc=0x0040
    addiHIGH x7, x0, 0                                  ; pc=0x0044
    addi x7, x7, 32768                                  ; pc=0x0048
    lw x6, 0(x7) ; estado                               ; pc=0x004C
    add x11, x6, x0                                     ; pc=0x0050
    jal x0, 4                                           ; pc=0x0054 ; target=.L_ir_1_main_end ; addr=0x0058
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0058
    addi x2, x2, 24                                     ; pc=0x005C
    freeze                                              ; pc=0x0060

marcar:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x0064
    sw x1, 0(x2)                                        ; pc=0x0068
    sw x17, 4(x2)                                       ; pc=0x006C
    addi x17, x2, 16                                    ; pc=0x0070

    add x3, x11, x0 ; parametro promovido valor         ; pc=0x0074

    addiHIGH x6, x0, 0                                  ; pc=0x0078
    addi x6, x6, 32768                                  ; pc=0x007C
    lw x5, 0(x6) ; estado                               ; pc=0x0080
    add x7, x5, x3                                      ; pc=0x0084
    addiHIGH x8, x0, 0                                  ; pc=0x0088
    addi x8, x8, 32768                                  ; pc=0x008C
    sw x7, 0(x8) ; estado                               ; pc=0x0090
    addiHIGH x10, x0, 0                                 ; pc=0x0094
    addi x10, x10, 32768                                ; pc=0x0098
    lw x9, 0(x10) ; estado                              ; pc=0x009C
    add x11, x9, x0                                     ; pc=0x00A0
    jal x0, 4                                           ; pc=0x00A4 ; target=.L_ir_2_marcar_end ; addr=0x00A8
.L_ir_2_marcar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00A8
    lw x17, 4(x2)                                       ; pc=0x00AC
    addi x2, x2, 16                                     ; pc=0x00B0
    jalr x1, 0                                          ; pc=0x00B4