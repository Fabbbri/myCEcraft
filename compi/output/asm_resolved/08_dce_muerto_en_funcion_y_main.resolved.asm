; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x00B8
;   acumular = 0x00C4
;   .L_ir_2_acumular_end = 0x012C

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0044 jal -> acumular (addr=0x00C4, offset=128)
;   pc=0x0098 jal -> acumular (addr=0x00C4, offset=44)
;   pc=0x00B4 jal -> .L_ir_1_main_end (addr=0x00B8, offset=4)
;   pc=0x0128 jal -> .L_ir_2_acumular_end (addr=0x012C, offset=4)

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
    addiSigned x2, x2, -60                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 60                                    ; pc=0x002C

    addi x7, x0, 3                                      ; pc=0x0030
    add x6, x7, x0 ; promote semilla                    ; pc=0x0034
    addi x8, x0, 2                                      ; pc=0x0038
    add x11, x8, x0                                     ; pc=0x003C
    sw x6, -4(x17) ; semilla                            ; pc=0x0040
    jal x1, 128                                         ; pc=0x0044 ; target=acumular ; addr=0x00C4
    add x9, x11, x0                                     ; pc=0x0048
    sw x9, -28(x17) ; t5                                ; pc=0x004C
    lw x6, -4(x17) ; semilla                            ; pc=0x0050
    addi x10, x0, 11                                    ; pc=0x0054
    add x7, x6, x10                                     ; pc=0x0058
    add x3, x7, x0 ; promote e1                         ; pc=0x005C
    add x8, x3, x3                                      ; pc=0x0060
    add x4, x8, x0 ; promote e2                         ; pc=0x0064
    add x9, x4, x3                                      ; pc=0x0068
    add x5, x9, x0 ; promote e3                         ; pc=0x006C
    add x7, x5, x4                                      ; pc=0x0070
    sw x7, -20(x17) ; e4                                ; pc=0x0074
    lw x10, -20(x17) ; e4                               ; pc=0x0078
    add x8, x10, x5                                     ; pc=0x007C
    sw x8, -24(x17) ; e5                                ; pc=0x0080
    addi x9, x0, 4                                      ; pc=0x0084
    add x11, x9, x0                                     ; pc=0x0088
    sw x3, -8(x17) ; e1                                 ; pc=0x008C
    sw x4, -12(x17) ; e2                                ; pc=0x0090
    sw x5, -16(x17) ; e3                                ; pc=0x0094
    jal x1, 44                                          ; pc=0x0098 ; target=acumular ; addr=0x00C4
    add x7, x11, x0                                     ; pc=0x009C
    sw x7, -52(x17) ; t11                               ; pc=0x00A0
    addiHIGH x10, x0, 0                                 ; pc=0x00A4
    addi x10, x10, 32768                                ; pc=0x00A8
    lw x8, 0(x10) ; acumulado                           ; pc=0x00AC
    add x11, x8, x0                                     ; pc=0x00B0
    jal x0, 4                                           ; pc=0x00B4 ; target=.L_ir_1_main_end ; addr=0x00B8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00B8
    addi x2, x2, 60                                     ; pc=0x00BC
    freeze                                              ; pc=0x00C0

acumular:
    ; prologue
    addiSigned x2, x2, -48                              ; pc=0x00C4
    sw x1, 0(x2)                                        ; pc=0x00C8
    sw x17, 4(x2)                                       ; pc=0x00CC
    addi x17, x2, 48                                    ; pc=0x00D0

    add x5, x11, x0 ; parametro promovido v             ; pc=0x00D4

    addi x7, x0, 10                                     ; pc=0x00D8
    add x8, x5, x7                                      ; pc=0x00DC
    add x3, x8, x0 ; promote d1                         ; pc=0x00E0
    add x9, x3, x3                                      ; pc=0x00E4
    add x4, x9, x0 ; promote d2                         ; pc=0x00E8
    add x10, x4, x3                                     ; pc=0x00EC
    add x6, x10, x0 ; promote d3                        ; pc=0x00F0
    add x8, x6, x4                                      ; pc=0x00F4
    sw x8, -20(x17) ; d4                                ; pc=0x00F8
    addiHIGH x9, x0, 0                                  ; pc=0x00FC
    addi x9, x9, 32768                                  ; pc=0x0100
    lw x7, 0(x9) ; acumulado                            ; pc=0x0104
    add x10, x7, x5                                     ; pc=0x0108
    addiHIGH x8, x0, 0                                  ; pc=0x010C
    addi x8, x8, 32768                                  ; pc=0x0110
    sw x10, 0(x8) ; acumulado                           ; pc=0x0114
    addiHIGH x8, x0, 0                                  ; pc=0x0118
    addi x8, x8, 32768                                  ; pc=0x011C
    lw x9, 0(x8) ; acumulado                            ; pc=0x0120
    add x11, x9, x0                                     ; pc=0x0124
    jal x0, 4                                           ; pc=0x0128 ; target=.L_ir_2_acumular_end ; addr=0x012C
.L_ir_2_acumular_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x012C
    lw x17, 4(x2)                                       ; pc=0x0130
    addi x2, x2, 48                                     ; pc=0x0134
    jalr x1, 0                                          ; pc=0x0138