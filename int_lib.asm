; �������ɿ��ļ�
.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
start:

public _OUCH_21H
_OUCH_21H proc 
    push ax
    push bx
    push cx
    push dx
	push es

	mov ax,0003h
    int 10h                          ; ����

	mov ah,0
    int 21h
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_OUCH_21H endp


public _L2U_21H
_L2U_21H proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; ����ַ����׵�ַ

    push ax
    push bx
    push cx
    push dx
	push es

	mov ah,1
	mov dx,si                        ; ���ַ����׵�ַ�� dx 
    int 21h
   
	pop es
	pop dx
	pop cx
	pop bx
	pop ax

	pop si
	pop bp
	ret
_L2U_21H endp


public _U2L_21H
_U2L_21H proc 
    push bp
	mov	bp,sp
	push si
	mov	si,word ptr [bp+4]           ; ����ַ����׵�ַ

    push ax
    push bx
    push cx
    push dx
	push es

	mov ah,2
	mov dx,si                        ; ���ַ����׵�ַ�� dx 
    int 21h
   
	pop es
	pop dx
	pop cx
	pop bx
	pop ax

	pop si
	pop bp
	ret
_U2L_21H endp


public _A2I_21H
_A2I_21H proc 
    push bp
	mov	bp,sp
	push si
    push bx
    push cx
    push dx
	push es

	mov	si,word ptr [bp+4]           ; ����ַ����׵�ַ
	mov ah,3
	mov dx,si                        ; ���ַ����׵�ַ�� dx 
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop si
	pop bp
	ret
_A2I_21H endp


public _I2A_21H
_I2A_21H proc 
    push bp
	mov	bp,sp
	push si
    push bx
    push cx
    push dx
	push es

	mov	si,word ptr [bp+4]           ; ����ַ����׵�ַ
	mov dx,si                        ; ���ַ����׵�ַ�� dx 
	mov bx, word ptr[bp+6]			 ;����int
	mov ah,4	
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop si
	pop bp
	ret
_I2A_21H endp


public _DSP_21H
_DSP_21H proc 
    push bp
	mov	bp,sp
	push si
	push ax
    push bx
    push cx
    push dx
	push es

	mov	si,word ptr [bp+4]           ; ����ַ����׵�ַ
	mov dx,si                        ; ���ַ����׵�ַ�� dx 
	xor bx,bx
	mov bx, word ptr [bp+6]			 ;����hang
	mov ch, bl						;����hang
	xor bx,bx
	mov bx, word ptr [bp+8]
	mov cl, bl							;��
	xor bx,bx
	mov bx, word ptr [bp+10]			;����
	mov ah,5	
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop si
	pop bp
	ret
_DSP_21H endp


public _LEN_21H
_LEN_21H proc 
    push bp
	mov	bp,sp
	push si
    push bx
    push cx
    push dx
	push es

	mov	si,word ptr [bp+4]           ; ����ַ����׵�ַ
	mov ah,6
	mov dx,si                        ; ���ַ����׵�ַ�� dx 
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop si
	pop bp
	ret
_LEN_21H endp


_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start
