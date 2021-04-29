TITLE_SPRITE_X_POS = 80

TITLE_FADE_COLOR_INDEX = 15
  
!zone HandleTitle
HandleTitle
          lda #15
          ldx #$10
          jsr ColorClear32bitAddr
          
          lda #$ff
          sta VIC4.SPR16EN
          sta VIC4.SPRX64EN
          
          ;enable palette 00 from RAM
          lda #$fc
          trb VIC3.ROMBANK
          
          ;set sprite palette bank 2
          lda #%00001000
          sta VIC4.PALSEL
          
          ;set default palette colors
          ldx #0
-          
          lda PALETTE_DEFAULT_16_COLORS_R,x
          sta VIC4.PALRED,x
          lda PALETTE_DEFAULT_16_COLORS_G,x
          sta VIC4.PALGREEN,x
          lda PALETTE_DEFAULT_16_COLORS_B,x
          sta VIC4.PALBLUE,x
          inx
          cpx #16
          bne -
          
          lda #0
          sta VIC4.PALRED + TITLE_FADE_COLOR_INDEX
          sta VIC4.PALGREEN + TITLE_FADE_COLOR_INDEX
          sta VIC4.PALBLUE + TITLE_FADE_COLOR_INDEX
          sta PAL_POS
          sta COLOR_INDEX
          sta PAL_COLORS
          sta PAL_COLORS + 1
          sta PAL_COLORS + 2
     
          lda #TITLE_SPRITE_X_POS
          sta VIC.SPRITE_X_POS
          lda #TITLE_SPRITE_X_POS + 1 * 28
          sta VIC.SPRITE_X_POS + 2
          lda #TITLE_SPRITE_X_POS + 2 * 28
          sta VIC.SPRITE_X_POS + 4
          lda #TITLE_SPRITE_X_POS + 3 * 28
          sta VIC.SPRITE_X_POS + 6
          lda #TITLE_SPRITE_X_POS + 4 * 28
          sta VIC.SPRITE_X_POS + 8
          lda #TITLE_SPRITE_X_POS + 5 * 28
          sta VIC.SPRITE_X_POS + 10
          lda #TITLE_SPRITE_X_POS + 6 * 28
          sta VIC.SPRITE_X_POS + 12
          lda #< ( TITLE_SPRITE_X_POS + 7 * 28 )
          sta VIC.SPRITE_X_POS + 14
          lda #$80
          sta VIC.SPRITE_X_EXTEND
          
          lda #70
          sta VIC.SPRITE_Y_POS
          sta VIC.SPRITE_Y_POS + 2
          sta VIC.SPRITE_Y_POS + 4
          sta VIC.SPRITE_Y_POS + 6
          sta VIC.SPRITE_Y_POS + 8
          sta VIC.SPRITE_Y_POS + 10
          sta VIC.SPRITE_Y_POS + 12
          sta VIC.SPRITE_Y_POS + 14
          
          lda #TITLE_LETTER_SPRITES / 64
          sta SPRITE_POINTER_BASE
          lda #( 1 * 256 + TITLE_LETTER_SPRITES ) / 64
          sta SPRITE_POINTER_BASE + 1
          lda #( 2 * 256 + TITLE_LETTER_SPRITES ) / 64
          sta SPRITE_POINTER_BASE + 2
          lda #( 3 * 256 + TITLE_LETTER_SPRITES ) / 64
          sta SPRITE_POINTER_BASE + 3
          lda #( 4 * 256 + TITLE_LETTER_SPRITES ) / 64
          sta SPRITE_POINTER_BASE + 4
          lda #( 5 * 256 + TITLE_LETTER_SPRITES ) / 64
          sta SPRITE_POINTER_BASE + 5
          lda #( 6 * 256 + TITLE_LETTER_SPRITES ) / 64
          sta SPRITE_POINTER_BASE + 6
          lda #( 7 * 256 + TITLE_LETTER_SPRITES ) / 64
          sta SPRITE_POINTER_BASE + 7
          
          lda #15
          sta VIC.SPRITE_MULTICOLOR_1
          lda #1
          sta VIC.SPRITE_MULTICOLOR_2
          
          ;transparent color index for 16color sprites
          lda #0 ;13
          sta VIC.SPRITE_COLOR
          sta VIC.SPRITE_COLOR + 1
          sta VIC.SPRITE_COLOR + 2
          sta VIC.SPRITE_COLOR + 3
          sta VIC.SPRITE_COLOR + 4
          sta VIC.SPRITE_COLOR + 5
          sta VIC.SPRITE_COLOR + 6
          sta VIC.SPRITE_COLOR + 7

          lda #$ff
          ;sta VIC.SPRITE_MULTICOLOR
          sta VIC.SPRITE_ENABLE
          
          lda #0
          sta VIC.BACKGROUND_COLOR
          
          ldx #0
          
-         
          lda #32 ;160
          sta SCREEN_CHAR,x
          sta SCREEN_CHAR + 1 * 250,x
          sta SCREEN_CHAR + 2 * 250,x
          sta SCREEN_CHAR + 3 * 250,x
          sta SCREEN_CHAR + 4 * 250,x
          sta SCREEN_CHAR + 5 * 250,x
          sta SCREEN_CHAR + 6 * 250,x
          sta SCREEN_CHAR + 7 * 250,x
          
          inx
          cpx #250
          bne -
          
          lda #<TEXT_WRITTEN_BY
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_WRITTEN_BY
          sta ZEROPAGE_POINTER_1 + 1
          lda #<( SCREEN_CHAR + 8 * 80 + 27 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_CHAR + 8 * 80 + 27 )
          sta ZEROPAGE_POINTER_2 + 1
          jsr DisplayText
          
          lda #<TEXT_FOR_COMPO
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_FOR_COMPO
          sta ZEROPAGE_POINTER_1 + 1
          lda #<( SCREEN_CHAR + 10 * 80 + 27 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_CHAR + 10 * 80 + 27 )
          sta ZEROPAGE_POINTER_2 + 1
          jsr DisplayText

          lda #<TEXT_INSTRUCTIONS_1
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_INSTRUCTIONS_1
          sta ZEROPAGE_POINTER_1 + 1
          lda #<( SCREEN_CHAR + 13 * 80 + 3 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_CHAR + 13 * 80 + 3 )
          sta ZEROPAGE_POINTER_2 + 1
          jsr DisplayText

          lda #<TEXT_INSTRUCTIONS_2
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_INSTRUCTIONS_2
          sta ZEROPAGE_POINTER_1 + 1
          lda #<( SCREEN_CHAR + 14 * 80 + 3 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_CHAR + 14 * 80 + 3 )
          sta ZEROPAGE_POINTER_2 + 1
          jsr DisplayText

          lda #<TEXT_INSTRUCTIONS_3
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_INSTRUCTIONS_3
          sta ZEROPAGE_POINTER_1 + 1
          lda #<( SCREEN_CHAR + 15 * 80 + 3 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_CHAR + 15 * 80 + 3 )
          sta ZEROPAGE_POINTER_2 + 1
          jsr DisplayText

          lda #<TEXT_PRESS_FIRE
          sta ZEROPAGE_POINTER_1
          lda #>TEXT_PRESS_FIRE
          sta ZEROPAGE_POINTER_1 + 1
          lda #<( SCREEN_CHAR + 22 * 80 + 26 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_CHAR + 22 * 80 + 26 )
          sta ZEROPAGE_POINTER_2 + 1
          jsr DisplayText
          
          jsr WaitFrame
          
          ;80 col mode
          lda #$80    
          tsb VIC3.VICDIS

          ;Turn off FCM mode and 16bit per char number
          lda #$00
          sta VIC4.VIC4DIS
          
          lda #80
          sta VIC4.CHARSTEP_LO
          lda #0
          sta VIC4.CHARSTEP_HI
          
TitleLoop
          lda #60
          jsr WaitForLine
          ldx #13
          stx VIC.BACKGROUND_COLOR
          inc
          jsr WaitForLine
          ldx #0
          stx VIC.BACKGROUND_COLOR
          inc
          jsr WaitForLine
          ldx #8
          stx VIC.BACKGROUND_COLOR
          
          jsr WaitFrame

          ;color "effect"
          ldy PAL_INDEX
          lda COLOR_INDEX,y
          tax
          clc
          adc #$d1
          sta .ColorIndex
          
          lda PAL_COLORS,x
          clc
          adc COLOR_DIR,y
          sta PAL_COLORS,x
          
          ;swizzle
          asl
          adc #$80
          rol
          asl
          adc #$80
          rol
.ColorIndex = * + 2
          sta VIC4.PALRED + TITLE_FADE_COLOR_INDEX
          sta PARAM1
          
          inc PAL_POS
          lda PAL_POS
          cmp #63
          bne +
          
          lda #0
          sta PAL_POS
          
          inc PAL_INDEX
          lda PAL_INDEX
          cmp #6
          bne +
          lda #0
          sta PAL_INDEX
          
          
+          

          lda CIA1.DATA_PORT_B
          sta JOY_VALUE
          
          and #$10
          lbne TitleLoop

          ;release button
          jsr ReleaseButton
          
          ;jmp HandleWellDone
          
          ;40 col mode
          lda #$80    
          trb VIC3.VICDIS

          ;Turn on FCM mode and 16bit per char number
          lda #$07
          sta VIC4.VIC4DIS
          
          lda #80
          sta VIC4.CHARSTEP_LO
          lda #0
          sta VIC4.CHARSTEP_HI
        
          
          
          jmp StartGame

HEX_CHAR2
          !byte 48,49,50,51,52,53,54,55,56,57,1,2,3,4,5,6
          
;hi byte offset to indicate R, G or B (being 0,1 or 2)          
COLOR_INDEX
          !byte 0,1,2,0,1,2
          
COLOR_DIR
          !byte 4,4,4,$fc,$fc,$fc
          
PAL_COLORS
          !byte 0,0,0
          
!zone DisplayText
DisplayText
          ldy #0
-          
          lda (ZEROPAGE_POINTER_1),y
          beq .Done
          
          sta (ZEROPAGE_POINTER_2),y
          iny
          bra -
          
          
.Done
          rts
          
          
          
!zone ReleaseButton
ReleaseButton
-          
          jsr WaitFrame
          lda CIA1.DATA_PORT_B
          sta JOY_VALUE
          and #$10
          beq -
          
          rts
          
          
          
!zone PaletteFadeIn
.PALETTE_POS
          !byte 0
.PALETTE_R
          !byte 127
.PALETTE_G
          !byte 255
.PALETTE_B
          !byte 255
          
PaletteFadeIn
          lda #0
          sta .PALETTE_POS
          
--
          ;copy palette data (16 entries)
          ldy #0
          ldx #$00
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
          
          
          jsr WaitFrame
          inc .PALETTE_POS
          lda .PALETTE_POS
          cmp #16
          bne --
          
          rts
  
          
PAL_POS
          !byte 0
          
PAL_INDEX
          !byte 0
          
TEXT_WRITTEN_BY
          !scr "written by endurion  2021",0
          
TEXT_FOR_COMPO
          !scr "for shallans mega65 compo",0          
          
TEXT_INSTRUCTIONS_1
          !scr "destroy all colored blocks. you can only destroy them if your ball has the",0          
TEXT_INSTRUCTIONS_2
          !scr "same color. there are color changers, direction changers, keys and locks.",0
TEXT_INSTRUCTIONS_3
          !scr "press fire to speed up. f1 to self destruct.",0          
          
TEXT_PRESS_FIRE
          !scr "press fire to start playing",0                    
          
PALETTE_DEFAULT_16_COLORS_R
          !hex 00ff88aacc0000eedd66ff3377aa00bb
          
PALETTE_DEFAULT_16_COLORS_G
          !hex 00ff00ff44cc00ee8844773377ff88bb
          
PALETTE_DEFAULT_16_COLORS_B
          !hex 00ff00eecc55aa77550077337766ffbb
          
