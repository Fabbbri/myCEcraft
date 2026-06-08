; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x00A4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00A0 jal -> .L_ir_1_main_end (addr=0x00A4, offset=4)

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
    addiSigned x2, x2, -48                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 48                                    ; pc=0x002C

    addi x3, x0, 1                                      ; pc=0x0030
    sw x3, -16(x17) ; a__v1__x3                         ; pc=0x0034
    lw x3, -16(x17) ; a__v1__x3                         ; pc=0x0038
    addi x4, x0, 10                                     ; pc=0x003C
    add x5, x3, x4                                      ; pc=0x0040
    sw x5, -20(x17) ; t0__x4                            ; pc=0x0044
    lw x4, -20(x17) ; t0__x4                            ; pc=0x0048
    sw x4, -24(x17) ; first__v1__x5                     ; pc=0x004C
    addi x6, x0, 2                                      ; pc=0x0050
    sw x6, -28(x17) ; a__v2__x6                         ; pc=0x0054
    lw x6, -28(x17) ; a__v2__x6                         ; pc=0x0058
    addi x7, x0, 20                                     ; pc=0x005C
    add x8, x6, x7                                      ; pc=0x0060
    sw x8, -32(x17) ; t1__x7                            ; pc=0x0064
    lw x7, -32(x17) ; t1__x7                            ; pc=0x0068
    sw x7, -36(x17) ; second__v1__x8                    ; pc=0x006C
    lw x5, -24(x17) ; first__v1__x5                     ; pc=0x0070
    lw x8, -36(x17) ; second__v1__x8                    ; pc=0x0074
    add x9, x5, x8                                      ; pc=0x0078
    sw x9, -40(x17) ; t2__x9                            ; pc=0x007C
    lw x6, -28(x17) ; a__v2__x6                         ; pc=0x0080
    sw x6, -4(x17) ; a                                  ; pc=0x0084
    lw x5, -24(x17) ; first__v1__x5                     ; pc=0x0088
    sw x5, -8(x17) ; first                              ; pc=0x008C
    lw x8, -36(x17) ; second__v1__x8                    ; pc=0x0090
    sw x8, -12(x17) ; second                            ; pc=0x0094
    lw x9, -40(x17) ; t2__x9                            ; pc=0x0098
    add x11, x9, x0                                     ; pc=0x009C
    jal x0, 4                                           ; pc=0x00A0 ; target=.L_ir_1_main_end ; addr=0x00A4
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00A4
    addi x2, x2, 48                                     ; pc=0x00A8
    freeze                                              ; pc=0x00AC