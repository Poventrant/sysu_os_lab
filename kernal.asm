global  _cmain        ; 声明一个c程序函数cmain()

.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h
start:
	call setIntFunc
	call setint21
	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp,  100h   
	call near ptr _cmain   ; 调用C语言程序cmain()
	jmp $
	
include search.asm
include fileop.asm
include kliba.asm  
include setint.asm   
include timer.asm 
include intfunc.asm
includelib user_lib.lib
_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start