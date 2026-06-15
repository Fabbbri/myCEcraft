; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
estado: ; addr=0x8000
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
    addiSigned x2, x2, -52                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 52                                    ; pc=0x002C

    addi x6, x0, 7                                      ; pc=0x0030
    add x3, x6, x0 ; promote base                       ; pc=0x0034
    addi x7, x0, 0                                      ; pc=0x0038
    addi x8, x0, 0                                      ; pc=0x003C
    blt x7, x3, .L_ir_2_ir_cmp_true                     ; pc=0x0040
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0044
.L_ir_2_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0048
.L_ir_3_ir_cmp_end:
    add x4, x8, x0 ; promote t1                         ; pc=0x004C
    beq x4, x0, L_else_0                                ; pc=0x0050
    jal x0, L_end_if_1                                  ; pc=0x0054
L_else_0:
L_end_if_1:
    addi x9, x0, 5                                      ; pc=0x0058
    add x11, x9, x0                                     ; pc=0x005C
    sw x3, -4(x17) ; base                               ; pc=0x0060
    sw x4, -40(x17) ; spill t1                          ; pc=0x0064
    jal x1, marcar                                      ; pc=0x0068
    add x10, x11, x0                                    ; pc=0x006C
    add x5, x10, x0 ; promote t10                       ; pc=0x0070
    addiHIGH x8, x0, 0                                  ; pc=0x0074
    addi x8, x8, 32768                                  ; pc=0x0078
    lw x6, 0(x8) ; estado                               ; pc=0x007C
    add x11, x6, x0                                     ; pc=0x0080
    jal x0, .L_ir_1_main_end                            ; pc=0x0084
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0088
    addi x2, x2, 52                                     ; pc=0x008C
    freeze                                              ; pc=0x0090

marcar:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x0094
    sw x1, 0(x2)                                        ; pc=0x0098
    sw x17, 4(x2)                                       ; pc=0x009C
    addi x17, x2, 16                                    ; pc=0x00A0

    add x3, x11, x0 ; parametro promovido v             ; pc=0x00A4

    addiHIGH x6, x0, 0                                  ; pc=0x00A8
    addi x6, x6, 32768                                  ; pc=0x00AC
    lw x5, 0(x6) ; estado                               ; pc=0x00B0
    add x7, x5, x3                                      ; pc=0x00B4
    addiHIGH x8, x0, 0                                  ; pc=0x00B8
    addi x8, x8, 32768                                  ; pc=0x00BC
    sw x7, 0(x8) ; estado                               ; pc=0x00C0
    addiHIGH x10, x0, 0                                 ; pc=0x00C4
    addi x10, x10, 32768                                ; pc=0x00C8
    lw x9, 0(x10) ; estado                              ; pc=0x00CC
    add x11, x9, x0                                     ; pc=0x00D0
    jal x0, .L_ir_4_marcar_end                          ; pc=0x00D4
.L_ir_4_marcar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00D8
    lw x17, 4(x2)                                       ; pc=0x00DC
    addi x2, x2, 16                                     ; pc=0x00E0
    jalr x1, 0                                          ; pc=0x00E4