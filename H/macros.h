;----[/h/:macros.h - presenter ]--------

regstore = $c8   ;A/X/Y +0+1+2

phx      .macro
         txa
         pha
         .endm

plx      .macro
         pla
         tax
         .endm

phy      .macro
         tya
         pha
         .endm

ply      .macro
         pla
         tay
         .endm

phxf     .macro
         stx regstore+1
         .endm

plxf     .macro
         ldx regstore+1
         .endm

phyf     .macro
         sty regstore+2
         .endm

plyf     .macro
         ldy regstore+2
         .endm

sl{CBM-@}inc{CBM-@}y .macro
         iny
         bne *+4
         inc ptr+1
         .endm


pr{CBM-@}st{CBM-@}dirty .macro
         lda #1
         sta dirty
         .endm

pr{CBM-@}cl{CBM-@}dirty .macro
         lda #0
         sta dirty
         .endm

ui{CBM-@}newline .macro
         inc sl{CBM-@}row

         ldx sl{CBM-@}row
         ldy #0
         clc
         jsr setlrc
         #ldxy 0
         sec
         jsr setlrc
         .endm

ui{CBM-@}mkredraw .macro
         ldx layer+slindx
         jsr markredraw
         .endm

