!macro enableVIC4Reg {
  ; Enable VIC4 registers
  lda #$00
  tax
  tay
  taz
  map
  eom  
}

!macro enable40MHz {
  ; Enable 40Mhz
  lda #$41
  sta $00
}

!to "test.prg",cbm

!cpu m65

*=$2001
  !basic 2021,"",entry

*=$2016
entry:
  lda #$00
  
  sei
  
  +enableVIC4Reg
  +enable40MHz
  
  lda #$35
  sta $01
  
  
  ; Turn off raster interrupts
  lda #$00
  sta $d01a
  
  ; Disable CIAs
  lda #$7f
  sta $dd0d
  sta $dc0d

  cli

  
GameLoop:
  inc $d020
  inc $0800
  jmp GameLoop