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
    addiSigned x2, x2, -56                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 56                                    ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    add x6, x5, x5                                      ; pc=0x0034
    add x6, x6, x6                                      ; pc=0x0038
    addiHIGH x7, x0, 0                                  ; pc=0x003C
    addi x7, x7, 32784                                  ; pc=0x0040
    add x7, x7, x6                                      ; pc=0x0044
    lw x8, 0(x7)                                        ; pc=0x0048
    add x20, x8, x0 ; promote t42                       ; pc=0x004C
    addi x9, x0, 0                                      ; pc=0x0050
    add x10, x9, x9                                     ; pc=0x0054
    add x10, x10, x10                                   ; pc=0x0058
    addiHIGH x6, x0, 0                                  ; pc=0x005C
    addi x6, x6, 32792                                  ; pc=0x0060
    add x6, x6, x10                                     ; pc=0x0064
    sw x20, 0(x6)                                       ; pc=0x0068
    addi x5, x0, 1                                      ; pc=0x006C
    add x7, x5, x5                                      ; pc=0x0070
    add x7, x7, x7                                      ; pc=0x0074
    addiHIGH x8, x0, 0                                  ; pc=0x0078
    addi x8, x8, 32784                                  ; pc=0x007C
    add x8, x8, x7                                      ; pc=0x0080
    lw x10, 0(x8)                                       ; pc=0x0084
    add x21, x10, x0 ; promote t43                      ; pc=0x0088
    addi x9, x0, 1                                      ; pc=0x008C
    add x6, x9, x9                                      ; pc=0x0090
    add x6, x6, x6                                      ; pc=0x0094
    addiHIGH x7, x0, 0                                  ; pc=0x0098
    addi x7, x7, 32792                                  ; pc=0x009C
    add x7, x7, x6                                      ; pc=0x00A0
    sw x21, 0(x7)                                       ; pc=0x00A4
    addiHIGH x5, x0, 0                                  ; pc=0x00A8
    addi x5, x5, 32792                                  ; pc=0x00AC
    add x11, x5, x0                                     ; pc=0x00B0
    addiHIGH x8, x0, 0                                  ; pc=0x00B4
    addi x8, x8, 32768                                  ; pc=0x00B8
    add x12, x8, x0                                     ; pc=0x00BC
    sw x20, -4(x17) ; spill t42                         ; pc=0x00C0
    sw x21, -8(x17) ; spill t43                         ; pc=0x00C4
    jal x1, tea_encrypt                                 ; pc=0x00C8
    addi x10, x0, 0                                     ; pc=0x00CC
    add x6, x10, x10                                    ; pc=0x00D0
    add x6, x6, x6                                      ; pc=0x00D4
    addiHIGH x9, x0, 0                                  ; pc=0x00D8
    addi x9, x9, 32792                                  ; pc=0x00DC
    add x9, x9, x6                                      ; pc=0x00E0
    lw x7, 0(x9)                                        ; pc=0x00E4
    add x22, x7, x0 ; promote t45                       ; pc=0x00E8
    addi x5, x0, 0                                      ; pc=0x00EC
    add x8, x5, x5                                      ; pc=0x00F0
    add x8, x8, x8                                      ; pc=0x00F4
    addiHIGH x6, x0, 0                                  ; pc=0x00F8
    addi x6, x6, 32800                                  ; pc=0x00FC
    add x6, x6, x8                                      ; pc=0x0100
    sw x22, 0(x6)                                       ; pc=0x0104
    addi x10, x0, 1                                     ; pc=0x0108
    add x9, x10, x10                                    ; pc=0x010C
    add x9, x9, x9                                      ; pc=0x0110
    addiHIGH x7, x0, 0                                  ; pc=0x0114
    addi x7, x7, 32792                                  ; pc=0x0118
    add x7, x7, x9                                      ; pc=0x011C
    lw x8, 0(x7)                                        ; pc=0x0120
    add x23, x8, x0 ; promote t46                       ; pc=0x0124
    addi x5, x0, 1                                      ; pc=0x0128
    add x6, x5, x5                                      ; pc=0x012C
    add x6, x6, x6                                      ; pc=0x0130
    addiHIGH x9, x0, 0                                  ; pc=0x0134
    addi x9, x9, 32800                                  ; pc=0x0138
    add x9, x9, x6                                      ; pc=0x013C
    sw x23, 0(x9)                                       ; pc=0x0140
    addiHIGH x10, x0, 0                                 ; pc=0x0144
    addi x10, x10, 32800                                ; pc=0x0148
    add x11, x10, x0                                    ; pc=0x014C
    addiHIGH x7, x0, 0                                  ; pc=0x0150
    addi x7, x7, 32768                                  ; pc=0x0154
    add x12, x7, x0                                     ; pc=0x0158
    sw x22, -16(x17) ; spill t45                        ; pc=0x015C
    sw x23, -20(x17) ; spill t46                        ; pc=0x0160
    jal x1, tea_decrypt                                 ; pc=0x0164
    addi x8, x0, 0                                      ; pc=0x0168
    add x6, x8, x8                                      ; pc=0x016C
    add x6, x6, x6                                      ; pc=0x0170
    addiHIGH x5, x0, 0                                  ; pc=0x0174
    addi x5, x5, 32800                                  ; pc=0x0178
    add x5, x5, x6                                      ; pc=0x017C
    lw x9, 0(x5)                                        ; pc=0x0180
    add x3, x9, x0 ; promote t48                        ; pc=0x0184
    addi x10, x0, 0                                     ; pc=0x0188
    add x7, x10, x10                                    ; pc=0x018C
    add x7, x7, x7                                      ; pc=0x0190
    addiHIGH x6, x0, 0                                  ; pc=0x0194
    addi x6, x6, 32784                                  ; pc=0x0198
    add x6, x6, x7                                      ; pc=0x019C
    lw x8, 0(x6)                                        ; pc=0x01A0
    add x24, x8, x0 ; promote t49                       ; pc=0x01A4
    addi x5, x0, 0                                      ; pc=0x01A8
    beq x3, x24, .L_ir_2_ir_cmp_true                    ; pc=0x01AC
    jal x0, .L_ir_3_ir_cmp_end                          ; pc=0x01B0
.L_ir_2_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x01B4
.L_ir_3_ir_cmp_end:
    add x25, x5, x0 ; promote t50                       ; pc=0x01B8
    beq x25, x0, L_else_4                               ; pc=0x01BC
    addi x9, x0, 1                                      ; pc=0x01C0
    add x7, x9, x9                                      ; pc=0x01C4
    add x7, x7, x7                                      ; pc=0x01C8
    addiHIGH x10, x0, 0                                 ; pc=0x01CC
    addi x10, x10, 32800                                ; pc=0x01D0
    add x10, x10, x7                                    ; pc=0x01D4
    lw x6, 0(x10)                                       ; pc=0x01D8
    add x4, x6, x0 ; promote t51                        ; pc=0x01DC
    addi x8, x0, 1                                      ; pc=0x01E0
    add x5, x8, x8                                      ; pc=0x01E4
    add x5, x5, x5                                      ; pc=0x01E8
    addiHIGH x7, x0, 0                                  ; pc=0x01EC
    addi x7, x7, 32784                                  ; pc=0x01F0
    add x7, x7, x5                                      ; pc=0x01F4
    lw x9, 0(x7)                                        ; pc=0x01F8
    add x26, x9, x0 ; promote t52                       ; pc=0x01FC
    addi x10, x0, 0                                     ; pc=0x0200
    beq x4, x26, .L_ir_4_ir_cmp_true                    ; pc=0x0204
    jal x0, .L_ir_5_ir_cmp_end                          ; pc=0x0208
.L_ir_4_ir_cmp_true:
    addi x10, x0, 1                                     ; pc=0x020C
.L_ir_5_ir_cmp_end:
    add x27, x10, x0 ; promote t53                      ; pc=0x0210
    beq x27, x0, L_else_6                               ; pc=0x0214
    addi x6, x0, 0                                      ; pc=0x0218
    add x11, x6, x0                                     ; pc=0x021C
    jal x0, .L_ir_1_main_end                            ; pc=0x0220
    jal x0, L_end_if_7                                  ; pc=0x0224
L_else_6:
L_end_if_7:
    jal x0, L_end_if_5                                  ; pc=0x0228
L_else_4:
L_end_if_5:
    addi x5, x0, 1                                      ; pc=0x022C
    add x11, x5, x0                                     ; pc=0x0230
    jal x0, .L_ir_1_main_end                            ; pc=0x0234
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0238
    addi x2, x2, 56                                     ; pc=0x023C
    freeze                                              ; pc=0x0240

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -188                             ; pc=0x0244
    sw x1, 0(x2)                                        ; pc=0x0248
    sw x17, 4(x2)                                       ; pc=0x024C
    sw x20, 8(x2) ; save x20                            ; pc=0x0250
    sw x21, 12(x2) ; save x21                           ; pc=0x0254
    sw x22, 16(x2) ; save x22                           ; pc=0x0258
    sw x23, 20(x2) ; save x23                           ; pc=0x025C
    sw x24, 24(x2) ; save x24                           ; pc=0x0260
    sw x25, 28(x2) ; save x25                           ; pc=0x0264
    sw x26, 32(x2) ; save x26                           ; pc=0x0268
    sw x27, 36(x2) ; save x27                           ; pc=0x026C
    sw x28, 40(x2) ; save x28                           ; pc=0x0270
    sw x29, 44(x2) ; save x29                           ; pc=0x0274
    sw x30, 48(x2) ; save x30                           ; pc=0x0278
    sw x31, 52(x2) ; save x31                           ; pc=0x027C
    addi x17, x2, 188                                   ; pc=0x0280

    sw x11, -4(x17) ; parametro v                       ; pc=0x0284
    sw x12, -8(x17) ; parametro tea_key                 ; pc=0x0288

    addi x5, x0, 0                                      ; pc=0x028C
    add x6, x5, x5                                      ; pc=0x0290
    add x6, x6, x6                                      ; pc=0x0294
    lw x7, -4(x17) ; base ref v                         ; pc=0x0298
    add x7, x7, x6                                      ; pc=0x029C
    lw x8, 0(x7)                                        ; pc=0x02A0
    add x28, x8, x0 ; promote t0                        ; pc=0x02A4
    add x3, x28, x0 ; promote v0                        ; pc=0x02A8
    addi x9, x0, 1                                      ; pc=0x02AC
    add x10, x9, x9                                     ; pc=0x02B0
    add x10, x10, x10                                   ; pc=0x02B4
    lw x6, -4(x17) ; base ref v                         ; pc=0x02B8
    add x6, x6, x10                                     ; pc=0x02BC
    lw x5, 0(x6)                                        ; pc=0x02C0
    add x29, x5, x0 ; promote t1                        ; pc=0x02C4
    add x4, x29, x0 ; promote v1                        ; pc=0x02C8
    addi x7, x0, 0                                      ; pc=0x02CC
    add x20, x7, x0 ; promote sum                       ; pc=0x02D0
    addi x8, x0, 0                                      ; pc=0x02D4
    add x21, x8, x0 ; promote i                         ; pc=0x02D8
L_for_start_0:
    addi x10, x0, 32                                    ; pc=0x02DC
    addi x9, x0, 0                                      ; pc=0x02E0
    blt x21, x10, .L_ir_7_ir_cmp_true                   ; pc=0x02E4
    jal x0, .L_ir_8_ir_cmp_end                          ; pc=0x02E8
.L_ir_7_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x02EC
.L_ir_8_ir_cmp_end:
    add x30, x9, x0 ; promote t2                        ; pc=0x02F0
    beq x30, x0, L_for_end_1                            ; pc=0x02F4
    addiHIGH x5, x0, 0                                  ; pc=0x02F8
    addi x5, x5, 32808                                  ; pc=0x02FC
    lw x6, 0(x5) ; DELTA                                ; pc=0x0300
    add x7, x20, x6                                     ; pc=0x0304
    add x20, x7, x0 ; promote sum                       ; pc=0x0308
    addi x8, x0, 0                                      ; pc=0x030C
    add x9, x8, x8                                      ; pc=0x0310
    add x9, x9, x9                                      ; pc=0x0314
    lw x10, -8(x17) ; base ref tea_key                  ; pc=0x0318
    add x10, x10, x9                                    ; pc=0x031C
    lw x5, 0(x10)                                       ; pc=0x0320
    sw x5, -68(x17) ; t4                                ; pc=0x0324
    lw x7, -68(x17) ; t4                                ; pc=0x0328
    addi x9, x0, 4                                      ; pc=0x032C
    sll x6, x4, x9                                      ; pc=0x0330
    add x6, x6, x7                                      ; pc=0x0334
    add x22, x6, x0 ; promote left0                     ; pc=0x0338
    add x8, x4, x20                                     ; pc=0x033C
    add x24, x8, x0 ; promote mid0                      ; pc=0x0340
    addi x10, x0, 1                                     ; pc=0x0344
    add x5, x10, x10                                    ; pc=0x0348
    add x5, x5, x5                                      ; pc=0x034C
    lw x9, -8(x17) ; base ref tea_key                   ; pc=0x0350
    add x9, x9, x5                                      ; pc=0x0354
    lw x6, 0(x9)                                        ; pc=0x0358
    sw x6, -80(x17) ; t7                                ; pc=0x035C
    lw x7, -80(x17) ; t7                                ; pc=0x0360
    addi x5, x0, 5                                      ; pc=0x0364
    srl x8, x4, x5                                      ; pc=0x0368
    add x8, x8, x7                                      ; pc=0x036C
    add x26, x8, x0 ; promote right0                    ; pc=0x0370
    xor x10, x22, x24                                   ; pc=0x0374
    sw x10, -88(x17) ; t9                               ; pc=0x0378
    lw x9, -88(x17) ; t9                                ; pc=0x037C
    xor x6, x9, x26                                     ; pc=0x0380
    sw x6, -92(x17) ; t10                               ; pc=0x0384
    lw x5, -92(x17) ; t10                               ; pc=0x0388
    add x8, x3, x5                                      ; pc=0x038C
    add x3, x8, x0 ; promote v0                         ; pc=0x0390
    addi x7, x0, 2                                      ; pc=0x0394
    add x10, x7, x7                                     ; pc=0x0398
    add x10, x10, x10                                   ; pc=0x039C
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x03A0
    add x6, x6, x10                                     ; pc=0x03A4
    lw x9, 0(x6)                                        ; pc=0x03A8
    sw x9, -100(x17) ; t12                              ; pc=0x03AC
    lw x8, -100(x17) ; t12                              ; pc=0x03B0
    addi x10, x0, 4                                     ; pc=0x03B4
    sll x5, x3, x10                                     ; pc=0x03B8
    add x5, x5, x8                                      ; pc=0x03BC
    add x23, x5, x0 ; promote left1                     ; pc=0x03C0
    add x7, x3, x20                                     ; pc=0x03C4
    add x25, x7, x0 ; promote mid1                      ; pc=0x03C8
    addi x6, x0, 3                                      ; pc=0x03CC
    add x9, x6, x6                                      ; pc=0x03D0
    add x9, x9, x9                                      ; pc=0x03D4
    lw x10, -8(x17) ; base ref tea_key                  ; pc=0x03D8
    add x10, x10, x9                                    ; pc=0x03DC
    lw x5, 0(x10)                                       ; pc=0x03E0
    sw x5, -112(x17) ; t15                              ; pc=0x03E4
    lw x8, -112(x17) ; t15                              ; pc=0x03E8
    addi x9, x0, 5                                      ; pc=0x03EC
    srl x7, x3, x9                                      ; pc=0x03F0
    add x7, x7, x8                                      ; pc=0x03F4
    add x27, x7, x0 ; promote right1                    ; pc=0x03F8
    xor x6, x23, x25                                    ; pc=0x03FC
    sw x6, -120(x17) ; t17                              ; pc=0x0400
    lw x10, -120(x17) ; t17                             ; pc=0x0404
    xor x5, x10, x27                                    ; pc=0x0408
    sw x5, -124(x17) ; t18                              ; pc=0x040C
    lw x9, -124(x17) ; t18                              ; pc=0x0410
    add x7, x4, x9                                      ; pc=0x0414
    add x4, x7, x0 ; promote v1                         ; pc=0x0418
    addi x8, x0, 1                                      ; pc=0x041C
    add x6, x21, x8                                     ; pc=0x0420
    add x21, x6, x0 ; promote i                         ; pc=0x0424
    jal x0, L_for_start_0                               ; pc=0x0428
L_for_end_1:
    addi x5, x0, 0                                      ; pc=0x042C
    add x10, x5, x5                                     ; pc=0x0430
    add x10, x10, x10                                   ; pc=0x0434
    lw x7, -4(x17) ; base ref v                         ; pc=0x0438
    add x7, x7, x10                                     ; pc=0x043C
    sw x3, 0(x7)                                        ; pc=0x0440
    addi x9, x0, 1                                      ; pc=0x0444
    add x6, x9, x9                                      ; pc=0x0448
    add x6, x6, x6                                      ; pc=0x044C
    lw x8, -4(x17) ; base ref v                         ; pc=0x0450
    add x8, x8, x6                                      ; pc=0x0454
    sw x4, 0(x8)                                        ; pc=0x0458
.L_ir_6_tea_encrypt_end:
    ; epilogue
    lw x20, 8(x2) ; restore x20                         ; pc=0x045C
    lw x21, 12(x2) ; restore x21                        ; pc=0x0460
    lw x22, 16(x2) ; restore x22                        ; pc=0x0464
    lw x23, 20(x2) ; restore x23                        ; pc=0x0468
    lw x24, 24(x2) ; restore x24                        ; pc=0x046C
    lw x25, 28(x2) ; restore x25                        ; pc=0x0470
    lw x26, 32(x2) ; restore x26                        ; pc=0x0474
    lw x27, 36(x2) ; restore x27                        ; pc=0x0478
    lw x28, 40(x2) ; restore x28                        ; pc=0x047C
    lw x29, 44(x2) ; restore x29                        ; pc=0x0480
    lw x30, 48(x2) ; restore x30                        ; pc=0x0484
    lw x31, 52(x2) ; restore x31                        ; pc=0x0488
    lw x1, 0(x2)                                        ; pc=0x048C
    lw x17, 4(x2)                                       ; pc=0x0490
    addi x2, x2, 188                                    ; pc=0x0494
    jalr x1, 0                                          ; pc=0x0498

tea_decrypt:
    ; prologue
    addiSigned x2, x2, -188                             ; pc=0x049C
    sw x1, 0(x2)                                        ; pc=0x04A0
    sw x17, 4(x2)                                       ; pc=0x04A4
    sw x20, 8(x2) ; save x20                            ; pc=0x04A8
    sw x21, 12(x2) ; save x21                           ; pc=0x04AC
    sw x22, 16(x2) ; save x22                           ; pc=0x04B0
    sw x23, 20(x2) ; save x23                           ; pc=0x04B4
    sw x24, 24(x2) ; save x24                           ; pc=0x04B8
    sw x25, 28(x2) ; save x25                           ; pc=0x04BC
    sw x26, 32(x2) ; save x26                           ; pc=0x04C0
    sw x27, 36(x2) ; save x27                           ; pc=0x04C4
    sw x28, 40(x2) ; save x28                           ; pc=0x04C8
    sw x29, 44(x2) ; save x29                           ; pc=0x04CC
    sw x30, 48(x2) ; save x30                           ; pc=0x04D0
    sw x31, 52(x2) ; save x31                           ; pc=0x04D4
    addi x17, x2, 188                                   ; pc=0x04D8

    sw x11, -4(x17) ; parametro v                       ; pc=0x04DC
    sw x12, -8(x17) ; parametro tea_key                 ; pc=0x04E0

    addi x5, x0, 0                                      ; pc=0x04E4
    add x6, x5, x5                                      ; pc=0x04E8
    add x6, x6, x6                                      ; pc=0x04EC
    lw x7, -4(x17) ; base ref v                         ; pc=0x04F0
    add x7, x7, x6                                      ; pc=0x04F4
    lw x8, 0(x7)                                        ; pc=0x04F8
    add x28, x8, x0 ; promote t21                       ; pc=0x04FC
    add x3, x28, x0 ; promote v0                        ; pc=0x0500
    addi x9, x0, 1                                      ; pc=0x0504
    add x10, x9, x9                                     ; pc=0x0508
    add x10, x10, x10                                   ; pc=0x050C
    lw x6, -4(x17) ; base ref v                         ; pc=0x0510
    add x6, x6, x10                                     ; pc=0x0514
    lw x5, 0(x6)                                        ; pc=0x0518
    add x29, x5, x0 ; promote t22                       ; pc=0x051C
    add x4, x29, x0 ; promote v1                        ; pc=0x0520
    addiHIGH x8, x0, 0                                  ; pc=0x0524
    addi x8, x8, 32812                                  ; pc=0x0528
    lw x7, 0(x8) ; SUM_INIT                             ; pc=0x052C
    add x20, x7, x0 ; promote sum                       ; pc=0x0530
    addi x10, x0, 0                                     ; pc=0x0534
    add x21, x10, x0 ; promote i                        ; pc=0x0538
L_for_start_2:
    addi x9, x0, 32                                     ; pc=0x053C
    addi x6, x0, 0                                      ; pc=0x0540
    blt x21, x9, .L_ir_10_ir_cmp_true                   ; pc=0x0544
    jal x0, .L_ir_11_ir_cmp_end                         ; pc=0x0548
.L_ir_10_ir_cmp_true:
    addi x6, x0, 1                                      ; pc=0x054C
.L_ir_11_ir_cmp_end:
    add x30, x6, x0 ; promote t23                       ; pc=0x0550
    beq x30, x0, L_for_end_3                            ; pc=0x0554
    addi x5, x0, 2                                      ; pc=0x0558
    add x8, x5, x5                                      ; pc=0x055C
    add x8, x8, x8                                      ; pc=0x0560
    lw x7, -8(x17) ; base ref tea_key                   ; pc=0x0564
    add x7, x7, x8                                      ; pc=0x0568
    lw x10, 0(x7)                                       ; pc=0x056C
    add x31, x10, x0 ; promote t24                      ; pc=0x0570
    addi x9, x0, 4                                      ; pc=0x0574
    sll x6, x3, x9                                      ; pc=0x0578
    add x6, x6, x31                                     ; pc=0x057C
    add x22, x6, x0 ; promote left1                     ; pc=0x0580
    add x8, x3, x20                                     ; pc=0x0584
    add x24, x8, x0 ; promote mid1                      ; pc=0x0588
    addi x5, x0, 3                                      ; pc=0x058C
    add x7, x5, x5                                      ; pc=0x0590
    add x7, x7, x7                                      ; pc=0x0594
    lw x10, -8(x17) ; base ref tea_key                  ; pc=0x0598
    add x10, x10, x7                                    ; pc=0x059C
    lw x9, 0(x10)                                       ; pc=0x05A0
    sw x9, -76(x17) ; t27                               ; pc=0x05A4
    lw x6, -76(x17) ; t27                               ; pc=0x05A8
    addi x7, x0, 5                                      ; pc=0x05AC
    srl x8, x3, x7                                      ; pc=0x05B0
    add x8, x8, x6                                      ; pc=0x05B4
    add x26, x8, x0 ; promote right1                    ; pc=0x05B8
    xor x5, x22, x24                                    ; pc=0x05BC
    sw x5, -84(x17) ; t29                               ; pc=0x05C0
    lw x10, -84(x17) ; t29                              ; pc=0x05C4
    xor x9, x10, x26                                    ; pc=0x05C8
    sw x9, -88(x17) ; t30                               ; pc=0x05CC
    lw x7, -88(x17) ; t30                               ; pc=0x05D0
    sub x8, x4, x7                                      ; pc=0x05D4
    add x4, x8, x0 ; promote v1                         ; pc=0x05D8
    addi x6, x0, 0                                      ; pc=0x05DC
    add x5, x6, x6                                      ; pc=0x05E0
    add x5, x5, x5                                      ; pc=0x05E4
    lw x9, -8(x17) ; base ref tea_key                   ; pc=0x05E8
    add x9, x9, x5                                      ; pc=0x05EC
    lw x10, 0(x9)                                       ; pc=0x05F0
    sw x10, -96(x17) ; t32                              ; pc=0x05F4
    lw x8, -96(x17) ; t32                               ; pc=0x05F8
    addi x5, x0, 4                                      ; pc=0x05FC
    sll x7, x4, x5                                      ; pc=0x0600
    add x7, x7, x8                                      ; pc=0x0604
    add x23, x7, x0 ; promote left0                     ; pc=0x0608
    add x6, x4, x20                                     ; pc=0x060C
    add x25, x6, x0 ; promote mid0                      ; pc=0x0610
    addi x9, x0, 1                                      ; pc=0x0614
    add x10, x9, x9                                     ; pc=0x0618
    add x10, x10, x10                                   ; pc=0x061C
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x0620
    add x5, x5, x10                                     ; pc=0x0624
    lw x7, 0(x5)                                        ; pc=0x0628
    sw x7, -108(x17) ; t35                              ; pc=0x062C
    lw x8, -108(x17) ; t35                              ; pc=0x0630
    addi x10, x0, 5                                     ; pc=0x0634
    srl x6, x4, x10                                     ; pc=0x0638
    add x6, x6, x8                                      ; pc=0x063C
    add x27, x6, x0 ; promote right0                    ; pc=0x0640
    xor x9, x23, x25                                    ; pc=0x0644
    sw x9, -116(x17) ; t37                              ; pc=0x0648
    lw x5, -116(x17) ; t37                              ; pc=0x064C
    xor x7, x5, x27                                     ; pc=0x0650
    sw x7, -120(x17) ; t38                              ; pc=0x0654
    lw x10, -120(x17) ; t38                             ; pc=0x0658
    sub x6, x3, x10                                     ; pc=0x065C
    add x3, x6, x0 ; promote v0                         ; pc=0x0660
    addiHIGH x9, x0, 0                                  ; pc=0x0664
    addi x9, x9, 32808                                  ; pc=0x0668
    lw x8, 0(x9) ; DELTA                                ; pc=0x066C
    sub x7, x20, x8                                     ; pc=0x0670
    add x20, x7, x0 ; promote sum                       ; pc=0x0674
    addi x5, x0, 1                                      ; pc=0x0678
    add x6, x21, x5                                     ; pc=0x067C
    add x21, x6, x0 ; promote i                         ; pc=0x0680
    jal x0, L_for_start_2                               ; pc=0x0684
L_for_end_3:
    addi x10, x0, 0                                     ; pc=0x0688
    add x9, x10, x10                                    ; pc=0x068C
    add x9, x9, x9                                      ; pc=0x0690
    lw x7, -4(x17) ; base ref v                         ; pc=0x0694
    add x7, x7, x9                                      ; pc=0x0698
    sw x3, 0(x7)                                        ; pc=0x069C
    addi x8, x0, 1                                      ; pc=0x06A0
    add x6, x8, x8                                      ; pc=0x06A4
    add x6, x6, x6                                      ; pc=0x06A8
    lw x5, -4(x17) ; base ref v                         ; pc=0x06AC
    add x5, x5, x6                                      ; pc=0x06B0
    sw x4, 0(x5)                                        ; pc=0x06B4
.L_ir_9_tea_decrypt_end:
    ; epilogue
    lw x20, 8(x2) ; restore x20                         ; pc=0x06B8
    lw x21, 12(x2) ; restore x21                        ; pc=0x06BC
    lw x22, 16(x2) ; restore x22                        ; pc=0x06C0
    lw x23, 20(x2) ; restore x23                        ; pc=0x06C4
    lw x24, 24(x2) ; restore x24                        ; pc=0x06C8
    lw x25, 28(x2) ; restore x25                        ; pc=0x06CC
    lw x26, 32(x2) ; restore x26                        ; pc=0x06D0
    lw x27, 36(x2) ; restore x27                        ; pc=0x06D4
    lw x28, 40(x2) ; restore x28                        ; pc=0x06D8
    lw x29, 44(x2) ; restore x29                        ; pc=0x06DC
    lw x30, 48(x2) ; restore x30                        ; pc=0x06E0
    lw x31, 52(x2) ; restore x31                        ; pc=0x06E4
    lw x1, 0(x2)                                        ; pc=0x06E8
    lw x17, 4(x2)                                       ; pc=0x06EC
    addi x2, x2, 188                                    ; pc=0x06F0
    jalr x1, 0                                          ; pc=0x06F4