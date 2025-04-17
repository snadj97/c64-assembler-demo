    PROCESSOR 6502

    SEG CODE    ; Main segment (necessary for compilation when using segments elsewhere...)
    ORG $8000   ; Cartridge entry point

    .word coldstart             ; coldstart vector
    .word warmstart             ; warmstart vector
    .byte $C3,$C2,$CD,$38,$30   ; "CMB80". Autostart string

coldstart:
    SEI         ;Set Interrupt
    STX $d016   ;Store register x (but why?)
    JSR $fda3   ;Prepare IRQ
    JSR $fd50   ;Init memory. Rewrite this routine to speed up boot process
    JSR $fd15   ;Init I/O
    JSR $ff5b;  ;Init video
    CLI         ;Clear interrupt

warmstart:
; Setup code
    LDA #$05
    STA $0400

    JSR hello_world

    JMP loop


loop:
; Loop start
    LDA #0    ; Raster line for comparison
compare:
    CMP $d012
    BNE compare

    INC i
    LDA #128
    CMP i
    BNE loop

    LDA #0
    STA i

    LDA var2
    STA $d020   ; Store accumulator value into border color

    LDA var1
    STA $0442

    INC var1
    INC var2


; Loop end
    JMP loop

hello_world:
    LDA #8
    STA $0436

    LDA #5
    STA $0437

    LDA #12
    STA $0438

    LDA #12
    STA $0439

    LDA #15
    STA $043A

    LDA #32
    STA $043B

    LDA #23
    STA $043C

    LDA #15
    STA $043D

    LDA #18
    STA $043E

    LDA #12
    STA $043F

    LDA #4
    STA $0440

    RTS

;fill up to -$9fff (or $bfff if 16K)
    ORG $9fff
    .byte $FF

; Data segment
    SEG.U variables  ; Uninitialized segment (not written to binary)
    ORG $0100       ; C64 RAM location - stack
var1:   .byte 1     ; $0100
var2:   .byte 0     ; $0101
i:      .byte 0     ; $0102
