; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_ir_0_enderExit = 0x0018
;   main = 0x0018
;   L_for_start_4 = 0x0038
;   .L_ir_2_ir_cmp_true = 0x0050
;   .L_ir_3_ir_cmp_end = 0x0054
;   L_for_end_5 = 0x01A4
;   L_for_start_6 = 0x01AC
;   .L_ir_4_ir_cmp_true = 0x01C8
;   .L_ir_5_ir_cmp_end = 0x01CC
;   L_for_end_7 = 0x032C
;   L_for_start_8 = 0x033C
;   .L_ir_6_ir_cmp_true = 0x0354
;   .L_ir_7_ir_cmp_end = 0x0358
;   .L_ir_8_ir_cmp_true = 0x03B0
;   .L_ir_9_ir_cmp_end = 0x03B4
;   L_else_10 = 0x03D0
;   L_end_if_11 = 0x03D0
;   .L_ir_10_ir_cmp_true = 0x041C
;   .L_ir_11_ir_cmp_end = 0x0420
;   L_else_12 = 0x0438
;   L_end_if_13 = 0x0438
;   L_for_end_9 = 0x0448
;   .L_ir_12_ir_cmp_true = 0x045C
;   .L_ir_13_ir_cmp_end = 0x0460
;   L_else_14 = 0x047C
;   L_end_if_15 = 0x047C
;   .L_ir_1_main_end = 0x0488
;   tea_encrypt = 0x0494
;   L_for_start_0 = 0x0504
;   .L_ir_15_ir_cmp_true = 0x0518
;   .L_ir_16_ir_cmp_end = 0x051C
;   L_for_end_1 = 0x0684
;   .L_ir_14_tea_encrypt_end = 0x06B4
;   tea_decrypt = 0x06C4
;   L_for_start_2 = 0x073C
;   .L_ir_18_ir_cmp_true = 0x0750
;   .L_ir_19_ir_cmp_end = 0x0754
;   L_for_end_3 = 0x08BC
;   .L_ir_17_tea_decrypt_end = 0x08EC

; Referencias resueltas
;   pc=0x0000 portalv -> .L_ir_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0048 blt -> .L_ir_2_ir_cmp_true (addr=0x0050, offset=8)
;   pc=0x004C jal -> .L_ir_3_ir_cmp_end (addr=0x0054, offset=8)
;   pc=0x005C beq -> L_for_end_5 (addr=0x01A4, offset=328)
;   pc=0x0104 jal -> tea_encrypt (addr=0x0494, offset=912)
;   pc=0x01A0 jal -> L_for_start_4 (addr=0x0038, offset=-360)
;   pc=0x01C0 blt -> .L_ir_4_ir_cmp_true (addr=0x01C8, offset=8)
;   pc=0x01C4 jal -> .L_ir_5_ir_cmp_end (addr=0x01CC, offset=8)
;   pc=0x01D4 beq -> L_for_end_7 (addr=0x032C, offset=344)
;   pc=0x0284 jal -> tea_decrypt (addr=0x06C4, offset=1088)
;   pc=0x0328 jal -> L_for_start_6 (addr=0x01AC, offset=-380)
;   pc=0x034C blt -> .L_ir_6_ir_cmp_true (addr=0x0354, offset=8)
;   pc=0x0350 jal -> .L_ir_7_ir_cmp_end (addr=0x0358, offset=8)
;   pc=0x0360 beq -> L_for_end_9 (addr=0x0448, offset=232)
;   pc=0x03A8 bne -> .L_ir_8_ir_cmp_true (addr=0x03B0, offset=8)
;   pc=0x03AC jal -> .L_ir_9_ir_cmp_end (addr=0x03B4, offset=8)
;   pc=0x03BC beq -> L_else_10 (addr=0x03D0, offset=20)
;   pc=0x03C8 jal -> .L_ir_1_main_end (addr=0x0488, offset=192)
;   pc=0x03CC jal -> L_end_if_11 (addr=0x03D0, offset=4)
;   pc=0x0414 bne -> .L_ir_10_ir_cmp_true (addr=0x041C, offset=8)
;   pc=0x0418 jal -> .L_ir_11_ir_cmp_end (addr=0x0420, offset=8)
;   pc=0x0428 beq -> L_else_12 (addr=0x0438, offset=16)
;   pc=0x0434 jal -> L_end_if_13 (addr=0x0438, offset=4)
;   pc=0x0444 jal -> L_for_start_8 (addr=0x033C, offset=-264)
;   pc=0x0454 beq -> .L_ir_12_ir_cmp_true (addr=0x045C, offset=8)
;   pc=0x0458 jal -> .L_ir_13_ir_cmp_end (addr=0x0460, offset=8)
;   pc=0x0468 beq -> L_else_14 (addr=0x047C, offset=20)
;   pc=0x0474 jal -> .L_ir_1_main_end (addr=0x0488, offset=20)
;   pc=0x0478 jal -> L_end_if_15 (addr=0x047C, offset=4)
;   pc=0x0484 jal -> .L_ir_1_main_end (addr=0x0488, offset=4)
;   pc=0x0510 blt -> .L_ir_15_ir_cmp_true (addr=0x0518, offset=8)
;   pc=0x0514 jal -> .L_ir_16_ir_cmp_end (addr=0x051C, offset=8)
;   pc=0x0524 beq -> L_for_end_1 (addr=0x0684, offset=352)
;   pc=0x0680 jal -> L_for_start_0 (addr=0x0504, offset=-380)
;   pc=0x0748 blt -> .L_ir_18_ir_cmp_true (addr=0x0750, offset=8)
;   pc=0x074C jal -> .L_ir_19_ir_cmp_end (addr=0x0754, offset=8)
;   pc=0x075C beq -> L_for_end_3 (addr=0x08BC, offset=352)
;   pc=0x08B8 jal -> L_for_start_2 (addr=0x073C, offset=-380)

; ==================================================
; Ensamblador generado directamente desde IR
; Las optimizaciones IR son la fuente del ejecutable
; ==================================================

.data
key: ; addr=0x8000
    .word 0xDEADBEEF
    .word 0xDEADBEEF
    .word 0xDEADBEEF
    .word 0xDEADBEEF
image_original: ; addr=0x8010
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
image_encrypted: ; addr=0x8410
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
image_decrypted: ; addr=0x8810
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
block: ; addr=0x8C10
    .word 0
    .word 0
DELTA: ; addr=0x8C18
    .word 0x9E3779B9
SUM_INIT: ; addr=0x8C1C
    .word 0xC6EF3720
IMAGE_WORDS: ; addr=0x8C20
    .word 0x100

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
    addiSigned x2, x2, -132                             ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 132                                   ; pc=0x002C

    addi x5, x0, 0                                      ; pc=0x0030
    add x4, x5, x0 ; promote offset                     ; pc=0x0034
L_for_start_4:
    addiHIGH x7, x0, 0                                  ; pc=0x0038
    addi x7, x7, 35872                                  ; pc=0x003C
    lw x6, 0(x7) ; IMAGE_WORDS                          ; pc=0x0040
    addi x8, x0, 0                                      ; pc=0x0044
    blt x4, x6, 8                                       ; pc=0x0048 ; target=.L_ir_2_ir_cmp_true ; addr=0x0050
    jal x0, 8                                           ; pc=0x004C ; target=.L_ir_3_ir_cmp_end ; addr=0x0054
.L_ir_2_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0050
.L_ir_3_ir_cmp_end:
    sw x8, -20(x17) ; t42                               ; pc=0x0054
    lw x9, -20(x17) ; t42                               ; pc=0x0058
    beq x9, x0, 328                                     ; pc=0x005C ; target=L_for_end_5 ; addr=0x01A4
    add x10, x4, x4                                     ; pc=0x0060
    add x10, x10, x10                                   ; pc=0x0064
    addiHIGH x5, x0, 0                                  ; pc=0x0068
    addi x5, x5, 32784                                  ; pc=0x006C
    add x5, x5, x10                                     ; pc=0x0070
    lw x7, 0(x5)                                        ; pc=0x0074
    sw x7, -24(x17) ; t43                               ; pc=0x0078
    lw x8, -24(x17) ; t43                               ; pc=0x007C
    addi x6, x0, 0                                      ; pc=0x0080
    add x9, x6, x6                                      ; pc=0x0084
    add x9, x9, x9                                      ; pc=0x0088
    addiHIGH x10, x0, 0                                 ; pc=0x008C
    addi x10, x10, 35856                                ; pc=0x0090
    add x10, x10, x9                                    ; pc=0x0094
    sw x8, 0(x10)                                       ; pc=0x0098
    addi x5, x0, 1                                      ; pc=0x009C
    add x7, x4, x5                                      ; pc=0x00A0
    sw x7, -28(x17) ; t44                               ; pc=0x00A4
    lw x9, -28(x17) ; t44                               ; pc=0x00A8
    add x6, x9, x9                                      ; pc=0x00AC
    add x6, x6, x6                                      ; pc=0x00B0
    addiHIGH x10, x0, 0                                 ; pc=0x00B4
    addi x10, x10, 32784                                ; pc=0x00B8
    add x10, x10, x6                                    ; pc=0x00BC
    lw x8, 0(x10)                                       ; pc=0x00C0
    sw x8, -32(x17) ; t45                               ; pc=0x00C4
    lw x7, -32(x17) ; t45                               ; pc=0x00C8
    addi x5, x0, 1                                      ; pc=0x00CC
    add x6, x5, x5                                      ; pc=0x00D0
    add x6, x6, x6                                      ; pc=0x00D4
    addiHIGH x9, x0, 0                                  ; pc=0x00D8
    addi x9, x9, 35856                                  ; pc=0x00DC
    add x9, x9, x6                                      ; pc=0x00E0
    sw x7, 0(x9)                                        ; pc=0x00E4
    addiHIGH x10, x0, 0                                 ; pc=0x00E8
    addi x10, x10, 35856                                ; pc=0x00EC
    add x11, x10, x0                                    ; pc=0x00F0
    addiHIGH x8, x0, 0                                  ; pc=0x00F4
    addi x8, x8, 32768                                  ; pc=0x00F8
    add x12, x8, x0                                     ; pc=0x00FC
    sw x4, -4(x17) ; offset                             ; pc=0x0100
    jal x1, 912                                         ; pc=0x0104 ; target=tea_encrypt ; addr=0x0494
    addi x6, x0, 0                                      ; pc=0x0108
    add x5, x6, x6                                      ; pc=0x010C
    add x5, x5, x5                                      ; pc=0x0110
    addiHIGH x9, x0, 0                                  ; pc=0x0114
    addi x9, x9, 35856                                  ; pc=0x0118
    add x9, x9, x5                                      ; pc=0x011C
    lw x7, 0(x9)                                        ; pc=0x0120
    sw x7, -40(x17) ; t47                               ; pc=0x0124
    lw x10, -40(x17) ; t47                              ; pc=0x0128
    lw x4, -4(x17) ; offset                             ; pc=0x012C
    add x8, x4, x4                                      ; pc=0x0130
    add x8, x8, x8                                      ; pc=0x0134
    addiHIGH x5, x0, 0                                  ; pc=0x0138
    addi x5, x5, 33808                                  ; pc=0x013C
    add x5, x5, x8                                      ; pc=0x0140
    sw x10, 0(x5)                                       ; pc=0x0144
    addi x6, x0, 1                                      ; pc=0x0148
    add x9, x6, x6                                      ; pc=0x014C
    add x9, x9, x9                                      ; pc=0x0150
    addiHIGH x7, x0, 0                                  ; pc=0x0154
    addi x7, x7, 35856                                  ; pc=0x0158
    add x7, x7, x9                                      ; pc=0x015C
    lw x8, 0(x7)                                        ; pc=0x0160
    sw x8, -44(x17) ; t48                               ; pc=0x0164
    addi x5, x0, 1                                      ; pc=0x0168
    add x10, x4, x5                                     ; pc=0x016C
    sw x10, -48(x17) ; t49                              ; pc=0x0170
    lw x9, -44(x17) ; t48                               ; pc=0x0174
    lw x6, -48(x17) ; t49                               ; pc=0x0178
    add x7, x6, x6                                      ; pc=0x017C
    add x7, x7, x7                                      ; pc=0x0180
    addiHIGH x8, x0, 0                                  ; pc=0x0184
    addi x8, x8, 33808                                  ; pc=0x0188
    add x8, x8, x7                                      ; pc=0x018C
    sw x9, 0(x8)                                        ; pc=0x0190
    addi x10, x0, 2                                     ; pc=0x0194
    add x5, x4, x10                                     ; pc=0x0198
    add x4, x5, x0 ; promote offset                     ; pc=0x019C
    jal x0, -360                                        ; pc=0x01A0 ; target=L_for_start_4 ; addr=0x0038
L_for_end_5:
    addi x7, x0, 0                                      ; pc=0x01A4
    sw x7, -8(x17) ; offset2                            ; pc=0x01A8
L_for_start_6:
    lw x6, -8(x17) ; offset2                            ; pc=0x01AC
    addiHIGH x9, x0, 0                                  ; pc=0x01B0
    addi x9, x9, 35872                                  ; pc=0x01B4
    lw x8, 0(x9) ; IMAGE_WORDS                          ; pc=0x01B8
    addi x5, x0, 0                                      ; pc=0x01BC
    blt x6, x8, 8                                       ; pc=0x01C0 ; target=.L_ir_4_ir_cmp_true ; addr=0x01C8
    jal x0, 8                                           ; pc=0x01C4 ; target=.L_ir_5_ir_cmp_end ; addr=0x01CC
.L_ir_4_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x01C8
.L_ir_5_ir_cmp_end:
    sw x5, -56(x17) ; t51                               ; pc=0x01CC
    lw x10, -56(x17) ; t51                              ; pc=0x01D0
    beq x10, x0, 344                                    ; pc=0x01D4 ; target=L_for_end_7 ; addr=0x032C
    lw x7, -8(x17) ; offset2                            ; pc=0x01D8
    add x9, x7, x7                                      ; pc=0x01DC
    add x9, x9, x9                                      ; pc=0x01E0
    addiHIGH x5, x0, 0                                  ; pc=0x01E4
    addi x5, x5, 33808                                  ; pc=0x01E8
    add x5, x5, x9                                      ; pc=0x01EC
    lw x8, 0(x5)                                        ; pc=0x01F0
    sw x8, -60(x17) ; t52                               ; pc=0x01F4
    lw x6, -60(x17) ; t52                               ; pc=0x01F8
    addi x10, x0, 0                                     ; pc=0x01FC
    add x9, x10, x10                                    ; pc=0x0200
    add x9, x9, x9                                      ; pc=0x0204
    addiHIGH x7, x0, 0                                  ; pc=0x0208
    addi x7, x7, 35856                                  ; pc=0x020C
    add x7, x7, x9                                      ; pc=0x0210
    sw x6, 0(x7)                                        ; pc=0x0214
    lw x5, -8(x17) ; offset2                            ; pc=0x0218
    addi x8, x0, 1                                      ; pc=0x021C
    add x9, x5, x8                                      ; pc=0x0220
    sw x9, -64(x17) ; t53                               ; pc=0x0224
    lw x10, -64(x17) ; t53                              ; pc=0x0228
    add x7, x10, x10                                    ; pc=0x022C
    add x7, x7, x7                                      ; pc=0x0230
    addiHIGH x6, x0, 0                                  ; pc=0x0234
    addi x6, x6, 33808                                  ; pc=0x0238
    add x6, x6, x7                                      ; pc=0x023C
    lw x9, 0(x6)                                        ; pc=0x0240
    sw x9, -68(x17) ; t54                               ; pc=0x0244
    lw x8, -68(x17) ; t54                               ; pc=0x0248
    addi x5, x0, 1                                      ; pc=0x024C
    add x7, x5, x5                                      ; pc=0x0250
    add x7, x7, x7                                      ; pc=0x0254
    addiHIGH x10, x0, 0                                 ; pc=0x0258
    addi x10, x10, 35856                                ; pc=0x025C
    add x10, x10, x7                                    ; pc=0x0260
    sw x8, 0(x10)                                       ; pc=0x0264
    addiHIGH x6, x0, 0                                  ; pc=0x0268
    addi x6, x6, 35856                                  ; pc=0x026C
    add x11, x6, x0                                     ; pc=0x0270
    addiHIGH x9, x0, 0                                  ; pc=0x0274
    addi x9, x9, 32768                                  ; pc=0x0278
    add x12, x9, x0                                     ; pc=0x027C
    sw x4, -4(x17) ; offset                             ; pc=0x0280
    jal x1, 1088                                        ; pc=0x0284 ; target=tea_decrypt ; addr=0x06C4
    addi x7, x0, 0                                      ; pc=0x0288
    add x5, x7, x7                                      ; pc=0x028C
    add x5, x5, x5                                      ; pc=0x0290
    addiHIGH x10, x0, 0                                 ; pc=0x0294
    addi x10, x10, 35856                                ; pc=0x0298
    add x10, x10, x5                                    ; pc=0x029C
    lw x8, 0(x10)                                       ; pc=0x02A0
    sw x8, -76(x17) ; t56                               ; pc=0x02A4
    lw x6, -76(x17) ; t56                               ; pc=0x02A8
    lw x9, -8(x17) ; offset2                            ; pc=0x02AC
    add x5, x9, x9                                      ; pc=0x02B0
    add x5, x5, x5                                      ; pc=0x02B4
    addiHIGH x7, x0, 0                                  ; pc=0x02B8
    addi x7, x7, 34832                                  ; pc=0x02BC
    add x7, x7, x5                                      ; pc=0x02C0
    sw x6, 0(x7)                                        ; pc=0x02C4
    addi x10, x0, 1                                     ; pc=0x02C8
    add x8, x10, x10                                    ; pc=0x02CC
    add x8, x8, x8                                      ; pc=0x02D0
    addiHIGH x5, x0, 0                                  ; pc=0x02D4
    addi x5, x5, 35856                                  ; pc=0x02D8
    add x5, x5, x8                                      ; pc=0x02DC
    lw x9, 0(x5)                                        ; pc=0x02E0
    sw x9, -80(x17) ; t57                               ; pc=0x02E4
    lw x7, -8(x17) ; offset2                            ; pc=0x02E8
    addi x6, x0, 1                                      ; pc=0x02EC
    add x8, x7, x6                                      ; pc=0x02F0
    sw x8, -84(x17) ; t58                               ; pc=0x02F4
    lw x10, -80(x17) ; t57                              ; pc=0x02F8
    lw x5, -84(x17) ; t58                               ; pc=0x02FC
    add x9, x5, x5                                      ; pc=0x0300
    add x9, x9, x9                                      ; pc=0x0304
    addiHIGH x8, x0, 0                                  ; pc=0x0308
    addi x8, x8, 34832                                  ; pc=0x030C
    add x8, x8, x9                                      ; pc=0x0310
    sw x10, 0(x8)                                       ; pc=0x0314
    lw x6, -8(x17) ; offset2                            ; pc=0x0318
    addi x7, x0, 2                                      ; pc=0x031C
    add x9, x6, x7                                      ; pc=0x0320
    sw x9, -8(x17) ; offset2                            ; pc=0x0324
    jal x0, -380                                        ; pc=0x0328 ; target=L_for_start_6 ; addr=0x01AC
L_for_end_7:
    addi x5, x0, 0                                      ; pc=0x032C
    sw x5, -12(x17) ; changed                           ; pc=0x0330
    addi x8, x0, 0                                      ; pc=0x0334
    add x3, x8, x0 ; promote check                      ; pc=0x0338
L_for_start_8:
    addiHIGH x9, x0, 0                                  ; pc=0x033C
    addi x9, x9, 35872                                  ; pc=0x0340
    lw x10, 0(x9) ; IMAGE_WORDS                         ; pc=0x0344
    addi x7, x0, 0                                      ; pc=0x0348
    blt x3, x10, 8                                      ; pc=0x034C ; target=.L_ir_6_ir_cmp_true ; addr=0x0354
    jal x0, 8                                           ; pc=0x0350 ; target=.L_ir_7_ir_cmp_end ; addr=0x0358
.L_ir_6_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0354
.L_ir_7_ir_cmp_end:
    sw x7, -92(x17) ; t60                               ; pc=0x0358
    lw x6, -92(x17) ; t60                               ; pc=0x035C
    beq x6, x0, 232                                     ; pc=0x0360 ; target=L_for_end_9 ; addr=0x0448
    add x5, x3, x3                                      ; pc=0x0364
    add x5, x5, x5                                      ; pc=0x0368
    addiHIGH x8, x0, 0                                  ; pc=0x036C
    addi x8, x8, 34832                                  ; pc=0x0370
    add x8, x8, x5                                      ; pc=0x0374
    lw x9, 0(x8)                                        ; pc=0x0378
    sw x9, -96(x17) ; t61                               ; pc=0x037C
    add x7, x3, x3                                      ; pc=0x0380
    add x7, x7, x7                                      ; pc=0x0384
    addiHIGH x10, x0, 0                                 ; pc=0x0388
    addi x10, x10, 32784                                ; pc=0x038C
    add x10, x10, x7                                    ; pc=0x0390
    lw x6, 0(x10)                                       ; pc=0x0394
    sw x6, -100(x17) ; t62                              ; pc=0x0398
    lw x5, -96(x17) ; t61                               ; pc=0x039C
    lw x8, -100(x17) ; t62                              ; pc=0x03A0
    addi x9, x0, 0                                      ; pc=0x03A4
    bne x5, x8, 8                                       ; pc=0x03A8 ; target=.L_ir_8_ir_cmp_true ; addr=0x03B0
    jal x0, 8                                           ; pc=0x03AC ; target=.L_ir_9_ir_cmp_end ; addr=0x03B4
.L_ir_8_ir_cmp_true:
    addi x9, x0, 1                                      ; pc=0x03B0
.L_ir_9_ir_cmp_end:
    sw x9, -104(x17) ; t63                              ; pc=0x03B4
    lw x7, -104(x17) ; t63                              ; pc=0x03B8
    beq x7, x0, 20                                      ; pc=0x03BC ; target=L_else_10 ; addr=0x03D0
    addi x10, x0, 1                                     ; pc=0x03C0
    add x11, x10, x0                                    ; pc=0x03C4
    jal x0, 192                                         ; pc=0x03C8 ; target=.L_ir_1_main_end ; addr=0x0488
    jal x0, 4                                           ; pc=0x03CC ; target=L_end_if_11 ; addr=0x03D0
L_else_10:
L_end_if_11:
    add x6, x3, x3                                      ; pc=0x03D0
    add x6, x6, x6                                      ; pc=0x03D4
    addiHIGH x9, x0, 0                                  ; pc=0x03D8
    addi x9, x9, 33808                                  ; pc=0x03DC
    add x9, x9, x6                                      ; pc=0x03E0
    lw x8, 0(x9)                                        ; pc=0x03E4
    sw x8, -108(x17) ; t64                              ; pc=0x03E8
    add x5, x3, x3                                      ; pc=0x03EC
    add x5, x5, x5                                      ; pc=0x03F0
    addiHIGH x7, x0, 0                                  ; pc=0x03F4
    addi x7, x7, 32784                                  ; pc=0x03F8
    add x7, x7, x5                                      ; pc=0x03FC
    lw x10, 0(x7)                                       ; pc=0x0400
    sw x10, -112(x17) ; t65                             ; pc=0x0404
    lw x6, -108(x17) ; t64                              ; pc=0x0408
    lw x9, -112(x17) ; t65                              ; pc=0x040C
    addi x8, x0, 0                                      ; pc=0x0410
    bne x6, x9, 8                                       ; pc=0x0414 ; target=.L_ir_10_ir_cmp_true ; addr=0x041C
    jal x0, 8                                           ; pc=0x0418 ; target=.L_ir_11_ir_cmp_end ; addr=0x0420
.L_ir_10_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x041C
.L_ir_11_ir_cmp_end:
    sw x8, -116(x17) ; t66                              ; pc=0x0420
    lw x5, -116(x17) ; t66                              ; pc=0x0424
    beq x5, x0, 16                                      ; pc=0x0428 ; target=L_else_12 ; addr=0x0438
    addi x7, x0, 1                                      ; pc=0x042C
    sw x7, -12(x17) ; changed                           ; pc=0x0430
    jal x0, 4                                           ; pc=0x0434 ; target=L_end_if_13 ; addr=0x0438
L_else_12:
L_end_if_13:
    addi x10, x0, 1                                     ; pc=0x0438
    add x8, x3, x10                                     ; pc=0x043C
    add x3, x8, x0 ; promote check                      ; pc=0x0440
    jal x0, -264                                        ; pc=0x0444 ; target=L_for_start_8 ; addr=0x033C
L_for_end_9:
    lw x9, -12(x17) ; changed                           ; pc=0x0448
    addi x6, x0, 0                                      ; pc=0x044C
    addi x5, x0, 0                                      ; pc=0x0450
    beq x9, x6, 8                                       ; pc=0x0454 ; target=.L_ir_12_ir_cmp_true ; addr=0x045C
    jal x0, 8                                           ; pc=0x0458 ; target=.L_ir_13_ir_cmp_end ; addr=0x0460
.L_ir_12_ir_cmp_true:
    addi x5, x0, 1                                      ; pc=0x045C
.L_ir_13_ir_cmp_end:
    sw x5, -124(x17) ; t68                              ; pc=0x0460
    lw x7, -124(x17) ; t68                              ; pc=0x0464
    beq x7, x0, 20                                      ; pc=0x0468 ; target=L_else_14 ; addr=0x047C
    addi x8, x0, 2                                      ; pc=0x046C
    add x11, x8, x0                                     ; pc=0x0470
    jal x0, 20                                          ; pc=0x0474 ; target=.L_ir_1_main_end ; addr=0x0488
    jal x0, 4                                           ; pc=0x0478 ; target=L_end_if_15 ; addr=0x047C
L_else_14:
L_end_if_15:
    addi x10, x0, 0                                     ; pc=0x047C
    add x11, x10, x0                                    ; pc=0x0480
    jal x0, 4                                           ; pc=0x0484 ; target=.L_ir_1_main_end ; addr=0x0488
.L_ir_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0488
    addi x2, x2, 132                                    ; pc=0x048C
    freeze                                              ; pc=0x0490

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -140                             ; pc=0x0494
    sw x1, 0(x2)                                        ; pc=0x0498
    sw x17, 4(x2)                                       ; pc=0x049C
    addi x17, x2, 140                                   ; pc=0x04A0

    sw x11, -4(x17) ; parametro v                       ; pc=0x04A4
    sw x12, -8(x17) ; parametro tea_key                 ; pc=0x04A8

    addi x5, x0, 0                                      ; pc=0x04AC
    add x6, x5, x5                                      ; pc=0x04B0
    add x6, x6, x6                                      ; pc=0x04B4
    lw x7, -4(x17) ; base ref v                         ; pc=0x04B8
    add x7, x7, x6                                      ; pc=0x04BC
    lw x8, 0(x7)                                        ; pc=0x04C0
    sw x8, -52(x17) ; t0                                ; pc=0x04C4
    lw x9, -52(x17) ; t0                                ; pc=0x04C8
    add x3, x9, x0 ; promote v0                         ; pc=0x04CC
    addi x10, x0, 1                                     ; pc=0x04D0
    add x6, x10, x10                                    ; pc=0x04D4
    add x6, x6, x6                                      ; pc=0x04D8
    lw x5, -4(x17) ; base ref v                         ; pc=0x04DC
    add x5, x5, x6                                      ; pc=0x04E0
    lw x7, 0(x5)                                        ; pc=0x04E4
    sw x7, -56(x17) ; t1                                ; pc=0x04E8
    lw x8, -56(x17) ; t1                                ; pc=0x04EC
    add x4, x8, x0 ; promote v1                         ; pc=0x04F0
    addi x9, x0, 0                                      ; pc=0x04F4
    sw x9, -20(x17) ; sum                               ; pc=0x04F8
    addi x6, x0, 0                                      ; pc=0x04FC
    sw x6, -24(x17) ; i                                 ; pc=0x0500
L_for_start_0:
    lw x10, -24(x17) ; i                                ; pc=0x0504
    addi x5, x0, 32                                     ; pc=0x0508
    addi x7, x0, 0                                      ; pc=0x050C
    blt x10, x5, 8                                      ; pc=0x0510 ; target=.L_ir_15_ir_cmp_true ; addr=0x0518
    jal x0, 8                                           ; pc=0x0514 ; target=.L_ir_16_ir_cmp_end ; addr=0x051C
.L_ir_15_ir_cmp_true:
    addi x7, x0, 1                                      ; pc=0x0518
.L_ir_16_ir_cmp_end:
    sw x7, -60(x17) ; t2                                ; pc=0x051C
    lw x8, -60(x17) ; t2                                ; pc=0x0520
    beq x8, x0, 352                                     ; pc=0x0524 ; target=L_for_end_1 ; addr=0x0684
    lw x9, -20(x17) ; sum                               ; pc=0x0528
    addiHIGH x7, x0, 0                                  ; pc=0x052C
    addi x7, x7, 35864                                  ; pc=0x0530
    lw x6, 0(x7) ; DELTA                                ; pc=0x0534
    add x5, x9, x6                                      ; pc=0x0538
    sw x5, -20(x17) ; sum                               ; pc=0x053C
    addi x10, x0, 0                                     ; pc=0x0540
    add x8, x10, x10                                    ; pc=0x0544
    add x8, x8, x8                                      ; pc=0x0548
    lw x7, -8(x17) ; base ref tea_key                   ; pc=0x054C
    add x7, x7, x8                                      ; pc=0x0550
    lw x5, 0(x7)                                        ; pc=0x0554
    sw x5, -68(x17) ; t4                                ; pc=0x0558
    lw x6, -68(x17) ; t4                                ; pc=0x055C
    addi x8, x0, 4                                      ; pc=0x0560
    sll x9, x4, x8                                      ; pc=0x0564
    add x9, x9, x6                                      ; pc=0x0568
    sw x9, -28(x17) ; left0                             ; pc=0x056C
    lw x10, -20(x17) ; sum                              ; pc=0x0570
    add x7, x4, x10                                     ; pc=0x0574
    sw x7, -32(x17) ; mid0                              ; pc=0x0578
    addi x5, x0, 1                                      ; pc=0x057C
    add x8, x5, x5                                      ; pc=0x0580
    add x8, x8, x8                                      ; pc=0x0584
    lw x9, -8(x17) ; base ref tea_key                   ; pc=0x0588
    add x9, x9, x8                                      ; pc=0x058C
    lw x6, 0(x9)                                        ; pc=0x0590
    sw x6, -80(x17) ; t7                                ; pc=0x0594
    lw x7, -80(x17) ; t7                                ; pc=0x0598
    addi x8, x0, 5                                      ; pc=0x059C
    srl x10, x4, x8                                     ; pc=0x05A0
    add x10, x10, x7                                    ; pc=0x05A4
    sw x10, -36(x17) ; right0                           ; pc=0x05A8
    lw x5, -28(x17) ; left0                             ; pc=0x05AC
    lw x9, -32(x17) ; mid0                              ; pc=0x05B0
    xor x6, x5, x9                                      ; pc=0x05B4
    sw x6, -88(x17) ; t9                                ; pc=0x05B8
    lw x8, -88(x17) ; t9                                ; pc=0x05BC
    lw x10, -36(x17) ; right0                           ; pc=0x05C0
    xor x7, x8, x10                                     ; pc=0x05C4
    sw x7, -92(x17) ; t10                               ; pc=0x05C8
    lw x6, -92(x17) ; t10                               ; pc=0x05CC
    add x9, x3, x6                                      ; pc=0x05D0
    add x3, x9, x0 ; promote v0                         ; pc=0x05D4
    addi x5, x0, 2                                      ; pc=0x05D8
    add x7, x5, x5                                      ; pc=0x05DC
    add x7, x7, x7                                      ; pc=0x05E0
    lw x10, -8(x17) ; base ref tea_key                  ; pc=0x05E4
    add x10, x10, x7                                    ; pc=0x05E8
    lw x8, 0(x10)                                       ; pc=0x05EC
    sw x8, -100(x17) ; t12                              ; pc=0x05F0
    lw x9, -100(x17) ; t12                              ; pc=0x05F4
    addi x7, x0, 4                                      ; pc=0x05F8
    sll x6, x3, x7                                      ; pc=0x05FC
    add x6, x6, x9                                      ; pc=0x0600
    sw x6, -40(x17) ; left1                             ; pc=0x0604
    lw x5, -20(x17) ; sum                               ; pc=0x0608
    add x10, x3, x5                                     ; pc=0x060C
    sw x10, -44(x17) ; mid1                             ; pc=0x0610
    addi x8, x0, 3                                      ; pc=0x0614
    add x7, x8, x8                                      ; pc=0x0618
    add x7, x7, x7                                      ; pc=0x061C
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x0620
    add x6, x6, x7                                      ; pc=0x0624
    lw x9, 0(x6)                                        ; pc=0x0628
    sw x9, -112(x17) ; t15                              ; pc=0x062C
    lw x10, -112(x17) ; t15                             ; pc=0x0630
    addi x7, x0, 5                                      ; pc=0x0634
    srl x5, x3, x7                                      ; pc=0x0638
    add x5, x5, x10                                     ; pc=0x063C
    sw x5, -48(x17) ; right1                            ; pc=0x0640
    lw x8, -40(x17) ; left1                             ; pc=0x0644
    lw x6, -44(x17) ; mid1                              ; pc=0x0648
    xor x9, x8, x6                                      ; pc=0x064C
    sw x9, -120(x17) ; t17                              ; pc=0x0650
    lw x7, -120(x17) ; t17                              ; pc=0x0654
    lw x5, -48(x17) ; right1                            ; pc=0x0658
    xor x10, x7, x5                                     ; pc=0x065C
    sw x10, -124(x17) ; t18                             ; pc=0x0660
    lw x9, -124(x17) ; t18                              ; pc=0x0664
    add x6, x4, x9                                      ; pc=0x0668
    add x4, x6, x0 ; promote v1                         ; pc=0x066C
    lw x8, -24(x17) ; i                                 ; pc=0x0670
    addi x10, x0, 1                                     ; pc=0x0674
    add x5, x8, x10                                     ; pc=0x0678
    sw x5, -24(x17) ; i                                 ; pc=0x067C
    jal x0, -380                                        ; pc=0x0680 ; target=L_for_start_0 ; addr=0x0504
L_for_end_1:
    addi x7, x0, 0                                      ; pc=0x0684
    add x6, x7, x7                                      ; pc=0x0688
    add x6, x6, x6                                      ; pc=0x068C
    lw x9, -4(x17) ; base ref v                         ; pc=0x0690
    add x9, x9, x6                                      ; pc=0x0694
    sw x3, 0(x9)                                        ; pc=0x0698
    addi x5, x0, 1                                      ; pc=0x069C
    add x10, x5, x5                                     ; pc=0x06A0
    add x10, x10, x10                                   ; pc=0x06A4
    lw x8, -4(x17) ; base ref v                         ; pc=0x06A8
    add x8, x8, x10                                     ; pc=0x06AC
    sw x4, 0(x8)                                        ; pc=0x06B0
.L_ir_14_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x06B4
    lw x17, 4(x2)                                       ; pc=0x06B8
    addi x2, x2, 140                                    ; pc=0x06BC
    jalr x1, 0                                          ; pc=0x06C0

tea_decrypt:
    ; prologue
    addiSigned x2, x2, -140                             ; pc=0x06C4
    sw x1, 0(x2)                                        ; pc=0x06C8
    sw x17, 4(x2)                                       ; pc=0x06CC
    addi x17, x2, 140                                   ; pc=0x06D0

    sw x11, -4(x17) ; parametro v                       ; pc=0x06D4
    sw x12, -8(x17) ; parametro tea_key                 ; pc=0x06D8

    addi x5, x0, 0                                      ; pc=0x06DC
    add x6, x5, x5                                      ; pc=0x06E0
    add x6, x6, x6                                      ; pc=0x06E4
    lw x7, -4(x17) ; base ref v                         ; pc=0x06E8
    add x7, x7, x6                                      ; pc=0x06EC
    lw x8, 0(x7)                                        ; pc=0x06F0
    sw x8, -52(x17) ; t21                               ; pc=0x06F4
    lw x9, -52(x17) ; t21                               ; pc=0x06F8
    add x3, x9, x0 ; promote v0                         ; pc=0x06FC
    addi x10, x0, 1                                     ; pc=0x0700
    add x6, x10, x10                                    ; pc=0x0704
    add x6, x6, x6                                      ; pc=0x0708
    lw x5, -4(x17) ; base ref v                         ; pc=0x070C
    add x5, x5, x6                                      ; pc=0x0710
    lw x7, 0(x5)                                        ; pc=0x0714
    sw x7, -56(x17) ; t22                               ; pc=0x0718
    lw x8, -56(x17) ; t22                               ; pc=0x071C
    add x4, x8, x0 ; promote v1                         ; pc=0x0720
    addiHIGH x6, x0, 0                                  ; pc=0x0724
    addi x6, x6, 35868                                  ; pc=0x0728
    lw x9, 0(x6) ; SUM_INIT                             ; pc=0x072C
    sw x9, -20(x17) ; sum                               ; pc=0x0730
    addi x10, x0, 0                                     ; pc=0x0734
    sw x10, -24(x17) ; i                                ; pc=0x0738
L_for_start_2:
    lw x5, -24(x17) ; i                                 ; pc=0x073C
    addi x7, x0, 32                                     ; pc=0x0740
    addi x8, x0, 0                                      ; pc=0x0744
    blt x5, x7, 8                                       ; pc=0x0748 ; target=.L_ir_18_ir_cmp_true ; addr=0x0750
    jal x0, 8                                           ; pc=0x074C ; target=.L_ir_19_ir_cmp_end ; addr=0x0754
.L_ir_18_ir_cmp_true:
    addi x8, x0, 1                                      ; pc=0x0750
.L_ir_19_ir_cmp_end:
    sw x8, -60(x17) ; t23                               ; pc=0x0754
    lw x6, -60(x17) ; t23                               ; pc=0x0758
    beq x6, x0, 352                                     ; pc=0x075C ; target=L_for_end_3 ; addr=0x08BC
    addi x9, x0, 2                                      ; pc=0x0760
    add x10, x9, x9                                     ; pc=0x0764
    add x10, x10, x10                                   ; pc=0x0768
    lw x8, -8(x17) ; base ref tea_key                   ; pc=0x076C
    add x8, x8, x10                                     ; pc=0x0770
    lw x7, 0(x8)                                        ; pc=0x0774
    sw x7, -64(x17) ; t24                               ; pc=0x0778
    lw x5, -64(x17) ; t24                               ; pc=0x077C
    addi x10, x0, 4                                     ; pc=0x0780
    sll x6, x3, x10                                     ; pc=0x0784
    add x6, x6, x5                                      ; pc=0x0788
    sw x6, -28(x17) ; left1                             ; pc=0x078C
    lw x9, -20(x17) ; sum                               ; pc=0x0790
    add x8, x3, x9                                      ; pc=0x0794
    sw x8, -32(x17) ; mid1                              ; pc=0x0798
    addi x7, x0, 3                                      ; pc=0x079C
    add x10, x7, x7                                     ; pc=0x07A0
    add x10, x10, x10                                   ; pc=0x07A4
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x07A8
    add x6, x6, x10                                     ; pc=0x07AC
    lw x5, 0(x6)                                        ; pc=0x07B0
    sw x5, -76(x17) ; t27                               ; pc=0x07B4
    lw x8, -76(x17) ; t27                               ; pc=0x07B8
    addi x10, x0, 5                                     ; pc=0x07BC
    srl x9, x3, x10                                     ; pc=0x07C0
    add x9, x9, x8                                      ; pc=0x07C4
    sw x9, -36(x17) ; right1                            ; pc=0x07C8
    lw x7, -28(x17) ; left1                             ; pc=0x07CC
    lw x6, -32(x17) ; mid1                              ; pc=0x07D0
    xor x5, x7, x6                                      ; pc=0x07D4
    sw x5, -84(x17) ; t29                               ; pc=0x07D8
    lw x10, -84(x17) ; t29                              ; pc=0x07DC
    lw x9, -36(x17) ; right1                            ; pc=0x07E0
    xor x8, x10, x9                                     ; pc=0x07E4
    sw x8, -88(x17) ; t30                               ; pc=0x07E8
    lw x5, -88(x17) ; t30                               ; pc=0x07EC
    sub x6, x4, x5                                      ; pc=0x07F0
    add x4, x6, x0 ; promote v1                         ; pc=0x07F4
    addi x7, x0, 0                                      ; pc=0x07F8
    add x8, x7, x7                                      ; pc=0x07FC
    add x8, x8, x8                                      ; pc=0x0800
    lw x9, -8(x17) ; base ref tea_key                   ; pc=0x0804
    add x9, x9, x8                                      ; pc=0x0808
    lw x10, 0(x9)                                       ; pc=0x080C
    sw x10, -96(x17) ; t32                              ; pc=0x0810
    lw x6, -96(x17) ; t32                               ; pc=0x0814
    addi x8, x0, 4                                      ; pc=0x0818
    sll x5, x4, x8                                      ; pc=0x081C
    add x5, x5, x6                                      ; pc=0x0820
    sw x5, -40(x17) ; left0                             ; pc=0x0824
    lw x7, -20(x17) ; sum                               ; pc=0x0828
    add x9, x4, x7                                      ; pc=0x082C
    sw x9, -44(x17) ; mid0                              ; pc=0x0830
    addi x10, x0, 1                                     ; pc=0x0834
    add x8, x10, x10                                    ; pc=0x0838
    add x8, x8, x8                                      ; pc=0x083C
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x0840
    add x5, x5, x8                                      ; pc=0x0844
    lw x6, 0(x5)                                        ; pc=0x0848
    sw x6, -108(x17) ; t35                              ; pc=0x084C
    lw x9, -108(x17) ; t35                              ; pc=0x0850
    addi x8, x0, 5                                      ; pc=0x0854
    srl x7, x4, x8                                      ; pc=0x0858
    add x7, x7, x9                                      ; pc=0x085C
    sw x7, -48(x17) ; right0                            ; pc=0x0860
    lw x10, -40(x17) ; left0                            ; pc=0x0864
    lw x5, -44(x17) ; mid0                              ; pc=0x0868
    xor x6, x10, x5                                     ; pc=0x086C
    sw x6, -116(x17) ; t37                              ; pc=0x0870
    lw x8, -116(x17) ; t37                              ; pc=0x0874
    lw x7, -48(x17) ; right0                            ; pc=0x0878
    xor x9, x8, x7                                      ; pc=0x087C
    sw x9, -120(x17) ; t38                              ; pc=0x0880
    lw x6, -120(x17) ; t38                              ; pc=0x0884
    sub x5, x3, x6                                      ; pc=0x0888
    add x3, x5, x0 ; promote v0                         ; pc=0x088C
    lw x10, -20(x17) ; sum                              ; pc=0x0890
    addiHIGH x7, x0, 0                                  ; pc=0x0894
    addi x7, x7, 35864                                  ; pc=0x0898
    lw x9, 0(x7) ; DELTA                                ; pc=0x089C
    sub x8, x10, x9                                     ; pc=0x08A0
    sw x8, -20(x17) ; sum                               ; pc=0x08A4
    lw x5, -24(x17) ; i                                 ; pc=0x08A8
    addi x6, x0, 1                                      ; pc=0x08AC
    add x7, x5, x6                                      ; pc=0x08B0
    sw x7, -24(x17) ; i                                 ; pc=0x08B4
    jal x0, -380                                        ; pc=0x08B8 ; target=L_for_start_2 ; addr=0x073C
L_for_end_3:
    addi x8, x0, 0                                      ; pc=0x08BC
    add x9, x8, x8                                      ; pc=0x08C0
    add x9, x9, x9                                      ; pc=0x08C4
    lw x10, -4(x17) ; base ref v                        ; pc=0x08C8
    add x10, x10, x9                                    ; pc=0x08CC
    sw x3, 0(x10)                                       ; pc=0x08D0
    addi x7, x0, 1                                      ; pc=0x08D4
    add x6, x7, x7                                      ; pc=0x08D8
    add x6, x6, x6                                      ; pc=0x08DC
    lw x5, -4(x17) ; base ref v                         ; pc=0x08E0
    add x5, x5, x6                                      ; pc=0x08E4
    sw x4, 0(x5)                                        ; pc=0x08E8
.L_ir_17_tea_decrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x08EC
    lw x17, 4(x2)                                       ; pc=0x08F0
    addi x2, x2, 140                                    ; pc=0x08F4
    jalr x1, 0                                          ; pc=0x08F8