setIntFunc:
	push ax
	push es
	
	call setTimer
	xor ax,ax				        		        ; AX = 0
	mov es,ax					                    ; ES = 0
	mov word ptr es:[20h],offset Timer		        ; int 8H定时器
	mov ax, cs
	mov word ptr es:[22h],ax
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[51*4],offset intmsg1		;33h
	mov ax, cs
	mov word ptr es:[51*4+2],ax

	xor ax,ax
	mov es,ax
	mov word ptr es:[52*4],offset intmsg2		; 34h
	mov ax, cs
	mov word ptr es:[52*4+2],ax

	xor ax,ax
	mov es,ax
	mov word ptr es:[53*4],offset intmsg3		; 35h
	mov ax, cs
	mov word ptr es:[53*4+2],ax

	xor ax,ax
	mov es,ax
	mov word ptr es:[54*4],offset intmsg4		; 36h
	mov ax, cs
	mov word ptr es:[54*4+2],ax
	
	pop ax
	mov es,ax
	pop ax
ret

setint21:
	push ax
	push es
	push ds
	
	mov ax, cs
	mov es, ax
	mov ds, ax
	push word ptr es:[84h]                  ; 重设9h 
	pop word ptr ds:[4]
	push word ptr es:[86h]
	pop word ptr ds:[6]
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[84h],offset user_21h		;21h
	mov ax, cs
	mov word ptr es:[86h],ax
	
	pop ax
	mov ds, ax
	pop ax
	mov es,ax
	pop ax
	ret
	
resetint21:
	push ax
	push es
	push ds
	
	mov ax, cs
	mov es, ax
	mov ds, ax
	push word ptr es:[4]                  ; 重设9h 
	pop word ptr ds:[84h]
	push word ptr es:[6]
	pop word ptr ds:[86h]
	
	pop ax
	mov ds, ax
	pop ax
	mov es,ax
	pop ax
	ret
	
setint9:	
	push ax
	push es
	xor ax,ax
	mov es,ax
	push word ptr es:[9*4]                  ; 重设9h 
	pop word ptr ds:[0]
	push word ptr es:[9*4+2]
	pop word ptr ds:[2]

	mov word ptr es:[24h],offset ouch_key		; 设置键盘中断向量的偏移地址9h
	mov ax,cs 
	mov word ptr es:[26h],ax
	pop ax
	mov es,ax
	pop ax
ret
	
resetint9:
	push ax
	push es
	xor ax,ax
	mov es,ax
	push word ptr ds:[0]                     ; 恢复
	pop word ptr es:[9*4]
	push word ptr ds:[2]
	pop word ptr es:[9*4+2]
	int 9h										;键盘中断
	pop ax
	mov es,ax
	pop ax
ret