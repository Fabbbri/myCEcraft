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
;   .L_ir_6_ir_cmp_true = 0x0108
;   .L_ir_7_ir_cmp_end = 0x010C
;   L_else_4 = 0x0128
;   L_end_if_5 = 0x0128
;   L_while_end_3 = 0x0138
;   .L_ir_1_main_end = 0x0144

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0050 blt -> .L_ir_2_ir_cmp_true (addr=0x0058, offset=8)
;   pc=0x0054 jal -> .L_ir_3_ir_cmp_end (addr=0x005C, offset=8)
;   pc=0x0064 beq -> L_while_end_1 (addr=0x008C, offset=40)
;   pc=0x0088 jal -> L_while_start_0 (addr=0x0048, offset=-64)
;   pc=0x00A4 blt -> .L_ir_4_ir_cmp_true (addr=0x00AC, offset=8)
;   pc=0x00A8 jal -> .L_ir_5_ir_cmp_end (addr=0x00B0, offset=8)
;   pc=0x00B8 beq -> L_while_end_3 (addr=0x0138, offset=128)
;   pc=0x0100 bge -> .L_ir_6_ir_cmp_true (addr=0x0108, offset=8)
;   pc=0x0104 jal -> .L_ir_7_ir_cmp_end (addr=0x010C, offset=8)
;   pc=0x0114 beq -> L_else_4 (addr=0x0128, offset=20)
;   pc=0x0124 jal -> L_end_if_5 (addr=0x0128, offset=4)
;   pc=0x0134 jal -> L_while_start_2 (addr=0x009C, offset=-152)
;   pc=0x0140 jal -> .L_ir_1_main_end (addr=0x0144, offset=4)

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
    beq x9, x0, 128                                     ; pc=0x00B8 ; target=L_while_end_3 ; addr=0x0138
    add x7, x4, x4                                      ; pc=0x00BC
    add x7, x7, x7                                      ; pc=0x00C0
    addiSigned x8, x17, -1920                           ; pc=0x00C4
    add x8, x8, x7                                      ; pc=0x00C8
    lw x10, 0(x8)                                       ; pc=0x00CC
    sw x10, -1948(x17) ; t3                             ; pc=0x00D0
    addi x6, x0, 341                                    ; pc=0x00D4
    add x5, x4, x6                                      ; pc=0x00D8
    sw x5, -1952(x17) ; t5                              ; pc=0x00DC
    lw x9, -1932(x17) ; suma                            ; pc=0x00E0
    lw x7, -1948(x17) ; t3                              ; pc=0x00E4
    add x8, x9, x7                                      ; pc=0x00E8
    sw x8, -1932(x17) ; suma                            ; pc=0x00EC
    lw x10, -1952(x17) ; t5                             ; pc=0x00F0
    add x4, x10, x0 ; promote idx                       ; pc=0x00F4
    addi x5, x0, 480                                    ; pc=0x00F8
    addi x6, x0, 0                                      ; pc=0x00FC
    bge x4, x5, 8                                       ; pc=0x0100 ; target=.L_ir_6_ir_cmp_true ; addr=0x0108
    jal x0, 8                                           ; pc=0x0104 ; target=.L_ir_7_ir_cmp_end ; addr=0x010C
.L_ir_6_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x0108
.L_ir_7_ir_cmp_end:
    sw x6, -1960(x17) ; t6                              ; pc=0x010C
    lw x8, -1960(x17) ; t6                              ; pc=0x0110
    beq x8, x0, 20                                      ; pc=0x0114 ; target=L_else_4 ; addr=0x0128
    addi x7, x0, 480                                    ; pc=0x0118
    sub x9, x4, x7                                      ; pc=0x011C
    add x4, x9, x0 ; promote idx                        ; pc=0x0120
    jal x0, 4                                           ; pc=0x0124 ; target=L_end_if_5 ; addr=0x0128
L_else_4:
L_end_if_5:
    addi x10, x0, 1                                     ; pc=0x0128
    add x6, x3, x10                                     ; pc=0x012C
    add x3, x6, x0 ; promote i                          ; pc=0x0130
    jal x0, -152                                        ; pc=0x0134 ; target=L_while_start_2 ; addr=0x009C
L_while_end_3:
    lw x5, -1932(x17) ; suma                            ; pc=0x0138
    add x11, x5, x0                                     ; pc=0x013C
    jal x0, 4                                           ; pc=0x0140 ; target=.L_ir_1_main_end ; addr=0x0144
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0144
    addi x2, x2, 1976                                   ; pc=0x0148
    freeze                                              ; pc=0x014C