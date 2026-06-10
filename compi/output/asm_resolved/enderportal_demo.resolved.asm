; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_endchange_0 = 0x0070
;   .L_ir_1_main_end = 0x007C

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x003C portalv -> L_endchange_0 (addr=0x0070, offset=52)
;   pc=0x0078 jal -> .L_ir_1_main_end (addr=0x007C, offset=4)

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
    addiSigned x2, x2, -12                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 12                                    ; pc=0x002C

    addi x3, x0, 12441                                  ; pc=0x0030
    sw x3, -4(x17) ; num                                ; pc=0x0034
    addi x4, x0, 2121                                   ; pc=0x0038
    portalv x4, v0, 52                                  ; enderPortal         ; pc=0x003C ; target=L_endchange_0 ; addr=0x0070
    lw x5, -4(x17) ; num                                ; pc=0x0040
    addiHIGH x6, x0, 0                                  ; pc=0x0044
    addi x6, x6, 65535                                  ; pc=0x0048
    and x7, x5, x6                                      ; pc=0x004C
    addi x8, x0, 16                                     ; pc=0x0050
    srl x9, x5, x8                                      ; pc=0x0054
    changev v0, x7, x9 ; enderchange                    ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064
    swv v0, 0(v0)                                       ; pc=0x0068
    closev ; enderclose                                 ; pc=0x006C
L_endchange_0:
    addi x10, x0, 0                                     ; pc=0x0070
    add x11, x10, x0                                    ; pc=0x0074
    jal x0, 4                                           ; pc=0x0078 ; target=.L_ir_1_main_end ; addr=0x007C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x007C
    addi x2, x2, 12                                     ; pc=0x0080
    freeze                                              ; pc=0x0084