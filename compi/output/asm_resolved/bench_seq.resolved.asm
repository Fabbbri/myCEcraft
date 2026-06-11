; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L0_while_start = 0x0048
;   .L1_while_end = 0x0084
;   .L2_while_start = 0x008C
;   .L3_while_end = 0x00D0
;   .L_codegen_1_main_end = 0x00DC

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0050 bge -> .L1_while_end (addr=0x0084, offset=52)
;   pc=0x0080 jal -> .L0_while_start (addr=0x0048, offset=-56)
;   pc=0x0094 bge -> .L3_while_end (addr=0x00D0, offset=60)
;   pc=0x00CC jal -> .L2_while_start (addr=0x008C, offset=-64)
;   pc=0x00D8 jal -> .L_codegen_1_main_end (addr=0x00DC, offset=4)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, 24                                  ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x0018
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
    addiSigned x2, x2, -2056                            ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 2056                                  ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -1024(x17) ; arr                             ; pc=0x0034
    addi x3, x0, 0                                      ; pc=0x0038
    sw x3, -1028(x17) ; i                               ; pc=0x003C
    addi x3, x0, 0                                      ; pc=0x0040
    sw x3, -1032(x17) ; suma                            ; pc=0x0044

.L0_while_start:
    lw x3, -1028(x17) ; i                               ; pc=0x0048
    addi x4, x0, 256                                    ; pc=0x004C
    bge x3, x4, 52                                      ; pc=0x0050 ; target=.L1_while_end ; addr=0x0084
    lw x4, -1028(x17) ; i                               ; pc=0x0054
    lw x3, -1028(x17) ; i                               ; pc=0x0058
    add x5, x3, x3                                      ; pc=0x005C
    add x5, x5, x5                                      ; pc=0x0060
    addiSigned x6, x17, -1024                           ; pc=0x0064
    ; base arr
    add x6, x6, x5                                      ; pc=0x0068
    sw x4, 0(x6)                                        ; pc=0x006C
    lw x4, -1028(x17) ; i                               ; pc=0x0070
    addi x6, x0, 1                                      ; pc=0x0074
    add x5, x4, x6                                      ; pc=0x0078
    sw x5, -1028(x17) ; i                               ; pc=0x007C
    jal x0, -56                                         ; pc=0x0080 ; target=.L0_while_start ; addr=0x0048
.L1_while_end:

    addi x5, x0, 0                                      ; pc=0x0084
    sw x5, -1028(x17) ; i                               ; pc=0x0088

.L2_while_start:
    lw x5, -1028(x17) ; i                               ; pc=0x008C
    addi x6, x0, 256                                    ; pc=0x0090
    bge x5, x6, 60                                      ; pc=0x0094 ; target=.L3_while_end ; addr=0x00D0
    lw x6, -1032(x17) ; suma                            ; pc=0x0098
    lw x5, -1028(x17) ; i                               ; pc=0x009C
    add x4, x5, x5                                      ; pc=0x00A0
    add x4, x4, x4                                      ; pc=0x00A4
    addiSigned x3, x17, -1024                           ; pc=0x00A8
    ; base arr
    add x3, x3, x4                                      ; pc=0x00AC
    lw x4, 0(x3)                                        ; pc=0x00B0
    add x3, x6, x4                                      ; pc=0x00B4
    sw x3, -1032(x17) ; suma                            ; pc=0x00B8
    lw x3, -1028(x17) ; i                               ; pc=0x00BC
    addi x4, x0, 1                                      ; pc=0x00C0
    add x6, x3, x4                                      ; pc=0x00C4
    sw x6, -1028(x17) ; i                               ; pc=0x00C8
    jal x0, -64                                         ; pc=0x00CC ; target=.L2_while_start ; addr=0x008C
.L3_while_end:

    lw x6, -1032(x17) ; suma                            ; pc=0x00D0
    add x11, x6, x0                                     ; pc=0x00D4
    jal x0, 4                                           ; pc=0x00D8 ; target=.L_codegen_1_main_end ; addr=0x00DC
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00DC
    addi x2, x2, 2056                                   ; pc=0x00E0
    freeze                                              ; pc=0x00E4