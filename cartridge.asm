    PROCESSOR 6502

    SEG CODE    ; Main segment (necessary for compilation when using segments elsewhere...)
    ORG $8000   ; Cartridge entry point

    WORD coldstart             ; coldstart vector
    WORD warmstart             ; warmstart vector
    BYTE $c3,$c2,$cd,$38,$30   ; "CMB80". Autostart string

; Some "defines"
BORDER      = $d020
BACKGROUND  = $d021
PLOT        = $fff0 ; Set cursor location. X (row), Y (col) as inputs
CHROUT      = $ffd2 ; Output character to current cursor location
SHOW_CURSOR = $00cc ; 0 means ON, >= 1 means OFF


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
    LDA #255
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
; in:   A  (byte)
; out:  X  (hi-nibble)
;       Y  (lo-nibble)
    PHA     ; Push A to stack. A preserves value
    LSR     ; Shift A right 4 times (127: 0x7F -> 0111 1111 >> 0000 0111)
    LSR
    LSR
    LSR
    TAX             ; Transfer A to X -> X = 0000 0111
    LDA hexits,X    ; Look up value in character table: 0x07 -> '7' and load into A
    STA tmp         ; Store A in variable tmp (in RAM, see SEG.U variables)

    PLA             ; Pull original A value into A (0x7F)
    AND #%00001111  ; AND A to get LSBs (0x7F & 0x0F -> 0x0F: 0000 1111)
    TAX             ; Transfer A to X -> X = 0000 1111
    LDA hexits,X    ; Look up value in character table: 0x0F -> 'f' and load into A
    TAX             ; Transfer A to X (hi-nibble output)
    LDY tmp         ; Load Y with value stored in 'tmp' (low-nibble output)
    RTS


hexits: .byte "0123456789ABCDEF"    ; IMPORTANT that characters here are capital letters!

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
