; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x0018
;   main = 0x0018
;   .L0_while_start = 0x0050
;   .L1_while_end = 0x00A0
;   .L_codegen_1_main_end = 0x00AC

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x0018, offset=24)
;   pc=0x0058 bge -> .L1_while_end (addr=0x00A0, offset=72)
;   pc=0x009C jal -> .L0_while_start (addr=0x0050, offset=-76)
;   pc=0x00A8 jal -> .L_codegen_1_main_end (addr=0x00AC, offset=4)

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
    addiSigned x2, x2, -28                              ; pc=0x0020
    sw x1, 0(x2)                                        ; pc=0x0024
    sw x17, 4(x2)                                       ; pc=0x0028
    addi x17, x2, 28                                    ; pc=0x002C

    addi x3, x0, 0                                      ; pc=0x0030
    sw x3, -4(x17) ; i                                  ; pc=0x0034
    addi x3, x0, 0                                      ; pc=0x0038
    sw x3, -8(x17) ; suma                               ; pc=0x003C
    addi x3, x0, 1                                      ; pc=0x0040
    sw x3, -12(x17) ; mezcla                            ; pc=0x0044
    addi x3, x0, 0                                      ; pc=0x0048
    sw x3, -16(x17) ; total                             ; pc=0x004C

.L0_while_start:
    lw x3, -4(x17) ; i                                  ; pc=0x0050
    addi x4, x0, 8                                      ; pc=0x0054
    bge x3, x4, 72                                      ; pc=0x0058 ; target=.L1_while_end ; addr=0x00A0
    lw x4, -8(x17) ; suma                               ; pc=0x005C
    lw x3, -4(x17) ; i                                  ; pc=0x0060
    add x5, x4, x3                                      ; pc=0x0064
    sw x5, -8(x17) ; suma                               ; pc=0x0068
    lw x5, -12(x17) ; mezcla                            ; pc=0x006C
    addi x3, x0, 2                                      ; pc=0x0070
    mul x4, x5, x3                                      ; pc=0x0074
    sw x4, -12(x17) ; mezcla                            ; pc=0x0078
    lw x4, -16(x17) ; total                             ; pc=0x007C
    lw x3, -8(x17) ; suma                               ; pc=0x0080
    add x5, x4, x3                                      ; pc=0x0084
    sw x5, -16(x17) ; total                             ; pc=0x0088
    lw x5, -4(x17) ; i                                  ; pc=0x008C
    addi x3, x0, 1                                      ; pc=0x0090
    add x4, x5, x3                                      ; pc=0x0094
    sw x4, -4(x17) ; i                                  ; pc=0x0098
    jal x0, -76                                         ; pc=0x009C ; target=.L0_while_start ; addr=0x0050
.L1_while_end:

    lw x4, -16(x17) ; total                             ; pc=0x00A0
    add x11, x4, x0                                     ; pc=0x00A4
    jal x0, 4                                           ; pc=0x00A8 ; target=.L_codegen_1_main_end ; addr=0x00AC
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x00AC
    addi x2, x2, 28                                     ; pc=0x00B0
    freeze                                              ; pc=0x00B4