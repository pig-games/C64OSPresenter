;- datastr.h ---------------------------
;Data Structures

         .word init     ;App Initialiser
         .word msgcmd   ;Message Handler
         .word willquit ;App Clean Up
         .word raw{CBM-@}rts  ;REU Freeze
         .word raw{CBM-@}rts  ;REU Thaw

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

sl{CBM-@}curr  .byte 0
sl{CBM-@}lopg  .byte 0
sl{CBM-@}hipg  .byte 0

sl{CBM-@}row   .byte 0
sl{CBM-@}seglo .byte 0
sl{CBM-@}seghi .byte 0

ptr      = $fb;$fc

slideptr = $fd;$fe

slidecmd .byte 0

ystore   .byte 0
dirty    .byte 1

