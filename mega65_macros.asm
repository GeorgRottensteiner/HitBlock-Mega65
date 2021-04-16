!zone VIC3

  
;write $A5 and $96 there to enable VIC 3  
;write 'G' and 'S' there to enable VIC 4  
.KEY            = $d02f
  
;1xxx xxxx      H640      0 = use 40 character screen width
;x1xx xxxx      FAST
;xx1x xxxx      ATTR
;xxx1 xxxx      BPM
;xxxx 1xxx      V400
;xxxx x1xx      H1280
;xxxx xx1x      MONO
;xxxx xxx1      INT
.VICDIS         = $d031  



!zone VIC4
  

;VIC4 display settings
;1xxx xxxx      = ALPHEN
;x1xx xxxx      = VFAST
;xx1x xxxx      = PALEMU
;xxx1 xxxx      = SPR640    1 = sprite 640 resolution enabled
;xxxx 1xxx      = SMTH
;xxxx x1xx      = FCLRHI    1 = enable full color for chars > $ff
;xxxx xx1x      = FCLRLO    1 = enable full color for chars <= $ff
;xxxx xxx1      = CHR16     1 = enable 16 bit character numbers
.VIC4DIS        = $d054

  
;enable sprite wide mode (bit = sprite index)
.SPRX64EN       = $d057

;number of bytes per line lo
.CHARSTEP_LO    = $d058

;number of bytes per line hi
.CHARSTEP_HI    = $d059

;disable hot registers
;1xxx xxxx = HOTREG     1 = disable writing VIC2 registers affected VIC4 registers
;x1xx xxxx = RSTDELEN   1 = enable raster delay by one line to match output pipeline
;xx11 xxxx = SIDBDRWD     = width of single side border
.HOTREG         = $d05d


;3 byte address of screen ram 
;$d060 = lo byte
;$d061 = medium byte
;$d062 = hi byte
.SCRNPTR        = $d060
  
;enable sprite 16 color mode (bit = sprite index)
.SPR16EN        = $d06b  

;sprite pointer list address lo  
.SPRPTRADR_LO   = $d06c   

;sprite pointer list address hi
.SPRPTRADR_HI   = $d06d
  
;1xxx xxxx =   SPRPTR16  - enable 16 bit sprite addresses
;x111 1111 =   SPRPTRBNK - sprite pointer bank
.SPRPTR16       = $d06e     


;11xx xxxx = MAPEDPAL     - palette bank mapped at $d100 to $d3ff
;xx11 xxxx = BTPALSEL     - bitmap/text palette bank
;xxxx 11xx = SPRPALSEL    - sprite palette bank
;xxxx xx11 = ABTPALSEL    - VIC4 alternative bitmap/text palette bank
.PALSEL         = $d070

;palette red entries (up to $d1ff) 
.PALRED         = $d100

;palette green entries (up to $d2ff) 
.PALGREEN       = $d200

;palette blue entries (up to $d3ff) 
.PALBLUE        = $d300



!zone Mega65
;read the last key pressed (until written to)
.PRESSED_KEY    = $d610
  
!macro enable40Mhz
          ; Enable 40Mhz
          lda #$41
          sta $00
!end
  
!macro enableVIC3Registers {
          lda #$00
          tax 
          tay 
          taz 
          map
          eom

          ;Enable VIC III
          lda #$A5  
          sta VIC3.KEY
          lda #$96
          sta VIC3.KEY
}

!macro enableVIC4Registers {
          ; Enable VIC4 registers
          lda #$00
          tax
          tay
          taz
          map
          eom  

          ;Enable VIC IV
          lda #$47        ;'G'
          sta VIC3.KEY
          lda #$53        ;'S'
          sta VIC3.KEY
}
