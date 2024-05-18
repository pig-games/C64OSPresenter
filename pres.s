;- pres.s ------------------------------


; Constants

strcolor .byte clblue

cr       = $0d ;Cariage return
c{CBM-@}cmd    = "!" ;Command
c{CBM-@}slide  = "S" ;Slide start
c{CBM-@}pause  = "P" ;Pause output
c{CBM-@}loc    = "L" ;Change location
c{CBM-@}color  = "C" ;Set color
c{CBM-@}backgr = "B" ;Set background color
c{CBM-@}end    = "E" ;End

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

         stx sl{CBM-@}curr
         stx sl{CBM-@}row
         stx pr{CBM-@}state
         stx ystore

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
         iny
         bne *+4
         inc ptr+1
         lda (ptr),y
         sec
         sbc #48
         clc
         adc ystore
         iny
         bne *+4
         inc ptr+1
         rts
         .bend

pr{CBM-@}docmd
         .block
         iny
         bne *+4
         inc ptr+1

         #switch 4
         .byte c{CBM-@}slide
         .byte c{CBM-@}loc
         .byte c{CBM-@}color
         .byte c{CBM-@}backgr
         .rta pr{CBM-@}doslide
         .rta pr{CBM-@}doloc
         .rta pr{CBM-@}docolor
         .rta pr{CBM-@}dobackgr

         sec
         rts
         .bend

pr{CBM-@}doslide
pr{CBM-@}dobackgr
         .block
         sty ystore

         ldx #0
         stx sl{CBM-@}row

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
         ;Set Draws Properties and Color
         ldx #d{CBM-@}crsr{CBM-@}h.d{CBM-@}petscr
         tay
         jsr setdprops

         ldy ystore

         clc
         rts
         .bend

pr{CBM-@}doloc
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

         lda pr{CBM-@}command
         beq loop

         sty pr{CBM-@}command
         jsr pr{CBM-@}docmd
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

         lda #s{CBM-@}ended
         sta pr{CBM-@}state
         rts

docmd
         ; get command code
         iny
         bne *+4
         inc ptr+1

         lda (ptr),y
         beq end

         cmp #"!"
         beq printchr

         cmp #c{CBM-@}slide
         bne noslide

         sta pr{CBM-@}command
         beq pause
noslide
         cmp #c{CBM-@}pause
         bne nopause

         iny
         bne *+4
         inc ptr+1
pause
         clc
         tya
         adc ptr
         sta sl{CBM-@}seglo
         lda #0
         adc ptr+1
         sta sl{CBM-@}seghi

         lda #s{CBM-@}paused
         sta pr{CBM-@}state

         rts
nopause
         jsr pr{CBM-@}docmd
         bcs end
         jmp loop

         .bend

pr{CBM-@}start
pr{CBM-@}prevsl
pr{CBM-@}nextsl
pr{CBM-@}end
         ;Process next slide in pres
         ;slidecmd -> current command
         .block

         lda #s{CBM-@}render
         sta pr{CBM-@}state

         #pr{CBM-@}st{CBM-@}dirty
         #ui{CBM-@}mkredraw

         clc ;Msg Handled
         rts
         .bend

