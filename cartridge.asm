    PROCESSOR 6502

    SEG CODE    ; Main segment (necessary for compilation when using segments elsewhere...)
    ORG $8000   ; Cartridge entry point

    .word coldstart             ; coldstart vector
    .word warmstart             ; warmstart vector
    .byte $C3,$C2,$CD,$38,$30   ; "CMB80". Autostart string

coldstart:
    SEI         ;Set Interrupt
    STX $d016   ;Store register x (but why?) - it seems 0xFF is stored in X from the start of the Commodore64. This is stored in $d016 for initialization.
    JSR $fda3   ;Prepare IRQ
    JSR $fd50   ;Init memory. Rewrite this routine to speed up boot process
    JSR $fd15   ;Init I/O
    JSR $ff5b;  ;Init video
    CLI         ;Clear interrupt

warmstart:
; Setup code start
    LDA #100
    JSR bytetohex

    TYA
    JSR $ffd2
    TXA
    JSR $ffd2

    JSR hello_world


; Setup code end
    JMP loop

loop:
; Loop start

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

bytetohex:
.block:
    PHA
    LSR
    LSR
    LSR
    LSR
    TAX
    LDA hexits,X
    STA tmp
    PLA
    AND #%00001111
    TAX
    LDA hexits,X
    TAX
    LDY tmp
    RTS


hexits: .byte "0123456789abcdef"

;fill up to -$9fff (or $bfff if 16K)
    ORG $9fff
    .byte $FF

; Variable data segment - data that can change
    SEG.U variables  ; Uninitialized segment (not written to binary)
    ORG $0100       ; C64 RAM location - stack
var1:   .byte 1     ; $0100
var2:   .byte 0     ; $0101
i:      .byte 0     ; $0102
tmp:    .byte 0
