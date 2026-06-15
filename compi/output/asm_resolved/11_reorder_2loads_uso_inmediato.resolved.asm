; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x00C8

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00C4 jal -> .L_ir_1_main_end (addr=0x00C8, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
ga: ; addr=0x8000
    .word 0xA
gb: ; addr=0x8004
    .word 0x1E

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
    addiSigned x2, x2, -76                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 76                                    ; pc=0x002C

    addiHIGH x8, x0, 0                                  ; pc=0x0030
    addi x8, x8, 32768                                  ; pc=0x0034
    lw x7, 0(x8) ; ga                                   ; pc=0x0038
    sw x7, -4(x17) ; a                                  ; pc=0x003C
    lw x9, -4(x17) ; a                                  ; pc=0x0040
    addi x10, x0, 1                                     ; pc=0x0044
    add x8, x9, x10                                     ; pc=0x0048
    add x4, x8, x0 ; promote parta                      ; pc=0x004C
    addi x7, x0, 2                                      ; pc=0x0050
    addi x8, x0, 3                                      ; pc=0x0054
    add x10, x7, x8                                     ; pc=0x0058
    add x5, x10, x0 ; promote w1                        ; pc=0x005C
    addi x9, x0, 4                                      ; pc=0x0060
    addi x10, x0, 5                                     ; pc=0x0064
    add x8, x9, x10                                     ; pc=0x0068
    add x3, x8, x0 ; promote w2                         ; pc=0x006C
    addiHIGH x8, x0, 0                                  ; pc=0x0070
    addi x8, x8, 32772                                  ; pc=0x0074
    lw x7, 0(x8) ; gb                                   ; pc=0x0078
    sw x7, -20(x17) ; b                                 ; pc=0x007C
    lw x10, -20(x17) ; b                                ; pc=0x0080
    addi x9, x0, 1                                      ; pc=0x0084
    add x8, x10, x9                                     ; pc=0x0088
    add x6, x8, x0 ; promote partb                      ; pc=0x008C
    add x7, x5, x3                                      ; pc=0x0090
    sw x7, -28(x17) ; w3                                ; pc=0x0094
    lw x8, -28(x17) ; w3                                ; pc=0x0098
    add x9, x8, x3                                      ; pc=0x009C
    sw x9, -32(x17) ; w4                                ; pc=0x00A0
    add x10, x4, x6                                     ; pc=0x00A4
    sw x10, -64(x17) ; t6                               ; pc=0x00A8
    lw x7, -64(x17) ; t6                                ; pc=0x00AC
    lw x9, -32(x17) ; w4                                ; pc=0x00B0
    add x8, x7, x9                                      ; pc=0x00B4
    sw x8, -36(x17) ; total                             ; pc=0x00B8
    lw x10, -36(x17) ; total                            ; pc=0x00BC
    add x11, x10, x0                                    ; pc=0x00C0
    jal x0, 4                                           ; pc=0x00C4 ; target=.L_ir_1_main_end ; addr=0x00C8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00C8
    addi x2, x2, 76                                     ; pc=0x00CC
    freeze                                              ; pc=0x00D0