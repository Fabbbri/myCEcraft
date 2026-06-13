; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0070
;   acumular = 0x007C
;   .L_ir_2_acumular_end = 0x00C0

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0038 jal -> acumular (addr=0x007C, offset=68)
;   pc=0x0050 jal -> acumular (addr=0x007C, offset=44)
;   pc=0x006C jal -> .L_ir_1_main_end (addr=0x0070, offset=4)
;   pc=0x00BC jal -> .L_ir_2_acumular_end (addr=0x00C0, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
acumulado: ; addr=0x8000
    .word 1

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
    addiSigned x2, x2, -40                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 40                                    ; pc=0x002C

    addi x5, x0, 2                                      ; pc=0x0030
    add x11, x5, x0                                     ; pc=0x0034
    jal x1, 68                                          ; pc=0x0038 ; target=acumular ; addr=0x007C
    add x6, x11, x0                                     ; pc=0x003C
    add x3, x6, x0 ; promote t5                         ; pc=0x0040
    addi x7, x0, 4                                      ; pc=0x0044
    add x11, x7, x0                                     ; pc=0x0048
    sw x3, -28(x17) ; spill t5                          ; pc=0x004C
    jal x1, 44                                          ; pc=0x0050 ; target=acumular ; addr=0x007C
    add x8, x11, x0                                     ; pc=0x0054
    add x4, x8, x0 ; promote t11                        ; pc=0x0058
    addiHIGH x10, x0, 0                                 ; pc=0x005C
    addi x10, x10, 32768                                ; pc=0x0060
    lw x9, 0(x10) ; acumulado                           ; pc=0x0064
    add x11, x9, x0                                     ; pc=0x0068
    jal x0, 4                                           ; pc=0x006C ; target=.L_ir_1_main_end ; addr=0x0070
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0070
    addi x2, x2, 40                                     ; pc=0x0074
    freeze                                              ; pc=0x0078

acumular:
    ; prologue
    addiSigned x2, x2, -32                              ; pc=0x007C
    sw x1, 0(x2)                                        ; pc=0x0080
    sw x17, 4(x2)                                       ; pc=0x0084
    addi x17, x2, 32                                    ; pc=0x0088

    add x3, x11, x0 ; parametro promovido v             ; pc=0x008C

    addiHIGH x6, x0, 0                                  ; pc=0x0090
    addi x6, x6, 32768                                  ; pc=0x0094
    lw x5, 0(x6) ; acumulado                            ; pc=0x0098
    add x7, x5, x3                                      ; pc=0x009C
    addiHIGH x8, x0, 0                                  ; pc=0x00A0
    addi x8, x8, 32768                                  ; pc=0x00A4
    sw x7, 0(x8) ; acumulado                            ; pc=0x00A8
    addiHIGH x10, x0, 0                                 ; pc=0x00AC
    addi x10, x10, 32768                                ; pc=0x00B0
    lw x9, 0(x10) ; acumulado                           ; pc=0x00B4
    add x11, x9, x0                                     ; pc=0x00B8
    jal x0, 4                                           ; pc=0x00BC ; target=.L_ir_2_acumular_end ; addr=0x00C0
.L_ir_2_acumular_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00C0
    lw x17, 4(x2)                                       ; pc=0x00C4
    addi x2, x2, 32                                     ; pc=0x00C8
    jalr x1, 0                                          ; pc=0x00CC