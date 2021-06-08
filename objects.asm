TYPE_PLAYER     = 1
TYPE_SMOKE      = 2
TYPE_DISK       = 3
TYPE_EXPLOSION  = 4

;sprite number constant
SPRITE_BASE             = SPRITE_DATA / 64  

SPRITE_BALL             = SPRITE_BASE + 0

SPRITE_SMOKE            = SPRITE_BASE + 3

SPRITE_DISK             = SPRITE_DATA_BLUE_DISK / 64

SPRITE_EXPLOSION        = SPRITE_BASE + 3 + 5 * 4

;offset from calculated char pos to true sprite pos
SPRITE_CENTER_OFFSET_X  = 8
SPRITE_CENTER_OFFSET_Y  = 1;11


;------------------------------------------------------------
;check joystick (player control)
;------------------------------------------------------------
!zone BHPlayer
BHPlayer
          lda #0
          sta PLAYER_AFFECTED
          
          lda JOY_VALUE
          and #$10
          bne .NotFire
          
          jsr .HandlePlayer
          
          ;did we die?
          lda PLAYER_KILLED
          beq +
.Killed          
          rts
+          

          
.NotFire          
.HandlePlayer          
          lda SPRITE_CHAR_POS_X_DELTA,x
          ora SPRITE_CHAR_POS_Y_DELTA,x
          bne .NoJoy

          lda PLAYER_DIR
          beq .HandleLRMove

          lda JOY_VALUE
          and #$01
          bne .NotUp
          
          lda #1
          sta SPRITE_DIRECTION_Y,x
          jmp .NoJoy

.NotUp
          lda JOY_VALUE
          and #$02
          bne .NotDown
          
          lda #2
          sta SPRITE_DIRECTION_Y,x
          jmp .NoJoy
          
.HandleLRMove          
          
          lda JOY_VALUE
          and #$04
          bne .NotLeft
          
          lda #2
          sta SPRITE_DIRECTION,x
          jmp .NoJoy

.NotLeft          
          lda JOY_VALUE
          and #$08
          bne .NotRight
          
          lda #1
          sta SPRITE_DIRECTION,x
          jmp .NoJoy

.NotDown          
.NotRight          
.NoJoy          

.YMovement
          ;y movement
          lda SPRITE_DIRECTION_Y,x
          beq .NoYMovement
          cmp #2
          beq .GoDown
          
          jsr ObjectMoveUpBlocking
          bne .Moved
      
          jmp .BlockedY
          
          
.GoDown 
          jsr ObjectMoveDownBlocking
          bne .Moved
      
.BlockedY
          lda PLAYER_AFFECTED
          bne .Killed

          ;blocked, toggle dir (1<>2)
          lda #3
          eor SPRITE_DIRECTION_Y,x
          sta SPRITE_DIRECTION_Y,x
          jmp .YMovement
          
.Moved          
          ;for vertical mode
          lda PLAYER_DIR
          beq +
          ;if we moved in y, reached full char pos again?
          lda SPRITE_DIRECTION_Y,x
          beq +
 
          lda SPRITE_CHAR_POS_Y_DELTA,x
          bne +
          
          ;yes!
          lda #0
          sta SPRITE_DIRECTION_Y,x
          
+          

.NoYMovement
          ;x movement?
          lda SPRITE_DIRECTION,x
          beq .MovedX
          
          cmp #1
          beq .GoRight
          
.GoLeft          
          jsr ObjectMoveLeftBlocking
          bne .MovedX
          
          ;blocked, auto-bounce right
          lda PLAYER_AFFECTED
          lbne .Killed
          
          lda #1
          sta SPRITE_DIRECTION,x
          jmp .GoRight
          
.GoRight          
          jsr ObjectMoveRightBlocking
          bne .MovedX
          
          ;blocked, auto-bounce left
          lda PLAYER_AFFECTED
          lbne .Killed

          lda #2
          sta SPRITE_DIRECTION,x
          jmp .GoLeft
          
.MovedX   
          ;for vertical mode
          lda PLAYER_DIR
          bne +
          ;if we moved in x, reached full char pos again?
          lda SPRITE_DIRECTION,x
          beq +
 
          lda SPRITE_CHAR_POS_X_DELTA,x
          bne +
          
          ;yes!
          lda #0
          sta SPRITE_DIRECTION,x
          
+          

          rts



!zone IsEnemyCollidingWithObject


.CalculateSimpleXPos
          ;Returns a with simple x pos (x halved + 128 if > 256)
          ;modifies y
          lda BIT_TABLE,x
          and SPRITE_POS_X_EXTEND
          beq .NoXBit

          lda SPRITE_POS_X,x
          lsr
          clc
          adc #128
          rts

.NoXBit
          lda SPRITE_POS_X,x
          lsr
          rts


;modifies X
;check y pos
;check object collision with other object (object CURRENT_INDEX vs CURRENT_SUB_INDEX)
;return a = 1 when colliding, a = 0 when not
;------------------------------------------------------------
;temp PARAM8 holds height to check in pixels
IsEnemyCollidingWithObject
          ldx CURRENT_SUB_INDEX
          ldy CURRENT_INDEX
          lda SPRITE_HEIGHT_CHARS,y
          asl
          asl
          asl
          sta PARAM8
          lda SPRITE_POS_Y,y
          sta PARAM2

          lda SPRITE_POS_Y,x
          sec
          sbc PARAM8         ;offset to bottom
          cmp PARAM2
          bcs .NotTouching

          ;sprite x is above sprite y
          clc
          adc PARAM8
          sta PARAM1

          lda SPRITE_HEIGHT_CHARS,x
          asl
          asl
          asl
          clc
          adc PARAM1
          cmp PARAM2
          bcc .NotTouching

          ;X = Index in enemy-table
          jsr .CalculateSimpleXPos
          sta PARAM1
          ldx CURRENT_INDEX
          jsr .CalculateSimpleXPos

          sec
          sbc #8    ;was 4
          ;position X-Anfang Player - 12 Pixel
          cmp PARAM1
          bcs .NotTouching
          adc #16   ;was 8
          cmp PARAM1
          bcc .NotTouching


          lda #1
          ;sta VIC.BORDER_COLOR
          rts

.NotTouching
          lda #0
          ;sta VIC.BORDER_COLOR
          rts






;------------------------------------------------------------
;fly left/right
;------------------------------------------------------------
!if 0 {
!zone BehaviourBird
BehaviourBird
          lda ENEMY_SPELL
          cmp #2
          beq .NoAnimUpdate

          jsr HandleBehaviour

          lda BEHAVIOUR_QUICKER
          beq .SingleAnimStep
          jsr .AnimStep
.SingleAnimStep
          jmp .AnimStep

.AnimStep
          inc SPRITE_ANIM_DELAY,x
          lda SPRITE_ANIM_DELAY,x
          cmp #4
          bne .NoAnimUpdate

          lda #0
          sta SPRITE_ANIM_DELAY,x

          inc SPRITE_ANIM_POS,x
          lda SPRITE_ANIM_POS,x
          and #$03
          sta SPRITE_ANIM_POS,x

          tay
          lda SPRITE_DIRECTION,x
          beq .FacingLeft
          lda #3
.FacingLeft
          clc
          adc #SPRITE_BIRD_FLY_R_1
          adc PING_PONG_ANIM_TABLE,y
          sta SPRITE_POINTER_BASE,x

.NoAnimUpdate
          rts
}



!zone FindEmptySpriteSlot
;Looks for an empty sprite slot, returns in X. Starts with Index X
;#1 in A when empty slot found, #0 when full
FindEmptySpriteSlot
.CheckSlot
          lda SPRITE_ACTIVE,x
          beq .FoundSlot

          inx
          cpx #8
          bne .CheckSlot

          lda #0
          rts

.FoundSlot
          lda #1
          rts


!zone RemoveObject
;Removed object from array
;X = index of object
RemoveObject
          ;remove from array
          lda #0
          sta SPRITE_ACTIVE,x

          ;disable sprite
          lda BIT_TABLE,x
          eor #$ff
          and VIC.SPRITE_ENABLE
          sta VIC.SPRITE_ENABLE

          lda BIT_TABLE,x
          eor #$ff
          and VIC.SPRITE_EXPAND_X
          sta VIC.SPRITE_EXPAND_X

          lda BIT_TABLE,x
          eor #$ff
          and VIC.SPRITE_EXPAND_Y
          sta VIC.SPRITE_EXPAND_Y

          rts





;------------------------------------------------------------
;move object left if not blocked
;x = object index
;returns: a=1 if moved, a=0 if blocked
;------------------------------------------------------------
!zone ObjectMoveLeftBlocking
ObjectMoveLeftBlocking
          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .CheckCanMoveLeft

.CanMoveLeft
          jsr ObjectMoveLeft
          lda #1
          rts

.CheckCanMoveLeft
          lda #DIR_W
          sta MOVE_DIR

          lda SPRITE_CHAR_POS_X,x
          beq .BlockedLeft
          ;lbeq HitTile.HitWallSound

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          bmi .BlockedLeft
          tay
          iny
          sty PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1

          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda SPRITE_HEIGHT_CHARS,x
          sta PARAM6

          lda SPRITE_CHAR_POS_Y_DELTA,x
          beq +
          inc PARAM6
+

--
          lda SPRITE_CHAR_POS_X,x
          dec
          asl
          tay

          lda (ZEROPAGE_POINTER_1),y
          jsr IsCharBlocking
          bne .BlockedLeft

          inc PARAM2
          dec PARAM6
          beq .CanMoveLeft

          lda ZEROPAGE_POINTER_1
          clc
          adc #80
          sta ZEROPAGE_POINTER_1
          bcc +
          inc ZEROPAGE_POINTER_1 + 1
+
          jmp --

.BlockedLeft
          tya
          lsr
          lsr
          sta PARAM1
          lsr PARAM2
          
          ;PARAM1,PARAM2 = screen tile pos
          lda #DIR_W
          sta HIT_DIR
          jsr HitTile
          
          lda #1
          sta BLOCKED_DIR
          
          lda #0
          rts
          
          

;------------------------------------------------------------
;move object left
;x = object index
;------------------------------------------------------------
!zone ObjectMoveLeft
ObjectMoveLeft
          lda SPRITE_NUM_PARTS,x
          sta PARAM11

-
          lda SPRITE_CHAR_POS_X_DELTA,x
          bne .NoCharStep

          lda #8
          sta SPRITE_CHAR_POS_X_DELTA,x
          dec SPRITE_CHAR_POS_X,x

.NoCharStep
          dec SPRITE_CHAR_POS_X_DELTA,x

          jsr MoveSpriteLeft

          inx
          dec PARAM11
          bne -

          lda SPRITE_MAIN_INDEX - 1,x
          tax
          rts




;------------------------------------------------------------
;move object right if not blocked
;x = object index
;return a=1 when moved, 0 when blocked
;------------------------------------------------------------
!zone ObjectMoveRightBlocking
ObjectMoveRightBlocking
          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .CheckCanMoveRight

.CanMoveRight
          jsr ObjectMoveRight
          lda #1
          rts

.CheckCanMoveRight
          lda #DIR_E
          sta MOVE_DIR

          ldy #40
          lda SPRITE_CHAR_POS_X,x
          cmp #39
          lbeq HitTile.HitWallSound

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          bmi .BlockedRight
          tay
          iny
          sty PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda SPRITE_HEIGHT_CHARS,x
          sta PARAM6

          lda SPRITE_CHAR_POS_Y_DELTA,x
          beq +
          inc PARAM6
+

--
          lda SPRITE_CHAR_POS_X,x
          clc
          adc SPRITE_WIDTH_CHARS,x
          asl
          tay

          lda (ZEROPAGE_POINTER_1),y
          jsr IsCharBlocking
          bne .BlockedRight

          inc PARAM2
          dec PARAM6
          beq .CanMoveRight

          lda ZEROPAGE_POINTER_1
          clc
          adc #80
          sta ZEROPAGE_POINTER_1
          bcc +
          inc ZEROPAGE_POINTER_1 + 1
+
          jmp --

.BlockedRight
          tya
          lsr
          lsr
          sta PARAM1
          lsr PARAM2
          
          ;PARAM1,PARAM2 = screen char pos
          lda #DIR_E
          sta HIT_DIR
          jsr HitTile
          
          lda #1
          sta BLOCKED_DIR

          lda #0
          rts
          

          
;------------------------------------------------------------
;move object right
;x = object index
;------------------------------------------------------------
!zone ObjectMoveRight
ObjectMoveRight
          lda SPRITE_NUM_PARTS,x
          sta PARAM11

-
          inc SPRITE_CHAR_POS_X_DELTA,x

          lda SPRITE_CHAR_POS_X_DELTA,x
          cmp #8
          bne .NoCharStep

          lda #0
          sta SPRITE_CHAR_POS_X_DELTA,x
          inc SPRITE_CHAR_POS_X,x

.NoCharStep
          jsr MoveSpriteRight
          inx
          dec PARAM11
          bne -

          lda SPRITE_MAIN_INDEX - 1,x
          tax
          rts


;------------------------------------------------------------
;move object up if not blocked
;x = object index
;return a=1 when moved, 0 when blocked
;------------------------------------------------------------
!zone ObjectMoveUpBlocking
ObjectMoveUpBlocking
          lda SPRITE_CHAR_POS_Y_DELTA,x
          beq .CheckCanMoveUp

.CanMoveUp
          jsr ObjectMoveUp
          lda #1
          rts

.CheckCanMoveUp
          lda #DIR_N
          sta MOVE_DIR

          ;at top of screen?

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          bmi .BlockedTop
          beq .BlockedTop

.CheckUp
          lda SPRITE_WIDTH_CHARS,x
          sta PARAM5

          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .NoSecondCharCheckNeeded
          inc PARAM5
.NoSecondCharCheckNeeded

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          tay
          sty PARAM2
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda SPRITE_CHAR_POS_X,x
          asl
          dec
          dec
          tay
-
          iny
          iny
          lda (ZEROPAGE_POINTER_1),y

          jsr IsCharBlocking
          bne .BlockedUp

          dec PARAM5
          bne -

          jmp .CanMoveUp

.BlockedTop
          cpx ACTIVE_PLAYER_INDEX
          bne .BlockedUp

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          bmi .CanMoveUp
          beq .CanMoveUp
          jmp .CheckUp

.BlockedUp
          tya
          lsr
          lsr
          sta PARAM1
          lsr PARAM2
          
          ;PARAM1,PARAM2 = screen char pos
          lda #DIR_N
          sta HIT_DIR
          jsr HitTile


          lda #2
          sta BLOCKED_DIR
          lda #0
          rts


;------------------------------------------------------------
;move object up
;x = object index
;------------------------------------------------------------
!zone ObjectMoveUp
ObjectMoveUp
          lda SPRITE_NUM_PARTS,x
          sta PARAM11
-
          dec SPRITE_CHAR_POS_Y_DELTA,x

          lda SPRITE_CHAR_POS_Y_DELTA,x
          cmp #$ff
          bne .NoCharStep

          dec SPRITE_CHAR_POS_Y,x
          lda #7
          sta SPRITE_CHAR_POS_Y_DELTA,x

.NoCharStep
          jsr MoveSpriteUp

          inx
          dec PARAM11
          bne -

          lda SPRITE_MAIN_INDEX - 1,x
          tax
          rts



;move object down if not blocked
;x = object index
;a = 1 if moved, 0 if blocked
!zone ObjectMoveDownBlocking
ObjectMoveDownBlocking

          lda SPRITE_CHAR_POS_Y_DELTA,x
          bne +

          lda #DIR_S
          sta MOVE_DIR
          
          jsr CheckCanMoveDown
          bne +

          ldy #2
          sty BLOCKED_DIR

          lda #0
          rts
+

          jsr ObjectMoveDown
          lda #1
          rts


;------------------------------------------------------------
;move object down
;x = object index
;------------------------------------------------------------
!zone ObjectMoveDown
ObjectMoveDown
          lda SPRITE_NUM_PARTS,x
          sta PARAM11
-
          inc SPRITE_CHAR_POS_Y_DELTA,x

          lda SPRITE_CHAR_POS_Y_DELTA,x
          cmp #8
          bne .NoCharStep

          lda #0
          sta SPRITE_CHAR_POS_Y_DELTA,x
          inc SPRITE_CHAR_POS_Y,x

.NoCharStep
          jsr MoveSpriteDown

          inx
          dec PARAM11
          bne -

          lda SPRITE_MAIN_INDEX - 1,x
          tax
          rts



!zone CheckCanMoveDown
;returns 0 if blocked, 1 if move is possible
CheckCanMoveDown
          lda SPRITE_WIDTH_CHARS,x
          sta PARAM5

          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .NoSecondCharCheckNeeded
          inc PARAM5
.NoSecondCharCheckNeeded

          ldy SPRITE_CHAR_POS_Y,x
          iny
          sty PARAM2
          cpy #24
          lbcs HitTile.HitWallSound

          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda SPRITE_CHAR_POS_X,x
          asl
          dec
          dec
          tay
-
          iny
          iny
          
          lda (ZEROPAGE_POINTER_1),y

          jsr IsCharBlocking
          bne .BlockedDown
          
          dec PARAM5
          bne -

          ;not blocked
          lda #1
          rts



.BlockedDown
          tya
          lsr
          lsr
          sta PARAM1
          lsr PARAM2
          
          ;PARAM1,PARAM2 = screen char pos
          lda #DIR_S
          sta HIT_DIR
          jsr HitTile
          

          lda #0
          rts

.BlockedDownBorder          
.HitWallSound
          lda #0
          sta PLAYER_AFFECTED
          rts
          


;------------------------------------------------------------
;Enemy Behaviour
;------------------------------------------------------------
!zone ObjectControl
ObjectControl
          stx CURRENT_INDEX

.ObjectLoop
          ldy SPRITE_ACTIVE,x
          beq .NextObject

          lda SPRITE_HITBACK,x
          beq +
          dec SPRITE_HITBACK,x
          bne +

          lda SPRITE_HITBACK_ORIG_COLOR,x
          sta VIC.SPRITE_COLOR,x

+

          ;enemy is active
          dey
          lda ENEMY_BEHAVIOUR_TABLE_LO,y
          sta .JumpPointer + 1
          lda ENEMY_BEHAVIOUR_TABLE_HI,y
          sta .JumpPointer + 2

.JumpPointer
          jsr $8000

          cpx CURRENT_INDEX
          beq +
          inc VIC.BORDER_COLOR

+

.NextObject
          inc CURRENT_INDEX
          ldx CURRENT_INDEX
          cpx #8
          bne .ObjectLoop
          rts


;------------------------------------------------------------
;Move Sprite Left
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteLeft
MoveSpriteLeft
          dec SPRITE_POS_X,x
          bpl .NoChangeInExtendedFlag

          lda BIT_TABLE,x
          trb SPRITE_POS_X_EXTEND
          trb VIC.SPRITE_X_EXTEND

.NoChangeInExtendedFlag
          txa
          asl
          tay

          lda SPRITE_POS_X,x
          sta VIC.SPRITE_X_POS,y
          rts

;------------------------------------------------------------
;Move Sprite Right
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteRight
MoveSpriteRight
          inc SPRITE_POS_X,x
          lda SPRITE_POS_X,x
          bne .NoChangeInExtendedFlag

          lda BIT_TABLE,x
          tsb SPRITE_POS_X_EXTEND
          tsb VIC.SPRITE_X_EXTEND

.NoChangeInExtendedFlag
          txa
          asl
          tay

          lda SPRITE_POS_X,x
          sta VIC.SPRITE_X_POS,y
          rts

;------------------------------------------------------------
;Move Sprite Up
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteUp
MoveSpriteUp
          dec SPRITE_POS_Y,x

          txa
          asl
          tay

          lda SPRITE_POS_Y,x
          sta VIC.SPRITE_Y_POS,y
          rts

;------------------------------------------------------------
;Move Sprite Down
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteDown
MoveSpriteDown
          inc SPRITE_POS_Y,x

          txa
          asl
          tay

          lda SPRITE_POS_Y,x
          sta VIC.SPRITE_Y_POS,y
          rts


;------------------------------------------------------------
;IsCharBlocking
;checks if a char is blocking
;A = character, ZEROPAGE_POINTER1 + y is char offset
;returns 1 for blocking, 0 for not blocking,
;        sets HIT_CRUMBLE if char was crumble and returns 1
;------------------------------------------------------------
!zone IsCharBlocking
IsCharBlocking
          cmp #0
          beq .NotBlocking
          cmp #1
          beq .NotBlocking
          cmp #28
          beq .NotBlocking
          cmp #32
          beq .NotBlocking
          cmp #33
          beq .NotBlocking

          cmp #208
          beq .Deadly

          ;blocking
          lda #1
          rts

.NotBlocking
          lda #0
          rts


.Deadly
          ldy PARAM6
          lda #2
          rts



;------------------------------------------------------------
;CalcSpritePosFromCharPos
;calculates the real sprite coordinates from screen char pos
;and sets them directly
;PARAM1 = char_pos_x
;PARAM2 = char_pos_y
;X      = sprite index
;------------------------------------------------------------
!zone CalcSpritePosFromCharPos
CalcSpritePosFromCharPos

          ;offset screen to border 24,50
          lda BIT_TABLE,x
          eor #$ff
          and SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC.SPRITE_X_EXTEND

          ;need extended x bit?
          lda PARAM1
          sta SPRITE_CHAR_POS_X,x
          cmp #30
          bcc .NoXBit

          lda BIT_TABLE,x
          ora SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC.SPRITE_X_EXTEND

.NoXBit
          ;calculate sprite positions (offset from border)
          txa
          asl
          tay

          ;X = charX * 8 + ( 24 - SPRITE_CENTER_OFFSET_X=8 )
          lda PARAM1
          asl
          asl
          asl
          clc
          adc #( 24 - SPRITE_CENTER_OFFSET_X )
          sta SPRITE_POS_X,x
          sta VIC.SPRITE_X_POS,y

          ;Y = charY * 8 + ( 50 - SPRITE_CENTER_OFFSET_Y=11 )
          lda PARAM2
          sta SPRITE_CHAR_POS_Y,x
          asl
          asl
          asl
          clc
          adc #( 50 - SPRITE_CENTER_OFFSET_Y )
          sta SPRITE_POS_Y,x
          sta VIC.SPRITE_Y_POS,y

          lda #0
          sta SPRITE_CHAR_POS_X_DELTA,x
          sta SPRITE_CHAR_POS_Y_DELTA,x
          rts



;adds object
;PARAM1 = X
;PARAM2 = Y
;PARAM3 = TYPE
;returns a = 0 if no free slot found
!zone AddObject
AddObject
          ldx #0
AddObjectStartingWithSlot
          jsr FindEmptySpriteSlot
          bne +
          lda #0
          tax
          rts
+
          ;PARAM1 and PARAM2 hold x,y already
AddObjectInSlotX
          jsr CalcSpritePosFromCharPos

;requires PARAM3 = type, x/y already initialised
CreateObjectInSlot
          lda PARAM3
          sta SPRITE_ACTIVE,x

          ;sprite color

          ;disable mc flag
          lda BIT_TABLE,x
          eor #$ff
          and VIC.SPRITE_MULTICOLOR
          sta VIC.SPRITE_MULTICOLOR

          ;disable extended color flag
          lda BIT_TABLE,x
          trb VIC4.SPR16EN
          trb VIC4.SPRX64EN
          
          ldy PARAM3

          ;initialise enemy values
          lda TYPE_START_SPRITE,y
          sta SPRITE_POINTER_BASE,x
          sta SPRITE_BASE_IMAGE,x
          lda TYPE_START_HEIGHT_CHARS,y
          sta SPRITE_HEIGHT_CHARS,x
          lda TYPE_START_SPRITE_HP,y
          sta SPRITE_HP,x
          lda #1
          sta SPRITE_WIDTH_CHARS,x
          lda TYPE_START_COLOR,y
          sta VIC.SPRITE_COLOR,x
          bpl +
          ;set MC flag
          lda BIT_TABLE,x
          ora VIC.SPRITE_MULTICOLOR
          sta VIC.SPRITE_MULTICOLOR

+
          txa
          sta SPRITE_MAIN_INDEX,x
          
          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_EXTENDED_COLORS
          beq +
          
          lda BIT_TABLE,x
          tsb VIC4.SPR16EN
          tsb VIC4.SPRX64EN
          
          ;force 0 to be transparent
          lda #0
          sta VIC.SPRITE_COLOR,x
          
+          

          ;enable sprite
          lda BIT_TABLE,x
          tsb VIC.SPRITE_ENABLE
          

          lda #0
          ;look right per default
          sta SPRITE_DIRECTION,x
          sta SPRITE_DIRECTION_Y,x
          sta SPRITE_ANIM_POS,x
          sta SPRITE_ANIM_DELAY,x
          sta SPRITE_MOVE_POS,x
          sta SPRITE_MOVE_POS_Y,x
          sta SPRITE_MOVE_DX,x
          sta SPRITE_MOVE_DY,x
          sta SPRITE_STATE,x
          sta SPRITE_STATE_POS,x
          sta SPRITE_LIFETIME,x
          sta SPRITE_SHOT_HIT_COUNT,x
          lda #1
          sta SPRITE_NUM_PARTS,x

          lda TYPE_START_SPRITE_OFFSET_X,y
          sta PARAM4

          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_START_INVINCIBLE
          beq +
          lda #$80
          sta SPRITE_STATE,x

+
          lda PARAM4
.AdjustX
          beq .NoXMovementNeeded
          jsr MoveSpriteRight
          dec PARAM4
          jmp .AdjustX

.NoXMovementNeeded
          ldy SPRITE_ACTIVE,x
          lda TYPE_START_SPRITE_OFFSET_Y,y
          sta PARAM4

          jsr MoveSpriteDown
          lda PARAM4
.AdjustY
          beq AddObject.NoYMovementNeeded

          ;lda SPRITE_POS_Y,x
          ;sec
          ;sbc PARAM4
          ;sta SPRITE_POS_Y,x
          ;txa
          ;asl
          ;tay
          ;sta VIC.SPRITE_Y_POS,y
          ;ldy SPRITE_ACTIVE,x

          jsr MoveSpriteUp
          dec PARAM4
          jmp .AdjustY

.NoYMovementNeeded
          lda #1
          rts


!zone BHSmoke
BHSmoke
          inc SPRITE_STATE_POS,x
          lda SPRITE_STATE_POS,x
          and #$03
          bne +
 
          inc SPRITE_STATE,x
          lda SPRITE_STATE,x
          cmp #5
          lbeq RemoveObject
          
          asl
          asl
          clc
          adc #SPRITE_SMOKE
          sta SPRITE_POINTER_BASE,x
+          
  
          rts
          


!zone BHExplosion
BHExplosion
          inc SPRITE_STATE_POS,x
          lda SPRITE_STATE_POS,x
          and #$03
          bne +
 
          inc SPRITE_STATE,x
          lda SPRITE_STATE,x
          cmp #4
          lbeq RemoveObject
          
          asl
          asl
          clc
          adc #SPRITE_EXPLOSION
          sta SPRITE_POINTER_BASE,x
+          
  
          rts
          


!zone BHDisk
BHDisk
          lda SPRITE_ANIM_POS,x
          beq .GoUp
          cmp #1
          beq .GoDown
          cmp #2
          beq .GoLeft
          
          ;go right
          jsr ObjectMoveRight
          
.Moved          
          dec SPRITE_STATE,x
          bne .MoveDone
          
          ;set disk as tile
          
          ;calc tile offset
          lda SPRITE_CHAR_POS_X,x
          lsr
          sta PARAM1
          lda SPRITE_CHAR_POS_Y,x
          lsr
          sta PARAM2
          
          ldy SPRITE_ANIM_DELAY,x
          
          lda SPRITE_POINTER_BASE,x
          sec
          sbc #SPRITE_DISK
          lsr
          lsr
          clc
          adc #TILE_DISK_BLUE
          jsr SetTileAndUpdateShadows
          
          ldx CURRENT_INDEX
          jmp RemoveObject
.MoveDone
          rts
          
.GoLeft
          jsr ObjectMoveLeft
          jmp .Moved
          
.GoUp
          jsr ObjectMoveUp
          jmp .Moved
          
.GoDown
          jsr ObjectMoveDown
          jmp .Moved


;PARAM1 = x, PARAM2 = y, PARAM3 = type, x = slot
!zone SpawnObjectInSlotX
SpawnObjectInSlotX
          jsr AddObjectInSlotX
          jmp SpawnObject.FirstSpriteAdded

;PARAM1 = x, PARAM2 = y, PARAM3 = type
!zone SpawnObject
.MAIN_INDEX  
          !byte 0
          
SpawnObject
          ;add object to sprite array
          ldx ACTIVE_PLAYER_INDEX
          jsr AddObjectStartingWithSlot
.FirstSpriteAdded
          txa
          sta SPRITE_MAIN_INDEX,x
          sta .MAIN_INDEX

          ;offset in x to next group sprite
          lda #3
          sta PARAM10
          ;offset in y to next group sprite
          lda #3
          sta PARAM11

          ldy PARAM3
          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_EXPAND_X
          beq +
          lda #6
          sta PARAM10
+

          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_EXPAND_Y
          beq +
          lda #5
          sta PARAM11
+

          ;need to add second sprite?
          ldy PARAM3
          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_DOUBLE_H
          beq +
          ;a double sprite H
          lda #4
          sta SPRITE_WIDTH_CHARS,x
          lda PARAM1
          clc
          adc PARAM10
          sta PARAM1
          inc PARAM3
          ldx .MAIN_INDEX
          jsr AddObjectStartingWithSlot
          lda .MAIN_INDEX
          sta SPRITE_MAIN_INDEX,x
          tay
          lda #2
          sta SPRITE_NUM_PARTS,y

          ldy PARAM3
          lda TYPE_START_SPRITE_FLAGS - 1,y
          and #SF_DOUBLE_V
          beq ++

          ;a quad sprite!

          inc PARAM3
          lda PARAM1
          sec
          sbc PARAM10
          sta PARAM1
          lda PARAM2
          clc
          adc PARAM11
          sta PARAM2
          ldx .MAIN_INDEX
          jsr AddObjectStartingWithSlot

          lda PARAM1
          clc
          adc PARAM10
          sta PARAM1
          inc PARAM3
          ldx .MAIN_INDEX
          jsr AddObjectStartingWithSlot

          ;mark as quad sprite
          lda .MAIN_INDEX
          sta SPRITE_MAIN_INDEX,x
          sta SPRITE_MAIN_INDEX - 1,x
          tay
          lda #4
          sta SPRITE_NUM_PARTS,y


          jmp ++
+
          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_DOUBLE_V
          beq +
          ;a double sprite V
          dec PARAM2
          dec PARAM2
          dec PARAM2
          inc PARAM3
          ldx .MAIN_INDEX
          jsr AddObjectStartingWithSlot
          lda .MAIN_INDEX
          sta SPRITE_MAIN_INDEX,x
          tay
          lda #2
          sta SPRITE_NUM_PARTS,y
          jmp ++
+

++
          lda SPRITE_MAIN_INDEX,x
          tax

          ;move down for collision?
          ;ldy SPRITE_ACTIVE,x
;          lda TYPE_START_SPRITE_FLAGS,y
;          and #SF_DOUBLE_V
;          beq .NotExpandedY
;
;          lda SPRITE_NUM_PARTS,x
;          sta PARAM1
;-
;          lda SPRITE_POS_Y,x
;          clc
;          adc #3
;          sta SPRITE_POS_Y,x
;
;          inx
;          dec PARAM1
;          bpl -
;
;          lda SPRITE_MAIN_INDEX,x
;          tax
;.NotExpandedY

          ;expand x/y?
          ldy PARAM3
          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_EXPAND_X
          beq .NoExpandX

          lda SPRITE_NUM_PARTS,x
          sta PARAM2
-
          lda VIC.SPRITE_EXPAND_X
          ora BIT_TABLE,x
          sta VIC.SPRITE_EXPAND_X

          lda SPRITE_WIDTH_CHARS,x
          asl
          sta SPRITE_WIDTH_CHARS,x

          inx
          dec PARAM2
          bne -

          dex
.NoExpandX
          ;expand y?
          lda SPRITE_MAIN_INDEX,x
          tax

          ldy PARAM3
          lda TYPE_START_SPRITE_FLAGS,y
          and #SF_EXPAND_Y
          beq .NoExpandY

          lda SPRITE_NUM_PARTS,x
          sta PARAM2
-
          lda VIC.SPRITE_EXPAND_Y
          ora BIT_TABLE,x
          sta VIC.SPRITE_EXPAND_Y

          lda SPRITE_HEIGHT_CHARS,x
          asl
          sta SPRITE_HEIGHT_CHARS,x

          inx
          dec PARAM2
          bne -

          dex
.NoExpandY

          lda SPRITE_MAIN_INDEX,x
          tax
          rts





ENEMY_BEHAVIOUR_TABLE_LO
          !byte <BHPlayer
          !byte <BHSmoke
          !byte <BHDisk
          !byte <BHExplosion

ENEMY_BEHAVIOUR_TABLE_HI
          !byte >BHPlayer
          !byte >BHSmoke
          !byte >BHDisk
          !byte >BHExplosion

;0 = normal, 1 = enemy, 2 = pickup, 3 = special behaviour (sphere), 4 = boss, 5 = check collision (player and player shot), 6 = enemy shot
;            7 = respawnable enemy
IS_TYPE_ENEMY = * - 1
          !byte 5     ;player bottom
          !byte 0     ;smoke
          !byte 0     ;disk
          !byte 0     ;explosion

TYPE_START_SPRITE_OFFSET_X = * - 1
          !byte 8     ;player bottom
          !byte 0     ;smoke
          !byte 0     ;disk
          !byte 0     ;explosion

TYPE_START_SPRITE_OFFSET_Y = * - 1
          !byte 0     ;player bottom
          !byte 0     ;smoke
          !byte 0     ;disk


TYPE_START_HEIGHT_CHARS = * - 1
          !byte 1     ;player
          !byte 1     ;smoke
          !byte 1     ;disk
          !byte 1     ;explosion


TYPE_START_SPRITE = * - 1
          !byte SPRITE_DATA / 64
          !byte SPRITE_SMOKE
          !byte SPRITE_DISK
          !byte SPRITE_EXPLOSION

TYPE_START_COLOR = * - 1
          !byte 11      ;player bottom
          !byte 2       ;smoke
          !byte 2       ;disk
          !byte 2       ;explosion

SF_DOUBLE_V             = $01     ;two sprites on top of each other
SF_DOUBLE_H             = $02     ;two sprites beside each other
SF_START_INVINCIBLE     = $04   ;sprite starts out invincible (enemy shots) = SPRITE_STATE is set to $80
SF_EXPAND_X             = $08
SF_EXPAND_Y             = $10
SF_EXTENDED_COLORS      = $20
;SF_DOUBLE_V, SF_DOUBLE_H, SF_START_INVINCIBLE, SF_EXPAND_X, SF_EXPAND_Y, SF_HIDDEN_WITHOUT_GUN
TYPE_START_SPRITE_FLAGS = * - 1
          !byte SF_EXTENDED_COLORS      ;player
          !byte 0                       ;smoke
          !byte SF_EXTENDED_COLORS      ;disk
          !byte 0                       ;explosion

TYPE_START_SPRITE_HP = * - 1
          !byte 0     ;player bottom
          !byte 0     ;smoke
          !byte 0     ;disk
          !byte 0     ;explosion


SPRITE_POS_X_EXTEND
          !byte 0

;all these sprite thingies require 8 bytes for copy to work!
SPRITE_POS_X
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_X
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_X_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_Y_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_POS_Y
          !byte 0,0,0,0,0,0,0,0

;0 = empty/TYPE_NONE
SPRITE_ACTIVE
          !byte 0,0,0,0,0,0,0,0
;0 = none, 1 = left, 2 = right
SPRITE_DIRECTION
          !byte 0,0,0,0,0,0,0,0
;0 = none, 1 = up , 2 = down
SPRITE_DIRECTION_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_ANIM_POS
          !byte 0,0,0,0,0,0,0,0
SPRITE_ANIM_DELAY
          !byte 0,0,0,0,0,0,0,0
SPRITE_MOVE_POS
          !byte 0,0,0,0,0,0,0,0
SPRITE_MOVE_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_BASE_IMAGE
          !byte 0,0,0,0,0,0,0,0
SPRITE_STATE
          !byte 0,0,0,0,0,0,0,0
SPRITE_STATE_POS
          !byte 0,0,0,0,0,0,0,0
SPRITE_WIDTH_CHARS
          !byte 0,0,0,0,0,0,0,0
SPRITE_HEIGHT_CHARS
          !byte 0,0,0,0,0,0,0,0
SPRITE_MAIN_INDEX
          !byte 0,0,0,0,0,0,0,0
SPRITE_NUM_PARTS
          !byte 0,0,0,0,0,0,0,0
SPRITE_HP
          !byte 0,0,0,0,0,0,0,0
SPRITE_HITBACK
          !byte 0,0,0,0,0,0,0,0
SPRITE_HITBACK_ORIG_COLOR
          !byte 0,0,0,0,0,0,0,0
;how many times has a shot hit this enemy
SPRITE_SHOT_HIT_COUNT
          !fill 8
SPRITE_LIFETIME
          !fill 8
SPRITE_MOVE_DX
          !byte 0,0,0,0,0,0,0,0
SPRITE_MOVE_DY
          !byte 0,0,0,0,0,0,0,0

;1 = blocked in X, 2 = blocked in Y
BLOCKED_DIR
          !byte 0
          
MOVE_DIR
          !byte 0

ACTIVE_PLAYER_INDEX
          !byte 0

PLAYER_SHOT_COLOR = * - 1
          !byte 14,13,7,1

BIT_TABLE
          !byte 1,2,4,8,16,32,64,128