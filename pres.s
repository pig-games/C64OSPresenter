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
c{CBM-@}sttab  = "i" ;Set indent
c{CBM-@}clend  = "{CBM-@}" ;Clear to line end
c{CBM-@}color  = "c" ;Set color
c{CBM-@}backgr = "b" ;Set background color
c{CBM-@}inctpl = "#" ;Include template
c{CBM-@}end    = "e" ;End

s{CBM-@}ended  = 0
s{CBM-@}paused = 1
s{CBM-@}render = 2

pr{CBM-@}free  ;Free open pres mem
         .block

         ldy opnfileref+1
         beq done

         cpy appfileref+1
         beq afterfree

         ;Free file ref
         ldx #1
         jsr pgfree
afterfree

         ;Free file buf
         ldy pr{CBM-@}bufpg
         beq nobuf
         ldx pr{CBM-@}bufsz
         jsr pgfree
         ;Free sl ptrs

         ldx #1
         ldy pr{CBM-@}fdpg
         jsr pgfree

         ;Free fields
         ldx #1
         ldy sl{CBM-@}ptrpg
         jsr pgfree
nobuf
         lda #0
         sta opnfileref+1
         sta pr{CBM-@}bufpg
         sta pr{CBM-@}bufsz
         sta pr{CBM-@}fdpg
         sta sl{CBM-@}ptrpg
done
         rts
         .bend

pr{CBM-@}init  ;Initialise presentation
         .block

         ldx pr{CBM-@}prslo
         stx sl{CBM-@}seglo
         ldy pr{CBM-@}prshi
         sty sl{CBM-@}seghi

         ldx #0
         stx sl{CBM-@}row
         stx sl{CBM-@}curcol
         stx sl{CBM-@}col
         stx sl{CBM-@}max
         stx pr{CBM-@}state
         stx slidecmd
         stx ystore
         stx sl{CBM-@}infld
         stx fldstack
         stx fldstack+1
         stx fldstack+2
         stx fldstack+3
         stx fldstack+4
         stx fldstack+5
         stx fldstack+6
         stx fldstack+7
         lda #$ff ;no slides yet
         sta sl{CBM-@}cur
         lda #1
         sta sl{CBM-@}haspause

         rts
         .bend

cleanpg
         .block
         ldy #0
         lda #0
         sta (ptr),y
         iny
         sta (ptr),y
         iny
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

         ;set pf field with fname
         ldx #<f{CBM-@}pf
         ldy #>f{CBM-@}pf
         #stxy ptr2
         inc ptr2
         inc ptr2

         lda #frefname
         clc
         adc ptr
         sta ptr
         ldy #0
loop
         lda (ptr),y
         beq end ;*+8
         sta (ptr2),y
         iny
         jmp loop
end
         lda #"!"
         sta (ptr2),y
         iny
         lda #"e"
         sta (ptr2),y

         ;read file

         #rdxy opnfileref
         jsr fread
raddr    .word $00 ;inline args
rsize    .word $00

         jsr fclose

         ;allocate sl ptr buffer
         lda #mapapp
         ldx #1
         jsr pgalloc
         sty sl{CBM-@}ptrpg
         ;clear non zero bytes 0 to 2
         ldx #0
         #stxy ptr
         jsr cleanpg

         ;allocate field buffer
         lda #mapapp
         ldx #1
         jsr pgalloc ;todo: clnalloc
         sty pr{CBM-@}fdpg
         ;clear non zero bytes 0 to 2
         ldx #0
         #stxy ptr
         jsr cleanpg

         ;set pv field

         ldx #<f{CBM-@}pv
         ldy #>f{CBM-@}pv
         #stxy ptr
         ldy #0
         jsr pr{CBM-@}dodfield

         ;set sn field

         ldx #<f{CBM-@}sn
         ldy #>f{CBM-@}sn
         #stxy ptr
         ldy #0
         jsr pr{CBM-@}dodfield

         ;set pf field

         ldx #<f{CBM-@}pf
         ldy #>f{CBM-@}pf
         #stxy ptr
         ldy #0
         jsr pr{CBM-@}dodfield

         ;set pd field

         ldx #<f{CBM-@}pd
         ldy #>f{CBM-@}pd
         #stxy ptr
         ldy #0
         jsr pr{CBM-@}dodfield

         ldx #0
         stx pr{CBM-@}prslo
         ldy pr{CBM-@}bufpg
         sty pr{CBM-@}prshi

         jsr pr{CBM-@}init

         ldx #0
         ldy pr{CBM-@}bufpg
         jsr pr{CBM-@}incltpl

         ;trigger pres redraw

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

pr{CBM-@}incltpl
         .block
         #stxy ptr
         ;check for include
         ldy #0
         lda (ptr),y
         cmp #c{CBM-@}cmd
         bne end
         iny
         lda (ptr),y
         cmp #c{CBM-@}inctpl
         bne end
         clc
         lda #2
         adc ptr
         sta ptr
         ;change closing cr to 0
         ldy #0
loop
         lda (ptr),y
         beq end
         #sl{CBM-@}inc{CBM-@}y
         cmp #cr
         bne loop

         lda #0
         dey ;set
         sta (ptr),y ;replace cr with 0

         ;set start of prs data
         lda ptr+1
         sta pr{CBM-@}prshi
         sta sl{CBM-@}seghi
         iny
         iny
         iny
         sty pr{CBM-@}prslo
         sty sl{CBM-@}seglo

         ;get file ref

         clc
         #rdxy ptr
         jsr frefcvt
         #stxy ptr2

         lda #ff{CBM-@}r.ff{CBM-@}s
         jsr fopen

         ;reserve mem for file

         ldy #frefblks ;lo byte only
         lda (ptr2),y
         sta pr{CBM-@}tplsz
         sta rsize+1

         tax
         lda #mapapp
         jsr pgalloc

         sty pr{CBM-@}tplpg
         sty raddr+1

         #rdxy ptr2
         jsr fread
raddr    .word $00 ;inline args
rsize    .word $00

         jsr fclose

         ldx #0
         ldy pr{CBM-@}tplpg
         jsr doheader
         bcc end
;err
         sec
         rts
end
         clc
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
         ldy ystore

         ; consume CR after !s
         ; actually works with any chr
         #sl{CBM-@}inc{CBM-@}y

         .bend
         ;fallthrough

pr{CBM-@}strtsl
         .block
         sty ystore

         ;set sl field to slide num

         #ldxy 10
         #stxy divisor
         ldx sl{CBM-@}cur
         ldy #0
         inx
         #stxy dividnd
         jsr tostr
         #stxy ptr2

         ldx #<f{CBM-@}sn
         ldy #>f{CBM-@}sn
         #stxy ptr
         inc ptr
         inc ptr
         ldy #0
loop
         lda (ptr2),y
         beq end ;*+8
         sta (ptr),y
         iny
         jmp loop
end
         lda #"!"
         sta (ptr),y
         iny
         lda #"e"
         sta (ptr),y

         ; restore slide data ptr
         ldx sl{CBM-@}seglo
         ldy sl{CBM-@}seghi
         #stxy ptr

         ldy ystore
         ; consume CR after !s
         ; actually works with any chr
         #sl{CBM-@}inc{CBM-@}y

         ;start slide

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
         bne dowin ;*+5
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
         beq notab ;*+5
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
         bcs end ;*+11
         lda #$20
         jsr ctxdraw
         inx
         jmp loop
end
         stx sl{CBM-@}curcol
         clc
         rts
         .bend

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
         beq noempty ;*+6
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
         ;backup ptr
         lda ptr+1
         pha
         lda ptr
         pha

         lda #<fldstack
         sta ptr
         lda #>fldstack
         sta ptr+1

         ldy sl{CBM-@}infld

         pla ;restore lo stack ptr
         adc ystore
         sta (ptr),y
         pla ;restore hi stack ptr
         adc #0
         iny
         sta (ptr),y

         iny
         sty sl{CBM-@}infld

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

pr{CBM-@}dohcmd ;header allowed commands
         .block
         #sl{CBM-@}inc{CBM-@}y
         #switch 6
         .byte c{CBM-@}loc
         .byte c{CBM-@}window
         .byte c{CBM-@}sttab
         .byte c{CBM-@}clend
         .byte c{CBM-@}color
         .byte c{CBM-@}backgr
         .rta pr{CBM-@}doloc
         .rta pr{CBM-@}dowindow
         .rta pr{CBM-@}dotab
         .rta pr{CBM-@}doclend
         .rta pr{CBM-@}docolor
         .rta pr{CBM-@}dobackgr

         sec
         rts
         .bend

pr{CBM-@}info
         .block

         #ldxy 0
         clc
         jsr setlrc
         #ldxy 0
         sec
         jsr setlrc

         ;Clear the Draw Context
         lda #" "
         jsr ctxclear

         jsr pr{CBM-@}init

         ;skip chars upto first !s or !d

         ldx sl{CBM-@}seglo
         ldy sl{CBM-@}seghi
         #stxy ptr

         #ui{CBM-@}newline
         #ui{CBM-@}newline
         ldy #0
loop
         lda (ptr),y
         bne *+5
         jmp end
         cmp #c{CBM-@}cmd
         beq cmd
         cmp #cr
         bne printchar

         sty ystore
         #ui{CBM-@}newline
         ldy ystore
         #sl{CBM-@}inc{CBM-@}y
         jmp loop
printchar
         cmp #$a0
         bne *+4
         lda #$20 ;repl. $a0 with space
         jsr ctxdraw
         inc sl{CBM-@}curcol

         #sl{CBM-@}inc{CBM-@}y
         jmp loop
cmd      ;get command code
         #sl{CBM-@}inc{CBM-@}y
         lda (ptr),y
         beq end

         cmp #"!"      ;second !
         beq printchar ;output !
         cmp #c{CBM-@}slide
         beq end
         cmp #c{CBM-@}end
         beq end

         cmp #c{CBM-@}dfield
         beq dloop
         ; process allowed command

         jsr pr{CBM-@}dohcmd
         bcs err
         jmp loop

         ;skip dfield
dloop
         #sl{CBM-@}inc{CBM-@}y
         lda (ptr),y
         beq end
         cmp #c{CBM-@}cmd
         bne dloop
         #sl{CBM-@}inc{CBM-@}y
         lda (ptr),y
         beq end
         cmp #c{CBM-@}end
         bne dloop
         #sl{CBM-@}inc{CBM-@}y
         jmp loop
end
         clc
         rts
err
         sec
         rts
         .bend

pr{CBM-@}render ;render a segment of content
         ;renders up to the next 'break'
         .block

         jsr hidemouse

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
         lda #$20 ;repl. $a0 with space
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
         #sl{CBM-@}inc{CBM-@}y    ;eat !

         lda (ptr),y  ;read cmd
         beq end

         cmp #"!"     ;second !
         beq printchr ;output !

         cmp #c{CBM-@}slide
         bne noslide ;*+6

         ;pause and wait for trigger

         sta pr{CBM-@}cmd ;set to c{CBM-@}slide
         beq pause  ;wait for trigger
noslide
         cmp #c{CBM-@}end
         bne noend

         ;we found !e; prs or field?

         ldy sl{CBM-@}infld
         beq notinfld

         ; return from field
         lda #<fldstack
         sta ptr
         lda #>fldstack
         sta ptr+1

         dey
         lda (ptr),y
         sta sl{CBM-@}seghi
         dey
         lda (ptr),y
         sta sl{CBM-@}seglo
         lda #0
         sty sl{CBM-@}infld
         jmp pr{CBM-@}render

noend
         cmp #c{CBM-@}pause ;test for !p
         bne nopause
         #sl{CBM-@}inc{CBM-@}y    ;eat p

pause
         dec sl{CBM-@}haspause
         lda #s{CBM-@}paused
         sta pr{CBM-@}state
         clc          ;set new seg ptr
         tya          ;at ptr + y
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

notinfld ; prs end
         lda #1
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

doheader
         .block
         #stxy ptr
         ldy #0
loop
         lda (ptr),y
         beq end
         cmp #c{CBM-@}cmd
         beq cmd ;*+10
         #sl{CBM-@}inc{CBM-@}y
         jmp loop
cmd      ;get command code
         #sl{CBM-@}inc{CBM-@}y

         lda (ptr),y
         beq end

         cmp #c{CBM-@}slide
         beq end
         cmp #c{CBM-@}end
         beq end

         cmp #c{CBM-@}dfield
         bne loop
         ;process dfield
         #sl{CBM-@}inc{CBM-@}y ;eat d
         jsr pr{CBM-@}dodfield
         bcs end
         jmp loop
end
         clc
         rts
err
         sec
         rts
         .bend

pr{CBM-@}start
         .block
         lda pr{CBM-@}state
         beq *+4 ;ended
         clc
         rts

;ended   ;state is ended so we can start
         ; set currrent date in pd fld

         ldy d{CBM-@}year
         ldx d{CBM-@}month
         lda d{CBM-@}day
         jsr toisodt

         #stxy ptr2

         ldx #<f{CBM-@}pd
         ldy #>f{CBM-@}pd
         #stxy ptr
         inc ptr
         inc ptr
         ldy #0
loop
         lda (ptr2),y
         beq dcend
         sta (ptr),y
         iny
         jmp loop
dcend
         lda #"!"
         sta (ptr),y
         iny
         lda #"e"
         sta (ptr),y

         ;start joystick
         lda jydriver
         bne joyon
         jsr ldjydrv
         jsr joystart
joyon
         ;do actual start slide

         lda redrawflgs
         and #(rmenubar.rstatbar):$ff
         jsr setflags

         jsr pr{CBM-@}init

         ;skip chars upto first !s or !d

         ldx sl{CBM-@}seglo
         ldy sl{CBM-@}seghi
         jsr doheader
         bcs end
doslide
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

         ldx #0
         ldy sl{CBM-@}ptrpg
         #stxy ptr

         ldy #$80      ;hi pages

         sta (ptr),y
         lda sl{CBM-@}seglo
         ldy #0        ;lo pages
         sta (ptr),y

         lda util{CBM-@}opn
         bne util
         ldy #$d8
         jsr setchrs
util
         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw

         clc           ;Msg Handled
         rts
end
         jmp pr{CBM-@}end
         .bend

pr{CBM-@}nextsl
         ;Process next slide in pres
         .block
         lda pr{CBM-@}state
         beq end
         lda sl{CBM-@}max
         bne end

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
         stx sl{CBM-@}max
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

         ;stop joystick
         lda jydriver
         beq joyoff
         lda #"2"
         jsr joystop
         jsr unldjydrv
joyoff
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

