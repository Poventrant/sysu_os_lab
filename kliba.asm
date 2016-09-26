;全局变量
extrn _timech:near 

; ========================================================================
; SCOPY@                               
; ========================================================================
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
;  void _clr()                    
; ========================================================================
public _clr
_clr proc 
		mov ax,0003H
		int	10h	
		ret
_clr endp

; ========================================================================
; void _PrintChar()                    
; ========================================================================
public _printChar
_printChar proc 
	push bp
		mov bp,sp
		mov al,[bp+4]
		mov bl,0
		mov ah,0eh
		int 10h
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
	mov ax, cs
	mov es, ax
	mov ds, ax
	
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
;   void backspace();
; ========================================================================
public _backspace
_backspace proc 
    push ax
    push bx
    push cx
    push dx			
	;读光标位置，(dh,dl) = (行，列)
	mov bh,0
    mov ah,3h
    int 10h

	add dl,-1
    ;设置光标位置(dh,dl) = (行，列)
    mov bh,0
    mov ah,2h
    int 10h

    mov al,' '
	mov bl,1
	mov ah,0eh
	int 10h
    ;设置光标位置(dh,dl) = (行，列)
    mov bh,0
    mov ah,2h
    int 10h

	pop dx
	pop cx
	pop bx
	pop ax
	ret
_backspace endp

; ========================================================================
;  void _gettime()                       
; ========================================================================
; 获取time
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

; ========================================================================
;  void _exe()                       
; ========================================================================
public _exe
_exe proc 
   	push bp
	mov	bp,sp
    push ax
    push bx
    push cx
    push dx
	push es
	push ds
	call setint9						;设置int9键盘中断

	mov bx,7e00h
	call bx
	
	call resetint9			;回复INT9键盘中断
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
_exe endp
; ========================================================================
;  void _Process(int seg, int start)                       
; ========================================================================
public _Process 
_Process proc
	push bp
	mov bp, sp  
	push ax

	mov ax,word ptr [bp+4]      ; 段地址
	mov es,ax                   ; 设置段地址
	mov bx,100h                 ; 段间偏移地址
	mov ah,2                    ; 功能号
	mov al,byte ptr [bp+12]                    ; 扇区数 
	mov dl,0                    ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,byte ptr [bp+8]                    ; 磁头号，起始编号为0，磁盘的第几面（0 或 1）两面用完就下一个磁道
	mov ch,byte ptr [bp+10]                    ; 柱面号， 起始编号为0，磁盘的第几道
	mov cl,byte ptr [bp+6]               ; 起始扇区号，起始编号为1
	int 13H 				    ; BIOS的13h功能调用

	pop ax
	pop bp
	ret
_Process endp

; ========================================================================
;  void _intCall()                       
; ========================================================================
public _intCall
_intCall proc 
    push ax
    push bx
    push cx
    push dx
	push es
	
	mov ax,0003h
    int 10h                          ; 清屏

    int 33h
	int 34h
	int 35h
	int 36h

	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_intCall endp

; ========================================================================
;   void _stackCopy(int sub_ss,int f_ss, int size); 复制内存的数据
; ========================================================================
public _stackCopy
_stackCopy proc
	push bp
	mov bp, sp
	push ax
	push es
	push ds
	push di
	push si
	push cx

	mov ax,word ptr [bp+4]                ; 子进程 ss
	mov es,ax
	mov di, 0
	mov ax,word ptr [bp+6]               ; 父进程 ss
	mov ds, ax
	mov si, 0
	mov cx, word ptr [bp+8]               ; 循环CX次赋值给ES:DI
copyloop:
	push word ptr ds:[si]
	pop word ptr es:[di]
	add di, 2
	add si, 2
	loop copyloop

	pop cx
	pop si
	pop di
	pop ds
	pop es
	pop ax
	pop bp
	ret
_stackCopy endp
; ========================================================================
;  void _menu()                       
; ========================================================================
public _menu
_menu proc
	push ax
    push bx
    push cx
    push dx
	push es
	push bp
	
    mov ah,13h 	                    ; 功能号
	mov al,0                 		; 光标放到串尾
	mov bl, 71h
	mov bh,0 	                	; 第0页
	mov dh,0				 	    ; 行
	mov dl,2					    ; 列
	mov bp, offset menuchar         ; BP=串地址
	mov cx, 322 	                ; 串长
	int 10h 
	
	pop bp
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_menu endp
;=============================================================================================================================================================
;=============================================================================================================================================================
menuchar:
		db 0ah,0dh
		db"                 ---------13349086 Pang wenquan-----------                    "
		db 0ah,0dh
		db"       1.exe          2.time          3.int           4.21h           5.asc   "
		db 0ah,0dh
		db"       6.info         7.clr           8.hlt           9.run           10.fork "
		db 0ah,0dh
		db"       11.semaphore                                                           "
		db 0ah,0dh,'$'