;----[app.s - presenter ]--------------

open{CBM-@}ut  .null "Open"
fileext  .text ".prs"
fileextl = *-fileext

cpychrs  ;a=src, y=tar, x=numpg
         .block
loop
         jsr memcpy
         clc
         adc #1
         iny
         dex
         bne loop
         rts
         .bend

restchrs ;y = source
         .block
         sei
         lda $01
         pha
         jsr seeram
         tya
         ldy #$d0
         ldx #8
         jsr cpychrs
         pla
         sta $01
         cli
         rts
         .bend

setchrs  ;y = sourcepg
         .block
         sei
         lda $01
         and #%11111011 ;Enable charrom
         sta $01
         tya
         ldy #$d0
         ldx #8
         jsr cpychrs
         lda $01
         ora #%00000100 ;Disable charrom
         sta $01
         cli
         rts
         .bend

willfrz
         .block
         ;restore theme colors

         ldx bk{CBM-@}bgcol
         stx tkcolors+c{CBM-@}bckgnd
         ldy bk{CBM-@}bcol
         sty tkcolors+c{CBM-@}border

         ldy chrsbkpg
         jsr restchrs

         rts
         .bend

willthw
         .block
         lda pr{CBM-@}state
         beq ended

         ldy #$d8
         jsr setchrs

         ldx sl{CBM-@}bgcol
         ldy sl{CBM-@}bcol
         jmp restore
ended
         ldx bk{CBM-@}bgcol
         ldy bk{CBM-@}bcol
restore
         stx tkcolors+c{CBM-@}bckgnd
         sty tkcolors+c{CBM-@}border

         jsr seeioker
         stx vic{CBM-@}bgcol0
         sty vic{CBM-@}bcol
         jsr seeram

         ;Open file if applicable
         lda opnappmcmd
         cmp #mc{CBM-@}fopn
         bne done

         ldy opnappmdhi
         ldx #0
         stx opnappmcmd
         jsr pr{CBM-@}load
done
         rts
         .bend

willquit
         .block
         ;Restore theme & charset
         jsr willfrz

         ;Dealloc Resources

         ;free display buffers
         ldx #4
         ldy drawctx+d{CBM-@}coloro+1
         jsr pgfree
         ldx #4
         ldy drawctx+d{CBM-@}origin+1
         jsr pgfree
         ldx #8
         ldy chrsbkpg
         jsr pgfree

         ;free slide location buffers
         ldx #1
         ldy pr{CBM-@}fbfpg
         jsr pgfree
         ldx #1
         ldy sl{CBM-@}ptrpg
         jsr pgfree

         ;free presentation mem

         jsr pr{CBM-@}free

         ;Unload Shared Libraries

         ldx #"p"
         ldy #"a"
         lda #0
         jsr unldlib

         ;Unload Custom Icons

         rts
         .bend

msgcmd   ;A -> Msg Command
         .block

         ;"Menu Enquiry" and "Menu Cmd"
         ;message types must be handled
         ;to support menu actions

         #switch 3
         .byte mc{CBM-@}fopn
         .byte mc{CBM-@}menq,mc{CBM-@}mnu
         .rta pr{CBM-@}load
         .rta mnuenq,mnucmd

done     sec
         rts

mnuenq   ;X -> Menu Action Code
         lda #0 ;Enabled, Not selected
         rts

mnucmd   ;X -> Menu Action Code
         txa
         #switch 6
         .text "!ospne"
         .rta quitapp
         .rta fileopen
         .rta pr{CBM-@}start
         .rta pr{CBM-@}prevsl
         .rta pr{CBM-@}nextsl
         .rta pr{CBM-@}end
         sec
         rts
         .bend

fileopen ;Open file util
         .block

         lda #mc{CBM-@}mptr
         sta opnutilmcmd

         #copy16 openjob,opnutilmdlo

         #ldxy open{CBM-@}ut
         jsr loadutil
         bcc done

         jsr seeram
         lda #mc{CBM-@}mptr
         #ldxy openjob
         jsr umcmd

         jsr seeioker

         clc
done     rts

umcmd    jmp (utilbase+utilmcmd)

openjob  .text "ojof"
         .word openjob+6
         ;A      -> fregpg
         ;RegPtr -> direntry
         ;C <- CLR = valid
         ;C <- SET = invalid

         #stxy dentr+1
         inx
         inx
         inx ;fdname

         #stxy ptr ; -> filename

         ;find end of string
         ldy #$ff
         iny
         lda (ptr),y
         bne *-3

         ;X.prs
         ;If Y < 5 name is to short
         cpy #5
         bcc invalidt

         ;Check file extension
         ldx #fileextl-1
extloop
         dey
         lda (ptr),y
         jsr tolower
         cmp fileext,x
         bne invalidt
         dex
         bpl extloop

         ldx #20     ;fdtype
dentr    lda $ffff,x ; self mod
         cmp #3
         beq validtyp

invalidt sec         ;invalid type
         rts

validtyp clc
         rts
         .bend

drawmain ;Main draw routine
         .block

         ;Configure the Draw Context
         #ldxy drawctx
         jsr setctx

         lda dirty
         beq done

         #pr{CBM-@}cl{CBM-@}dirty

         ;Set Draws Properties and Color
         ldx #d{CBM-@}crsr{CBM-@}h.d{CBM-@}petscr
         ldy sl{CBM-@}fcol
         jsr setdprops

         lda pr{CBM-@}bufsz
         beq nofile
         lda pr{CBM-@}state
         bne render
nofile
         ;Clear the Draw Context
         lda #" "
         jsr ctxclear
         jmp done

render   ;dirty and have file
         ;presentation output

         lda pr{CBM-@}state
         cmp #s{CBM-@}render
         bne done
         jsr pr{CBM-@}render
done
         ldx #0
         ldy #0
         jsr ctx2scr

         rts
         .bend

;path.lib

setname  jmp 3
pathadd  jmp 6
gopath   jmp 18

