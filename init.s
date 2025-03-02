;- init.s ------------------------------

init
         .block
         #ldxy externs
         jsr initextern

         #ldxy layer
         jsr layerpush

         lda #mapapp
         ldx #4
         jsr pgalloc
         sty drawctx+d{CBM-@}coloro+1

         lda #mapapp
         ldx #4
         jsr pgalloc
         sty drawctx+d{CBM-@}origin+1

         lda #mapapp
         ldx #8
         jsr pgalloc
         sty chrsbkpg

         ;Backup charset
         lda #$d0
         ldx #8
         jsr seeram
         jsr cpychrs
         jsr seeioker

         ;Load Shared Libraries

         ldx #"p"
         ldy #"a"
         lda #2
         jsr loadlib

         sta setname+2
         sta pathadd+2
         sta gopath+2

         ldx #"d"
         ldy #"a"
         lda #2
         jsr loadlib

         sta toisodt+2

         ;Load Custom TK Classes

         ;Load Custom Icons

         ;Initialize UI

         lda tkcolors+c{CBM-@}bckgnd
         sta sl{CBM-@}bgcol
         sta bk{CBM-@}bgcol
         lda tkcolors+c{CBM-@}border
         sta sl{CBM-@}bcol
         sta bk{CBM-@}bcol
         lda #0
         sta pr{CBM-@}state

         ;Open file if applicable
         lda opnappmcmd
         cmp #mc{CBM-@}fopn
         bne nofile

         ldy opnappmdhi
         ldx #0
         stx opnappmcmd
         jsr pr{CBM-@}load
         rts
nofile
         jsr ldsplash
         rts
         .bend

ldsplash
         .block

         ldx #0
         ldy drawctx+d{CBM-@}origin+1
         sty addr1+1
         sty addr2+1
         ldy drawctx+d{CBM-@}coloro+1
         sty addr3+1

         #ldxy spl{CBM-@}fname
         jsr cnfappfref

         ;store fref and open file

         sty opnfileref+1
         lda #ff{CBM-@}r
         jsr fopen

         #rdxy opnfileref
         ;skip header

         jsr fread
addr1    .word $00
         .word 55

         ;read screen codes
         jsr fread
addr2    .word $00
         .word 1000

         jsr fread
addr3    .word $00
         .word 1000

         jsr fclose

         rts
spl{CBM-@}fname .null "splash.pet"
         .bend

