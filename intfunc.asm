; ������Ϊ 4 ��ϵͳ�������
extrn _radomPos:near  
extrn _row:near  
extrn _column:near 
extrn _beupper:near
extrn _belower:near
extrn _beint:near
extrn _bestr:near
extrn _bestrlen:near
extrn _do_exit:near
extrn _do_fork:near
extrn _do_wait:near
extrn _semaGet:near
extrn _semaFree:near
extrn _do_P:near
extrn _do_V:near
extrn _process_exit:near

user_21h:
@0:
	cmp ah,0
	jne @1
	call @@0
	jmp quitint
@1:
	cmp ah,1
	jne @2
	call @@1
	jmp quitint
@2:
	cmp ah,2
	jne @3
	call @@2
	jmp quitint
@3:
	cmp ah,3
	jne @4
	call @@3
	jmp quitint
@4:
	cmp ah,4
	jne @5
	call @@4
	jmp quitint
@5:
	cmp ah,5
	jne @6
	call @@5
	jmp quitint
@6:
	cmp ah,6
	jne @7
	call @@6
	jmp quitint
@7:
	cmp ah,7
	jne @8
	jmp @@7
	jmp quitint
@8:
	cmp ah,8
	jne @9
	jmp @@8
	jmp quitint
@9:
	cmp ah,9
	jne @10
	jmp @@9
	jmp quitint
@10:
	cmp ah,10
	jne @11
	jmp @@10
	jmp quitint
@11:
	cmp ah,11
	jne @12
	jmp @@11
	jmp quitint
@12:
	cmp ah,12
	jne @13
	jmp @@12
	jmp quitint
@13:
	cmp ah,13
	jne @14
	jmp @@13
	jmp quitint
@14:
	cmp ah,14
	jne @15
	jmp @@14
	jmp quitint
@15:
quitint:	
	iret						

	
;========================================================================================================================================================
@@0:	
    mov ah,13h 	                    ; ���ܺ�
	mov al,0                 		; ���ŵ���β
	mov bl, 0ah
	mov bh,0 	                	; ��0ҳ
	mov dh,12	                    ; ��
	mov dl,38                       ; ��
	mov bp, offset ouch 	        ; BP=����ַ
	mov cx,5  	                    ; ����
	int 10h 		                ; ����10H���ж�
@@0loop:
	mov ah,0 	    ; ���ܺ�
	int 16h 	    ; ����16h���ж�
	cmp al,1Bh      ;�س��� ascii ��Ϊ 0dh(13)
	je @@0quit
	jmp @@0loop
@@0quit:
	ret
;===================================================================================================================================================
@@1:
	push dx
	call near ptr _beupper     ; ���� C ����
	pop dx
	ret
;===================================================================================================================================================
@@2:
	push dx
	call near ptr _belower     ; ���� C ����
	pop dx
	ret
;===================================================================================================================================================
@@3:
	push dx
	call near ptr _beint
	pop dx
	ret
;===================================================================================================================================================
@@4:
	push bx
	push dx
	call near ptr _bestr
	pop dx
	pop bx
	ret
;===================================================================================================================================================
@@5:
	mov bp,dx 	        			; BP=����ַ
	mov dh,ch	                    ; ��
	mov dl,cl                       ; ��
	mov cx,bx  	                    ; ����
	
	mov ah,13h 	                    ; ���ܺ�
	mov al,0                 		; ���ŵ���β
	mov bl, 0ah
	mov bh,0 	                	; ��0ҳ
	int 10h 		                ; ����10H���ж�
@@5loop:
	mov ah,0 	    ; ���ܺ�
	int 16h 	    ; ����16h���ж�
	cmp al,1Bh      ;�س��� ascii ��Ϊ 0dh(13)
	je @@5quit
	jmp @@5loop
@@5quit:
	ret
;===================================================================================================================================================
@@6:
	push dx
	call near ptr _bestrlen
	pop dx
	ret
;===================================================================================================================================================
@@7:
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
	push ax                      
	mov ax,cs		;��ʱ��cs = 1000h
	mov ds, ax
	mov es, ax
	call _PCB_store
	call _do_fork   ; ���� C ����
	jmp Restore
;===================================================================================================================================================
@@8:
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
	push ax                     
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _PCB_store
	call near ptr _do_wait   ; ���� C ����
	jmp Restore
;===================================================================================================================================================
@@9:
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
	push ax                    
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _PCB_store 
	push word ptr ds:[0]		;��ulib.asm�н�mark��������ڴ�������
	call near ptr _do_exit   ; ���� C ����
    pop word ptr ds:[0]
	jmp Restore

;==========================�����ź���=========================================================================================================================
@@10:
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
	push ax                    
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _PCB_store 
	
	push word ptr ds:[0]		;��ulib.asm�н�mark��������ڴ�������
	call near ptr _semaGet   ; ���� C ����
    pop word ptr ds:[0]

	jmp Restore

;=======================�ͷ��ź���============================================================================================================================
@@11:
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
	push ax                    
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _PCB_store 
    
	push word ptr ds:[0]		;��ulib.asm�н�mark��������ڴ�������
	call near ptr _semaFree   ; ���� C ����
    pop word ptr ds:[0]

	jmp Restore
;========================================P ����===========================================================================================================
@@12:
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
	push ax                    
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _PCB_store 

	push word ptr ds:[0]		;��ulib.asm�н�mark��������ڴ�������
	call near ptr _do_P   ; ���� C ����
    pop word ptr ds:[0]

	jmp Restore

;================================V ����===================================================================================================================
@@13:
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
	push ax                    
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _PCB_store 
    
	push word ptr ds:[0]		;��ulib.asm�н�mark��������ڴ�������
	call near ptr _do_V   ; ���� C ����
    pop word ptr ds:[0]

	jmp Restore
;========���̵��˳�===================================================================================================================
@@14:
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
	push ax                    
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _PCB_store 
	call near ptr _process_exit   ; ���� C ����
	jmp Restore
;===================================================================================================================================================
;===================================================================================================================================================
intmsg1:
    push ax
	push bx
	push cx
	push dx
	push bp
loop01:	
	mov ah,13h 	                ; ���ܺ�
	mov al,0 	            	; ���ŵ���β
	mov bl, byte ptr es:[color]
	mov bh,0 		            ; ��0ҳ
	mov dh,0 	                ; ��0��
	mov dl,0 	                ; ��0��
	mov bp,offset msgstr1          ; BP=����ַ
	mov cx,504 	                ; ����Ϊ 504
	int 10h 		            ; ����10H���ж�

	mov ah,0 	    ; ���ܺ�
	int 16h 	    ; ����16h���ж�
	cmp al,1Bh      ;�س��� ascii ��Ϊ 0dh(13)
	je return1
	jmp loop01
return1:
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	iret						; ���жϷ���

intmsg2:
    push ax
	push bx
	push cx
	push dx
	push bp
	
loop2:
	mov ah,13h 	                ; ���ܺ�
	mov al,0             		; ���ŵ���β
	mov bl, byte ptr es:[color]
	mov bh,0             		; ��0ҳ
	mov dh,5 	                ; ��5��
	mov dl,44 	                ; ��44��
	mov bp,offset msgstr2 	        ; BP=����ַ
	mov cx,20 	                ; ����
	int 10h 		            ; ����10H���ж�

	mov ah,0 	    ; ���ܺ�
	int 16h 	    ; ����16h���ж�
	cmp al,1Bh      ;�س��� ascii ��Ϊ 0dh(13)
	je return2
	jmp loop2
return2:	
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	iret						; ���жϷ���


intmsg3:
    push ax
	push bx
	push cx
	push dx
	push bp
loop3:
	mov ah,13h 	                 ; ���ܺ�
	mov al,0 		             ; ���ŵ���β
	mov bl, byte ptr es:[color]
	mov bh,0 	                 ; ��0ҳ
	mov dh,13 	                 ; ��13��
	mov dl,0 	                 ; ��0��
	mov bp,offset msgstr3 	         ; BP=����ַ
	mov cx,462 	                 ; ����Ϊ 479
	int 10h 		             ; ����10H���ж�

	mov ah,0 	    ; ���ܺ�
	int 16h 	    ; ����16h���ж�
	cmp al,1Bh      ;�س��� ascii ��Ϊ 0dh(13)
	je return3
	jmp loop3
return3:	
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	iret						; ���жϷ���

intmsg4:
    push ax
	push bx
	push cx
	push dx
	push bp
loop4:
	mov ah,13h 	                ; ���ܺ�
	mov al,0 	             	; ���ŵ���β
	mov bl, byte ptr es:[color]
	mov bh,0 	                ; ��0ҳ
	mov dh,18 	                ; ��18��
	mov dl,42 	                ; ��46��
	mov bp,offset msgstr4 	    ; BP=����ַ
	mov cx,30 	                ; ����
	int 10h 		            ; ����10H���ж�

	mov ah,0 	    ; ���ܺ�
	int 16h 	    ; ����16h���ж�
	cmp al,1Bh      ;�س��� ascii ��Ϊ 0dh(13)
	je return4
	jmp loop4
return4:
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	iret					; ���жϷ���

ouch_key:
    push ax
    push bx
    push cx
    push dx
	push bp

	dec byte ptr es:[oneOut]
	cmp byte ptr es:[oneOut],0
	je printOUCH
	mov byte ptr es:[oneOut],1
	jmp pause

printOUCH:
	call near ptr _radomPos			;���λ��
    mov ah,13h 	                    ; ���ܺ�
	mov al,0                 		; ���ŵ���β
	mov bl, byte ptr es:[color]
	mov bh,0 	                	; ��0ҳ
	mov dh,byte ptr es:[_row] 	    ; ��
	mov dl,byte ptr es:[_column]    ; ��
	mov bp, offset ouch 	        ; BP=����ַ
	mov cx,5  	                    ; ����
	int 10h 		                ; ����10H���ж�
    
pause:
	in al,60h						;�����̻����� 
	mov al,20h					    ; AL = EOI
	out 20h,al						; ����EOI����8529A
	out 0A0h,al					    ; ����EOI����8529A
	
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	iret							; ���жϷ���
	

msgstr1:
    db "---ALL INT CAN press esc to continue----"
	db 0ah,0dh
	db "----------------------------------------"
	db 0ah,0dh
	db "-----------------or---------------------"
	db 0ah,0dh
	db "----------------------------------------"
	db 0ah,0dh
	db "-------------press other key------------"
	db 0ah,0dh
	db "----------------------------------------"
	db 0ah,0dh
	db "------to change the string's color!-----"
	db 0ah,0dh
	db "----------------------------------------"
	db 0ah,0dh
	db "----------------------------------------"
	db 0ah,0dh
	db "---------------int 33h------------------"
	db 0ah,0dh
	db "----------------------------------------"
	db 0ah,0dh
    db "----------------------------------------"
	db 0ah,0dh,'$'
msgstr2: db "int 34h, keep going."
msgstr3:
    db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------- int 35h --------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh
	db "|--------------------------------------|"
	db 0ah,0dh,'$'
msgstr4: db "I'm int 36h,press Esc to quit!"
ouch: db "OUCH!"
oneOut db 0