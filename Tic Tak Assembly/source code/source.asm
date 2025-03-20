include irvine32.inc
include macros.inc

datasize = 300

.data
board dd " "," "," " , " "," "," ",  " "," "," "
player1x    dd     "X"
player2o    dd     "O"
pturn       dd      0
checkempty  dd      ?

;winning variables
winx        dd      ?
winY        dd      ?

;winnig check variables
a           dd      ?
b           dd      ?

;file handling variables
filename    byte    "aboutus.txt"
handler     dd      ?

str0        byte    "           code written by        "  
str1        byte    "NAMES: Haider khan"
str2        byte    "Roll no xxx"
str3        byte    "THANKS FOR PLAYING.............."
buffer byte datasize dup(?)

newline     byte    0dh, 0ah, 0

lstr0       dd      lengthof str0
lstr1       dd      lengthof str1
lstr2       dd      lengthof str2
lstr3       dd      lengthof str3

choice      dd      ?
choice1     dd      ?

.code
menu proc
    mwrite "        WELCOME TO TIK TACK TOE GAME     "
    call crlf
    call crlf
    mwrite "                 PLAY                      "
    call crlf
    call crlf
    mwrite "               About us                    "
    call crlf
    call crlf
    mwrite "                 EXIT                      "
ret
menu endp

write proc
    mov edx,offset filename
	call createoutputfile
	mov handler,eax

    ;write to file
    mov eax,handler
	mov ecx,lstr0
	mov edx,offset str0
	call writetofile

    mov eax,handler 			
    mov edx,offset newline 			
    mov ecx,2 			
    call writetofile

	;write names to file
	mov eax,handler
	mov ecx,lstr1
	mov edx,offset str1
	call writetofile

    mov eax,handler 			
    mov edx,offset newline 			
    mov ecx,2 			
    call writetofile

	;Writing to file
	mov eax,handler
	mov ecx,lstr2
	mov edx,offset str2
	call writetofile

    mov eax,handler 			
    mov edx,offset newline 			
    mov ecx,2 			
    call writetofile

	;Writing to file
	mov eax,handler
	mov ecx,lstr3
	mov edx,offset str3
	call writetofile

	call closefile
ret 
write endp

read proc
    mov eax,0
    mov edx,offset filename
	call openinputfile
	mov handler,eax

	mov edx,offset buffer
	mov ecx,datasize
	call readfromfile
	mov lstr3,eax

	mov edx,offset buffer
	mov ecx,lstr3
	call writestring

    call crlf
ret 
read endp

main proc

starting:
call clrscr
call menu
call crlf
call crlf

    mwrite "choose from menu: "
    call readint
    mov choice , eax
    .if choice == 1
gameloop:
    call clrscr
    call displayboard
    mov eax,pturn

    .if eax == 0
    p1:
	    call player1
        call checkwinX
    .if winx == 1
        call clrscr
        call displayboard
        call p1wins
        jmp ending
     .endif
    .elseif eax == 1
    p2:
	    call player2  
        call checkwinY
    .if winY == 1
        call clrscr
        call displayboard
        call p2wins
        jmp ending
    .endif
    .else
	    mwrite "Invalid move"
	    cmp pturn,0
	    je p1
	    jne p2
    .endif

    call emptyornot

    .if checkempty == 1
        mov checkempty,0
        jmp gameloop
    .else
        call clrscr
        call displayboard
        mwrite "no empty place left.."
        call crlf
    .endif

.elseif choice == 2
    call clrscr
    call read

    mwrite "Press any key to continue:"
    call readint

.else
    jmp ending
.endif
    jmp starting
ending:
    call crlf
    mwrite "Game exited successfully....."
exit
main endp

displayboard proc

call crlf 

mwrite "                        "
mwrite "-------------"
call crlf

mov ecx,3
mov edx,offset board
rows:
mov a,ecx

mov ecx,3
mwrite "                        "
mwrite "| "
columns:
call writestring
add edx,4
mwrite " | "

loop columns
call crlf


mov ecx,a
mwrite "                        "
mwrite "-------------"
call crlf

loop rows
ret
displayboard endp


player1 proc
    mwrite "Player 1, choose a position (1-9) to place X: "
    call readint
    sub eax, 1
    
    mov edx,offset board
    mov ebx,4
    imul ebx,eax
    add edx, ebx
    mov eax, [edx]
    cmp eax, ' '
    jne invalidMove
    mov byte ptr [edx], 'X'
    mov pturn,1
    jmp ending
invalidMove:
    mwrite "Invalid move. Try again."
    call player1
    ending:
    call displayboard
    ret
player1 endp


player2 proc
    mwrite "Player 2, choose a position (1-9) to place O: "
    call readint
    sub eax, 1
    
    mov edx,offset board
    mov ebx,4
    imul ebx,eax
    add edx, ebx
    mov eax, [edx]
    cmp eax, ' '
    jne invalidMove
    mov byte ptr [edx], 'O'
    mov pturn,0
    jmp ending
invalidMove:
    mwrite "Invalid move. Try again."
    call player2
    ending:
    call displayboard
    ret
player2 endp

emptyornot proc
    mov edx,offset board
    mov ecx,9
    check:
    mov eax,[edx]
    add edx,4
    .if eax == ' '
        mov checkempty,1
    .else
        mov checkempty,0
    .endif
    loop check
    done:
        ;call displayboard
    ret
emptyornot endp

checkwinX proc
;for first line = x checking win
    mov edx,offset board
    mov ecx,2
    mov eax,[edx]
    mov a,eax
    mov eax,[edx+4]
    mov b,eax
    mov eax,[edx+8]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif
;for line2 check x
    mov eax,[edx+12]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+20]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif

;for line3 check x
    mov eax,[edx+24]
    mov a,eax
    mov eax,[edx+28]
    mov b,eax
    mov eax,[edx+32]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif

;for verticals line1 check x
    mov eax,[edx]
    mov a,eax
    mov eax,[edx+12]
    mov b,eax
    mov eax,[edx+24]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif

;for verticals line2 check x
    mov eax,[edx+4]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+28]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif

;for verticals line3 check x
    mov eax,[edx+8]
    mov a,eax
    mov eax,[edx+20]
    mov b,eax
    mov eax,[edx+32]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif

;for cross line1 check x
    mov eax,[edx]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+32]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif

;for cross line1 check x
    mov eax,[edx+8]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+24]
    .if a == 'X' && b == 'X' && eax == 'X'
        mov winx,1
        jmp ending
    .endif
ending:
ret
checkwinX endp

checkwinY proc
;for first line = O checking win
    mov edx,offset board
    mov eax,[edx]
    mov a,eax
    mov eax,[edx+4]
    mov b,eax
    mov eax,[edx+8]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif
;for line2 check O
    mov eax,[edx+12]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+20]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif

;for line3 check O
    mov eax,[edx+24]
    mov a,eax
    mov eax,[edx+28]
    mov b,eax
    mov eax,[edx+32]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif

;for verticals line1 check O
    mov eax,[edx]
    mov a,eax
    mov eax,[edx+12]
    mov b,eax
    mov eax,[edx+24]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif

;for verticals line2 check O
    mov eax,[edx+4]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+28]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif

;for verticals line3 check O
    mov eax,[edx+8]
    mov a,eax
    mov eax,[edx+20]
    mov b,eax
    mov eax,[edx+32]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif

;for cross line1 check O
    mov eax,[edx]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+32]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif

;for cross line1 check O
    mov eax,[edx+8]
    mov a,eax
    mov eax,[edx+16]
    mov b,eax
    mov eax,[edx+24]
    .if a == 'O' && b == 'O' && eax == 'O'
        mov winY,1
        jmp ending
    .endif
ending:
ret
checkwinY endp

p1wins proc
call crlf
    mwrite "Player1 wins."
    call crlf
ret
p1wins endp

p2wins proc
call crlf
    mwrite "Player2 wins."
    call crlf
ret
p2wins endp

end main
