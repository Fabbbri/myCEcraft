; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   .L_ir_2_ir_cmp_true = 0x01BC
;   .L_ir_3_ir_cmp_end = 0x01C0
;   .L_ir_4_ir_cmp_true = 0x0220
;   .L_ir_5_ir_cmp_end = 0x0224
;   L_else_6 = 0x0240
;   L_end_if_7 = 0x0240
;   L_else_4 = 0x0244
;   L_end_if_5 = 0x0244
;   .L_ir_1_main_end = 0x0250
;   tea_encrypt = 0x025C
;   L_for_start_0 = 0x02CC
;   .L_ir_7_ir_cmp_true = 0x02E0
;   .L_ir_8_ir_cmp_end = 0x02E4
;   L_for_end_1 = 0x04BC
;   .L_ir_6_tea_encrypt_end = 0x04F4
;   tea_decrypt = 0x0504
;   L_for_start_2 = 0x057C
;   .L_ir_10_ir_cmp_true = 0x0590
;   .L_ir_11_ir_cmp_end = 0x0594
;   L_for_end_3 = 0x076C
;   .L_ir_9_tea_decrypt_end = 0x07A4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x00C8 jal -> tea_encrypt (addr=0x025C, offset=404)
;   pc=0x0164 jal -> tea_decrypt (addr=0x0504, offset=928)
;   pc=0x01B4 beq -> .L_ir_2_ir_cmp_true (addr=0x01BC, offset=8)
;   pc=0x01B8 jal -> .L_ir_3_ir_cmp_end (addr=0x01C0, offset=8)
;   pc=0x01C8 beq -> L_else_4 (addr=0x0244, offset=124)
;   pc=0x0218 beq -> .L_ir_4_ir_cmp_true (addr=0x0220, offset=8)
;   pc=0x021C jal -> .L_ir_5_ir_cmp_end (addr=0x0224, offset=8)
;   pc=0x022C beq -> L_else_6 (addr=0x0240, offset=20)
;   pc=0x0238 jal -> .L_ir_1_main_end (addr=0x0250, offset=24)
;   pc=0x023C jal -> L_end_if_7 (addr=0x0240, offset=4)
;   pc=0x0240 jal -> L_end_if_5 (addr=0x0244, offset=4)
;   pc=0x024C jal -> .L_ir_1_main_end (addr=0x0250, offset=4)
;   pc=0x02D8 blt -> .L_ir_7_ir_cmp_true (addr=0x02E0, offset=8)
;   pc=0x02DC jal -> .L_ir_8_ir_cmp_end (addr=0x02E4, offset=8)
;   pc=0x02EC beq -> L_for_end_1 (addr=0x04BC, offset=464)
;   pc=0x04B8 jal -> L_for_start_0 (addr=0x02CC, offset=-492)
;   pc=0x0588 blt -> .L_ir_10_ir_cmp_true (addr=0x0590, offset=8)
;   pc=0x058C jal -> .L_ir_11_ir_cmp_end (addr=0x0594, offset=8)
;   pc=0x059C beq -> L_for_end_3 (addr=0x076C, offset=464)
;   pc=0x0768 jal -> L_for_start_2 (addr=0x057C, offset=-492)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
key: ; addr=0x8000
    .word 0
    .word 1
    .word 2
    .word 3
plain: ; addr=0x8010
    .word 0
    .word 0
cipher: ; addr=0x8018
    .word 0
    .word 0
roundtrip: ; addr=0x8020
    .word 0
    .word 0
DELTA: ; addr=0x8028
    .word 0x9E3779B9
SUM_INIT: ; addr=0x802C
    .word 0xC6EF3720

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
    addiSigned x2, x2, -56                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 56                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    add x4, x3, x3                                      ; pc=0x0034
    add x4, x4, x4                                      ; pc=0x0038
    addiHIGH x5, x0, 0                                  ; pc=0x003C
    addi x5, x5, 32784                                  ; pc=0x0040
    add x5, x5, x4                                      ; pc=0x0044
    lw x6, 0(x5)                                        ; pc=0x0048
    sw x6, -4(x17) ; t42                                ; pc=0x004C
    lw x7, -4(x17) ; t42                                ; pc=0x0050
    addi x8, x0, 0                                      ; pc=0x0054
    add x9, x8, x8                                      ; pc=0x0058
    add x9, x9, x9                                      ; pc=0x005C
    addiHIGH x10, x0, 0                                 ; pc=0x0060
    addi x10, x10, 32792                                ; pc=0x0064
    add x10, x10, x9                                    ; pc=0x0068
    sw x7, 0(x10)                                       ; pc=0x006C
    addi x4, x0, 1                                      ; pc=0x0070
    add x3, x4, x4                                      ; pc=0x0074
    add x3, x3, x3                                      ; pc=0x0078
    addiHIGH x5, x0, 0                                  ; pc=0x007C
    addi x5, x5, 32784                                  ; pc=0x0080
    add x5, x5, x3                                      ; pc=0x0084
    lw x6, 0(x5)                                        ; pc=0x0088
    sw x6, -8(x17) ; t43                                ; pc=0x008C
    lw x9, -8(x17) ; t43                                ; pc=0x0090
    addi x8, x0, 1                                      ; pc=0x0094
    add x10, x8, x8                                     ; pc=0x0098
    add x10, x10, x10                                   ; pc=0x009C
    addiHIGH x7, x0, 0                                  ; pc=0x00A0
    addi x7, x7, 32792                                  ; pc=0x00A4
    add x7, x7, x10                                     ; pc=0x00A8
    sw x9, 0(x7)                                        ; pc=0x00AC
    addiHIGH x3, x0, 0                                  ; pc=0x00B0
    addi x3, x3, 32792                                  ; pc=0x00B4
    add x11, x3, x0                                     ; pc=0x00B8
    addiHIGH x4, x0, 0                                  ; pc=0x00BC
    addi x4, x4, 32768                                  ; pc=0x00C0
    add x12, x4, x0                                     ; pc=0x00C4
    jal x1, 404                                         ; pc=0x00C8 ; target=tea_encrypt ; addr=0x025C
    addi x5, x0, 0                                      ; pc=0x00CC
    add x6, x5, x5                                      ; pc=0x00D0
    add x6, x6, x6                                      ; pc=0x00D4
    addiHIGH x10, x0, 0                                 ; pc=0x00D8
    addi x10, x10, 32792                                ; pc=0x00DC
    add x10, x10, x6                                    ; pc=0x00E0
    lw x8, 0(x10)                                       ; pc=0x00E4
    sw x8, -16(x17) ; t45                               ; pc=0x00E8
    lw x7, -16(x17) ; t45                               ; pc=0x00EC
    addi x9, x0, 0                                      ; pc=0x00F0
    add x3, x9, x9                                      ; pc=0x00F4
    add x3, x3, x3                                      ; pc=0x00F8
    addiHIGH x4, x0, 0                                  ; pc=0x00FC
    addi x4, x4, 32800                                  ; pc=0x0100
    add x4, x4, x3                                      ; pc=0x0104
    sw x7, 0(x4)                                        ; pc=0x0108
    addi x6, x0, 1                                      ; pc=0x010C
    add x5, x6, x6                                      ; pc=0x0110
    add x5, x5, x5                                      ; pc=0x0114
    addiHIGH x10, x0, 0                                 ; pc=0x0118
    addi x10, x10, 32792                                ; pc=0x011C
    add x10, x10, x5                                    ; pc=0x0120
    lw x8, 0(x10)                                       ; pc=0x0124
    sw x8, -20(x17) ; t46                               ; pc=0x0128
    lw x3, -20(x17) ; t46                               ; pc=0x012C
    addi x9, x0, 1                                      ; pc=0x0130
    add x4, x9, x9                                      ; pc=0x0134
    add x4, x4, x4                                      ; pc=0x0138
    addiHIGH x7, x0, 0                                  ; pc=0x013C
    addi x7, x7, 32800                                  ; pc=0x0140
    add x7, x7, x4                                      ; pc=0x0144
    sw x3, 0(x7)                                        ; pc=0x0148
    addiHIGH x5, x0, 0                                  ; pc=0x014C
    addi x5, x5, 32800                                  ; pc=0x0150
    add x11, x5, x0                                     ; pc=0x0154
    addiHIGH x6, x0, 0                                  ; pc=0x0158
    addi x6, x6, 32768                                  ; pc=0x015C
    add x12, x6, x0                                     ; pc=0x0160
    jal x1, 928                                         ; pc=0x0164 ; target=tea_decrypt ; addr=0x0504
    addi x10, x0, 0                                     ; pc=0x0168
    add x8, x10, x10                                    ; pc=0x016C
    add x8, x8, x8                                      ; pc=0x0170
    addiHIGH x4, x0, 0                                  ; pc=0x0174
    addi x4, x4, 32800                                  ; pc=0x0178
    add x4, x4, x8                                      ; pc=0x017C
    lw x9, 0(x4)                                        ; pc=0x0180
    sw x9, -28(x17) ; t48                               ; pc=0x0184
    addi x7, x0, 0                                      ; pc=0x0188
    add x3, x7, x7                                      ; pc=0x018C
    add x3, x3, x3                                      ; pc=0x0190
    addiHIGH x5, x0, 0                                  ; pc=0x0194
    addi x5, x5, 32784                                  ; pc=0x0198
    add x5, x5, x3                                      ; pc=0x019C
    lw x6, 0(x5)                                        ; pc=0x01A0
    sw x6, -32(x17) ; t49                               ; pc=0x01A4
    lw x8, -28(x17) ; t48                               ; pc=0x01A8
    lw x10, -32(x17) ; t49                              ; pc=0x01AC
    addi x4, x0, 0                                      ; pc=0x01B0
    beq x8, x10, 8                                      ; pc=0x01B4 ; target=.L_ir_2_ir_cmp_true ; addr=0x01BC
    jal x0, 8                                           ; pc=0x01B8 ; target=.L_ir_3_ir_cmp_end ; addr=0x01C0
.L_ir_2_ir_cmp_true:
    addi x4, x0, 1                                      ; pc=0x01BC
.L_ir_3_ir_cmp_end:
    sw x4, -36(x17) ; t50                               ; pc=0x01C0
    lw x9, -36(x17) ; t50                               ; pc=0x01C4
    beq x9, x0, 124                                     ; pc=0x01C8 ; target=L_else_4 ; addr=0x0244
    addi x3, x0, 1                                      ; pc=0x01CC
    add x7, x3, x3                                      ; pc=0x01D0
    add x7, x7, x7                                      ; pc=0x01D4
    addiHIGH x5, x0, 0                                  ; pc=0x01D8
    addi x5, x5, 32800                                  ; pc=0x01DC
    add x5, x5, x7                                      ; pc=0x01E0
    lw x6, 0(x5)                                        ; pc=0x01E4
    sw x6, -40(x17) ; t51                               ; pc=0x01E8
    addi x4, x0, 1                                      ; pc=0x01EC
    add x10, x4, x4                                     ; pc=0x01F0
    add x10, x10, x10                                   ; pc=0x01F4
    addiHIGH x8, x0, 0                                  ; pc=0x01F8
    addi x8, x8, 32784                                  ; pc=0x01FC
    add x8, x8, x10                                     ; pc=0x0200
    lw x9, 0(x8)                                        ; pc=0x0204
    sw x9, -44(x17) ; t52                               ; pc=0x0208
    lw x7, -40(x17) ; t51                               ; pc=0x020C
    lw x3, -44(x17) ; t52                               ; pc=0x0210
    addi x5, x0, 0                                      ; pc=0x0214
    beq x7, x3, 8                                       ; pc=0x0218 ; target=.L_ir_4_ir_cmp_true ; addr=0x0220
    jal x0, 8                                           ; pc=0x021C ; target=.L_ir_5_ir_cmp_end ; addr=0x0224
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x0220
.L_ir_5_ir_cmp_end:
    sw x5, -48(x17) ; t53                               ; pc=0x0224
    lw x6, -48(x17) ; t53                               ; pc=0x0228
    beq x6, x0, 20                                      ; pc=0x022C ; target=L_else_6 ; addr=0x0240
    addi x10, x0, 0                                     ; pc=0x0230
    add x11, x10, x0                                    ; pc=0x0234
    jal x0, 24                                          ; pc=0x0238 ; target=.L_ir_1_main_end ; addr=0x0250
    jal x0, 4                                           ; pc=0x023C ; target=L_end_if_7 ; addr=0x0240
L_else_6:
L_end_if_7:
    jal x0, 4                                           ; pc=0x0240 ; target=L_end_if_5 ; addr=0x0244
L_else_4:
L_end_if_5:
    addi x4, x0, 1                                      ; pc=0x0244
    add x11, x4, x0                                     ; pc=0x0248
    jal x0, 4                                           ; pc=0x024C ; target=.L_ir_1_main_end ; addr=0x0250
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0250
    addi x2, x2, 56                                     ; pc=0x0254
    freeze                                              ; pc=0x0258

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -140                             ; pc=0x025C
    sw x1, 0(x2)                                        ; pc=0x0260
    sw x17, 4(x2)                                       ; pc=0x0264
    addi x17, x2, 140                                   ; pc=0x0268

    sw x11, -4(x17) ; parametro v                       ; pc=0x026C
    sw x12, -8(x17) ; parametro tea_key                 ; pc=0x0270

    addi x8, x0, 0                                      ; pc=0x0274
    add x9, x8, x8                                      ; pc=0x0278
    add x9, x9, x9                                      ; pc=0x027C
    lw x5, -4(x17) ; base ref v                         ; pc=0x0280
    add x5, x5, x9                                      ; pc=0x0284
    lw x3, 0(x5)                                        ; pc=0x0288
    sw x3, -52(x17) ; t0                                ; pc=0x028C
    lw x7, -52(x17) ; t0                                ; pc=0x0290
    sw x7, -12(x17) ; v0                                ; pc=0x0294
    addi x6, x0, 1                                      ; pc=0x0298
    add x10, x6, x6                                     ; pc=0x029C
    add x10, x10, x10                                   ; pc=0x02A0
    lw x4, -4(x17) ; base ref v                         ; pc=0x02A4
    add x4, x4, x10                                     ; pc=0x02A8
    lw x9, 0(x4)                                        ; pc=0x02AC
    sw x9, -56(x17) ; t1                                ; pc=0x02B0
    lw x8, -56(x17) ; t1                                ; pc=0x02B4
    sw x8, -16(x17) ; v1                                ; pc=0x02B8
    addi x5, x0, 0                                      ; pc=0x02BC
    sw x5, -20(x17) ; sum                               ; pc=0x02C0
    addi x3, x0, 0                                      ; pc=0x02C4
    sw x3, -24(x17) ; i                                 ; pc=0x02C8
L_for_start_0:
    lw x7, -24(x17) ; i                                 ; pc=0x02CC
    addi x10, x0, 32                                    ; pc=0x02D0
    addi x6, x0, 0                                      ; pc=0x02D4
    blt x7, x10, 8                                      ; pc=0x02D8 ; target=.L_ir_7_ir_cmp_true ; addr=0x02E0
    jal x0, 8                                           ; pc=0x02DC ; target=.L_ir_8_ir_cmp_end ; addr=0x02E4
.L_ir_7_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x02E0
.L_ir_8_ir_cmp_end:
    sw x6, -60(x17) ; t2                                ; pc=0x02E4
    lw x4, -60(x17) ; t2                                ; pc=0x02E8
    beq x4, x0, 464                                     ; pc=0x02EC ; target=L_for_end_1 ; addr=0x04BC
    lw x9, -20(x17) ; sum                               ; pc=0x02F0
    addiHIGH x5, x0, 0                                  ; pc=0x02F4
    addi x5, x5, 32808                                  ; pc=0x02F8
    lw x8, 0(x5) ; DELTA                                ; pc=0x02FC
    add x3, x9, x8                                      ; pc=0x0300
    sw x3, -64(x17) ; t3                                ; pc=0x0304
    lw x6, -64(x17) ; t3                                ; pc=0x0308
    sw x6, -20(x17) ; sum                               ; pc=0x030C
    addi x10, x0, 0                                     ; pc=0x0310
    add x7, x10, x10                                    ; pc=0x0314
    add x7, x7, x7                                      ; pc=0x0318
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x031C
    add x4, x4, x7                                      ; pc=0x0320
    lw x5, 0(x4)                                        ; pc=0x0324
    sw x5, -68(x17) ; t4                                ; pc=0x0328
    lw x3, -16(x17) ; v1                                ; pc=0x032C
    lw x8, -68(x17) ; t4                                ; pc=0x0330
    addi x6, x0, 4                                      ; pc=0x0334
    sll x9, x3, x6                                      ; pc=0x0338
    add x9, x9, x8                                      ; pc=0x033C
    sw x9, -72(x17) ; t5                                ; pc=0x0340
    lw x7, -72(x17) ; t5                                ; pc=0x0344
    sw x7, -28(x17) ; left0                             ; pc=0x0348
    lw x10, -16(x17) ; v1                               ; pc=0x034C
    lw x4, -20(x17) ; sum                               ; pc=0x0350
    add x5, x10, x4                                     ; pc=0x0354
    sw x5, -76(x17) ; t6                                ; pc=0x0358
    lw x6, -76(x17) ; t6                                ; pc=0x035C
    sw x6, -32(x17) ; mid0                              ; pc=0x0360
    addi x9, x0, 1                                      ; pc=0x0364
    add x8, x9, x9                                      ; pc=0x0368
    add x8, x8, x8                                      ; pc=0x036C
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x0370
    add x3, x3, x8                                      ; pc=0x0374
    lw x7, 0(x3)                                        ; pc=0x0378
    sw x7, -80(x17) ; t7                                ; pc=0x037C
    lw x5, -16(x17) ; v1                                ; pc=0x0380
    lw x4, -80(x17) ; t7                                ; pc=0x0384
    addi x6, x0, 5                                      ; pc=0x0388
    srl x10, x5, x6                                     ; pc=0x038C
    add x10, x10, x4                                    ; pc=0x0390
    sw x10, -84(x17) ; t8                               ; pc=0x0394
    lw x8, -84(x17) ; t8                                ; pc=0x0398
    sw x8, -36(x17) ; right0                            ; pc=0x039C
    lw x9, -28(x17) ; left0                             ; pc=0x03A0
    lw x3, -32(x17) ; mid0                              ; pc=0x03A4
    xor x7, x9, x3                                      ; pc=0x03A8
    sw x7, -88(x17) ; t9                                ; pc=0x03AC
    lw x6, -88(x17) ; t9                                ; pc=0x03B0
    lw x10, -36(x17) ; right0                           ; pc=0x03B4
    xor x4, x6, x10                                     ; pc=0x03B8
    sw x4, -92(x17) ; t10                               ; pc=0x03BC
    lw x5, -12(x17) ; v0                                ; pc=0x03C0
    lw x8, -92(x17) ; t10                               ; pc=0x03C4
    add x7, x5, x8                                      ; pc=0x03C8
    sw x7, -96(x17) ; t11                               ; pc=0x03CC
    lw x3, -96(x17) ; t11                               ; pc=0x03D0
    sw x3, -12(x17) ; v0                                ; pc=0x03D4
    addi x9, x0, 2                                      ; pc=0x03D8
    add x4, x9, x9                                      ; pc=0x03DC
    add x4, x4, x4                                      ; pc=0x03E0
    lw x10, -8(x17) ; base ref tea_key                  ; pc=0x03E4
    add x10, x10, x4                                    ; pc=0x03E8
    lw x6, 0(x10)                                       ; pc=0x03EC
    sw x6, -100(x17) ; t12                              ; pc=0x03F0
    lw x7, -12(x17) ; v0                                ; pc=0x03F4
    lw x8, -100(x17) ; t12                              ; pc=0x03F8
    addi x3, x0, 4                                      ; pc=0x03FC
    sll x5, x7, x3                                      ; pc=0x0400
    add x5, x5, x8                                      ; pc=0x0404
    sw x5, -104(x17) ; t13                              ; pc=0x0408
    lw x4, -104(x17) ; t13                              ; pc=0x040C
    sw x4, -40(x17) ; left1                             ; pc=0x0410
    lw x9, -12(x17) ; v0                                ; pc=0x0414
    lw x10, -20(x17) ; sum                              ; pc=0x0418
    add x6, x9, x10                                     ; pc=0x041C
    sw x6, -108(x17) ; t14                              ; pc=0x0420
    lw x3, -108(x17) ; t14                              ; pc=0x0424
    sw x3, -44(x17) ; mid1                              ; pc=0x0428
    addi x5, x0, 3                                      ; pc=0x042C
    add x8, x5, x5                                      ; pc=0x0430
    add x8, x8, x8                                      ; pc=0x0434
    lw x7, -8(x17) ; base ref tea_key                   ; pc=0x0438
    add x7, x7, x8                                      ; pc=0x043C
    lw x4, 0(x7)                                        ; pc=0x0440
    sw x4, -112(x17) ; t15                              ; pc=0x0444
    lw x6, -12(x17) ; v0                                ; pc=0x0448
    lw x10, -112(x17) ; t15                             ; pc=0x044C
    addi x3, x0, 5                                      ; pc=0x0450
    srl x9, x6, x3                                      ; pc=0x0454
    add x9, x9, x10                                     ; pc=0x0458
    sw x9, -116(x17) ; t16                              ; pc=0x045C
    lw x8, -116(x17) ; t16                              ; pc=0x0460
    sw x8, -48(x17) ; right1                            ; pc=0x0464
    lw x5, -40(x17) ; left1                             ; pc=0x0468
    lw x7, -44(x17) ; mid1                              ; pc=0x046C
    xor x4, x5, x7                                      ; pc=0x0470
    sw x4, -120(x17) ; t17                              ; pc=0x0474
    lw x3, -120(x17) ; t17                              ; pc=0x0478
    lw x9, -48(x17) ; right1                            ; pc=0x047C
    xor x10, x3, x9                                     ; pc=0x0480
    sw x10, -124(x17) ; t18                             ; pc=0x0484
    lw x6, -16(x17) ; v1                                ; pc=0x0488
    lw x8, -124(x17) ; t18                              ; pc=0x048C
    add x4, x6, x8                                      ; pc=0x0490
    sw x4, -128(x17) ; t19                              ; pc=0x0494
    lw x7, -128(x17) ; t19                              ; pc=0x0498
    sw x7, -16(x17) ; v1                                ; pc=0x049C
    lw x5, -24(x17) ; i                                 ; pc=0x04A0
    addi x10, x0, 1                                     ; pc=0x04A4
    add x9, x5, x10                                     ; pc=0x04A8
    sw x9, -132(x17) ; t20                              ; pc=0x04AC
    lw x3, -132(x17) ; t20                              ; pc=0x04B0
    sw x3, -24(x17) ; i                                 ; pc=0x04B4
    jal x0, -492                                        ; pc=0x04B8 ; target=L_for_start_0 ; addr=0x02CC
L_for_end_1:
    lw x4, -12(x17) ; v0                                ; pc=0x04BC
    addi x8, x0, 0                                      ; pc=0x04C0
    add x6, x8, x8                                      ; pc=0x04C4
    add x6, x6, x6                                      ; pc=0x04C8
    lw x7, -4(x17) ; base ref v                         ; pc=0x04CC
    add x7, x7, x6                                      ; pc=0x04D0
    sw x4, 0(x7)                                        ; pc=0x04D4
    lw x9, -16(x17) ; v1                                ; pc=0x04D8
    addi x10, x0, 1                                     ; pc=0x04DC
    add x5, x10, x10                                    ; pc=0x04E0
    add x5, x5, x5                                      ; pc=0x04E4
    lw x3, -4(x17) ; base ref v                         ; pc=0x04E8
    add x3, x3, x5                                      ; pc=0x04EC
    sw x9, 0(x3)                                        ; pc=0x04F0
.L_ir_6_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x04F4
    lw x17, 4(x2)                                       ; pc=0x04F8
    addi x2, x2, 140                                    ; pc=0x04FC
    jalr x1, 0                                          ; pc=0x0500

tea_decrypt:
    ; prologue
    addiSigned x2, x2, -140                             ; pc=0x0504
    sw x1, 0(x2)                                        ; pc=0x0508
    sw x17, 4(x2)                                       ; pc=0x050C
    addi x17, x2, 140                                   ; pc=0x0510

    sw x11, -4(x17) ; parametro v                       ; pc=0x0514
    sw x12, -8(x17) ; parametro tea_key                 ; pc=0x0518

    addi x6, x0, 0                                      ; pc=0x051C
    add x8, x6, x6                                      ; pc=0x0520
    add x8, x8, x8                                      ; pc=0x0524
    lw x7, -4(x17) ; base ref v                         ; pc=0x0528
    add x7, x7, x8                                      ; pc=0x052C
    lw x4, 0(x7)                                        ; pc=0x0530
    sw x4, -52(x17) ; t21                               ; pc=0x0534
    lw x5, -52(x17) ; t21                               ; pc=0x0538
    sw x5, -12(x17) ; v0                                ; pc=0x053C
    addi x10, x0, 1                                     ; pc=0x0540
    add x3, x10, x10                                    ; pc=0x0544
    add x3, x3, x3                                      ; pc=0x0548
    lw x9, -4(x17) ; base ref v                         ; pc=0x054C
    add x9, x9, x3                                      ; pc=0x0550
    lw x8, 0(x9)                                        ; pc=0x0554
    sw x8, -56(x17) ; t22                               ; pc=0x0558
    lw x6, -56(x17) ; t22                               ; pc=0x055C
    sw x6, -16(x17) ; v1                                ; pc=0x0560
    addiHIGH x4, x0, 0                                  ; pc=0x0564
    addi x4, x4, 32812                                  ; pc=0x0568
    lw x7, 0(x4) ; SUM_INIT                             ; pc=0x056C
    sw x7, -20(x17) ; sum                               ; pc=0x0570
    addi x5, x0, 0                                      ; pc=0x0574
    sw x5, -24(x17) ; i                                 ; pc=0x0578
L_for_start_2:
    lw x3, -24(x17) ; i                                 ; pc=0x057C
    addi x10, x0, 32                                    ; pc=0x0580
    addi x9, x0, 0                                      ; pc=0x0584
    blt x3, x10, 8                                      ; pc=0x0588 ; target=.L_ir_10_ir_cmp_true ; addr=0x0590
    jal x0, 8                                           ; pc=0x058C ; target=.L_ir_11_ir_cmp_end ; addr=0x0594
.L_ir_10_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x0590
.L_ir_11_ir_cmp_end:
    sw x9, -60(x17) ; t23                               ; pc=0x0594
    lw x8, -60(x17) ; t23                               ; pc=0x0598
    beq x8, x0, 464                                     ; pc=0x059C ; target=L_for_end_3 ; addr=0x076C
    addi x6, x0, 2                                      ; pc=0x05A0
    add x4, x6, x6                                      ; pc=0x05A4
    add x4, x4, x4                                      ; pc=0x05A8
    lw x7, -8(x17) ; base ref tea_key                   ; pc=0x05AC
    add x7, x7, x4                                      ; pc=0x05B0
    lw x5, 0(x7)                                        ; pc=0x05B4
    sw x5, -64(x17) ; t24                               ; pc=0x05B8
    lw x9, -12(x17) ; v0                                ; pc=0x05BC
    lw x10, -64(x17) ; t24                              ; pc=0x05C0
    addi x8, x0, 4                                      ; pc=0x05C4
    sll x3, x9, x8                                      ; pc=0x05C8
    add x3, x3, x10                                     ; pc=0x05CC
    sw x3, -68(x17) ; t25                               ; pc=0x05D0
    lw x4, -68(x17) ; t25                               ; pc=0x05D4
    sw x4, -28(x17) ; left1                             ; pc=0x05D8
    lw x6, -12(x17) ; v0                                ; pc=0x05DC
    lw x7, -20(x17) ; sum                               ; pc=0x05E0
    add x5, x6, x7                                      ; pc=0x05E4
    sw x5, -72(x17) ; t26                               ; pc=0x05E8
    lw x8, -72(x17) ; t26                               ; pc=0x05EC
    sw x8, -32(x17) ; mid1                              ; pc=0x05F0
    addi x3, x0, 3                                      ; pc=0x05F4
    add x10, x3, x3                                     ; pc=0x05F8
    add x10, x10, x10                                   ; pc=0x05FC
    lw x9, -8(x17) ; base ref tea_key                   ; pc=0x0600
    add x9, x9, x10                                     ; pc=0x0604
    lw x4, 0(x9)                                        ; pc=0x0608
    sw x4, -76(x17) ; t27                               ; pc=0x060C
    lw x5, -12(x17) ; v0                                ; pc=0x0610
    lw x7, -76(x17) ; t27                               ; pc=0x0614
    addi x8, x0, 5                                      ; pc=0x0618
    srl x6, x5, x8                                      ; pc=0x061C
    add x6, x6, x7                                      ; pc=0x0620
    sw x6, -80(x17) ; t28                               ; pc=0x0624
    lw x10, -80(x17) ; t28                              ; pc=0x0628
    sw x10, -36(x17) ; right1                           ; pc=0x062C
    lw x3, -28(x17) ; left1                             ; pc=0x0630
    lw x9, -32(x17) ; mid1                              ; pc=0x0634
    xor x4, x3, x9                                      ; pc=0x0638
    sw x4, -84(x17) ; t29                               ; pc=0x063C
    lw x8, -84(x17) ; t29                               ; pc=0x0640
    lw x6, -36(x17) ; right1                            ; pc=0x0644
    xor x7, x8, x6                                      ; pc=0x0648
    sw x7, -88(x17) ; t30                               ; pc=0x064C
    lw x5, -16(x17) ; v1                                ; pc=0x0650
    lw x10, -88(x17) ; t30                              ; pc=0x0654
    sub x4, x5, x10                                     ; pc=0x0658
    sw x4, -92(x17) ; t31                               ; pc=0x065C
    lw x9, -92(x17) ; t31                               ; pc=0x0660
    sw x9, -16(x17) ; v1                                ; pc=0x0664
    addi x3, x0, 0                                      ; pc=0x0668
    add x7, x3, x3                                      ; pc=0x066C
    add x7, x7, x7                                      ; pc=0x0670
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x0674
    add x6, x6, x7                                      ; pc=0x0678
    lw x8, 0(x6)                                        ; pc=0x067C
    sw x8, -96(x17) ; t32                               ; pc=0x0680
    lw x4, -16(x17) ; v1                                ; pc=0x0684
    lw x10, -96(x17) ; t32                              ; pc=0x0688
    addi x9, x0, 4                                      ; pc=0x068C
    sll x5, x4, x9                                      ; pc=0x0690
    add x5, x5, x10                                     ; pc=0x0694
    sw x5, -100(x17) ; t33                              ; pc=0x0698
    lw x7, -100(x17) ; t33                              ; pc=0x069C
    sw x7, -40(x17) ; left0                             ; pc=0x06A0
    lw x3, -16(x17) ; v1                                ; pc=0x06A4
    lw x6, -20(x17) ; sum                               ; pc=0x06A8
    add x8, x3, x6                                      ; pc=0x06AC
    sw x8, -104(x17) ; t34                              ; pc=0x06B0
    lw x9, -104(x17) ; t34                              ; pc=0x06B4
    sw x9, -44(x17) ; mid0                              ; pc=0x06B8
    addi x5, x0, 1                                      ; pc=0x06BC
    add x10, x5, x5                                     ; pc=0x06C0
    add x10, x10, x10                                   ; pc=0x06C4
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x06C8
    add x4, x4, x10                                     ; pc=0x06CC
    lw x7, 0(x4)                                        ; pc=0x06D0
    sw x7, -108(x17) ; t35                              ; pc=0x06D4
    lw x8, -16(x17) ; v1                                ; pc=0x06D8
    lw x6, -108(x17) ; t35                              ; pc=0x06DC
    addi x9, x0, 5                                      ; pc=0x06E0
    srl x3, x8, x9                                      ; pc=0x06E4
    add x3, x3, x6                                      ; pc=0x06E8
    sw x3, -112(x17) ; t36                              ; pc=0x06EC
    lw x10, -112(x17) ; t36                             ; pc=0x06F0
    sw x10, -48(x17) ; right0                           ; pc=0x06F4
    lw x5, -40(x17) ; left0                             ; pc=0x06F8
    lw x4, -44(x17) ; mid0                              ; pc=0x06FC
    xor x7, x5, x4                                      ; pc=0x0700
    sw x7, -116(x17) ; t37                              ; pc=0x0704
    lw x9, -116(x17) ; t37                              ; pc=0x0708
    lw x3, -48(x17) ; right0                            ; pc=0x070C
    xor x6, x9, x3                                      ; pc=0x0710
    sw x6, -120(x17) ; t38                              ; pc=0x0714
    lw x8, -12(x17) ; v0                                ; pc=0x0718
    lw x10, -120(x17) ; t38                             ; pc=0x071C
    sub x7, x8, x10                                     ; pc=0x0720
    sw x7, -124(x17) ; t39                              ; pc=0x0724
    lw x4, -124(x17) ; t39                              ; pc=0x0728
    sw x4, -12(x17) ; v0                                ; pc=0x072C
    lw x5, -20(x17) ; sum                               ; pc=0x0730
    addiHIGH x3, x0, 0                                  ; pc=0x0734
    addi x3, x3, 32808                                  ; pc=0x0738
    lw x6, 0(x3) ; DELTA                                ; pc=0x073C
    sub x9, x5, x6                                      ; pc=0x0740
    sw x9, -128(x17) ; t40                              ; pc=0x0744
    lw x7, -128(x17) ; t40                              ; pc=0x0748
    sw x7, -20(x17) ; sum                               ; pc=0x074C
    lw x10, -24(x17) ; i                                ; pc=0x0750
    addi x8, x0, 1                                      ; pc=0x0754
    add x4, x10, x8                                     ; pc=0x0758
    sw x4, -132(x17) ; t41                              ; pc=0x075C
    lw x3, -132(x17) ; t41                              ; pc=0x0760
    sw x3, -24(x17) ; i                                 ; pc=0x0764
    jal x0, -492                                        ; pc=0x0768 ; target=L_for_start_2 ; addr=0x057C
L_for_end_3:
    lw x9, -12(x17) ; v0                                ; pc=0x076C
    addi x6, x0, 0                                      ; pc=0x0770
    add x5, x6, x6                                      ; pc=0x0774
    add x5, x5, x5                                      ; pc=0x0778
    lw x7, -4(x17) ; base ref v                         ; pc=0x077C
    add x7, x7, x5                                      ; pc=0x0780
    sw x9, 0(x7)                                        ; pc=0x0784
    lw x4, -16(x17) ; v1                                ; pc=0x0788
    addi x8, x0, 1                                      ; pc=0x078C
    add x10, x8, x8                                     ; pc=0x0790
    add x10, x10, x10                                   ; pc=0x0794
    lw x3, -4(x17) ; base ref v                         ; pc=0x0798
    add x3, x3, x10                                     ; pc=0x079C
    sw x4, 0(x3)                                        ; pc=0x07A0
.L_ir_9_tea_decrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x07A4
    lw x17, 4(x2)                                       ; pc=0x07A8
    addi x2, x2, 140                                    ; pc=0x07AC
    jalr x1, 0                                          ; pc=0x07B0