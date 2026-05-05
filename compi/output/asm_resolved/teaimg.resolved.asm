; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0020
;   main = 0x0020
;   .L4_for_start = 0x007C
;   .L5_for_end = 0x0504
;   .L6_for_start = 0x0518
;   .L7_for_end = 0x09A0
;   .L8_for_start = 0x09C8
;   .L10_if_else = 0x0B38
;   .L11_if_end = 0x0B38
;   .L12_if_else = 0x0C44
;   .L13_if_end = 0x0C44
;   .L9_for_end = 0x0C84
;   .L14_if_else = 0x0CE8
;   .L15_if_end = 0x0CE8
;   .L_codegen_1_main_end = 0x0D14
;   tea_encrypt = 0x0D38
;   .L0_for_start = 0x0E58
;   .L1_for_end = 0x12F8
;   .L_codegen_2_tea_encrypt_end = 0x13C0
;   tea_decrypt = 0x13FC
;   .L2_for_start = 0x153C
;   .L3_for_end = 0x19DC
;   .L_codegen_3_tea_decrypt_end = 0x1AA4

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0020, offset=32)
;   pc=0x00BC bge -> .L5_for_end (addr=0x0504, offset=1096)
;   pc=0x02F0 jal -> tea_encrypt (addr=0x0D38, offset=2632)
;   pc=0x04F8 jal -> .L4_for_start (addr=0x007C, offset=-1148)
;   pc=0x0558 bge -> .L7_for_end (addr=0x09A0, offset=1096)
;   pc=0x078C jal -> tea_decrypt (addr=0x13FC, offset=3184)
;   pc=0x0994 jal -> .L6_for_start (addr=0x0518, offset=-1148)
;   pc=0x0A08 bge -> .L9_for_end (addr=0x0C84, offset=636)
;   pc=0x0AF4 beq -> .L10_if_else (addr=0x0B38, offset=68)
;   pc=0x0B20 jal -> .L_codegen_1_main_end (addr=0x0D14, offset=500)
;   pc=0x0B2C jal -> .L11_if_end (addr=0x0B38, offset=12)
;   pc=0x0C18 beq -> .L12_if_else (addr=0x0C44, offset=44)
;   pc=0x0C38 jal -> .L13_if_end (addr=0x0C44, offset=12)
;   pc=0x0C78 jal -> .L8_for_start (addr=0x09C8, offset=-688)
;   pc=0x0CA4 bne -> .L14_if_else (addr=0x0CE8, offset=68)
;   pc=0x0CD0 jal -> .L_codegen_1_main_end (addr=0x0D14, offset=68)
;   pc=0x0CDC jal -> .L15_if_end (addr=0x0CE8, offset=12)
;   pc=0x0D08 jal -> .L_codegen_1_main_end (addr=0x0D14, offset=12)
;   pc=0x0E78 bge -> .L1_for_end (addr=0x12F8, offset=1152)
;   pc=0x12EC jal -> .L0_for_start (addr=0x0E58, offset=-1172)
;   pc=0x155C bge -> .L3_for_end (addr=0x19DC, offset=1152)
;   pc=0x19D0 jal -> .L2_for_start (addr=0x153C, offset=-1172)

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
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
image_encrypted: ; addr=0xA958
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
image_decrypted: ; addr=0xD2A0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
block: ; addr=0xFBE8
    .word 0
    .word 0
DELTA: ; addr=0xFBF0
    .word 0x9E3779B9
SUM_INIT: ; addr=0xFBF4
    .word 0xC6EF3720
IMAGE_WORDS: ; addr=0xFBF8
    .word 0xA52

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
    addiSigned x2, x2, -28                              ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x1, 0(x2)                                        ; pc=0x0050
    sw x17, 4(x2)                                       ; pc=0x0054
    addi x17, x2, 28                                    ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064


    ; for
    addi x3, x0, 0                                      ; pc=0x0068
    sleep ; stall RAW                                   ; pc=0x006C
    sleep ; stall RAW                                   ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sw x3, -4(x17) ; offset                             ; pc=0x0078
.L4_for_start:
    lw x3, -4(x17) ; offset                             ; pc=0x007C
    sleep ; stall RAW                                   ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    addiHIGH x5, x0, 0                                  ; pc=0x008C
    sleep ; stall RAW                                   ; pc=0x0090
    sleep ; stall RAW                                   ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    addi x5, x5, 64504                                  ; pc=0x009C
    sleep ; stall RAW                                   ; pc=0x00A0
    sleep ; stall RAW                                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    lw x4, 0(x5) ; IMAGE_WORDS                          ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    sleep ; stall RAW                                   ; pc=0x00B4
    sleep ; stall RAW                                   ; pc=0x00B8
    bge x3, x4, 1096                                    ; pc=0x00BC ; target=.L5_for_end ; addr=0x0504
    sleep ; nop despues de control                      ; pc=0x00C0
    sleep ; nop despues de control                      ; pc=0x00C4
    lw x4, -4(x17) ; offset                             ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    add x3, x4, x4                                      ; pc=0x00D8
    sleep ; stall RAW                                   ; pc=0x00DC
    sleep ; stall RAW                                   ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    add x3, x3, x3                                      ; pc=0x00E8
    sleep ; stall RAW                                   ; pc=0x00EC
    sleep ; stall RAW                                   ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    addiHIGH x5, x0, 0                                  ; pc=0x00F8
    sleep ; stall RAW                                   ; pc=0x00FC
    sleep ; stall RAW                                   ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    addi x5, x5, 32784                                  ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    sleep ; stall RAW                                   ; pc=0x0110
    sleep ; stall RAW                                   ; pc=0x0114
    ; base image_original
    add x5, x5, x3                                      ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    sleep ; stall RAW                                   ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    lw x3, 0(x5)                                        ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    sleep ; stall RAW                                   ; pc=0x0130
    sleep ; stall RAW                                   ; pc=0x0134
    addi x5, x0, 0                                      ; pc=0x0138
    sleep ; stall RAW                                   ; pc=0x013C
    sleep ; stall RAW                                   ; pc=0x0140
    sleep ; stall RAW                                   ; pc=0x0144
    add x4, x5, x5                                      ; pc=0x0148
    sleep ; stall RAW                                   ; pc=0x014C
    sleep ; stall RAW                                   ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    add x4, x4, x4                                      ; pc=0x0158
    sleep ; stall RAW                                   ; pc=0x015C
    sleep ; stall RAW                                   ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    addiHIGH x6, x0, 0                                  ; pc=0x0168
    sleep ; stall RAW                                   ; pc=0x016C
    sleep ; stall RAW                                   ; pc=0x0170
    sleep ; stall RAW                                   ; pc=0x0174
    addi x6, x6, 64488                                  ; pc=0x0178
    sleep ; stall RAW                                   ; pc=0x017C
    sleep ; stall RAW                                   ; pc=0x0180
    sleep ; stall RAW                                   ; pc=0x0184
    ; base block
    add x6, x6, x4                                      ; pc=0x0188
    sleep ; stall RAW                                   ; pc=0x018C
    sleep ; stall RAW                                   ; pc=0x0190
    sleep ; stall RAW                                   ; pc=0x0194
    sw x3, 0(x6)                                        ; pc=0x0198
    lw x3, -4(x17) ; offset                             ; pc=0x019C
    sleep ; stall RAW                                   ; pc=0x01A0
    sleep ; stall RAW                                   ; pc=0x01A4
    sleep ; stall RAW                                   ; pc=0x01A8
    addi x6, x0, 1                                      ; pc=0x01AC
    sleep ; stall RAW                                   ; pc=0x01B0
    sleep ; stall RAW                                   ; pc=0x01B4
    sleep ; stall RAW                                   ; pc=0x01B8
    add x4, x3, x6                                      ; pc=0x01BC
    sleep ; stall RAW                                   ; pc=0x01C0
    sleep ; stall RAW                                   ; pc=0x01C4
    sleep ; stall RAW                                   ; pc=0x01C8
    add x6, x4, x4                                      ; pc=0x01CC
    sleep ; stall RAW                                   ; pc=0x01D0
    sleep ; stall RAW                                   ; pc=0x01D4
    sleep ; stall RAW                                   ; pc=0x01D8
    add x6, x6, x6                                      ; pc=0x01DC
    sleep ; stall RAW                                   ; pc=0x01E0
    sleep ; stall RAW                                   ; pc=0x01E4
    sleep ; stall RAW                                   ; pc=0x01E8
    addiHIGH x3, x0, 0                                  ; pc=0x01EC
    sleep ; stall RAW                                   ; pc=0x01F0
    sleep ; stall RAW                                   ; pc=0x01F4
    sleep ; stall RAW                                   ; pc=0x01F8
    addi x3, x3, 32784                                  ; pc=0x01FC
    sleep ; stall RAW                                   ; pc=0x0200
    sleep ; stall RAW                                   ; pc=0x0204
    sleep ; stall RAW                                   ; pc=0x0208
    ; base image_original
    add x3, x3, x6                                      ; pc=0x020C
    sleep ; stall RAW                                   ; pc=0x0210
    sleep ; stall RAW                                   ; pc=0x0214
    sleep ; stall RAW                                   ; pc=0x0218
    lw x6, 0(x3)                                        ; pc=0x021C
    sleep ; stall RAW                                   ; pc=0x0220
    sleep ; stall RAW                                   ; pc=0x0224
    sleep ; stall RAW                                   ; pc=0x0228
    addi x3, x0, 1                                      ; pc=0x022C
    sleep ; stall RAW                                   ; pc=0x0230
    sleep ; stall RAW                                   ; pc=0x0234
    sleep ; stall RAW                                   ; pc=0x0238
    add x4, x3, x3                                      ; pc=0x023C
    sleep ; stall RAW                                   ; pc=0x0240
    sleep ; stall RAW                                   ; pc=0x0244
    sleep ; stall RAW                                   ; pc=0x0248
    add x4, x4, x4                                      ; pc=0x024C
    sleep ; stall RAW                                   ; pc=0x0250
    sleep ; stall RAW                                   ; pc=0x0254
    sleep ; stall RAW                                   ; pc=0x0258
    addiHIGH x5, x0, 0                                  ; pc=0x025C
    sleep ; stall RAW                                   ; pc=0x0260
    sleep ; stall RAW                                   ; pc=0x0264
    sleep ; stall RAW                                   ; pc=0x0268
    addi x5, x5, 64488                                  ; pc=0x026C
    sleep ; stall RAW                                   ; pc=0x0270
    sleep ; stall RAW                                   ; pc=0x0274
    sleep ; stall RAW                                   ; pc=0x0278
    ; base block
    add x5, x5, x4                                      ; pc=0x027C
    sleep ; stall RAW                                   ; pc=0x0280
    sleep ; stall RAW                                   ; pc=0x0284
    sleep ; stall RAW                                   ; pc=0x0288
    sw x6, 0(x5)                                        ; pc=0x028C
    addiHIGH x6, x0, 0                                  ; pc=0x0290
    sleep ; stall RAW                                   ; pc=0x0294
    sleep ; stall RAW                                   ; pc=0x0298
    sleep ; stall RAW                                   ; pc=0x029C
    addi x6, x6, 64488                                  ; pc=0x02A0
    sleep ; stall RAW                                   ; pc=0x02A4
    sleep ; stall RAW                                   ; pc=0x02A8
    sleep ; stall RAW                                   ; pc=0x02AC
    ; base block
    add x11, x6, x0                                     ; pc=0x02B0
    sleep ; stall RAW                                   ; pc=0x02B4
    sleep ; stall RAW                                   ; pc=0x02B8
    sleep ; stall RAW                                   ; pc=0x02BC
    addiHIGH x6, x0, 0                                  ; pc=0x02C0
    sleep ; stall RAW                                   ; pc=0x02C4
    sleep ; stall RAW                                   ; pc=0x02C8
    sleep ; stall RAW                                   ; pc=0x02CC
    addi x6, x6, 32768                                  ; pc=0x02D0
    sleep ; stall RAW                                   ; pc=0x02D4
    sleep ; stall RAW                                   ; pc=0x02D8
    sleep ; stall RAW                                   ; pc=0x02DC
    ; base key
    add x12, x6, x0                                     ; pc=0x02E0
    sleep ; stall RAW                                   ; pc=0x02E4
    sleep ; stall RAW                                   ; pc=0x02E8
    sleep ; stall RAW                                   ; pc=0x02EC
    jal x1, 2632                                        ; pc=0x02F0 ; target=tea_encrypt ; addr=0x0D38
    sleep ; nop despues de control                      ; pc=0x02F4
    sleep ; nop despues de control                      ; pc=0x02F8
    addi x6, x0, 0                                      ; pc=0x02FC
    sleep ; stall RAW                                   ; pc=0x0300
    sleep ; stall RAW                                   ; pc=0x0304
    sleep ; stall RAW                                   ; pc=0x0308
    add x5, x6, x6                                      ; pc=0x030C
    sleep ; stall RAW                                   ; pc=0x0310
    sleep ; stall RAW                                   ; pc=0x0314
    sleep ; stall RAW                                   ; pc=0x0318
    add x5, x5, x5                                      ; pc=0x031C
    sleep ; stall RAW                                   ; pc=0x0320
    sleep ; stall RAW                                   ; pc=0x0324
    sleep ; stall RAW                                   ; pc=0x0328
    addiHIGH x4, x0, 0                                  ; pc=0x032C
    sleep ; stall RAW                                   ; pc=0x0330
    sleep ; stall RAW                                   ; pc=0x0334
    sleep ; stall RAW                                   ; pc=0x0338
    addi x4, x4, 64488                                  ; pc=0x033C
    sleep ; stall RAW                                   ; pc=0x0340
    sleep ; stall RAW                                   ; pc=0x0344
    sleep ; stall RAW                                   ; pc=0x0348
    ; base block
    add x4, x4, x5                                      ; pc=0x034C
    sleep ; stall RAW                                   ; pc=0x0350
    sleep ; stall RAW                                   ; pc=0x0354
    sleep ; stall RAW                                   ; pc=0x0358
    lw x5, 0(x4)                                        ; pc=0x035C
    sleep ; stall RAW                                   ; pc=0x0360
    sleep ; stall RAW                                   ; pc=0x0364
    sleep ; stall RAW                                   ; pc=0x0368
    lw x4, -4(x17) ; offset                             ; pc=0x036C
    sleep ; stall RAW                                   ; pc=0x0370
    sleep ; stall RAW                                   ; pc=0x0374
    sleep ; stall RAW                                   ; pc=0x0378
    add x6, x4, x4                                      ; pc=0x037C
    sleep ; stall RAW                                   ; pc=0x0380
    sleep ; stall RAW                                   ; pc=0x0384
    sleep ; stall RAW                                   ; pc=0x0388
    add x6, x6, x6                                      ; pc=0x038C
    sleep ; stall RAW                                   ; pc=0x0390
    sleep ; stall RAW                                   ; pc=0x0394
    sleep ; stall RAW                                   ; pc=0x0398
    addiHIGH x3, x0, 0                                  ; pc=0x039C
    sleep ; stall RAW                                   ; pc=0x03A0
    sleep ; stall RAW                                   ; pc=0x03A4
    sleep ; stall RAW                                   ; pc=0x03A8
    addi x3, x3, 43352                                  ; pc=0x03AC
    sleep ; stall RAW                                   ; pc=0x03B0
    sleep ; stall RAW                                   ; pc=0x03B4
    sleep ; stall RAW                                   ; pc=0x03B8
    ; base image_encrypted
    add x3, x3, x6                                      ; pc=0x03BC
    sleep ; stall RAW                                   ; pc=0x03C0
    sleep ; stall RAW                                   ; pc=0x03C4
    sleep ; stall RAW                                   ; pc=0x03C8
    sw x5, 0(x3)                                        ; pc=0x03CC
    addi x5, x0, 1                                      ; pc=0x03D0
    sleep ; stall RAW                                   ; pc=0x03D4
    sleep ; stall RAW                                   ; pc=0x03D8
    sleep ; stall RAW                                   ; pc=0x03DC
    add x3, x5, x5                                      ; pc=0x03E0
    sleep ; stall RAW                                   ; pc=0x03E4
    sleep ; stall RAW                                   ; pc=0x03E8
    sleep ; stall RAW                                   ; pc=0x03EC
    add x3, x3, x3                                      ; pc=0x03F0
    sleep ; stall RAW                                   ; pc=0x03F4
    sleep ; stall RAW                                   ; pc=0x03F8
    sleep ; stall RAW                                   ; pc=0x03FC
    addiHIGH x6, x0, 0                                  ; pc=0x0400
    sleep ; stall RAW                                   ; pc=0x0404
    sleep ; stall RAW                                   ; pc=0x0408
    sleep ; stall RAW                                   ; pc=0x040C
    addi x6, x6, 64488                                  ; pc=0x0410
    sleep ; stall RAW                                   ; pc=0x0414
    sleep ; stall RAW                                   ; pc=0x0418
    sleep ; stall RAW                                   ; pc=0x041C
    ; base block
    add x6, x6, x3                                      ; pc=0x0420
    sleep ; stall RAW                                   ; pc=0x0424
    sleep ; stall RAW                                   ; pc=0x0428
    sleep ; stall RAW                                   ; pc=0x042C
    lw x3, 0(x6)                                        ; pc=0x0430
    sleep ; stall RAW                                   ; pc=0x0434
    sleep ; stall RAW                                   ; pc=0x0438
    sleep ; stall RAW                                   ; pc=0x043C
    lw x6, -4(x17) ; offset                             ; pc=0x0440
    sleep ; stall RAW                                   ; pc=0x0444
    sleep ; stall RAW                                   ; pc=0x0448
    sleep ; stall RAW                                   ; pc=0x044C
    addi x5, x0, 1                                      ; pc=0x0450
    sleep ; stall RAW                                   ; pc=0x0454
    sleep ; stall RAW                                   ; pc=0x0458
    sleep ; stall RAW                                   ; pc=0x045C
    add x4, x6, x5                                      ; pc=0x0460
    sleep ; stall RAW                                   ; pc=0x0464
    sleep ; stall RAW                                   ; pc=0x0468
    sleep ; stall RAW                                   ; pc=0x046C
    add x5, x4, x4                                      ; pc=0x0470
    sleep ; stall RAW                                   ; pc=0x0474
    sleep ; stall RAW                                   ; pc=0x0478
    sleep ; stall RAW                                   ; pc=0x047C
    add x5, x5, x5                                      ; pc=0x0480
    sleep ; stall RAW                                   ; pc=0x0484
    sleep ; stall RAW                                   ; pc=0x0488
    sleep ; stall RAW                                   ; pc=0x048C
    addiHIGH x6, x0, 0                                  ; pc=0x0490
    sleep ; stall RAW                                   ; pc=0x0494
    sleep ; stall RAW                                   ; pc=0x0498
    sleep ; stall RAW                                   ; pc=0x049C
    addi x6, x6, 43352                                  ; pc=0x04A0
    sleep ; stall RAW                                   ; pc=0x04A4
    sleep ; stall RAW                                   ; pc=0x04A8
    sleep ; stall RAW                                   ; pc=0x04AC
    ; base image_encrypted
    add x6, x6, x5                                      ; pc=0x04B0
    sleep ; stall RAW                                   ; pc=0x04B4
    sleep ; stall RAW                                   ; pc=0x04B8
    sleep ; stall RAW                                   ; pc=0x04BC
    sw x3, 0(x6)                                        ; pc=0x04C0
    lw x3, -4(x17) ; offset                             ; pc=0x04C4
    sleep ; stall RAW                                   ; pc=0x04C8
    sleep ; stall RAW                                   ; pc=0x04CC
    sleep ; stall RAW                                   ; pc=0x04D0
    addi x6, x0, 2                                      ; pc=0x04D4
    sleep ; stall RAW                                   ; pc=0x04D8
    sleep ; stall RAW                                   ; pc=0x04DC
    sleep ; stall RAW                                   ; pc=0x04E0
    add x5, x3, x6                                      ; pc=0x04E4
    sleep ; stall RAW                                   ; pc=0x04E8
    sleep ; stall RAW                                   ; pc=0x04EC
    sleep ; stall RAW                                   ; pc=0x04F0
    sw x5, -4(x17) ; offset                             ; pc=0x04F4
    jal x0, -1148                                       ; pc=0x04F8 ; target=.L4_for_start ; addr=0x007C
    sleep ; nop despues de control                      ; pc=0x04FC
    sleep ; nop despues de control                      ; pc=0x0500
.L5_for_end:


    ; for
    addi x5, x0, 0                                      ; pc=0x0504
    sleep ; stall RAW                                   ; pc=0x0508
    sleep ; stall RAW                                   ; pc=0x050C
    sleep ; stall RAW                                   ; pc=0x0510
    sw x5, -8(x17) ; offset2                            ; pc=0x0514
.L6_for_start:
    lw x5, -8(x17) ; offset2                            ; pc=0x0518
    sleep ; stall RAW                                   ; pc=0x051C
    sleep ; stall RAW                                   ; pc=0x0520
    sleep ; stall RAW                                   ; pc=0x0524
    addiHIGH x3, x0, 0                                  ; pc=0x0528
    sleep ; stall RAW                                   ; pc=0x052C
    sleep ; stall RAW                                   ; pc=0x0530
    sleep ; stall RAW                                   ; pc=0x0534
    addi x3, x3, 64504                                  ; pc=0x0538
    sleep ; stall RAW                                   ; pc=0x053C
    sleep ; stall RAW                                   ; pc=0x0540
    sleep ; stall RAW                                   ; pc=0x0544
    lw x6, 0(x3) ; IMAGE_WORDS                          ; pc=0x0548
    sleep ; stall RAW                                   ; pc=0x054C
    sleep ; stall RAW                                   ; pc=0x0550
    sleep ; stall RAW                                   ; pc=0x0554
    bge x5, x6, 1096                                    ; pc=0x0558 ; target=.L7_for_end ; addr=0x09A0
    sleep ; nop despues de control                      ; pc=0x055C
    sleep ; nop despues de control                      ; pc=0x0560
    lw x6, -8(x17) ; offset2                            ; pc=0x0564
    sleep ; stall RAW                                   ; pc=0x0568
    sleep ; stall RAW                                   ; pc=0x056C
    sleep ; stall RAW                                   ; pc=0x0570
    add x5, x6, x6                                      ; pc=0x0574
    sleep ; stall RAW                                   ; pc=0x0578
    sleep ; stall RAW                                   ; pc=0x057C
    sleep ; stall RAW                                   ; pc=0x0580
    add x5, x5, x5                                      ; pc=0x0584
    sleep ; stall RAW                                   ; pc=0x0588
    sleep ; stall RAW                                   ; pc=0x058C
    sleep ; stall RAW                                   ; pc=0x0590
    addiHIGH x3, x0, 0                                  ; pc=0x0594
    sleep ; stall RAW                                   ; pc=0x0598
    sleep ; stall RAW                                   ; pc=0x059C
    sleep ; stall RAW                                   ; pc=0x05A0
    addi x3, x3, 43352                                  ; pc=0x05A4
    sleep ; stall RAW                                   ; pc=0x05A8
    sleep ; stall RAW                                   ; pc=0x05AC
    sleep ; stall RAW                                   ; pc=0x05B0
    ; base image_encrypted
    add x3, x3, x5                                      ; pc=0x05B4
    sleep ; stall RAW                                   ; pc=0x05B8
    sleep ; stall RAW                                   ; pc=0x05BC
    sleep ; stall RAW                                   ; pc=0x05C0
    lw x5, 0(x3)                                        ; pc=0x05C4
    sleep ; stall RAW                                   ; pc=0x05C8
    sleep ; stall RAW                                   ; pc=0x05CC
    sleep ; stall RAW                                   ; pc=0x05D0
    addi x3, x0, 0                                      ; pc=0x05D4
    sleep ; stall RAW                                   ; pc=0x05D8
    sleep ; stall RAW                                   ; pc=0x05DC
    sleep ; stall RAW                                   ; pc=0x05E0
    add x6, x3, x3                                      ; pc=0x05E4
    sleep ; stall RAW                                   ; pc=0x05E8
    sleep ; stall RAW                                   ; pc=0x05EC
    sleep ; stall RAW                                   ; pc=0x05F0
    add x6, x6, x6                                      ; pc=0x05F4
    sleep ; stall RAW                                   ; pc=0x05F8
    sleep ; stall RAW                                   ; pc=0x05FC
    sleep ; stall RAW                                   ; pc=0x0600
    addiHIGH x4, x0, 0                                  ; pc=0x0604
    sleep ; stall RAW                                   ; pc=0x0608
    sleep ; stall RAW                                   ; pc=0x060C
    sleep ; stall RAW                                   ; pc=0x0610
    addi x4, x4, 64488                                  ; pc=0x0614
    sleep ; stall RAW                                   ; pc=0x0618
    sleep ; stall RAW                                   ; pc=0x061C
    sleep ; stall RAW                                   ; pc=0x0620
    ; base block
    add x4, x4, x6                                      ; pc=0x0624
    sleep ; stall RAW                                   ; pc=0x0628
    sleep ; stall RAW                                   ; pc=0x062C
    sleep ; stall RAW                                   ; pc=0x0630
    sw x5, 0(x4)                                        ; pc=0x0634
    lw x5, -8(x17) ; offset2                            ; pc=0x0638
    sleep ; stall RAW                                   ; pc=0x063C
    sleep ; stall RAW                                   ; pc=0x0640
    sleep ; stall RAW                                   ; pc=0x0644
    addi x4, x0, 1                                      ; pc=0x0648
    sleep ; stall RAW                                   ; pc=0x064C
    sleep ; stall RAW                                   ; pc=0x0650
    sleep ; stall RAW                                   ; pc=0x0654
    add x6, x5, x4                                      ; pc=0x0658
    sleep ; stall RAW                                   ; pc=0x065C
    sleep ; stall RAW                                   ; pc=0x0660
    sleep ; stall RAW                                   ; pc=0x0664
    add x4, x6, x6                                      ; pc=0x0668
    sleep ; stall RAW                                   ; pc=0x066C
    sleep ; stall RAW                                   ; pc=0x0670
    sleep ; stall RAW                                   ; pc=0x0674
    add x4, x4, x4                                      ; pc=0x0678
    sleep ; stall RAW                                   ; pc=0x067C
    sleep ; stall RAW                                   ; pc=0x0680
    sleep ; stall RAW                                   ; pc=0x0684
    addiHIGH x5, x0, 0                                  ; pc=0x0688
    sleep ; stall RAW                                   ; pc=0x068C
    sleep ; stall RAW                                   ; pc=0x0690
    sleep ; stall RAW                                   ; pc=0x0694
    addi x5, x5, 43352                                  ; pc=0x0698
    sleep ; stall RAW                                   ; pc=0x069C
    sleep ; stall RAW                                   ; pc=0x06A0
    sleep ; stall RAW                                   ; pc=0x06A4
    ; base image_encrypted
    add x5, x5, x4                                      ; pc=0x06A8
    sleep ; stall RAW                                   ; pc=0x06AC
    sleep ; stall RAW                                   ; pc=0x06B0
    sleep ; stall RAW                                   ; pc=0x06B4
    lw x4, 0(x5)                                        ; pc=0x06B8
    sleep ; stall RAW                                   ; pc=0x06BC
    sleep ; stall RAW                                   ; pc=0x06C0
    sleep ; stall RAW                                   ; pc=0x06C4
    addi x5, x0, 1                                      ; pc=0x06C8
    sleep ; stall RAW                                   ; pc=0x06CC
    sleep ; stall RAW                                   ; pc=0x06D0
    sleep ; stall RAW                                   ; pc=0x06D4
    add x6, x5, x5                                      ; pc=0x06D8
    sleep ; stall RAW                                   ; pc=0x06DC
    sleep ; stall RAW                                   ; pc=0x06E0
    sleep ; stall RAW                                   ; pc=0x06E4
    add x6, x6, x6                                      ; pc=0x06E8
    sleep ; stall RAW                                   ; pc=0x06EC
    sleep ; stall RAW                                   ; pc=0x06F0
    sleep ; stall RAW                                   ; pc=0x06F4
    addiHIGH x3, x0, 0                                  ; pc=0x06F8
    sleep ; stall RAW                                   ; pc=0x06FC
    sleep ; stall RAW                                   ; pc=0x0700
    sleep ; stall RAW                                   ; pc=0x0704
    addi x3, x3, 64488                                  ; pc=0x0708
    sleep ; stall RAW                                   ; pc=0x070C
    sleep ; stall RAW                                   ; pc=0x0710
    sleep ; stall RAW                                   ; pc=0x0714
    ; base block
    add x3, x3, x6                                      ; pc=0x0718
    sleep ; stall RAW                                   ; pc=0x071C
    sleep ; stall RAW                                   ; pc=0x0720
    sleep ; stall RAW                                   ; pc=0x0724
    sw x4, 0(x3)                                        ; pc=0x0728
    addiHIGH x4, x0, 0                                  ; pc=0x072C
    sleep ; stall RAW                                   ; pc=0x0730
    sleep ; stall RAW                                   ; pc=0x0734
    sleep ; stall RAW                                   ; pc=0x0738
    addi x4, x4, 64488                                  ; pc=0x073C
    sleep ; stall RAW                                   ; pc=0x0740
    sleep ; stall RAW                                   ; pc=0x0744
    sleep ; stall RAW                                   ; pc=0x0748
    ; base block
    add x11, x4, x0                                     ; pc=0x074C
    sleep ; stall RAW                                   ; pc=0x0750
    sleep ; stall RAW                                   ; pc=0x0754
    sleep ; stall RAW                                   ; pc=0x0758
    addiHIGH x4, x0, 0                                  ; pc=0x075C
    sleep ; stall RAW                                   ; pc=0x0760
    sleep ; stall RAW                                   ; pc=0x0764
    sleep ; stall RAW                                   ; pc=0x0768
    addi x4, x4, 32768                                  ; pc=0x076C
    sleep ; stall RAW                                   ; pc=0x0770
    sleep ; stall RAW                                   ; pc=0x0774
    sleep ; stall RAW                                   ; pc=0x0778
    ; base key
    add x12, x4, x0                                     ; pc=0x077C
    sleep ; stall RAW                                   ; pc=0x0780
    sleep ; stall RAW                                   ; pc=0x0784
    sleep ; stall RAW                                   ; pc=0x0788
    jal x1, 3184                                        ; pc=0x078C ; target=tea_decrypt ; addr=0x13FC
    sleep ; nop despues de control                      ; pc=0x0790
    sleep ; nop despues de control                      ; pc=0x0794
    addi x4, x0, 0                                      ; pc=0x0798
    sleep ; stall RAW                                   ; pc=0x079C
    sleep ; stall RAW                                   ; pc=0x07A0
    sleep ; stall RAW                                   ; pc=0x07A4
    add x3, x4, x4                                      ; pc=0x07A8
    sleep ; stall RAW                                   ; pc=0x07AC
    sleep ; stall RAW                                   ; pc=0x07B0
    sleep ; stall RAW                                   ; pc=0x07B4
    add x3, x3, x3                                      ; pc=0x07B8
    sleep ; stall RAW                                   ; pc=0x07BC
    sleep ; stall RAW                                   ; pc=0x07C0
    sleep ; stall RAW                                   ; pc=0x07C4
    addiHIGH x6, x0, 0                                  ; pc=0x07C8
    sleep ; stall RAW                                   ; pc=0x07CC
    sleep ; stall RAW                                   ; pc=0x07D0
    sleep ; stall RAW                                   ; pc=0x07D4
    addi x6, x6, 64488                                  ; pc=0x07D8
    sleep ; stall RAW                                   ; pc=0x07DC
    sleep ; stall RAW                                   ; pc=0x07E0
    sleep ; stall RAW                                   ; pc=0x07E4
    ; base block
    add x6, x6, x3                                      ; pc=0x07E8
    sleep ; stall RAW                                   ; pc=0x07EC
    sleep ; stall RAW                                   ; pc=0x07F0
    sleep ; stall RAW                                   ; pc=0x07F4
    lw x3, 0(x6)                                        ; pc=0x07F8
    sleep ; stall RAW                                   ; pc=0x07FC
    sleep ; stall RAW                                   ; pc=0x0800
    sleep ; stall RAW                                   ; pc=0x0804
    lw x6, -8(x17) ; offset2                            ; pc=0x0808
    sleep ; stall RAW                                   ; pc=0x080C
    sleep ; stall RAW                                   ; pc=0x0810
    sleep ; stall RAW                                   ; pc=0x0814
    add x4, x6, x6                                      ; pc=0x0818
    sleep ; stall RAW                                   ; pc=0x081C
    sleep ; stall RAW                                   ; pc=0x0820
    sleep ; stall RAW                                   ; pc=0x0824
    add x4, x4, x4                                      ; pc=0x0828
    sleep ; stall RAW                                   ; pc=0x082C
    sleep ; stall RAW                                   ; pc=0x0830
    sleep ; stall RAW                                   ; pc=0x0834
    addiHIGH x5, x0, 0                                  ; pc=0x0838
    sleep ; stall RAW                                   ; pc=0x083C
    sleep ; stall RAW                                   ; pc=0x0840
    sleep ; stall RAW                                   ; pc=0x0844
    addi x5, x5, 53920                                  ; pc=0x0848
    sleep ; stall RAW                                   ; pc=0x084C
    sleep ; stall RAW                                   ; pc=0x0850
    sleep ; stall RAW                                   ; pc=0x0854
    ; base image_decrypted
    add x5, x5, x4                                      ; pc=0x0858
    sleep ; stall RAW                                   ; pc=0x085C
    sleep ; stall RAW                                   ; pc=0x0860
    sleep ; stall RAW                                   ; pc=0x0864
    sw x3, 0(x5)                                        ; pc=0x0868
    addi x3, x0, 1                                      ; pc=0x086C
    sleep ; stall RAW                                   ; pc=0x0870
    sleep ; stall RAW                                   ; pc=0x0874
    sleep ; stall RAW                                   ; pc=0x0878
    add x5, x3, x3                                      ; pc=0x087C
    sleep ; stall RAW                                   ; pc=0x0880
    sleep ; stall RAW                                   ; pc=0x0884
    sleep ; stall RAW                                   ; pc=0x0888
    add x5, x5, x5                                      ; pc=0x088C
    sleep ; stall RAW                                   ; pc=0x0890
    sleep ; stall RAW                                   ; pc=0x0894
    sleep ; stall RAW                                   ; pc=0x0898
    addiHIGH x4, x0, 0                                  ; pc=0x089C
    sleep ; stall RAW                                   ; pc=0x08A0
    sleep ; stall RAW                                   ; pc=0x08A4
    sleep ; stall RAW                                   ; pc=0x08A8
    addi x4, x4, 64488                                  ; pc=0x08AC
    sleep ; stall RAW                                   ; pc=0x08B0
    sleep ; stall RAW                                   ; pc=0x08B4
    sleep ; stall RAW                                   ; pc=0x08B8
    ; base block
    add x4, x4, x5                                      ; pc=0x08BC
    sleep ; stall RAW                                   ; pc=0x08C0
    sleep ; stall RAW                                   ; pc=0x08C4
    sleep ; stall RAW                                   ; pc=0x08C8
    lw x5, 0(x4)                                        ; pc=0x08CC
    sleep ; stall RAW                                   ; pc=0x08D0
    sleep ; stall RAW                                   ; pc=0x08D4
    sleep ; stall RAW                                   ; pc=0x08D8
    lw x4, -8(x17) ; offset2                            ; pc=0x08DC
    sleep ; stall RAW                                   ; pc=0x08E0
    sleep ; stall RAW                                   ; pc=0x08E4
    sleep ; stall RAW                                   ; pc=0x08E8
    addi x3, x0, 1                                      ; pc=0x08EC
    sleep ; stall RAW                                   ; pc=0x08F0
    sleep ; stall RAW                                   ; pc=0x08F4
    sleep ; stall RAW                                   ; pc=0x08F8
    add x6, x4, x3                                      ; pc=0x08FC
    sleep ; stall RAW                                   ; pc=0x0900
    sleep ; stall RAW                                   ; pc=0x0904
    sleep ; stall RAW                                   ; pc=0x0908
    add x3, x6, x6                                      ; pc=0x090C
    sleep ; stall RAW                                   ; pc=0x0910
    sleep ; stall RAW                                   ; pc=0x0914
    sleep ; stall RAW                                   ; pc=0x0918
    add x3, x3, x3                                      ; pc=0x091C
    sleep ; stall RAW                                   ; pc=0x0920
    sleep ; stall RAW                                   ; pc=0x0924
    sleep ; stall RAW                                   ; pc=0x0928
    addiHIGH x4, x0, 0                                  ; pc=0x092C
    sleep ; stall RAW                                   ; pc=0x0930
    sleep ; stall RAW                                   ; pc=0x0934
    sleep ; stall RAW                                   ; pc=0x0938
    addi x4, x4, 53920                                  ; pc=0x093C
    sleep ; stall RAW                                   ; pc=0x0940
    sleep ; stall RAW                                   ; pc=0x0944
    sleep ; stall RAW                                   ; pc=0x0948
    ; base image_decrypted
    add x4, x4, x3                                      ; pc=0x094C
    sleep ; stall RAW                                   ; pc=0x0950
    sleep ; stall RAW                                   ; pc=0x0954
    sleep ; stall RAW                                   ; pc=0x0958
    sw x5, 0(x4)                                        ; pc=0x095C
    lw x5, -8(x17) ; offset2                            ; pc=0x0960
    sleep ; stall RAW                                   ; pc=0x0964
    sleep ; stall RAW                                   ; pc=0x0968
    sleep ; stall RAW                                   ; pc=0x096C
    addi x4, x0, 2                                      ; pc=0x0970
    sleep ; stall RAW                                   ; pc=0x0974
    sleep ; stall RAW                                   ; pc=0x0978
    sleep ; stall RAW                                   ; pc=0x097C
    add x3, x5, x4                                      ; pc=0x0980
    sleep ; stall RAW                                   ; pc=0x0984
    sleep ; stall RAW                                   ; pc=0x0988
    sleep ; stall RAW                                   ; pc=0x098C
    sw x3, -8(x17) ; offset2                            ; pc=0x0990
    jal x0, -1148                                       ; pc=0x0994 ; target=.L6_for_start ; addr=0x0518
    sleep ; nop despues de control                      ; pc=0x0998
    sleep ; nop despues de control                      ; pc=0x099C
.L7_for_end:

    addi x3, x0, 0                                      ; pc=0x09A0
    sleep ; stall RAW                                   ; pc=0x09A4
    sleep ; stall RAW                                   ; pc=0x09A8
    sleep ; stall RAW                                   ; pc=0x09AC
    sw x3, -12(x17) ; changed                           ; pc=0x09B0

    ; for
    addi x3, x0, 0                                      ; pc=0x09B4
    sleep ; stall RAW                                   ; pc=0x09B8
    sleep ; stall RAW                                   ; pc=0x09BC
    sleep ; stall RAW                                   ; pc=0x09C0
    sw x3, -16(x17) ; check                             ; pc=0x09C4
.L8_for_start:
    lw x3, -16(x17) ; check                             ; pc=0x09C8
    sleep ; stall RAW                                   ; pc=0x09CC
    sleep ; stall RAW                                   ; pc=0x09D0
    sleep ; stall RAW                                   ; pc=0x09D4
    addiHIGH x5, x0, 0                                  ; pc=0x09D8
    sleep ; stall RAW                                   ; pc=0x09DC
    sleep ; stall RAW                                   ; pc=0x09E0
    sleep ; stall RAW                                   ; pc=0x09E4
    addi x5, x5, 64504                                  ; pc=0x09E8
    sleep ; stall RAW                                   ; pc=0x09EC
    sleep ; stall RAW                                   ; pc=0x09F0
    sleep ; stall RAW                                   ; pc=0x09F4
    lw x4, 0(x5) ; IMAGE_WORDS                          ; pc=0x09F8
    sleep ; stall RAW                                   ; pc=0x09FC
    sleep ; stall RAW                                   ; pc=0x0A00
    sleep ; stall RAW                                   ; pc=0x0A04
    bge x3, x4, 636                                     ; pc=0x0A08 ; target=.L9_for_end ; addr=0x0C84
    sleep ; nop despues de control                      ; pc=0x0A0C
    sleep ; nop despues de control                      ; pc=0x0A10

    ; if
    lw x4, -16(x17) ; check                             ; pc=0x0A14
    sleep ; stall RAW                                   ; pc=0x0A18
    sleep ; stall RAW                                   ; pc=0x0A1C
    sleep ; stall RAW                                   ; pc=0x0A20
    add x3, x4, x4                                      ; pc=0x0A24
    sleep ; stall RAW                                   ; pc=0x0A28
    sleep ; stall RAW                                   ; pc=0x0A2C
    sleep ; stall RAW                                   ; pc=0x0A30
    add x3, x3, x3                                      ; pc=0x0A34
    sleep ; stall RAW                                   ; pc=0x0A38
    sleep ; stall RAW                                   ; pc=0x0A3C
    sleep ; stall RAW                                   ; pc=0x0A40
    addiHIGH x5, x0, 0                                  ; pc=0x0A44
    sleep ; stall RAW                                   ; pc=0x0A48
    sleep ; stall RAW                                   ; pc=0x0A4C
    sleep ; stall RAW                                   ; pc=0x0A50
    addi x5, x5, 53920                                  ; pc=0x0A54
    sleep ; stall RAW                                   ; pc=0x0A58
    sleep ; stall RAW                                   ; pc=0x0A5C
    sleep ; stall RAW                                   ; pc=0x0A60
    ; base image_decrypted
    add x5, x5, x3                                      ; pc=0x0A64
    sleep ; stall RAW                                   ; pc=0x0A68
    sleep ; stall RAW                                   ; pc=0x0A6C
    sleep ; stall RAW                                   ; pc=0x0A70
    lw x3, 0(x5)                                        ; pc=0x0A74
    sleep ; stall RAW                                   ; pc=0x0A78
    sleep ; stall RAW                                   ; pc=0x0A7C
    sleep ; stall RAW                                   ; pc=0x0A80
    lw x5, -16(x17) ; check                             ; pc=0x0A84
    sleep ; stall RAW                                   ; pc=0x0A88
    sleep ; stall RAW                                   ; pc=0x0A8C
    sleep ; stall RAW                                   ; pc=0x0A90
    add x4, x5, x5                                      ; pc=0x0A94
    sleep ; stall RAW                                   ; pc=0x0A98
    sleep ; stall RAW                                   ; pc=0x0A9C
    sleep ; stall RAW                                   ; pc=0x0AA0
    add x4, x4, x4                                      ; pc=0x0AA4
    sleep ; stall RAW                                   ; pc=0x0AA8
    sleep ; stall RAW                                   ; pc=0x0AAC
    sleep ; stall RAW                                   ; pc=0x0AB0
    addiHIGH x6, x0, 0                                  ; pc=0x0AB4
    sleep ; stall RAW                                   ; pc=0x0AB8
    sleep ; stall RAW                                   ; pc=0x0ABC
    sleep ; stall RAW                                   ; pc=0x0AC0
    addi x6, x6, 32784                                  ; pc=0x0AC4
    sleep ; stall RAW                                   ; pc=0x0AC8
    sleep ; stall RAW                                   ; pc=0x0ACC
    sleep ; stall RAW                                   ; pc=0x0AD0
    ; base image_original
    add x6, x6, x4                                      ; pc=0x0AD4
    sleep ; stall RAW                                   ; pc=0x0AD8
    sleep ; stall RAW                                   ; pc=0x0ADC
    sleep ; stall RAW                                   ; pc=0x0AE0
    lw x4, 0(x6)                                        ; pc=0x0AE4
    sleep ; stall RAW                                   ; pc=0x0AE8
    sleep ; stall RAW                                   ; pc=0x0AEC
    sleep ; stall RAW                                   ; pc=0x0AF0
    beq x3, x4, 68                                      ; pc=0x0AF4 ; target=.L10_if_else ; addr=0x0B38
    sleep ; nop despues de control                      ; pc=0x0AF8
    sleep ; nop despues de control                      ; pc=0x0AFC
    addi x4, x0, 1                                      ; pc=0x0B00
    sleep ; stall RAW                                   ; pc=0x0B04
    sleep ; stall RAW                                   ; pc=0x0B08
    sleep ; stall RAW                                   ; pc=0x0B0C
    add x11, x4, x0                                     ; pc=0x0B10
    sleep ; stall RAW                                   ; pc=0x0B14
    sleep ; stall RAW                                   ; pc=0x0B18
    sleep ; stall RAW                                   ; pc=0x0B1C
    jal x0, 500                                         ; pc=0x0B20 ; target=.L_codegen_1_main_end ; addr=0x0D14
    sleep ; nop despues de control                      ; pc=0x0B24
    sleep ; nop despues de control                      ; pc=0x0B28
    jal x0, 12                                          ; pc=0x0B2C ; target=.L11_if_end ; addr=0x0B38
    sleep ; nop despues de control                      ; pc=0x0B30
    sleep ; nop despues de control                      ; pc=0x0B34
.L10_if_else:
.L11_if_end:


    ; if
    lw x4, -16(x17) ; check                             ; pc=0x0B38
    sleep ; stall RAW                                   ; pc=0x0B3C
    sleep ; stall RAW                                   ; pc=0x0B40
    sleep ; stall RAW                                   ; pc=0x0B44
    add x3, x4, x4                                      ; pc=0x0B48
    sleep ; stall RAW                                   ; pc=0x0B4C
    sleep ; stall RAW                                   ; pc=0x0B50
    sleep ; stall RAW                                   ; pc=0x0B54
    add x3, x3, x3                                      ; pc=0x0B58
    sleep ; stall RAW                                   ; pc=0x0B5C
    sleep ; stall RAW                                   ; pc=0x0B60
    sleep ; stall RAW                                   ; pc=0x0B64
    addiHIGH x6, x0, 0                                  ; pc=0x0B68
    sleep ; stall RAW                                   ; pc=0x0B6C
    sleep ; stall RAW                                   ; pc=0x0B70
    sleep ; stall RAW                                   ; pc=0x0B74
    addi x6, x6, 43352                                  ; pc=0x0B78
    sleep ; stall RAW                                   ; pc=0x0B7C
    sleep ; stall RAW                                   ; pc=0x0B80
    sleep ; stall RAW                                   ; pc=0x0B84
    ; base image_encrypted
    add x6, x6, x3                                      ; pc=0x0B88
    sleep ; stall RAW                                   ; pc=0x0B8C
    sleep ; stall RAW                                   ; pc=0x0B90
    sleep ; stall RAW                                   ; pc=0x0B94
    lw x3, 0(x6)                                        ; pc=0x0B98
    sleep ; stall RAW                                   ; pc=0x0B9C
    sleep ; stall RAW                                   ; pc=0x0BA0
    sleep ; stall RAW                                   ; pc=0x0BA4
    lw x6, -16(x17) ; check                             ; pc=0x0BA8
    sleep ; stall RAW                                   ; pc=0x0BAC
    sleep ; stall RAW                                   ; pc=0x0BB0
    sleep ; stall RAW                                   ; pc=0x0BB4
    add x4, x6, x6                                      ; pc=0x0BB8
    sleep ; stall RAW                                   ; pc=0x0BBC
    sleep ; stall RAW                                   ; pc=0x0BC0
    sleep ; stall RAW                                   ; pc=0x0BC4
    add x4, x4, x4                                      ; pc=0x0BC8
    sleep ; stall RAW                                   ; pc=0x0BCC
    sleep ; stall RAW                                   ; pc=0x0BD0
    sleep ; stall RAW                                   ; pc=0x0BD4
    addiHIGH x5, x0, 0                                  ; pc=0x0BD8
    sleep ; stall RAW                                   ; pc=0x0BDC
    sleep ; stall RAW                                   ; pc=0x0BE0
    sleep ; stall RAW                                   ; pc=0x0BE4
    addi x5, x5, 32784                                  ; pc=0x0BE8
    sleep ; stall RAW                                   ; pc=0x0BEC
    sleep ; stall RAW                                   ; pc=0x0BF0
    sleep ; stall RAW                                   ; pc=0x0BF4
    ; base image_original
    add x5, x5, x4                                      ; pc=0x0BF8
    sleep ; stall RAW                                   ; pc=0x0BFC
    sleep ; stall RAW                                   ; pc=0x0C00
    sleep ; stall RAW                                   ; pc=0x0C04
    lw x4, 0(x5)                                        ; pc=0x0C08
    sleep ; stall RAW                                   ; pc=0x0C0C
    sleep ; stall RAW                                   ; pc=0x0C10
    sleep ; stall RAW                                   ; pc=0x0C14
    beq x3, x4, 44                                      ; pc=0x0C18 ; target=.L12_if_else ; addr=0x0C44
    sleep ; nop despues de control                      ; pc=0x0C1C
    sleep ; nop despues de control                      ; pc=0x0C20
    addi x4, x0, 1                                      ; pc=0x0C24
    sleep ; stall RAW                                   ; pc=0x0C28
    sleep ; stall RAW                                   ; pc=0x0C2C
    sleep ; stall RAW                                   ; pc=0x0C30
    sw x4, -12(x17) ; changed                           ; pc=0x0C34
    jal x0, 12                                          ; pc=0x0C38 ; target=.L13_if_end ; addr=0x0C44
    sleep ; nop despues de control                      ; pc=0x0C3C
    sleep ; nop despues de control                      ; pc=0x0C40
.L12_if_else:
.L13_if_end:

    lw x4, -16(x17) ; check                             ; pc=0x0C44
    sleep ; stall RAW                                   ; pc=0x0C48
    sleep ; stall RAW                                   ; pc=0x0C4C
    sleep ; stall RAW                                   ; pc=0x0C50
    addi x3, x0, 1                                      ; pc=0x0C54
    sleep ; stall RAW                                   ; pc=0x0C58
    sleep ; stall RAW                                   ; pc=0x0C5C
    sleep ; stall RAW                                   ; pc=0x0C60
    add x5, x4, x3                                      ; pc=0x0C64
    sleep ; stall RAW                                   ; pc=0x0C68
    sleep ; stall RAW                                   ; pc=0x0C6C
    sleep ; stall RAW                                   ; pc=0x0C70
    sw x5, -16(x17) ; check                             ; pc=0x0C74
    jal x0, -688                                        ; pc=0x0C78 ; target=.L8_for_start ; addr=0x09C8
    sleep ; nop despues de control                      ; pc=0x0C7C
    sleep ; nop despues de control                      ; pc=0x0C80
.L9_for_end:


    ; if
    lw x5, -12(x17) ; changed                           ; pc=0x0C84
    sleep ; stall RAW                                   ; pc=0x0C88
    sleep ; stall RAW                                   ; pc=0x0C8C
    sleep ; stall RAW                                   ; pc=0x0C90
    addi x3, x0, 0                                      ; pc=0x0C94
    sleep ; stall RAW                                   ; pc=0x0C98
    sleep ; stall RAW                                   ; pc=0x0C9C
    sleep ; stall RAW                                   ; pc=0x0CA0
    bne x5, x3, 68                                      ; pc=0x0CA4 ; target=.L14_if_else ; addr=0x0CE8
    sleep ; nop despues de control                      ; pc=0x0CA8
    sleep ; nop despues de control                      ; pc=0x0CAC
    addi x3, x0, 2                                      ; pc=0x0CB0
    sleep ; stall RAW                                   ; pc=0x0CB4
    sleep ; stall RAW                                   ; pc=0x0CB8
    sleep ; stall RAW                                   ; pc=0x0CBC
    add x11, x3, x0                                     ; pc=0x0CC0
    sleep ; stall RAW                                   ; pc=0x0CC4
    sleep ; stall RAW                                   ; pc=0x0CC8
    sleep ; stall RAW                                   ; pc=0x0CCC
    jal x0, 68                                          ; pc=0x0CD0 ; target=.L_codegen_1_main_end ; addr=0x0D14
    sleep ; nop despues de control                      ; pc=0x0CD4
    sleep ; nop despues de control                      ; pc=0x0CD8
    jal x0, 12                                          ; pc=0x0CDC ; target=.L15_if_end ; addr=0x0CE8
    sleep ; nop despues de control                      ; pc=0x0CE0
    sleep ; nop despues de control                      ; pc=0x0CE4
.L14_if_else:
.L15_if_end:

    addi x3, x0, 0                                      ; pc=0x0CE8
    sleep ; stall RAW                                   ; pc=0x0CEC
    sleep ; stall RAW                                   ; pc=0x0CF0
    sleep ; stall RAW                                   ; pc=0x0CF4
    add x11, x3, x0                                     ; pc=0x0CF8
    sleep ; stall RAW                                   ; pc=0x0CFC
    sleep ; stall RAW                                   ; pc=0x0D00
    sleep ; stall RAW                                   ; pc=0x0D04
    jal x0, 12                                          ; pc=0x0D08 ; target=.L_codegen_1_main_end ; addr=0x0D14
    sleep ; nop despues de control                      ; pc=0x0D0C
    sleep ; nop despues de control                      ; pc=0x0D10
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0D14
    sleep ; stall RAW                                   ; pc=0x0D18
    sleep ; stall RAW                                   ; pc=0x0D1C
    sleep ; stall RAW                                   ; pc=0x0D20
    addi x2, x2, 28                                     ; pc=0x0D24
    sleep ; stall RAW                                   ; pc=0x0D28
    sleep ; stall RAW                                   ; pc=0x0D2C
    sleep ; stall RAW                                   ; pc=0x0D30
    freeze                                              ; pc=0x0D34

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x0D38
    sleep ; stall RAW                                   ; pc=0x0D3C
    sleep ; stall RAW                                   ; pc=0x0D40
    sleep ; stall RAW                                   ; pc=0x0D44
    sw x1, 0(x2)                                        ; pc=0x0D48
    sw x17, 4(x2)                                       ; pc=0x0D4C
    addi x17, x2, 60                                    ; pc=0x0D50
    sleep ; stall RAW                                   ; pc=0x0D54
    sleep ; stall RAW                                   ; pc=0x0D58
    sleep ; stall RAW                                   ; pc=0x0D5C

    sw x11, -4(x17) ; parámetro v                       ; pc=0x0D60
    sw x12, -8(x17) ; parámetro tea_key                 ; pc=0x0D64

    addi x3, x0, 0                                      ; pc=0x0D68
    sleep ; stall RAW                                   ; pc=0x0D6C
    sleep ; stall RAW                                   ; pc=0x0D70
    sleep ; stall RAW                                   ; pc=0x0D74
    add x5, x3, x3                                      ; pc=0x0D78
    sleep ; stall RAW                                   ; pc=0x0D7C
    sleep ; stall RAW                                   ; pc=0x0D80
    sleep ; stall RAW                                   ; pc=0x0D84
    add x5, x5, x5                                      ; pc=0x0D88
    sleep ; stall RAW                                   ; pc=0x0D8C
    sleep ; stall RAW                                   ; pc=0x0D90
    sleep ; stall RAW                                   ; pc=0x0D94
    lw x4, -4(x17) ; base ref v                         ; pc=0x0D98
    sleep ; stall RAW                                   ; pc=0x0D9C
    sleep ; stall RAW                                   ; pc=0x0DA0
    sleep ; stall RAW                                   ; pc=0x0DA4
    add x4, x4, x5                                      ; pc=0x0DA8
    sleep ; stall RAW                                   ; pc=0x0DAC
    sleep ; stall RAW                                   ; pc=0x0DB0
    sleep ; stall RAW                                   ; pc=0x0DB4
    lw x5, 0(x4)                                        ; pc=0x0DB8
    sleep ; stall RAW                                   ; pc=0x0DBC
    sleep ; stall RAW                                   ; pc=0x0DC0
    sleep ; stall RAW                                   ; pc=0x0DC4
    sw x5, -12(x17) ; v0                                ; pc=0x0DC8
    addi x5, x0, 1                                      ; pc=0x0DCC
    sleep ; stall RAW                                   ; pc=0x0DD0
    sleep ; stall RAW                                   ; pc=0x0DD4
    sleep ; stall RAW                                   ; pc=0x0DD8
    add x4, x5, x5                                      ; pc=0x0DDC
    sleep ; stall RAW                                   ; pc=0x0DE0
    sleep ; stall RAW                                   ; pc=0x0DE4
    sleep ; stall RAW                                   ; pc=0x0DE8
    add x4, x4, x4                                      ; pc=0x0DEC
    sleep ; stall RAW                                   ; pc=0x0DF0
    sleep ; stall RAW                                   ; pc=0x0DF4
    sleep ; stall RAW                                   ; pc=0x0DF8
    lw x3, -4(x17) ; base ref v                         ; pc=0x0DFC
    sleep ; stall RAW                                   ; pc=0x0E00
    sleep ; stall RAW                                   ; pc=0x0E04
    sleep ; stall RAW                                   ; pc=0x0E08
    add x3, x3, x4                                      ; pc=0x0E0C
    sleep ; stall RAW                                   ; pc=0x0E10
    sleep ; stall RAW                                   ; pc=0x0E14
    sleep ; stall RAW                                   ; pc=0x0E18
    lw x4, 0(x3)                                        ; pc=0x0E1C
    sleep ; stall RAW                                   ; pc=0x0E20
    sleep ; stall RAW                                   ; pc=0x0E24
    sleep ; stall RAW                                   ; pc=0x0E28
    sw x4, -16(x17) ; v1                                ; pc=0x0E2C
    addi x4, x0, 0                                      ; pc=0x0E30
    sleep ; stall RAW                                   ; pc=0x0E34
    sleep ; stall RAW                                   ; pc=0x0E38
    sleep ; stall RAW                                   ; pc=0x0E3C
    sw x4, -20(x17) ; sum                               ; pc=0x0E40

    ; for
    addi x4, x0, 0                                      ; pc=0x0E44
    sleep ; stall RAW                                   ; pc=0x0E48
    sleep ; stall RAW                                   ; pc=0x0E4C
    sleep ; stall RAW                                   ; pc=0x0E50
    sw x4, -24(x17) ; i                                 ; pc=0x0E54
.L0_for_start:
    lw x4, -24(x17) ; i                                 ; pc=0x0E58
    sleep ; stall RAW                                   ; pc=0x0E5C
    sleep ; stall RAW                                   ; pc=0x0E60
    sleep ; stall RAW                                   ; pc=0x0E64
    addi x3, x0, 32                                     ; pc=0x0E68
    sleep ; stall RAW                                   ; pc=0x0E6C
    sleep ; stall RAW                                   ; pc=0x0E70
    sleep ; stall RAW                                   ; pc=0x0E74
    bge x4, x3, 1152                                    ; pc=0x0E78 ; target=.L1_for_end ; addr=0x12F8
    sleep ; nop despues de control                      ; pc=0x0E7C
    sleep ; nop despues de control                      ; pc=0x0E80
    lw x3, -20(x17) ; sum                               ; pc=0x0E84
    sleep ; stall RAW                                   ; pc=0x0E88
    sleep ; stall RAW                                   ; pc=0x0E8C
    sleep ; stall RAW                                   ; pc=0x0E90
    addiHIGH x5, x0, 0                                  ; pc=0x0E94
    sleep ; stall RAW                                   ; pc=0x0E98
    sleep ; stall RAW                                   ; pc=0x0E9C
    sleep ; stall RAW                                   ; pc=0x0EA0
    addi x5, x5, 64496                                  ; pc=0x0EA4
    sleep ; stall RAW                                   ; pc=0x0EA8
    sleep ; stall RAW                                   ; pc=0x0EAC
    sleep ; stall RAW                                   ; pc=0x0EB0
    lw x4, 0(x5) ; DELTA                                ; pc=0x0EB4
    sleep ; stall RAW                                   ; pc=0x0EB8
    sleep ; stall RAW                                   ; pc=0x0EBC
    sleep ; stall RAW                                   ; pc=0x0EC0
    add x5, x3, x4                                      ; pc=0x0EC4
    sleep ; stall RAW                                   ; pc=0x0EC8
    sleep ; stall RAW                                   ; pc=0x0ECC
    sleep ; stall RAW                                   ; pc=0x0ED0
    sw x5, -20(x17) ; sum                               ; pc=0x0ED4
    lw x5, -16(x17) ; v1                                ; pc=0x0ED8
    sleep ; stall RAW                                   ; pc=0x0EDC
    sleep ; stall RAW                                   ; pc=0x0EE0
    sleep ; stall RAW                                   ; pc=0x0EE4
    addi x4, x0, 0                                      ; pc=0x0EE8
    sleep ; stall RAW                                   ; pc=0x0EEC
    sleep ; stall RAW                                   ; pc=0x0EF0
    sleep ; stall RAW                                   ; pc=0x0EF4
    add x3, x4, x4                                      ; pc=0x0EF8
    sleep ; stall RAW                                   ; pc=0x0EFC
    sleep ; stall RAW                                   ; pc=0x0F00
    sleep ; stall RAW                                   ; pc=0x0F04
    add x3, x3, x3                                      ; pc=0x0F08
    sleep ; stall RAW                                   ; pc=0x0F0C
    sleep ; stall RAW                                   ; pc=0x0F10
    sleep ; stall RAW                                   ; pc=0x0F14
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x0F18
    sleep ; stall RAW                                   ; pc=0x0F1C
    sleep ; stall RAW                                   ; pc=0x0F20
    sleep ; stall RAW                                   ; pc=0x0F24
    add x6, x6, x3                                      ; pc=0x0F28
    sleep ; stall RAW                                   ; pc=0x0F2C
    sleep ; stall RAW                                   ; pc=0x0F30
    sleep ; stall RAW                                   ; pc=0x0F34
    lw x3, 0(x6)                                        ; pc=0x0F38
    sleep ; stall RAW                                   ; pc=0x0F3C
    sleep ; stall RAW                                   ; pc=0x0F40
    sleep ; stall RAW                                   ; pc=0x0F44
    addi x4, x0, 4                                      ; pc=0x0F48
    sleep ; stall RAW                                   ; pc=0x0F4C
    sleep ; stall RAW                                   ; pc=0x0F50
    sleep ; stall RAW                                   ; pc=0x0F54
    sll x6, x5, x4                                      ; pc=0x0F58
    sleep ; stall RAW                                   ; pc=0x0F5C
    sleep ; stall RAW                                   ; pc=0x0F60
    sleep ; stall RAW                                   ; pc=0x0F64
    add x6, x6, x3                                      ; pc=0x0F68
    sleep ; stall RAW                                   ; pc=0x0F6C
    sleep ; stall RAW                                   ; pc=0x0F70
    sleep ; stall RAW                                   ; pc=0x0F74
    sw x6, -28(x17) ; left0                             ; pc=0x0F78
    lw x6, -16(x17) ; v1                                ; pc=0x0F7C
    sleep ; stall RAW                                   ; pc=0x0F80
    sleep ; stall RAW                                   ; pc=0x0F84
    sleep ; stall RAW                                   ; pc=0x0F88
    lw x3, -20(x17) ; sum                               ; pc=0x0F8C
    sleep ; stall RAW                                   ; pc=0x0F90
    sleep ; stall RAW                                   ; pc=0x0F94
    sleep ; stall RAW                                   ; pc=0x0F98
    add x5, x6, x3                                      ; pc=0x0F9C
    sleep ; stall RAW                                   ; pc=0x0FA0
    sleep ; stall RAW                                   ; pc=0x0FA4
    sleep ; stall RAW                                   ; pc=0x0FA8
    sw x5, -32(x17) ; mid0                              ; pc=0x0FAC
    lw x5, -16(x17) ; v1                                ; pc=0x0FB0
    sleep ; stall RAW                                   ; pc=0x0FB4
    sleep ; stall RAW                                   ; pc=0x0FB8
    sleep ; stall RAW                                   ; pc=0x0FBC
    addi x3, x0, 1                                      ; pc=0x0FC0
    sleep ; stall RAW                                   ; pc=0x0FC4
    sleep ; stall RAW                                   ; pc=0x0FC8
    sleep ; stall RAW                                   ; pc=0x0FCC
    add x6, x3, x3                                      ; pc=0x0FD0
    sleep ; stall RAW                                   ; pc=0x0FD4
    sleep ; stall RAW                                   ; pc=0x0FD8
    sleep ; stall RAW                                   ; pc=0x0FDC
    add x6, x6, x6                                      ; pc=0x0FE0
    sleep ; stall RAW                                   ; pc=0x0FE4
    sleep ; stall RAW                                   ; pc=0x0FE8
    sleep ; stall RAW                                   ; pc=0x0FEC
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x0FF0
    sleep ; stall RAW                                   ; pc=0x0FF4
    sleep ; stall RAW                                   ; pc=0x0FF8
    sleep ; stall RAW                                   ; pc=0x0FFC
    add x4, x4, x6                                      ; pc=0x1000
    sleep ; stall RAW                                   ; pc=0x1004
    sleep ; stall RAW                                   ; pc=0x1008
    sleep ; stall RAW                                   ; pc=0x100C
    lw x6, 0(x4)                                        ; pc=0x1010
    sleep ; stall RAW                                   ; pc=0x1014
    sleep ; stall RAW                                   ; pc=0x1018
    sleep ; stall RAW                                   ; pc=0x101C
    addi x3, x0, 5                                      ; pc=0x1020
    sleep ; stall RAW                                   ; pc=0x1024
    sleep ; stall RAW                                   ; pc=0x1028
    sleep ; stall RAW                                   ; pc=0x102C
    srl x4, x5, x3                                      ; pc=0x1030
    sleep ; stall RAW                                   ; pc=0x1034
    sleep ; stall RAW                                   ; pc=0x1038
    sleep ; stall RAW                                   ; pc=0x103C
    add x4, x4, x6                                      ; pc=0x1040
    sleep ; stall RAW                                   ; pc=0x1044
    sleep ; stall RAW                                   ; pc=0x1048
    sleep ; stall RAW                                   ; pc=0x104C
    sw x4, -36(x17) ; right0                            ; pc=0x1050
    lw x4, -12(x17) ; v0                                ; pc=0x1054
    sleep ; stall RAW                                   ; pc=0x1058
    sleep ; stall RAW                                   ; pc=0x105C
    sleep ; stall RAW                                   ; pc=0x1060
    lw x6, -28(x17) ; left0                             ; pc=0x1064
    sleep ; stall RAW                                   ; pc=0x1068
    sleep ; stall RAW                                   ; pc=0x106C
    sleep ; stall RAW                                   ; pc=0x1070
    lw x5, -32(x17) ; mid0                              ; pc=0x1074
    sleep ; stall RAW                                   ; pc=0x1078
    sleep ; stall RAW                                   ; pc=0x107C
    sleep ; stall RAW                                   ; pc=0x1080
    xor x3, x6, x5                                      ; pc=0x1084
    sleep ; stall RAW                                   ; pc=0x1088
    sleep ; stall RAW                                   ; pc=0x108C
    sleep ; stall RAW                                   ; pc=0x1090
    lw x5, -36(x17) ; right0                            ; pc=0x1094
    sleep ; stall RAW                                   ; pc=0x1098
    sleep ; stall RAW                                   ; pc=0x109C
    sleep ; stall RAW                                   ; pc=0x10A0
    xor x6, x3, x5                                      ; pc=0x10A4
    sleep ; stall RAW                                   ; pc=0x10A8
    sleep ; stall RAW                                   ; pc=0x10AC
    sleep ; stall RAW                                   ; pc=0x10B0
    add x5, x4, x6                                      ; pc=0x10B4
    sleep ; stall RAW                                   ; pc=0x10B8
    sleep ; stall RAW                                   ; pc=0x10BC
    sleep ; stall RAW                                   ; pc=0x10C0
    sw x5, -12(x17) ; v0                                ; pc=0x10C4
    lw x5, -12(x17) ; v0                                ; pc=0x10C8
    sleep ; stall RAW                                   ; pc=0x10CC
    sleep ; stall RAW                                   ; pc=0x10D0
    sleep ; stall RAW                                   ; pc=0x10D4
    addi x6, x0, 2                                      ; pc=0x10D8
    sleep ; stall RAW                                   ; pc=0x10DC
    sleep ; stall RAW                                   ; pc=0x10E0
    sleep ; stall RAW                                   ; pc=0x10E4
    add x4, x6, x6                                      ; pc=0x10E8
    sleep ; stall RAW                                   ; pc=0x10EC
    sleep ; stall RAW                                   ; pc=0x10F0
    sleep ; stall RAW                                   ; pc=0x10F4
    add x4, x4, x4                                      ; pc=0x10F8
    sleep ; stall RAW                                   ; pc=0x10FC
    sleep ; stall RAW                                   ; pc=0x1100
    sleep ; stall RAW                                   ; pc=0x1104
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x1108
    sleep ; stall RAW                                   ; pc=0x110C
    sleep ; stall RAW                                   ; pc=0x1110
    sleep ; stall RAW                                   ; pc=0x1114
    add x3, x3, x4                                      ; pc=0x1118
    sleep ; stall RAW                                   ; pc=0x111C
    sleep ; stall RAW                                   ; pc=0x1120
    sleep ; stall RAW                                   ; pc=0x1124
    lw x4, 0(x3)                                        ; pc=0x1128
    sleep ; stall RAW                                   ; pc=0x112C
    sleep ; stall RAW                                   ; pc=0x1130
    sleep ; stall RAW                                   ; pc=0x1134
    addi x6, x0, 4                                      ; pc=0x1138
    sleep ; stall RAW                                   ; pc=0x113C
    sleep ; stall RAW                                   ; pc=0x1140
    sleep ; stall RAW                                   ; pc=0x1144
    sll x3, x5, x6                                      ; pc=0x1148
    sleep ; stall RAW                                   ; pc=0x114C
    sleep ; stall RAW                                   ; pc=0x1150
    sleep ; stall RAW                                   ; pc=0x1154
    add x3, x3, x4                                      ; pc=0x1158
    sleep ; stall RAW                                   ; pc=0x115C
    sleep ; stall RAW                                   ; pc=0x1160
    sleep ; stall RAW                                   ; pc=0x1164
    sw x3, -40(x17) ; left1                             ; pc=0x1168
    lw x3, -12(x17) ; v0                                ; pc=0x116C
    sleep ; stall RAW                                   ; pc=0x1170
    sleep ; stall RAW                                   ; pc=0x1174
    sleep ; stall RAW                                   ; pc=0x1178
    lw x4, -20(x17) ; sum                               ; pc=0x117C
    sleep ; stall RAW                                   ; pc=0x1180
    sleep ; stall RAW                                   ; pc=0x1184
    sleep ; stall RAW                                   ; pc=0x1188
    add x5, x3, x4                                      ; pc=0x118C
    sleep ; stall RAW                                   ; pc=0x1190
    sleep ; stall RAW                                   ; pc=0x1194
    sleep ; stall RAW                                   ; pc=0x1198
    sw x5, -44(x17) ; mid1                              ; pc=0x119C
    lw x5, -12(x17) ; v0                                ; pc=0x11A0
    sleep ; stall RAW                                   ; pc=0x11A4
    sleep ; stall RAW                                   ; pc=0x11A8
    sleep ; stall RAW                                   ; pc=0x11AC
    addi x4, x0, 3                                      ; pc=0x11B0
    sleep ; stall RAW                                   ; pc=0x11B4
    sleep ; stall RAW                                   ; pc=0x11B8
    sleep ; stall RAW                                   ; pc=0x11BC
    add x3, x4, x4                                      ; pc=0x11C0
    sleep ; stall RAW                                   ; pc=0x11C4
    sleep ; stall RAW                                   ; pc=0x11C8
    sleep ; stall RAW                                   ; pc=0x11CC
    add x3, x3, x3                                      ; pc=0x11D0
    sleep ; stall RAW                                   ; pc=0x11D4
    sleep ; stall RAW                                   ; pc=0x11D8
    sleep ; stall RAW                                   ; pc=0x11DC
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x11E0
    sleep ; stall RAW                                   ; pc=0x11E4
    sleep ; stall RAW                                   ; pc=0x11E8
    sleep ; stall RAW                                   ; pc=0x11EC
    add x6, x6, x3                                      ; pc=0x11F0
    sleep ; stall RAW                                   ; pc=0x11F4
    sleep ; stall RAW                                   ; pc=0x11F8
    sleep ; stall RAW                                   ; pc=0x11FC
    lw x3, 0(x6)                                        ; pc=0x1200
    sleep ; stall RAW                                   ; pc=0x1204
    sleep ; stall RAW                                   ; pc=0x1208
    sleep ; stall RAW                                   ; pc=0x120C
    addi x4, x0, 5                                      ; pc=0x1210
    sleep ; stall RAW                                   ; pc=0x1214
    sleep ; stall RAW                                   ; pc=0x1218
    sleep ; stall RAW                                   ; pc=0x121C
    srl x6, x5, x4                                      ; pc=0x1220
    sleep ; stall RAW                                   ; pc=0x1224
    sleep ; stall RAW                                   ; pc=0x1228
    sleep ; stall RAW                                   ; pc=0x122C
    add x6, x6, x3                                      ; pc=0x1230
    sleep ; stall RAW                                   ; pc=0x1234
    sleep ; stall RAW                                   ; pc=0x1238
    sleep ; stall RAW                                   ; pc=0x123C
    sw x6, -48(x17) ; right1                            ; pc=0x1240
    lw x6, -16(x17) ; v1                                ; pc=0x1244
    sleep ; stall RAW                                   ; pc=0x1248
    sleep ; stall RAW                                   ; pc=0x124C
    sleep ; stall RAW                                   ; pc=0x1250
    lw x3, -40(x17) ; left1                             ; pc=0x1254
    sleep ; stall RAW                                   ; pc=0x1258
    sleep ; stall RAW                                   ; pc=0x125C
    sleep ; stall RAW                                   ; pc=0x1260
    lw x5, -44(x17) ; mid1                              ; pc=0x1264
    sleep ; stall RAW                                   ; pc=0x1268
    sleep ; stall RAW                                   ; pc=0x126C
    sleep ; stall RAW                                   ; pc=0x1270
    xor x4, x3, x5                                      ; pc=0x1274
    sleep ; stall RAW                                   ; pc=0x1278
    sleep ; stall RAW                                   ; pc=0x127C
    sleep ; stall RAW                                   ; pc=0x1280
    lw x5, -48(x17) ; right1                            ; pc=0x1284
    sleep ; stall RAW                                   ; pc=0x1288
    sleep ; stall RAW                                   ; pc=0x128C
    sleep ; stall RAW                                   ; pc=0x1290
    xor x3, x4, x5                                      ; pc=0x1294
    sleep ; stall RAW                                   ; pc=0x1298
    sleep ; stall RAW                                   ; pc=0x129C
    sleep ; stall RAW                                   ; pc=0x12A0
    add x5, x6, x3                                      ; pc=0x12A4
    sleep ; stall RAW                                   ; pc=0x12A8
    sleep ; stall RAW                                   ; pc=0x12AC
    sleep ; stall RAW                                   ; pc=0x12B0
    sw x5, -16(x17) ; v1                                ; pc=0x12B4
    lw x5, -24(x17) ; i                                 ; pc=0x12B8
    sleep ; stall RAW                                   ; pc=0x12BC
    sleep ; stall RAW                                   ; pc=0x12C0
    sleep ; stall RAW                                   ; pc=0x12C4
    addi x3, x0, 1                                      ; pc=0x12C8
    sleep ; stall RAW                                   ; pc=0x12CC
    sleep ; stall RAW                                   ; pc=0x12D0
    sleep ; stall RAW                                   ; pc=0x12D4
    add x6, x5, x3                                      ; pc=0x12D8
    sleep ; stall RAW                                   ; pc=0x12DC
    sleep ; stall RAW                                   ; pc=0x12E0
    sleep ; stall RAW                                   ; pc=0x12E4
    sw x6, -24(x17) ; i                                 ; pc=0x12E8
    jal x0, -1172                                       ; pc=0x12EC ; target=.L0_for_start ; addr=0x0E58
    sleep ; nop despues de control                      ; pc=0x12F0
    sleep ; nop despues de control                      ; pc=0x12F4
.L1_for_end:

    lw x6, -12(x17) ; v0                                ; pc=0x12F8
    sleep ; stall RAW                                   ; pc=0x12FC
    sleep ; stall RAW                                   ; pc=0x1300
    sleep ; stall RAW                                   ; pc=0x1304
    addi x3, x0, 0                                      ; pc=0x1308
    sleep ; stall RAW                                   ; pc=0x130C
    sleep ; stall RAW                                   ; pc=0x1310
    sleep ; stall RAW                                   ; pc=0x1314
    add x5, x3, x3                                      ; pc=0x1318
    sleep ; stall RAW                                   ; pc=0x131C
    sleep ; stall RAW                                   ; pc=0x1320
    sleep ; stall RAW                                   ; pc=0x1324
    add x5, x5, x5                                      ; pc=0x1328
    sleep ; stall RAW                                   ; pc=0x132C
    sleep ; stall RAW                                   ; pc=0x1330
    sleep ; stall RAW                                   ; pc=0x1334
    lw x4, -4(x17) ; base ref v                         ; pc=0x1338
    sleep ; stall RAW                                   ; pc=0x133C
    sleep ; stall RAW                                   ; pc=0x1340
    sleep ; stall RAW                                   ; pc=0x1344
    add x4, x4, x5                                      ; pc=0x1348
    sleep ; stall RAW                                   ; pc=0x134C
    sleep ; stall RAW                                   ; pc=0x1350
    sleep ; stall RAW                                   ; pc=0x1354
    sw x6, 0(x4)                                        ; pc=0x1358
    lw x6, -16(x17) ; v1                                ; pc=0x135C
    sleep ; stall RAW                                   ; pc=0x1360
    sleep ; stall RAW                                   ; pc=0x1364
    sleep ; stall RAW                                   ; pc=0x1368
    addi x4, x0, 1                                      ; pc=0x136C
    sleep ; stall RAW                                   ; pc=0x1370
    sleep ; stall RAW                                   ; pc=0x1374
    sleep ; stall RAW                                   ; pc=0x1378
    add x5, x4, x4                                      ; pc=0x137C
    sleep ; stall RAW                                   ; pc=0x1380
    sleep ; stall RAW                                   ; pc=0x1384
    sleep ; stall RAW                                   ; pc=0x1388
    add x5, x5, x5                                      ; pc=0x138C
    sleep ; stall RAW                                   ; pc=0x1390
    sleep ; stall RAW                                   ; pc=0x1394
    sleep ; stall RAW                                   ; pc=0x1398
    lw x3, -4(x17) ; base ref v                         ; pc=0x139C
    sleep ; stall RAW                                   ; pc=0x13A0
    sleep ; stall RAW                                   ; pc=0x13A4
    sleep ; stall RAW                                   ; pc=0x13A8
    add x3, x3, x5                                      ; pc=0x13AC
    sleep ; stall RAW                                   ; pc=0x13B0
    sleep ; stall RAW                                   ; pc=0x13B4
    sleep ; stall RAW                                   ; pc=0x13B8
    sw x6, 0(x3)                                        ; pc=0x13BC
.L_codegen_2_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x13C0
    sleep ; stall RAW                                   ; pc=0x13C4
    sleep ; stall RAW                                   ; pc=0x13C8
    sleep ; stall RAW                                   ; pc=0x13CC
    lw x17, 4(x2)                                       ; pc=0x13D0
    sleep ; stall RAW                                   ; pc=0x13D4
    sleep ; stall RAW                                   ; pc=0x13D8
    sleep ; stall RAW                                   ; pc=0x13DC
    addi x2, x2, 60                                     ; pc=0x13E0
    sleep ; stall RAW                                   ; pc=0x13E4
    sleep ; stall RAW                                   ; pc=0x13E8
    sleep ; stall RAW                                   ; pc=0x13EC
    jalr x1, 0                                          ; pc=0x13F0
    sleep ; nop despues de control                      ; pc=0x13F4
    sleep ; nop despues de control                      ; pc=0x13F8

tea_decrypt:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x13FC
    sleep ; stall RAW                                   ; pc=0x1400
    sleep ; stall RAW                                   ; pc=0x1404
    sleep ; stall RAW                                   ; pc=0x1408
    sw x1, 0(x2)                                        ; pc=0x140C
    sw x17, 4(x2)                                       ; pc=0x1410
    addi x17, x2, 60                                    ; pc=0x1414
    sleep ; stall RAW                                   ; pc=0x1418
    sleep ; stall RAW                                   ; pc=0x141C
    sleep ; stall RAW                                   ; pc=0x1420

    sw x11, -4(x17) ; parámetro v                       ; pc=0x1424
    sw x12, -8(x17) ; parámetro tea_key                 ; pc=0x1428

    addi x6, x0, 0                                      ; pc=0x142C
    sleep ; stall RAW                                   ; pc=0x1430
    sleep ; stall RAW                                   ; pc=0x1434
    sleep ; stall RAW                                   ; pc=0x1438
    add x3, x6, x6                                      ; pc=0x143C
    sleep ; stall RAW                                   ; pc=0x1440
    sleep ; stall RAW                                   ; pc=0x1444
    sleep ; stall RAW                                   ; pc=0x1448
    add x3, x3, x3                                      ; pc=0x144C
    sleep ; stall RAW                                   ; pc=0x1450
    sleep ; stall RAW                                   ; pc=0x1454
    sleep ; stall RAW                                   ; pc=0x1458
    lw x5, -4(x17) ; base ref v                         ; pc=0x145C
    sleep ; stall RAW                                   ; pc=0x1460
    sleep ; stall RAW                                   ; pc=0x1464
    sleep ; stall RAW                                   ; pc=0x1468
    add x5, x5, x3                                      ; pc=0x146C
    sleep ; stall RAW                                   ; pc=0x1470
    sleep ; stall RAW                                   ; pc=0x1474
    sleep ; stall RAW                                   ; pc=0x1478
    lw x3, 0(x5)                                        ; pc=0x147C
    sleep ; stall RAW                                   ; pc=0x1480
    sleep ; stall RAW                                   ; pc=0x1484
    sleep ; stall RAW                                   ; pc=0x1488
    sw x3, -12(x17) ; v0                                ; pc=0x148C
    addi x3, x0, 1                                      ; pc=0x1490
    sleep ; stall RAW                                   ; pc=0x1494
    sleep ; stall RAW                                   ; pc=0x1498
    sleep ; stall RAW                                   ; pc=0x149C
    add x5, x3, x3                                      ; pc=0x14A0
    sleep ; stall RAW                                   ; pc=0x14A4
    sleep ; stall RAW                                   ; pc=0x14A8
    sleep ; stall RAW                                   ; pc=0x14AC
    add x5, x5, x5                                      ; pc=0x14B0
    sleep ; stall RAW                                   ; pc=0x14B4
    sleep ; stall RAW                                   ; pc=0x14B8
    sleep ; stall RAW                                   ; pc=0x14BC
    lw x6, -4(x17) ; base ref v                         ; pc=0x14C0
    sleep ; stall RAW                                   ; pc=0x14C4
    sleep ; stall RAW                                   ; pc=0x14C8
    sleep ; stall RAW                                   ; pc=0x14CC
    add x6, x6, x5                                      ; pc=0x14D0
    sleep ; stall RAW                                   ; pc=0x14D4
    sleep ; stall RAW                                   ; pc=0x14D8
    sleep ; stall RAW                                   ; pc=0x14DC
    lw x5, 0(x6)                                        ; pc=0x14E0
    sleep ; stall RAW                                   ; pc=0x14E4
    sleep ; stall RAW                                   ; pc=0x14E8
    sleep ; stall RAW                                   ; pc=0x14EC
    sw x5, -16(x17) ; v1                                ; pc=0x14F0
    addiHIGH x6, x0, 0                                  ; pc=0x14F4
    sleep ; stall RAW                                   ; pc=0x14F8
    sleep ; stall RAW                                   ; pc=0x14FC
    sleep ; stall RAW                                   ; pc=0x1500
    addi x6, x6, 64500                                  ; pc=0x1504
    sleep ; stall RAW                                   ; pc=0x1508
    sleep ; stall RAW                                   ; pc=0x150C
    sleep ; stall RAW                                   ; pc=0x1510
    lw x5, 0(x6) ; SUM_INIT                             ; pc=0x1514
    sleep ; stall RAW                                   ; pc=0x1518
    sleep ; stall RAW                                   ; pc=0x151C
    sleep ; stall RAW                                   ; pc=0x1520
    sw x5, -20(x17) ; sum                               ; pc=0x1524

    ; for
    addi x5, x0, 0                                      ; pc=0x1528
    sleep ; stall RAW                                   ; pc=0x152C
    sleep ; stall RAW                                   ; pc=0x1530
    sleep ; stall RAW                                   ; pc=0x1534
    sw x5, -24(x17) ; i                                 ; pc=0x1538
.L2_for_start:
    lw x5, -24(x17) ; i                                 ; pc=0x153C
    sleep ; stall RAW                                   ; pc=0x1540
    sleep ; stall RAW                                   ; pc=0x1544
    sleep ; stall RAW                                   ; pc=0x1548
    addi x6, x0, 32                                     ; pc=0x154C
    sleep ; stall RAW                                   ; pc=0x1550
    sleep ; stall RAW                                   ; pc=0x1554
    sleep ; stall RAW                                   ; pc=0x1558
    bge x5, x6, 1152                                    ; pc=0x155C ; target=.L3_for_end ; addr=0x19DC
    sleep ; nop despues de control                      ; pc=0x1560
    sleep ; nop despues de control                      ; pc=0x1564
    lw x6, -12(x17) ; v0                                ; pc=0x1568
    sleep ; stall RAW                                   ; pc=0x156C
    sleep ; stall RAW                                   ; pc=0x1570
    sleep ; stall RAW                                   ; pc=0x1574
    addi x5, x0, 2                                      ; pc=0x1578
    sleep ; stall RAW                                   ; pc=0x157C
    sleep ; stall RAW                                   ; pc=0x1580
    sleep ; stall RAW                                   ; pc=0x1584
    add x3, x5, x5                                      ; pc=0x1588
    sleep ; stall RAW                                   ; pc=0x158C
    sleep ; stall RAW                                   ; pc=0x1590
    sleep ; stall RAW                                   ; pc=0x1594
    add x3, x3, x3                                      ; pc=0x1598
    sleep ; stall RAW                                   ; pc=0x159C
    sleep ; stall RAW                                   ; pc=0x15A0
    sleep ; stall RAW                                   ; pc=0x15A4
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x15A8
    sleep ; stall RAW                                   ; pc=0x15AC
    sleep ; stall RAW                                   ; pc=0x15B0
    sleep ; stall RAW                                   ; pc=0x15B4
    add x4, x4, x3                                      ; pc=0x15B8
    sleep ; stall RAW                                   ; pc=0x15BC
    sleep ; stall RAW                                   ; pc=0x15C0
    sleep ; stall RAW                                   ; pc=0x15C4
    lw x3, 0(x4)                                        ; pc=0x15C8
    sleep ; stall RAW                                   ; pc=0x15CC
    sleep ; stall RAW                                   ; pc=0x15D0
    sleep ; stall RAW                                   ; pc=0x15D4
    addi x5, x0, 4                                      ; pc=0x15D8
    sleep ; stall RAW                                   ; pc=0x15DC
    sleep ; stall RAW                                   ; pc=0x15E0
    sleep ; stall RAW                                   ; pc=0x15E4
    sll x4, x6, x5                                      ; pc=0x15E8
    sleep ; stall RAW                                   ; pc=0x15EC
    sleep ; stall RAW                                   ; pc=0x15F0
    sleep ; stall RAW                                   ; pc=0x15F4
    add x4, x4, x3                                      ; pc=0x15F8
    sleep ; stall RAW                                   ; pc=0x15FC
    sleep ; stall RAW                                   ; pc=0x1600
    sleep ; stall RAW                                   ; pc=0x1604
    sw x4, -28(x17) ; left1                             ; pc=0x1608
    lw x4, -12(x17) ; v0                                ; pc=0x160C
    sleep ; stall RAW                                   ; pc=0x1610
    sleep ; stall RAW                                   ; pc=0x1614
    sleep ; stall RAW                                   ; pc=0x1618
    lw x3, -20(x17) ; sum                               ; pc=0x161C
    sleep ; stall RAW                                   ; pc=0x1620
    sleep ; stall RAW                                   ; pc=0x1624
    sleep ; stall RAW                                   ; pc=0x1628
    add x6, x4, x3                                      ; pc=0x162C
    sleep ; stall RAW                                   ; pc=0x1630
    sleep ; stall RAW                                   ; pc=0x1634
    sleep ; stall RAW                                   ; pc=0x1638
    sw x6, -32(x17) ; mid1                              ; pc=0x163C
    lw x6, -12(x17) ; v0                                ; pc=0x1640
    sleep ; stall RAW                                   ; pc=0x1644
    sleep ; stall RAW                                   ; pc=0x1648
    sleep ; stall RAW                                   ; pc=0x164C
    addi x3, x0, 3                                      ; pc=0x1650
    sleep ; stall RAW                                   ; pc=0x1654
    sleep ; stall RAW                                   ; pc=0x1658
    sleep ; stall RAW                                   ; pc=0x165C
    add x4, x3, x3                                      ; pc=0x1660
    sleep ; stall RAW                                   ; pc=0x1664
    sleep ; stall RAW                                   ; pc=0x1668
    sleep ; stall RAW                                   ; pc=0x166C
    add x4, x4, x4                                      ; pc=0x1670
    sleep ; stall RAW                                   ; pc=0x1674
    sleep ; stall RAW                                   ; pc=0x1678
    sleep ; stall RAW                                   ; pc=0x167C
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x1680
    sleep ; stall RAW                                   ; pc=0x1684
    sleep ; stall RAW                                   ; pc=0x1688
    sleep ; stall RAW                                   ; pc=0x168C
    add x5, x5, x4                                      ; pc=0x1690
    sleep ; stall RAW                                   ; pc=0x1694
    sleep ; stall RAW                                   ; pc=0x1698
    sleep ; stall RAW                                   ; pc=0x169C
    lw x4, 0(x5)                                        ; pc=0x16A0
    sleep ; stall RAW                                   ; pc=0x16A4
    sleep ; stall RAW                                   ; pc=0x16A8
    sleep ; stall RAW                                   ; pc=0x16AC
    addi x3, x0, 5                                      ; pc=0x16B0
    sleep ; stall RAW                                   ; pc=0x16B4
    sleep ; stall RAW                                   ; pc=0x16B8
    sleep ; stall RAW                                   ; pc=0x16BC
    srl x5, x6, x3                                      ; pc=0x16C0
    sleep ; stall RAW                                   ; pc=0x16C4
    sleep ; stall RAW                                   ; pc=0x16C8
    sleep ; stall RAW                                   ; pc=0x16CC
    add x5, x5, x4                                      ; pc=0x16D0
    sleep ; stall RAW                                   ; pc=0x16D4
    sleep ; stall RAW                                   ; pc=0x16D8
    sleep ; stall RAW                                   ; pc=0x16DC
    sw x5, -36(x17) ; right1                            ; pc=0x16E0
    lw x5, -16(x17) ; v1                                ; pc=0x16E4
    sleep ; stall RAW                                   ; pc=0x16E8
    sleep ; stall RAW                                   ; pc=0x16EC
    sleep ; stall RAW                                   ; pc=0x16F0
    lw x4, -28(x17) ; left1                             ; pc=0x16F4
    sleep ; stall RAW                                   ; pc=0x16F8
    sleep ; stall RAW                                   ; pc=0x16FC
    sleep ; stall RAW                                   ; pc=0x1700
    lw x6, -32(x17) ; mid1                              ; pc=0x1704
    sleep ; stall RAW                                   ; pc=0x1708
    sleep ; stall RAW                                   ; pc=0x170C
    sleep ; stall RAW                                   ; pc=0x1710
    xor x3, x4, x6                                      ; pc=0x1714
    sleep ; stall RAW                                   ; pc=0x1718
    sleep ; stall RAW                                   ; pc=0x171C
    sleep ; stall RAW                                   ; pc=0x1720
    lw x6, -36(x17) ; right1                            ; pc=0x1724
    sleep ; stall RAW                                   ; pc=0x1728
    sleep ; stall RAW                                   ; pc=0x172C
    sleep ; stall RAW                                   ; pc=0x1730
    xor x4, x3, x6                                      ; pc=0x1734
    sleep ; stall RAW                                   ; pc=0x1738
    sleep ; stall RAW                                   ; pc=0x173C
    sleep ; stall RAW                                   ; pc=0x1740
    sub x6, x5, x4                                      ; pc=0x1744
    sleep ; stall RAW                                   ; pc=0x1748
    sleep ; stall RAW                                   ; pc=0x174C
    sleep ; stall RAW                                   ; pc=0x1750
    sw x6, -16(x17) ; v1                                ; pc=0x1754
    lw x6, -16(x17) ; v1                                ; pc=0x1758
    sleep ; stall RAW                                   ; pc=0x175C
    sleep ; stall RAW                                   ; pc=0x1760
    sleep ; stall RAW                                   ; pc=0x1764
    addi x4, x0, 0                                      ; pc=0x1768
    sleep ; stall RAW                                   ; pc=0x176C
    sleep ; stall RAW                                   ; pc=0x1770
    sleep ; stall RAW                                   ; pc=0x1774
    add x5, x4, x4                                      ; pc=0x1778
    sleep ; stall RAW                                   ; pc=0x177C
    sleep ; stall RAW                                   ; pc=0x1780
    sleep ; stall RAW                                   ; pc=0x1784
    add x5, x5, x5                                      ; pc=0x1788
    sleep ; stall RAW                                   ; pc=0x178C
    sleep ; stall RAW                                   ; pc=0x1790
    sleep ; stall RAW                                   ; pc=0x1794
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x1798
    sleep ; stall RAW                                   ; pc=0x179C
    sleep ; stall RAW                                   ; pc=0x17A0
    sleep ; stall RAW                                   ; pc=0x17A4
    add x3, x3, x5                                      ; pc=0x17A8
    sleep ; stall RAW                                   ; pc=0x17AC
    sleep ; stall RAW                                   ; pc=0x17B0
    sleep ; stall RAW                                   ; pc=0x17B4
    lw x5, 0(x3)                                        ; pc=0x17B8
    sleep ; stall RAW                                   ; pc=0x17BC
    sleep ; stall RAW                                   ; pc=0x17C0
    sleep ; stall RAW                                   ; pc=0x17C4
    addi x4, x0, 4                                      ; pc=0x17C8
    sleep ; stall RAW                                   ; pc=0x17CC
    sleep ; stall RAW                                   ; pc=0x17D0
    sleep ; stall RAW                                   ; pc=0x17D4
    sll x3, x6, x4                                      ; pc=0x17D8
    sleep ; stall RAW                                   ; pc=0x17DC
    sleep ; stall RAW                                   ; pc=0x17E0
    sleep ; stall RAW                                   ; pc=0x17E4
    add x3, x3, x5                                      ; pc=0x17E8
    sleep ; stall RAW                                   ; pc=0x17EC
    sleep ; stall RAW                                   ; pc=0x17F0
    sleep ; stall RAW                                   ; pc=0x17F4
    sw x3, -40(x17) ; left0                             ; pc=0x17F8
    lw x3, -16(x17) ; v1                                ; pc=0x17FC
    sleep ; stall RAW                                   ; pc=0x1800
    sleep ; stall RAW                                   ; pc=0x1804
    sleep ; stall RAW                                   ; pc=0x1808
    lw x5, -20(x17) ; sum                               ; pc=0x180C
    sleep ; stall RAW                                   ; pc=0x1810
    sleep ; stall RAW                                   ; pc=0x1814
    sleep ; stall RAW                                   ; pc=0x1818
    add x6, x3, x5                                      ; pc=0x181C
    sleep ; stall RAW                                   ; pc=0x1820
    sleep ; stall RAW                                   ; pc=0x1824
    sleep ; stall RAW                                   ; pc=0x1828
    sw x6, -44(x17) ; mid0                              ; pc=0x182C
    lw x6, -16(x17) ; v1                                ; pc=0x1830
    sleep ; stall RAW                                   ; pc=0x1834
    sleep ; stall RAW                                   ; pc=0x1838
    sleep ; stall RAW                                   ; pc=0x183C
    addi x5, x0, 1                                      ; pc=0x1840
    sleep ; stall RAW                                   ; pc=0x1844
    sleep ; stall RAW                                   ; pc=0x1848
    sleep ; stall RAW                                   ; pc=0x184C
    add x3, x5, x5                                      ; pc=0x1850
    sleep ; stall RAW                                   ; pc=0x1854
    sleep ; stall RAW                                   ; pc=0x1858
    sleep ; stall RAW                                   ; pc=0x185C
    add x3, x3, x3                                      ; pc=0x1860
    sleep ; stall RAW                                   ; pc=0x1864
    sleep ; stall RAW                                   ; pc=0x1868
    sleep ; stall RAW                                   ; pc=0x186C
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x1870
    sleep ; stall RAW                                   ; pc=0x1874
    sleep ; stall RAW                                   ; pc=0x1878
    sleep ; stall RAW                                   ; pc=0x187C
    add x4, x4, x3                                      ; pc=0x1880
    sleep ; stall RAW                                   ; pc=0x1884
    sleep ; stall RAW                                   ; pc=0x1888
    sleep ; stall RAW                                   ; pc=0x188C
    lw x3, 0(x4)                                        ; pc=0x1890
    sleep ; stall RAW                                   ; pc=0x1894
    sleep ; stall RAW                                   ; pc=0x1898
    sleep ; stall RAW                                   ; pc=0x189C
    addi x5, x0, 5                                      ; pc=0x18A0
    sleep ; stall RAW                                   ; pc=0x18A4
    sleep ; stall RAW                                   ; pc=0x18A8
    sleep ; stall RAW                                   ; pc=0x18AC
    srl x4, x6, x5                                      ; pc=0x18B0
    sleep ; stall RAW                                   ; pc=0x18B4
    sleep ; stall RAW                                   ; pc=0x18B8
    sleep ; stall RAW                                   ; pc=0x18BC
    add x4, x4, x3                                      ; pc=0x18C0
    sleep ; stall RAW                                   ; pc=0x18C4
    sleep ; stall RAW                                   ; pc=0x18C8
    sleep ; stall RAW                                   ; pc=0x18CC
    sw x4, -48(x17) ; right0                            ; pc=0x18D0
    lw x4, -12(x17) ; v0                                ; pc=0x18D4
    sleep ; stall RAW                                   ; pc=0x18D8
    sleep ; stall RAW                                   ; pc=0x18DC
    sleep ; stall RAW                                   ; pc=0x18E0
    lw x3, -40(x17) ; left0                             ; pc=0x18E4
    sleep ; stall RAW                                   ; pc=0x18E8
    sleep ; stall RAW                                   ; pc=0x18EC
    sleep ; stall RAW                                   ; pc=0x18F0
    lw x6, -44(x17) ; mid0                              ; pc=0x18F4
    sleep ; stall RAW                                   ; pc=0x18F8
    sleep ; stall RAW                                   ; pc=0x18FC
    sleep ; stall RAW                                   ; pc=0x1900
    xor x5, x3, x6                                      ; pc=0x1904
    sleep ; stall RAW                                   ; pc=0x1908
    sleep ; stall RAW                                   ; pc=0x190C
    sleep ; stall RAW                                   ; pc=0x1910
    lw x6, -48(x17) ; right0                            ; pc=0x1914
    sleep ; stall RAW                                   ; pc=0x1918
    sleep ; stall RAW                                   ; pc=0x191C
    sleep ; stall RAW                                   ; pc=0x1920
    xor x3, x5, x6                                      ; pc=0x1924
    sleep ; stall RAW                                   ; pc=0x1928
    sleep ; stall RAW                                   ; pc=0x192C
    sleep ; stall RAW                                   ; pc=0x1930
    sub x6, x4, x3                                      ; pc=0x1934
    sleep ; stall RAW                                   ; pc=0x1938
    sleep ; stall RAW                                   ; pc=0x193C
    sleep ; stall RAW                                   ; pc=0x1940
    sw x6, -12(x17) ; v0                                ; pc=0x1944
    lw x6, -20(x17) ; sum                               ; pc=0x1948
    sleep ; stall RAW                                   ; pc=0x194C
    sleep ; stall RAW                                   ; pc=0x1950
    sleep ; stall RAW                                   ; pc=0x1954
    addiHIGH x4, x0, 0                                  ; pc=0x1958
    sleep ; stall RAW                                   ; pc=0x195C
    sleep ; stall RAW                                   ; pc=0x1960
    sleep ; stall RAW                                   ; pc=0x1964
    addi x4, x4, 64496                                  ; pc=0x1968
    sleep ; stall RAW                                   ; pc=0x196C
    sleep ; stall RAW                                   ; pc=0x1970
    sleep ; stall RAW                                   ; pc=0x1974
    lw x3, 0(x4) ; DELTA                                ; pc=0x1978
    sleep ; stall RAW                                   ; pc=0x197C
    sleep ; stall RAW                                   ; pc=0x1980
    sleep ; stall RAW                                   ; pc=0x1984
    sub x4, x6, x3                                      ; pc=0x1988
    sleep ; stall RAW                                   ; pc=0x198C
    sleep ; stall RAW                                   ; pc=0x1990
    sleep ; stall RAW                                   ; pc=0x1994
    sw x4, -20(x17) ; sum                               ; pc=0x1998
    lw x4, -24(x17) ; i                                 ; pc=0x199C
    sleep ; stall RAW                                   ; pc=0x19A0
    sleep ; stall RAW                                   ; pc=0x19A4
    sleep ; stall RAW                                   ; pc=0x19A8
    addi x3, x0, 1                                      ; pc=0x19AC
    sleep ; stall RAW                                   ; pc=0x19B0
    sleep ; stall RAW                                   ; pc=0x19B4
    sleep ; stall RAW                                   ; pc=0x19B8
    add x6, x4, x3                                      ; pc=0x19BC
    sleep ; stall RAW                                   ; pc=0x19C0
    sleep ; stall RAW                                   ; pc=0x19C4
    sleep ; stall RAW                                   ; pc=0x19C8
    sw x6, -24(x17) ; i                                 ; pc=0x19CC
    jal x0, -1172                                       ; pc=0x19D0 ; target=.L2_for_start ; addr=0x153C
    sleep ; nop despues de control                      ; pc=0x19D4
    sleep ; nop despues de control                      ; pc=0x19D8
.L3_for_end:

    lw x6, -12(x17) ; v0                                ; pc=0x19DC
    sleep ; stall RAW                                   ; pc=0x19E0
    sleep ; stall RAW                                   ; pc=0x19E4
    sleep ; stall RAW                                   ; pc=0x19E8
    addi x3, x0, 0                                      ; pc=0x19EC
    sleep ; stall RAW                                   ; pc=0x19F0
    sleep ; stall RAW                                   ; pc=0x19F4
    sleep ; stall RAW                                   ; pc=0x19F8
    add x4, x3, x3                                      ; pc=0x19FC
    sleep ; stall RAW                                   ; pc=0x1A00
    sleep ; stall RAW                                   ; pc=0x1A04
    sleep ; stall RAW                                   ; pc=0x1A08
    add x4, x4, x4                                      ; pc=0x1A0C
    sleep ; stall RAW                                   ; pc=0x1A10
    sleep ; stall RAW                                   ; pc=0x1A14
    sleep ; stall RAW                                   ; pc=0x1A18
    lw x5, -4(x17) ; base ref v                         ; pc=0x1A1C
    sleep ; stall RAW                                   ; pc=0x1A20
    sleep ; stall RAW                                   ; pc=0x1A24
    sleep ; stall RAW                                   ; pc=0x1A28
    add x5, x5, x4                                      ; pc=0x1A2C
    sleep ; stall RAW                                   ; pc=0x1A30
    sleep ; stall RAW                                   ; pc=0x1A34
    sleep ; stall RAW                                   ; pc=0x1A38
    sw x6, 0(x5)                                        ; pc=0x1A3C
    lw x6, -16(x17) ; v1                                ; pc=0x1A40
    sleep ; stall RAW                                   ; pc=0x1A44
    sleep ; stall RAW                                   ; pc=0x1A48
    sleep ; stall RAW                                   ; pc=0x1A4C
    addi x5, x0, 1                                      ; pc=0x1A50
    sleep ; stall RAW                                   ; pc=0x1A54
    sleep ; stall RAW                                   ; pc=0x1A58
    sleep ; stall RAW                                   ; pc=0x1A5C
    add x4, x5, x5                                      ; pc=0x1A60
    sleep ; stall RAW                                   ; pc=0x1A64
    sleep ; stall RAW                                   ; pc=0x1A68
    sleep ; stall RAW                                   ; pc=0x1A6C
    add x4, x4, x4                                      ; pc=0x1A70
    sleep ; stall RAW                                   ; pc=0x1A74
    sleep ; stall RAW                                   ; pc=0x1A78
    sleep ; stall RAW                                   ; pc=0x1A7C
    lw x3, -4(x17) ; base ref v                         ; pc=0x1A80
    sleep ; stall RAW                                   ; pc=0x1A84
    sleep ; stall RAW                                   ; pc=0x1A88
    sleep ; stall RAW                                   ; pc=0x1A8C
    add x3, x3, x4                                      ; pc=0x1A90
    sleep ; stall RAW                                   ; pc=0x1A94
    sleep ; stall RAW                                   ; pc=0x1A98
    sleep ; stall RAW                                   ; pc=0x1A9C
    sw x6, 0(x3)                                        ; pc=0x1AA0
.L_codegen_3_tea_decrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x1AA4
    sleep ; stall RAW                                   ; pc=0x1AA8
    sleep ; stall RAW                                   ; pc=0x1AAC
    sleep ; stall RAW                                   ; pc=0x1AB0
    lw x17, 4(x2)                                       ; pc=0x1AB4
    sleep ; stall RAW                                   ; pc=0x1AB8
    sleep ; stall RAW                                   ; pc=0x1ABC
    sleep ; stall RAW                                   ; pc=0x1AC0
    addi x2, x2, 60                                     ; pc=0x1AC4
    sleep ; stall RAW                                   ; pc=0x1AC8
    sleep ; stall RAW                                   ; pc=0x1ACC
    sleep ; stall RAW                                   ; pc=0x1AD0
    jalr x1, 0                                          ; pc=0x1AD4
    sleep ; nop despues de control                      ; pc=0x1AD8
    sleep ; nop despues de control                      ; pc=0x1ADC