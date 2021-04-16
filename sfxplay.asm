FX_SLIDE              = 0
FX_NONE               = 1
FX_STEP               = 2
FX_SLIDE_PING_PONG    = 3

FX_WAVE_TRIANGLE      = 0
FX_WAVE_SAWTOOTH      = 1
FX_WAVE_PULSE         = 2
FX_WAVE_NOISE         = 3


ZP_ADDRESS            = $57

NUM_CHANNELS          = 3

!zone SFXPlay
;a = channel (0 to 2 )
;x = sfx address lo
;y = sfx address hi  
;expect 10 bytes, (FFFFFFWW) = Effect + Waveform
;                FX lo/hi, Pulse Lo, Pulse Hi, AD, SR, Effect Delta, Effect Delay, Effect Step
SFXPlay
          stx ZP_ADDRESS
          sty ZP_ADDRESS + 1
          
          lda #0
          sta .CURRENT_CHANNEL
          tax
          lda CHANNEL_OFFSET,x
          sta .CURRENT_VOICE
          
          ldy #0
          lda (ZP_ADDRESS),y
          lsr
          lsr
          sta EFFECT_TYPE_SETUP,x
          sta EFFECT_TYPE,x
          
          
          lda (ZP_ADDRESS),y
          and #$03
          tay
          ;sty WAVE_FORM_SETUP,x
          
          ldx .CURRENT_VOICE
          lda WAVE_FORM_TABLE,y
          sta SID_MIRROR + 4,x

          lda #0
          sta SID.FREQUENCY_LO_1 + 4,x
          
          ;copy SID registers 0 to 3
          ldy #1
-          
          lda (ZP_ADDRESS),y
          sta SID_MIRROR,x
          sta SID_MIRROR_SETUP,x
          sta SID.FREQUENCY_LO_1,x

          iny
          inx
          cpy #4
          bne -

          ldx .CURRENT_VOICE
          lda SID_MIRROR + 4,x
          sta SID_MIRROR_SETUP + 4,x
          sta SID.FREQUENCY_LO_1 + 4,x
          
          ldx .CURRENT_CHANNEL
          ldy #7
          lda (ZP_ADDRESS),y
          sta EFFECT_DELTA,x
          sta EFFECT_DELTA_SETUP,x

          iny          
          lda (ZP_ADDRESS),y
          sta EFFECT_DELAY,x
          sta EFFECT_DELAY_SETUP,x
          
          iny          
          lda (ZP_ADDRESS),y
          sta EFFECT_VALUE,x
          sta EFFECT_VALUE_SETUP,x

          rts
          
.CURRENT_CHANNEL
          !byte 0
.CURRENT_VOICE
          !byte 0
          
          
          
!zone SFXUpdate
SFXUpdate
          ldy #0
          sty SFXPlay.CURRENT_CHANNEL
.NextChannel
          ldx EFFECT_TYPE,y
          lda FX_TABLE_LO,x
          sta .JumpPos
          lda FX_TABLE_HI,x
          sta .JumpPos + 1
          
          ldx SFXPlay.CURRENT_CHANNEL
          ldy CHANNEL_OFFSET,x
.JumpPos = * + 1          
          jsr $ffff
          
          inc SFXPlay.CURRENT_CHANNEL
          ldy SFXPlay.CURRENT_CHANNEL
          cpy #3
          bne .NextChannel
          
          rts
          
FX_TABLE_LO
          !byte <FXSlide
          !byte <FXNone
          !byte <FXStep
          !byte <FXPingPong

FX_TABLE_HI
          !byte >FXSlide
          !byte >FXNone
          !byte >FXStep
          !byte >FXPingPong
          
          
!zone FXSlide
FXSlide
          dec EFFECT_DELAY,x
          beq FXOff
          
          lda EFFECT_DELTA,x
          bpl .Up
          
          lda SID_MIRROR + 1,y
          clc
          adc EFFECT_DELTA,x
          bcc .Overflow
          jmp +

          
.Up          
          lda SID_MIRROR + 1,y
          clc
          adc EFFECT_DELTA,x
          bcs .Overflow
+          
          sta SID_MIRROR + 1,y
          sta SID.FREQUENCY_LO_1 + 1,y
          rts
          
.Overflow

FXOff
          lda #0
          sta EFFECT_DELTA,x
          sta SID.CONTROL_WAVE_FORM_1,y
          rts

          
          
!zone FXNone
FXNone
          dec EFFECT_DELAY,x
          beq FXOff
          rts


          
!zone FXStep
FXStep
          dec EFFECT_DELAY,x
          bne .NoStep
          
          ;step, switch to slide
          lda SID_MIRROR + 1,y
          clc
          adc EFFECT_VALUE,x
          sta SID_MIRROR + 1,y
          sta SID.FREQUENCY_LO_1 + 1,y
          
          lda #0
          sta EFFECT_DELTA,x
          lda EFFECT_DELAY_SETUP,x
          sta EFFECT_DELAY,x
          
          lda #FX_SLIDE
          sta EFFECT_TYPE,x
          
.NoStep
          rts

          
          
!zone FXPingPong
FXPingPong
          dec EFFECT_VALUE,x
          bne .GoSlide
          
          lda EFFECT_VALUE_SETUP,x
          sta EFFECT_VALUE,x
          
          lda EFFECT_DELTA,x
          eor #$ff
          clc
          adc #1
          sta EFFECT_DELTA,x
          
.GoSlide          
          jmp FXSlide
          
          
          
WAVE_FORM_TABLE
          !byte 17,33,65,129
          
CHANNEL_OFFSET
          !byte 0,7,14

SID_MIRROR
          !fill 7 * NUM_CHANNELS
SID_MIRROR_SETUP
          !fill 7 * NUM_CHANNELS
          
;WAVE_FORM_SETUP
;          !fill NUM_CHANNELS
          
EFFECT_TYPE
          !fill NUM_CHANNELS
EFFECT_TYPE_SETUP
          !fill NUM_CHANNELS
          
EFFECT_DELTA          
          !fill NUM_CHANNELS
EFFECT_DELTA_SETUP
          !fill NUM_CHANNELS
          
EFFECT_DELAY
          !fill NUM_CHANNELS
EFFECT_DELAY_SETUP
          !fill NUM_CHANNELS
EFFECT_VALUE
          !fill NUM_CHANNELS
EFFECT_VALUE_SETUP
          !fill NUM_CHANNELS
          
          