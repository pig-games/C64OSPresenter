;----[ app.s - presenter ]--------------

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
         lda jdrvpg
         beq nojoy
         sta jdrvpgbk
         lda #0
         sta jdrvpg
nojoy
         ;restore theme colors

         ldx bk{CBM-@}bgcol
         stx tkcolors+c{CBM-@}bckgnd
         ldy bk{CBM-@}bcol
         sty tkcolors+c{CBM-@}border

         ldy chrsbkpg
         jsr restchrs

         rts
         .bend

didthw
         .block
         ;Open file if applicable
         lda opnappmcmd
         cmp #mc{CBM-@}fopn
         bne notopnf

         ldy opnappmdhi
         ldx #0
         stx opnappmcmd
         jsr pr{CBM-@}load
         jsr pr{CBM-@}end

notopnf
         lda pr{CBM-@}state
         beq ended

         lda util{CBM-@}opn
         bne util
         ldy #$d8
         jsr setchrs
util
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

         lda jdrvpgbk
         beq done
         sta jdrvpg
         lda #0
         sta jdrvpgbk
done
         rts
         .bend

willquit
         .block
         ;unload joystck if needed
         lda jydriver
         beq joyoff
         lda #"2"
         jsr joystop
         jsr unldjydrv
joyoff
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

         ;free presentation mem

         jsr pr{CBM-@}free

         ;Unload Shared Libraries

         ldx #"p"
         ldy #"a"
         lda #0
         jsr unldlib

         ldx #"d"
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

         #switch 4
         .byte mc{CBM-@}fopn
         .byte mc{CBM-@}menq,mc{CBM-@}mnu
         .byte mc{CBM-@}hmem
         .rta pr{CBM-@}load
         .rta mnuenq,mnucmd
         .rta chk{CBM-@}util

done     sec
         rts

mnuenq   ;X -> Menu Action Code
         lda #0 ;Enabled, Not selected
         txa
         ldx #0
         #switch 7
         .text "ospnejt"
         .rta chkend
         .rta chkstrt
         .rta chkact
         .rta chkact
         .rta chkact
         .rta chkjoy
         .rta chkend
         lda #0
         rts

chkend
         lda pr{CBM-@}state
         beq *+4; ended
         ldx #mnu{CBM-@}dis
;ended
         txa
         rts

chkstrt
         lda pr{CBM-@}state
         bne disable
         lda opnfileref+1
         bne enable
disable
         ldx #mnu{CBM-@}dis
enable
         txa
         rts

chkact
         lda pr{CBM-@}state
         bne *+4 ;started
         ldx #mnu{CBM-@}dis
;started
         txa
         rts

chkjoy
         lda jydriver
         bne *+4 ;active
         ldx #mnu{CBM-@}sel
;active
         ldx #0
         rts


mnucmd   ;X -> Menu Action Code
         txa
         #switch 8
         .text "!ospnejt"
         .rta quitapp
         .rta fileopen
         .rta pr{CBM-@}start
         .rta pr{CBM-@}prevsl
         .rta pr{CBM-@}nextsl
         .rta pr{CBM-@}end
         .rta tggljoy
         .rta opn{CBM-@}tut
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

chk{CBM-@}util
         .block
         lda himemuse
         and #hmemutil
         beq no{CBM-@}util
         lda util{CBM-@}opn
         bne end

         lda #1
         sta util{CBM-@}opn

         lda pr{CBM-@}state
         beq end

         ;restore os chrset

         ldy chrsbkpg
         jsr restchrs

         jmp end
no{CBM-@}util
         lda util{CBM-@}opn
         beq end

         lda #0
         sta util{CBM-@}opn
         lda pr{CBM-@}state
         beq end

         ;restore prs chrset
         ldy #$d8
         jsr setchrs
end
         clc
         rts
         .bend

opn{CBM-@}tut
         .block
         jsr pr{CBM-@}end

         #ldxy tut{CBM-@}fname
         jsr cnfappfref
         jsr pr{CBM-@}load
         jsr pr{CBM-@}start

         clc
         rts
tut{CBM-@}fname .null "tutorial.prs"
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
         beq done
         ;dirty and have file
         ;presentation output

         lda pr{CBM-@}state
         beq info
         cmp #s{CBM-@}render
         beq render
         bne done
info
         jsr pr{CBM-@}info
         jmp done
render
         jsr pr{CBM-@}render
done
         ldx #0
         ldy #0
         jsr ctx2scr

         rts
         .bend

tggljoy
         .block
         lda jydriver
         beq on
         ;turn off driver and timer
         jsr joystop
         jsr unldjydrv
         jmp end

on       ;turn on driver and timer
         jsr ldjydrv
         jsr joystart
end
         rts
         .bend

unldjydrv ;unload joystick driver
         .block
         ldy jdrvpg
         bne *+4
         sec
         rts

         ldx #0   ;Disable driver
         stx jdrvpg
         stx jydriver

         ;Y -> jdrvpg
         ldx #1
         jsr pgfree

         clc
         rts
         .bend

ldjydrv  ;Load Joystick driver
         .block
         jsr unldjydrv

         lda #1
         sta jydriver

         ldx #1
         lda #mapsys
         jsr pgalloc

         jsr getsfref
         stx ptr2+1
         ldx #0
         stx ptr2

         lda drvpath,x
         sta (ptr2),y
         beq *+6
         inx
         iny
         bne *-9

         ldx #0
         ldy #frefname

         lda nesxdrv,x
         sta (ptr2),y
         beq *+6
         inx
         iny
         bne *-9

         #rdxy ptr2
         jsr loadreloc

         sta jdrvpg
         clc
         rts

drvpath  .null "drivers/"
nesxdrv  .null "joy.nes 2 player"
         .bend

joychk
         .block
         pha
         lda jport2
         bne *+7
         sta jyold
         pla
         rts
         cmp jyold
         bne *+4
         pla
         rts
         sta jyold

         lsr a
         bcc noup
         jsr pr{CBM-@}prevsl
         pla
         rts
noup     lsr a
         bcc nodown
         jsr pr{CBM-@}nextsl
         pla
         rts
nodown   lsr a
         bcc noleft
         jsr pr{CBM-@}prevsl
         pla
         rts
noleft   lsr a
         bcc noright
         jsr pr{CBM-@}nextsl
         pla
         rts
noright  lsr a
         bcc nofire1
         jsr pr{CBM-@}nextsl
         pla
         rts
nofire1  lsr a
         bcc nofire2
         jsr pr{CBM-@}nextsl
         pla
         rts
nofire2  lsr a
         bcc noselect
         jsr pr{CBM-@}end
         pla
         rts
noselect lsr a
         bcc nostart
         jsr pr{CBM-@}start
nostart
         pla
         rts
         .bend

joytimer .byte 6,0,0
         .byte 0
         .word joychk
         .byte 6,0,0

joystop  ;Cancel the timer
         lda #tcancel
         sta joytimer+tstat
         rts

joystart ;Start the timer
         lda #tintrvl.tcancel
         sta joytimer+tstat
         #ldxy joytimer
         jsr timeque
         rts

cnfappfref
         .block
         ;RegPtr->Filename
         ;RegPtr<-appfileref
         ;ptr<-appfileref

         #stxy fstr+1

         #rdxy appfileref
         #stxy ptr

         ldx #$ff
         ldy #frefname-1

         inx
         iny
fstr     lda $ffff,x        ;self mod
         sta (ptr),y
         bne *-7

         #rdxy ptr
         rts
         .bend

;path.lib

setname  jmp 3
pathadd  jmp 6
gopath   jmp 18

;datetime.lib

toisodt  jmp 3

