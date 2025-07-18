    PROCESSOR 6502

    SEG CODE    ; Main segment (necessary for compilation when using segments elsewhere...)
    ORG $8000   ; Cartridge entry point

    WORD coldstart             ; coldstart vector
    WORD warmstart             ; warmstart vector
    BYTE $c3,$c2,$cd,$38,$30   ; "CMB80". Autostart string

; Some "defines"
BORDER       = $d020
BACKGROUND   = $d021
PLOT         = $fff0    ; Set cursor location. X (row), Y (col) as inputs
CHROUT       = $ffd2    ; Output character to current cursor location
CURSOR_SHOW  = $00cc    ; 0 means ON, >= 1 means OFF
CURSOR_COLOR = $0286
CURSOR_PHASE = $00cf
GETIN        = $ffe4

CIA2B_DDR    = $dd03
CIA2B_DATA   = $dd01
PIN_CFG      = %00000001 ; PB0 as output, all other inputs

CHAR_ENTER  = $0d
CHAR_DELETE = $14

MAX_CHARS = 10

coldstart:  SEI         ;Set Interrupt
            STX $d016   ;Store register x (but why?) - it seems 0xFF is stored in X from the start of the Commodore64. This is stored in $d016 for initialization.
            JSR $fda3   ;Prepare IRQ
            JSR $fd50   ;Init memory. Rewrite this routine to speed up boot process
            JSR $fd15   ;Init I/O
            JSR $ff5b;  ;Init video
            CLI         ;Clear interrupt

warmstart:  LDA #0
            STA BACKGROUND  ; Background: black
            STA BORDER      ; Border: black

            LDA #$05
            STA CURSOR_COLOR     ; Change cursor color to green

            JSR big_box
            JSR small_box

            JSR print_title_1
            JSR print_title_2

            CLC
            LDX #12
            LDY #15
            JSR PLOT    ; Set cursor position

            JSR init_gpo

; ______________Loop start_____________
main_loop:
wait_char:  JSR GETIN
            CMP #0
            BEQ wait_char
            CMP #CHAR_DELETE    ; If DELETE, branch
            BEQ handle_del
            CMP #CHAR_ENTER    ; If ENTER, branch
            BEQ handle_in

handle_add: JSR add_char
            JMP loop_end

handle_del: JSR del_char
            JMP loop_end

handle_in:  JSR process_input

loop_end:       JMP main_loop
; ______________Loop end ________________

print_title_1:  SUBROUTINE
                CLC
                LDX #4
                LDY #16
                JSR PLOT
                LDX #0
.loop:          LDA title_1,X
                JSR CHROUT
                INX
                CMP #0
                BNE .loop
                RTS

print_title_2:  SUBROUTINE
                CLC
                LDX #7
                LDY #10
                JSR PLOT
                LDX #0
.loop:          LDA title_2,X
                JSR CHROUT
                INX
                CMP #0
                BNE .loop
                RTS

add_char:   SUBROUTINE
            LDX c_cnt
            CPX #MAX_CHARS
            BEQ .end
            STA input,X
            INX
            STX c_cnt
            JSR CHROUT
.end        RTS

del_char:   SUBROUTINE
            LDX c_cnt
            CPX #0
            BEQ .end
            DEX
            STX c_cnt
            LDA #0
            STA input,X
            LDA #$9d
            JSR CHROUT
            LDA #$20
            JSR CHROUT
            LDA #$9d
            JSR CHROUT
.end        RTS

big_box:    SUBROUTINE
            CLC
            LDX #0
            LDY #0
            JSR PLOT    ; Set cursor position
            LDX #0      ; Loop through constant, zero-terminated string
.loop_top:  LDA BIG_BOX_TOP,X
            JSR CHROUT
            INX
            CMP #0
            BNE .loop_top
            LDA #LS
            JSR CHROUT
            LDX #1
.loop_side: LDY #39
            CLC
            JSR PLOT
            LDA #RS
            JSR CHROUT
            LDA #LS
            JSR CHROUT
            INX
            CPX #23
            BNE .loop_side
            CLC
            JSR PLOT
            LDA #RS
            JSR CHROUT
            LDA #$05
            STA $dbe7
            LDA #$7a
            STA $07e7
            LDX #24
            LDY #0
            JSR PLOT    ; Set cursor position
            LDX #0      ; Loop through constant, zero-terminated string
.loop_bot:  LDA BIG_BOX_BOT,X
            CMP #0
            BEQ .end
            JSR CHROUT
            INX
            JMP .loop_bot
.end        RTS

small_box:  SUBROUTINE
            CLC
            LDX #11
            LDY #14
            JSR PLOT    ; Set cursor position
            LDX #0      ; Loop through constant, zero-terminated string
.loop_top:  LDA SMALL_BOX_TOP,X
            JSR CHROUT
            INX
            CMP #0
            BNE .loop_top
            CLC
            LDX #12
            LDY #14
            JSR PLOT
            LDX #0
.loop_side: LDA SMALL_BOX_SIDE,X
            JSR CHROUT
            INX
            CMP #0
            BNE .loop_side
            CLC
            LDX #13
            LDY #14
            JSR PLOT    ; Set cursor position
            LDX #0      ; Loop through constant, zero-terminated string
.loop_bot:  LDA SMALL_BOX_BOT,X
            CMP #0
            BEQ .end
            JSR CHROUT
            INX
            JMP .loop_bot
.end        RTS

process_input:  SUBROUTINE
                LDX #0      ; Initialize X as iterator
.loop:          LDA input,X
                CMP password,X  ; Compare input at idx X with password at same index
                BNE .incorrect  ; If characters are not equal jump to incorrect
                CMP #0
                BEQ .correct    ; If character is 0, jump to correct
                INX
                JMP .loop
.incorrect:     JSR pw_incorrect
                JMP .done
.correct:       JSR pw_correct
.done:          JSR clear_password
                RTS

clear_password: SUBROUTINE
                LDA #0
.loop           LDX c_cnt
                CPX #0
                BEQ .end
                JSR del_char
                JMP .loop
.end            RTS

pw_correct: SUBROUTINE
            CLC
            LDX #16
            LDY #9
            JSR PLOT
            LDX #0
.loop:      LDA PW_CORRECT,X
            JSR CHROUT
            INX
            CMP #0
            BNE .loop
            JSR pb0_off
            LDA #15
            ADC c_cnt
            TAY
            CLC
            LDX #12
            JSR PLOT
            RTS

pw_incorrect:   SUBROUTINE
                CLC
                LDX #16
                LDY #9
                JSR PLOT
                LDX #0
.loop:          LDA PW_INCORRECT,X
                JSR CHROUT
                INX
                CMP #0
                BNE .loop
                LDA #14
                ADC c_cnt
                TAY
                CLC
                LDX #12
                JSR PLOT
                RTS

init_gpo:   SUBROUTINE
            LDA #PIN_CFG
            STA CIA2B_DDR
            JSR pb0_on
            RTS

pb0_on:     SUBROUTINE
            LDA #1
            STA CIA2B_DATA
            RTS

pb0_off:    SUBROUTINE
            LDA #0
            STA CIA2B_DATA
            RTS

; Set character color to green for all screen characters
; This is usefule, if characters are placed manually. Otherwise,
; consider setting the cursor text color setting $0286 and outputting
; characters to screen using JSR $ffd2
charcolor:  SUBROUTINE
            LDA #$00    ; Load start address for setting character color ($d800)
            STA $08     ; 16-bit value, low
            LDA #$d8
            STA $09     ; 16-bit value, high
            LDX #0      ; Set X to 0 (no address offset)
.loop       LDA #$05    ; Green
            STA ($08,X) ; Store A in address [$01, $00] -> $d800
            CLC
            LDA $08
            ADC #1
            STA $08
            BVS .inchigh ; If overflow, increment high byte
.comp       LDA $08     ; Compare to highest color address ($dbe7) and loop until reached
            CMP #$e7
            BNE .loop
            LDA $09
            CMP #$db
            BNE .loop
            RTS
.inchigh:   CLC
            LDA $09
            ADC #1
            STA $09
            JMP .comp

test_byte:  SUBROUTINE
            CLC
            LDX #20
            LDY #19
            JSR PLOT
            LDA CIA2B_DATA        ; Convert a byte value to a hex string (2 chars)...
            JSR bytetohex
            TYA             ; ... and print them to the screen
            JSR CHROUT
            TXA
            JSR CHROUT
            RTS

; in:   A  (byte)
; out:  X  (hi-nibble)
;       Y  (lo-nibble)
bytetohex:  PHA     ; Push A to stack. A preserves value
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
hexits:             BYTE "0123456789ABCDEF"    ; IMPORTANT that characters here are capital letters!
hello_world_str:    BYTE "HELLO WORLD",0
title_1:            BYTE "L.O.C.K.",0
title_2:            BYTE "DIGITAL BOX SECURITY",0
password:           BYTE "SHPRO1",0

PW_INCORRECT:   BYTE "    ACCESS DENIED!    ",0
PW_CORRECT:     BYTE "   ACCESS APPROVED!   ",0

RS = $ea
LS = $f4

BIG_BOX_TOP:    BYTE $cf,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$d0,0
BIG_BOX_BOT:    BYTE $cc,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,0

SMALL_BOX_TOP:  BYTE $cf,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$b7,$d0,0
SMALL_BOX_SIDE: BYTE LS,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,RS,0
SMALL_BOX_BOT:  BYTE $cc,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$fa,0

; EOF - Fill up to -$9fff (or $bfff if 16K)
    ORG $9fff
    BYTE $FF

; Variable data segment - data that can change
;; Note: The 'U' below specifies the segment to be uninitialized.
;; This means that the variables will not be stored in the binary.
;; This is useful for addressing memory addresses in the C64 RAM,
;; as those addresses are outside of the cartridge memory range.
    SEG.U variables
    ORG $0200       ; C64 RAM location - stack
i:          BYTE 0
tmp:        BYTE 0
c_cnt:      BYTE 0
input:      BYTE 0,0,0,0,0,0,0,0,0,0,0  ; Length 10, zero-terminated
