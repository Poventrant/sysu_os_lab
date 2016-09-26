extrn _timech:near
; �������ɿ��ļ�
.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
start:

; ========================================================================
; SCOPY@                               
; ========================================================================
; ʵ��Ϊ�ֲ��ַ�������ʼ���쳣����Ĳ�������
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

	mov byte ptr[_timech],  ch       ; ���λ
	mov byte ptr[_timech+1],cl       ; ���λ
	mov byte ptr[_timech+2],dh       ; ��
	mov byte ptr[_timech+3],dl       ; ��
	
	xor cx,cx
	xor dx,dx
    mov ah,2h
    int 1ah
	
	mov byte ptr[_timech+4],ch       ; ʱ
	mov byte ptr[_timech+5],cl       ; ��
	mov byte ptr[_timech+6],dh       ; ��
	
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