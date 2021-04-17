TILE_EMPTY            = 0
TILE_EMPTY_SHADOW_1   = 1
TILE_EMPTY_SHADOW_2   = 2
TILE_EMPTY_SHADOW_3   = 3
TILE_EMPTY_SHADOW_4   = 4
TILE_EMPTY_SHADOW_5   = 5
TILE_EMPTY_SHADOW_6   = 6
TILE_EMPTY_SHADOW_7   = 7

TILE_BLUE             = 8
TILE_RED              = 9
TILE_GREEN            = 10
TILE_YELLOW           = 11
TILE_VIOLET           = 12
TILE_BROWN            = 13
TILE_STEEL            = 14

TILE_COLOR_BLUE       = 15
TILE_COLOR_RED        = 16
TILE_COLOR_GREEN      = 17
TILE_COLOR_YELLOW     = 18
TILE_COLOR_VIOLET     = 19
TILE_COLOR_BROWN      = 20

TILE_SKULL            = 21

TILE_DISK_BLUE        = 22
TILE_DISK_RED         = 23
TILE_DISK_GREEN       = 24
TILE_DISK_YELLOW      = 25
TILE_DISK_VIOLET      = 26
TILE_DISK_BROWN       = 27

TILE_DIR_TOGGLE       = 28

TILE_KEY_BLUE         = 29
TILE_KEY_RED          = 30
TILE_KEY_GREEN        = 31
TILE_KEY_YELLOW       = 32
TILE_KEY_VIOLET       = 33
TILE_KEY_BROWN        = 34

TILE_LOCK_BLUE        = 35
TILE_LOCK_RED         = 36
TILE_LOCK_GREEN       = 37
TILE_LOCK_YELLOW      = 38
TILE_LOCK_VIOLET      = 39
TILE_LOCK_BROWN       = 40

COLOR_BLUE            = 0
COLOR_RED             = 1
COLOR_GREEN           = 2
COLOR_YELLOW          = 3
COLOR_VIOLET          = 4
COLOR_BROWN           = 5

DIR_N                 = 0
DIR_S                 = 1
DIR_W                 = 2
DIR_E                 = 3

SCORE_OFFSET_X        = 1
TIMER_OFFSET_X        = 18
LIVES_OFFSET_X        = 36

!zone StartGame
StartGame
          ;lda #$01
          ;ldx #$10    ;Pages to clear
          ;jsr ColorClear32bitAddr
          
          lda #$00
          ldx #$10;Pages to clear
          jsr ScreenClear32bitAddr
          
          ;prepare score bar
          ;empty out score bar
          lda #28
          ldx #0
-          
          sta SCREEN_CHAR + 24 * 80,x
          
          inx
          inx
          cpx #80
          bne -
          
          
          ;SC
          lda #60
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X )
          
          ;LI
          lda #63
          sta SCREEN_CHAR + 2 * ( 24 * 40 + LIVES_OFFSET_X )

          lda #64 + 2 * 3
          sta SCREEN_CHAR + 2 * ( 24 * 40 + LIVES_OFFSET_X + 1 )
          inc
          sta SCREEN_CHAR + 2 * ( 24 * 40 + LIVES_OFFSET_X + 2 )
          
          ;score
          lda #64
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 1 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 3 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 5 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 7 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 9 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 11 )
          
          lda #65
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 2 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 4 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 6 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 8 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 10 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 12 )
 
          ;clock
          lda #31
          sta SCREEN_CHAR + 2 * ( 24 * 40 + 17 )
          
          lda #0
          lda #9
          sta LEVEL_NR
          
          lda #3
          sta PLAYER_LIVES
          
RestartLevel          
NextLevel          
          lda LEVEL_NR
          cmp #10
          bne +
          
          jmp HandleWellDone
          
+          

          ldx #0
          txa
-          
          sta SPRITE_ACTIVE,x
          inx
          cpx #8
          bne -
    
          jsr BuildScreen
          
          ;clock to 500
          lda #64 + 5 * 2
          sta SCREEN_CHAR + 2 * ( 24 * 40 + 18 )
          lda #64 + 0 * 2
          sta SCREEN_CHAR + 2 * ( 24 * 40 + 20 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + 22 )
          lda #65 + 5 * 2
          sta SCREEN_CHAR + 2 * ( 24 * 40 + 19 )
          lda #65 + 0 * 2
          sta SCREEN_CHAR + 2 * ( 24 * 40 + 21 )
          sta SCREEN_CHAR + 2 * ( 24 * 40 + 23 )
          
          lda #0
          sta VIC.SPRITE_ENABLE
          sta VIC4.SPR16EN
          sta VIC4.SPRX64EN
          sta PLAYER_KILLED
          sta PLAYER_AFFECTED
          sta TIMER_DELAY
          sta LEVEL_START_DELAY
          
          lda PLAYER_START_X
          sta PARAM1
          lda PLAYER_START_Y
          sta PARAM2
          lda #TYPE_PLAYER
          sta PARAM3
          jsr SpawnObject
          
          ;set player start color
          lda PLAYER_COLOR
          asl
          asl
          clc
          adc #SPRITE_BASE
          sta SPRITE_POINTER_BASE
          
          ;start moving down
          lda #2
          sta SPRITE_DIRECTION_Y
          lda #0
          sta SPRITE_DIRECTION
          lda #0
          sta PLAYER_DIR
          
          lda #0
          sta PLAYER_KEYS
          sta PLAYER_KEYS + 1
          sta PLAYER_KEYS + 2
          sta PLAYER_KEYS + 3
          sta PLAYER_KEYS + 4
          sta PLAYER_KEYS + 5
          
          ;lda #0
          ;sta SPRITE_DIRECTION_Y
          ;lda #2
          ;sta SPRITE_DIRECTION
          ;lda #1
          ;sta PLAYER_DIR
 
          ;wait a bit
-          
          jsr WaitFrame
          
          inc LEVEL_START_DELAY
          lda LEVEL_START_DELAY
          cmp #64
          bne -
  
  
!zone GameLoop
GameLoop
          jsr WaitFrame
          
          jsr SFXUpdate
          
          lda CIA1.DATA_PORT_B
          sta JOY_VALUE
          
          lda SPRITE_ACTIVE
          bne .PlayerIsAliveOrExploding
          
          lda JOY_VALUE
          and #$10
          bne .NotFirePressed
          
          ;wait for fire to be released
.FirePressed          
          jsr WaitFrame
          lda $dc01
          and #$10
          beq .FirePressed
          
          lda PLAYER_LIVES
          lbne RestartLevel
          
          jmp HandleTitle

.PlayerIsAliveOrExploding          

;bonus
          lda SCREEN_CHAR + 2 * ( 24 * 40 + TIMER_OFFSET_X )
          cmp #64
          bne .TimerTick
          
          lda SCREEN_CHAR + 2 * ( 24 * 40 + TIMER_OFFSET_X + 2 )
          cmp #64
          bne .TimerTick
          
          lda SCREEN_CHAR + 2 * ( 24 * 40 + TIMER_OFFSET_X + 4 )
          cmp #64
          bne .TimerTick
          
          jmp .NoTimer
          
.TimerTick          
          inc TIMER_DELAY
          lda TIMER_DELAY
          and #$07
          bne +

          ldx #TIMER_OFFSET_X + 4
          jsr DecTime
+
.NoTimer  
          
          
.NotFirePressed          

          lda Mega65.PRESSED_KEY
          beq +
          
          ;clear key
          sta Mega65.PRESSED_KEY
          
          cmp #$f1
          bne +
          
          lda SPRITE_ACTIVE
          cmp #TYPE_PLAYER
          bne +
          
          jsr HitTile.KillPlayer      
          jmp GameLoop
+          
          cmp #49
          bne +
 
          inc LEVEL_NR
          jmp NextLevel
+          


          lda NUM_BLOCKS
          bne .GameIsOn
          
          jmp LevelDoneAnimation
          
.GameIsOn     
          
          ldx #0
          jsr ObjectControl
          
        
          jmp GameLoop



!zone LevelDoneAnimation
.DONE_STATE
          !byte 0
          
LevelDoneAnimation
          lda #0
          sta .DONE_STATE

.NextFrame          
          jsr WaitFrame
          
          ldx #1
          jsr ObjectControl
          
          inc .DONE_STATE
          lda .DONE_STATE
          and #$03
          bne .NextFrame
          
          lda .DONE_STATE
          lsr
          lsr
          tay
          cpy #7 
          beq .AnimDone
          
          lda FLASH_TABLE,y
          sta PARAM1
          
          ;replace char colors
          ldx #0
-          
          ldy $4000,x
          beq .NextByte
          
          sta $4000,x
          
.NextByte

          ldy $4800,x
          beq .NextByte2
          
          sta $4800,x
          
.NextByte2

          inx
          cpx #128
          bne -
          
          jmp .NextFrame
          
          
.AnimDone          
          ;and wait
          lda #0
          sta .DONE_STATE
-          
          jsr WaitFrame
          
          inc .DONE_STATE
          lda .DONE_STATE
          cmp #64
          bne -
          
.BonusTick
          jsr WaitFrame
          ;bonus
          lda SCREEN_CHAR + 2 * ( 24 * 40 + TIMER_OFFSET_X )
          cmp #64
          bne .TimerTick
          
          lda SCREEN_CHAR + 2 * ( 24 * 40 + TIMER_OFFSET_X + 2 )
          cmp #64
          bne .TimerTick
          
          lda SCREEN_CHAR + 2 * ( 24 * 40 + TIMER_OFFSET_X + 4 )
          cmp #64
          bne .TimerTick
          
          inc LEVEL_NR
          jmp NextLevel
          
.TimerTick
          ldx #TIMER_OFFSET_X + 4
          jsr DecTime
          
          inc TIMER_DELAY
          lda TIMER_DELAY
          and #$07
          bne +
          
          ldy #SFX_BONUS_BLIP
          jsr PlaySoundEffectInChannel0
+          
          ;+1
          lda #1
          ldx #5 * 4
          jsr IncScore
          
          jmp .BonusTick
          
          
  
          
FLASH_TABLE
          !byte 10,12,15,12,10,11,11,11
          
!zone HitTile
;PARAM1,PARAM2 = x,y of tile
;                can be off screen!!  
HitTile
          ;get tile index
          ldy PARAM2
          sty PARAM4
          lda PARAM1
          sta PARAM3
          clc
          adc TILE_OFFSET,y
          tay
          sty PARAM7
          lda LEVEL_DATA,y
          
          ;direction changer?
          cmp #TILE_DIR_TOGGLE
          bne +
 
          lda PLAYER_DIR
          eor #$01
          sta PLAYER_DIR

          lda #1
          sta PLAYER_AFFECTED
          
          ldy #SFX_COLOR_CHANGE
          jsr PlaySoundEffectInChannel0
          
          ;is target dir set to move?
          ldy MOVE_DIR
          
          lda PLAYER_DIR
          beq .CheckH
          
          ;turned to horizontal movement
          lda DIR_TOGGLE_TABLE_H_H,y
          sta SPRITE_DIRECTION
          lda DIR_TOGGLE_TABLE_H_V,y
          sta SPRITE_DIRECTION_Y
          rts
          
          
.CheckH          
          lda DIR_TOGGLE_TABLE_V_H,y
          sta SPRITE_DIRECTION
          lda DIR_TOGGLE_TABLE_V_V,y
          sta SPRITE_DIRECTION_Y
          rts
          
+          
          
          ;skull?
          cmp #TILE_SKULL
          bne +
          
.KillPlayer
          ldy #SFX_BALL_KILLED
          jsr PlaySoundEffectInChannel0

          ldx #0
          lda #TYPE_EXPLOSION
          sta PARAM3
          jsr CreateObjectInSlot
          
          ldy PLAYER_COLOR
          lda SMOKE_COLOR_TABLE,y
          sta VIC.SPRITE_COLOR,x
          
          lda #8
          sta PARAM1
-          
          jsr ObjectMoveLeft
          jsr ObjectMoveUp
          
          dec PARAM1
          bne -
          
          lda #1
          sta PLAYER_KILLED
          sta PLAYER_AFFECTED
          
          dec SCREEN_CHAR + 2 * ( 24 * 40 + LIVES_OFFSET_X + 1 )
          dec SCREEN_CHAR + 2 * ( 24 * 40 + LIVES_OFFSET_X + 1 )
          dec SCREEN_CHAR + 2 * ( 24 * 40 + LIVES_OFFSET_X + 2 )
          dec SCREEN_CHAR + 2 * ( 24 * 40 + LIVES_OFFSET_X + 2 )
          dec PLAYER_LIVES
          
          rts
          
+          
          ;hit color block?
          cmp #TILE_BLUE
          bcs +
          jmp .NoColorBlock
+          
          cmp #TILE_BROWN + 1
          bcc +
          jmp .NoColorBlock
+          
          ;is the color matching?
          sec
          sbc #TILE_BLUE
          cmp PLAYER_COLOR
          lbne .WrongColorBlock
          
          ;fix shadow quad 2x2
          ldy PARAM7
          lda #TILE_EMPTY
          jsr SetTileAndUpdateShadows
          
          ;spawn smoke
          lda PARAM3
          asl
          sta PARAM1
          inc PARAM1
          lda PARAM4
          asl
          sta PARAM2
          lda #TYPE_SMOKE
          sta PARAM3
          jsr SpawnObject
          
          ldy PLAYER_COLOR
          lda SMOKE_COLOR_TABLE,y
          sta VIC.SPRITE_COLOR,x
          
          ;add to score +10
          lda #1
          ldx #4 * 4
          jsr IncScore
          
          dec NUM_BLOCKS
          
          ldy #SFX_BRICK_BREAK
          jsr PlaySoundEffectInChannel0

          ;restore player index
          ldx CURRENT_INDEX
          rts
          
          
.NoColorBlock          
          ;hit color changer block?
          cmp #TILE_COLOR_BLUE
          bcc .NoColorChangerBlock
          
          cmp #TILE_COLOR_BROWN + 1
          bcs .NoColorChangerBlock          
          
          sec
          sbc #TILE_COLOR_BLUE
          sta PLAYER_COLOR
          asl
          asl
          clc
          adc #SPRITE_BASE
          sta SPRITE_POINTER_BASE
          
          ldy #SFX_COLOR_CHANGE
          jsr PlaySoundEffectInChannel0
          
          jmp .NoRemove
          
.NoColorChangerBlock          
          cmp #TILE_DISK_BLUE
          bcc .NoDiskBlock
          
          cmp #TILE_DISK_BROWN + 1
          bcs .NoDiskBlock          
          
          ;hit a disk          
          sec
          sbc #TILE_DISK_BLUE
          cmp PLAYER_COLOR
          lbne .CantPushDisk
          
          sta .TEMP_COLOR
          
          ;is block behind disk free?
          lda PARAM7
          ldy HIT_DIR
          clc
          adc HIT_OFFSET_BY_DIR,y
          tay
          lda LEVEL_DATA,y
          jsr IsTileBlocking
          lbne .DiskIsBlocked
          
          ;push disk!
          ldy PARAM7
          lda #TILE_EMPTY
          jsr SetTileAndUpdateShadows
          
          ;spawn smoke
          lda PARAM3
          asl
          sta PARAM1
          inc PARAM1
          lda PARAM4
          asl
          sta PARAM2
          lda #TYPE_DISK
          sta PARAM3
          jsr SpawnObject
          
          lda HIT_DIR
          sta SPRITE_ANIM_POS,x
          lda #16
          sta SPRITE_STATE,x
          lda PARAM7
          ldy HIT_DIR
          clc
          adc HIT_OFFSET_BY_DIR,y
          sta SPRITE_ANIM_DELAY,x
          
.TEMP_COLOR = * + 1          
          lda #0
          asl
          asl
          clc
          adc #SPRITE_DISK
          sta SPRITE_POINTER_BASE,x
          
          ldy #SFX_DISK_PUSH
          jsr PlaySoundEffectInChannel0
          
          ;restore player index
          ldx CURRENT_INDEX
          rts
          
          
.NoDiskBlock
          cmp #TILE_KEY_BLUE
          bcc .NoKeyBlock
          
          cmp #TILE_KEY_BROWN + 1
          bcs .NoKeyBlock          
          
          ;hit a key          
          sec
          sbc #TILE_KEY_BLUE
          cmp PLAYER_COLOR
          bne .NoKeyBlock
          
          sta .TEMP_COLOR
          
          tay
          lda #1
          sta PLAYER_KEYS,y
          
          ;collect block
          ldy PARAM7
          lda #TILE_EMPTY
          jsr SetTileAndUpdateShadows
          
          ldy #SFX_COLOR_CHANGE
          jsr PlaySoundEffectInChannel0          
          
          ;restore player index
          ldx CURRENT_INDEX
          rts
          
          
.NoKeyBlock
          cmp #TILE_LOCK_BLUE
          lbcc .NoLockBlock
          
          cmp #TILE_LOCK_BROWN + 1
          lbcs .NoLockBlock          
          
          ;hit a lock          
          sec
          sbc #TILE_LOCK_BLUE
          cmp PLAYER_COLOR
          lbne .NoLockBlock
          
          ;has key?
          tay
          lda PLAYER_KEYS,y
          lbeq .NoLockBlock
          
          ;yes!
          ldy PARAM7
          lda #TILE_EMPTY
          jsr SetTileAndUpdateShadows
     
          ldy #SFX_BRICK_BREAK
          jsr PlaySoundEffectInChannel0          
          
          ;restore player index
          ldx CURRENT_INDEX
          rts
          
.DiskIsBlocked          
.CantPushDisk          
.NoLockBlock
.WrongColorBlock
          ldy #SFX_BALL_BOUNCE
          lda #1
          jsr PlaySoundEffect
.NoRemove          
          ldx CURRENT_INDEX
          rts
          
          
          
DIR_TOGGLE_TABLE_H_H
          !byte 1   ;n > e
          !byte 1   ;s > e
          !byte 1   ;w > e
          !byte 2   ;e > w
          
DIR_TOGGLE_TABLE_H_V
          !byte 2   ;n > s
          !byte 1   ;s > n
          !byte 2   ;w > s
          !byte 2   ;e > s
          
DIR_TOGGLE_TABLE_V_H
          !byte 0   ;n > e
          !byte 0   ;s > e
          !byte 1   ;w > e
          !byte 2   ;e > w
          
DIR_TOGGLE_TABLE_V_V
          !byte 2   ;n > s
          !byte 1   ;s > n
          !byte 2   ;w > s
          !byte 2   ;e > s
          
HIT_OFFSET_BY_DIR
          !byte 256 - 20
          !byte 20
          !byte 256 - 1
          !byte 1
          
       
SMOKE_COLOR_TABLE
          !byte 3
          !byte 8
          !byte 4
          !byte 13
          !byte 11
          !byte 9
          
          
        
!zone SetTileAndUpdateShadows
;a = tile to set
;y = offset in tiles  
;PARAM1 = tile x
;PARAM2 = tile y
SetTileAndUpdateShadows
          sta LEVEL_DATA,y
          jsr FixTileShadow
          lda LEVEL_DATA,y
          jsr DrawTile
          
          ;tile to right
          iny
          inc PARAM1
          
          lda LEVEL_DATA,y
          jsr IsTileBlocking
          bne .Skip1
          
          jsr FixTileShadow
          
          lda LEVEL_DATA,y
          jsr DrawTile
          
.Skip1          
          tya
          clc
          adc #19
          tay
          inc PARAM2
          dec PARAM1
          lda LEVEL_DATA,y
          jsr IsTileBlocking
          bne .Skip2
          
          jsr FixTileShadow
          
          lda LEVEL_DATA,y
          jsr DrawTile
          
.Skip2          
          ;tile to right
          iny
          inc PARAM1
          
          lda LEVEL_DATA,y
          jsr IsTileBlocking
          bne .Skip3
          
          jsr FixTileShadow
          
          lda LEVEL_DATA,y
          jsr DrawTile
         
.Skip3
          rts
  
          
          
!zone IncScore
;x = offset in chars  
IncScore  
          asl
          clc
          adc SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 1 ),x
          cmp #64 + 20
          bcc .Done
          
          sec
          sbc #20
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 1 ),x
          inc
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 2 ),x
          
          dex
          dex
          dex
          dex
          lda #1
          jmp IncScore
          
          
          
          
.Done
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 1 ),x
          ;second half of digit
          inc
          sta SCREEN_CHAR + 2 * ( 24 * 40 + SCORE_OFFSET_X + 2 ),x
          rts

          
          
!zone DecTime
;x = offset in chars  
DecTime  
          txa
          asl
          tax
.DecTime          
          lda SCREEN_CHAR + 2 * 24 * 40,x
          cmp #64
          beq .Overflow
          
          dec SCREEN_CHAR + 2 * 24 * 40,x
          dec SCREEN_CHAR + 2 * 24 * 40,x
          dec SCREEN_CHAR + 2 * 24 * 40 + 2,x
          dec SCREEN_CHAR + 2 * 24 * 40 + 2,x
.Done          
          rts
          
.Overflow
          lda #64 + 2 * 9
          sta SCREEN_CHAR + 2 * 24 * 40,x
          lda #64 + 2 * 9 + 1
          sta SCREEN_CHAR + 2 * 24 * 40 + 2,x
          
          cpx #TIMER_OFFSET_X
          beq .Done
          
          dex
          dex
          dex
          dex
          jmp .DecTime
          
          
!zone DrawTile
;PARAM1, PARAM2 = tile x,y
;A = tile index  
DrawTile  
          phy
          ;ldx #0
;          lda PARAM1
;          jsr DisplayHex
;
;          ldx #3
;          lda PARAM2
;          jsr DisplayHex
;
;          lda #TILE_RED
          tax
          
          lda PARAM1
          sta PARAM8
          
          ;*2 = char index
          asl PARAM8    
          ;*2 = 16 bit char index!
          asl PARAM8
          
          lda PARAM2
          asl
          tay
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_3
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_3 + 1
          
          lda SCREENS_TILE_CHARS_0_0,x
          ldy PARAM8
          sta (ZEROPAGE_POINTER_3),y
          iny
          iny
          lda SCREENS_TILE_CHARS_1_0,x
          sta (ZEROPAGE_POINTER_3),y

          tya
          clc
          adc #39 * 2
          tay
          lda SCREENS_TILE_CHARS_0_1,x
          sta (ZEROPAGE_POINTER_3),y

          iny
          iny
          lda SCREENS_TILE_CHARS_1_1,x
          sta (ZEROPAGE_POINTER_3),y
          
          ply
          rts
          
          
!zone WaitFrame
WaitFrame  
          lda #$f0
WaitForLine          
-          
          cmp VIC.RASTER_POS
          bne -

-          
          cmp VIC.RASTER_POS
          beq -

          rts          

          

PLAYER_START_X
          !byte 0
          
PLAYER_START_Y
          !byte 0          
          
PLAYER_COLOR
          !byte COLOR_BLUE
          
JOY_VALUE
          !byte 0
          
NUM_BLOCKS
          !byte 0
          
HIT_DIR
          !byte 0
        
PLAYER_KILLED
          !byte 0
          
PLAYER_AFFECTED
          !byte 0
          
PLAYER_LIVES
          !byte 0
          
PLAYER_KEYS
          !fill 6
          
TIMER_DELAY
          !byte 0
          
LEVEL_START_DELAY
          !byte 0
          
;0 = up/down, 1 = left/right          
PLAYER_DIR
          !byte 0
          
SCREEN_LINE_OFFSET_TABLE_LO
!for ROWX = 0 to 24
          !byte <( SCREEN_CHAR + ROWX * 80 )
!end  
        
SCREEN_LINE_OFFSET_TABLE_HI
!for ROWX = 0 TO 24
          !byte >( SCREEN_CHAR + ROWX * 80 )
!end          
        
        
TILE_OFFSET
!for ROWX = 0 to 12
          !byte ROWX * 20
!end  
        
        
        