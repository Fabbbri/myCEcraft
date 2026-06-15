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
;   L_while_end_1 = 0x0188
;   L_while_start_2 = 0x0198
;   .L_ir_4_ir_cmp_true = 0x01A8
;   .L_ir_5_ir_cmp_end = 0x01AC
;   .L_ir_6_ir_cmp_true = 0x01FC
;   .L_ir_7_ir_cmp_end = 0x0200
;   L_else_4 = 0x021C
;   L_end_if_5 = 0x021C
;   L_while_end_3 = 0x022C
;   .L_ir_1_main_end = 0x0238

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0050 blt -> .L_ir_2_ir_cmp_true (addr=0x0058, offset=8)
;   pc=0x0054 jal -> .L_ir_3_ir_cmp_end (addr=0x005C, offset=8)
;   pc=0x0064 beq -> L_while_end_1 (addr=0x0188, offset=292)
;   pc=0x0184 jal -> L_while_start_0 (addr=0x0048, offset=-316)
;   pc=0x01A0 blt -> .L_ir_4_ir_cmp_true (addr=0x01A8, offset=8)
;   pc=0x01A4 jal -> .L_ir_5_ir_cmp_end (addr=0x01AC, offset=8)
;   pc=0x01B4 beq -> L_while_end_3 (addr=0x022C, offset=120)
;   pc=0x01F4 bge -> .L_ir_6_ir_cmp_true (addr=0x01FC, offset=8)
;   pc=0x01F8 jal -> .L_ir_7_ir_cmp_end (addr=0x0200, offset=8)
;   pc=0x0208 beq -> L_else_4 (addr=0x021C, offset=20)
;   pc=0x0218 jal -> L_end_if_5 (addr=0x021C, offset=4)
;   pc=0x0228 jal -> L_while_start_2 (addr=0x0198, offset=-144)
;   pc=0x0234 jal -> .L_ir_1_main_end (addr=0x0238, offset=4)

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
    sw x9, -1936(x17) ; t9__x3                          ; pc=0x005C
    lw x10, -1936(x17) ; t9__x3                         ; pc=0x0060
    beq x10, x0, 292                                    ; pc=0x0064 ; target=L_while_end_1 ; addr=0x0188
    add x5, x3, x3                                      ; pc=0x0068
    add x5, x5, x5                                      ; pc=0x006C
    addiSigned x6, x17, -1920                           ; pc=0x0070
    add x6, x6, x5                                      ; pc=0x0074
    sw x3, 0(x6)                                        ; pc=0x0078
    addi x7, x0, 1                                      ; pc=0x007C
    add x9, x3, x7                                      ; pc=0x0080
    addi x8, x0, 1                                      ; pc=0x0084
    add x10, x3, x8                                     ; pc=0x0088
    add x5, x10, x10                                    ; pc=0x008C
    add x5, x5, x5                                      ; pc=0x0090
    addiSigned x6, x17, -1920                           ; pc=0x0094
    add x6, x6, x5                                      ; pc=0x0098
    sw x9, 0(x6)                                        ; pc=0x009C
    addi x7, x0, 2                                      ; pc=0x00A0
    add x8, x3, x7                                      ; pc=0x00A4
    addi x5, x0, 2                                      ; pc=0x00A8
    add x10, x3, x5                                     ; pc=0x00AC
    add x6, x10, x10                                    ; pc=0x00B0
    add x6, x6, x6                                      ; pc=0x00B4
    addiSigned x9, x17, -1920                           ; pc=0x00B8
    add x9, x9, x6                                      ; pc=0x00BC
    sw x8, 0(x9)                                        ; pc=0x00C0
    addi x7, x0, 3                                      ; pc=0x00C4
    add x5, x3, x7                                      ; pc=0x00C8
    addi x6, x0, 3                                      ; pc=0x00CC
    add x10, x3, x6                                     ; pc=0x00D0
    add x9, x10, x10                                    ; pc=0x00D4
    add x9, x9, x9                                      ; pc=0x00D8
    addiSigned x8, x17, -1920                           ; pc=0x00DC
    add x8, x8, x9                                      ; pc=0x00E0
    sw x5, 0(x8)                                        ; pc=0x00E4
    addi x7, x0, 4                                      ; pc=0x00E8
    add x6, x3, x7                                      ; pc=0x00EC
    addi x9, x0, 4                                      ; pc=0x00F0
    add x10, x3, x9                                     ; pc=0x00F4
    add x8, x10, x10                                    ; pc=0x00F8
    add x8, x8, x8                                      ; pc=0x00FC
    addiSigned x5, x17, -1920                           ; pc=0x0100
    add x5, x5, x8                                      ; pc=0x0104
    sw x6, 0(x5)                                        ; pc=0x0108
    addi x7, x0, 5                                      ; pc=0x010C
    add x9, x3, x7                                      ; pc=0x0110
    addi x8, x0, 5                                      ; pc=0x0114
    add x10, x3, x8                                     ; pc=0x0118
    add x5, x10, x10                                    ; pc=0x011C
    add x5, x5, x5                                      ; pc=0x0120
    addiSigned x6, x17, -1920                           ; pc=0x0124
    add x6, x6, x5                                      ; pc=0x0128
    sw x9, 0(x6)                                        ; pc=0x012C
    addi x7, x0, 6                                      ; pc=0x0130
    add x8, x3, x7                                      ; pc=0x0134
    addi x5, x0, 6                                      ; pc=0x0138
    add x10, x3, x5                                     ; pc=0x013C
    add x6, x10, x10                                    ; pc=0x0140
    add x6, x6, x6                                      ; pc=0x0144
    addiSigned x9, x17, -1920                           ; pc=0x0148
    add x9, x9, x6                                      ; pc=0x014C
    sw x8, 0(x9)                                        ; pc=0x0150
    addi x7, x0, 7                                      ; pc=0x0154
    add x5, x3, x7                                      ; pc=0x0158
    addi x6, x0, 7                                      ; pc=0x015C
    add x10, x3, x6                                     ; pc=0x0160
    add x9, x10, x10                                    ; pc=0x0164
    add x9, x9, x9                                      ; pc=0x0168
    addiSigned x8, x17, -1920                           ; pc=0x016C
    add x8, x8, x9                                      ; pc=0x0170
    sw x5, 0(x8)                                        ; pc=0x0174
    addi x7, x0, 8                                      ; pc=0x0178
    add x6, x3, x7                                      ; pc=0x017C
    add x3, x6, x0 ; promote i                          ; pc=0x0180
    jal x0, -316                                        ; pc=0x0184 ; target=L_while_start_0 ; addr=0x0048
L_while_end_1:
    addi x9, x0, 0                                      ; pc=0x0188
    add x3, x9, x0 ; promote i                          ; pc=0x018C
    addi x10, x0, 0                                     ; pc=0x0190
    add x4, x10, x0 ; promote idx                       ; pc=0x0194
L_while_start_2:
    addi x8, x0, 480                                    ; pc=0x0198
    addi x5, x0, 0                                      ; pc=0x019C
    blt x3, x8, 8                                       ; pc=0x01A0 ; target=.L_ir_4_ir_cmp_true ; addr=0x01A8
    jal x0, 8                                           ; pc=0x01A4 ; target=.L_ir_5_ir_cmp_end ; addr=0x01AC
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x01A8
.L_ir_5_ir_cmp_end:
    sw x5, -1944(x17) ; t2__x5                          ; pc=0x01AC
    lw x5, -1944(x17) ; t2__x5                          ; pc=0x01B0
    beq x5, x0, 120                                     ; pc=0x01B4 ; target=L_while_end_3 ; addr=0x022C
    add x6, x4, x4                                      ; pc=0x01B8
    add x6, x6, x6                                      ; pc=0x01BC
    addiSigned x7, x17, -1920                           ; pc=0x01C0
    add x7, x7, x6                                      ; pc=0x01C4
    lw x9, 0(x7)                                        ; pc=0x01C8
    sw x9, -1948(x17) ; t3__x6                          ; pc=0x01CC
    lw x10, -1932(x17) ; suma                           ; pc=0x01D0
    lw x6, -1948(x17) ; t3__x6                          ; pc=0x01D4
    add x8, x10, x6                                     ; pc=0x01D8
    sw x8, -1932(x17) ; suma                            ; pc=0x01DC
    addi x5, x0, 341                                    ; pc=0x01E0
    add x7, x4, x5                                      ; pc=0x01E4
    add x4, x7, x0 ; promote idx                        ; pc=0x01E8
    addi x9, x0, 480                                    ; pc=0x01EC
    addi x8, x0, 0                                      ; pc=0x01F0
    bge x4, x9, 8                                       ; pc=0x01F4 ; target=.L_ir_6_ir_cmp_true ; addr=0x01FC
    jal x0, 8                                           ; pc=0x01F8 ; target=.L_ir_7_ir_cmp_end ; addr=0x0200
.L_ir_6_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x01FC
.L_ir_7_ir_cmp_end:
    sw x8, -1960(x17) ; t6__x9                          ; pc=0x0200
    lw x9, -1960(x17) ; t6__x9                          ; pc=0x0204
    beq x9, x0, 20                                      ; pc=0x0208 ; target=L_else_4 ; addr=0x021C
    addi x6, x0, 480                                    ; pc=0x020C
    sub x10, x4, x6                                     ; pc=0x0210
    add x4, x10, x0 ; promote idx                       ; pc=0x0214
    jal x0, 4                                           ; pc=0x0218 ; target=L_end_if_5 ; addr=0x021C
L_else_4:
L_end_if_5:
    addi x7, x0, 1                                      ; pc=0x021C
    add x5, x3, x7                                      ; pc=0x0220
    add x3, x5, x0 ; promote i                          ; pc=0x0224
    jal x0, -144                                        ; pc=0x0228 ; target=L_while_start_2 ; addr=0x0198
L_while_end_3:
    lw x8, -1932(x17) ; suma                            ; pc=0x022C
    add x11, x8, x0                                     ; pc=0x0230
    jal x0, 4                                           ; pc=0x0234 ; target=.L_ir_1_main_end ; addr=0x0238
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0238
    addi x2, x2, 1976                                   ; pc=0x023C
    freeze                                              ; pc=0x0240