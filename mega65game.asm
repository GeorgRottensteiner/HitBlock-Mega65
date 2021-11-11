!cpu m65

!to "HitBlock65.prg",cbm

!src "mega65_macros.asm"

!src <kernal.asm>

USE_16COLOR_SPRITES

SCREEN_CHAR = $a000
COLOR_RAM   = $ff80000

SCREEN_COLOR        = $d800

CURRENT_INDEX       = $10
CURRENT_SUB_INDEX   = $11
ZEROPAGE_POINTER_1  = $20
ZEROPAGE_POINTER_2  = $22
ZEROPAGE_POINTER_3  = $24
ZEROPAGE_POINTER_4  = $26

PARAM1              = $30
PARAM2              = $31
PARAM3              = $32
PARAM4              = $33
PARAM5              = $34
PARAM6              = $35
PARAM7              = $36
PARAM8              = $37
PARAM9              = $38
PARAM10             = $39
PARAM11             = $3a


* = $02
!zone ZP
  .Screen
    !dword ?
  .Color
    !dword ?

* = $2001
!basic
;          jmp *

          jsr SetupSystem

          jsr SetupScreenVector
          jsr SetupColorVector

          ;Move default screen location
          lda #<SCREEN_CHAR
          sta VIC4.SCRNPTR
          lda #>SCREEN_CHAR
          sta VIC4.SCRNPTR + 1
          lda #SCREEN_CHAR >> 16
          sta VIC4.SCRNPTR + 2
          lda #0
          sta VIC4.SCRNPTR + 3

          ;Relocate charset (Only for hires and MCM)
          ;$d068-$d06a
          ; lda #<CHARROM
          ; sta $d068
          ; lda #>CHARROM
          ; sta $d069
          ; lda #[CHARROM >> 16]
          ; sta $d06a

          lda #80
          sta VIC4.CHARSTEP_LO
          lda #0
          sta VIC4.CHARSTEP_HI

          sta VIC.BORDER_COLOR
          sta VIC.BACKGROUND_COLOR


          ;Disable hot register so VIC2 registers wont destroy VIC4 values (bit 7)
          ;turn off bit 7
          lda #$80
          trb VIC4.HOTREG

          ; Set VIC to use 40 column mode display
          ;turn off bit 7
          lda #$80
          trb VIC3.VICDIS

          ;Turn on MCM (same as C64)
          ; lda #$10
          ; tsb $d016

          ;Turn on FCM mode and 16bit per char number
          ;bit 0 = Enable 16 bit char numbers
          ;bit 1 = Enable Fullcolor for chars <=$ff
          ;bit 2 = Enable Fullcolor for chars >$ff
          lda #$07
          sta VIC4.VIC4DIS


          ;Clear 8 pages (2000 bytes) for Hires and MCM
          ; lda #$00
          ; ldx #$08;Pages to clear
          ; jsr ScreenClear32bitAddr
          ; lda #$08
          ; ldx #$08;Pages to clear
          ; jsr ColorClear32bitAddr

          ;Clear 16 pages (4000 bytes) FCM
          lda #$00
          ldx #$10;Pages to clear
          jsr ScreenClear32bitAddr
          lda #$08
          ldx #$10;Pages to clear
          ;jsr ColorClear32bitAddr




          jsr SetPalette

          ;change the 16 bit extended atrributes
          ;ldz #$00
          ;lda #%10000001 ;Set bit 7 = Vertical flip
          ;sta [ZP.Color], z
          ;lda #$00000000
          ;inz
          ;sta [ZP.Color], z

          ;lda #%10000000 ;Set bit 7 = Vertical flip
          ;inz
          ;sta [ZP.Color], z

          lda #<4088
          sta VIC4.SPRPTRADR_LO
          lda #>4088
          sta VIC4.SPRPTRADR_HI

          jmp HandleTitle



!zone SetPalette
SetPalette
          ;Bit 6-7 = Mapped Palette
          ;bit 0-1 = Char palette index
          lda #%01011001
          sta VIC4.PALSEL


          ;copy palette data (16 entries),
          ;copy 8 times since the palette is also used for sprites
          ;and sprite palettes offset is 16 * sprite index
          ldy #0
--
          ldx #0
-

          lda PALETTE_DATA_R, x
          sta VIC4.PALRED,y
          lda PALETTE_DATA_G, x
          sta VIC4.PALGREEN,y
          lda PALETTE_DATA_B, x
          sta VIC4.PALBLUE,y

          iny
          inx
          cpx #16
          bne -

          cpy #128
          bne --

          ;duplicate sprite palettes
          ;use palette bank 1
          lda #%10001001
          sta VIC4.PALSEL

          ldx #$00
          ldy #0
-
          lda PALETTE_DATA_R + 16, x
          sta VIC4.PALRED,y
          lda PALETTE_DATA_G + 16, x
          sta VIC4.PALGREEN,y
          lda PALETTE_DATA_B + 16, x
          sta VIC4.PALBLUE,y

          iny
          inx
          cpx #10
          bne -

          ldx #0
          tya
          clc
          adc #16 - 10
          tay
          cpy #8 * 16
          bne -

          ;lda #$c4 ;ff ;$c4 / 2
          ;sta VIC4.PALRED + 2
          ;lda #$cc
          ;sta VIC4.PALGREEN + 2
          ;lda #$68
          ;sta VIC4.PALBLUE + 2

          rts



PALETTE_DATA_R
        ;256 reds (only color that is 7 bits not 8)
        ;Missing bit because of nybble swap = bit 4
        !byte $00,$55,$00,$55,$00,$55,$00,$55,$aa,$aa,$ff,$aa,$ff,$ff,$aa,$ff

        !byte 0,$36,$4c,$0e,$5f,0,$78,$3c,$cc,$ac

PALETTE_DATA_G
        ;256 greens
        !byte $00,$55,$00,$55,$aa,$ff,$aa,$ff,$00,$55,$55,$00,$55,$ff,$aa,$ff

        !byte 0,$95,$cc,$6d,$5f,0,$33,$35,$c7,$8b

PALETTE_DATA_B
        ;256 blues
        !byte $00,$55,$AA,$FF,$00,$55,$aa,$ff,$00,$00,$55,$aa,$ff,$55,$aa,$ff

        !byte 0,$e2,$86,$7a,$6e,0,$e2,$74,$06,$f5

;CC7C60

!zone ColorClear32bitAddr
;x = num pages, a = color value to set
ColorClear32bitAddr
          jsr SetupColorVector
.Outerloop
          ldz #$00
      -
          sta [ZP.Color], z
          inz
          bne -
          dex
          beq +
          inc ZP.Color + 1
          bra .Outerloop
+

          jmp SetupColorVector



!zone ScreenClear32bitAddr
ScreenClear32bitAddr
          jsr SetupColorVector
          jsr SetupScreenVector

--
          ldz #$00
-
          lda #0
          sta [ZP.Screen], z
          lda #$00
          sta [ZP.Color], z
          inz

          ;force chars to $100!
          lda #$01
          sta [ZP.Screen], z

          lda #0
          sta [ZP.Color], z

          inz
          bne -

          dex
          beq +

          inc ZP.Screen + 1
          inc ZP.Color + 1
          bra --

+

          jsr SetupColorVector
          jmp SetupScreenVector



!zone SetupScreenVector
SetupScreenVector
          lda #<SCREEN_CHAR
          sta ZP.Screen + 0
          lda #>SCREEN_CHAR
          sta ZP.Screen + 1
          lda #SCREEN_CHAR >> 16
          sta ZP.Screen + 2
          lda #$00
          sta ZP.Screen + 3
          rts



!zone SetupColorVector
SetupColorVector
          phx
          ldx #<COLOR_RAM
          stx ZP.Color + 0
          ldx #>COLOR_RAM
          stx ZP.Color + 1
          ldx #( COLOR_RAM >> 16 ) & $ff
          stx ZP.Color + 2
          ldx #( COLOR_RAM >> 24 )
          stx ZP.Color + 3
          plx
          rts



!zone SetupSystem
SetupSystem
          lda #$00

          sei

          +enableVIC4Registers

          lda #$35
          sta $01

          ;+enable40Mhz
          ;+enableVIC4Registers

          ;Turn off CIA interrupts
          lda #$7f
          sta $dc0d
          sta $dd0d

          ;Turn off raster interrupts, used by C65 rom
          lda #$00
          sta $d01a

          ;Disable C65 rom write protection
          ;$20000 - $3ffff
          lda #$70
          sta $d640
          eom

          +enable40Mhz

          cli
          rts



!zone DisplayHex
;x = offset
;a = value
DisplayHex
          sta PARAM10

          txa
          asl
          tax

          lda PARAM10
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX_CHAR,y
          sta SCREEN_CHAR + 80 * 24,x
          inc
          sta SCREEN_CHAR + 80 * 24 + 2,x

          lda PARAM10
          and #$0f
          tay
          lda HEX_CHAR,y
          sta SCREEN_CHAR + 80 * 24 + 4,x
          inc
          sta SCREEN_CHAR + 80 * 24 + 6,x
          rts

HEX_CHAR
          !byte 64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94


!ifdef USE_16COLOR_SPRITES {
;SPRITE_POINTERS
;          !fill 8 * 2
SPRITE_POINTER_BASE = $0ff8
} else {
SPRITE_POINTER_BASE = $0ff8
}


;16 bit char addresses (charnum = addr/64)
;  $000 = $0000
;  $001 = $0040
;  $002 = $0080
;  ...
;  $100 = $4000


!realign 256
SPRITE_DATA
!ifdef USE_16COLOR_SPRITES {
;tile 0, 0
        !byte 0,102,102,0,0,0,0,0
        !byte 6,51,51,32,0,0,0,0
        !byte 99,115,51,50,0,0,0,0
        !byte 99,51,51,50,0,0,0,0
        !byte 99,51,51,50,0,0,0,0
        !byte 99,51,51,34,0,0,0,0
        !byte 2,51,50,32,0,0,0,0
        !byte 0,34,34,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,0,1

!realign 256
        ;red ball
        !byte 0,170,170,0,0,0,0,0
        !byte 10,136,136,144,0,0,0,0
        !byte 168,120,136,137,0,0,0,0
        !byte 168,136,136,137,0,0,0,0
        !byte 168,136,136,137,0,0,0,0
        !byte 168,136,136,153,0,0,0,0
        !byte 9,136,137,144,0,0,0,0
        !byte 0,153,153,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,1,1

!realign 256
        ;green ball
        !byte 0,85,85,0,0,0,0,0
        !byte 5,68,68,32,0,0,0,0
        !byte 84,116,68,66,0,0,0,0
        !byte 84,68,68,66,0,0,0,0
        !byte 84,68,68,66,0,0,0,0
        !byte 84,68,68,34,0,0,0,0
        !byte 2,68,66,32,0,0,0,0
        !byte 0,34,34,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,2,1

!realign 256
        ;yellow ball
        !byte 0,255,255,0,0,0,0,0
        !byte 15,221,221,144,0,0,0,0
        !byte 253,125,221,217,0,0,0,0
        !byte 253,221,221,217,0,0,0,0
        !byte 253,221,221,217,0,0,0,0
        !byte 253,221,221,153,0,0,0,0
        !byte 9,221,217,144,0,0,0,0
        !byte 0,153,153,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,3,1

!realign 256
        ;purple ball
        !byte 0,204,204,0,0,0,0,0
        !byte 12,187,187,16,0,0,0,0
        !byte 203,123,187,177,0,0,0,0
        !byte 203,187,187,177,0,0,0,0
        !byte 203,187,187,177,0,0,0,0
        !byte 203,187,187,17,0,0,0,0
        !byte 1,187,177,16,0,0,0,0
        !byte 0,17,17,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,4,1

!realign 256
        ;brown ball
        !byte 0,221,221,0,0,0,0,0
        !byte 13,153,153,16,0,0,0,0
        !byte 217,121,153,145,0,0,0,0
        !byte 217,153,153,145,0,0,0,0
        !byte 217,153,153,145,0,0,0,0
        !byte 217,153,153,17,0,0,0,0
        !byte 1,153,145,16,0,0,0,0
        !byte 0,17,17,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,5,1

!realign 256
SPRITE_DATA_BLUE_DISK
        ;blue disk
        !byte 119,119,119,119,119,119,119,115
        !byte 115,51,51,51,51,51,51,49
        !byte 115,51,51,51,51,51,51,49
        !byte 115,51,51,51,51,51,51,49
        !byte 115,3,51,51,51,51,51,49
        !byte 115,51,51,48,3,51,51,49
        !byte 115,51,51,0,0,51,51,49
        !byte 115,51,48,0,0,3,51,49
        !byte 115,51,48,0,0,3,51,49
        !byte 115,51,51,0,0,51,51,49
        !byte 115,51,51,48,3,51,51,49
        !byte 115,51,51,51,51,51,51,49
        !byte 115,51,51,48,3,51,51,49
        !byte 115,51,51,48,3,51,51,49
        !byte 115,51,51,51,51,51,51,49
        !byte 49,17,17,17,17,17,17,17
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,6,1

!realign 256
        ;red disk
        !byte 170,170,170,170,170,170,170,168
        !byte 168,136,136,136,136,136,136,129
        !byte 168,136,136,136,136,136,136,129
        !byte 168,136,136,136,136,136,136,129
        !byte 168,8,136,136,136,136,136,129
        !byte 168,136,136,128,8,136,136,129
        !byte 168,136,136,0,0,136,136,129
        !byte 168,136,128,0,0,8,136,129
        !byte 168,136,128,0,0,8,136,129
        !byte 168,136,136,0,0,136,136,129
        !byte 168,136,136,128,8,136,136,129
        !byte 168,136,136,136,136,136,136,129
        !byte 168,136,136,128,8,136,136,129
        !byte 168,136,136,128,8,136,136,129
        !byte 168,136,136,136,136,136,136,129
        !byte 129,17,17,17,17,17,17,17
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,7,1

!realign 256
        ;green disk
        !byte 85,85,85,85,85,85,85,84
        !byte 84,68,68,68,68,68,68,65
        !byte 84,68,68,68,68,68,68,65
        !byte 84,68,68,68,68,68,68,65
        !byte 84,4,68,68,68,68,68,65
        !byte 84,68,68,64,4,68,68,65
        !byte 84,68,68,0,0,68,68,65
        !byte 84,68,64,0,0,4,68,65
        !byte 84,68,64,0,0,4,68,65
        !byte 84,68,68,0,0,68,68,65
        !byte 84,68,68,64,4,68,68,65
        !byte 84,68,68,68,68,68,68,65
        !byte 84,68,68,64,4,68,68,65
        !byte 84,68,68,64,4,68,68,65
        !byte 84,68,68,68,68,68,68,65
        !byte 65,17,17,17,17,17,17,17
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 64
!media "sprites.spriteproject",sprite,8,1

!realign 256
        ;yellow disk
        !byte 255,255,255,255,255,255,255,253
        !byte 253,221,221,221,221,221,221,209
        !byte 253,221,221,221,221,221,221,209
        !byte 253,221,221,221,221,221,221,209
        !byte 253,13,221,221,221,221,221,209
        !byte 253,221,221,208,13,221,221,209
        !byte 253,221,221,0,0,221,221,209
        !byte 253,221,208,0,0,13,221,209
        !byte 253,221,208,0,0,13,221,209
        !byte 253,221,221,0,0,221,221,209
        !byte 253,221,221,208,13,221,221,209
        !byte 253,221,221,221,221,221,221,209
        !byte 253,221,221,208,13,221,221,209
        !byte 253,221,221,208,13,221,221,209
        !byte 253,221,221,221,221,221,221,209
        !byte 209,17,17,17,17,17,17,17
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 256
        ;purple disk
        !byte 204,204,204,204,204,204,204,203
        !byte 203,187,187,187,187,187,187,177
        !byte 203,187,187,187,187,187,187,177
        !byte 203,187,187,187,187,187,187,177
        !byte 203,11,187,187,187,187,187,177
        !byte 203,187,187,176,11,187,187,177
        !byte 203,187,187,0,0,187,187,177
        !byte 203,187,176,0,0,11,187,177
        !byte 203,187,176,0,0,11,187,177
        !byte 203,187,187,0,0,187,187,177
        !byte 203,187,187,176,11,187,187,177
        !byte 203,187,187,187,187,187,187,177
        !byte 203,187,187,176,11,187,187,177
        !byte 203,187,187,176,11,187,187,177
        !byte 203,187,187,187,187,187,187,177
        !byte 177,17,17,17,17,17,17,17
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

!realign 256
        ;brown disk
        !byte 221,221,221,221,221,221,221,217
        !byte 217,153,153,153,153,153,153,145
        !byte 217,153,153,153,153,153,153,145
        !byte 217,153,153,153,153,153,153,145
        !byte 217,9,153,153,153,153,153,145
        !byte 217,153,153,144,9,153,153,145
        !byte 217,153,153,0,0,153,153,145
        !byte 217,153,144,0,0,9,153,145
        !byte 217,153,144,0,0,9,153,145
        !byte 217,153,153,0,0,153,153,145
        !byte 217,153,153,144,9,153,153,145
        !byte 217,153,153,153,153,153,153,145
        !byte 217,153,153,144,9,153,153,145
        !byte 217,153,153,144,9,153,153,145
        !byte 217,153,153,153,153,153,153,145
        !byte 145,17,17,17,17,17,17,17
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0
        !byte 0,0,0,0,0,0,0,0

} else {

        !byte $3c,$00,$00,$7e,$00,$00,$ff,$00
        !byte $00,$ff,$00,$00,$ff,$00,$00,$ff
        !byte $00,$00,$7e,$00,$00,$3c,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$01
}

;!realign 64
!realign 256
TITLE_LETTER_SPRITES
!realign 256
          ;sprite 0, 0
        !byte 50,34,34,32,3,34,34,34
        !byte 36,51,50,80,2,67,51,34
        !byte 35,34,33,80,2,50,34,21
        !byte 35,34,33,80,2,50,34,21
        !byte 147,146,145,80,2,50,146,21
        !byte 34,41,33,80,9,41,41,21
        !byte 146,153,145,80,9,41,153,21
        !byte 146,153,145,153,153,41,153,21
        !byte 137,137,137,146,146,153,137,21
        !byte 146,152,152,152,152,152,152,21
        !byte 137,136,136,136,136,136,136,21
        !byte 137,136,136,136,136,136,136,21
        !byte 121,120,113,17,17,135,135,21
        !byte 136,135,129,85,88,136,120,21
        !byte 120,119,113,80,7,135,119,21
        !byte 120,119,113,80,7,135,119,21
        !byte 104,103,97,80,6,134,118,21
        !byte 119,118,113,80,7,119,103,21
        !byte 103,102,97,80,6,118,102,21
        !byte 102,17,17,80,6,97,17,21
        !byte 101,85,85,80,6,85,85,85
!realign 256
          ;sprite 16, 0
        !byte 50,34,34,34,34,34,34,34
        !byte 36,51,51,51,51,51,51,37
        !byte 35,34,34,34,34,34,34,21
        !byte 35,34,34,34,34,34,34,21
        !byte 147,146,146,146,146,146,146,21
        !byte 41,17,25,41,41,17,17,21
        !byte 149,85,146,153,153,21,85,85
        !byte 0,0,146,153,153,21,0,0
        !byte 0,0,130,137,137,21,0,0
        !byte 0,0,153,152,152,21,0,0
        !byte 0,0,137,136,136,21,0,0
        !byte 0,0,137,136,136,21,0,0
        !byte 0,0,120,120,120,21,0,0
        !byte 0,0,137,135,135,21,0,0
        !byte 135,119,120,119,119,23,119,119
        !byte 121,136,136,119,119,120,136,117
        !byte 104,103,103,103,103,103,103,21
        !byte 119,118,118,118,118,118,118,21
        !byte 104,102,102,102,102,102,102,21
        !byte 102,17,17,17,17,17,17,21
        !byte 101,85,85,85,85,85,85,85
!realign 256
          ;sprite 32, 0
        !byte 50,34,34,34,34,34,34,34
        !byte 36,51,51,51,51,51,51,37
        !byte 35,34,34,34,34,34,34,21
        !byte 35,34,34,34,34,34,34,21
        !byte 147,146,146,146,146,146,146,21
        !byte 41,17,25,41,41,17,17,21
        !byte 149,85,146,153,153,21,85,85
        !byte 0,0,146,153,153,21,0,0
        !byte 0,0,130,137,137,21,0,0
        !byte 0,0,153,152,152,21,0,0
        !byte 0,0,137,136,136,21,0,0
        !byte 0,0,137,136,136,21,0,0
        !byte 0,0,120,120,120,21,0,0
        !byte 0,0,137,135,135,21,0,0
        !byte 0,0,120,119,119,21,0,0
        !byte 0,0,120,119,119,21,0,0
        !byte 0,0,104,103,103,21,0,0
        !byte 0,0,119,118,118,21,0,0
        !byte 0,0,104,102,102,21,0,0
        !byte 0,0,102,17,17,21,0,0
        !byte 0,0,101,85,85,85,0,0
!realign 256
          ;sprite 48, 0
        !byte 50,34,34,34,34,34,32,0
        !byte 36,51,51,51,51,51,50,32
        !byte 35,34,34,34,34,34,34,16
        !byte 35,34,34,34,34,34,33,21
        !byte 147,146,146,146,146,146,146,21
        !byte 34,41,33,17,17,25,41,21
        !byte 146,153,145,85,85,153,153,21
        !byte 146,153,145,153,153,41,153,21
        !byte 137,137,137,34,34,41,137,21
        !byte 146,152,152,152,152,152,145,80
        !byte 137,136,136,136,136,136,129,80
        !byte 137,136,136,136,136,136,136,21
        !byte 121,120,113,17,17,24,120,21
        !byte 136,135,129,85,85,135,135,21
        !byte 120,119,113,119,119,135,119,21
        !byte 120,119,119,136,136,135,119,21
        !byte 104,103,103,103,103,103,103,21
        !byte 119,118,118,118,118,118,118,21
        !byte 104,102,102,102,102,102,97,80
        !byte 102,17,17,17,17,17,21,80
        !byte 101,85,85,85,85,85,80,0
!realign 256
          ;sprite 64, 0
        !byte 50,34,34,32,0,0,0,0
        !byte 36,51,50,80,0,0,0,0
        !byte 35,34,33,80,0,0,0,0
        !byte 35,34,33,80,0,0,0,0
        !byte 147,146,145,80,0,0,0,0
        !byte 34,41,33,80,0,0,0,0
        !byte 146,153,145,80,0,0,0,0
        !byte 146,153,145,80,0,0,0,0
        !byte 137,137,129,80,0,0,0,0
        !byte 146,152,145,80,0,0,0,0
        !byte 137,136,129,80,0,0,0,0
        !byte 137,136,129,80,0,0,0,0
        !byte 121,120,113,80,0,0,0,0
        !byte 136,135,129,80,0,0,0,0
        !byte 120,119,113,119,119,119,119,119
        !byte 120,119,119,136,136,136,136,117
        !byte 104,103,103,103,103,103,103,21
        !byte 119,118,118,118,118,118,118,21
        !byte 104,102,102,102,102,102,102,21
        !byte 102,17,17,17,17,17,17,21
        !byte 101,85,85,85,85,85,85,85
!realign 256
          ;sprite 80, 0
        !byte 0,2,34,34,34,34,32,0
        !byte 0,35,51,51,51,51,50,0
        !byte 2,50,34,34,34,34,34,16
        !byte 35,34,34,34,34,34,33,21
        !byte 147,146,146,146,146,146,146,21
        !byte 34,41,41,17,17,41,41,21
        !byte 146,153,145,85,89,41,153,21
        !byte 146,153,145,80,9,41,153,21
        !byte 137,137,129,80,9,153,137,21
        !byte 146,152,145,80,8,152,152,21
        !byte 137,136,129,80,8,152,136,21
        !byte 137,136,129,80,8,152,136,21
        !byte 121,120,113,80,8,136,120,21
        !byte 136,135,129,80,7,151,135,21
        !byte 120,119,113,119,119,135,119,21
        !byte 120,119,119,136,136,119,119,21
        !byte 104,103,103,103,103,103,103,21
        !byte 119,118,118,118,118,118,118,21
        !byte 6,102,102,102,102,102,97,80
        !byte 0,81,17,17,17,17,21,0
        !byte 0,5,85,85,85,85,80,0
!realign 256
          ;sprite 96, 0
        !byte 0,2,34,34,34,34,32,0
        !byte 0,35,51,51,51,51,50,0
        !byte 2,50,34,34,34,34,34,16
        !byte 35,34,34,34,34,34,33,21
        !byte 147,146,146,146,146,146,146,21
        !byte 34,41,41,17,17,41,41,21
        !byte 146,153,145,85,89,153,153,21
        !byte 146,153,145,80,9,145,17,21
        !byte 137,137,129,80,9,85,85,85
        !byte 146,152,145,80,0,0,0,0
        !byte 137,136,129,80,0,0,0,0
        !byte 137,136,129,80,0,0,0,0
        !byte 121,120,113,80,8,120,120,120
        !byte 136,135,129,80,7,152,136,117
        !byte 120,119,113,119,119,135,119,21
        !byte 120,119,119,136,136,119,119,21
        !byte 104,103,103,103,103,103,103,21
        !byte 119,118,118,118,118,118,118,21
        !byte 6,102,102,102,102,102,97,80
        !byte 0,81,17,17,17,17,21,0
        !byte 0,5,85,85,85,85,80,0
!realign 256
          ;sprite 112, 0
        !byte 50,34,34,32,3,34,34,34
        !byte 36,51,50,80,2,67,51,34
        !byte 35,34,33,80,2,50,34,21
        !byte 35,34,33,80,2,50,34,21
        !byte 147,146,145,80,2,50,146,21
        !byte 34,41,33,80,9,41,41,21
        !byte 146,153,145,80,9,41,153,21
        !byte 146,153,145,153,153,41,153,21
        !byte 137,137,137,146,146,153,137,21
        !byte 146,152,152,152,152,152,145,80
        !byte 137,136,136,136,136,136,129,80
        !byte 137,136,136,136,136,136,136,21
        !byte 121,120,113,17,17,24,120,21
        !byte 136,135,129,85,85,135,135,21
        !byte 120,119,113,80,7,135,119,21
        !byte 120,119,113,80,7,135,119,21
        !byte 104,103,97,80,6,134,118,21
        !byte 119,118,113,80,7,119,103,21
        !byte 103,102,97,80,6,118,102,21
        !byte 102,17,17,80,6,97,17,21
        !byte 101,85,85,80,6,85,85,85

        ;!media "sprites.spriteproject",SPRITE,9,8

!src "title.asm"
!src "game.asm"

;one byte is one pixel
* = $4000
!src "tiles.asm"

!src "sfxplay.asm"
!src "objects.asm"
!src "level.asm"
!src "welldone.asm"


!zone PlaySoundEffect
PlaySoundEffectInChannel0
          lda #0

;y = SFX_...
;a = channel 0,1,2
PlaySoundEffect
          pha
          ldx SFX_TABLE_LO,y
          lda SFX_TABLE_HI,y
          tay
          pla
          jmp SFXPlay



SFX_BALL_BOUNCE   = 0
SFX_DISK_PUSH     = 1
SFX_COLOR_CHANGE  = 2
SFX_BRICK_BREAK   = 3
SFX_BALL_KILLED   = 4
SFX_BONUS_BLIP    = 5

SFX_TABLE_LO
          !byte <FX_BOUNCE
          !byte <FX_DISK_PUSH
          !byte <FX_COLOR_CHANGE
          !byte <FX_BRICK_BREAK
          !byte <FX_BALL_KILLED
          !byte <FX_BONUS_BLIP

SFX_TABLE_HI
          !byte >FX_BOUNCE
          !byte >FX_DISK_PUSH
          !byte >FX_COLOR_CHANGE
          !byte >FX_BRICK_BREAK
          !byte >FX_BALL_KILLED
          !byte >FX_BONUS_BLIP

FX_BOUNCE
          ;!byte ( FX_SLIDE_PING_PONG << 2 ) | FX_WAVE_SAWTOOTH
          ;!hex c20b2d459db50106
          ;!byte FX_STEP
          !byte ( FX_SLIDE << 2 ) | FX_WAVE_NOISE
          !hex 362c7ca48cf4e317dc

FX_DISK_PUSH
          !byte ( FX_SLIDE_PING_PONG << 2 ) | FX_WAVE_TRIANGLE
          !hex ef163e668eb60209
          !byte FX_STEP

FX_COLOR_CHANGE
          !byte ( FX_SLIDE << 2 ) | FX_WAVE_PULSE
          !hex 2d057d558de50306dd

FX_BRICK_BREAK
          !byte ( FX_SLIDE << 2 ) | FX_WAVE_NOISE
          !hex 4c2599c86b0dfc2b20

FX_BALL_KILLED
          !byte ( FX_SLIDE << 2 ) | FX_WAVE_NOISE
          !hex b50a062e567eff2b18

FX_BONUS_BLIP
          !byte ( FX_SLIDE_PING_PONG << 2 ) | FX_WAVE_TRIANGLE
          !hex e60f375f87af1cf8d7

