; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L0_for_start = 0x0088
;   .L1_for_end = 0x00E0
;   .L_codegen_1_main_end = 0x0100

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0090 bge -> .L1_for_end (addr=0x00E0, offset=80)
;   pc=0x00DC jal -> .L0_for_start (addr=0x0088, offset=-84)
;   pc=0x00FC jal -> .L_codegen_1_main_end (addr=0x0100, offset=4)

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
    addiSigned x2, x2, -88                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 88                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -40(x17) ; datos[0]                          ; pc=0x0034
    addi x3, x0, 1                                      ; pc=0x0038
    sw x3, -36(x17) ; datos[1]                          ; pc=0x003C
    addi x3, x0, 2                                      ; pc=0x0040
    sw x3, -32(x17) ; datos[2]                          ; pc=0x0044
    addi x3, x0, 3                                      ; pc=0x0048
    sw x3, -28(x17) ; datos[3]                          ; pc=0x004C
    addi x3, x0, 4                                      ; pc=0x0050
    sw x3, -24(x17) ; datos[4]                          ; pc=0x0054
    addi x3, x0, 5                                      ; pc=0x0058
    sw x3, -20(x17) ; datos[5]                          ; pc=0x005C
    addi x3, x0, 6                                      ; pc=0x0060
    sw x3, -16(x17) ; datos[6]                          ; pc=0x0064
    addi x3, x0, 7                                      ; pc=0x0068
    sw x3, -12(x17) ; datos[7]                          ; pc=0x006C
    addi x3, x0, 8                                      ; pc=0x0070
    sw x3, -8(x17) ; datos[8]                           ; pc=0x0074
    addi x3, x0, 9                                      ; pc=0x0078
    sw x3, -4(x17) ; datos[9]                           ; pc=0x007C

    ; for
    addi x3, x0, 0                                      ; pc=0x0080
    sw x3, -44(x17) ; i                                 ; pc=0x0084
.L0_for_start:
    lw x3, -44(x17) ; i                                 ; pc=0x0088
    addi x4, x0, 10                                     ; pc=0x008C
    bge x3, x4, 80                                      ; pc=0x0090 ; target=.L1_for_end ; addr=0x00E0
    lw x4, -44(x17) ; i                                 ; pc=0x0094
    add x3, x4, x4                                      ; pc=0x0098
    add x3, x3, x3                                      ; pc=0x009C
    addiSigned x5, x17, -40                             ; pc=0x00A0
    ; base datos
    add x5, x5, x3                                      ; pc=0x00A4
    lw x3, 0(x5)                                        ; pc=0x00A8
    addi x5, x0, 1                                      ; pc=0x00AC
    add x4, x3, x5                                      ; pc=0x00B0
    lw x5, -44(x17) ; i                                 ; pc=0x00B4
    add x3, x5, x5                                      ; pc=0x00B8
    add x3, x3, x3                                      ; pc=0x00BC
    addiSigned x6, x17, -40                             ; pc=0x00C0
    ; base datos
    add x6, x6, x3                                      ; pc=0x00C4
    sw x4, 0(x6)                                        ; pc=0x00C8
    lw x4, -44(x17) ; i                                 ; pc=0x00CC
    addi x6, x0, 1                                      ; pc=0x00D0
    add x3, x4, x6                                      ; pc=0x00D4
    sw x3, -44(x17) ; i                                 ; pc=0x00D8
    jal x0, -84                                         ; pc=0x00DC ; target=.L0_for_start ; addr=0x0088
.L1_for_end:

    addi x3, x0, 9                                      ; pc=0x00E0
    add x6, x3, x3                                      ; pc=0x00E4
    add x6, x6, x6                                      ; pc=0x00E8
    addiSigned x4, x17, -40                             ; pc=0x00EC
    ; base datos
    add x4, x4, x6                                      ; pc=0x00F0
    lw x6, 0(x4)                                        ; pc=0x00F4
    add x11, x6, x0                                     ; pc=0x00F8
    jal x0, 4                                           ; pc=0x00FC ; target=.L_codegen_1_main_end ; addr=0x0100
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0100
    addi x2, x2, 88                                     ; pc=0x0104
    freeze                                              ; pc=0x0108