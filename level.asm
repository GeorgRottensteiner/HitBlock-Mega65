!zone BuildScreen
BuildScreen
          jsr SetupScreenVector
          
          ldy LEVEL_NR
          lda SCREENS_MAP_LIST_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREENS_MAP_LIST_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          
          lda SCREENS_MAP_EXTRA_DATA_LIST_LO,y
          sta ZEROPAGE_POINTER_2
          lda SCREENS_MAP_EXTRA_DATA_LIST_HI,y
          sta ZEROPAGE_POINTER_2 + 1
          
          ldy #0
          lda (ZEROPAGE_POINTER_2),y
          asl
          sta PLAYER_START_X
          iny
          lda (ZEROPAGE_POINTER_2),y
          asl
          sta PLAYER_START_Y
          iny
          lda (ZEROPAGE_POINTER_2),y
          sta PLAYER_COLOR
          
          ldy #0
          sty NUM_BLOCKS
-          
          lda (ZEROPAGE_POINTER_1),y
          sta LEVEL_DATA,y
 
          ;count blocks to destroy
          cmp #TILE_BLUE
          bcc +
          
          cmp #TILE_BROWN + 1
          bcs +
          
          inc NUM_BLOCKS
          
+          
          
          iny
          cpy #240
          bne -
          
          ;fix shadows
          ldy #21
--          
          jsr FixTileShadow
          
          iny
          cpy #20 * 12
          bne --
          
          
          lda #<LEVEL_DATA
          sta ZEROPAGE_POINTER_1
          lda #>LEVEL_DATA
          sta ZEROPAGE_POINTER_1 + 1

          ldz #$00
          lda #0
          sta PARAM2
          
.NextLine          
          lda #0
          ldz #0
          sta PARAM1
          
          ;ldy PARAM2
          ;lda SCREEN_LINE_OFFSET_TABLE_LO,y
          ;sta ZEROPAGE_POINTER_2
          ;lda SCREEN_LINE_OFFSET_TABLE_HI,y
          ;sta ZEROPAGE_POINTER_2 + 1

.NextTile                    
          ldy PARAM1
          lda (ZEROPAGE_POINTER_1),y
          tax

          ;UL
          lda SCREENS_TILE_CHARS_0_0,x
          sta [ZP.Screen], z 
          inz
          inz
          bne +
          inc ZP.Screen + 1
+          
          
          
          ;UR
          lda SCREENS_TILE_CHARS_1_0,x
          sta [ZP.Screen], z 
          inz
          inz
          bne +
          inc ZP.Screen + 1
+          

          inc PARAM1
          lda PARAM1
          cmp #20
          bne .NextTile
          
          
          ;lower half of tiles
          lda ZP.Screen
          clc
          adc #80
          sta ZP.Screen
          bcc +
          inc ZP.Screen + 1
+          
          
          inc PARAM2
          ;ldy PARAM2
          ;lda SCREEN_LINE_OFFSET_TABLE_LO,y
          ;sta ZEROPAGE_POINTER_2
          ;lda SCREEN_LINE_OFFSET_TABLE_HI,y
          ;sta ZEROPAGE_POINTER_2 + 1
          
          lda #0
          taz
          sta PARAM1

.NextTile2
          ldy PARAM1
          lda (ZEROPAGE_POINTER_1),y
          tax

          ;LL
          lda SCREENS_TILE_CHARS_0_1,x
          sta [ZP.Screen], z 
          inz
          inz
          bne +
          inc ZP.Screen + 1
+          
          
          
          ;LR
          lda SCREENS_TILE_CHARS_1_1,x
          sta [ZP.Screen], z 
          inz
          inz
          bne +
          inc ZP.Screen + 1
+          

          inc PARAM1
          lda PARAM1
          cmp #20
          bne .NextTile2
          
          ;next line
          lda #0
          sta PARAM1

          lda ZP.Screen
          clc
          adc #80
          sta ZP.Screen
          bcc +
          inc ZP.Screen + 1
+          
          lda ZEROPAGE_POINTER_1
          clc
          adc #20
          sta ZEROPAGE_POINTER_1
          bcc +
          inc ZEROPAGE_POINTER_1 + 1
+          
          
          inc PARAM2
          lda PARAM2
          cmp #24
          lbne .NextLine

          
          rts

          
!zone FixTileShadow
;expect y is tile index in LEVEL_DATA  
FixTileShadow
          lda LEVEL_DATA,y
          jsr IsTileBlocking
          bne .TileIsNotBlocking
          
          ;blocking tile have no shadows
          ;combine shadow data
          ;tile to the left
          lda LEVEL_DATA - 1,y
          jsr IsTileBlocking
          sta PARAM11
          
          ;tile to the top
          lda LEVEL_DATA - 20,y
          jsr IsTileBlocking
          asl
          ora PARAM11
          sta PARAM11
          
          ;tile to the top left
          lda LEVEL_DATA - 21,y
          jsr IsTileBlocking
          asl
          asl
          ora PARAM11
          sta PARAM11
          
          tax
          lda TILE_SHADOW_TABLE,x
          sta LEVEL_DATA,y
          
.TileIsNotBlocking
          rts
  


!zone IsTileBlocking          
;a = tile index
;returns 1 if blocking, 0 if non blocking  
IsTileBlocking          
          cmp #TILE_EMPTY_SHADOW_7 + 1
          bcc .NotBlocking
          
          lda #1
          rts
          
.NotBlocking
          lda #0
          rts
          
          
          
;xxxx xABC 
;            A = tile to top left is blocking
;            B = tile above is blocking
;            C = tile to left is blocking          
TILE_SHADOW_TABLE
          !byte TILE_EMPTY      ;no blocking
          !byte TILE_EMPTY_SHADOW_5   ;blocked left
          !byte TILE_EMPTY_SHADOW_1   ;blocked top
          !byte TILE_EMPTY_SHADOW_6   ;blocked top, left
          !byte TILE_EMPTY_SHADOW_3   ;blocked top left
          !byte TILE_EMPTY_SHADOW_4   ;blocked left, top left
          !byte TILE_EMPTY_SHADOW_2   ;blocked top, top left
          !byte TILE_EMPTY_SHADOW_7   ;blocked top, left, top left
            
        
            
!mediasrc "levels.mapproject",SCREENS_,maptile

LEVEL_NR
          !byte 0
          
LEVEL_DATA
          !fill 240