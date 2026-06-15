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
    addiSigned x2, x2, -72                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 72                                    ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    sw x5, -40(x17) ; datos[0]                          ; pc=0x0034
    addi x6, x0, 1                                      ; pc=0x0038
    sw x6, -36(x17) ; datos[1]                          ; pc=0x003C
    addi x7, x0, 2                                      ; pc=0x0040
    sw x7, -32(x17) ; datos[2]                          ; pc=0x0044
    addi x8, x0, 3                                      ; pc=0x0048
    sw x8, -28(x17) ; datos[3]                          ; pc=0x004C
    addi x9, x0, 4                                      ; pc=0x0050
    sw x9, -24(x17) ; datos[4]                          ; pc=0x0054
    addi x10, x0, 5                                     ; pc=0x0058
    sw x10, -20(x17) ; datos[5]                         ; pc=0x005C
    addi x5, x0, 6                                      ; pc=0x0060
    sw x5, -16(x17) ; datos[6]                          ; pc=0x0064
    addi x6, x0, 7                                      ; pc=0x0068
    sw x6, -12(x17) ; datos[7]                          ; pc=0x006C
    addi x7, x0, 8                                      ; pc=0x0070
    sw x7, -8(x17) ; datos[8]                           ; pc=0x0074
    addi x8, x0, 9                                      ; pc=0x0078
    sw x8, -4(x17) ; datos[9]                           ; pc=0x007C
    addi x9, x0, 0                                      ; pc=0x0080
    add x3, x9, x0 ; promote i                          ; pc=0x0084
L_for_start_0:
    addi x10, x0, 10                                    ; pc=0x0088
    addi x5, x0, 0                                      ; pc=0x008C
    blt x3, x10, .L_ir_2_ir_cmp_true                    ; pc=0x0090
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x0094
.L_ir_2_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0098
.L_ir_3_ir_cmp_end:
    add x4, x5, x0 ; promote t0                         ; pc=0x009C
    beq x4, x0, L_for_end_1                             ; pc=0x00A0
    add x6, x3, x3                                      ; pc=0x00A4
    add x6, x6, x6                                      ; pc=0x00A8
    addiSigned x7, x17, -40                             ; pc=0x00AC
    add x7, x7, x6                                      ; pc=0x00B0
    lw x8, 0(x7)                                        ; pc=0x00B4
    sw x8, -52(x17) ; t1                                ; pc=0x00B8
    lw x9, -52(x17) ; t1                                ; pc=0x00BC
    addi x5, x0, 1                                      ; pc=0x00C0
    add x10, x9, x5                                     ; pc=0x00C4
    sw x10, -56(x17) ; t2                               ; pc=0x00C8
    lw x6, -56(x17) ; t2                                ; pc=0x00CC
    add x7, x3, x3                                      ; pc=0x00D0
    add x7, x7, x7                                      ; pc=0x00D4
    addiSigned x8, x17, -40                             ; pc=0x00D8
    add x8, x8, x7                                      ; pc=0x00DC
    sw x6, 0(x8)                                        ; pc=0x00E0
    addi x10, x0, 1                                     ; pc=0x00E4
    add x5, x3, x10                                     ; pc=0x00E8
    add x3, x5, x0 ; promote i                          ; pc=0x00EC
    jal x0, L_for_start_0                               ; pc=0x00F0
L_for_end_1:
    addi x9, x0, 9                                      ; pc=0x00F4
    add x7, x9, x9                                      ; pc=0x00F8
    add x7, x7, x7                                      ; pc=0x00FC
    addiSigned x8, x17, -40                             ; pc=0x0100
    add x8, x8, x7                                      ; pc=0x0104
    lw x6, 0(x8)                                        ; pc=0x0108
    sw x6, -64(x17) ; t4                                ; pc=0x010C
    lw x5, -64(x17) ; t4                                ; pc=0x0110
    add x11, x5, x0                                     ; pc=0x0114
    jal x0, .L_ir_1_main_end                            ; pc=0x0118
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x011C
    addi x2, x2, 72                                     ; pc=0x0120
    freeze                                              ; pc=0x0124