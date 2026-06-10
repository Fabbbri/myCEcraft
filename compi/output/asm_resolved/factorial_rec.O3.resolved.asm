; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_1_main_end = 0x0050
;   fact = 0x005C
;   .L_ir_3_ir_cmp_true = 0x0084
;   .L_ir_4_ir_cmp_end = 0x0088
;   L_else_0 = 0x00A4
;   L_end_if_1 = 0x00A4
;   .L_ir_2_fact_end = 0x00E4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0038 jal -> fact (addr=0x005C, offset=36)
;   pc=0x004C jal -> .L_ir_1_main_end (addr=0x0050, offset=4)
;   pc=0x007C bge -> .L_ir_3_ir_cmp_true (addr=0x0084, offset=8)
;   pc=0x0080 jal -> .L_ir_4_ir_cmp_end (addr=0x0088, offset=8)
;   pc=0x0090 beq -> L_else_0 (addr=0x00A4, offset=20)
;   pc=0x009C jal -> .L_ir_2_fact_end (addr=0x00E4, offset=72)
;   pc=0x00A0 jal -> L_end_if_1 (addr=0x00A4, offset=4)
;   pc=0x00BC jal -> fact (addr=0x005C, offset=-96)
;   pc=0x00E0 jal -> .L_ir_2_fact_end (addr=0x00E4, offset=4)

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

    addi x3, x0, 5                                      ; pc=0x0030
    add x11, x3, x0                                     ; pc=0x0034
    jal x1, 36                                          ; pc=0x0038 ; target=fact ; addr=0x005C
    add x7, x11, x0                                     ; pc=0x003C
    sw x7, -4(x17) ; t4__x7                             ; pc=0x0040
    lw x7, -4(x17) ; t4__x7                             ; pc=0x0044
    add x11, x7, x0                                     ; pc=0x0048
    jal x0, 4                                           ; pc=0x004C ; target=.L_ir_1_main_end ; addr=0x0050
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0050
    addi x2, x2, 12                                     ; pc=0x0054
    freeze                                              ; pc=0x0058

fact:
    ; prologue
    addiSigned x2, x2, -28                              ; pc=0x005C
    sw x1, 0(x2)                                        ; pc=0x0060
    sw x17, 4(x2)                                       ; pc=0x0064
    addi x17, x2, 28                                    ; pc=0x0068

    sw x11, -4(x17) ; parametro n                       ; pc=0x006C

    lw x4, -4(x17) ; n                                  ; pc=0x0070
    addi x5, x0, 1                                      ; pc=0x0074
    addi x3, x0, 0                                      ; pc=0x0078
    bge x5, x4, 8                                       ; pc=0x007C ; target=.L_ir_3_ir_cmp_true ; addr=0x0084
    jal x0, 8                                           ; pc=0x0080 ; target=.L_ir_4_ir_cmp_end ; addr=0x0088
.L_ir_3_ir_cmp_true:
    addi x3, x0, 1                                      ; pc=0x0084
.L_ir_4_ir_cmp_end:
    sw x3, -8(x17) ; t0__x3                             ; pc=0x0088
    lw x3, -8(x17) ; t0__x3                             ; pc=0x008C
    beq x3, x0, 20                                      ; pc=0x0090 ; target=L_else_0 ; addr=0x00A4
    addi x6, x0, 1                                      ; pc=0x0094
    add x11, x6, x0                                     ; pc=0x0098
    jal x0, 72                                          ; pc=0x009C ; target=.L_ir_2_fact_end ; addr=0x00E4
    jal x0, 4                                           ; pc=0x00A0 ; target=L_end_if_1 ; addr=0x00A4
L_else_0:
L_end_if_1:
    lw x8, -4(x17) ; n                                  ; pc=0x00A4
    addi x9, x0, 1                                      ; pc=0x00A8
    sub x4, x8, x9                                      ; pc=0x00AC
    sw x4, -12(x17) ; t1__x4                            ; pc=0x00B0
    lw x4, -12(x17) ; t1__x4                            ; pc=0x00B4
    add x11, x4, x0                                     ; pc=0x00B8
    jal x1, -96                                         ; pc=0x00BC ; target=fact ; addr=0x005C
    add x5, x11, x0                                     ; pc=0x00C0
    sw x5, -16(x17) ; t2__x5                            ; pc=0x00C4
    lw x10, -4(x17) ; n                                 ; pc=0x00C8
    lw x5, -16(x17) ; t2__x5                            ; pc=0x00CC
    mul x6, x10, x5                                     ; pc=0x00D0
    sw x6, -20(x17) ; t3__x6                            ; pc=0x00D4
    lw x6, -20(x17) ; t3__x6                            ; pc=0x00D8
    add x11, x6, x0                                     ; pc=0x00DC
    jal x0, 4                                           ; pc=0x00E0 ; target=.L_ir_2_fact_end ; addr=0x00E4
.L_ir_2_fact_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x00E4
    lw x17, 4(x2)                                       ; pc=0x00E8
    addi x2, x2, 28                                     ; pc=0x00EC
    jalr x1, 0                                          ; pc=0x00F0