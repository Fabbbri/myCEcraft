; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0108
;   registrar = 0x0114
;   .L_ir_2_registrar_end = 0x0158

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0080 jal -> registrar (addr=0x0114, offset=148)
;   pc=0x0104 jal -> .L_ir_1_main_end (addr=0x0108, offset=4)
;   pc=0x0154 jal -> .L_ir_2_registrar_end (addr=0x0158, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
contador: ; addr=0x8000
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
    addiSigned x2, x2, -108                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 108                                   ; pc=0x002C

    addi x7, x0, 4                                      ; pc=0x0030
    add x3, x7, x0 ; promote local                      ; pc=0x0034
    addi x8, x0, 7                                      ; pc=0x0038
    add x9, x3, x8                                      ; pc=0x003C
    add x4, x9, x0 ; promote p1                         ; pc=0x0040
    add x10, x4, x4                                     ; pc=0x0044
    add x5, x10, x0 ; promote p2                        ; pc=0x0048
    add x7, x5, x4                                      ; pc=0x004C
    add x6, x7, x0 ; promote p3                         ; pc=0x0050
    add x9, x6, x5                                      ; pc=0x0054
    sw x9, -20(x17) ; p4                                ; pc=0x0058
    lw x8, -20(x17) ; p4                                ; pc=0x005C
    add x10, x8, x6                                     ; pc=0x0060
    sw x10, -24(x17) ; p5                               ; pc=0x0064
    addi x7, x0, 6                                      ; pc=0x0068
    add x11, x7, x0                                     ; pc=0x006C
    sw x3, -4(x17) ; local                              ; pc=0x0070
    sw x4, -8(x17) ; p1                                 ; pc=0x0074
    sw x5, -12(x17) ; p2                                ; pc=0x0078
    sw x6, -16(x17) ; p3                                ; pc=0x007C
    jal x1, 148                                         ; pc=0x0080 ; target=registrar ; addr=0x0114
    add x9, x11, x0                                     ; pc=0x0084
    sw x9, -76(x17) ; t7                                ; pc=0x0088
    lw x10, -76(x17) ; t7                               ; pc=0x008C
    sw x10, -28(x17) ; ret                              ; pc=0x0090
    lw x8, -28(x17) ; ret                               ; pc=0x0094
    lw x7, -24(x17) ; p5                                ; pc=0x0098
    add x9, x8, x7                                      ; pc=0x009C
    sw x9, -32(x17) ; q1                                ; pc=0x00A0
    lw x10, -32(x17) ; q1                               ; pc=0x00A4
    lw x9, -32(x17) ; q1                                ; pc=0x00A8
    add x7, x10, x9                                     ; pc=0x00AC
    sw x7, -36(x17) ; q2                                ; pc=0x00B0
    lw x8, -36(x17) ; q2                                ; pc=0x00B4
    lw x7, -32(x17) ; q1                                ; pc=0x00B8
    add x9, x8, x7                                      ; pc=0x00BC
    sw x9, -40(x17) ; q3                                ; pc=0x00C0
    lw x3, -4(x17) ; local                              ; pc=0x00C4
    lw x10, -40(x17) ; q3                               ; pc=0x00C8
    add x9, x3, x10                                     ; pc=0x00CC
    sw x9, -44(x17) ; r1                                ; pc=0x00D0
    lw x7, -44(x17) ; r1                                ; pc=0x00D4
    lw x8, -44(x17) ; r1                                ; pc=0x00D8
    add x9, x7, x8                                      ; pc=0x00DC
    sw x9, -48(x17) ; r2                                ; pc=0x00E0
    lw x10, -48(x17) ; r2                               ; pc=0x00E4
    lw x9, -44(x17) ; r1                                ; pc=0x00E8
    add x8, x10, x9                                     ; pc=0x00EC
    sw x8, -52(x17) ; r3                                ; pc=0x00F0
    addiHIGH x8, x0, 0                                  ; pc=0x00F4
    addi x8, x8, 32768                                  ; pc=0x00F8
    lw x7, 0(x8) ; contador                             ; pc=0x00FC
    add x11, x7, x0                                     ; pc=0x0100
    jal x0, 4                                           ; pc=0x0104 ; target=.L_ir_1_main_end ; addr=0x0108
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0108
    addi x2, x2, 108                                    ; pc=0x010C
    freeze                                              ; pc=0x0110

registrar:
    ; prologue
    addiSigned x2, x2, -20                              ; pc=0x0114
    sw x1, 0(x2)                                        ; pc=0x0118
    sw x17, 4(x2)                                       ; pc=0x011C
    addi x17, x2, 20                                    ; pc=0x0120

    add x3, x11, x0 ; parametro promovido v             ; pc=0x0124

    addiHIGH x7, x0, 0                                  ; pc=0x0128
    addi x7, x7, 32768                                  ; pc=0x012C
    lw x6, 0(x7) ; contador                             ; pc=0x0130
    add x8, x6, x3                                      ; pc=0x0134
    addiHIGH x9, x0, 0                                  ; pc=0x0138
    addi x9, x9, 32768                                  ; pc=0x013C
    sw x8, 0(x9) ; contador                             ; pc=0x0140
    addi x10, x0, 1                                     ; pc=0x0144
    add x7, x3, x10                                     ; pc=0x0148
    add x5, x7, x0 ; promote t1                         ; pc=0x014C
    add x11, x5, x0                                     ; pc=0x0150
    jal x0, 4                                           ; pc=0x0154 ; target=.L_ir_2_registrar_end ; addr=0x0158
.L_ir_2_registrar_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0158
    lw x17, 4(x2)                                       ; pc=0x015C
    addi x2, x2, 20                                     ; pc=0x0160
    jalr x1, 0                                          ; pc=0x0164