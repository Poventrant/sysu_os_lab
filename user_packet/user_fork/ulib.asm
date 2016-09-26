; 用于生成库文件
.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
start:

; ========================================================================
; SCOPY@                               
; ========================================================================
; 实参为局部字符串带初始化异常问题的补钉程序
public SCOPY@
SCOPY@ proc 
	arg_0 = dword ptr 6
	arg_4 = dword ptr 0ah
	push bp
	mov bp,sp
	push si
	push di
	push ds
	lds si,[bp+arg_0]
	les di,[bp+arg_4]
	cld
	shr cx,1
	rep movsw
	adc cx,cx
	rep movsb
	pop ds
	pop di
	pop si
	pop bp
	retf 8
SCOPY@ endp

; ========================================================================
; int _fork()                      
; ========================================================================
public _fork
_fork proc 
	mov ah,7
	int 21h
	ret
_fork endp

; ========================================================================
; int _wait()                       
; ========================================================================
public _wait
_wait proc 
	mov ah,8
	int 21h
	ret
_wait endp

; ========================================================================
; void _exit()                       
; ========================================================================
public _exit
_exit proc 
    push bp
	mov bp,sp
	push bx
	
	mov ax, 1000h			;内核段地址
	push ax
	pop es
	push word ptr [bp+4]
	pop word ptr es:[0]
	
	xor ax, ax
	mov ah,9
	int 21h

	pop bx
	pop bp

	ret
_exit endp
; ========================================================================
;  void _GetChar()                    
; ========================================================================
public _getChar
_getChar proc
	mov ah,0
	int 16h
	ret
_getChar endp
; ========================================================================
; void _PrintChar()                       
; ========================================================================
; 字符输出
public _printChar
_printChar proc 
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	;***
	mov al,[bp+4]
	mov bl,[bp+6]
	mov ah,0eh
	int 10h
	mov sp,bp
	;***
	pop cx
	pop bx
	pop ax
	mov sp,bp
	pop bp
	ret
_printChar endp

; ========================================================================
; void _cprintf(char * info, int color);
; ========================================================================
Public	_cprintf
_cprintf proc
	push bp
	mov bp, sp
	push es 
	push ds
	push ax
	push bx
	push cx
	push dx
	push si
	mov	si, word ptr [bp+4]	;char
startCprintf:
	mov bh,0
    mov ah,3h	;读光标位置，(dh,dl) = (行，列)
    int 10h

	mov al, byte ptr [si]
	cmp al, 0Ah;回车键
	jz @@@@0
	cmp al, 0Dh;换行
	jz @@@@0
	jmp showChar0
@@@@0:
	push bx
	mov bl, 1
	mov ah,0eh
	int 10h
	pop bx
	jmp opSi

showChar0:
	push bp
	push ax
	push bx
	push cx
	
	mov ah,13h 	                    ; 功能号
	mov al,0                 		; 光标放到串尾
	mov bl, byte ptr [bp+6]			;颜色
	mov bh,0 	                	; 第0页
	mov bp, si			            ; BP=串地址
	mov cx, 1 	               		; 串长
	int 10h 
checkColOver:
	cmp dl, 79
	jnz notOverColumn

	mov al, 0Dh
	mov bl, 1
	mov ah,0eh
	int 10h
	
	pop cx
	pop bx
	pop ax
	pop bp
	jmp opSi
notOverColumn:
	add dl, 1
	pop cx
	pop bx
	pop ax
	pop bp
	
setCur:
	mov bh,0
    mov ah,2h
    int 10h
opSi:
	inc si
	cmp byte ptr [si],0
	jnz startCprintf
	
endCprintf:
	pop si
	pop dx
	pop cx
	pop bx
    pop ax
	pop ds
	pop es
	pop	bp
	ret
_cprintf endp

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start
