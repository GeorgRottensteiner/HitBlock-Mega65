!zone HandleWellDone
HandleWellDone
          jsr WaitFrame
          
          lda #0
          sta VIC.BACKGROUND_COLOR
          sta VIC.SPRITE_ENABLE
          
          ldx #0
          
-         
          lda WELLDONE_SCREEN + 0 * 250,x
          sta SCREEN_CHAR + 0 * 250,x
          lda WELLDONE_SCREEN + 1 * 250,x
          sta SCREEN_CHAR + 1 * 250,x
          lda WELLDONE_SCREEN + 2 * 250,x
          sta SCREEN_CHAR + 2 * 250,x
          lda WELLDONE_SCREEN + 3 * 250,x
          sta SCREEN_CHAR + 3 * 250,x
          
          lda WELLDONE_SCREEN + 1000 + 0 * 250,x
          sta SCREEN_COLOR + 0 * 250,x
          lda WELLDONE_SCREEN + 1000 + 1 * 250,x
          sta SCREEN_COLOR + 1 * 250,x
          lda WELLDONE_SCREEN + 1000 + 2 * 250,x
          sta SCREEN_COLOR + 2 * 250,x
          lda WELLDONE_SCREEN + 1000 + 3 * 250,x
          sta SCREEN_COLOR + 3 * 250,x
          
          inx
          cpx #250
          bne -
          
          jsr WaitFrame
          
          ;40 col mode
          lda #$80    
          trb VIC3.VICDIS

          ;Turn off FCM mode and 16bit per char number
          lda #$00
          sta VIC4.VIC4DIS
          
          lda #40
          sta VIC4.CHARSTEP_LO
          lda #0
          sta VIC4.CHARSTEP_HI
          
          
WellDoneLoop
          jsr WaitFrame

          lda CIA1.DATA_PORT_B
          sta JOY_VALUE
          
          and #$10
          bne WellDoneLoop

          ;release button
          jsr ReleaseButton
          
          jmp HandleTitle
          
          

WELLDONE_SCREEN
          !media "welldone.charscreen",CHARCOLOR