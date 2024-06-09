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

         lda #0
         sta opnfileref+1
         sta pr{CBM-@}bufpg
         sta pr{CBM-@}bufsz
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
         stx sl{CBM-@}col
         stx pr{CBM-@}state
         stx ystore
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

         #switch 7
         .byte c{CBM-@}slide
         .byte c{CBM-@}prevsl
         .byte c{CBM-@}loc
         .byte c{CBM-@}window
         .byte c{CBM-@}sttab
         .byte c{CBM-@}color
         .byte c{CBM-@}backgr
         .rta pr{CBM-@}doslide
         .rta pr{CBM-@}strtsl
         .rta pr{CBM-@}doloc
         .rta pr{CBM-@}dowindow
         .rta pr{CBM-@}dotab
         .rta pr{CBM-@}docolor
         .rta pr{CBM-@}dobackgr

         sec
         rts
         .bend

pr{CBM-@}doslide
         .block
         sty ystore
         inc sl{CBM-@}cur

         ; store new slide ptrs

         ldx #0
         ldy sl{CBM-@}ptrpg
         #stxy ptr

         lda sl{CBM-@}seglo
         ldy sl{CBM-@}cur  ;lo pages
         sta (ptr),y

         tya
         ora #$80 ;set bit 7 for hi
         tay
         lda sl{CBM-@}seghi
         sta (ptr),y

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
         tax
         ldy #0
         sec
         jsr setlrc
         ldy ystore
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

         ;restore theme colors

         ldx bk{CBM-@}bgcol
         ldy bk{CBM-@}bcol
         stx tkcolors+c{CBM-@}bckgnd
         sty tkcolors+c{CBM-@}border

         jsr seeioker
         stx vic{CBM-@}bgcol0
         sty vic{CBM-@}bcol
         jsr seeram

         lda redrawflgs
         ora #rmenubar
         ora #rstatbar
         jsr setflags

         lda #s{CBM-@}ended
         sta pr{CBM-@}state

         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw

         clc
         rts
         .bend

