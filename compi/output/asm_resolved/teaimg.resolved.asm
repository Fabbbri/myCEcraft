; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0020
;   main = 0x0020
;   .L4_for_start = 0x007C
;   .L5_for_end = 0x0504
;   .L_codegen_1_main_end = 0x0530
;   tea_encrypt = 0x0554
;   .L0_for_start = 0x0674
;   .L1_for_end = 0x0B14
;   .L_codegen_2_tea_encrypt_end = 0x0BDC
;   tea_decrypt = 0x0C18
;   .L2_for_start = 0x0D58
;   .L3_for_end = 0x11F8
;   .L_codegen_3_tea_decrypt_end = 0x12C0

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0020, offset=32)
;   pc=0x00BC bge -> .L5_for_end (addr=0x0504, offset=1096)
;   pc=0x02F0 jal -> tea_decrypt (addr=0x0C18, offset=2344)
;   pc=0x04F8 jal -> .L4_for_start (addr=0x007C, offset=-1148)
;   pc=0x0524 jal -> .L_codegen_1_main_end (addr=0x0530, offset=12)
;   pc=0x0694 bge -> .L1_for_end (addr=0x0B14, offset=1152)
;   pc=0x0B08 jal -> .L0_for_start (addr=0x0674, offset=-1172)
;   pc=0x0D78 bge -> .L3_for_end (addr=0x11F8, offset=1152)
;   pc=0x11EC jal -> .L2_for_start (addr=0x0D58, offset=-1172)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.data
key: ; addr=0x8000
    .word 0xDEADCAFE
    .word 0xDEADCAFE
    .word 0xDEADCAFE
    .word 0xDEADCAFE
image_data: ; addr=0x8010
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
block: ; addr=0xE848
    .word 0
    .word 0
DELTA: ; addr=0xE850
    .word 0x9E3779B9
SUM_INIT: ; addr=0xE854
    .word 0xC6EF3720
IMAGE_WORDS: ; addr=0xE858
    .word 0x1A0E

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
    addiSigned x2, x2, -16                              ; pc=0x0040
    sleep ; stall RAW                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sw x1, 0(x2)                                        ; pc=0x0050
    sw x17, 4(x2)                                       ; pc=0x0054
    addi x17, x2, 16                                    ; pc=0x0058
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
    addi x5, x5, 59480                                  ; pc=0x009C
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
    ; base image_data
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
    addi x6, x6, 59464                                  ; pc=0x0178
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
    ; base image_data
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
    addi x5, x5, 59464                                  ; pc=0x026C
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
    addi x6, x6, 59464                                  ; pc=0x02A0
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
    jal x1, 2344                                        ; pc=0x02F0 ; target=tea_decrypt ; addr=0x0C18
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
    addi x4, x4, 59464                                  ; pc=0x033C
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
    addi x3, x3, 32784                                  ; pc=0x03AC
    sleep ; stall RAW                                   ; pc=0x03B0
    sleep ; stall RAW                                   ; pc=0x03B4
    sleep ; stall RAW                                   ; pc=0x03B8
    ; base image_data
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
    addi x6, x6, 59464                                  ; pc=0x0410
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
    addi x6, x6, 32784                                  ; pc=0x04A0
    sleep ; stall RAW                                   ; pc=0x04A4
    sleep ; stall RAW                                   ; pc=0x04A8
    sleep ; stall RAW                                   ; pc=0x04AC
    ; base image_data
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

    addi x5, x0, 0                                      ; pc=0x0504
    sleep ; stall RAW                                   ; pc=0x0508
    sleep ; stall RAW                                   ; pc=0x050C
    sleep ; stall RAW                                   ; pc=0x0510
    add x11, x5, x0                                     ; pc=0x0514
    sleep ; stall RAW                                   ; pc=0x0518
    sleep ; stall RAW                                   ; pc=0x051C
    sleep ; stall RAW                                   ; pc=0x0520
    jal x0, 12                                          ; pc=0x0524 ; target=.L_codegen_1_main_end ; addr=0x0530
    sleep ; nop despues de control                      ; pc=0x0528
    sleep ; nop despues de control                      ; pc=0x052C
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0530
    sleep ; stall RAW                                   ; pc=0x0534
    sleep ; stall RAW                                   ; pc=0x0538
    sleep ; stall RAW                                   ; pc=0x053C
    addi x2, x2, 16                                     ; pc=0x0540
    sleep ; stall RAW                                   ; pc=0x0544
    sleep ; stall RAW                                   ; pc=0x0548
    sleep ; stall RAW                                   ; pc=0x054C
    freeze                                              ; pc=0x0550

tea_encrypt:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x0554
    sleep ; stall RAW                                   ; pc=0x0558
    sleep ; stall RAW                                   ; pc=0x055C
    sleep ; stall RAW                                   ; pc=0x0560
    sw x1, 0(x2)                                        ; pc=0x0564
    sw x17, 4(x2)                                       ; pc=0x0568
    addi x17, x2, 60                                    ; pc=0x056C
    sleep ; stall RAW                                   ; pc=0x0570
    sleep ; stall RAW                                   ; pc=0x0574
    sleep ; stall RAW                                   ; pc=0x0578

    sw x11, -4(x17) ; parámetro v                       ; pc=0x057C
    sw x12, -8(x17) ; parámetro tea_key                 ; pc=0x0580

    addi x5, x0, 0                                      ; pc=0x0584
    sleep ; stall RAW                                   ; pc=0x0588
    sleep ; stall RAW                                   ; pc=0x058C
    sleep ; stall RAW                                   ; pc=0x0590
    add x6, x5, x5                                      ; pc=0x0594
    sleep ; stall RAW                                   ; pc=0x0598
    sleep ; stall RAW                                   ; pc=0x059C
    sleep ; stall RAW                                   ; pc=0x05A0
    add x6, x6, x6                                      ; pc=0x05A4
    sleep ; stall RAW                                   ; pc=0x05A8
    sleep ; stall RAW                                   ; pc=0x05AC
    sleep ; stall RAW                                   ; pc=0x05B0
    lw x3, -4(x17) ; base ref v                         ; pc=0x05B4
    sleep ; stall RAW                                   ; pc=0x05B8
    sleep ; stall RAW                                   ; pc=0x05BC
    sleep ; stall RAW                                   ; pc=0x05C0
    add x3, x3, x6                                      ; pc=0x05C4
    sleep ; stall RAW                                   ; pc=0x05C8
    sleep ; stall RAW                                   ; pc=0x05CC
    sleep ; stall RAW                                   ; pc=0x05D0
    lw x6, 0(x3)                                        ; pc=0x05D4
    sleep ; stall RAW                                   ; pc=0x05D8
    sleep ; stall RAW                                   ; pc=0x05DC
    sleep ; stall RAW                                   ; pc=0x05E0
    sw x6, -12(x17) ; v0                                ; pc=0x05E4
    addi x6, x0, 1                                      ; pc=0x05E8
    sleep ; stall RAW                                   ; pc=0x05EC
    sleep ; stall RAW                                   ; pc=0x05F0
    sleep ; stall RAW                                   ; pc=0x05F4
    add x3, x6, x6                                      ; pc=0x05F8
    sleep ; stall RAW                                   ; pc=0x05FC
    sleep ; stall RAW                                   ; pc=0x0600
    sleep ; stall RAW                                   ; pc=0x0604
    add x3, x3, x3                                      ; pc=0x0608
    sleep ; stall RAW                                   ; pc=0x060C
    sleep ; stall RAW                                   ; pc=0x0610
    sleep ; stall RAW                                   ; pc=0x0614
    lw x5, -4(x17) ; base ref v                         ; pc=0x0618
    sleep ; stall RAW                                   ; pc=0x061C
    sleep ; stall RAW                                   ; pc=0x0620
    sleep ; stall RAW                                   ; pc=0x0624
    add x5, x5, x3                                      ; pc=0x0628
    sleep ; stall RAW                                   ; pc=0x062C
    sleep ; stall RAW                                   ; pc=0x0630
    sleep ; stall RAW                                   ; pc=0x0634
    lw x3, 0(x5)                                        ; pc=0x0638
    sleep ; stall RAW                                   ; pc=0x063C
    sleep ; stall RAW                                   ; pc=0x0640
    sleep ; stall RAW                                   ; pc=0x0644
    sw x3, -16(x17) ; v1                                ; pc=0x0648
    addi x3, x0, 0                                      ; pc=0x064C
    sleep ; stall RAW                                   ; pc=0x0650
    sleep ; stall RAW                                   ; pc=0x0654
    sleep ; stall RAW                                   ; pc=0x0658
    sw x3, -20(x17) ; sum                               ; pc=0x065C

    ; for
    addi x3, x0, 0                                      ; pc=0x0660
    sleep ; stall RAW                                   ; pc=0x0664
    sleep ; stall RAW                                   ; pc=0x0668
    sleep ; stall RAW                                   ; pc=0x066C
    sw x3, -24(x17) ; i                                 ; pc=0x0670
.L0_for_start:
    lw x3, -24(x17) ; i                                 ; pc=0x0674
    sleep ; stall RAW                                   ; pc=0x0678
    sleep ; stall RAW                                   ; pc=0x067C
    sleep ; stall RAW                                   ; pc=0x0680
    addi x5, x0, 32                                     ; pc=0x0684
    sleep ; stall RAW                                   ; pc=0x0688
    sleep ; stall RAW                                   ; pc=0x068C
    sleep ; stall RAW                                   ; pc=0x0690
    bge x3, x5, 1152                                    ; pc=0x0694 ; target=.L1_for_end ; addr=0x0B14
    sleep ; nop despues de control                      ; pc=0x0698
    sleep ; nop despues de control                      ; pc=0x069C
    lw x5, -20(x17) ; sum                               ; pc=0x06A0
    sleep ; stall RAW                                   ; pc=0x06A4
    sleep ; stall RAW                                   ; pc=0x06A8
    sleep ; stall RAW                                   ; pc=0x06AC
    addiHIGH x6, x0, 0                                  ; pc=0x06B0
    sleep ; stall RAW                                   ; pc=0x06B4
    sleep ; stall RAW                                   ; pc=0x06B8
    sleep ; stall RAW                                   ; pc=0x06BC
    addi x6, x6, 59472                                  ; pc=0x06C0
    sleep ; stall RAW                                   ; pc=0x06C4
    sleep ; stall RAW                                   ; pc=0x06C8
    sleep ; stall RAW                                   ; pc=0x06CC
    lw x3, 0(x6) ; DELTA                                ; pc=0x06D0
    sleep ; stall RAW                                   ; pc=0x06D4
    sleep ; stall RAW                                   ; pc=0x06D8
    sleep ; stall RAW                                   ; pc=0x06DC
    add x6, x5, x3                                      ; pc=0x06E0
    sleep ; stall RAW                                   ; pc=0x06E4
    sleep ; stall RAW                                   ; pc=0x06E8
    sleep ; stall RAW                                   ; pc=0x06EC
    sw x6, -20(x17) ; sum                               ; pc=0x06F0
    lw x6, -16(x17) ; v1                                ; pc=0x06F4
    sleep ; stall RAW                                   ; pc=0x06F8
    sleep ; stall RAW                                   ; pc=0x06FC
    sleep ; stall RAW                                   ; pc=0x0700
    addi x3, x0, 0                                      ; pc=0x0704
    sleep ; stall RAW                                   ; pc=0x0708
    sleep ; stall RAW                                   ; pc=0x070C
    sleep ; stall RAW                                   ; pc=0x0710
    add x5, x3, x3                                      ; pc=0x0714
    sleep ; stall RAW                                   ; pc=0x0718
    sleep ; stall RAW                                   ; pc=0x071C
    sleep ; stall RAW                                   ; pc=0x0720
    add x5, x5, x5                                      ; pc=0x0724
    sleep ; stall RAW                                   ; pc=0x0728
    sleep ; stall RAW                                   ; pc=0x072C
    sleep ; stall RAW                                   ; pc=0x0730
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x0734
    sleep ; stall RAW                                   ; pc=0x0738
    sleep ; stall RAW                                   ; pc=0x073C
    sleep ; stall RAW                                   ; pc=0x0740
    add x4, x4, x5                                      ; pc=0x0744
    sleep ; stall RAW                                   ; pc=0x0748
    sleep ; stall RAW                                   ; pc=0x074C
    sleep ; stall RAW                                   ; pc=0x0750
    lw x5, 0(x4)                                        ; pc=0x0754
    sleep ; stall RAW                                   ; pc=0x0758
    sleep ; stall RAW                                   ; pc=0x075C
    sleep ; stall RAW                                   ; pc=0x0760
    addi x3, x0, 4                                      ; pc=0x0764
    sleep ; stall RAW                                   ; pc=0x0768
    sleep ; stall RAW                                   ; pc=0x076C
    sleep ; stall RAW                                   ; pc=0x0770
    sll x4, x6, x3                                      ; pc=0x0774
    sleep ; stall RAW                                   ; pc=0x0778
    sleep ; stall RAW                                   ; pc=0x077C
    sleep ; stall RAW                                   ; pc=0x0780
    add x4, x4, x5                                      ; pc=0x0784
    sleep ; stall RAW                                   ; pc=0x0788
    sleep ; stall RAW                                   ; pc=0x078C
    sleep ; stall RAW                                   ; pc=0x0790
    sw x4, -28(x17) ; left0                             ; pc=0x0794
    lw x4, -16(x17) ; v1                                ; pc=0x0798
    sleep ; stall RAW                                   ; pc=0x079C
    sleep ; stall RAW                                   ; pc=0x07A0
    sleep ; stall RAW                                   ; pc=0x07A4
    lw x5, -20(x17) ; sum                               ; pc=0x07A8
    sleep ; stall RAW                                   ; pc=0x07AC
    sleep ; stall RAW                                   ; pc=0x07B0
    sleep ; stall RAW                                   ; pc=0x07B4
    add x6, x4, x5                                      ; pc=0x07B8
    sleep ; stall RAW                                   ; pc=0x07BC
    sleep ; stall RAW                                   ; pc=0x07C0
    sleep ; stall RAW                                   ; pc=0x07C4
    sw x6, -32(x17) ; mid0                              ; pc=0x07C8
    lw x6, -16(x17) ; v1                                ; pc=0x07CC
    sleep ; stall RAW                                   ; pc=0x07D0
    sleep ; stall RAW                                   ; pc=0x07D4
    sleep ; stall RAW                                   ; pc=0x07D8
    addi x5, x0, 1                                      ; pc=0x07DC
    sleep ; stall RAW                                   ; pc=0x07E0
    sleep ; stall RAW                                   ; pc=0x07E4
    sleep ; stall RAW                                   ; pc=0x07E8
    add x4, x5, x5                                      ; pc=0x07EC
    sleep ; stall RAW                                   ; pc=0x07F0
    sleep ; stall RAW                                   ; pc=0x07F4
    sleep ; stall RAW                                   ; pc=0x07F8
    add x4, x4, x4                                      ; pc=0x07FC
    sleep ; stall RAW                                   ; pc=0x0800
    sleep ; stall RAW                                   ; pc=0x0804
    sleep ; stall RAW                                   ; pc=0x0808
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x080C
    sleep ; stall RAW                                   ; pc=0x0810
    sleep ; stall RAW                                   ; pc=0x0814
    sleep ; stall RAW                                   ; pc=0x0818
    add x3, x3, x4                                      ; pc=0x081C
    sleep ; stall RAW                                   ; pc=0x0820
    sleep ; stall RAW                                   ; pc=0x0824
    sleep ; stall RAW                                   ; pc=0x0828
    lw x4, 0(x3)                                        ; pc=0x082C
    sleep ; stall RAW                                   ; pc=0x0830
    sleep ; stall RAW                                   ; pc=0x0834
    sleep ; stall RAW                                   ; pc=0x0838
    addi x5, x0, 5                                      ; pc=0x083C
    sleep ; stall RAW                                   ; pc=0x0840
    sleep ; stall RAW                                   ; pc=0x0844
    sleep ; stall RAW                                   ; pc=0x0848
    srl x3, x6, x5                                      ; pc=0x084C
    sleep ; stall RAW                                   ; pc=0x0850
    sleep ; stall RAW                                   ; pc=0x0854
    sleep ; stall RAW                                   ; pc=0x0858
    add x3, x3, x4                                      ; pc=0x085C
    sleep ; stall RAW                                   ; pc=0x0860
    sleep ; stall RAW                                   ; pc=0x0864
    sleep ; stall RAW                                   ; pc=0x0868
    sw x3, -36(x17) ; right0                            ; pc=0x086C
    lw x3, -12(x17) ; v0                                ; pc=0x0870
    sleep ; stall RAW                                   ; pc=0x0874
    sleep ; stall RAW                                   ; pc=0x0878
    sleep ; stall RAW                                   ; pc=0x087C
    lw x4, -28(x17) ; left0                             ; pc=0x0880
    sleep ; stall RAW                                   ; pc=0x0884
    sleep ; stall RAW                                   ; pc=0x0888
    sleep ; stall RAW                                   ; pc=0x088C
    lw x6, -32(x17) ; mid0                              ; pc=0x0890
    sleep ; stall RAW                                   ; pc=0x0894
    sleep ; stall RAW                                   ; pc=0x0898
    sleep ; stall RAW                                   ; pc=0x089C
    xor x5, x4, x6                                      ; pc=0x08A0
    sleep ; stall RAW                                   ; pc=0x08A4
    sleep ; stall RAW                                   ; pc=0x08A8
    sleep ; stall RAW                                   ; pc=0x08AC
    lw x6, -36(x17) ; right0                            ; pc=0x08B0
    sleep ; stall RAW                                   ; pc=0x08B4
    sleep ; stall RAW                                   ; pc=0x08B8
    sleep ; stall RAW                                   ; pc=0x08BC
    xor x4, x5, x6                                      ; pc=0x08C0
    sleep ; stall RAW                                   ; pc=0x08C4
    sleep ; stall RAW                                   ; pc=0x08C8
    sleep ; stall RAW                                   ; pc=0x08CC
    add x6, x3, x4                                      ; pc=0x08D0
    sleep ; stall RAW                                   ; pc=0x08D4
    sleep ; stall RAW                                   ; pc=0x08D8
    sleep ; stall RAW                                   ; pc=0x08DC
    sw x6, -12(x17) ; v0                                ; pc=0x08E0
    lw x6, -12(x17) ; v0                                ; pc=0x08E4
    sleep ; stall RAW                                   ; pc=0x08E8
    sleep ; stall RAW                                   ; pc=0x08EC
    sleep ; stall RAW                                   ; pc=0x08F0
    addi x4, x0, 2                                      ; pc=0x08F4
    sleep ; stall RAW                                   ; pc=0x08F8
    sleep ; stall RAW                                   ; pc=0x08FC
    sleep ; stall RAW                                   ; pc=0x0900
    add x3, x4, x4                                      ; pc=0x0904
    sleep ; stall RAW                                   ; pc=0x0908
    sleep ; stall RAW                                   ; pc=0x090C
    sleep ; stall RAW                                   ; pc=0x0910
    add x3, x3, x3                                      ; pc=0x0914
    sleep ; stall RAW                                   ; pc=0x0918
    sleep ; stall RAW                                   ; pc=0x091C
    sleep ; stall RAW                                   ; pc=0x0920
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x0924
    sleep ; stall RAW                                   ; pc=0x0928
    sleep ; stall RAW                                   ; pc=0x092C
    sleep ; stall RAW                                   ; pc=0x0930
    add x5, x5, x3                                      ; pc=0x0934
    sleep ; stall RAW                                   ; pc=0x0938
    sleep ; stall RAW                                   ; pc=0x093C
    sleep ; stall RAW                                   ; pc=0x0940
    lw x3, 0(x5)                                        ; pc=0x0944
    sleep ; stall RAW                                   ; pc=0x0948
    sleep ; stall RAW                                   ; pc=0x094C
    sleep ; stall RAW                                   ; pc=0x0950
    addi x4, x0, 4                                      ; pc=0x0954
    sleep ; stall RAW                                   ; pc=0x0958
    sleep ; stall RAW                                   ; pc=0x095C
    sleep ; stall RAW                                   ; pc=0x0960
    sll x5, x6, x4                                      ; pc=0x0964
    sleep ; stall RAW                                   ; pc=0x0968
    sleep ; stall RAW                                   ; pc=0x096C
    sleep ; stall RAW                                   ; pc=0x0970
    add x5, x5, x3                                      ; pc=0x0974
    sleep ; stall RAW                                   ; pc=0x0978
    sleep ; stall RAW                                   ; pc=0x097C
    sleep ; stall RAW                                   ; pc=0x0980
    sw x5, -40(x17) ; left1                             ; pc=0x0984
    lw x5, -12(x17) ; v0                                ; pc=0x0988
    sleep ; stall RAW                                   ; pc=0x098C
    sleep ; stall RAW                                   ; pc=0x0990
    sleep ; stall RAW                                   ; pc=0x0994
    lw x3, -20(x17) ; sum                               ; pc=0x0998
    sleep ; stall RAW                                   ; pc=0x099C
    sleep ; stall RAW                                   ; pc=0x09A0
    sleep ; stall RAW                                   ; pc=0x09A4
    add x6, x5, x3                                      ; pc=0x09A8
    sleep ; stall RAW                                   ; pc=0x09AC
    sleep ; stall RAW                                   ; pc=0x09B0
    sleep ; stall RAW                                   ; pc=0x09B4
    sw x6, -44(x17) ; mid1                              ; pc=0x09B8
    lw x6, -12(x17) ; v0                                ; pc=0x09BC
    sleep ; stall RAW                                   ; pc=0x09C0
    sleep ; stall RAW                                   ; pc=0x09C4
    sleep ; stall RAW                                   ; pc=0x09C8
    addi x3, x0, 3                                      ; pc=0x09CC
    sleep ; stall RAW                                   ; pc=0x09D0
    sleep ; stall RAW                                   ; pc=0x09D4
    sleep ; stall RAW                                   ; pc=0x09D8
    add x5, x3, x3                                      ; pc=0x09DC
    sleep ; stall RAW                                   ; pc=0x09E0
    sleep ; stall RAW                                   ; pc=0x09E4
    sleep ; stall RAW                                   ; pc=0x09E8
    add x5, x5, x5                                      ; pc=0x09EC
    sleep ; stall RAW                                   ; pc=0x09F0
    sleep ; stall RAW                                   ; pc=0x09F4
    sleep ; stall RAW                                   ; pc=0x09F8
    lw x4, -8(x17) ; base ref tea_key                   ; pc=0x09FC
    sleep ; stall RAW                                   ; pc=0x0A00
    sleep ; stall RAW                                   ; pc=0x0A04
    sleep ; stall RAW                                   ; pc=0x0A08
    add x4, x4, x5                                      ; pc=0x0A0C
    sleep ; stall RAW                                   ; pc=0x0A10
    sleep ; stall RAW                                   ; pc=0x0A14
    sleep ; stall RAW                                   ; pc=0x0A18
    lw x5, 0(x4)                                        ; pc=0x0A1C
    sleep ; stall RAW                                   ; pc=0x0A20
    sleep ; stall RAW                                   ; pc=0x0A24
    sleep ; stall RAW                                   ; pc=0x0A28
    addi x3, x0, 5                                      ; pc=0x0A2C
    sleep ; stall RAW                                   ; pc=0x0A30
    sleep ; stall RAW                                   ; pc=0x0A34
    sleep ; stall RAW                                   ; pc=0x0A38
    srl x4, x6, x3                                      ; pc=0x0A3C
    sleep ; stall RAW                                   ; pc=0x0A40
    sleep ; stall RAW                                   ; pc=0x0A44
    sleep ; stall RAW                                   ; pc=0x0A48
    add x4, x4, x5                                      ; pc=0x0A4C
    sleep ; stall RAW                                   ; pc=0x0A50
    sleep ; stall RAW                                   ; pc=0x0A54
    sleep ; stall RAW                                   ; pc=0x0A58
    sw x4, -48(x17) ; right1                            ; pc=0x0A5C
    lw x4, -16(x17) ; v1                                ; pc=0x0A60
    sleep ; stall RAW                                   ; pc=0x0A64
    sleep ; stall RAW                                   ; pc=0x0A68
    sleep ; stall RAW                                   ; pc=0x0A6C
    lw x5, -40(x17) ; left1                             ; pc=0x0A70
    sleep ; stall RAW                                   ; pc=0x0A74
    sleep ; stall RAW                                   ; pc=0x0A78
    sleep ; stall RAW                                   ; pc=0x0A7C
    lw x6, -44(x17) ; mid1                              ; pc=0x0A80
    sleep ; stall RAW                                   ; pc=0x0A84
    sleep ; stall RAW                                   ; pc=0x0A88
    sleep ; stall RAW                                   ; pc=0x0A8C
    xor x3, x5, x6                                      ; pc=0x0A90
    sleep ; stall RAW                                   ; pc=0x0A94
    sleep ; stall RAW                                   ; pc=0x0A98
    sleep ; stall RAW                                   ; pc=0x0A9C
    lw x6, -48(x17) ; right1                            ; pc=0x0AA0
    sleep ; stall RAW                                   ; pc=0x0AA4
    sleep ; stall RAW                                   ; pc=0x0AA8
    sleep ; stall RAW                                   ; pc=0x0AAC
    xor x5, x3, x6                                      ; pc=0x0AB0
    sleep ; stall RAW                                   ; pc=0x0AB4
    sleep ; stall RAW                                   ; pc=0x0AB8
    sleep ; stall RAW                                   ; pc=0x0ABC
    add x6, x4, x5                                      ; pc=0x0AC0
    sleep ; stall RAW                                   ; pc=0x0AC4
    sleep ; stall RAW                                   ; pc=0x0AC8
    sleep ; stall RAW                                   ; pc=0x0ACC
    sw x6, -16(x17) ; v1                                ; pc=0x0AD0
    lw x6, -24(x17) ; i                                 ; pc=0x0AD4
    sleep ; stall RAW                                   ; pc=0x0AD8
    sleep ; stall RAW                                   ; pc=0x0ADC
    sleep ; stall RAW                                   ; pc=0x0AE0
    addi x5, x0, 1                                      ; pc=0x0AE4
    sleep ; stall RAW                                   ; pc=0x0AE8
    sleep ; stall RAW                                   ; pc=0x0AEC
    sleep ; stall RAW                                   ; pc=0x0AF0
    add x4, x6, x5                                      ; pc=0x0AF4
    sleep ; stall RAW                                   ; pc=0x0AF8
    sleep ; stall RAW                                   ; pc=0x0AFC
    sleep ; stall RAW                                   ; pc=0x0B00
    sw x4, -24(x17) ; i                                 ; pc=0x0B04
    jal x0, -1172                                       ; pc=0x0B08 ; target=.L0_for_start ; addr=0x0674
    sleep ; nop despues de control                      ; pc=0x0B0C
    sleep ; nop despues de control                      ; pc=0x0B10
.L1_for_end:

    lw x4, -12(x17) ; v0                                ; pc=0x0B14
    sleep ; stall RAW                                   ; pc=0x0B18
    sleep ; stall RAW                                   ; pc=0x0B1C
    sleep ; stall RAW                                   ; pc=0x0B20
    addi x5, x0, 0                                      ; pc=0x0B24
    sleep ; stall RAW                                   ; pc=0x0B28
    sleep ; stall RAW                                   ; pc=0x0B2C
    sleep ; stall RAW                                   ; pc=0x0B30
    add x6, x5, x5                                      ; pc=0x0B34
    sleep ; stall RAW                                   ; pc=0x0B38
    sleep ; stall RAW                                   ; pc=0x0B3C
    sleep ; stall RAW                                   ; pc=0x0B40
    add x6, x6, x6                                      ; pc=0x0B44
    sleep ; stall RAW                                   ; pc=0x0B48
    sleep ; stall RAW                                   ; pc=0x0B4C
    sleep ; stall RAW                                   ; pc=0x0B50
    lw x3, -4(x17) ; base ref v                         ; pc=0x0B54
    sleep ; stall RAW                                   ; pc=0x0B58
    sleep ; stall RAW                                   ; pc=0x0B5C
    sleep ; stall RAW                                   ; pc=0x0B60
    add x3, x3, x6                                      ; pc=0x0B64
    sleep ; stall RAW                                   ; pc=0x0B68
    sleep ; stall RAW                                   ; pc=0x0B6C
    sleep ; stall RAW                                   ; pc=0x0B70
    sw x4, 0(x3)                                        ; pc=0x0B74
    lw x4, -16(x17) ; v1                                ; pc=0x0B78
    sleep ; stall RAW                                   ; pc=0x0B7C
    sleep ; stall RAW                                   ; pc=0x0B80
    sleep ; stall RAW                                   ; pc=0x0B84
    addi x3, x0, 1                                      ; pc=0x0B88
    sleep ; stall RAW                                   ; pc=0x0B8C
    sleep ; stall RAW                                   ; pc=0x0B90
    sleep ; stall RAW                                   ; pc=0x0B94
    add x6, x3, x3                                      ; pc=0x0B98
    sleep ; stall RAW                                   ; pc=0x0B9C
    sleep ; stall RAW                                   ; pc=0x0BA0
    sleep ; stall RAW                                   ; pc=0x0BA4
    add x6, x6, x6                                      ; pc=0x0BA8
    sleep ; stall RAW                                   ; pc=0x0BAC
    sleep ; stall RAW                                   ; pc=0x0BB0
    sleep ; stall RAW                                   ; pc=0x0BB4
    lw x5, -4(x17) ; base ref v                         ; pc=0x0BB8
    sleep ; stall RAW                                   ; pc=0x0BBC
    sleep ; stall RAW                                   ; pc=0x0BC0
    sleep ; stall RAW                                   ; pc=0x0BC4
    add x5, x5, x6                                      ; pc=0x0BC8
    sleep ; stall RAW                                   ; pc=0x0BCC
    sleep ; stall RAW                                   ; pc=0x0BD0
    sleep ; stall RAW                                   ; pc=0x0BD4
    sw x4, 0(x5)                                        ; pc=0x0BD8
.L_codegen_2_tea_encrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x0BDC
    sleep ; stall RAW                                   ; pc=0x0BE0
    sleep ; stall RAW                                   ; pc=0x0BE4
    sleep ; stall RAW                                   ; pc=0x0BE8
    lw x17, 4(x2)                                       ; pc=0x0BEC
    sleep ; stall RAW                                   ; pc=0x0BF0
    sleep ; stall RAW                                   ; pc=0x0BF4
    sleep ; stall RAW                                   ; pc=0x0BF8
    addi x2, x2, 60                                     ; pc=0x0BFC
    sleep ; stall RAW                                   ; pc=0x0C00
    sleep ; stall RAW                                   ; pc=0x0C04
    sleep ; stall RAW                                   ; pc=0x0C08
    jalr x1, 0                                          ; pc=0x0C0C
    sleep ; nop despues de control                      ; pc=0x0C10
    sleep ; nop despues de control                      ; pc=0x0C14

tea_decrypt:
    ; prologue
    addiSigned x2, x2, -60                              ; pc=0x0C18
    sleep ; stall RAW                                   ; pc=0x0C1C
    sleep ; stall RAW                                   ; pc=0x0C20
    sleep ; stall RAW                                   ; pc=0x0C24
    sw x1, 0(x2)                                        ; pc=0x0C28
    sw x17, 4(x2)                                       ; pc=0x0C2C
    addi x17, x2, 60                                    ; pc=0x0C30
    sleep ; stall RAW                                   ; pc=0x0C34
    sleep ; stall RAW                                   ; pc=0x0C38
    sleep ; stall RAW                                   ; pc=0x0C3C

    sw x11, -4(x17) ; parámetro v                       ; pc=0x0C40
    sw x12, -8(x17) ; parámetro tea_key                 ; pc=0x0C44

    addi x4, x0, 0                                      ; pc=0x0C48
    sleep ; stall RAW                                   ; pc=0x0C4C
    sleep ; stall RAW                                   ; pc=0x0C50
    sleep ; stall RAW                                   ; pc=0x0C54
    add x5, x4, x4                                      ; pc=0x0C58
    sleep ; stall RAW                                   ; pc=0x0C5C
    sleep ; stall RAW                                   ; pc=0x0C60
    sleep ; stall RAW                                   ; pc=0x0C64
    add x5, x5, x5                                      ; pc=0x0C68
    sleep ; stall RAW                                   ; pc=0x0C6C
    sleep ; stall RAW                                   ; pc=0x0C70
    sleep ; stall RAW                                   ; pc=0x0C74
    lw x6, -4(x17) ; base ref v                         ; pc=0x0C78
    sleep ; stall RAW                                   ; pc=0x0C7C
    sleep ; stall RAW                                   ; pc=0x0C80
    sleep ; stall RAW                                   ; pc=0x0C84
    add x6, x6, x5                                      ; pc=0x0C88
    sleep ; stall RAW                                   ; pc=0x0C8C
    sleep ; stall RAW                                   ; pc=0x0C90
    sleep ; stall RAW                                   ; pc=0x0C94
    lw x5, 0(x6)                                        ; pc=0x0C98
    sleep ; stall RAW                                   ; pc=0x0C9C
    sleep ; stall RAW                                   ; pc=0x0CA0
    sleep ; stall RAW                                   ; pc=0x0CA4
    sw x5, -12(x17) ; v0                                ; pc=0x0CA8
    addi x5, x0, 1                                      ; pc=0x0CAC
    sleep ; stall RAW                                   ; pc=0x0CB0
    sleep ; stall RAW                                   ; pc=0x0CB4
    sleep ; stall RAW                                   ; pc=0x0CB8
    add x6, x5, x5                                      ; pc=0x0CBC
    sleep ; stall RAW                                   ; pc=0x0CC0
    sleep ; stall RAW                                   ; pc=0x0CC4
    sleep ; stall RAW                                   ; pc=0x0CC8
    add x6, x6, x6                                      ; pc=0x0CCC
    sleep ; stall RAW                                   ; pc=0x0CD0
    sleep ; stall RAW                                   ; pc=0x0CD4
    sleep ; stall RAW                                   ; pc=0x0CD8
    lw x4, -4(x17) ; base ref v                         ; pc=0x0CDC
    sleep ; stall RAW                                   ; pc=0x0CE0
    sleep ; stall RAW                                   ; pc=0x0CE4
    sleep ; stall RAW                                   ; pc=0x0CE8
    add x4, x4, x6                                      ; pc=0x0CEC
    sleep ; stall RAW                                   ; pc=0x0CF0
    sleep ; stall RAW                                   ; pc=0x0CF4
    sleep ; stall RAW                                   ; pc=0x0CF8
    lw x6, 0(x4)                                        ; pc=0x0CFC
    sleep ; stall RAW                                   ; pc=0x0D00
    sleep ; stall RAW                                   ; pc=0x0D04
    sleep ; stall RAW                                   ; pc=0x0D08
    sw x6, -16(x17) ; v1                                ; pc=0x0D0C
    addiHIGH x4, x0, 0                                  ; pc=0x0D10
    sleep ; stall RAW                                   ; pc=0x0D14
    sleep ; stall RAW                                   ; pc=0x0D18
    sleep ; stall RAW                                   ; pc=0x0D1C
    addi x4, x4, 59476                                  ; pc=0x0D20
    sleep ; stall RAW                                   ; pc=0x0D24
    sleep ; stall RAW                                   ; pc=0x0D28
    sleep ; stall RAW                                   ; pc=0x0D2C
    lw x6, 0(x4) ; SUM_INIT                             ; pc=0x0D30
    sleep ; stall RAW                                   ; pc=0x0D34
    sleep ; stall RAW                                   ; pc=0x0D38
    sleep ; stall RAW                                   ; pc=0x0D3C
    sw x6, -20(x17) ; sum                               ; pc=0x0D40

    ; for
    addi x6, x0, 0                                      ; pc=0x0D44
    sleep ; stall RAW                                   ; pc=0x0D48
    sleep ; stall RAW                                   ; pc=0x0D4C
    sleep ; stall RAW                                   ; pc=0x0D50
    sw x6, -24(x17) ; i                                 ; pc=0x0D54
.L2_for_start:
    lw x6, -24(x17) ; i                                 ; pc=0x0D58
    sleep ; stall RAW                                   ; pc=0x0D5C
    sleep ; stall RAW                                   ; pc=0x0D60
    sleep ; stall RAW                                   ; pc=0x0D64
    addi x4, x0, 32                                     ; pc=0x0D68
    sleep ; stall RAW                                   ; pc=0x0D6C
    sleep ; stall RAW                                   ; pc=0x0D70
    sleep ; stall RAW                                   ; pc=0x0D74
    bge x6, x4, 1152                                    ; pc=0x0D78 ; target=.L3_for_end ; addr=0x11F8
    sleep ; nop despues de control                      ; pc=0x0D7C
    sleep ; nop despues de control                      ; pc=0x0D80
    lw x4, -12(x17) ; v0                                ; pc=0x0D84
    sleep ; stall RAW                                   ; pc=0x0D88
    sleep ; stall RAW                                   ; pc=0x0D8C
    sleep ; stall RAW                                   ; pc=0x0D90
    addi x6, x0, 2                                      ; pc=0x0D94
    sleep ; stall RAW                                   ; pc=0x0D98
    sleep ; stall RAW                                   ; pc=0x0D9C
    sleep ; stall RAW                                   ; pc=0x0DA0
    add x5, x6, x6                                      ; pc=0x0DA4
    sleep ; stall RAW                                   ; pc=0x0DA8
    sleep ; stall RAW                                   ; pc=0x0DAC
    sleep ; stall RAW                                   ; pc=0x0DB0
    add x5, x5, x5                                      ; pc=0x0DB4
    sleep ; stall RAW                                   ; pc=0x0DB8
    sleep ; stall RAW                                   ; pc=0x0DBC
    sleep ; stall RAW                                   ; pc=0x0DC0
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x0DC4
    sleep ; stall RAW                                   ; pc=0x0DC8
    sleep ; stall RAW                                   ; pc=0x0DCC
    sleep ; stall RAW                                   ; pc=0x0DD0
    add x3, x3, x5                                      ; pc=0x0DD4
    sleep ; stall RAW                                   ; pc=0x0DD8
    sleep ; stall RAW                                   ; pc=0x0DDC
    sleep ; stall RAW                                   ; pc=0x0DE0
    lw x5, 0(x3)                                        ; pc=0x0DE4
    sleep ; stall RAW                                   ; pc=0x0DE8
    sleep ; stall RAW                                   ; pc=0x0DEC
    sleep ; stall RAW                                   ; pc=0x0DF0
    addi x6, x0, 4                                      ; pc=0x0DF4
    sleep ; stall RAW                                   ; pc=0x0DF8
    sleep ; stall RAW                                   ; pc=0x0DFC
    sleep ; stall RAW                                   ; pc=0x0E00
    sll x3, x4, x6                                      ; pc=0x0E04
    sleep ; stall RAW                                   ; pc=0x0E08
    sleep ; stall RAW                                   ; pc=0x0E0C
    sleep ; stall RAW                                   ; pc=0x0E10
    add x3, x3, x5                                      ; pc=0x0E14
    sleep ; stall RAW                                   ; pc=0x0E18
    sleep ; stall RAW                                   ; pc=0x0E1C
    sleep ; stall RAW                                   ; pc=0x0E20
    sw x3, -28(x17) ; left1                             ; pc=0x0E24
    lw x3, -12(x17) ; v0                                ; pc=0x0E28
    sleep ; stall RAW                                   ; pc=0x0E2C
    sleep ; stall RAW                                   ; pc=0x0E30
    sleep ; stall RAW                                   ; pc=0x0E34
    lw x5, -20(x17) ; sum                               ; pc=0x0E38
    sleep ; stall RAW                                   ; pc=0x0E3C
    sleep ; stall RAW                                   ; pc=0x0E40
    sleep ; stall RAW                                   ; pc=0x0E44
    add x4, x3, x5                                      ; pc=0x0E48
    sleep ; stall RAW                                   ; pc=0x0E4C
    sleep ; stall RAW                                   ; pc=0x0E50
    sleep ; stall RAW                                   ; pc=0x0E54
    sw x4, -32(x17) ; mid1                              ; pc=0x0E58
    lw x4, -12(x17) ; v0                                ; pc=0x0E5C
    sleep ; stall RAW                                   ; pc=0x0E60
    sleep ; stall RAW                                   ; pc=0x0E64
    sleep ; stall RAW                                   ; pc=0x0E68
    addi x5, x0, 3                                      ; pc=0x0E6C
    sleep ; stall RAW                                   ; pc=0x0E70
    sleep ; stall RAW                                   ; pc=0x0E74
    sleep ; stall RAW                                   ; pc=0x0E78
    add x3, x5, x5                                      ; pc=0x0E7C
    sleep ; stall RAW                                   ; pc=0x0E80
    sleep ; stall RAW                                   ; pc=0x0E84
    sleep ; stall RAW                                   ; pc=0x0E88
    add x3, x3, x3                                      ; pc=0x0E8C
    sleep ; stall RAW                                   ; pc=0x0E90
    sleep ; stall RAW                                   ; pc=0x0E94
    sleep ; stall RAW                                   ; pc=0x0E98
    lw x6, -8(x17) ; base ref tea_key                   ; pc=0x0E9C
    sleep ; stall RAW                                   ; pc=0x0EA0
    sleep ; stall RAW                                   ; pc=0x0EA4
    sleep ; stall RAW                                   ; pc=0x0EA8
    add x6, x6, x3                                      ; pc=0x0EAC
    sleep ; stall RAW                                   ; pc=0x0EB0
    sleep ; stall RAW                                   ; pc=0x0EB4
    sleep ; stall RAW                                   ; pc=0x0EB8
    lw x3, 0(x6)                                        ; pc=0x0EBC
    sleep ; stall RAW                                   ; pc=0x0EC0
    sleep ; stall RAW                                   ; pc=0x0EC4
    sleep ; stall RAW                                   ; pc=0x0EC8
    addi x5, x0, 5                                      ; pc=0x0ECC
    sleep ; stall RAW                                   ; pc=0x0ED0
    sleep ; stall RAW                                   ; pc=0x0ED4
    sleep ; stall RAW                                   ; pc=0x0ED8
    srl x6, x4, x5                                      ; pc=0x0EDC
    sleep ; stall RAW                                   ; pc=0x0EE0
    sleep ; stall RAW                                   ; pc=0x0EE4
    sleep ; stall RAW                                   ; pc=0x0EE8
    add x6, x6, x3                                      ; pc=0x0EEC
    sleep ; stall RAW                                   ; pc=0x0EF0
    sleep ; stall RAW                                   ; pc=0x0EF4
    sleep ; stall RAW                                   ; pc=0x0EF8
    sw x6, -36(x17) ; right1                            ; pc=0x0EFC
    lw x6, -16(x17) ; v1                                ; pc=0x0F00
    sleep ; stall RAW                                   ; pc=0x0F04
    sleep ; stall RAW                                   ; pc=0x0F08
    sleep ; stall RAW                                   ; pc=0x0F0C
    lw x3, -28(x17) ; left1                             ; pc=0x0F10
    sleep ; stall RAW                                   ; pc=0x0F14
    sleep ; stall RAW                                   ; pc=0x0F18
    sleep ; stall RAW                                   ; pc=0x0F1C
    lw x4, -32(x17) ; mid1                              ; pc=0x0F20
    sleep ; stall RAW                                   ; pc=0x0F24
    sleep ; stall RAW                                   ; pc=0x0F28
    sleep ; stall RAW                                   ; pc=0x0F2C
    xor x5, x3, x4                                      ; pc=0x0F30
    sleep ; stall RAW                                   ; pc=0x0F34
    sleep ; stall RAW                                   ; pc=0x0F38
    sleep ; stall RAW                                   ; pc=0x0F3C
    lw x4, -36(x17) ; right1                            ; pc=0x0F40
    sleep ; stall RAW                                   ; pc=0x0F44
    sleep ; stall RAW                                   ; pc=0x0F48
    sleep ; stall RAW                                   ; pc=0x0F4C
    xor x3, x5, x4                                      ; pc=0x0F50
    sleep ; stall RAW                                   ; pc=0x0F54
    sleep ; stall RAW                                   ; pc=0x0F58
    sleep ; stall RAW                                   ; pc=0x0F5C
    sub x4, x6, x3                                      ; pc=0x0F60
    sleep ; stall RAW                                   ; pc=0x0F64
    sleep ; stall RAW                                   ; pc=0x0F68
    sleep ; stall RAW                                   ; pc=0x0F6C
    sw x4, -16(x17) ; v1                                ; pc=0x0F70
    lw x4, -16(x17) ; v1                                ; pc=0x0F74
    sleep ; stall RAW                                   ; pc=0x0F78
    sleep ; stall RAW                                   ; pc=0x0F7C
    sleep ; stall RAW                                   ; pc=0x0F80
    addi x3, x0, 0                                      ; pc=0x0F84
    sleep ; stall RAW                                   ; pc=0x0F88
    sleep ; stall RAW                                   ; pc=0x0F8C
    sleep ; stall RAW                                   ; pc=0x0F90
    add x6, x3, x3                                      ; pc=0x0F94
    sleep ; stall RAW                                   ; pc=0x0F98
    sleep ; stall RAW                                   ; pc=0x0F9C
    sleep ; stall RAW                                   ; pc=0x0FA0
    add x6, x6, x6                                      ; pc=0x0FA4
    sleep ; stall RAW                                   ; pc=0x0FA8
    sleep ; stall RAW                                   ; pc=0x0FAC
    sleep ; stall RAW                                   ; pc=0x0FB0
    lw x5, -8(x17) ; base ref tea_key                   ; pc=0x0FB4
    sleep ; stall RAW                                   ; pc=0x0FB8
    sleep ; stall RAW                                   ; pc=0x0FBC
    sleep ; stall RAW                                   ; pc=0x0FC0
    add x5, x5, x6                                      ; pc=0x0FC4
    sleep ; stall RAW                                   ; pc=0x0FC8
    sleep ; stall RAW                                   ; pc=0x0FCC
    sleep ; stall RAW                                   ; pc=0x0FD0
    lw x6, 0(x5)                                        ; pc=0x0FD4
    sleep ; stall RAW                                   ; pc=0x0FD8
    sleep ; stall RAW                                   ; pc=0x0FDC
    sleep ; stall RAW                                   ; pc=0x0FE0
    addi x3, x0, 4                                      ; pc=0x0FE4
    sleep ; stall RAW                                   ; pc=0x0FE8
    sleep ; stall RAW                                   ; pc=0x0FEC
    sleep ; stall RAW                                   ; pc=0x0FF0
    sll x5, x4, x3                                      ; pc=0x0FF4
    sleep ; stall RAW                                   ; pc=0x0FF8
    sleep ; stall RAW                                   ; pc=0x0FFC
    sleep ; stall RAW                                   ; pc=0x1000
    add x5, x5, x6                                      ; pc=0x1004
    sleep ; stall RAW                                   ; pc=0x1008
    sleep ; stall RAW                                   ; pc=0x100C
    sleep ; stall RAW                                   ; pc=0x1010
    sw x5, -40(x17) ; left0                             ; pc=0x1014
    lw x5, -16(x17) ; v1                                ; pc=0x1018
    sleep ; stall RAW                                   ; pc=0x101C
    sleep ; stall RAW                                   ; pc=0x1020
    sleep ; stall RAW                                   ; pc=0x1024
    lw x6, -20(x17) ; sum                               ; pc=0x1028
    sleep ; stall RAW                                   ; pc=0x102C
    sleep ; stall RAW                                   ; pc=0x1030
    sleep ; stall RAW                                   ; pc=0x1034
    add x4, x5, x6                                      ; pc=0x1038
    sleep ; stall RAW                                   ; pc=0x103C
    sleep ; stall RAW                                   ; pc=0x1040
    sleep ; stall RAW                                   ; pc=0x1044
    sw x4, -44(x17) ; mid0                              ; pc=0x1048
    lw x4, -16(x17) ; v1                                ; pc=0x104C
    sleep ; stall RAW                                   ; pc=0x1050
    sleep ; stall RAW                                   ; pc=0x1054
    sleep ; stall RAW                                   ; pc=0x1058
    addi x6, x0, 1                                      ; pc=0x105C
    sleep ; stall RAW                                   ; pc=0x1060
    sleep ; stall RAW                                   ; pc=0x1064
    sleep ; stall RAW                                   ; pc=0x1068
    add x5, x6, x6                                      ; pc=0x106C
    sleep ; stall RAW                                   ; pc=0x1070
    sleep ; stall RAW                                   ; pc=0x1074
    sleep ; stall RAW                                   ; pc=0x1078
    add x5, x5, x5                                      ; pc=0x107C
    sleep ; stall RAW                                   ; pc=0x1080
    sleep ; stall RAW                                   ; pc=0x1084
    sleep ; stall RAW                                   ; pc=0x1088
    lw x3, -8(x17) ; base ref tea_key                   ; pc=0x108C
    sleep ; stall RAW                                   ; pc=0x1090
    sleep ; stall RAW                                   ; pc=0x1094
    sleep ; stall RAW                                   ; pc=0x1098
    add x3, x3, x5                                      ; pc=0x109C
    sleep ; stall RAW                                   ; pc=0x10A0
    sleep ; stall RAW                                   ; pc=0x10A4
    sleep ; stall RAW                                   ; pc=0x10A8
    lw x5, 0(x3)                                        ; pc=0x10AC
    sleep ; stall RAW                                   ; pc=0x10B0
    sleep ; stall RAW                                   ; pc=0x10B4
    sleep ; stall RAW                                   ; pc=0x10B8
    addi x6, x0, 5                                      ; pc=0x10BC
    sleep ; stall RAW                                   ; pc=0x10C0
    sleep ; stall RAW                                   ; pc=0x10C4
    sleep ; stall RAW                                   ; pc=0x10C8
    srl x3, x4, x6                                      ; pc=0x10CC
    sleep ; stall RAW                                   ; pc=0x10D0
    sleep ; stall RAW                                   ; pc=0x10D4
    sleep ; stall RAW                                   ; pc=0x10D8
    add x3, x3, x5                                      ; pc=0x10DC
    sleep ; stall RAW                                   ; pc=0x10E0
    sleep ; stall RAW                                   ; pc=0x10E4
    sleep ; stall RAW                                   ; pc=0x10E8
    sw x3, -48(x17) ; right0                            ; pc=0x10EC
    lw x3, -12(x17) ; v0                                ; pc=0x10F0
    sleep ; stall RAW                                   ; pc=0x10F4
    sleep ; stall RAW                                   ; pc=0x10F8
    sleep ; stall RAW                                   ; pc=0x10FC
    lw x5, -40(x17) ; left0                             ; pc=0x1100
    sleep ; stall RAW                                   ; pc=0x1104
    sleep ; stall RAW                                   ; pc=0x1108
    sleep ; stall RAW                                   ; pc=0x110C
    lw x4, -44(x17) ; mid0                              ; pc=0x1110
    sleep ; stall RAW                                   ; pc=0x1114
    sleep ; stall RAW                                   ; pc=0x1118
    sleep ; stall RAW                                   ; pc=0x111C
    xor x6, x5, x4                                      ; pc=0x1120
    sleep ; stall RAW                                   ; pc=0x1124
    sleep ; stall RAW                                   ; pc=0x1128
    sleep ; stall RAW                                   ; pc=0x112C
    lw x4, -48(x17) ; right0                            ; pc=0x1130
    sleep ; stall RAW                                   ; pc=0x1134
    sleep ; stall RAW                                   ; pc=0x1138
    sleep ; stall RAW                                   ; pc=0x113C
    xor x5, x6, x4                                      ; pc=0x1140
    sleep ; stall RAW                                   ; pc=0x1144
    sleep ; stall RAW                                   ; pc=0x1148
    sleep ; stall RAW                                   ; pc=0x114C
    sub x4, x3, x5                                      ; pc=0x1150
    sleep ; stall RAW                                   ; pc=0x1154
    sleep ; stall RAW                                   ; pc=0x1158
    sleep ; stall RAW                                   ; pc=0x115C
    sw x4, -12(x17) ; v0                                ; pc=0x1160
    lw x4, -20(x17) ; sum                               ; pc=0x1164
    sleep ; stall RAW                                   ; pc=0x1168
    sleep ; stall RAW                                   ; pc=0x116C
    sleep ; stall RAW                                   ; pc=0x1170
    addiHIGH x3, x0, 0                                  ; pc=0x1174
    sleep ; stall RAW                                   ; pc=0x1178
    sleep ; stall RAW                                   ; pc=0x117C
    sleep ; stall RAW                                   ; pc=0x1180
    addi x3, x3, 59472                                  ; pc=0x1184
    sleep ; stall RAW                                   ; pc=0x1188
    sleep ; stall RAW                                   ; pc=0x118C
    sleep ; stall RAW                                   ; pc=0x1190
    lw x5, 0(x3) ; DELTA                                ; pc=0x1194
    sleep ; stall RAW                                   ; pc=0x1198
    sleep ; stall RAW                                   ; pc=0x119C
    sleep ; stall RAW                                   ; pc=0x11A0
    sub x3, x4, x5                                      ; pc=0x11A4
    sleep ; stall RAW                                   ; pc=0x11A8
    sleep ; stall RAW                                   ; pc=0x11AC
    sleep ; stall RAW                                   ; pc=0x11B0
    sw x3, -20(x17) ; sum                               ; pc=0x11B4
    lw x3, -24(x17) ; i                                 ; pc=0x11B8
    sleep ; stall RAW                                   ; pc=0x11BC
    sleep ; stall RAW                                   ; pc=0x11C0
    sleep ; stall RAW                                   ; pc=0x11C4
    addi x5, x0, 1                                      ; pc=0x11C8
    sleep ; stall RAW                                   ; pc=0x11CC
    sleep ; stall RAW                                   ; pc=0x11D0
    sleep ; stall RAW                                   ; pc=0x11D4
    add x4, x3, x5                                      ; pc=0x11D8
    sleep ; stall RAW                                   ; pc=0x11DC
    sleep ; stall RAW                                   ; pc=0x11E0
    sleep ; stall RAW                                   ; pc=0x11E4
    sw x4, -24(x17) ; i                                 ; pc=0x11E8
    jal x0, -1172                                       ; pc=0x11EC ; target=.L2_for_start ; addr=0x0D58
    sleep ; nop despues de control                      ; pc=0x11F0
    sleep ; nop despues de control                      ; pc=0x11F4
.L3_for_end:

    lw x4, -12(x17) ; v0                                ; pc=0x11F8
    sleep ; stall RAW                                   ; pc=0x11FC
    sleep ; stall RAW                                   ; pc=0x1200
    sleep ; stall RAW                                   ; pc=0x1204
    addi x5, x0, 0                                      ; pc=0x1208
    sleep ; stall RAW                                   ; pc=0x120C
    sleep ; stall RAW                                   ; pc=0x1210
    sleep ; stall RAW                                   ; pc=0x1214
    add x3, x5, x5                                      ; pc=0x1218
    sleep ; stall RAW                                   ; pc=0x121C
    sleep ; stall RAW                                   ; pc=0x1220
    sleep ; stall RAW                                   ; pc=0x1224
    add x3, x3, x3                                      ; pc=0x1228
    sleep ; stall RAW                                   ; pc=0x122C
    sleep ; stall RAW                                   ; pc=0x1230
    sleep ; stall RAW                                   ; pc=0x1234
    lw x6, -4(x17) ; base ref v                         ; pc=0x1238
    sleep ; stall RAW                                   ; pc=0x123C
    sleep ; stall RAW                                   ; pc=0x1240
    sleep ; stall RAW                                   ; pc=0x1244
    add x6, x6, x3                                      ; pc=0x1248
    sleep ; stall RAW                                   ; pc=0x124C
    sleep ; stall RAW                                   ; pc=0x1250
    sleep ; stall RAW                                   ; pc=0x1254
    sw x4, 0(x6)                                        ; pc=0x1258
    lw x4, -16(x17) ; v1                                ; pc=0x125C
    sleep ; stall RAW                                   ; pc=0x1260
    sleep ; stall RAW                                   ; pc=0x1264
    sleep ; stall RAW                                   ; pc=0x1268
    addi x6, x0, 1                                      ; pc=0x126C
    sleep ; stall RAW                                   ; pc=0x1270
    sleep ; stall RAW                                   ; pc=0x1274
    sleep ; stall RAW                                   ; pc=0x1278
    add x3, x6, x6                                      ; pc=0x127C
    sleep ; stall RAW                                   ; pc=0x1280
    sleep ; stall RAW                                   ; pc=0x1284
    sleep ; stall RAW                                   ; pc=0x1288
    add x3, x3, x3                                      ; pc=0x128C
    sleep ; stall RAW                                   ; pc=0x1290
    sleep ; stall RAW                                   ; pc=0x1294
    sleep ; stall RAW                                   ; pc=0x1298
    lw x5, -4(x17) ; base ref v                         ; pc=0x129C
    sleep ; stall RAW                                   ; pc=0x12A0
    sleep ; stall RAW                                   ; pc=0x12A4
    sleep ; stall RAW                                   ; pc=0x12A8
    add x5, x5, x3                                      ; pc=0x12AC
    sleep ; stall RAW                                   ; pc=0x12B0
    sleep ; stall RAW                                   ; pc=0x12B4
    sleep ; stall RAW                                   ; pc=0x12B8
    sw x4, 0(x5)                                        ; pc=0x12BC
.L_codegen_3_tea_decrypt_end:
    ; epilogue
    lw x1, 0(x2)                                        ; pc=0x12C0
    sleep ; stall RAW                                   ; pc=0x12C4
    sleep ; stall RAW                                   ; pc=0x12C8
    sleep ; stall RAW                                   ; pc=0x12CC
    lw x17, 4(x2)                                       ; pc=0x12D0
    sleep ; stall RAW                                   ; pc=0x12D4
    sleep ; stall RAW                                   ; pc=0x12D8
    sleep ; stall RAW                                   ; pc=0x12DC
    addi x2, x2, 60                                     ; pc=0x12E0
    sleep ; stall RAW                                   ; pc=0x12E4
    sleep ; stall RAW                                   ; pc=0x12E8
    sleep ; stall RAW                                   ; pc=0x12EC
    jalr x1, 0                                          ; pc=0x12F0
    sleep ; nop despues de control                      ; pc=0x12F4
    sleep ; nop despues de control                      ; pc=0x12F8