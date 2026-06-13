; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0064
;   calcular = 0x0070
;   .L_ir_2_calcular_end = 0x0120

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0050 jal -> calcular (addr=0x0070, offset=32)
;   pc=0x0060 jal -> .L_ir_1_main_end (addr=0x0064, offset=4)
;   pc=0x011C jal -> .L_ir_2_calcular_end (addr=0x0120, offset=4)

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

    addi x4, x0, 10                                     ; pc=0x0030
    add x11, x4, x0                                     ; pc=0x0034
    addi x5, x0, 20                                     ; pc=0x0038
    add x12, x5, x0                                     ; pc=0x003C
    addi x6, x0, 30                                     ; pc=0x0040
    add x13, x6, x0                                     ; pc=0x0044
    addi x7, x0, 40                                     ; pc=0x0048
    add x14, x7, x0                                     ; pc=0x004C
    jal x1, 32                                          ; pc=0x0050 ; target=calcular ; addr=0x0070
    add x8, x11, x0                                     ; pc=0x0054
    add x3, x8, x0 ; promote t11                        ; pc=0x0058
    add x11, x3, x0                                     ; pc=0x005C
    jal x0, 4                                           ; pc=0x0060 ; target=.L_ir_1_main_end ; addr=0x0064
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0064
    addi x2, x2, 12                                     ; pc=0x0068
    freeze                                              ; pc=0x006C

calcular:
    ; prologue
    addiSigned x2, x2, -84                              ; pc=0x0070
    sw x1, 0(x2)                                        ; pc=0x0074
    sw x17, 4(x2)                                       ; pc=0x0078
    addi x17, x2, 84                                    ; pc=0x007C

    sw x11, -4(x17) ; parametro a                       ; pc=0x0080
    sw x12, -8(x17) ; parametro b                       ; pc=0x0084
    sw x13, -12(x17) ; parametro c                      ; pc=0x0088
    sw x14, -16(x17) ; parametro d                      ; pc=0x008C

    lw x7, -4(x17) ; a                                  ; pc=0x0090
    addi x8, x0, 1                                      ; pc=0x0094
    add x9, x7, x8                                      ; pc=0x0098
    add x6, x9, x0 ; promote p                          ; pc=0x009C
    lw x10, -8(x17) ; b                                 ; pc=0x00A0
    addi x9, x0, 2                                      ; pc=0x00A4
    add x8, x10, x9                                     ; pc=0x00A8
    add x3, x8, x0 ; promote q                          ; pc=0x00AC
    lw x7, -12(x17) ; c                                 ; pc=0x00B0
    addi x8, x0, 3                                      ; pc=0x00B4
    add x9, x7, x8                                      ; pc=0x00B8
    add x4, x9, x0 ; promote r                          ; pc=0x00BC
    lw x10, -16(x17) ; d                                ; pc=0x00C0
    addi x9, x0, 4                                      ; pc=0x00C4
    add x8, x10, x9                                     ; pc=0x00C8
    add x5, x8, x0 ; promote s                          ; pc=0x00CC
    add x7, x6, x3                                      ; pc=0x00D0
    add x6, x7, x0 ; promote p                          ; pc=0x00D4
    add x8, x3, x4                                      ; pc=0x00D8
    add x3, x8, x0 ; promote q                          ; pc=0x00DC
    add x9, x4, x5                                      ; pc=0x00E0
    add x4, x9, x0 ; promote r                          ; pc=0x00E4
    lw x10, -4(x17) ; a                                 ; pc=0x00E8
    add x7, x5, x10                                     ; pc=0x00EC
    add x5, x7, x0 ; promote s                          ; pc=0x00F0
    add x8, x6, x3                                      ; pc=0x00F4
    sw x8, -68(x17) ; t8                                ; pc=0x00F8
    lw x9, -68(x17) ; t8                                ; pc=0x00FC
    add x7, x9, x4                                      ; pc=0x0100
    sw x7, -72(x17) ; t9                                ; pc=0x0104
    lw x10, -72(x17) ; t9                               ; pc=0x0108
    add x8, x10, x5                                     ; pc=0x010C
    sw x8, -76(x17) ; t10                               ; pc=0x0110
    lw x7, -76(x17) ; t10                               ; pc=0x0114
    add x11, x7, x0                                     ; pc=0x0118
    jal x0, 4                                           ; pc=0x011C ; target=.L_ir_2_calcular_end ; addr=0x0120
.L_ir_2_calcular_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0120
    lw x17, 4(x2)                                       ; pc=0x0124
    addi x2, x2, 84                                     ; pc=0x0128
    jalr x1, 0                                          ; pc=0x012C