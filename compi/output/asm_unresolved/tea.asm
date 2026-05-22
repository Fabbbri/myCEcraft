; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
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
    portalv x0, x0, .L_codegen_0_enderExit              ; pc=0x0000
    lwv v0, 0(v0)                                       ; pc=0x0004
    sleep ; stall RAW                                   ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0014
.L_codegen_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0018
    addi x2, x2, 0x7FF0                                 ; pc=0x001C

    ; prologue
    addiSigned x2, x2, -8                               ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 8                                     ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    add x4, x3, x3                                      ; pc=0x0034
    add x4, x4, x4                                      ; pc=0x0038
    addiHIGH x5, x0, 0                                  ; pc=0x003C
    addi x5, x5, 32784                                  ; pc=0x0040
    ; base plain
    add x5, x5, x4                                      ; pc=0x0044
    lw x4, 0(x5)                                        ; pc=0x0048
    addi x5, x0, 0                                      ; pc=0x004C
    add x3, x5, x5                                      ; pc=0x0050
    add x3, x3, x3                                      ; pc=0x0054
    addiHIGH x6, x0, 0                                  ; pc=0x0058
    addi x6, x6, 32792                                  ; pc=0x005C
    ; base cipher
    add x6, x6, x3                                      ; pc=0x0060
    sw x4, 0(x6)                                        ; pc=0x0064
    addi x4, x0, 1                                      ; pc=0x0068
    add x6, x4, x4                                      ; pc=0x006C
    add x6, x6, x6                                      ; pc=0x0070
    addiHIGH x3, x0, 0                                  ; pc=0x0074
    addi x3, x3, 32784                                  ; pc=0x0078
    ; base plain
    add x3, x3, x6                                      ; pc=0x007C
    lw x6, 0(x3)                                        ; pc=0x0080
    addi x3, x0, 1                                      ; pc=0x0084
    add x4, x3, x3                                      ; pc=0x0088
    add x4, x4, x4                                      ; pc=0x008C
    addiHIGH x5, x0, 0                                  ; pc=0x0090
    addi x5, x5, 32792                                  ; pc=0x0094
    ; base cipher
    add x5, x5, x4                                      ; pc=0x0098
    sw x6, 0(x5)                                        ; pc=0x009C
    addiHIGH x6, x0, 0                                  ; pc=0x00A0
    addi x6, x6, 32792                                  ; pc=0x00A4
    ; base cipher
    add x11, x6, x0                                     ; pc=0x00A8
    addiHIGH x6, x0, 0                                  ; pc=0x00AC
    addi x6, x6, 32768                                  ; pc=0x00B0
    ; base key
    add x12, x6, x0                                     ; pc=0x00B4
    jal x1, tea_encrypt                                 ; pc=0x00B8
    addi x6, x0, 0                                      ; pc=0x00BC
    add x5, x6, x6                                      ; pc=0x00C0
    add x5, x5, x5                                      ; pc=0x00C4
    addiHIGH x4, x0, 0                                  ; pc=0x00C8
    addi x4, x4, 32792                                  ; pc=0x00CC
    ; base cipher
    add x4, x4, x5                                      ; pc=0x00D0
    lw x5, 0(x4)                                        ; pc=0x00D4
    addi x4, x0, 0                                      ; pc=0x00D8
    add x6, x4, x4                                      ; pc=0x00DC
    add x6, x6, x6                                      ; pc=0x00E0
    addiHIGH x3, x0, 0                                  ; pc=0x00E4
    addi x3, x3, 32800                                  ; pc=0x00E8
    ; base roundtrip
    add x3, x3, x6                                      ; pc=0x00EC
    sw x5, 0(x3)                                        ; pc=0x00F0
    addi x5, x0, 1                                      ; pc=0x00F4
    add x3, x5, x5                                      ; pc=0x00F8
    add x3, x3, x3                                      ; pc=0x00FC
    addiHIGH x6, x0, 0                                  ; pc=0x0100
    addi x6, x6, 32792                                  ; pc=0x0104
    ; base cipher
    add x6, x6, x3                                      ; pc=0x0108
    lw x3, 0(x6)                                        ; pc=0x010C
    addi x6, x0, 1                                      ; pc=0x0110
    add x5, x6, x6                                      ; pc=0x0114
    add x5, x5, x5                                      ; pc=0x0118
    addiHIGH x4, x0, 0                                  ; pc=0x011C
    addi x4, x4, 32800                                  ; pc=0x0120
    ; base roundtrip
    add x4, x4, x5                                      ; pc=0x0124
    sw x3, 0(x4)                                        ; pc=0x0128
    addiHIGH x3, x0, 0                                  ; pc=0x012C
    addi x3, x3, 32800                                  ; pc=0x0130
    ; base roundtrip
    add x11, x3, x0                                     ; pc=0x0134
    addiHIGH x3, x0, 0                                  ; pc=0x0138
    addi x3, x3, 32768                                  ; pc=0x013C
    ; base key
    add x12, x3, x0                                     ; pc=0x0140
    jal x1, tea_decrypt                                 ; pc=0x0144

    ; if
    addi x3, x0, 0                                      ; pc=0x0148
    add x4, x3, x3                                      ; pc=0x014C
    add x4, x4, x4                                      ; pc=0x0150
    addiHIGH x5, x0, 0                                  ; pc=0x0154
    addi x5, x5, 32800                                  ; pc=0x0158
    ; base roundtrip
    add x5, x5, x4                                      ; pc=0x015C
    lw x4, 0(x5)                                        ; pc=0x0160
    addi x5, x0, 0                                      ; pc=0x0164
    add x3, x5, x5                                      ; pc=0x0168
    add x3, x3, x3                                      ; pc=0x016C
    addiHIGH x6, x0, 0                                  ; pc=0x0170
    addi x6, x6, 32784                                  ; pc=0x0174
    ; base plain
    add x6, x6, x3                                      ; pc=0x0178
    lw x3, 0(x6)                                        ; pc=0x017C
    bne x4, x3, .L4_if_else                             ; pc=0x0180

    ; if
    addi x3, x0, 1                                      ; pc=0x0184
    add x4, x3, x3                                      ; pc=0x0188
    add x4, x4, x4                                      ; pc=0x018C
    addiHIGH x6, x0, 0                                  ; pc=0x0190
    addi x6, x6, 32800                                  ; pc=0x0194
    ; base roundtrip
    add x6, x6, x4                                      ; pc=0x0198
    lw x4, 0(x6)                                        ; pc=0x019C
    addi x6, x0, 1                                      ; pc=0x01A0
    add x3, x6, x6                                      ; pc=0x01A4
    add x3, x3, x3                                      ; pc=0x01A8
    addiHIGH x5, x0, 0                                  ; pc=0x01AC
    addi x5, x5, 32784                                  ; pc=0x01B0
    ; base plain
    add x5, x5, x3                                      ; pc=0x01B4
    lw x3, 0(x5)                                        ; pc=0x01B8
    bne x4, x3, .L6_if_else                             ; pc=0x01BC
    addi x3, x0, 0                                      ; pc=0x01C0
    add x11, x3, x0                                     ; pc=0x01C4
    jal x0, .L_codegen_1_main_end                       ; pc=0x01C8
    jal x0, .L7_if_end                                  ; pc=0x01CC
.L6_if_else:
.L7_if_end:

    jal x0, .L5_if_end                                  ; pc=0x01D0
.L4_if_else:
.L5_if_end:

    addi x3, x0, 1                                      ; pc=0x01D4
    add x11, x3, x0                                     ; pc=0x01D8
    jal x0, .L_codegen_1_main_end                       ; pc=0x01DC
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x01E0
    addi x2, x2, 8                                      ; pc=0x01E4
    freeze                                              ; pc=0x01E8

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x01EC
    sw x1, 0(x2)                                        ; pc=0x01F0
    sw x17, 4(x2)                                       ; pc=0x01F4
    addi x17, x2, 60                                    ; pc=0x01F8

    sw x11, -4(x17) ; parámetro v                       ; pc=0x01FC
    sw x12, -8(x17) ; parámetro tea_key                 ; pc=0x0200

    addi x3, x0, 0                                      ; pc=0x0204
    add x4, x3, x3                                      ; pc=0x0208
    add x4, x4, x4                                      ; pc=0x020C
    lw x5, -4(x17) ; base ref v                         ; pc=0x0210
    add x5, x5, x4                                      ; pc=0x0214
    lw x4, 0(x5)                                        ; pc=0x0218
    sw x4, -12(x17) ; v0                                ; pc=0x021C
    addi x4, x0, 1                                      ; pc=0x0220
    add x5, x4, x4                                      ; pc=0x0224
    add x5, x5, x5                                      ; pc=0x0228
    lw x3, -4(x17) ; base ref v                         ; pc=0x022C
    add x3, x3, x5                                      ; pc=0x0230
    lw x5, 0(x3)                                        ; pc=0x0234
    sw x5, -16(x17) ; v1                                ; pc=0x0238
    addi x5, x0, 0                                      ; pc=0x023C
    sw x5, -20(x17) ; sum                               ; pc=0x0240

    ; for
    addi x5, x0, 0                                      ; pc=0x0244
    sw x5, -24(x17) ; i                                 ; pc=0x0248
.L0_for_start:
    lw x5, -24(x17) ; i                                 ; pc=0x024C
    addi x3, x0, 32                                     ; pc=0x0250
    bge x5, x3, .L1_for_end                             ; pc=0x0254
    lw x3, -20(x17) ; sum                               ; pc=0x0258
    addiHIGH x4, x0, 0                                  ; pc=0x025C
    addi x4, x4, 32808                                  ; pc=0x0260
    lw x5, 0(x4) ; DELTA                                ; pc=0x0264
    add x4, x3, x5                                      ; pc=0x0268
    sw x4, -20(x17) ; sum                               ; pc=0x026C
    lw x4, -16(x17) ; v1                                ; pc=0x0270
    addi x5, x0, 0                                      ; pc=0x0274
    add x3, x5, x5                                      ; pc=0x0278
    add x3, x3, x3                                      ; pc=0x027C
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x0280
    add x6, x6, x3                                      ; pc=0x0284
    lw x3, 0(x6)                                        ; pc=0x0288
    addi x5, x0, 4                                      ; pc=0x028C
    sll x6, x4, x5                                      ; pc=0x0290
    add x6, x6, x3                                      ; pc=0x0294
    sw x6, -28(x17) ; left0                             ; pc=0x0298
    lw x6, -16(x17) ; v1                                ; pc=0x029C
    lw x3, -20(x17) ; sum                               ; pc=0x02A0
    add x4, x6, x3                                      ; pc=0x02A4
    sw x4, -32(x17) ; mid0                              ; pc=0x02A8
    lw x4, -16(x17) ; v1                                ; pc=0x02AC
    addi x3, x0, 1                                      ; pc=0x02B0
    add x6, x3, x3                                      ; pc=0x02B4
    add x6, x6, x6                                      ; pc=0x02B8
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x02BC
    add x5, x5, x6                                      ; pc=0x02C0
    lw x6, 0(x5)                                        ; pc=0x02C4
    addi x3, x0, 5                                      ; pc=0x02C8
    srl x5, x4, x3                                      ; pc=0x02CC
    add x5, x5, x6                                      ; pc=0x02D0
    sw x5, -36(x17) ; right0                            ; pc=0x02D4
    lw x5, -12(x17) ; v0                                ; pc=0x02D8
    lw x6, -28(x17) ; left0                             ; pc=0x02DC
    lw x4, -32(x17) ; mid0                              ; pc=0x02E0
    xor x3, x6, x4                                      ; pc=0x02E4
    lw x4, -36(x17) ; right0                            ; pc=0x02E8
    xor x6, x3, x4                                      ; pc=0x02EC
    add x4, x5, x6                                      ; pc=0x02F0
    sw x4, -12(x17) ; v0                                ; pc=0x02F4
    lw x4, -12(x17) ; v0                                ; pc=0x02F8
    addi x6, x0, 2                                      ; pc=0x02FC
    add x5, x6, x6                                      ; pc=0x0300
    add x5, x5, x5                                      ; pc=0x0304
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x0308
    add x3, x3, x5                                      ; pc=0x030C
    lw x5, 0(x3)                                        ; pc=0x0310
    addi x6, x0, 4                                      ; pc=0x0314
    sll x3, x4, x6                                      ; pc=0x0318
    add x3, x3, x5                                      ; pc=0x031C
    sw x3, -40(x17) ; left1                             ; pc=0x0320
    lw x3, -12(x17) ; v0                                ; pc=0x0324
    lw x5, -20(x17) ; sum                               ; pc=0x0328
    add x4, x3, x5                                      ; pc=0x032C
    sw x4, -44(x17) ; mid1                              ; pc=0x0330
    lw x4, -12(x17) ; v0                                ; pc=0x0334
    addi x5, x0, 3                                      ; pc=0x0338
    add x3, x5, x5                                      ; pc=0x033C
    add x3, x3, x3                                      ; pc=0x0340
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x0344
    add x6, x6, x3                                      ; pc=0x0348
    lw x3, 0(x6)                                        ; pc=0x034C
    addi x5, x0, 5                                      ; pc=0x0350
    srl x6, x4, x5                                      ; pc=0x0354
    add x6, x6, x3                                      ; pc=0x0358
    sw x6, -48(x17) ; right1                            ; pc=0x035C
    lw x6, -16(x17) ; v1                                ; pc=0x0360
    lw x3, -40(x17) ; left1                             ; pc=0x0364
    lw x4, -44(x17) ; mid1                              ; pc=0x0368
    xor x5, x3, x4                                      ; pc=0x036C
    lw x4, -48(x17) ; right1                            ; pc=0x0370
    xor x3, x5, x4                                      ; pc=0x0374
    add x4, x6, x3                                      ; pc=0x0378
    sw x4, -16(x17) ; v1                                ; pc=0x037C
    lw x4, -24(x17) ; i                                 ; pc=0x0380
    addi x3, x0, 1                                      ; pc=0x0384
    add x6, x4, x3                                      ; pc=0x0388
    sw x6, -24(x17) ; i                                 ; pc=0x038C
    jal x0, .L0_for_start                               ; pc=0x0390
.L1_for_end:

    lw x6, -12(x17) ; v0                                ; pc=0x0394
    addi x3, x0, 0                                      ; pc=0x0398
    add x4, x3, x3                                      ; pc=0x039C
    add x4, x4, x4                                      ; pc=0x03A0
    lw x5, -4(x17) ; base ref v                         ; pc=0x03A4
    add x5, x5, x4                                      ; pc=0x03A8
    sw x6, 0(x5)                                        ; pc=0x03AC
    lw x6, -16(x17) ; v1                                ; pc=0x03B0
    addi x5, x0, 1                                      ; pc=0x03B4
    add x4, x5, x5                                      ; pc=0x03B8
    add x4, x4, x4                                      ; pc=0x03BC
    lw x3, -4(x17) ; base ref v                         ; pc=0x03C0
    add x3, x3, x4                                      ; pc=0x03C4
    sw x6, 0(x3)                                        ; pc=0x03C8
.L_codegen_2_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x03CC
    lw x17, 4(x2)                                       ; pc=0x03D0
    addi x2, x2, 60                                     ; pc=0x03D4
    jalr x1, 0                                          ; pc=0x03D8

tea_decrypt:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x03DC
    sw x1, 0(x2)                                        ; pc=0x03E0
    sw x17, 4(x2)                                       ; pc=0x03E4
    addi x17, x2, 60                                    ; pc=0x03E8

    sw x11, -4(x17) ; parámetro v                       ; pc=0x03EC
    sw x12, -8(x17) ; parámetro tea_key                 ; pc=0x03F0

    addi x6, x0, 0                                      ; pc=0x03F4
    add x3, x6, x6                                      ; pc=0x03F8
    add x3, x3, x3                                      ; pc=0x03FC
    lw x4, -4(x17) ; base ref v                         ; pc=0x0400
    add x4, x4, x3                                      ; pc=0x0404
    lw x3, 0(x4)                                        ; pc=0x0408
    sw x3, -12(x17) ; v0                                ; pc=0x040C
    addi x3, x0, 1                                      ; pc=0x0410
    add x4, x3, x3                                      ; pc=0x0414
    add x4, x4, x4                                      ; pc=0x0418
    lw x6, -4(x17) ; base ref v                         ; pc=0x041C
    add x6, x6, x4                                      ; pc=0x0420
    lw x4, 0(x6)                                        ; pc=0x0424
    sw x4, -16(x17) ; v1                                ; pc=0x0428
    addiHIGH x6, x0, 0                                  ; pc=0x042C
    addi x6, x6, 32812                                  ; pc=0x0430
    lw x4, 0(x6) ; SUM_INIT                             ; pc=0x0434
    sw x4, -20(x17) ; sum                               ; pc=0x0438

    ; for
    addi x4, x0, 0                                      ; pc=0x043C
    sw x4, -24(x17) ; i                                 ; pc=0x0440
.L2_for_start:
    lw x4, -24(x17) ; i                                 ; pc=0x0444
    addi x6, x0, 32                                     ; pc=0x0448
    bge x4, x6, .L3_for_end                             ; pc=0x044C
    lw x6, -12(x17) ; v0                                ; pc=0x0450
    addi x4, x0, 2                                      ; pc=0x0454
    add x3, x4, x4                                      ; pc=0x0458
    add x3, x3, x3                                      ; pc=0x045C
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x0460
    add x5, x5, x3                                      ; pc=0x0464
    lw x3, 0(x5)                                        ; pc=0x0468
    addi x4, x0, 4                                      ; pc=0x046C
    sll x5, x6, x4                                      ; pc=0x0470
    add x5, x5, x3                                      ; pc=0x0474
    sw x5, -28(x17) ; left1                             ; pc=0x0478
    lw x5, -12(x17) ; v0                                ; pc=0x047C
    lw x3, -20(x17) ; sum                               ; pc=0x0480
    add x6, x5, x3                                      ; pc=0x0484
    sw x6, -32(x17) ; mid1                              ; pc=0x0488
    lw x6, -12(x17) ; v0                                ; pc=0x048C
    addi x3, x0, 3                                      ; pc=0x0490
    add x5, x3, x3                                      ; pc=0x0494
    add x5, x5, x5                                      ; pc=0x0498
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x049C
    add x4, x4, x5                                      ; pc=0x04A0
    lw x5, 0(x4)                                        ; pc=0x04A4
    addi x3, x0, 5                                      ; pc=0x04A8
    srl x4, x6, x3                                      ; pc=0x04AC
    add x4, x4, x5                                      ; pc=0x04B0
    sw x4, -36(x17) ; right1                            ; pc=0x04B4
    lw x4, -16(x17) ; v1                                ; pc=0x04B8
    lw x5, -28(x17) ; left1                             ; pc=0x04BC
    lw x6, -32(x17) ; mid1                              ; pc=0x04C0
    xor x3, x5, x6                                      ; pc=0x04C4
    lw x6, -36(x17) ; right1                            ; pc=0x04C8
    xor x5, x3, x6                                      ; pc=0x04CC
    sub x6, x4, x5                                      ; pc=0x04D0
    sw x6, -16(x17) ; v1                                ; pc=0x04D4
    lw x6, -16(x17) ; v1                                ; pc=0x04D8
    addi x5, x0, 0                                      ; pc=0x04DC
    add x4, x5, x5                                      ; pc=0x04E0
    add x4, x4, x4                                      ; pc=0x04E4
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x04E8
    add x3, x3, x4                                      ; pc=0x04EC
    lw x4, 0(x3)                                        ; pc=0x04F0
    addi x5, x0, 4                                      ; pc=0x04F4
    sll x3, x6, x5                                      ; pc=0x04F8
    add x3, x3, x4                                      ; pc=0x04FC
    sw x3, -40(x17) ; left0                             ; pc=0x0500
    lw x3, -16(x17) ; v1                                ; pc=0x0504
    lw x4, -20(x17) ; sum                               ; pc=0x0508
    add x6, x3, x4                                      ; pc=0x050C
    sw x6, -44(x17) ; mid0                              ; pc=0x0510
    lw x6, -16(x17) ; v1                                ; pc=0x0514
    addi x4, x0, 1                                      ; pc=0x0518
    add x3, x4, x4                                      ; pc=0x051C
    add x3, x3, x3                                      ; pc=0x0520
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x0524
    add x5, x5, x3                                      ; pc=0x0528
    lw x3, 0(x5)                                        ; pc=0x052C
    addi x4, x0, 5                                      ; pc=0x0530
    srl x5, x6, x4                                      ; pc=0x0534
    add x5, x5, x3                                      ; pc=0x0538
    sw x5, -48(x17) ; right0                            ; pc=0x053C
    lw x5, -12(x17) ; v0                                ; pc=0x0540
    lw x3, -40(x17) ; left0                             ; pc=0x0544
    lw x6, -44(x17) ; mid0                              ; pc=0x0548
    xor x4, x3, x6                                      ; pc=0x054C
    lw x6, -48(x17) ; right0                            ; pc=0x0550
    xor x3, x4, x6                                      ; pc=0x0554
    sub x6, x5, x3                                      ; pc=0x0558
    sw x6, -12(x17) ; v0                                ; pc=0x055C
    lw x6, -20(x17) ; sum                               ; pc=0x0560
    addiHIGH x5, x0, 0                                  ; pc=0x0564
    addi x5, x5, 32808                                  ; pc=0x0568
    lw x3, 0(x5) ; DELTA                                ; pc=0x056C
    sub x5, x6, x3                                      ; pc=0x0570
    sw x5, -20(x17) ; sum                               ; pc=0x0574
    lw x5, -24(x17) ; i                                 ; pc=0x0578
    addi x3, x0, 1                                      ; pc=0x057C
    add x6, x5, x3                                      ; pc=0x0580
    sw x6, -24(x17) ; i                                 ; pc=0x0584
    jal x0, .L2_for_start                               ; pc=0x0588
.L3_for_end:

    lw x6, -12(x17) ; v0                                ; pc=0x058C
    addi x3, x0, 0                                      ; pc=0x0590
    add x5, x3, x3                                      ; pc=0x0594
    add x5, x5, x5                                      ; pc=0x0598
    lw x4, -4(x17) ; base ref v                         ; pc=0x059C
    add x4, x4, x5                                      ; pc=0x05A0
    sw x6, 0(x4)                                        ; pc=0x05A4
    lw x6, -16(x17) ; v1                                ; pc=0x05A8
    addi x4, x0, 1                                      ; pc=0x05AC
    add x5, x4, x4                                      ; pc=0x05B0
    add x5, x5, x5                                      ; pc=0x05B4
    lw x3, -4(x17) ; base ref v                         ; pc=0x05B8
    add x3, x3, x5                                      ; pc=0x05BC
    sw x6, 0(x3)                                        ; pc=0x05C0
.L_codegen_3_tea_decrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x05C4
    lw x17, 4(x2)                                       ; pc=0x05C8
    addi x2, x2, 60                                     ; pc=0x05CC
    jalr x1, 0                                          ; pc=0x05D0