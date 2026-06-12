; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x00B8
;   acumular = 0x00C4
;   .L_ir_2_acumular_end = 0x0108

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0060 jal -> acumular (addr=0x00C4, offset=100)
;   pc=0x0088 jal -> acumular (addr=0x00C4, offset=60)
;   pc=0x00B4 jal -> .L_ir_1_main_end (addr=0x00B8, offset=4)
;   pc=0x0104 jal -> .L_ir_2_acumular_end (addr=0x0108, offset=4)

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
    addiSigned x2, x2, -44                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 44                                    ; pc=0x002C

    addi x7, x0, 10                                     ; pc=0x0030
    add x5, x7, x0 ; promote semilla                    ; pc=0x0034
    addi x8, x0, 8                                      ; pc=0x0038
    mul x9, x5, x8                                      ; pc=0x003C
    add x3, x9, x0 ; promote cadena_muerta              ; pc=0x0040
    addi x10, x0, 77                                    ; pc=0x0044
    add x7, x3, x10                                     ; pc=0x0048
    add x3, x7, x0 ; promote cadena_muerta              ; pc=0x004C
    addi x9, x0, 2                                      ; pc=0x0050
    add x11, x9, x0                                     ; pc=0x0054
    sw x3, -8(x17) ; cadena_muerta                      ; pc=0x0058
    sw x5, -4(x17) ; semilla                            ; pc=0x005C
    jal x1, 100                                         ; pc=0x0060 ; target=acumular ; addr=0x00C4
    add x8, x11, x0                                     ; pc=0x0064
    sw x8, -24(x17) ; t3                                ; pc=0x0068
    lw x3, -8(x17) ; cadena_muerta                      ; pc=0x006C
    addi x7, x0, 3                                      ; pc=0x0070
    mul x10, x3, x7                                     ; pc=0x0074
    add x4, x10, x0 ; promote otro_muerto               ; pc=0x0078
    addi x9, x0, 4                                      ; pc=0x007C
    add x11, x9, x0                                     ; pc=0x0080
    sw x4, -12(x17) ; otro_muerto                       ; pc=0x0084
    jal x1, 60                                          ; pc=0x0088 ; target=acumular ; addr=0x00C4
    add x8, x11, x0                                     ; pc=0x008C
    sw x8, -32(x17) ; t5                                ; pc=0x0090
    lw x4, -12(x17) ; otro_muerto                       ; pc=0x0094
    addi x10, x0, 1                                     ; pc=0x0098
    add x7, x4, x10                                     ; pc=0x009C
    add x4, x7, x0 ; promote otro_muerto                ; pc=0x00A0
    addiHIGH x8, x0, 0                                  ; pc=0x00A4
    addi x8, x8, 32768                                  ; pc=0x00A8
    lw x9, 0(x8) ; acumulado                            ; pc=0x00AC
    add x11, x9, x0                                     ; pc=0x00B0
    jal x0, 4                                           ; pc=0x00B4 ; target=.L_ir_1_main_end ; addr=0x00B8
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00B8
    addi x2, x2, 44                                     ; pc=0x00BC
    freeze                                              ; pc=0x00C0

acumular:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x00C4
    sw x1, 0(x2)                                        ; pc=0x00C8
    sw x17, 4(x2)                                       ; pc=0x00CC
    addi x17, x2, 16                                    ; pc=0x00D0

    add x3, x11, x0 ; parametro promovido valor         ; pc=0x00D4

    addiHIGH x6, x0, 0                                  ; pc=0x00D8
    addi x6, x6, 32768                                  ; pc=0x00DC
    lw x5, 0(x6) ; acumulado                            ; pc=0x00E0
    add x7, x5, x3                                      ; pc=0x00E4
    addiHIGH x8, x0, 0                                  ; pc=0x00E8
    addi x8, x8, 32768                                  ; pc=0x00EC
    sw x7, 0(x8) ; acumulado                            ; pc=0x00F0
    addiHIGH x10, x0, 0                                 ; pc=0x00F4
    addi x10, x10, 32768                                ; pc=0x00F8
    lw x9, 0(x10) ; acumulado                           ; pc=0x00FC
    add x11, x9, x0                                     ; pc=0x0100
    jal x0, 4                                           ; pc=0x0104 ; target=.L_ir_2_acumular_end ; addr=0x0108
.L_ir_2_acumular_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0108
    lw x17, 4(x2)                                       ; pc=0x010C
    addi x2, x2, 16                                     ; pc=0x0110
    jalr x1, 0                                          ; pc=0x0114