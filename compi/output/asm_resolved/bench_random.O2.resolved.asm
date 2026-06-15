; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_while_start_0 = 0x0048
;   .L_ir_2_ir_cmp_true = 0x0058
;   .L_ir_3_ir_cmp_end = 0x005C
;   L_while_end_1 = 0x008C
;   L_while_start_2 = 0x009C
;   .L_ir_4_ir_cmp_true = 0x00AC
;   .L_ir_5_ir_cmp_end = 0x00B0
;   .L_ir_6_ir_cmp_true = 0x0100
;   .L_ir_7_ir_cmp_end = 0x0104
;   L_else_4 = 0x0120
;   L_end_if_5 = 0x0120
;   L_while_end_3 = 0x0130
;   .L_ir_1_main_end = 0x013C

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0050 blt -> .L_ir_2_ir_cmp_true (addr=0x0058, offset=8)
;   pc=0x0054 jal -> .L_ir_3_ir_cmp_end (addr=0x005C, offset=8)
;   pc=0x0064 beq -> L_while_end_1 (addr=0x008C, offset=40)
;   pc=0x0088 jal -> L_while_start_0 (addr=0x0048, offset=-64)
;   pc=0x00A4 blt -> .L_ir_4_ir_cmp_true (addr=0x00AC, offset=8)
;   pc=0x00A8 jal -> .L_ir_5_ir_cmp_end (addr=0x00B0, offset=8)
;   pc=0x00B8 beq -> L_while_end_3 (addr=0x0130, offset=120)
;   pc=0x00F8 bge -> .L_ir_6_ir_cmp_true (addr=0x0100, offset=8)
;   pc=0x00FC jal -> .L_ir_7_ir_cmp_end (addr=0x0104, offset=8)
;   pc=0x010C beq -> L_else_4 (addr=0x0120, offset=20)
;   pc=0x011C jal -> L_end_if_5 (addr=0x0120, offset=4)
;   pc=0x012C jal -> L_while_start_2 (addr=0x009C, offset=-144)
;   pc=0x0138 jal -> .L_ir_1_main_end (addr=0x013C, offset=4)

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
    addiSigned x2, x2, -1976                            ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 1976                                  ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    sw x5, -1920(x17) ; arr                             ; pc=0x0034
    addi x6, x0, 0                                      ; pc=0x0038
    add x3, x6, x0 ; promote i                          ; pc=0x003C
    addi x7, x0, 0                                      ; pc=0x0040
    sw x7, -1932(x17) ; suma                            ; pc=0x0044
L_while_start_0:
    addi x8, x0, 480                                    ; pc=0x0048
    addi x9, x0, 0                                      ; pc=0x004C
    blt x3, x8, 8                                       ; pc=0x0050 ; target=.L_ir_2_ir_cmp_true ; addr=0x0058
    jal x0, 8                                           ; pc=0x0054 ; target=.L_ir_3_ir_cmp_end ; addr=0x005C
.L_ir_2_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0058
.L_ir_3_ir_cmp_end:
    sw x9, -1936(x17) ; t0                              ; pc=0x005C
    lw x10, -1936(x17) ; t0                             ; pc=0x0060
    beq x10, x0, 40                                     ; pc=0x0064 ; target=L_while_end_1 ; addr=0x008C
    add x5, x3, x3                                      ; pc=0x0068
    add x5, x5, x5                                      ; pc=0x006C
    addiSigned x6, x17, -1920                           ; pc=0x0070
    add x6, x6, x5                                      ; pc=0x0074
    sw x3, 0(x6)                                        ; pc=0x0078
    addi x7, x0, 1                                      ; pc=0x007C
    add x9, x3, x7                                      ; pc=0x0080
    add x3, x9, x0 ; promote i                          ; pc=0x0084
    jal x0, -64                                         ; pc=0x0088 ; target=L_while_start_0 ; addr=0x0048
L_while_end_1:
    addi x8, x0, 0                                      ; pc=0x008C
    add x3, x8, x0 ; promote i                          ; pc=0x0090
    addi x10, x0, 0                                     ; pc=0x0094
    add x4, x10, x0 ; promote idx                       ; pc=0x0098
L_while_start_2:
    addi x5, x0, 480                                    ; pc=0x009C
    addi x6, x0, 0                                      ; pc=0x00A0
    blt x3, x5, 8                                       ; pc=0x00A4 ; target=.L_ir_4_ir_cmp_true ; addr=0x00AC
    jal x0, 8                                           ; pc=0x00A8 ; target=.L_ir_5_ir_cmp_end ; addr=0x00B0
.L_ir_4_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x00AC
.L_ir_5_ir_cmp_end:
    sw x6, -1944(x17) ; t2                              ; pc=0x00B0
    lw x9, -1944(x17) ; t2                              ; pc=0x00B4
    beq x9, x0, 120                                     ; pc=0x00B8 ; target=L_while_end_3 ; addr=0x0130
    add x7, x4, x4                                      ; pc=0x00BC
    add x7, x7, x7                                      ; pc=0x00C0
    addiSigned x8, x17, -1920                           ; pc=0x00C4
    add x8, x8, x7                                      ; pc=0x00C8
    lw x10, 0(x8)                                       ; pc=0x00CC
    sw x10, -1948(x17) ; t3                             ; pc=0x00D0
    lw x6, -1932(x17) ; suma                            ; pc=0x00D4
    lw x5, -1948(x17) ; t3                              ; pc=0x00D8
    add x9, x6, x5                                      ; pc=0x00DC
    sw x9, -1932(x17) ; suma                            ; pc=0x00E0
    addi x7, x0, 341                                    ; pc=0x00E4
    add x8, x4, x7                                      ; pc=0x00E8
    add x4, x8, x0 ; promote idx                        ; pc=0x00EC
    addi x10, x0, 480                                   ; pc=0x00F0
    addi x9, x0, 0                                      ; pc=0x00F4
    bge x4, x10, 8                                      ; pc=0x00F8 ; target=.L_ir_6_ir_cmp_true ; addr=0x0100
    jal x0, 8                                           ; pc=0x00FC ; target=.L_ir_7_ir_cmp_end ; addr=0x0104
.L_ir_6_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0100
.L_ir_7_ir_cmp_end:
    sw x9, -1960(x17) ; t6                              ; pc=0x0104
    lw x5, -1960(x17) ; t6                              ; pc=0x0108
    beq x5, x0, 20                                      ; pc=0x010C ; target=L_else_4 ; addr=0x0120
    addi x6, x0, 480                                    ; pc=0x0110
    sub x8, x4, x6                                      ; pc=0x0114
    add x4, x8, x0 ; promote idx                        ; pc=0x0118
    jal x0, 4                                           ; pc=0x011C ; target=L_end_if_5 ; addr=0x0120
L_else_4:
L_end_if_5:
    addi x7, x0, 1                                      ; pc=0x0120
    add x9, x3, x7                                      ; pc=0x0124
    add x3, x9, x0 ; promote i                          ; pc=0x0128
    jal x0, -144                                        ; pc=0x012C ; target=L_while_start_2 ; addr=0x009C
L_while_end_3:
    lw x10, -1932(x17) ; suma                           ; pc=0x0130
    add x11, x10, x0                                    ; pc=0x0134
    jal x0, 4                                           ; pc=0x0138 ; target=.L_ir_1_main_end ; addr=0x013C
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x013C
    addi x2, x2, 1976                                   ; pc=0x0140
    freeze                                              ; pc=0x0144