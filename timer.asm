extrn _PCB_store:near
extrn _getCurrentPCB:near
extrn _Schedule:near
extrn _current_PCB:near
extrn _Timer_status:near
extrn _active_time:near

Kernal_Timer:
	push ax
	push bx
	push cx
	push dx
	push bp
    push es
	
	inc byte ptr es:[color]
	cmp byte ptr es:[color], 15
	je initcolor
onit:	
	dec byte ptr es:[count]	
	jnz endTimer						
	inc byte ptr es:[shape]                
	cmp byte ptr es:[shape],1              ; |
	je shape1
	cmp byte ptr es:[shape],2              ; /
	je shape2
	cmp byte ptr es:[shape],3              ; \ 
	je shape3
	jmp showch
initcolor: 
	mov byte ptr es:[color], 1
	jmp onit
shape1:
    mov bp,offset str1
	jmp showch
shape2:
    mov bp,offset str2
	jmp showch
shape3:
	mov byte ptr es:[shape],0
    mov bp,offset str3
	jmp showch
	
showch:
	mov ah,13h 	                        ; 功能号
	mov al,0                     		; 光标放到串尾
	mov bl,byte ptr es:[color]
	mov bh,0 	                    	; 第0页
	mov dh,24 	                        ; 第24行
	mov dl,78 	                        ; 第78列
	mov cx,1 	                        ; 串长为 1
	int 10h 	                    	; 调用10H号中断
	mov byte ptr es:[count],delay	
	
endTimer:
	mov al,20h					; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A	
	pop ax                                          ; 恢复寄存器信息
	mov es,ax
	pop bp
	pop dx 
	pop cx
	pop bx
	pop ax
	iret							; 从中断返回
;======================================================================================================================================================
;计时器	
Timer:
	cmp word ptr[_Timer_status],1                    
	jnz Process_Timer                               ; 用户时钟
	jmp Kernal_Timer                                ; 内核时钟
;======================================================================================================================================================
Process_Timer:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push sp					;SP上面有5个入栈，加上时钟中断的时候IP/CS/FLAG压栈，5+3=8个栈 sp = sp-8*2
	push di
	push si
	push bp
	push dx
	push cx
	push bx
	push ax                                         ; push into PCB_store as Parameters， sp = sp - 8*2
	;CALL指令段内调用将指令指针IP入栈，段间调用先入栈段基址Cs，再入栈IP
	mov ax, cs										;这时候CS的地址是时间中断的地址1000h, 因为在setint.asm 里面mov word ptr es:[22h],cs(=1000h)
	mov ds, ax
	mov es, ax
	cmp word ptr [_active_time], -2				;判断是否是-2，是的话就不用检查键盘输入而且进程也是没结束时间
												;只能通过用户程序本身系统调用   mov ah, 14    int 21h 
												;调用 process_exit(){active_time = 0;}结束进程
	jz do_not_dec
Timer_press_esc:
	mov al,0 	
	mov ah,1
	int 16h 									;检测键盘状态，是否有按键响应
	jnz Timer_pressed_esc						;有按键响应跳到Timer_pressed_esc
	mov ax,0ffh
	stc
	jmp Timer_after_esc 
Timer_pressed_esc: 
	mov ah, 00h 	
	int 16h										;获取缓冲区中的内容
	cmp al,1bh       							;检查是否是ESC的ascii  1bh
    jnz Timer_after_esc 
	mov word ptr [_active_time],0				;如果是ESC按键，那么结束进程
Timer_after_esc:
	cmp word ptr [_active_time],0  		        ; 是否到退出时间了
	jnz Timer_handle                            ; 否则继续
	mov word ptr [_current_PCB],0               ; 恢复的进程为OS进程
	mov word ptr [_Timer_status],1              ; 内核态
	jmp Restore                                 ; 开始恢复进程
	
Timer_handle:
	cmp word ptr [_active_time], -1				;
	jz do_not_dec
	dec word ptr [_active_time]                     ; -- _active_time
do_not_dec:
	call _PCB_store                                   ; 开始保存进程控制块 _current_PCB一开始是0，所以最先是保存内核的寄存器数据	
	call _Schedule                                  ; 进程调度也就是current_PCB++
Restore:
	call _getCurrentPCB                             ; 得到current_PCB进程控制块的起始地址	mov si, ax		
	mov si,ax										;返回值默认存在ax寄存器
	mov ss,word ptr [si+0]                        ;恢复栈堆
	mov sp,word ptr [si+2*8]                     ; 恢复栈顶指针
	cmp word ptr [si+2*16],1                 	  ;是否第一次
	jnz Restack                                	  ;不是第一次的话就跳到恢复堆栈的操作
	mov word ptr [si+2*16],0 
	jmp Restart
Restack:
	add sp, 16                                    ; 恢复进入时间中断前栈顶分别是由栈顶自下是:ds es fs gs ss ip cs flags 
	jmp Restart	
												;即在实模式下，x86 CPU会在（可屏蔽）中断发生时，先将FALGS、CS、IP压入当前程序的栈中\ 
Restart:										;然后再跳转到IVT里对应中断向量所指定的CS:IP处，开始执行中断处理程				   / 
	push word ptr [si+2*15]                      ; 恢复 flags
	push word ptr [si+2*14]                      ; 恢复 代码数据段CS
	push word ptr [si+2*13]	                     ; 恢复 ip  按此顺序压栈，/*****模拟中断******/进入操作
												 ;然后再跳转到IVT里对应中断向量所指定的CS:IP处，开始执行中断处理程
	mov ax,word ptr [si+2*12]                    ; 恢复ax cx .... ds si
	mov cx,word ptr [si+2*11]                   
	mov dx,word ptr [si+2*10]                    
	mov bx,word ptr [si+2*9]                     
	mov bp,word ptr [si+2*7]                     
	mov di,word ptr [si+2*5]                     
	mov es,word ptr [si+2*3]                     
	.386
	mov fs,word ptr [si+2*2]                     
	mov gs,word ptr [si+2*1]                     
	.8086
	push word ptr [si+2*6]                       ; push si ( ds 和 si 不直接 mov)
	push word ptr [si+2*4]                       
	pop ds                                          
	pop si
	
	cmp word ptr [_Timer_status], 1
	jne end_process_timer
	
resetScreen:
	push ax
	mov  ax, cs
	mov  ds, ax           ; DS = CS
	mov  es, ax           ; ES = CS
	pop ax
end_process_timer:                                  ; 结束用户态中断
	push ax         
	mov al,20h                                      ; 发送中断处理结束消息给中断控制器
	out 20h,al                                      ; 发送EOI到主8529A
	out 0A0h,al                                     ; 发送EOI到从8529A
	pop ax
	iret											;执行IRET时，寄存器出栈的顺序是IP/CS/FLAGS
													;这个时候才修改了cs:ip的值，才正式开始切换进程。。在下一个时间中断来到之前的这段时间 运行进程
;=================================================================================================================================================
	
setTimer:
	push ax
	mov al, 34h 
	out 43h,al   
	mov ax,23863                              ;        23863	; 时钟频率  1491快
	out 40h, al
	mov al, ah
	out 40h,al
	pop ax
	ret
	
datadef:
	delay equ 13					; 计时器延迟计数
	count db delay					; 计时器计数变量，初值=delay
	str1 db '|'
	str2 db '/'
	str3 db '\'
	shape db 0
	color db 1