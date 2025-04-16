# Assembler project for C64

## Setup development environment

- Install dasm assembler for 6502 assembly:

```sh
apt install dasm
```

- Install VICE (emulator):

```sh
apt install vice
```

Note: Due to copyrights, the binaries for VICE needs to be downloaded from
either their downloadable archive or somewhere else. Install in directory
`/usr/share/vice/` (drag and drop content from their archives 'data' directory).

## Building the project

- Build binary and .crt (emulator) files:

```sh
make
```

- Pad binary to fit EPROM size:

```
./append.sh
```

Note: This is a temporary solution to the EPROM programmer project currently
being limited to write a whole 64K binary to the EPROM - no more, no less.

## Cartridge startup code

```
 PROCESSOR 6502     ; dasm specific

 ORG $8000          ; dasm way of specifying current origin (basically where to put following data)
                    ; $8000 is the start address for cartridge bank 0 (8K). Bank 1 starts at $A000 (8K).

    .word coldstart             ; Cold start/hard reset start-up vector
    .word warmstart             ; Warm start/soft reset start-up vector. Basically the actual cartridge ROM to be executed.
    .byte $C3,$C2,$CD,$38,$30   ; "CMB80". Autostart string. Makes the C64 recognize this as a cartridge.

coldstart
    SEI         ; Set Interrupt
    STX $d016   ; Store register x (but why?)
    JSR $fda3   ; Prepare IRQ
    JSR $fd50   ; Init memory. Rewrite this routine to speed up boot process
    JSR $fd15   ; Init I/O
    JSR $ff5b;  ; Init video
    CLI         ; Clear interrupt

warmstart
    ; Insert your code here. The following is example code.
    LDA #$55    ; Load color 00 (black) into accumulator
    STA $d020   ; Store accumulator value (00/black) into border color
    INC $d021   ; Increase value at box color
    JMP *-3     ; Jump back 3 bytes

 ORG $9fff       ; Padding. 0xFF all the way until address $9fff (or $bfff if 16K)
    .byte 0      ; Last byte ends up being 0. Unsure whether this could technically be 0xFF.

```

## DASM notes

Start out by specifying processor:

```
 PROCESSOR 6502     ; OBS! Note the space at the start of the line!!
```

## Assembler notes

- [6502 Opcodes (ASM instructions?)](http://www.6502.org/tutorials/6502opcodes.html)

### Number literals

- Decimal:  `#123`
- Binary:   `#%10110100`
- Hex:      `#$12FE`

### 6502 Registers

Info source: [Assembly in one step](https://dwheeler.com/6502/oneelkruns/asm1step.html)

6502 has a total of 5 registers.

Three general purpose:
- A (accumulator)
    - Used for most buisness, arithmetics, comparisons, shifts.
- X and Y (general purpose registers)
    - Often used to hold offsets to memory locations.

Two special registers:
- S (stack pointer)
- P (processor status)
    - Not directly addressable by any 6502 instruction. Defined instructions
    will test on the register value behind the scenes.

### Addressing modes

- Immediate             #aa
    Immidiate or literal value.
    E.g. `LDA #$99` loads 0x99 into the accumulator.

- Absolute              aaaa
    Given value is a 16-bit address to location containing 8-bit value.
    E.g. `STA $3E32` stores the value in accumulator in memory location 0x3E32.

- Zero page             aa
    First 256 memory locations ($0000-00FF) are called "zero page".
    E.g.:
        `LDA $0023` uses an extra byte.
        `LDA $23`   is equivalent, saving one byte.

- Implied
    Some commands execute specific operation that do not reference memory.
    E.g.:
        `CLC` clears the carry flag
        `DEX` decrements the X register by one
        `TYA` Transfers the Y register to the accumulator

- Indirect absolute     (aaaa)
    Only used by `JMP`. Takes the given address ans uses it as a pointer to
    the low part of a 16-bit address in memory, then jumps to that address.
    E.g. `JMP ($2345)` jumps to address in $2345 low and $2346 high.

- Absolute indexed, X   aaaa,X
    

- Absolute indexed, Y   aaaa,Y
- Zero page indexed, X  aa,X
- Zero page indexed, Y  aa,Y
- Indexed indirect      (aa,X)
- Indirect indexed      (aa),Y
- Relative              aaaa
- Accumulator           A



### Some assembler good to know

```
LDA #5      ; Load decimal value 5 into accumulator
LDA #$05    ; Load hex value 0x05 (decimal 5) into accumulator
LDA $0005   ; Load value at address 0x0005 into accumulator
```
