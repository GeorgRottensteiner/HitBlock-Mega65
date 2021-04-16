TITLE_SPRITE_X_POS = 70
  
!zone HandleTitle
HandleTitle
          lda #15
          ldx #$10
          jsr ColorClear32bitAddr
          
          lda #0
          sta VIC4.SPR16EN
          sta VIC4.SPRX64EN
          
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
          inc 
          sta SPRITE_POINTER_BASE + 1
          inc 
          sta SPRITE_POINTER_BASE + 2
          inc 
          sta SPRITE_POINTER_BASE + 3
          inc 
          sta SPRITE_POINTER_BASE + 4
          inc 
          sta SPRITE_POINTER_BASE + 5
          inc 
          sta SPRITE_POINTER_BASE + 6
          inc 
          sta SPRITE_POINTER_BASE + 7
          
          lda #15
          sta VIC.SPRITE_MULTICOLOR_1
          lda #1
          sta VIC.SPRITE_MULTICOLOR_2
          
          lda #13
          sta VIC.SPRITE_COLOR
          sta VIC.SPRITE_COLOR + 1
          sta VIC.SPRITE_COLOR + 2
          sta VIC.SPRITE_COLOR + 3
          sta VIC.SPRITE_COLOR + 4
          sta VIC.SPRITE_COLOR + 5
          sta VIC.SPRITE_COLOR + 6
          sta VIC.SPRITE_COLOR + 7

          lda #$ff
          sta VIC.SPRITE_MULTICOLOR
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
          lda #7
          sta VIC.BACKGROUND_COLOR

          lda #61
          jsr WaitForLine
          lda #0
          sta VIC.BACKGROUND_COLOR
          
          jsr WaitFrame

          lda CIA1.DATA_PORT_B
          sta JOY_VALUE
          
          and #$10
          bne TitleLoop

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
  
          
          
TEXT_WRITTEN_BY
          !scr "written by endurion  2021",0
          
TEXT_FOR_COMPO
          !scr "for shallans mega65 compo",0          
          
TEXT_PRESS_FIRE
          !scr "press fire to start playing",0                    