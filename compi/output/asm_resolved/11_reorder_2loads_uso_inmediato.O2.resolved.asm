; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x00D8

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00D4 jal -> .L_ir_1_main_end (addr=0x00D8, offset=4)

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
    addi x9, x0, 2                                      ; pc=0x0040
    addi x10, x0, 3                                     ; pc=0x0044
    add x8, x9, x10                                     ; pc=0x0048
    sw x8, -40(x17) ; t1                                ; pc=0x004C
    lw x7, -4(x17) ; a                                  ; pc=0x0050
    addi x8, x0, 1                                      ; pc=0x0054
    add x10, x7, x8                                     ; pc=0x0058
    add x4, x10, x0 ; promote parta                     ; pc=0x005C
    lw x9, -40(x17) ; t1                                ; pc=0x0060
    add x5, x9, x0 ; promote w1                         ; pc=0x0064
    addi x10, x0, 4                                     ; pc=0x0068
    addi x8, x0, 5                                      ; pc=0x006C
    add x7, x10, x8                                     ; pc=0x0070
    add x3, x7, x0 ; promote w2                         ; pc=0x0074
    addiHIGH x7, x0, 0                                  ; pc=0x0078
    addi x7, x7, 32772                                  ; pc=0x007C
    lw x9, 0(x7) ; gb                                   ; pc=0x0080
    sw x9, -20(x17) ; b                                 ; pc=0x0084
    add x8, x5, x3                                      ; pc=0x0088
    sw x8, -52(x17) ; t4                                ; pc=0x008C
    lw x10, -20(x17) ; b                                ; pc=0x0090
    addi x7, x0, 1                                      ; pc=0x0094
    add x9, x10, x7                                     ; pc=0x0098
    add x6, x9, x0 ; promote partb                      ; pc=0x009C
    lw x8, -52(x17) ; t4                                ; pc=0x00A0
    sw x8, -28(x17) ; w3                                ; pc=0x00A4
    lw x9, -28(x17) ; w3                                ; pc=0x00A8
    add x7, x9, x3                                      ; pc=0x00AC
    sw x7, -32(x17) ; w4                                ; pc=0x00B0
    add x10, x4, x6                                     ; pc=0x00B4
    sw x10, -64(x17) ; t6                               ; pc=0x00B8
    lw x8, -64(x17) ; t6                                ; pc=0x00BC
    lw x7, -32(x17) ; w4                                ; pc=0x00C0
    add x9, x8, x7                                      ; pc=0x00C4
    sw x9, -36(x17) ; total                             ; pc=0x00C8
    lw x10, -36(x17) ; total                            ; pc=0x00CC
    add x11, x10, x0                                    ; pc=0x00D0
    jal x0, 4                                           ; pc=0x00D4 ; target=.L_ir_1_main_end ; addr=0x00D8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00D8
    addi x2, x2, 76                                     ; pc=0x00DC
    freeze                                              ; pc=0x00E0