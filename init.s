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
         sta bk{CBM-@}bgcol
         lda tkcolors+c{CBM-@}border
         sta bk{CBM-@}bcol

         rts
         .bend

