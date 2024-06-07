;- datastr.h ---------------------------
;Data Structures

         .word init     ;App Initialiser
         .word msgcmd   ;Message Handler
         .word willquit ;App Clean Up
         .word willfrz  ;REU Freeze
         .word willthw  ;REU Thaw

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

;---------------------------------------
; Presentation state
;---------------------------------------

pr{CBM-@}bufpg .byte 0
pr{CBM-@}bufsz .byte 0 ;size in pages
pr{CBM-@}state .byte 0
pr{CBM-@}cmd   .byte 0
pr{CBM-@}fbfpg .byte 0 ;field defs

sl{CBM-@}cur   .byte 0
sl{CBM-@}max   .byte 0
sl{CBM-@}ptrpg .byte 0

sl{CBM-@}haspause .byte 0
sl{CBM-@}fcol  .byte 0
sl{CBM-@}bcol  .byte 0
sl{CBM-@}col   .byte 0
sl{CBM-@}row   .byte 0
sl{CBM-@}seglo .byte 0
sl{CBM-@}seghi .byte 0

bk{CBM-@}fcol  .byte 0
bk{CBM-@}bgcol .byte 0
bk{CBM-@}bcol  .byte 0

ptr      = $fb;$fc

slideptr = $fd;$fe

slidecmd .byte 0

ystore   .byte 0
dirty    .byte 1

