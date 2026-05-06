; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0020
;   main = 0x0020
;   .L_codegen_1_main_end = 0x0188
;   es_primo = 0x01AC
;   .L0_if_else = 0x0240
;   .L1_if_end = 0x0240
;   .L2_if_else = 0x02C4
;   .L3_if_end = 0x02C4
;   .L4_if_else = 0x0390
;   .L5_if_end = 0x0390
;   .L_codegen_2_es_primo_end = 0x0428
;   sume = 0x0464
;   .L6_for_start = 0x04B8
;   .L8_if_else = 0x062C
;   .L9_if_end = 0x062C
;   .L7_for_end = 0x066C
;   .L_codegen_3_sume_end = 0x0698

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0020, offset=32)
;   pc=0x0150 jal -> sume (addr=0x0464, offset=788)
;   pc=0x017C jal -> .L_codegen_1_main_end (addr=0x0188, offset=12)
;   pc=0x01FC blt -> .L0_if_else (addr=0x0240, offset=68)
;   pc=0x0228 jal -> .L_codegen_2_es_primo_end (addr=0x0428, offset=512)
;   pc=0x0234 jal -> .L1_if_end (addr=0x0240, offset=12)
;   pc=0x0280 bge -> .L2_if_else (addr=0x02C4, offset=68)
;   pc=0x02AC jal -> .L_codegen_2_es_primo_end (addr=0x0428, offset=380)
;   pc=0x02B8 jal -> .L3_if_end (addr=0x02C4, offset=12)
;   pc=0x034C bne -> .L4_if_else (addr=0x0390, offset=68)
;   pc=0x0378 jal -> .L_codegen_2_es_primo_end (addr=0x0428, offset=176)
;   pc=0x0384 jal -> .L5_if_end (addr=0x0390, offset=12)
;   pc=0x03F0 jal -> es_primo (addr=0x01AC, offset=-580)
;   pc=0x041C jal -> .L_codegen_2_es_primo_end (addr=0x0428, offset=12)
;   pc=0x04D8 bge -> .L7_for_end (addr=0x066C, offset=404)
;   pc=0x0574 jal -> es_primo (addr=0x01AC, offset=-968)
;   pc=0x0590 beq -> .L8_if_else (addr=0x062C, offset=156)
;   pc=0x0620 jal -> .L9_if_end (addr=0x062C, offset=12)
;   pc=0x0660 jal -> .L6_for_start (addr=0x04B8, offset=-424)
;   pc=0x068C jal -> .L_codegen_3_sume_end (addr=0x0698, offset=12)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, 32                                  ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x0020
    sleep ; nop despues de control                      ; pc=0x0004
    sleep ; nop despues de control                      ; pc=0x0008
    lwv v0, 0(v0)                                       ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    sleep ; stall RAW                                   ; pc=0x0014
    sleep ; stall RAW                                   ; pc=0x0018
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x001C
.L_codegen_0_enderExit:

main:
    ; inicializar stack pointer
    addiHIGH x2, x0, 0                                  ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sleep ; stall RAW                                   ; pc=0x0028
    sleep ; stall RAW                                   ; pc=0x002C
    addi x2, x2, 0x7FF0                                 ; pc=0x0030
    sleep ; stall RAW                                   ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C

    ; prologue
    addiSigned x2, x2, -88                              ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x1, 0(x2)                                        ; pc=0x0050
    sw x17, 4(x2)                                       ; pc=0x0054
    addi x17, x2, 88                                    ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064

    addi x3, x0, 1                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sw x3, -40(x17) ; lista[0]                          ; pc=0x0078
    addi x3, x0, 2                                      ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    sw x3, -36(x17) ; lista[1]                          ; pc=0x008C
    addi x3, x0, 3                                      ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    sw x3, -32(x17) ; lista[2]                          ; pc=0x00A0
    addi x3, x0, 4                                      ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    sw x3, -28(x17) ; lista[3]                          ; pc=0x00B4
    addi x3, x0, 5                                      ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sw x3, -24(x17) ; lista[4]                          ; pc=0x00C8
    addi x3, x0, 6                                      ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sleep ; stall RAW                                   ; pc=0x00D8
    sw x3, -20(x17) ; lista[5]                          ; pc=0x00DC
    addi x3, x0, 7                                      ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    sw x3, -16(x17) ; lista[6]                          ; pc=0x00F0
    addi x3, x0, 8                                      ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    sw x3, -12(x17) ; lista[7]                          ; pc=0x0104
    addi x3, x0, 9                                      ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    sleep ; stall RAW                                   ; pc=0x0114
    sw x3, -8(x17) ; lista[8]                           ; pc=0x0118
    addi x3, x0, 11                                     ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sw x3, -4(x17) ; lista[9]                           ; pc=0x012C
    addiSigned x3, x17, -40                             ; pc=0x0130
    sleep ; stall RAW                                   ; pc=0x0134
    sleep ; stall RAW                                   ; pc=0x0138
    sleep ; stall RAW                                   ; pc=0x013C
    ; base lista
    add x11, x3, x0                                     ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    sleep ; stall RAW                                   ; pc=0x014C
    jal x1, 788                                         ; pc=0x0150 ; target=sume ; addr=0x0464
    sleep ; nop despues de control                      ; pc=0x0154
    sleep ; nop despues de control                      ; pc=0x0158
    add x3, x11, x0                                     ; pc=0x015C
    sleep ; stall RAW                                   ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    sleep ; stall RAW                                   ; pc=0x0168
    add x11, x3, x0                                     ; pc=0x016C
    sleep ; stall RAW                                   ; pc=0x0170
    sleep ; stall RAW                                   ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    jal x0, 12                                          ; pc=0x017C ; target=.L_codegen_1_main_end ; addr=0x0188
    sleep ; nop despues de control                      ; pc=0x0180
    sleep ; nop despues de control                      ; pc=0x0184
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0188
    sleep ; stall RAW                                   ; pc=0x018C
    sleep ; stall RAW                                   ; pc=0x0190
    sleep ; stall RAW                                   ; pc=0x0194
    addi x2, x2, 88                                     ; pc=0x0198
    sleep ; stall RAW                                   ; pc=0x019C
    sleep ; stall RAW                                   ; pc=0x01A0
    sleep ; stall RAW                                   ; pc=0x01A4
    freeze                                              ; pc=0x01A8

es_primo:
    ; prologue
    addiSigned x2, x2, -28                              ; pc=0x01AC
    sleep ; stall RAW                                   ; pc=0x01B0
    sleep ; stall RAW                                   ; pc=0x01B4
    sleep ; stall RAW                                   ; pc=0x01B8
    sw x1, 0(x2)                                        ; pc=0x01BC
    sw x17, 4(x2)                                       ; pc=0x01C0
    addi x17, x2, 28                                    ; pc=0x01C4
    sleep ; stall RAW                                   ; pc=0x01C8
    sleep ; stall RAW                                   ; pc=0x01CC
    sleep ; stall RAW                                   ; pc=0x01D0

    sw x11, -4(x17) ; parámetro n                       ; pc=0x01D4
    sw x12, -8(x17) ; parámetro divisor                 ; pc=0x01D8


    ; if
    lw x3, -4(x17) ; n                                  ; pc=0x01DC
    sleep ; stall RAW                                   ; pc=0x01E0
    sleep ; stall RAW                                   ; pc=0x01E4
    sleep ; stall RAW                                   ; pc=0x01E8
    addi x4, x0, 1                                      ; pc=0x01EC
    sleep ; stall RAW                                   ; pc=0x01F0
    sleep ; stall RAW                                   ; pc=0x01F4
    sleep ; stall RAW                                   ; pc=0x01F8
    blt x4, x3, 68                                      ; pc=0x01FC ; target=.L0_if_else ; addr=0x0240
    sleep ; nop despues de control                      ; pc=0x0200
    sleep ; nop despues de control                      ; pc=0x0204
    addi x4, x0, 0                                      ; pc=0x0208
    sleep ; stall RAW                                   ; pc=0x020C
    sleep ; stall RAW                                   ; pc=0x0210
    sleep ; stall RAW                                   ; pc=0x0214
    add x11, x4, x0                                     ; pc=0x0218
    sleep ; stall RAW                                   ; pc=0x021C
    sleep ; stall RAW                                   ; pc=0x0220
    sleep ; stall RAW                                   ; pc=0x0224
    jal x0, 512                                         ; pc=0x0228 ; target=.L_codegen_2_es_primo_end ; addr=0x0428
    sleep ; nop despues de control                      ; pc=0x022C
    sleep ; nop despues de control                      ; pc=0x0230
    jal x0, 12                                          ; pc=0x0234 ; target=.L1_if_end ; addr=0x0240
    sleep ; nop despues de control                      ; pc=0x0238
    sleep ; nop despues de control                      ; pc=0x023C
.L0_if_else:
.L1_if_end:


    ; if
    lw x4, -8(x17) ; divisor                            ; pc=0x0240
    sleep ; stall RAW                                   ; pc=0x0244
    sleep ; stall RAW                                   ; pc=0x0248
    sleep ; stall RAW                                   ; pc=0x024C
    lw x3, -8(x17) ; divisor                            ; pc=0x0250
    sleep ; stall RAW                                   ; pc=0x0254
    sleep ; stall RAW                                   ; pc=0x0258
    sleep ; stall RAW                                   ; pc=0x025C
    mul x5, x4, x3                                      ; pc=0x0260
    sleep ; stall RAW                                   ; pc=0x0264
    sleep ; stall RAW                                   ; pc=0x0268
    sleep ; stall RAW                                   ; pc=0x026C
    lw x3, -4(x17) ; n                                  ; pc=0x0270
    sleep ; stall RAW                                   ; pc=0x0274
    sleep ; stall RAW                                   ; pc=0x0278
    sleep ; stall RAW                                   ; pc=0x027C
    bge x3, x5, 68                                      ; pc=0x0280 ; target=.L2_if_else ; addr=0x02C4
    sleep ; nop despues de control                      ; pc=0x0284
    sleep ; nop despues de control                      ; pc=0x0288
    addi x3, x0, 1                                      ; pc=0x028C
    sleep ; stall RAW                                   ; pc=0x0290
    sleep ; stall RAW                                   ; pc=0x0294
    sleep ; stall RAW                                   ; pc=0x0298
    add x11, x3, x0                                     ; pc=0x029C
    sleep ; stall RAW                                   ; pc=0x02A0
    sleep ; stall RAW                                   ; pc=0x02A4
    sleep ; stall RAW                                   ; pc=0x02A8
    jal x0, 380                                         ; pc=0x02AC ; target=.L_codegen_2_es_primo_end ; addr=0x0428
    sleep ; nop despues de control                      ; pc=0x02B0
    sleep ; nop despues de control                      ; pc=0x02B4
    jal x0, 12                                          ; pc=0x02B8 ; target=.L3_if_end ; addr=0x02C4
    sleep ; nop despues de control                      ; pc=0x02BC
    sleep ; nop despues de control                      ; pc=0x02C0
.L2_if_else:
.L3_if_end:

    lw x3, -4(x17) ; n                                  ; pc=0x02C4
    sleep ; stall RAW                                   ; pc=0x02C8
    sleep ; stall RAW                                   ; pc=0x02CC
    sleep ; stall RAW                                   ; pc=0x02D0
    lw x5, -8(x17) ; divisor                            ; pc=0x02D4
    sleep ; stall RAW                                   ; pc=0x02D8
    sleep ; stall RAW                                   ; pc=0x02DC
    sleep ; stall RAW                                   ; pc=0x02E0
    div x4, x3, x5                                      ; pc=0x02E4
    sleep ; stall RAW                                   ; pc=0x02E8
    sleep ; stall RAW                                   ; pc=0x02EC
    sleep ; stall RAW                                   ; pc=0x02F0
    sw x4, -12(x17) ; cociente                          ; pc=0x02F4
    lw x4, -12(x17) ; cociente                          ; pc=0x02F8
    sleep ; stall RAW                                   ; pc=0x02FC
    sleep ; stall RAW                                   ; pc=0x0300
    sleep ; stall RAW                                   ; pc=0x0304
    lw x5, -8(x17) ; divisor                            ; pc=0x0308
    sleep ; stall RAW                                   ; pc=0x030C
    sleep ; stall RAW                                   ; pc=0x0310
    sleep ; stall RAW                                   ; pc=0x0314
    mul x3, x4, x5                                      ; pc=0x0318
    sleep ; stall RAW                                   ; pc=0x031C
    sleep ; stall RAW                                   ; pc=0x0320
    sleep ; stall RAW                                   ; pc=0x0324
    sw x3, -16(x17) ; producto                          ; pc=0x0328

    ; if
    lw x3, -16(x17) ; producto                          ; pc=0x032C
    sleep ; stall RAW                                   ; pc=0x0330
    sleep ; stall RAW                                   ; pc=0x0334
    sleep ; stall RAW                                   ; pc=0x0338
    lw x5, -4(x17) ; n                                  ; pc=0x033C
    sleep ; stall RAW                                   ; pc=0x0340
    sleep ; stall RAW                                   ; pc=0x0344
    sleep ; stall RAW                                   ; pc=0x0348
    bne x3, x5, 68                                      ; pc=0x034C ; target=.L4_if_else ; addr=0x0390
    sleep ; nop despues de control                      ; pc=0x0350
    sleep ; nop despues de control                      ; pc=0x0354
    addi x5, x0, 0                                      ; pc=0x0358
    sleep ; stall RAW                                   ; pc=0x035C
    sleep ; stall RAW                                   ; pc=0x0360
    sleep ; stall RAW                                   ; pc=0x0364
    add x11, x5, x0                                     ; pc=0x0368
    sleep ; stall RAW                                   ; pc=0x036C
    sleep ; stall RAW                                   ; pc=0x0370
    sleep ; stall RAW                                   ; pc=0x0374
    jal x0, 176                                         ; pc=0x0378 ; target=.L_codegen_2_es_primo_end ; addr=0x0428
    sleep ; nop despues de control                      ; pc=0x037C
    sleep ; nop despues de control                      ; pc=0x0380
    jal x0, 12                                          ; pc=0x0384 ; target=.L5_if_end ; addr=0x0390
    sleep ; nop despues de control                      ; pc=0x0388
    sleep ; nop despues de control                      ; pc=0x038C
.L4_if_else:
.L5_if_end:

    lw x5, -4(x17) ; n                                  ; pc=0x0390
    sleep ; stall RAW                                   ; pc=0x0394
    sleep ; stall RAW                                   ; pc=0x0398
    sleep ; stall RAW                                   ; pc=0x039C
    add x11, x5, x0                                     ; pc=0x03A0
    sleep ; stall RAW                                   ; pc=0x03A4
    sleep ; stall RAW                                   ; pc=0x03A8
    sleep ; stall RAW                                   ; pc=0x03AC
    lw x5, -8(x17) ; divisor                            ; pc=0x03B0
    sleep ; stall RAW                                   ; pc=0x03B4
    sleep ; stall RAW                                   ; pc=0x03B8
    sleep ; stall RAW                                   ; pc=0x03BC
    addi x3, x0, 1                                      ; pc=0x03C0
    sleep ; stall RAW                                   ; pc=0x03C4
    sleep ; stall RAW                                   ; pc=0x03C8
    sleep ; stall RAW                                   ; pc=0x03CC
    add x4, x5, x3                                      ; pc=0x03D0
    sleep ; stall RAW                                   ; pc=0x03D4
    sleep ; stall RAW                                   ; pc=0x03D8
    sleep ; stall RAW                                   ; pc=0x03DC
    add x12, x4, x0                                     ; pc=0x03E0
    sleep ; stall RAW                                   ; pc=0x03E4
    sleep ; stall RAW                                   ; pc=0x03E8
    sleep ; stall RAW                                   ; pc=0x03EC
    jal x1, -580                                        ; pc=0x03F0 ; target=es_primo ; addr=0x01AC
    sleep ; nop despues de control                      ; pc=0x03F4
    sleep ; nop despues de control                      ; pc=0x03F8
    add x4, x11, x0                                     ; pc=0x03FC
    sleep ; stall RAW                                   ; pc=0x0400
    sleep ; stall RAW                                   ; pc=0x0404
    sleep ; stall RAW                                   ; pc=0x0408
    add x11, x4, x0                                     ; pc=0x040C
    sleep ; stall RAW                                   ; pc=0x0410
    sleep ; stall RAW                                   ; pc=0x0414
    sleep ; stall RAW                                   ; pc=0x0418
    jal x0, 12                                          ; pc=0x041C ; target=.L_codegen_2_es_primo_end ; addr=0x0428
    sleep ; nop despues de control                      ; pc=0x0420
    sleep ; nop despues de control                      ; pc=0x0424
.L_codegen_2_es_primo_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0428
    sleep ; stall RAW                                   ; pc=0x042C
    sleep ; stall RAW                                   ; pc=0x0430
    sleep ; stall RAW                                   ; pc=0x0434
    lw x17, 4(x2)                                       ; pc=0x0438
    sleep ; stall RAW                                   ; pc=0x043C
    sleep ; stall RAW                                   ; pc=0x0440
    sleep ; stall RAW                                   ; pc=0x0444
    addi x2, x2, 28                                     ; pc=0x0448
    sleep ; stall RAW                                   ; pc=0x044C
    sleep ; stall RAW                                   ; pc=0x0450
    sleep ; stall RAW                                   ; pc=0x0454
    jalr x1, 0                                          ; pc=0x0458
    sleep ; nop despues de control                      ; pc=0x045C
    sleep ; nop despues de control                      ; pc=0x0460

sume:
    ; prologue
    addiSigned x2, x2, -24                              ; pc=0x0464
    sleep ; stall RAW                                   ; pc=0x0468
    sleep ; stall RAW                                   ; pc=0x046C
    sleep ; stall RAW                                   ; pc=0x0470
    sw x1, 0(x2)                                        ; pc=0x0474
    sw x17, 4(x2)                                       ; pc=0x0478
    addi x17, x2, 24                                    ; pc=0x047C
    sleep ; stall RAW                                   ; pc=0x0480
    sleep ; stall RAW                                   ; pc=0x0484
    sleep ; stall RAW                                   ; pc=0x0488

    sw x11, -4(x17) ; parámetro lista                   ; pc=0x048C

    addi x4, x0, 0                                      ; pc=0x0490
    sleep ; stall RAW                                   ; pc=0x0494
    sleep ; stall RAW                                   ; pc=0x0498
    sleep ; stall RAW                                   ; pc=0x049C
    sw x4, -8(x17) ; suma                               ; pc=0x04A0

    ; for
    addi x4, x0, 0                                      ; pc=0x04A4
    sleep ; stall RAW                                   ; pc=0x04A8
    sleep ; stall RAW                                   ; pc=0x04AC
    sleep ; stall RAW                                   ; pc=0x04B0
    sw x4, -12(x17) ; i                                 ; pc=0x04B4
.L6_for_start:
    lw x4, -12(x17) ; i                                 ; pc=0x04B8
    sleep ; stall RAW                                   ; pc=0x04BC
    sleep ; stall RAW                                   ; pc=0x04C0
    sleep ; stall RAW                                   ; pc=0x04C4
    addi x3, x0, 10                                     ; pc=0x04C8
    sleep ; stall RAW                                   ; pc=0x04CC
    sleep ; stall RAW                                   ; pc=0x04D0
    sleep ; stall RAW                                   ; pc=0x04D4
    bge x4, x3, 404                                     ; pc=0x04D8 ; target=.L7_for_end ; addr=0x066C
    sleep ; nop despues de control                      ; pc=0x04DC
    sleep ; nop despues de control                      ; pc=0x04E0

    ; if
    lw x3, -12(x17) ; i                                 ; pc=0x04E4
    sleep ; stall RAW                                   ; pc=0x04E8
    sleep ; stall RAW                                   ; pc=0x04EC
    sleep ; stall RAW                                   ; pc=0x04F0
    add x4, x3, x3                                      ; pc=0x04F4
    sleep ; stall RAW                                   ; pc=0x04F8
    sleep ; stall RAW                                   ; pc=0x04FC
    sleep ; stall RAW                                   ; pc=0x0500
    add x4, x4, x4                                      ; pc=0x0504
    sleep ; stall RAW                                   ; pc=0x0508
    sleep ; stall RAW                                   ; pc=0x050C
    sleep ; stall RAW                                   ; pc=0x0510
    lw x5, -4(x17) ; base ref lista                     ; pc=0x0514
    sleep ; stall RAW                                   ; pc=0x0518
    sleep ; stall RAW                                   ; pc=0x051C
    sleep ; stall RAW                                   ; pc=0x0520
    add x5, x5, x4                                      ; pc=0x0524
    sleep ; stall RAW                                   ; pc=0x0528
    sleep ; stall RAW                                   ; pc=0x052C
    sleep ; stall RAW                                   ; pc=0x0530
    lw x4, 0(x5)                                        ; pc=0x0534
    sleep ; stall RAW                                   ; pc=0x0538
    sleep ; stall RAW                                   ; pc=0x053C
    sleep ; stall RAW                                   ; pc=0x0540
    add x11, x4, x0                                     ; pc=0x0544
    sleep ; stall RAW                                   ; pc=0x0548
    sleep ; stall RAW                                   ; pc=0x054C
    sleep ; stall RAW                                   ; pc=0x0550
    addi x4, x0, 2                                      ; pc=0x0554
    sleep ; stall RAW                                   ; pc=0x0558
    sleep ; stall RAW                                   ; pc=0x055C
    sleep ; stall RAW                                   ; pc=0x0560
    add x12, x4, x0                                     ; pc=0x0564
    sleep ; stall RAW                                   ; pc=0x0568
    sleep ; stall RAW                                   ; pc=0x056C
    sleep ; stall RAW                                   ; pc=0x0570
    jal x1, -968                                        ; pc=0x0574 ; target=es_primo ; addr=0x01AC
    sleep ; nop despues de control                      ; pc=0x0578
    sleep ; nop despues de control                      ; pc=0x057C
    add x4, x11, x0                                     ; pc=0x0580
    sleep ; stall RAW                                   ; pc=0x0584
    sleep ; stall RAW                                   ; pc=0x0588
    sleep ; stall RAW                                   ; pc=0x058C
    beq x4, x0, 156                                     ; pc=0x0590 ; target=.L8_if_else ; addr=0x062C
    sleep ; nop despues de control                      ; pc=0x0594
    sleep ; nop despues de control                      ; pc=0x0598
    lw x4, -8(x17) ; suma                               ; pc=0x059C
    sleep ; stall RAW                                   ; pc=0x05A0
    sleep ; stall RAW                                   ; pc=0x05A4
    sleep ; stall RAW                                   ; pc=0x05A8
    lw x5, -12(x17) ; i                                 ; pc=0x05AC
    sleep ; stall RAW                                   ; pc=0x05B0
    sleep ; stall RAW                                   ; pc=0x05B4
    sleep ; stall RAW                                   ; pc=0x05B8
    add x3, x5, x5                                      ; pc=0x05BC
    sleep ; stall RAW                                   ; pc=0x05C0
    sleep ; stall RAW                                   ; pc=0x05C4
    sleep ; stall RAW                                   ; pc=0x05C8
    add x3, x3, x3                                      ; pc=0x05CC
    sleep ; stall RAW                                   ; pc=0x05D0
    sleep ; stall RAW                                   ; pc=0x05D4
    sleep ; stall RAW                                   ; pc=0x05D8
    lw x6, -4(x17) ; base ref lista                     ; pc=0x05DC
    sleep ; stall RAW                                   ; pc=0x05E0
    sleep ; stall RAW                                   ; pc=0x05E4
    sleep ; stall RAW                                   ; pc=0x05E8
    add x6, x6, x3                                      ; pc=0x05EC
    sleep ; stall RAW                                   ; pc=0x05F0
    sleep ; stall RAW                                   ; pc=0x05F4
    sleep ; stall RAW                                   ; pc=0x05F8
    lw x3, 0(x6)                                        ; pc=0x05FC
    sleep ; stall RAW                                   ; pc=0x0600
    sleep ; stall RAW                                   ; pc=0x0604
    sleep ; stall RAW                                   ; pc=0x0608
    add x6, x4, x3                                      ; pc=0x060C
    sleep ; stall RAW                                   ; pc=0x0610
    sleep ; stall RAW                                   ; pc=0x0614
    sleep ; stall RAW                                   ; pc=0x0618
    sw x6, -8(x17) ; suma                               ; pc=0x061C
    jal x0, 12                                          ; pc=0x0620 ; target=.L9_if_end ; addr=0x062C
    sleep ; nop despues de control                      ; pc=0x0624
    sleep ; nop despues de control                      ; pc=0x0628
.L8_if_else:
.L9_if_end:

    lw x6, -12(x17) ; i                                 ; pc=0x062C
    sleep ; stall RAW                                   ; pc=0x0630
    sleep ; stall RAW                                   ; pc=0x0634
    sleep ; stall RAW                                   ; pc=0x0638
    addi x3, x0, 1                                      ; pc=0x063C
    sleep ; stall RAW                                   ; pc=0x0640
    sleep ; stall RAW                                   ; pc=0x0644
    sleep ; stall RAW                                   ; pc=0x0648
    add x4, x6, x3                                      ; pc=0x064C
    sleep ; stall RAW                                   ; pc=0x0650
    sleep ; stall RAW                                   ; pc=0x0654
    sleep ; stall RAW                                   ; pc=0x0658
    sw x4, -12(x17) ; i                                 ; pc=0x065C
    jal x0, -424                                        ; pc=0x0660 ; target=.L6_for_start ; addr=0x04B8
    sleep ; nop despues de control                      ; pc=0x0664
    sleep ; nop despues de control                      ; pc=0x0668
.L7_for_end:

    lw x4, -8(x17) ; suma                               ; pc=0x066C
    sleep ; stall RAW                                   ; pc=0x0670
    sleep ; stall RAW                                   ; pc=0x0674
    sleep ; stall RAW                                   ; pc=0x0678
    add x11, x4, x0                                     ; pc=0x067C
    sleep ; stall RAW                                   ; pc=0x0680
    sleep ; stall RAW                                   ; pc=0x0684
    sleep ; stall RAW                                   ; pc=0x0688
    jal x0, 12                                          ; pc=0x068C ; target=.L_codegen_3_sume_end ; addr=0x0698
    sleep ; nop despues de control                      ; pc=0x0690
    sleep ; nop despues de control                      ; pc=0x0694
.L_codegen_3_sume_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0698
    sleep ; stall RAW                                   ; pc=0x069C
    sleep ; stall RAW                                   ; pc=0x06A0
    sleep ; stall RAW                                   ; pc=0x06A4
    lw x17, 4(x2)                                       ; pc=0x06A8
    sleep ; stall RAW                                   ; pc=0x06AC
    sleep ; stall RAW                                   ; pc=0x06B0
    sleep ; stall RAW                                   ; pc=0x06B4
    addi x2, x2, 24                                     ; pc=0x06B8
    sleep ; stall RAW                                   ; pc=0x06BC
    sleep ; stall RAW                                   ; pc=0x06C0
    sleep ; stall RAW                                   ; pc=0x06C4
    jalr x1, 0                                          ; pc=0x06C8
    sleep ; nop despues de control                      ; pc=0x06CC
    sleep ; nop despues de control                      ; pc=0x06D0