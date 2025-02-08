;- datastr.h ---------------------------
;Data Structures

         .word init     ;App Initialiser
         .word msgcmd   ;Message Handler
         .word willquit ;App Clean Up
         .word willfrz  ;REU Freeze
         .word didthw   ;REU Thaw

layer    .word drawmain
         .word sec{CBM-@}rts
         .word sec{CBM-@}rts
         .word sec{CBM-@}rts
         .byte 0

drawctx  .word 0
         .word 0
         .byte screen{CBM-@}cols
         .byte screen{CBM-@}cols
         .byte screen{CBM-@}rows
         .word 0
         .word 0

openfrpg .byte 0

chrsbkpg .byte 0

jydriver .byte 0
jdrvpgbk .byte 0
jyold    .byte 0
util{CBM-@}opn .byte 0


;---------------------------------------
; Presentation state
;---------------------------------------

pr{CBM-@}bufpg .byte 0
pr{CBM-@}bufsz .byte 0 ;size in pages
pr{CBM-@}prslo .byte 0
pr{CBM-@}prshi .byte 0
pr{CBM-@}state .byte 0
pr{CBM-@}cmd   .byte 0
pr{CBM-@}fdpg  .byte 0 ;field defs
pr{CBM-@}tplpg .byte 0 ;buf for template file
pr{CBM-@}tplsz .byte 0

sl{CBM-@}cur   .byte 0
sl{CBM-@}max   .byte 0
sl{CBM-@}ptrpg .byte 0

sl{CBM-@}haspause .byte 0
sl{CBM-@}fcol  .byte 0
sl{CBM-@}bcol  .byte 0
sl{CBM-@}bgcol .byte 0
sl{CBM-@}curcol .byte 0
sl{CBM-@}col   .byte 0
sl{CBM-@}row   .byte 0
sl{CBM-@}seglo .byte 0
sl{CBM-@}seghi .byte 0
sl{CBM-@}infld .byte 0

bk{CBM-@}fcol  .byte 0
bk{CBM-@}bgcol .byte 0
bk{CBM-@}bcol  .byte 0

ptr      = $fb;$fc

ptr2     = $fd;$fe

slidecmd .byte 0

labelbuf .word 0
fldstack .word 0,0,0,0,0,0,0,0

ystore   .byte 0
dirty    .byte 1

f{CBM-@}pv     .text "pv0.9.4!e"
f{CBM-@}pd     .text "pdyyyy-mm-dd!e"
f{CBM-@}pf     .text "pf{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}{CBM-@}!e"
f{CBM-@}sn     .text "sn0!e  "

d{CBM-@}year   = $03b3
d{CBM-@}month  = $03b4
d{CBM-@}day    = $03b5

