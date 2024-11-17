;----[ main.a - presenter ]-------------

         .include "/h/:macros.h"
         .include "//os/h/:modules.h"

         #inc{CBM-@}s "app"
         #inc{CBM-@}s "colors"
         #inc{CBM-@}s "ctxcolors"
         #inc{CBM-@}s "ctxdraw"
         #inc{CBM-@}s "io"
         #inc{CBM-@}s "pointer"
         #inc{CBM-@}s "switch"
         #inc{CBM-@}s "math"
         #inc{CBM-@}s "io{CBM-@}joy"

         ;Kernal Module Constants

         #inc{CBM-@}s "screen"
         #inc{CBM-@}s "service"
         #inc{CBM-@}s "memory"
         #inc{CBM-@}s "file"
         #inc{CBM-@}s "openjobs"
         #inc{CBM-@}s "string"
         #inc{CBM-@}s "input"
         #inc{CBM-@}s "timers"

         *= appbase

         .include "/h/:datastr.h"

         .include "init.s"
         .include "app.s"
         .include "pres.s"

externs  ;Kernal Link Table

         ;#inc{CBM-@}h "screen"
markredraw #syscall $f6,$03
layerpush #syscall $f6,$06
setlrc   #syscall $f6,$0c
setdprops #syscall $f6,$0f
ctxclear #syscall $f6,$12
ctxdraw  #syscall $f6,$15
ctx2scr  #syscall $f6,$18

         ;#inc{CBM-@}h "file"
fopen    #syscall $f0,$06
fread    #syscall $f0,$09
fclose   #syscall $f0,$0f
frefcvt  #syscall $f0,$12

         ;#inc{CBM-@}h "memory"
pgalloc  #syscall $fe,$15
pgfree   #syscall $fe,$0f
memcpy   #syscall $fe,$00

         ;#inc{CBM-@}h "service"
quitapp  #syscall $f2,$21
loadlib  #syscall $f2,$2a
unldlib  #syscall $f2,$2d
loadutil #syscall $f2,$1e
setflags #syscall $f2,$0c
getsfref #syscall $f2,$15
loadreloc #syscall $f2,$27

         ;#inc{CBM-@}h "toolkit"
setctx   #syscall $ee,$06

         ;#inc{CBM-@}h "string"
tolower  #syscall $fa,$0f

         ;#inc{CBM-@}h "math"
tostr    #syscall $f8,$06

         ;#inc{CBM-@}h "input"
hidemouse #syscall $fc,$06

         ;#inc{CBM-@}h "timers"
timeque  #syscall $ec,$00

         .byte $ff ;terminator

