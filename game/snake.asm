extrn _row:near  
extrn _column:near 
extrn _radomPos:near
extrn _itoa:near

snk_start0: 
	call showWall 
	
	push ax
	push ds
	mov ax, offset info
	mov ds, ax
	
	mov al,2 
	mov byte ptr ds:[bx],al        ;初始方向向右 
	
	pop ax
	mov ds, ax
	pop ax
	
	call initSnk 
	call randPosition 
	
snkGo:         
	call showFood 
	call snkRear
	call snkHead 
	call snkDelay 
	 
	mov al,0 	
	mov ah,1
	int 16h 			;检测键盘状态
	jnz snkGoon
	mov ax,0ffh
	stc
	jmp snkGo 
snkGoon: 
	mov ah, 00h 
	int 16h

	cmp ah,4bh        ;按键为左箭头 
	jz left_pressed 

	cmp ah,4dh        ;按键为右箭头 
	jz right_pressed 

	cmp ah,48h        ;按键为上箭头 
	jz up_pressed 

	cmp ah,50h        ;按键为下箭头 
	jz down_pressed 

	cmp al,1bh        ;按键为ESC 
	jz esc_pressed 
	jmp snkGo 
	
left_pressed: 
	push ax
	push ds
	mov ax, offset info
	mov ds, ax
	
	mov al,1 
	mov bx,1 
	mov byte ptr ds:[bx],al        ;方向改为向左
	
	pop ax
	mov ds, ax
	pop ax
	jmp snkGo 

right_pressed: 
	push ax
	push ds
	mov ax, offset info
	mov ds, ax
	
	mov al,2 
	mov bx,1 
	mov byte ptr ds:[bx],al        ;方向改为向右 
	
	pop ax
	mov ds, ax
	pop ax
	jmp snkGo 

up_pressed: 
	push ax
	push ds
	mov ax, offset info
	mov ds, ax
	
	mov al,3 
	mov bx,1 
	mov byte ptr ds:[bx],al        ;方向改为向上 
	
	pop ax
	mov ds, ax
	pop ax
	jmp snkGo 

down_pressed: 
	push ax
	push ds
	mov ax, offset info
	mov ds, ax
	
	mov al,4 
	mov bx,1 
	mov byte ptr ds:[bx],al        ;方向改为向下 
	
	pop ax
	mov ds, ax
	pop ax
	jmp snkGo 

esc_pressed: 
	call game_over

;------------------------------------睡眼 
snkDelay: 	
	push bx 
	push cx 
	mov bx,800
snkDelay1:        
	mov cx,60000
snkDelay2:       
	loop snkDelay2 

	dec bx 
	jnz snkDelay1 

	pop cx 
	pop bx
	ret 

;------------------------------------得到随机行和列 
;参数：无 
;返回：无 

randPosition: 
	push ax 
	push bx 
	push dx
	push es
	push ds
	
	mov ax, cs
	mov ds, ax
	mov es, ax
	call near ptr _radomPos
	mov dh, byte ptr es:[_row]
	mov dl, byte ptr es:[_column]
	
	mov ax, offset info
	mov ds, ax
	mov bx,2
	mov byte ptr ds:[bx], dh
	mov bx,3
	mov byte ptr ds:[bx], dl
	pop ax
	mov ds, ax
	pop ax
	mov es, ax
	pop dx 
	pop bx 
	pop ax 
	ret 

;------------------------------------清除贪食蛇尾 
;参数：无 
snkRear: 
	push ax
	push bx 
	push cx 
	push dx 
	push ds
	
	mov ax, offset info
	mov ds, ax

	mov dl,0 
	mov bx,0 
	mov byte ptr ds:[bx],dl 			;0号是黑色，就是将蛇尾与背景色一样
	mov bx,10h 
	mov dh,byte ptr ds:[bx] 
	mov dl,byte ptr ds:[bx+1] 
	 
	call showChar 

	mov bx,4        ;把贪食蛇的行列数往前挪一个字位置 
	mov ch,0 
	mov cl,byte ptr ds:[bx] 
	dec cx 
	add cx,cx 
	mov bx,10h 
s_mov_memtoleft: 
	mov dl,byte ptr ds:[bx+2] 
	mov byte ptr ds:[bx],dl 
	inc bx 
	loop s_mov_memtoleft 
	
	pop ax
	mov ds, ax
	pop dx 
	pop cx 
	pop bx
	pop ax
	ret 

;------------------------------------显示贪食蛇头 
;参数：无 
;返回：无 
snkHead: 
	push ax 
	push bx 
	push cx 
	push dx 
	push si 
	push ds
	
	mov ax, offset info
	mov ds, ax
	 
	mov dl,00000010b  ;设定字符显示的属性
	mov bx,0 
	mov byte ptr ds:[bx],dl 
	mov bx,1 
	mov dl,byte ptr ds:[bx] 
	mov bx,4 
	mov ah,0 
	mov al,byte ptr ds:[bx] 

	add ax,ax 
	sub ax,4 
	mov bx,ax 
	mov ah,byte ptr ds:[bx+10h] 
	mov al,byte ptr ds:[bx+11h] 

checkSnk: 
	cmp dl,1        ;贪食蛇头方向往左 
	jz turnLeft 

	cmp dl,2        ;贪食蛇头方向往右 
	jz turnRight 

	cmp dl,3        ;贪食蛇头方向往上 
	jz turnUp 

	cmp dl,4        ;贪食蛇头方向往下 
	jz turnDown 

turnLeft: 
	dec al 
	jmp changeDir 

turnRight: 
	inc al 
	jmp changeDir 

turnUp: 
	dec ah 
	jmp changeDir 

turnDown: 
	inc ah 
	jmp changeDir 

changeDir: 
	mov byte ptr ds:[bx+12h],ah 
	mov byte ptr ds:[bx+13h],al 

	cmp ah,0 
	jz hitWall 
	cmp ah,24 
	jz hitWall 
	cmp al,0 
	jz hitWall 
	cmp al,78 
	jz hitWall 

	call hitSnk         

	mov si,2        ;判断是否吃到食物
	mov ch,byte ptr ds:[si] 
	mov cl,byte ptr ds:[si+1] 

	cmp ah,ch        ;行号是否相等 
	jnz noGetFood 
	cmp al,cl        ;列号是否相等 
	jnz noGetFood 
	add bx,2        ;吃到食物
	call randPosition 
	mov si,4 
	mov cl,byte ptr ds:[si] 	
	inc cl 			;节数加一
	mov byte ptr ds:[si],cl 

	jmp checkSnk 

hitWall: 
	call game_over  

noGetFood: 
	mov dh,ah 
	mov dl,al 
	 
	call showChar 
	
	pop ax
	mov ds, ax
	pop si 
	pop dx 
	pop cx 
	pop bx 
	pop ax 
	ret 

hitSnk: 
	push ax 
	push bx 
	push cx 
	push ds
	
	push ax
	mov ax, offset info
	mov ds, ax
	pop ax
	
	mov bx,4 
	mov ch,0 
	mov cl,byte ptr ds:[bx] 
	sub cl,3 
	mov bx,16 
	 
s_bite:        
	jcxz bite_exit 
	cmp ah,byte ptr ds:[bx] 
	jnz bite_next 
	cmp al,byte ptr ds:[bx+1] 
	jnz bite_next 
	call game_over 

bite_next: 
	add bx,2 
	dec cl 
	jmp s_bite 

bite_exit: 
	pop ax
	mov ds, ax
	pop cx 
	pop bx 
	pop ax 
	ret 

initSnk:
	push ax
	push bx 
	push cx 
	push dx
	push ds
	 
	mov ax, offset info
	mov ds, ax
	
	mov dl,00000010b  
	mov bx,0 
	mov byte ptr ds:[bx],dl 
	mov dh,1 
	mov dl,1 
	mov bx,10h 
	mov cx,3 
s10:         
	call showChar 
	mov byte ptr ds:[bx],dh        ;初始贪食蛇行号列号放主内存保存 
	mov byte ptr ds:[bx+1],dl 
	add bx,2 
	inc dl 
	loop s10 

	mov bx,4        ;保存初始节数 
	mov dl,3 
	mov byte ptr ds:[bx],dl 

	mov bx,1        ;保存初始方向向右 
	mov dl,2 
	mov byte ptr ds:[bx],dl 
	
	pop ax
	mov ds, ax
	pop dx 
	pop cx 
	pop bx
	pop ax
	ret 

showWall: 
	push ax
	push cx 
	push dx 
	push si
	push ds
	
	mov ax, offset info
	mov ds, ax
	
	mov dl,21h ;上墙 
	mov si,0 
	mov byte ptr ds:[si],dl 
	mov dh,0 
	mov dl,0 
	mov cx,80 
showWall1:         
	call showChar 
	inc dl 
	loop showWall1 

	dec dl 
	mov dh,1        ;右墙 
	mov cx,23 
showWall2:         
	call showChar 
	inc dh 
	loop showWall2 
	 
	mov cx,79        ;下墙 
showWall3:         
	call showChar 
	dec dl 
	loop showWall3 

	mov cx,24        ;左墙 
showWall4:         
	call showChar 
	dec dh 
	loop showWall4 

	pop ax
	mov ds, ax
	pop si 
	pop dx 
	pop cx 
	pop ax
	ret 

showFood: 
	push ax
	push bx 
	push dx
	push ds
	
	mov ax, offset info
	mov ds, ax
	
	mov dl,02h  
	mov bx,0 
	mov byte ptr ds:[bx],dl 
	mov bx,2 
	mov dh, byte ptr ds:[bx] 
	mov bx,3 
	mov dl,byte ptr ds:[bx] 
	
	call showChar 
			
	pop ax
	mov ds, ax
	pop dx 
	pop bx 
	pop ax
	ret 

game_over:     
	mov ah,14
	int 21h
	 
showChar:         
	push ax 
	push bx 
	push dx 
	push si 
	push es 
	push ds
	
	mov ax, offset info
	mov ds, ax
	
	mov ax,0b800h 
	mov es,ax 

	mov bh,0 
	mov bl,dl 
	add bl,dl 
	mov al,160 
	mul dh                 
	add bx,ax        ;以上计算字符要放在显存中的偏移地址 

	mov si,0 
	mov ah,byte ptr ds:[si] 
	mov al, 'o' 
	mov word ptr es:[bx],ax 

	pop ax
	mov ds, ax
	pop ax
	mov es, ax
	pop si 
	pop dx 
	pop bx 
	pop ax         
	ret 


info: db 176 dup(?)			  ;第0字节保存颜色，1字节保存方向(1左2右3上4下),2、3字节保存食物所在行和列,4蛇的节数,5级数，67得分数 