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
	mov ah,13h 	                        ; ���ܺ�
	mov al,0                     		; ���ŵ���β
	mov bl,byte ptr es:[color]
	mov bh,0 	                    	; ��0ҳ
	mov dh,24 	                        ; ��24��
	mov dl,78 	                        ; ��78��
	mov cx,1 	                        ; ����Ϊ 1
	int 10h 	                    	; ����10H���ж�
	mov byte ptr es:[count],delay	
	
endTimer:
	mov al,20h					; AL = EOI
	out 20h,al						; ����EOI����8529A
	out 0A0h,al					; ����EOI����8529A	
	pop ax                                          ; �ָ��Ĵ�����Ϣ
	mov es,ax
	pop bp
	pop dx 
	pop cx
	pop bx
	pop ax
	iret							; ���жϷ���
;======================================================================================================================================================
;��ʱ��	
Timer:
	cmp word ptr[_Timer_status],1                    
	jnz Process_Timer                               ; �û�ʱ��
	jmp Kernal_Timer                                ; �ں�ʱ��
;======================================================================================================================================================
Process_Timer:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push sp					;SP������5����ջ������ʱ���жϵ�ʱ��IP/CS/FLAGѹջ��5+3=8��ջ sp = sp-8*2
	push di
	push si
	push bp
	push dx
	push cx
	push bx
	push ax                                         ; push into PCB_store as Parameters�� sp = sp - 8*2
	;CALLָ����ڵ��ý�ָ��ָ��IP��ջ���μ��������ջ�λ�ַCs������ջIP
	mov ax, cs										;��ʱ��CS�ĵ�ַ��ʱ���жϵĵ�ַ1000h, ��Ϊ��setint.asm ����mov word ptr es:[22h],cs(=1000h)
	mov ds, ax
	mov es, ax
	cmp word ptr [_active_time], -2				;�ж��Ƿ���-2���ǵĻ��Ͳ��ü�����������ҽ���Ҳ��û����ʱ��
												;ֻ��ͨ���û�������ϵͳ����   mov ah, 14    int 21h 
												;���� process_exit(){active_time = 0;}��������
	jz do_not_dec
Timer_press_esc:
	mov al,0 	
	mov ah,1
	int 16h 									;������״̬���Ƿ��а�����Ӧ
	jnz Timer_pressed_esc						;�а�����Ӧ����Timer_pressed_esc
	mov ax,0ffh
	stc
	jmp Timer_after_esc 
Timer_pressed_esc: 
	mov ah, 00h 	
	int 16h										;��ȡ�������е�����
	cmp al,1bh       							;����Ƿ���ESC��ascii  1bh
    jnz Timer_after_esc 
	mov word ptr [_active_time],0				;�����ESC��������ô��������
Timer_after_esc:
	cmp word ptr [_active_time],0  		        ; �Ƿ��˳�ʱ����
	jnz Timer_handle                            ; �������
	mov word ptr [_current_PCB],0               ; �ָ��Ľ���ΪOS����
	mov word ptr [_Timer_status],1              ; �ں�̬
	jmp Restore                                 ; ��ʼ�ָ�����
	
Timer_handle:
	cmp word ptr [_active_time], -1				;
	jz do_not_dec
	dec word ptr [_active_time]                     ; -- _active_time
do_not_dec:
	call _PCB_store                                   ; ��ʼ������̿��ƿ� _current_PCBһ��ʼ��0�����������Ǳ����ں˵ļĴ�������	
	call _Schedule                                  ; ���̵���Ҳ����current_PCB++
Restore:
	call _getCurrentPCB                             ; �õ�current_PCB���̿��ƿ����ʼ��ַ	mov si, ax		
	mov si,ax										;����ֵĬ�ϴ���ax�Ĵ���
	mov ss,word ptr [si+0]                        ;�ָ�ջ��
	mov sp,word ptr [si+2*8]                     ; �ָ�ջ��ָ��
	cmp word ptr [si+2*16],1                 	  ;�Ƿ��һ��
	jnz Restack                                	  ;���ǵ�һ�εĻ��������ָ���ջ�Ĳ���
	mov word ptr [si+2*16],0 
	jmp Restart
Restack:
	add sp, 16                                    ; �ָ�����ʱ���ж�ǰջ���ֱ�����ջ��������:ds es fs gs ss ip cs flags 
	jmp Restart	
												;����ʵģʽ�£�x86 CPU���ڣ������Σ��жϷ���ʱ���Ƚ�FALGS��CS��IPѹ�뵱ǰ�����ջ��\ 
Restart:										;Ȼ������ת��IVT���Ӧ�ж�������ָ����CS:IP������ʼִ���жϴ����				   / 
	push word ptr [si+2*15]                      ; �ָ� flags
	push word ptr [si+2*14]                      ; �ָ� �������ݶ�CS
	push word ptr [si+2*13]	                     ; �ָ� ip  ����˳��ѹջ��/*****ģ���ж�******/�������
												 ;Ȼ������ת��IVT���Ӧ�ж�������ָ����CS:IP������ʼִ���жϴ����
	mov ax,word ptr [si+2*12]                    ; �ָ�ax cx .... ds si
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
	push word ptr [si+2*6]                       ; push si ( ds �� si ��ֱ�� mov)
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
end_process_timer:                                  ; �����û�̬�ж�
	push ax         
	mov al,20h                                      ; �����жϴ��������Ϣ���жϿ�����
	out 20h,al                                      ; ����EOI����8529A
	out 0A0h,al                                     ; ����EOI����8529A
	pop ax
	iret											;ִ��IRETʱ���Ĵ�����ջ��˳����IP/CS/FLAGS
													;���ʱ����޸���cs:ip��ֵ������ʽ��ʼ�л����̡�������һ��ʱ���ж�����֮ǰ�����ʱ�� ���н���
;=================================================================================================================================================
	
setTimer:
	push ax
	mov al, 34h 
	out 43h,al   
	mov ax,23863                              ;        23863	; ʱ��Ƶ��  1491��
	out 40h, al
	mov al, ah
	out 40h,al
	pop ax
	ret
	
datadef:
	delay equ 13					; ��ʱ���ӳټ���
	count db delay					; ��ʱ��������������ֵ=delay
	str1 db '|'
	str2 db '/'
	str3 db '\'
	shape db 0
	color db 1