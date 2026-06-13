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

.data
base: ; addr=0x8000
    .word 9

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
    addiSigned x2, x2, -52                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 52                                    ; pc=0x002C

    addiHIGH x8, x0, 0                                  ; pc=0x0030
    addi x8, x8, 32768                                  ; pc=0x0034
    lw x7, 0(x8) ; base                                 ; pc=0x0038
    add x5, x7, x0 ; promote a                          ; pc=0x003C
    addi x9, x0, 1                                      ; pc=0x0040
    add x10, x5, x9                                     ; pc=0x0044
    add x3, x10, x0 ; promote part                      ; pc=0x0048
    addi x8, x0, 5                                      ; pc=0x004C
    addi x7, x0, 6                                      ; pc=0x0050
    add x10, x8, x7                                     ; pc=0x0054
    add x4, x10, x0 ; promote w1                        ; pc=0x0058
    addi x9, x0, 7                                      ; pc=0x005C
    addi x10, x0, 8                                     ; pc=0x0060
    add x7, x9, x10                                     ; pc=0x0064
    add x6, x7, x0 ; promote w2                         ; pc=0x0068
    add x8, x4, x6                                      ; pc=0x006C
    sw x8, -20(x17) ; w3                                ; pc=0x0070
    lw x7, -20(x17) ; w3                                ; pc=0x0074
    add x10, x3, x7                                     ; pc=0x0078
    sw x10, -24(x17) ; total                            ; pc=0x007C
    lw x9, -24(x17) ; total                             ; pc=0x0080
    add x11, x9, x0                                     ; pc=0x0084
    jal x0, 4                                           ; pc=0x0088 ; target=.L_ir_1_main_end ; addr=0x008C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x008C
    addi x2, x2, 52                                     ; pc=0x0090
    freeze                                              ; pc=0x0094