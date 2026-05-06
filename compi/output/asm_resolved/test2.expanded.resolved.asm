; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0020
;   main = 0x0020
;   .L_codegen_1_main_end = 0x016C
;   maximo_lista = 0x0190
;   .L0_for_start = 0x0274
;   .L_codegen_3_cmp_true = 0x036C
;   .L_codegen_4_cmp_end = 0x037C
;   .L2_if_else = 0x03DC
;   .L3_if_end = 0x03DC
;   .L1_for_end = 0x041C
;   .L_codegen_2_maximo_lista_end = 0x0448

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0020, offset=32)
;   pc=0x0134 jal -> maximo_lista (addr=0x0190, offset=92)
;   pc=0x0160 jal -> .L_codegen_1_main_end (addr=0x016C, offset=12)
;   pc=0x02B4 bge -> .L1_for_end (addr=0x041C, offset=360)
;   pc=0x0354 blt -> .L_codegen_3_cmp_true (addr=0x036C, offset=24)
;   pc=0x0360 jal -> .L_codegen_4_cmp_end (addr=0x037C, offset=28)
;   pc=0x03B0 beq -> .L2_if_else (addr=0x03DC, offset=44)
;   pc=0x03D0 jal -> .L3_if_end (addr=0x03DC, offset=12)
;   pc=0x0410 jal -> .L0_for_start (addr=0x0274, offset=-412)
;   pc=0x043C jal -> .L_codegen_2_maximo_lista_end (addr=0x0448, offset=12)

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
    addiSigned x2, x2, -64                              ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x1, 0(x2)                                        ; pc=0x0050
    sw x17, 4(x2)                                       ; pc=0x0054
    addi x17, x2, 64                                    ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064

    addi x3, x0, 3                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sw x3, -28(x17) ; lista[0]                          ; pc=0x0078
    addi x3, x0, 4                                      ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    sw x3, -24(x17) ; lista[1]                          ; pc=0x008C
    addi x3, x0, 5                                      ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    sw x3, -20(x17) ; lista[2]                          ; pc=0x00A0
    addi x3, x0, 24                                     ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    sw x3, -16(x17) ; lista[3]                          ; pc=0x00B4
    addi x3, x0, 5                                      ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    sw x3, -12(x17) ; lista[4]                          ; pc=0x00C8
    addi x3, x0, 65                                     ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    sleep ; stall RAW                                   ; pc=0x00D8
    sw x3, -8(x17) ; lista[5]                           ; pc=0x00DC
    addi x3, x0, 46                                     ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    sw x3, -4(x17) ; lista[6]                           ; pc=0x00F0
    addiSigned x3, x17, -28                             ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    ; base lista
    add x11, x3, x0                                     ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    addi x3, x0, 7                                      ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    add x12, x3, x0                                     ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    jal x1, 92                                          ; pc=0x0134 ; target=maximo_lista ; addr=0x0190
    sleep ; nop despues de control                      ; pc=0x0138
    sleep ; nop despues de control                      ; pc=0x013C
    add x3, x11, x0                                     ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    sleep ; stall RAW                                   ; pc=0x0148
    sleep ; stall RAW                                   ; pc=0x014C
    add x11, x3, x0                                     ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    sleep ; stall RAW                                   ; pc=0x0158
    sleep ; stall RAW                                   ; pc=0x015C
    jal x0, 12                                          ; pc=0x0160 ; target=.L_codegen_1_main_end ; addr=0x016C
    sleep ; nop despues de control                      ; pc=0x0164
    sleep ; nop despues de control                      ; pc=0x0168
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x016C
    sleep ; stall RAW                                   ; pc=0x0170
    sleep ; stall RAW                                   ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    addi x2, x2, 64                                     ; pc=0x017C
    sleep ; stall RAW                                   ; pc=0x0180
    sleep ; stall RAW                                   ; pc=0x0184
    sleep ; stall RAW                                   ; pc=0x0188
    freeze                                              ; pc=0x018C

maximo_lista:
    ; prologue
    addiSigned x2, x2, -40                              ; pc=0x0190
    sleep ; stall RAW                                   ; pc=0x0194
    sleep ; stall RAW                                   ; pc=0x0198
    sleep ; stall RAW                                   ; pc=0x019C
    sw x1, 0(x2)                                        ; pc=0x01A0
    sw x17, 4(x2)                                       ; pc=0x01A4
    addi x17, x2, 40                                    ; pc=0x01A8
    sleep ; stall RAW                                   ; pc=0x01AC
    sleep ; stall RAW                                   ; pc=0x01B0
    sleep ; stall RAW                                   ; pc=0x01B4

    sw x11, -4(x17) ; parámetro lista                   ; pc=0x01B8
    sw x12, -8(x17) ; parámetro largo                   ; pc=0x01BC

    addi x3, x0, 0                                      ; pc=0x01C0
    sleep ; stall RAW                                   ; pc=0x01C4
    sleep ; stall RAW                                   ; pc=0x01C8
    sleep ; stall RAW                                   ; pc=0x01CC
    add x4, x3, x3                                      ; pc=0x01D0
    sleep ; stall RAW                                   ; pc=0x01D4
    sleep ; stall RAW                                   ; pc=0x01D8
    sleep ; stall RAW                                   ; pc=0x01DC
    add x4, x4, x4                                      ; pc=0x01E0
    sleep ; stall RAW                                   ; pc=0x01E4
    sleep ; stall RAW                                   ; pc=0x01E8
    sleep ; stall RAW                                   ; pc=0x01EC
    lw x5, -4(x17) ; base ref lista                     ; pc=0x01F0
    sleep ; stall RAW                                   ; pc=0x01F4
    sleep ; stall RAW                                   ; pc=0x01F8
    sleep ; stall RAW                                   ; pc=0x01FC
    add x5, x5, x4                                      ; pc=0x0200
    sleep ; stall RAW                                   ; pc=0x0204
    sleep ; stall RAW                                   ; pc=0x0208
    sleep ; stall RAW                                   ; pc=0x020C
    lw x4, 0(x5)                                        ; pc=0x0210
    sleep ; stall RAW                                   ; pc=0x0214
    sleep ; stall RAW                                   ; pc=0x0218
    sleep ; stall RAW                                   ; pc=0x021C
    sw x4, -12(x17) ; maximo                            ; pc=0x0220
    addi x4, x0, 0                                      ; pc=0x0224
    sleep ; stall RAW                                   ; pc=0x0228
    sleep ; stall RAW                                   ; pc=0x022C
    sleep ; stall RAW                                   ; pc=0x0230
    sw x4, -16(x17) ; num                               ; pc=0x0234
    addi x4, x0, 0                                      ; pc=0x0238
    sleep ; stall RAW                                   ; pc=0x023C
    sleep ; stall RAW                                   ; pc=0x0240
    sleep ; stall RAW                                   ; pc=0x0244
    sw x4, -20(x17) ; esMayor                           ; pc=0x0248
    lw x4, -8(x17) ; largo                              ; pc=0x024C
    sleep ; stall RAW                                   ; pc=0x0250
    sleep ; stall RAW                                   ; pc=0x0254
    sleep ; stall RAW                                   ; pc=0x0258
    sw x4, -24(x17) ; limite                            ; pc=0x025C

    ; for
    addi x4, x0, 0                                      ; pc=0x0260
    sleep ; stall RAW                                   ; pc=0x0264
    sleep ; stall RAW                                   ; pc=0x0268
    sleep ; stall RAW                                   ; pc=0x026C
    sw x4, -28(x17) ; i                                 ; pc=0x0270
.L0_for_start:
    lw x4, -28(x17) ; i                                 ; pc=0x0274
    sleep ; stall RAW                                   ; pc=0x0278
    sleep ; stall RAW                                   ; pc=0x027C
    sleep ; stall RAW                                   ; pc=0x0280
    lw x5, -24(x17) ; limite                            ; pc=0x0284
    sleep ; stall RAW                                   ; pc=0x0288
    sleep ; stall RAW                                   ; pc=0x028C
    sleep ; stall RAW                                   ; pc=0x0290
    addi x3, x0, 0                                      ; pc=0x0294
    sleep ; stall RAW                                   ; pc=0x0298
    sleep ; stall RAW                                   ; pc=0x029C
    sleep ; stall RAW                                   ; pc=0x02A0
    add x6, x5, x3                                      ; pc=0x02A4
    sleep ; stall RAW                                   ; pc=0x02A8
    sleep ; stall RAW                                   ; pc=0x02AC
    sleep ; stall RAW                                   ; pc=0x02B0
    bge x4, x6, 360                                     ; pc=0x02B4 ; target=.L1_for_end ; addr=0x041C
    sleep ; nop despues de control                      ; pc=0x02B8
    sleep ; nop despues de control                      ; pc=0x02BC
    lw x6, -28(x17) ; i                                 ; pc=0x02C0
    sleep ; stall RAW                                   ; pc=0x02C4
    sleep ; stall RAW                                   ; pc=0x02C8
    sleep ; stall RAW                                   ; pc=0x02CC
    add x4, x6, x6                                      ; pc=0x02D0
    sleep ; stall RAW                                   ; pc=0x02D4
    sleep ; stall RAW                                   ; pc=0x02D8
    sleep ; stall RAW                                   ; pc=0x02DC
    add x4, x4, x4                                      ; pc=0x02E0
    sleep ; stall RAW                                   ; pc=0x02E4
    sleep ; stall RAW                                   ; pc=0x02E8
    sleep ; stall RAW                                   ; pc=0x02EC
    lw x3, -4(x17) ; base ref lista                     ; pc=0x02F0
    sleep ; stall RAW                                   ; pc=0x02F4
    sleep ; stall RAW                                   ; pc=0x02F8
    sleep ; stall RAW                                   ; pc=0x02FC
    add x3, x3, x4                                      ; pc=0x0300
    sleep ; stall RAW                                   ; pc=0x0304
    sleep ; stall RAW                                   ; pc=0x0308
    sleep ; stall RAW                                   ; pc=0x030C
    lw x4, 0(x3)                                        ; pc=0x0310
    sleep ; stall RAW                                   ; pc=0x0314
    sleep ; stall RAW                                   ; pc=0x0318
    sleep ; stall RAW                                   ; pc=0x031C
    sw x4, -16(x17) ; num                               ; pc=0x0320
    lw x4, -16(x17) ; num                               ; pc=0x0324
    sleep ; stall RAW                                   ; pc=0x0328
    sleep ; stall RAW                                   ; pc=0x032C
    sleep ; stall RAW                                   ; pc=0x0330
    lw x3, -12(x17) ; maximo                            ; pc=0x0334
    sleep ; stall RAW                                   ; pc=0x0338
    sleep ; stall RAW                                   ; pc=0x033C
    sleep ; stall RAW                                   ; pc=0x0340
    addi x6, x0, 0                                      ; pc=0x0344
    sleep ; stall RAW                                   ; pc=0x0348
    sleep ; stall RAW                                   ; pc=0x034C
    sleep ; stall RAW                                   ; pc=0x0350
    blt x3, x4, 24                                      ; pc=0x0354 ; target=.L_codegen_3_cmp_true ; addr=0x036C
    sleep ; nop despues de control                      ; pc=0x0358
    sleep ; nop despues de control                      ; pc=0x035C
    jal x0, 28                                          ; pc=0x0360 ; target=.L_codegen_4_cmp_end ; addr=0x037C
    sleep ; nop despues de control                      ; pc=0x0364
    sleep ; nop despues de control                      ; pc=0x0368
.L_codegen_3_cmp_true:
    addi x6, x0, 1                                      ; pc=0x036C
    sleep ; stall RAW                                   ; pc=0x0370
    sleep ; stall RAW                                   ; pc=0x0374
    sleep ; stall RAW                                   ; pc=0x0378
.L_codegen_4_cmp_end:
    sw x6, -20(x17) ; esMayor                           ; pc=0x037C

    ; if
    lw x6, -20(x17) ; esMayor                           ; pc=0x0380
    sleep ; stall RAW                                   ; pc=0x0384
    sleep ; stall RAW                                   ; pc=0x0388
    sleep ; stall RAW                                   ; pc=0x038C
    addi x3, x0, 0                                      ; pc=0x0390
    sleep ; stall RAW                                   ; pc=0x0394
    sleep ; stall RAW                                   ; pc=0x0398
    sleep ; stall RAW                                   ; pc=0x039C
    add x4, x6, x3                                      ; pc=0x03A0
    sleep ; stall RAW                                   ; pc=0x03A4
    sleep ; stall RAW                                   ; pc=0x03A8
    sleep ; stall RAW                                   ; pc=0x03AC
    beq x4, x0, 44                                      ; pc=0x03B0 ; target=.L2_if_else ; addr=0x03DC
    sleep ; nop despues de control                      ; pc=0x03B4
    sleep ; nop despues de control                      ; pc=0x03B8
    lw x4, -16(x17) ; num                               ; pc=0x03BC
    sleep ; stall RAW                                   ; pc=0x03C0
    sleep ; stall RAW                                   ; pc=0x03C4
    sleep ; stall RAW                                   ; pc=0x03C8
    sw x4, -12(x17) ; maximo                            ; pc=0x03CC
    jal x0, 12                                          ; pc=0x03D0 ; target=.L3_if_end ; addr=0x03DC
    sleep ; nop despues de control                      ; pc=0x03D4
    sleep ; nop despues de control                      ; pc=0x03D8
.L2_if_else:
.L3_if_end:

    lw x4, -28(x17) ; i                                 ; pc=0x03DC
    sleep ; stall RAW                                   ; pc=0x03E0
    sleep ; stall RAW                                   ; pc=0x03E4
    sleep ; stall RAW                                   ; pc=0x03E8
    addi x3, x0, 1                                      ; pc=0x03EC
    sleep ; stall RAW                                   ; pc=0x03F0
    sleep ; stall RAW                                   ; pc=0x03F4
    sleep ; stall RAW                                   ; pc=0x03F8
    add x6, x4, x3                                      ; pc=0x03FC
    sleep ; stall RAW                                   ; pc=0x0400
    sleep ; stall RAW                                   ; pc=0x0404
    sleep ; stall RAW                                   ; pc=0x0408
    sw x6, -28(x17) ; i                                 ; pc=0x040C
    jal x0, -412                                        ; pc=0x0410 ; target=.L0_for_start ; addr=0x0274
    sleep ; nop despues de control                      ; pc=0x0414
    sleep ; nop despues de control                      ; pc=0x0418
.L1_for_end:

    lw x6, -12(x17) ; maximo                            ; pc=0x041C
    sleep ; stall RAW                                   ; pc=0x0420
    sleep ; stall RAW                                   ; pc=0x0424
    sleep ; stall RAW                                   ; pc=0x0428
    add x11, x6, x0                                     ; pc=0x042C
    sleep ; stall RAW                                   ; pc=0x0430
    sleep ; stall RAW                                   ; pc=0x0434
    sleep ; stall RAW                                   ; pc=0x0438
    jal x0, 12                                          ; pc=0x043C ; target=.L_codegen_2_maximo_lista_end ; addr=0x0448
    sleep ; nop despues de control                      ; pc=0x0440
    sleep ; nop despues de control                      ; pc=0x0444
.L_codegen_2_maximo_lista_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0448
    sleep ; stall RAW                                   ; pc=0x044C
    sleep ; stall RAW                                   ; pc=0x0450
    sleep ; stall RAW                                   ; pc=0x0454
    lw x17, 4(x2)                                       ; pc=0x0458
    sleep ; stall RAW                                   ; pc=0x045C
    sleep ; stall RAW                                   ; pc=0x0460
    sleep ; stall RAW                                   ; pc=0x0464
    addi x2, x2, 40                                     ; pc=0x0468
    sleep ; stall RAW                                   ; pc=0x046C
    sleep ; stall RAW                                   ; pc=0x0470
    sleep ; stall RAW                                   ; pc=0x0474
    jalr x1, 0                                          ; pc=0x0478
    sleep ; nop despues de control                      ; pc=0x047C
    sleep ; nop despues de control                      ; pc=0x0480