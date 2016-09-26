extrn _timech:near
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

public _gettime
_gettime proc 
    push ax
    push bx
    push cx
    push dx		
		
	mov ah,4h
    int 1ah

	mov byte ptr[_timech],  ch       ; 年高位
	mov byte ptr[_timech+1],cl       ; 年低位
	mov byte ptr[_timech+2],dh       ; 月
	mov byte ptr[_timech+3],dl       ; 日
	
	xor cx,cx
	xor dx,dx
    mov ah,2h
    int 1ah
	
	mov byte ptr[_timech+4],ch       ; 时
	mov byte ptr[_timech+5],cl       ; 分
	mov byte ptr[_timech+6],dh       ; 秒
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_gettime endp

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start