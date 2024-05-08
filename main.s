;----[main.a - presenter ]--------------

         .include "/h/:macros.h"
         .include "//os/h/:modules.h"

         #inc{CBM-@}s "app"
         #inc{CBM-@}s "colors"
         #inc{CBM-@}s "ctxdraw"
         #inc{CBM-@}s "io"
         #inc{CBM-@}s "pointer"
         #inc{CBM-@}s "switch"
         #inc{CBM-@}s "math"

         ;Kernal Module Constants

         #inc{CBM-@}s "screen"
         #inc{CBM-@}s "service"
         #inc{CBM-@}s "memory"
         #inc{CBM-@}s "file"
         #inc{CBM-@}s "openjobs"
         #inc{CBM-@}s "string"

         *= appbase

         .include "/h/:datastr.h"

         .include "init.s"
         .include "app.s"
         .include "pres.s"

externs  ;Kernal Link Table

         #inc{CBM-@}h "screen"
markredraw #syscall lscr,markredraw{CBM-@}
layerpush #syscall lscr,layerpush{CBM-@}
setlrc   #syscall lscr,setlrc{CBM-@}
setdprops #syscall lscr,setdprops{CBM-@}
ctxclear #syscall lscr,ctxclear{CBM-@}
ctxdraw  #syscall lscr,ctxdraw{CBM-@}
ctx2scr  #syscall lscr,ctx2scr{CBM-@}

         #inc{CBM-@}h "file"
fopen    #syscall lfil,fopen{CBM-@}
fread    #syscall lfil,fread{CBM-@}
fclose   #syscall lfil,fclose{CBM-@}

         #inc{CBM-@}h "memory"
pgalloc  #syscall lmem,pgalloc{CBM-@}
pgfree   #syscall lmem,pgfree{CBM-@}

         #inc{CBM-@}h "service"
quitapp  #syscall lser,quitapp{CBM-@}
loadlib  #syscall lser,loadlib{CBM-@}
unldlib  #syscall lser,unldlib{CBM-@}
loadutil #syscall lser,loadutil{CBM-@}

         #inc{CBM-@}h "toolkit"
setctx   #syscall ltkt,setctx{CBM-@}

         #inc{CBM-@}h "string"
tolower  #syscall lstr,tolower{CBM-@}

         .byte $ff ;terminator

