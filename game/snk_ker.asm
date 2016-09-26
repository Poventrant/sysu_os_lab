.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h
start:
	
	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp,  100h         ; SP指向本段高端－4
	call snk_start0   ; 调用C语言程序main1() or main2()
	jmp $

include snake.asm
_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start

