;- pres.s ------------------------------

; Constants

defcolor .byte cblack
defbcolor .byte cwhite

vic{CBM-@}bgcol0 = $d021
vic{CBM-@}bcol = $d020

cr       = $0d ;Cariage return
c{CBM-@}cmd    = "!" ;Command
c{CBM-@}slide  = "s" ;Slide start
c{CBM-@}prevsl = "S" ;Prev slide
c{CBM-@}pause  = "p" ;Pause output
c{CBM-@}dfield = "d" ;Define field
c{CBM-@}field  = "f" ;Insert field value
c{CBM-@}loc    = "l" ;Change location
c{CBM-@}window = "w" ;Change window
c{CBM-@}sttab  = "t" ;Set tab (indent)
c{CBM-@}clend  = "{CBM-@}" ;Clear to line end
c{CBM-@}color  = "c" ;Set color
c{CBM-@}backgr = "b" ;Set background color
c{CBM-@}end    = "e" ;End

s{CBM-@}ended  = 0
s{CBM-@}paused = 1
s{CBM-@}render = 2


pr{CBM-@}free  ;Free open pres mem
         .block

         ldy opnfileref+1
         beq done

         ;Free file ref

         ldx #1
         jsr pgfree

         ;Free file buf

         ldy pr{CBM-@}bufpg
         ldx pr{CBM-@}bufsz
         jsr pgfree

         ;Free fields
         ldx #1
         ldy pr{CBM-@}fdpg
         jsr pgfree

         lda #0
         sta opnfileref+1
         sta pr{CBM-@}bufpg
         sta pr{CBM-@}bufsz
         sta pr{CBM-@}fdpg
done
         rts
         .bend

pr{CBM-@}init  ;Initialise presentation
         .block

         ldx #0
         ldy pr{CBM-@}bufpg
         stx sl{CBM-@}seglo
         sty sl{CBM-@}seghi
         stx sl{CBM-@}row
         stx sl{CBM-@}curcol
         stx sl{CBM-@}col
         stx pr{CBM-@}state
         stx ystore
         stx sl{CBM-@}infld
         lda #$ff ;no slides yet
         sta sl{CBM-@}cur
         sta sl{CBM-@}max
         lda #1
         sta sl{CBM-@}haspause

         tya      ;A = pr{CBM-@}bufpg
         ldy sl{CBM-@}ptrpg
         #stxy ptr
         ldy #$80 ;hi pages
         sta (ptr),y
         lda #0
         ldy #0   ;lo pages
         sta (ptr),y

         rts
         .bend

pr{CBM-@}load  ;Load presentation
         ;regptr -> file ref struct
         .block

         ;free existing pres mem
         #phyf
         jsr pr{CBM-@}free
         #plyf

         ldx #0

         ;store fref and open file

         sty opnfileref+1
         lda #ff{CBM-@}r.ff{CBM-@}s
         jsr fopen

         #stxy ptr

         ;reserve mem for file

         ldy #frefblks ;lo byte only
         lda (ptr),y
         sta pr{CBM-@}bufsz
         sta rsize+1

         tax
         lda #mapapp
         jsr pgalloc

         sty pr{CBM-@}bufpg
         sty raddr+1

         ;read file

         #rdxy opnfileref
         jsr fread
raddr    .word $00 ;inline args
rsize    .word $00

         jsr fclose

         ;allocate field buffer
         lda #mapapp
         ldx #1
         jsr pgalloc
         sty pr{CBM-@}fdpg
         ;clear non zero bytes 0 to 2
         ldx #0
         #stxy ptr
         ldy #0
         lda #0
         sta (ptr),y
         iny
         sta (ptr),y
         iny
         sta (ptr),y

         ;trigger pres redraw

         jsr pr{CBM-@}init
         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw

done     clc
         rts
         .bend

getnum   ;get 2 decimal number
         .block
         lda (ptr),y
         sec
         sbc #48
         sta ystore
         asl a
         asl a
         clc
         adc ystore
         asl a
         sta ystore
         #sl{CBM-@}inc{CBM-@}y
         lda (ptr),y
         sec
         sbc #48
         clc
         adc ystore
         #sl{CBM-@}inc{CBM-@}y
         rts
         .bend

pr{CBM-@}docmd
         .block
         #sl{CBM-@}inc{CBM-@}y

         #switch 10
         .byte c{CBM-@}slide
         .byte c{CBM-@}prevsl
         .byte c{CBM-@}loc
         .byte c{CBM-@}window
         .byte c{CBM-@}sttab
         .byte c{CBM-@}clend
         .byte c{CBM-@}color
         .byte c{CBM-@}backgr
         .byte c{CBM-@}dfield
         .byte c{CBM-@}field
         .rta pr{CBM-@}doslide
         .rta pr{CBM-@}strtsl
         .rta pr{CBM-@}doloc
         .rta pr{CBM-@}dowindow
         .rta pr{CBM-@}dotab
         .rta pr{CBM-@}doclend
         .rta pr{CBM-@}docolor
         .rta pr{CBM-@}dobackgr
         .rta pr{CBM-@}dodfield
         .rta pr{CBM-@}dofield

         sec
         rts
         .bend

pr{CBM-@}doslide
         .block
         sty ystore
         inc sl{CBM-@}cur

         ldx #0
         ldy sl{CBM-@}ptrpg
         #stxy ptr

         ;check for existing sl ptr
         lda sl{CBM-@}cur
         pha ;backup sl cur
         ora #$80 ;set bit 7 for hi
         tay
         lda (ptr),y
         beq noslptr

         ;use stored ptr
         sta sl{CBM-@}seghi
         pla
         tay
         lda (ptr),y
         sta sl{CBM-@}seglo
         jmp setslptr

noslptr
         lda sl{CBM-@}seghi
         sta (ptr),y

         pla ;restore y
         tay
         lda sl{CBM-@}seglo
         sta (ptr),y

setslptr
         ; restore slide data ptr
         ldx sl{CBM-@}seglo
         ldy sl{CBM-@}seghi
         #stxy ptr
         ldy ystore

         ; consume CR after !s
         ; actually works with any char
         #sl{CBM-@}inc{CBM-@}y

         .bend

pr{CBM-@}strtsl
         .block
         sty ystore

         ldx #0
         stx sl{CBM-@}row
         stx sl{CBM-@}col
         stx sl{CBM-@}curcol
         ldx #1
         stx sl{CBM-@}haspause
         #ldxy 0
         clc
         jsr setlrc
         #ldxy 0
         sec
         jsr setlrc

         ;Clear the Draw Context
         lda #" "
         jsr ctxclear
end
         ldy ystore

         clc
         rts
         .bend

pr{CBM-@}docolor
         .block

         jsr getnum
         sty ystore

         sta sl{CBM-@}fcol

         ;Set Draws Properties and Color
         ldx #d{CBM-@}crsr{CBM-@}h.d{CBM-@}petscr
         tay
         jsr setdprops

         ldy ystore

         clc
         rts
         .bend

pr{CBM-@}dobackgr
         .block
         ;get and set new color
         jsr getnum
         sty ystore

         sta sl{CBM-@}bgcol
         sta tkcolors+c{CBM-@}bckgnd
         sta sl{CBM-@}bcol
         sta tkcolors+c{CBM-@}border

         jsr seeioker
         sta vic{CBM-@}bgcol0
         sta vic{CBM-@}bcol
         jsr seeram

         ldy ystore
         clc
         rts
         .bend

pr{CBM-@}dowindow
         lda #1
         pha
         bne dowin
pr{CBM-@}doloc
         lda #0
         pha
dowin
         .block
         ; get column
         jsr getnum
         sta sl{CBM-@}curcol
         pha ;save column

         ; get row
         jsr getnum
         sty ystore
         sta sl{CBM-@}row
         tax
         ldy #0
         clc
         jsr setlrc

         pla ;restore column
         tax
         pla ;get tab switch
         beq notab
         stx sl{CBM-@}col
notab
         ldy #0
         sec
         jsr setlrc

         ldy ystore
         clc
         rts
         .bend

pr{CBM-@}dotab
         .block
         jsr getnum
         pha
         sty ystore
         ldx sl{CBM-@}row
         ldy #0
         clc
         jsr setlrc
         pla
         sta sl{CBM-@}col
         sta sl{CBM-@}curcol
         tax
         ldy #0
         sec
         jsr setlrc
         ldy ystore
         clc
         rts
         .bend

pr{CBM-@}doclend
         .block
         ldx sl{CBM-@}curcol
loop
         cpx #39
         bcs end
         lda #$20
         jsr ctxdraw
         inx
         jmp loop
end
         stx sl{CBM-@}curcol
         clc
         rts
         .bend

labelbuf .word 0
fldstack .word 0,0,0,0,0,0,0,0

find{CBM-@}slot
         .block
         pha ;store match on empty
         sty ystore
         ;point ptr2 to field buffer
         ldx #0
         ldy pr{CBM-@}fdpg
         #stxy ptr2

         ;read 1st char field name
         ldy ystore
         lda (ptr),y
         sta labelbuf
         #sl{CBM-@}inc{CBM-@}y

         ;read 2nd char field name
         lda (ptr),y
         sta labelbuf+1
         #sl{CBM-@}inc{CBM-@}y
         sty ystore

         ldx #$ff
loop
         ldy #0
         pla ;restore match on empty
         pha
         beq noempty
         lda (ptr2),y
         beq found{CBM-@}slot ;so store
noempty
         lda (ptr2),y
         cmp labelbuf
         bne nomatch

         iny
         lda (ptr2),y
         cmp labelbuf+1
         beq found{CBM-@}slot

nomatch
         lda #4
         clc
         adc ptr2
         bcs err{CBM-@}ovfl
         sta ptr2
         dex
         bne loop

err{CBM-@}full ;TODO error handling
         pla
         sec
         rts

err{CBM-@}ovfl
         pla
         sec
         rts

found{CBM-@}slot
         pla
         clc
         .bend
         rts

pr{CBM-@}dodfield
         .block
         lda #1 ;match on empty
         jsr find{CBM-@}slot
         bcs end

         ;store label
         ldy #0
         lda labelbuf
         sta (ptr2),y
         iny
         lda labelbuf+1
         sta (ptr2),y

         ;set ptr to start of value
         ldy ystore
         tya
         clc
         adc ptr
         sta ptr
         ldy #2
         sta (ptr2),y
         lda #0
         adc ptr+1
         sta ptr+1
         ldy #3
         sta (ptr2),y
         ldy #0
         sty ystore

         ;find !e
eloop
         lda (ptr),y

         beq end
         #sl{CBM-@}inc{CBM-@}y
         cmp #c{CBM-@}cmd
         bne eloop

         lda (ptr),y
         beq end
         #sl{CBM-@}inc{CBM-@}y
         cmp #c{CBM-@}end
         bne eloop
         sty ystore
end
         clc
         rts
         .bend

pr{CBM-@}dofield
         .block

         lda #0 ;don't match on empty
         jsr find{CBM-@}slot
         bcs end

         lda ystore
         adc ptr
         sta fldstack
         lda #0
         adc ptr+1
         sta fldstack+1

         inc sl{CBM-@}infld
         ldy #2
         lda (ptr2),y
         sta sl{CBM-@}seglo
         sta ptr
         iny
         lda (ptr2),y
         sta sl{CBM-@}seghi
         sta ptr+1

         ldy #0

end
         clc
         rts
         .bend

pr{CBM-@}render ;render a segment of content
         ;renders up to the next 'break'
         .block

         ldx sl{CBM-@}seglo
         ldy sl{CBM-@}seghi
         #stxy ptr

         ldy #0

         lda pr{CBM-@}cmd
         beq loop

         sty pr{CBM-@}cmd   ;clear command
         jsr pr{CBM-@}docmd ;it's still in A
         bcs end

loop     lda (ptr),y
         beq end

         cmp #cr
         bne nocr

         sty ystore
         #ui{CBM-@}newline
         ldy ystore
         jmp next
nocr
         cmp #c{CBM-@}cmd
         beq docmd

printchr
         cmp #$a0
         bne *+4
         lda #$20
         jsr ctxdraw
         inc sl{CBM-@}curcol

next     iny
         bne loop
         inc ptr+1
         bne loop
end
         ldx #0
         ldy pr{CBM-@}bufpg
         #stxy sl{CBM-@}seglo
         jmp pr{CBM-@}end

docmd
         ; get command code
         #sl{CBM-@}inc{CBM-@}y

         lda (ptr),y
         beq end

         cmp #"!"
         beq printchr

         cmp #c{CBM-@}slide
         bne noslide

         sta pr{CBM-@}cmd
         beq pause
noslide
         cmp #c{CBM-@}end
         bne noend
         lda sl{CBM-@}infld
         beq notinfld

         ; return from field
         lda fldstack+1
         sta sl{CBM-@}seghi
         lda fldstack
         sta sl{CBM-@}seglo
         lda #0
         dec sl{CBM-@}infld
         jmp pr{CBM-@}render

noend
         cmp #c{CBM-@}pause
         bne nopause

         #sl{CBM-@}inc{CBM-@}y
pause
         dec sl{CBM-@}haspause
         lda #s{CBM-@}paused
         sta pr{CBM-@}state
         clc
         tya
         adc ptr
         sta sl{CBM-@}seglo
         lda #0
         adc ptr+1
         sta sl{CBM-@}seghi

         rts
nopause
         jsr pr{CBM-@}docmd
         bcs end
         jmp loop

notinfld
         lda sl{CBM-@}cur
         sta sl{CBM-@}max
         clc
         tya
         adc ptr
         sta sl{CBM-@}seglo
         lda #0
         adc ptr+1
         sta sl{CBM-@}seghi
         lda #s{CBM-@}paused
         sta pr{CBM-@}state
         clc
         rts

         .bend

pr{CBM-@}start
         .block
         lda pr{CBM-@}state
         beq ended

         clc
         rts

ended    ;state is ended so we can start

         lda redrawflgs
         and #(rmenubar.rstatbar):$ff
         jsr setflags

         jsr pr{CBM-@}init
         ;skip chars up to first !s
         ldx sl{CBM-@}seglo
         ldy sl{CBM-@}seghi
         #stxy ptr
         ldy #0
loop
         lda (ptr),y
         beq end
         cmp #c{CBM-@}cmd
         bne next

         ;get command code
         #sl{CBM-@}inc{CBM-@}y

         lda (ptr),y
         beq end

         cmp #c{CBM-@}slide
         bne end
         sta pr{CBM-@}cmd

         lda #s{CBM-@}render
         sta pr{CBM-@}state

         clc
         tya
         adc ptr
         sta sl{CBM-@}seglo
         lda #0
         adc ptr+1
         sta sl{CBM-@}seghi

         ldy #$d8
         jsr setchrs

         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw

         clc ;Msg Handled
         rts

next     iny
         bne loop
         inc ptr+1
         bne loop

end
         jmp pr{CBM-@}end

         .bend

pr{CBM-@}nextsl
         ;Process next slide in pres
         ;slidecmd -> current command
         .block
         lda pr{CBM-@}state
         beq end

         lda sl{CBM-@}cur
         cmp sl{CBM-@}max
         bcs end

         lda #s{CBM-@}render
         sta pr{CBM-@}state

         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw
end
         clc ;Msg Handled
         rts
         .bend

pr{CBM-@}prevsl
         .block
         lda pr{CBM-@}state
         beq end

         ldx #0
         ldy sl{CBM-@}ptrpg
         #stxy ptr

         ldy sl{CBM-@}cur

         lda sl{CBM-@}haspause
         bmi haspause

         cpy #0
         beq end

         ;set slide ptrs to prev slide
         dey
         sty sl{CBM-@}cur
haspause
         lda (ptr),y ;lo byte
         clc
         adc #1 ;move past cr
         sta sl{CBM-@}seglo

         tya
         ora #$80 ;set bit 7 for hi
         tay
         lda (ptr),y ;hi byte
         adc #0 ;move past cr
         sta sl{CBM-@}seghi

         lda #c{CBM-@}prevsl
         sta pr{CBM-@}cmd
         lda #s{CBM-@}render
         sta pr{CBM-@}state
         lda #1
         sta sl{CBM-@}haspause

         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw
end
         clc
         rts
         .bend

pr{CBM-@}end
         .block
         ldy chrsbkpg
         jsr setchrs

         ;restore theme colors

         ldx bk{CBM-@}bgcol
         ldy bk{CBM-@}bcol
         stx tkcolors+c{CBM-@}bckgnd
         sty tkcolors+c{CBM-@}border

         jsr seeioker
         stx vic{CBM-@}bgcol0
         sty vic{CBM-@}bcol
         jsr seeram

         ;Clear the Draw Context
         lda #" "
         jsr ctxclear

         lda redrawflgs
         ora #rmenubar
         ora #rstatbar
         jsr setflags

         lda #s{CBM-@}ended
         sta pr{CBM-@}state

         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw
done
         clc
         rts
         .bend

