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
; Setup start {
    ; Background and border color to black
    LDA #0
    STA BACKGROUND
    STA BORDER

    ; All characters to green
    JSR charcolor ; For storing characters in the char matrix
    LDA #$05
    STA $0286     ; Change cursor color to green


    ; ; Convert a byte value to a hex string (2 chars)...
    ; LDA #127
    ; JSR bytetohex

    ; ; ... and print them to the screen
    ; TYA
    ; JSR CHROUT
    ; TXA
    ; JSR CHROUT

    ; Print 'HELLO WORLD' in the middle of the screen.
    JSR hello_world



; } Setup end
    JMP loop

loop:
; Loop start

; Loop end
    JMP loop

hello_world:
    SUBROUTINE
    ; Set cursor position
    CLC
    LDX #2
    LDY #15
    JSR PLOT

    ; Loop through constant, zero-terminated string
    LDX #0
.loop:
    LDA hello_world_str,X
    JSR CHROUT
    INX
    CMP #0
    BNE .loop

    LDA #'!
    JSR CHROUT

    RTS

charcolor:
; Set character color to green for all screen characters
; This is usefule, if characters are placed manually. Otherwise,
; consider setting the cursor text color setting $0286 and outputting
; characters to screen using JSR $ffd2
    SUBROUTINE

; Load start address for setting character color ($d800)
    LDA #$00
    STA $08     ; 16-bit value, low
    LDA #$d8
    STA $09     ; 16-bit value, high
    LDX #0      ; Set X to 0 (no address offset)

.loop

    LDA #$05    ; Green
    STA ($08,X) ; Store A in address [$01, $00] -> $d800

    CLC
    LDA $08
    ADC #1
    STA $08

    BVS .inchigh ; If overflow, increment high byte

.comp
; Compare to highest color address ($dbe7) and loop until reached
    LDA $08
    CMP #$e7
    BNE .loop

    LDA $09
    CMP #$db
    BNE .loop

    RTS

.inchigh:
    CLC
    LDA $09
    ADC #1
    STA $09

    JMP .comp

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


; Constants
hexits: BYTE "0123456789ABCDEF"    ; IMPORTANT that characters here are capital letters!
hello_world_str: BYTE "HELLO WORLD",0

; EOF - Fill up to -$9fff (or $bfff if 16K)
    ORG $9fff
    BYTE $FF

; Variable data segment - data that can change
;; Note: The 'U' below specifies the segment to be uninitialized.
;; This means that the variables will not be stored in the binary.
;; This is useful for addressing memory addresses in the C64 RAM,
;; as those addresses are outside of the cartridge memory range.
    SEG.U variables
    ORG $0100       ; C64 RAM location - stack
i:      BYTE 0
tmp:    BYTE 0
