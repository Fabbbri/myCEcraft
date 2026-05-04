; ==================================================
; Fase 5 - saltos y referencias resueltas
; Convencion: offset relativo en bytes = target_pc - current_pc
; ==================================================

; Tabla de etiquetas
;   .L_codegen_0_enderExit = 0x001C
;   main = 0x001C
;   .L_codegen_2_endchange = 0x0148
;   .L_codegen_1_main_end = 0x0170

; Referencias resueltas
;   pc=0x0000 portalv -> .L_codegen_0_enderExit (addr=0x001C, offset=28)
;   pc=0x0068 portalv -> .L_codegen_2_endchange (addr=0x0148, offset=224)
;   pc=0x0168 jal -> .L_codegen_1_main_end (addr=0x0170, offset=8)

; ==================================================
; Ensamblador generado para Craft21
; Fase 4 - versión inicial
; ==================================================

.text

    ; @EnterCraftWorld
    portalv x0, x0, 28                                  ; pc=0x0000 ; target=.L_codegen_0_enderExit ; addr=0x001C
    sleep ; nop despues de control                      ; pc=0x0004
    lwv v0, 0(v0)                                       ; pc=0x0008
    sleep ; stall RAW                                   ; pc=0x000C
    sleep ; stall RAW                                   ; pc=0x0010
    sleep ; stall RAW                                   ; pc=0x0014
    closev ; cerrar Secure Mode despues del bootstrap   ; pc=0x0018
.L_codegen_0_enderExit:

main:
    ; prologue
    addiSigned x2, x2, -16                              ; pc=0x001C
    sleep ; stall RAW                                   ; pc=0x0020
    sleep ; stall RAW                                   ; pc=0x0024
    sleep ; stall RAW                                   ; pc=0x0028
    sw x1, 0(x2)                                        ; pc=0x002C
    sw x17, 4(x2)                                       ; pc=0x0030
    addi x17, x2, 16                                    ; pc=0x0034
    sleep ; stall RAW                                   ; pc=0x0038
    sleep ; stall RAW                                   ; pc=0x003C
    sleep ; stall RAW                                   ; pc=0x0040

    addi x3, x0, 2121                                   ; pc=0x0044
    sleep ; stall RAW                                   ; pc=0x0048
    sleep ; stall RAW                                   ; pc=0x004C
    sleep ; stall RAW                                   ; pc=0x0050
    sw x3, -4(x17) ; password                           ; pc=0x0054
    lw x3, -4(x17) ; password                           ; pc=0x0058
    sleep ; stall RAW                                   ; pc=0x005C
    sleep ; stall RAW                                   ; pc=0x0060
    sleep ; stall RAW                                   ; pc=0x0064
    portalv x3, v0, 224                                 ; enderPortal ; pc=0x0068 ; target=.L_codegen_2_endchange ; addr=0x0148
    sleep ; nop despues de control                      ; pc=0x006C
    addi x1, v0, 38563 ; key[0] low                     ; pc=0x0070
    sleep ; stall RAW                                   ; pc=0x0074
    sleep ; stall RAW                                   ; pc=0x0078
    sleep ; stall RAW                                   ; pc=0x007C
    addiHIGHv v1, x1, 35 ; key[0] high                  ; pc=0x0080
    sleep ; stall RAW                                   ; pc=0x0084
    sleep ; stall RAW                                   ; pc=0x0088
    sleep ; stall RAW                                   ; pc=0x008C
    swv v1, 0(v0) ; key[0]                              ; pc=0x0090
    addi x1, v0, 1234 ; key[1] low                      ; pc=0x0094
    sleep ; stall RAW                                   ; pc=0x0098
    sleep ; stall RAW                                   ; pc=0x009C
    sleep ; stall RAW                                   ; pc=0x00A0
    addiHIGHv v1, x1, 0 ; key[1] high                   ; pc=0x00A4
    sleep ; stall RAW                                   ; pc=0x00A8
    sleep ; stall RAW                                   ; pc=0x00AC
    sleep ; stall RAW                                   ; pc=0x00B0
    swv v1, 4(v0) ; key[1]                              ; pc=0x00B4
    addi x1, v0, 13234 ; key[2] low                     ; pc=0x00B8
    sleep ; stall RAW                                   ; pc=0x00BC
    sleep ; stall RAW                                   ; pc=0x00C0
    sleep ; stall RAW                                   ; pc=0x00C4
    addiHIGHv v1, x1, 0 ; key[2] high                   ; pc=0x00C8
    sleep ; stall RAW                                   ; pc=0x00CC
    sleep ; stall RAW                                   ; pc=0x00D0
    sleep ; stall RAW                                   ; pc=0x00D4
    swv v1, 8(v0) ; key[2]                              ; pc=0x00D8
    addi x1, v0, 124 ; key[3] low                       ; pc=0x00DC
    sleep ; stall RAW                                   ; pc=0x00E0
    sleep ; stall RAW                                   ; pc=0x00E4
    sleep ; stall RAW                                   ; pc=0x00E8
    addiHIGHv v1, x1, 0 ; key[3] high                   ; pc=0x00EC
    sleep ; stall RAW                                   ; pc=0x00F0
    sleep ; stall RAW                                   ; pc=0x00F4
    sleep ; stall RAW                                   ; pc=0x00F8
    swv v1, 12(v0) ; key[3]                             ; pc=0x00FC
    addi x1, v0, 0x1234 ; enderlow                      ; pc=0x0100
    sleep ; stall RAW                                   ; pc=0x0104
    sleep ; stall RAW                                   ; pc=0x0108
    sleep ; stall RAW                                   ; pc=0x010C
    addiHIGHv v2, x1, 0xABCD ; enderhigh                ; pc=0x0110
    sleep ; stall RAW                                   ; pc=0x0114
    sleep ; stall RAW                                   ; pc=0x0118
    sleep ; stall RAW                                   ; pc=0x011C
    changev v2, v1 ; enderkey                           ; pc=0x0120
    sleep ; stall RAW                                   ; pc=0x0124
    sleep ; stall RAW                                   ; pc=0x0128
    sleep ; stall RAW                                   ; pc=0x012C
    lwv v3, 0(v0) ; enderload                           ; pc=0x0130
    sleep ; stall RAW                                   ; pc=0x0134
    sleep ; stall RAW                                   ; pc=0x0138
    sleep ; stall RAW                                   ; pc=0x013C
    swv v3, 4(v0) ; enderstore                          ; pc=0x0140
    closev ; enderclose                                 ; pc=0x0144
.L_codegen_2_endchange:
    addi x3, x0, 0                                      ; pc=0x0148
    sleep ; stall RAW                                   ; pc=0x014C
    sleep ; stall RAW                                   ; pc=0x0150
    sleep ; stall RAW                                   ; pc=0x0154
    add x11, x3, x0                                     ; pc=0x0158
    sleep ; stall RAW                                   ; pc=0x015C
    sleep ; stall RAW                                   ; pc=0x0160
    sleep ; stall RAW                                   ; pc=0x0164
    jal x0, 8                                           ; pc=0x0168 ; target=.L_codegen_1_main_end ; addr=0x0170
    sleep ; nop despues de control                      ; pc=0x016C
.L_codegen_1_main_end:
    ; epilogue
    lw x17, 4(x2)                                       ; pc=0x0170
    sleep ; stall RAW                                   ; pc=0x0174
    sleep ; stall RAW                                   ; pc=0x0178
    sleep ; stall RAW                                   ; pc=0x017C
    addi x2, x2, 16                                     ; pc=0x0180
    sleep ; stall RAW                                   ; pc=0x0184
    sleep ; stall RAW                                   ; pc=0x0188
    sleep ; stall RAW                                   ; pc=0x018C
    freeze                                              ; pc=0x0190