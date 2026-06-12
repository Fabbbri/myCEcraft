; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x008C

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0088 jal -> .L_ir_1_main_end (addr=0x008C, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

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
    addiSigned x2, x2, -44                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 44                                    ; pc=0x002C

    addi x7, x0, 1                                      ; pc=0x0030
    add x3, x7, x0 ; promote a                          ; pc=0x0034
    addi x8, x0, 10                                     ; pc=0x0038
    add x9, x3, x8                                      ; pc=0x003C
    add x4, x9, x0 ; promote primero                    ; pc=0x0040
    addi x10, x0, 2                                     ; pc=0x0044
    add x3, x10, x0 ; promote a                         ; pc=0x0048
    addi x7, x0, 20                                     ; pc=0x004C
    add x9, x3, x7                                      ; pc=0x0050
    add x5, x9, x0 ; promote segundo                    ; pc=0x0054
    addi x8, x0, 3                                      ; pc=0x0058
    add x3, x8, x0 ; promote a                          ; pc=0x005C
    addi x10, x0, 30                                    ; pc=0x0060
    add x9, x3, x10                                     ; pc=0x0064
    add x6, x9, x0 ; promote tercero                    ; pc=0x0068
    add x7, x4, x5                                      ; pc=0x006C
    sw x7, -32(x17) ; t3__x6                            ; pc=0x0070
    lw x8, -32(x17) ; t3__x6                            ; pc=0x0074
    add x7, x8, x6                                      ; pc=0x0078
    sw x7, -36(x17) ; t4__x7                            ; pc=0x007C
    lw x7, -36(x17) ; t4__x7                            ; pc=0x0080
    add x11, x7, x0                                     ; pc=0x0084
    jal x0, 4                                           ; pc=0x0088 ; target=.L_ir_1_main_end ; addr=0x008C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x008C
    addi x2, x2, 44                                     ; pc=0x0090
    freeze                                              ; pc=0x0094