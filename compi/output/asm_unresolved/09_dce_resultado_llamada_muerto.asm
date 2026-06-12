; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
contador: ; addr=0x8000
    .word 0

.text

    ; @EnterCraftWorld
    portalv x0, x0, .L_ir_0_enderExit                   ; pc=0x0000
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
    addiSigned x2, x2, -28                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 28                                    ; pc=0x002C

    addi x7, x0, 7                                      ; pc=0x0030
    addi x8, x0, 9                                      ; pc=0x0034
    mul x9, x7, x8                                      ; pc=0x0038
    add x3, x9, x0 ; promote local_muerto               ; pc=0x003C
    addi x10, x0, 6                                     ; pc=0x0040
    add x11, x10, x0                                    ; pc=0x0044
    sw x3, -4(x17) ; local_muerto                       ; pc=0x0048
    jal x1, registrar                                   ; pc=0x004C
    add x9, x11, x0                                     ; pc=0x0050
    add x6, x9, x0 ; promote t3                         ; pc=0x0054
    add x4, x6, x0 ; promote retorno_muerto             ; pc=0x0058
    lw x3, -4(x17) ; local_muerto                       ; pc=0x005C
    add x8, x3, x4                                      ; pc=0x0060
    add x3, x8, x0 ; promote local_muerto               ; pc=0x0064
    addiHIGH x10, x0, 0                                 ; pc=0x0068
    addi x10, x10, 32768                                ; pc=0x006C
    lw x7, 0(x10) ; contador                            ; pc=0x0070
    add x11, x7, x0                                     ; pc=0x0074
    jal x0, .L_ir_1_main_end                            ; pc=0x0078
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x007C
    addi x2, x2, 28                                     ; pc=0x0080
    freeze                                              ; pc=0x0084

registrar:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0088
    sw x1, 0(x2)                                        ; pc=0x008C
    sw x17, 4(x2)                                       ; pc=0x0090
    addi x17, x2, 20                                    ; pc=0x0094

    add x3, x11, x0 ; parametro promovido valor         ; pc=0x0098

    addiHIGH x7, x0, 0                                  ; pc=0x009C
    addi x7, x7, 32768                                  ; pc=0x00A0
    lw x6, 0(x7) ; contador                             ; pc=0x00A4
    add x8, x6, x3                                      ; pc=0x00A8
    addiHIGH x9, x0, 0                                  ; pc=0x00AC
    addi x9, x9, 32768                                  ; pc=0x00B0
    sw x8, 0(x9) ; contador                             ; pc=0x00B4
    addi x10, x0, 2                                     ; pc=0x00B8
    mul x7, x3, x10                                     ; pc=0x00BC
    add x5, x7, x0 ; promote t1                         ; pc=0x00C0
    add x11, x5, x0                                     ; pc=0x00C4
    jal x0, .L_ir_2_registrar_end                       ; pc=0x00C8
.L_ir_2_registrar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00CC
    lw x17, 4(x2)                                       ; pc=0x00D0
    addi x2, x2, 20                                     ; pc=0x00D4
    jalr x1, 0                                          ; pc=0x00D8