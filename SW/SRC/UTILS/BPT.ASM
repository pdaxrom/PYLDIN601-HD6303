                .ifdef  NATIVE
                include \DEV\DEVMAP.INC
                .else
                include ../../DEVMAP.INC
                .endif

swic            equ     $2C             ; променливи използвани от interrupt
swib            equ     $2D             ; драйверите за предаване на регистрите
swia            equ     $2E             ; A, B, X и флаговете C и V; достъпни
swix            equ     $2F             ; за interrupt драйверите само

                ldx     #hello
                int     $23

                ldaa    #$f7
                clrb
                ldx     #bpthandler
                int     $2f
                rts

bpthandler      proc
                pshx
                ldx     #regstr
                bsr     putstr
                pulx
                ldaa    swic
                bsr     puthex
                bsr     putspc
                ldaa    swia
                bsr     puthex
                bsr     putspc
                ldaa    swib
                bsr     puthex
                bsr     putspc
                ldaa    swix
                bsr     puthex
                ldaa    swix+1
                bsr     puthex
                bsr     putspc
                tsx
                xgdx
                addd    #9
                bsr     puthex
                tba
                bsr     puthex
                bsr     putspc
                tsx
                ldx     8,x
                xgdx
                bsr     puthex
                tba
                bsr     puthex
                bsr     putcrlf
                rts
regstr          db      10, 13, "C_ A_ B_ X___ SP__ PC__", 10, 13, 0
                endp

putstr          proc
                psha
                pshx
loop            ldaa    0,x
                beq     exit
                bsr     putchar
                inx
                bra     loop
exit            pulx
                pula
                rts
                endp

putspc          proc
                psha
                ldaa    #' '
                bsr     putchar
                pula
                rts
                endp

putcrlf         proc
                psha
                ldaa    #10
                bsr     putchar
                ldaa    #13
                bsr     putchar
                pula
                rts
                endp

puthex          proc
prhex2          psha
                lsra
                lsra
                lsra
                lsra
                bsr     prhex1
                pula
prhex1          anda    #$f
                oraa    #$30
                cmpa    #$3a
                bcs     prhexz
                adda    #7
prhexz          bsr     putchar
                rts
                endp

putchar         proc
                int     $22
                rts
                endp

hello           db      10, "Breakpoint INT $F7 installed!", 10, 0



