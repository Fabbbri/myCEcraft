; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x00DC

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00D8 jal -> .L_ir_1_main_end (addr=0x00DC, offset=4)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
da: ; addr=0x8000
    .word 4
db: ; addr=0x8004
    .word 8
dc: ; addr=0x8008
    .word 0xC

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
    addiSigned x2, x2, -72                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 72                                    ; pc=0x002C

    addiHIGH x8, x0, 0                                  ; pc=0x0030
    addi x8, x8, 32768                                  ; pc=0x0034
    lw x7, 0(x8) ; da                                   ; pc=0x0038
    add x5, x7, x0 ; promote a                          ; pc=0x003C
    addi x9, x0, 2                                      ; pc=0x0040
    addi x10, x0, 3                                     ; pc=0x0044
    add x8, x9, x10                                     ; pc=0x0048
    sw x8, -40(x17) ; t1                                ; pc=0x004C
    addi x7, x0, 1                                      ; pc=0x0050
    add x8, x5, x7                                      ; pc=0x0054
    add x3, x8, x0 ; promote parta                      ; pc=0x0058
    lw x10, -40(x17) ; t1                               ; pc=0x005C
    sw x10, -12(x17) ; w1                               ; pc=0x0060
    addiHIGH x8, x0, 0                                  ; pc=0x0064
    addi x8, x8, 32772                                  ; pc=0x0068
    lw x9, 0(x8) ; db                                   ; pc=0x006C
    add x6, x9, x0 ; promote b                          ; pc=0x0070
    addi x7, x0, 4                                      ; pc=0x0074
    addi x10, x0, 5                                     ; pc=0x0078
    add x8, x7, x10                                     ; pc=0x007C
    sw x8, -48(x17) ; t3                                ; pc=0x0080
    addi x9, x0, 1                                      ; pc=0x0084
    add x8, x6, x9                                      ; pc=0x0088
    add x4, x8, x0 ; promote partb                      ; pc=0x008C
    lw x10, -48(x17) ; t3                               ; pc=0x0090
    sw x10, -24(x17) ; w2                               ; pc=0x0094
    addiHIGH x8, x0, 0                                  ; pc=0x0098
    addi x8, x8, 32776                                  ; pc=0x009C
    lw x7, 0(x8) ; dc                                   ; pc=0x00A0
    sw x7, -28(x17) ; c                                 ; pc=0x00A4
    add x9, x3, x4                                      ; pc=0x00A8
    sw x9, -56(x17) ; t5                                ; pc=0x00AC
    lw x10, -28(x17) ; c                                ; pc=0x00B0
    addi x8, x0, 1                                      ; pc=0x00B4
    add x7, x10, x8                                     ; pc=0x00B8
    sw x7, -32(x17) ; partc                             ; pc=0x00BC
    lw x9, -56(x17) ; t5                                ; pc=0x00C0
    lw x7, -32(x17) ; partc                             ; pc=0x00C4
    add x8, x9, x7                                      ; pc=0x00C8
    sw x8, -36(x17) ; total                             ; pc=0x00CC
    lw x10, -36(x17) ; total                            ; pc=0x00D0
    add x11, x10, x0                                    ; pc=0x00D4
    jal x0, 4                                           ; pc=0x00D8 ; target=.L_ir_1_main_end ; addr=0x00DC
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00DC
    addi x2, x2, 72                                     ; pc=0x00E0
    freeze                                              ; pc=0x00E4