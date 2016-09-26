delay equ 4000					; 计时器延迟计数,用于控制画框的速度
ddelay equ 3000					; 计时器延迟计数,用于控制画框的速度
Dn_Rt equ 1 
Up_Rt equ 2 
Up_Lt equ 3 
Dn_Lt equ 4 
dir db 4	
org 100h					; 程序加载到100h，可用于生成COM

;初始化段寄存器
	xor ax,ax						; AX = 0
	mov ax,200
	mov es,ax					; ES = 0
	mov ds,ax					; DS = CS
	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	gs,ax					; GS = B800h
	
    mov word[count],delay
	mov word[dcount],ddelay

    mov word[x],-1
    mov word[y],80
	mov byte[rdlu], 1             ; 当前画框的方向, 1-向右,2-向下,3-向左,4-向上
    mov word[char],'B'

start:
	;jmp end_loop1
loop1:
    mov bl, byte[dir]
;=====================================================================================
DnRt:
	cmp bl, Dn_Rt
    jne UpRt
	inc word[x]
	inc word[y]
	mov bx,word[x]
	cmp bx, 12
    je  dr2ur
	mov bx,word[y]
	cmp bx, 80
    je  dr2dl
	jmp end_loop1
dr2ur:
    mov word[x],10
    mov byte[dir],Up_Rt	
    jmp end_loop1
dr2dl:
    mov word[y],78
    mov byte[dir],Dn_Lt	
    jmp end_loop1

UpRt:
	cmp bl, Up_Rt
    jne UpLt
	dec word[x]
	inc word[y]
	mov bx,word[y]
	cmp bx, 80
    je  ur2ul
	mov bx,word[x]
	cmp bx, -1
    je  ur2dr
	jmp end_loop1
ur2ul:
    mov word[y],78
    mov byte[dir],Up_Lt	
    jmp end_loop1
ur2dr:
    mov word[x],1
    mov byte[dir],Dn_Rt	
    jmp end_loop1
	
UpLt:
	cmp bl, Up_Lt
    jne DnLt
	dec word[x]
	dec word[y]
	mov bx,word[x]
	cmp bx, -1
    je  ul2dl
	mov bx,word[y]
	cmp bx, 39
    je  ul2ur
	jmp end_loop1

ul2dl:
    mov word[x],1
    mov byte[dir],Dn_Lt	
    jmp end_loop1
ul2ur:
    mov word[y],41
    mov byte[dir],Up_Rt	
    jmp end_loop1
		
DnLt:
	cmp bl, Dn_Lt
    jne end_loop1
	inc word[x]
	dec word[y]
	mov bx,word[y]
	cmp bx, 39
    je  dl2dr
	mov bx,word[x]
	cmp bx, 12
    je  dl2ul
	jmp end_loop1

dl2dr:
    mov word[y],41
    mov byte[dir],Dn_Rt	
    jmp end_loop1
	
dl2ul:
    mov word[x],10
    mov byte[dir],Up_Lt	
    jmp end_loop1
;=====================================================================================	
end_loop1:
	dec word[count]				; 递减计数变量
	jnz end_loop1					; >0：跳转; jump if not zero = jnz
	mov word[count],delay
	dec word[dcount]				; 递减计数变量
    jnz end_loop1
	mov word[count],delay
	mov word[dcount],ddelay
	jmp show

show:	
    xor ax,ax                      ; 计算当前字符的显存地址 gs:((80*x+y)*2)
    mov ax,word[x]
	mov bx,80                  ; (80*x
	mul bx
	add ax,word[y]             ; (80*x+y)
	mov bx,2
	mul bx                     ; ((80*x+y)*2)
	mov bp,ax
	mov ah,0bh		   ; 0000：黑底、1111：亮白字（默认值为07h）
	mov al,byte[char]	   ; AL = 显示字符值（默认值为20h=空格符）
	mov word[gs:bp],ax  	   ;   显示字符的ASCII码值
	jmp loop1
datadef:
	count dw delay				; 计时器计数变量，初值=delay
	dcount dw ddelay				; 计时器计数变量，初值=delay
	x dw 0                      ; 当前字符显示位置的行号,0~24
	y dw 0                      ; 当前字符显示位置的列号,0~79
	rdlu db 1                   ; 当前画框的方向, 1-向右,2-向下,3-向左,4-向上
	char db 'B'                 ; 当前显示字符
	
times 512-($-$$) db 0 ; $=当前地址、$$=当前节地址
