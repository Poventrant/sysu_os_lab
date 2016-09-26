org  7e00h	    ; 加载到0:7e00h处，并开始执行
delay equ 50000					; 计时器延迟计数,用于控制画框的速度
ddelay equ 40000					; 计时器延迟计数,用于控制画框的速度

START:
	mov ax,cs		; 设置 DS和ES = CS
	mov ds,ax
	mov es,ax
	call clr     ; 清屏
	call showstr	; 显示字符串
	jmp loop1
return:	ret 

showstr: 
	mov ah,13h 	    ; 功能号
	mov al,1 		; 光标放到串尾
	mov bl,0eh 	    ; 黑底红字
	mov bh,0 		; 第0页
	mov dh,05h 	    ; 第5行
	mov dl,1ch 	    ; 第28列
	mov bp,str1 	; BP=串地址
	mov cx,len1	; 串长为len1
	int 10h 		; 调用10H号中断
	ret

loop1:
	dec word[count]				; 递减计数变量
	jnz loop1					; >0：跳转; jump if not zero = jnz
	mov word[count],delay
	dec word[dcount]				; 递减计数变量
    jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay
	jmp return 
	
clr: 
    mov ax,0003H    ; 清屏属性
    int 10H         ; 调用中断
	ret 

	str1: db "Pro 3~~~, please press Esc to continue."
	len1: equ ($-str1)
datadef:
	count dw delay
	dcount dw ddelay
times 512-($-$$) db 0 ; 用0填充扇区的剩余部分