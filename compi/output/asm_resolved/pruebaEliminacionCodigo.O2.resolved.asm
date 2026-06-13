; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_for_start_0 = 0x0098
;   .L_ir_2_ir_cmp_true = 0x00A8
;   .L_ir_3_ir_cmp_end = 0x00AC
;   L_for_start_2 = 0x00BC
;   .L_ir_4_ir_cmp_true = 0x00CC
;   .L_ir_5_ir_cmp_end = 0x00D0
;   L_for_start_4 = 0x00E8
;   .L_ir_6_ir_cmp_true = 0x00F8
;   .L_ir_7_ir_cmp_end = 0x00FC
;   L_for_end_5 = 0x0194
;   L_for_end_3 = 0x01D4
;   L_for_end_1 = 0x01E4
;   .L_ir_1_main_end = 0x0280

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00A0 blt -> .L_ir_2_ir_cmp_true (addr=0x00A8, offset=8)
;   pc=0x00A4 jal -> .L_ir_3_ir_cmp_end (addr=0x00AC, offset=8)
;   pc=0x00B0 beq -> L_for_end_1 (addr=0x01E4, offset=308)
;   pc=0x00C4 blt -> .L_ir_4_ir_cmp_true (addr=0x00CC, offset=8)
;   pc=0x00C8 jal -> .L_ir_5_ir_cmp_end (addr=0x00D0, offset=8)
;   pc=0x00D4 beq -> L_for_end_3 (addr=0x01D4, offset=256)
;   pc=0x00F0 blt -> .L_ir_6_ir_cmp_true (addr=0x00F8, offset=8)
;   pc=0x00F4 jal -> .L_ir_7_ir_cmp_end (addr=0x00FC, offset=8)
;   pc=0x0100 beq -> L_for_end_5 (addr=0x0194, offset=148)
;   pc=0x0190 jal -> L_for_start_4 (addr=0x00E8, offset=-168)
;   pc=0x01D0 jal -> L_for_start_2 (addr=0x00BC, offset=-276)
;   pc=0x01E0 jal -> L_for_start_0 (addr=0x0098, offset=-328)
;   pc=0x027C jal -> .L_ir_1_main_end (addr=0x0280, offset=4)

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
    addiSigned x2, x2, -192                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 192                                   ; pc=0x002C

    addi x5, x0, 1                                      ; pc=0x0030
    sw x5, -16(x17) ; A[0]                              ; pc=0x0034
    addi x6, x0, 2                                      ; pc=0x0038
    sw x6, -12(x17) ; A[1]                              ; pc=0x003C
    addi x7, x0, 3                                      ; pc=0x0040
    sw x7, -8(x17) ; A[2]                               ; pc=0x0044
    addi x8, x0, 4                                      ; pc=0x0048
    sw x8, -4(x17) ; A[3]                               ; pc=0x004C
    addi x9, x0, 5                                      ; pc=0x0050
    sw x9, -32(x17) ; B[0]                              ; pc=0x0054
    addi x10, x0, 6                                     ; pc=0x0058
    sw x10, -28(x17) ; B[1]                             ; pc=0x005C
    addi x5, x0, 7                                      ; pc=0x0060
    sw x5, -24(x17) ; B[2]                              ; pc=0x0064
    addi x6, x0, 8                                      ; pc=0x0068
    sw x6, -20(x17) ; B[3]                              ; pc=0x006C
    addi x7, x0, 0                                      ; pc=0x0070
    sw x7, -48(x17) ; C[0]                              ; pc=0x0074
    addi x8, x0, 0                                      ; pc=0x0078
    sw x8, -44(x17) ; C[1]                              ; pc=0x007C
    addi x9, x0, 0                                      ; pc=0x0080
    sw x9, -40(x17) ; C[2]                              ; pc=0x0084
    addi x10, x0, 0                                     ; pc=0x0088
    sw x10, -36(x17) ; C[3]                             ; pc=0x008C
    addi x5, x0, 0                                      ; pc=0x0090
    add x3, x5, x0 ; promote i                          ; pc=0x0094
L_for_start_0:
    addi x6, x0, 2                                      ; pc=0x0098
    addi x7, x0, 0                                      ; pc=0x009C
    blt x3, x6, 8                                       ; pc=0x00A0 ; target=.L_ir_2_ir_cmp_true ; addr=0x00A8
    jal x0, 8                                           ; pc=0x00A4 ; target=.L_ir_3_ir_cmp_end ; addr=0x00AC
.L_ir_2_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x00A8
.L_ir_3_ir_cmp_end:
    add x29, x7, x0 ; promote t0                        ; pc=0x00AC
    beq x29, x0, 308                                    ; pc=0x00B0 ; target=L_for_end_1 ; addr=0x01E4
    addi x8, x0, 0                                      ; pc=0x00B4
    add x4, x8, x0 ; promote j                          ; pc=0x00B8
L_for_start_2:
    addi x9, x0, 2                                      ; pc=0x00BC
    addi x10, x0, 0                                     ; pc=0x00C0
    blt x4, x9, 8                                       ; pc=0x00C4 ; target=.L_ir_4_ir_cmp_true ; addr=0x00CC
    jal x0, 8                                           ; pc=0x00C8 ; target=.L_ir_5_ir_cmp_end ; addr=0x00D0
.L_ir_4_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x00CC
.L_ir_5_ir_cmp_end:
    add x30, x10, x0 ; promote t2                       ; pc=0x00D0
    beq x30, x0, 256                                    ; pc=0x00D4 ; target=L_for_end_3 ; addr=0x01D4
    addi x5, x0, 0                                      ; pc=0x00D8
    add x21, x5, x0 ; promote suma                      ; pc=0x00DC
    addi x7, x0, 0                                      ; pc=0x00E0
    add x20, x7, x0 ; promote k                         ; pc=0x00E4
L_for_start_4:
    addi x6, x0, 2                                      ; pc=0x00E8
    addi x8, x0, 0                                      ; pc=0x00EC
    blt x20, x6, 8                                      ; pc=0x00F0 ; target=.L_ir_6_ir_cmp_true ; addr=0x00F8
    jal x0, 8                                           ; pc=0x00F4 ; target=.L_ir_7_ir_cmp_end ; addr=0x00FC
.L_ir_6_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x00F8
.L_ir_7_ir_cmp_end:
    add x31, x8, x0 ; promote t4                        ; pc=0x00FC
    beq x31, x0, 148                                    ; pc=0x0100 ; target=L_for_end_5 ; addr=0x0194
    addi x10, x0, 2                                     ; pc=0x0104
    mul x9, x3, x10                                     ; pc=0x0108
    sw x9, -108(x17) ; t6                               ; pc=0x010C
    lw x5, -108(x17) ; t6                               ; pc=0x0110
    add x7, x5, x20                                     ; pc=0x0114
    sw x7, -112(x17) ; t7                               ; pc=0x0118
    lw x8, -112(x17) ; t7                               ; pc=0x011C
    add x6, x8, x8                                      ; pc=0x0120
    add x6, x6, x6                                      ; pc=0x0124
    addiSigned x9, x17, -16                             ; pc=0x0128
    add x9, x9, x6                                      ; pc=0x012C
    lw x10, 0(x9)                                       ; pc=0x0130
    add x22, x10, x0 ; promote t8                       ; pc=0x0134
    addi x7, x0, 2                                      ; pc=0x0138
    mul x5, x20, x7                                     ; pc=0x013C
    sw x5, -120(x17) ; t9                               ; pc=0x0140
    lw x6, -120(x17) ; t9                               ; pc=0x0144
    add x8, x6, x4                                      ; pc=0x0148
    sw x8, -124(x17) ; t10                              ; pc=0x014C
    lw x9, -124(x17) ; t10                              ; pc=0x0150
    add x10, x9, x9                                     ; pc=0x0154
    add x10, x10, x10                                   ; pc=0x0158
    addiSigned x5, x17, -32                             ; pc=0x015C
    add x5, x5, x10                                     ; pc=0x0160
    lw x7, 0(x5)                                        ; pc=0x0164
    add x25, x7, x0 ; promote t11                       ; pc=0x0168
    addi x8, x0, 1                                      ; pc=0x016C
    add x6, x20, x8                                     ; pc=0x0170
    add x23, x6, x0 ; promote t15                       ; pc=0x0174
    mul x10, x22, x25                                   ; pc=0x0178
    sw x10, -136(x17) ; t12                             ; pc=0x017C
    lw x9, -136(x17) ; t12                              ; pc=0x0180
    add x5, x21, x9                                     ; pc=0x0184
    add x21, x5, x0 ; promote suma                      ; pc=0x0188
    add x20, x23, x0 ; promote k                        ; pc=0x018C
    jal x0, -168                                        ; pc=0x0190 ; target=L_for_start_4 ; addr=0x00E8
L_for_end_5:
    addi x7, x0, 2                                      ; pc=0x0194
    mul x6, x3, x7                                      ; pc=0x0198
    sw x6, -144(x17) ; t16                              ; pc=0x019C
    lw x8, -144(x17) ; t16                              ; pc=0x01A0
    add x10, x8, x4                                     ; pc=0x01A4
    sw x10, -148(x17) ; t17                             ; pc=0x01A8
    lw x5, -148(x17) ; t17                              ; pc=0x01AC
    add x9, x5, x5                                      ; pc=0x01B0
    add x9, x9, x9                                      ; pc=0x01B4
    addiSigned x6, x17, -48                             ; pc=0x01B8
    add x6, x6, x9                                      ; pc=0x01BC
    sw x21, 0(x6)                                       ; pc=0x01C0
    addi x7, x0, 1                                      ; pc=0x01C4
    add x10, x4, x7                                     ; pc=0x01C8
    add x4, x10, x0 ; promote j                         ; pc=0x01CC
    jal x0, -276                                        ; pc=0x01D0 ; target=L_for_start_2 ; addr=0x00BC
L_for_end_3:
    addi x8, x0, 1                                      ; pc=0x01D4
    add x9, x3, x8                                      ; pc=0x01D8
    add x3, x9, x0 ; promote i                          ; pc=0x01DC
    jal x0, -328                                        ; pc=0x01E0 ; target=L_for_start_0 ; addr=0x0098
L_for_end_1:
    addi x5, x0, 0                                      ; pc=0x01E4
    add x6, x5, x5                                      ; pc=0x01E8
    add x6, x6, x6                                      ; pc=0x01EC
    addiSigned x10, x17, -48                            ; pc=0x01F0
    add x10, x10, x6                                    ; pc=0x01F4
    lw x7, 0(x10)                                       ; pc=0x01F8
    add x24, x7, x0 ; promote t22                       ; pc=0x01FC
    addi x9, x0, 1                                      ; pc=0x0200
    add x8, x9, x9                                      ; pc=0x0204
    add x8, x8, x8                                      ; pc=0x0208
    addiSigned x6, x17, -48                             ; pc=0x020C
    add x6, x6, x8                                      ; pc=0x0210
    lw x5, 0(x6)                                        ; pc=0x0214
    add x26, x5, x0 ; promote t23                       ; pc=0x0218
    addi x10, x0, 2                                     ; pc=0x021C
    add x7, x10, x10                                    ; pc=0x0220
    add x7, x7, x7                                      ; pc=0x0224
    addiSigned x8, x17, -48                             ; pc=0x0228
    add x8, x8, x7                                      ; pc=0x022C
    lw x9, 0(x8)                                        ; pc=0x0230
    add x27, x9, x0 ; promote t25                       ; pc=0x0234
    add x6, x24, x26                                    ; pc=0x0238
    sw x6, -172(x17) ; t24                              ; pc=0x023C
    lw x5, -172(x17) ; t24                              ; pc=0x0240
    add x7, x5, x27                                     ; pc=0x0244
    add x28, x7, x0 ; promote t26                       ; pc=0x0248
    addi x10, x0, 3                                     ; pc=0x024C
    add x8, x10, x10                                    ; pc=0x0250
    add x8, x8, x8                                      ; pc=0x0254
    addiSigned x9, x17, -48                             ; pc=0x0258
    add x9, x9, x8                                      ; pc=0x025C
    lw x6, 0(x9)                                        ; pc=0x0260
    sw x6, -180(x17) ; t27                              ; pc=0x0264
    lw x7, -180(x17) ; t27                              ; pc=0x0268
    add x5, x28, x7                                     ; pc=0x026C
    sw x5, -184(x17) ; t28                              ; pc=0x0270
    lw x8, -184(x17) ; t28                              ; pc=0x0274
    add x11, x8, x0                                     ; pc=0x0278
    jal x0, 4                                           ; pc=0x027C ; target=.L_ir_1_main_end ; addr=0x0280
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0280
    addi x2, x2, 192                                    ; pc=0x0284
    freeze                                              ; pc=0x0288