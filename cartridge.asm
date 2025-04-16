 PROCESSOR 6502

 ORG $8000

    .word coldstart             ; coldstart vector
    .word warmstart             ; warmstart vector
    .byte $C3,$C2,$CD,$38,$30   ; "CMB80". Autostart string

coldstart
    SEI         ;Set Interrupt
    STX $d016   ;Store register x (but why?)
    JSR $fda3   ;Prepare IRQ
    JSR $fd50   ;Init memory. Rewrite this routine to speed up boot process
    JSR $fd15   ;Init I/O
    JSR $ff5b;  ;Init video
    CLI         ;Clear interrupt

warmstart
; Setup code
    LDA #$55    ; Load color 00 (black) into accumulator
    STA $d020   ; Store accumulator value (00/black) into border color

    LDA #8
    STA $0400

    JMP loop

loop:
; Loop code
    JMP loop

 ORG $9fff       ;fill up to -$9fff (or $bfff if 16K)
    .byte $FF
