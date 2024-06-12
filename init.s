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
         ldx #1
         jsr pgalloc
         sty pr{CBM-@}fbfpg

         lda #mapapp
         ldx #1
         jsr pgalloc
         sty sl{CBM-@}ptrpg

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

         rts
         .bend

