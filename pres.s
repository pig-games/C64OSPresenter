;- pres.s ------------------------------


; Constants

strcolor .byte clblue

cr       = $0d ;Cariage return
c{CBM-@}newsl  = "!" ;New Slide
c{CBM-@}pause  = "," ;Pause output
c{CBM-@}end    = "." ;End marker

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
         stx sl{CBM-@}lopg
         stx sl{CBM-@}seglo
         sty sl{CBM-@}hipg
         sty sl{CBM-@}seghi

         stx sl{CBM-@}curr
         stx sl{CBM-@}row
         stx sl{CBM-@}row+1
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

pr{CBM-@}clr
         .block
         sty ystore

         ldx #0
         stx sl{CBM-@}row
         stx sl{CBM-@}row+1

         #rdxy sl{CBM-@}row
         clc
         jsr setlrc
         #ldxy 0
         sec
         jsr setlrc

         ;Clear the Draw Context
         lda #" "
         jsr ctxclear

         ldy ystore

         rts
         .bend

pr{CBM-@}render ;render a segment of content
         ;renders up to the next 'break'
         .block

         ldx sl{CBM-@}seglo
         ldy sl{CBM-@}seghi
         #stxy ptr

         ldy #0

loop     lda (ptr),y
         beq end

         cmp #c{CBM-@}newsl
         bne tst{CBM-@}cr
         ;process newslide
         jsr pr{CBM-@}clr

         jmp next
tst{CBM-@}cr
         cmp #cr
         bne printchr
docr
         sty ystore
         #ui{CBM-@}newline
         ldy ystore

         ; now check for command code
         iny
         bne *+4
         inc ptr+1

         lda (ptr),y
         beq end

         cmp #cr ;if another cr go again
         beq docr

         cmp #c{CBM-@}newsl ;test for newslide
         beq pause ;only need pause

notnewsl
         cmp #c{CBM-@}pause
         bne notpause

         iny
         bne pause
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
notpause
         cmp #c{CBM-@}end
         beq end

printchr
         jsr ctxdraw

next     iny
         bne loop
nextpg   inc ptr+1
         bne loop

end
         ldx #0
         ldy pr{CBM-@}bufpg
         #stxy sl{CBM-@}seglo

         lda #s{CBM-@}ended
         sta pr{CBM-@}state
         rts
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

