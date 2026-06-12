; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0084
;   marcar = 0x0090
;   .L_ir_2_marcar_end = 0x00D4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0054 jal -> marcar (addr=0x0090, offset=60)
;   pc=0x0080 jal -> .L_ir_1_main_end (addr=0x0084, offset=4)
;   pc=0x00D0 jal -> .L_ir_2_marcar_end (addr=0x00D4, offset=4)

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
    addiSigned x2, x2, -32                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 32                                    ; pc=0x002C

    addi x7, x0, 4                                      ; pc=0x0030
    add x4, x7, x0 ; promote base                       ; pc=0x0034
    addi x8, x0, 99                                     ; pc=0x0038
    mul x9, x4, x8                                      ; pc=0x003C
    add x3, x9, x0 ; promote muerto_antes               ; pc=0x0040
    addi x10, x0, 5                                     ; pc=0x0044
    add x11, x10, x0                                    ; pc=0x0048
    sw x4, -4(x17) ; base                               ; pc=0x004C
    sw x3, -8(x17) ; muerto_antes                       ; pc=0x0050
    jal x1, 60                                          ; pc=0x0054 ; target=marcar ; addr=0x0090
    add x7, x11, x0                                     ; pc=0x0058
    sw x7, -20(x17) ; t2                                ; pc=0x005C
    lw x3, -8(x17) ; muerto_antes                       ; pc=0x0060
    addi x9, x0, 123                                    ; pc=0x0064
    add x8, x3, x9                                      ; pc=0x0068
    add x5, x8, x0 ; promote muerto_despues             ; pc=0x006C
    addiHIGH x7, x0, 0                                  ; pc=0x0070
    addi x7, x7, 32768                                  ; pc=0x0074
    lw x10, 0(x7) ; estado                              ; pc=0x0078
    add x11, x10, x0                                    ; pc=0x007C
    jal x0, 4                                           ; pc=0x0080 ; target=.L_ir_1_main_end ; addr=0x0084
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0084
    addi x2, x2, 32                                     ; pc=0x0088
    freeze                                              ; pc=0x008C

marcar:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x0090
    sw x1, 0(x2)                                        ; pc=0x0094
    sw x17, 4(x2)                                       ; pc=0x0098
    addi x17, x2, 16                                    ; pc=0x009C

    add x3, x11, x0 ; parametro promovido valor         ; pc=0x00A0

    addiHIGH x6, x0, 0                                  ; pc=0x00A4
    addi x6, x6, 32768                                  ; pc=0x00A8
    lw x5, 0(x6) ; estado                               ; pc=0x00AC
    add x7, x5, x3                                      ; pc=0x00B0
    addiHIGH x8, x0, 0                                  ; pc=0x00B4
    addi x8, x8, 32768                                  ; pc=0x00B8
    sw x7, 0(x8) ; estado                               ; pc=0x00BC
    addiHIGH x10, x0, 0                                 ; pc=0x00C0
    addi x10, x10, 32768                                ; pc=0x00C4
    lw x9, 0(x10) ; estado                              ; pc=0x00C8
    add x11, x9, x0                                     ; pc=0x00CC
    jal x0, 4                                           ; pc=0x00D0 ; target=.L_ir_2_marcar_end ; addr=0x00D4
.L_ir_2_marcar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00D4
    lw x17, 4(x2)                                       ; pc=0x00D8
    addi x2, x2, 16                                     ; pc=0x00DC
    jalr x1, 0                                          ; pc=0x00E0