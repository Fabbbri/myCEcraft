; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

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
    addiSigned x2, x2, -12                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 12                                    ; pc=0x002C

    addi x4, x0, 5                                      ; pc=0x0030
    add x11, x4, x0                                     ; pc=0x0034
    jal x1, factorial                                   ; pc=0x0038
    add x5, x11, x0                                     ; pc=0x003C
    add x3, x5, x0 ; promote t3                         ; pc=0x0040
    add x11, x3, x0                                     ; pc=0x0044
    jal x0, .L_ir_1_main_end                            ; pc=0x0048
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x004C
    addi x2, x2, 12                                     ; pc=0x0050
    freeze                                              ; pc=0x0054

factorial:
    ; prologue
    addiSigned x2, x2, -40                              ; pc=0x0058
    sw x1, 0(x2)                                        ; pc=0x005C
    sw x17, 4(x2)                                       ; pc=0x0060
    sw x20, 8(x2) ; save x20                            ; pc=0x0064
    sw x21, 12(x2) ; save x21                           ; pc=0x0068
    addi x17, x2, 40                                    ; pc=0x006C

    add x5, x11, x0 ; parametro promovido n             ; pc=0x0070

    addi x7, x0, 1                                      ; pc=0x0074
    add x4, x7, x0 ; promote resultado                  ; pc=0x0078
    addi x8, x0, 1                                      ; pc=0x007C
    add x3, x8, x0 ; promote i                          ; pc=0x0080
L_while_start_0:
    addi x9, x0, 0                                      ; pc=0x0084
    bge x5, x3, .L_ir_3_ir_cmp_true                     ; pc=0x0088
    jal x0, .L_ir_4_ir_cmp_end                          ; pc=0x008C
.L_ir_3_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0090
.L_ir_4_ir_cmp_end:
    add x6, x9, x0 ; promote t0                         ; pc=0x0094
    beq x6, x0, L_while_end_1                           ; pc=0x0098
    mul x10, x4, x3                                     ; pc=0x009C
    add x4, x10, x0 ; promote resultado                 ; pc=0x00A0
    addi x7, x0, 1                                      ; pc=0x00A4
    add x8, x3, x7                                      ; pc=0x00A8
    add x3, x8, x0 ; promote i                          ; pc=0x00AC
    jal x0, L_while_start_0                             ; pc=0x00B0
L_while_end_1:
    add x11, x4, x0                                     ; pc=0x00B4
    jal x0, .L_ir_2_factorial_end                       ; pc=0x00B8
.L_ir_2_factorial_end:
    ; epilogue
    lw x20, 8(x2) ; restore x20                         ; pc=0x00BC
    lw x21, 12(x2) ; restore x21                        ; pc=0x00C0
    lw x1, 0(x2)                                        ; pc=0x00C4
    lw x17, 4(x2)                                       ; pc=0x00C8
    addi x2, x2, 40                                     ; pc=0x00CC
    jalr x1, 0                                          ; pc=0x00D0