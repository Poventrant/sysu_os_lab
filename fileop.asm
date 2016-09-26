;=============================================================================================================
;   void _loadUserFile(char* UserFileName,int UserBaseAddress,int UserOffsetAddress, int userloadtoSec);
;=============================================================================================================
; ���س����ڴ�,����ֵ��AX,1��ʾ�ҵ������سɹ���0��ʾû���سɹ�
UserFileName            dw  0           ; �ļ���ָ��
UserBaseAddress         dw  0           ; �ļ����ضε�ַ
UserOffsetAddress       dw  0           ; �ļ�����ƫ�Ƶ�ַ
userloadtoSec 			dw  0            ; ��ǰ��Ŀ¼
public _loadUserFile
_loadUserFile proc
    push bp
	mov bp,sp
	push bx
	push cx
	push dx
    push es
	push si
	push di

	mov ax,[bp+4]                     	  ; �Ѵ��ݽ������ļ���ָ��ŵ� UserFileName
	mov word ptr[UserFileName],ax
	mov ax,[bp+6]
	mov word ptr[UserBaseAddress],ax      ; �Ѵ��ݽ����Ļ���ַ�ŵ� UserBaseAddress
	mov ax,[bp+8]
	mov word ptr[UserOffsetAddress],ax    ; �Ѵ��ݽ�����ƫ�Ƶ�ַ�ŵ� UserOffsetAddress
	mov ax,[bp+10]
	mov word ptr[userloadtoSec],ax   	 ; �Ѵ��ݽ�����ƫ�Ƶ�ַ�ŵ� UserOffsetAddress
	
	push word ptr[userloadtoSec]
	push word ptr[UserFileName]
	call _searchFile
	pop word ptr[UserFileName]
	pop word ptr[userloadtoSec]
	
	cmp ax, -1
	jz LABEL_NO_USERFILE
	
	mov di, ax
LABEL_FILENAME_FOUND:	                      ; �ҵ� �ļ� ��������������
	; �����ļ�����ʼ������
	mov	ax, RootDirSectors	                  ; AX=��Ŀ¼ռ�õ�������
	and	di, 0FFE0h	                          ; DI -> ��ǰ��Ŀ�Ŀ�ʼ��ַ
	add	di, 1Ah			                      ; DI -> �ļ���������������Ŀ�е�ƫ�Ƶ�ַ
	mov cx, word ptr es:[di]	              ; CX=�ļ�����������
	push cx				                      ; �����������FAT�е����
	add	cx, ax			                      ; CX=�ļ��������ʼ������+��Ŀ¼ռ�õ�������
	add	cx, DeltaSectorNo	                  ; CL <- UserFileName����ʼ������(0-based)
	mov ax,word ptr[UserBaseAddress]          ; ȡ����ַ
	mov	es, ax			                      ; ES <- BaseOfRootDictionary��װ�س����ַ=9000h��
	mov bx,word ptr[UserOffsetAddress]        ; ȡƫ�Ƶ�ַ
	mov	ax, cx		                          ; AX <- ��ʼ������

LABEL_GOON_LOADING_FILE:
	push bx				                      ; ����װ�س���ƫ�Ƶ�ַ
	mov	cl, 1				                  ; 1������------------------------------------------------------------------------------------
	call	ReadSector		                  ; ������

	; ÿ��һ���ؾ��� "Booting  " �����һ����, �γ�������Ч����Booting ......
	mov	ah, 0Eh								  ; ���ܺţ��Ե紫��ʽ��ʾ�����ַ���
	mov	al, '.'							      ; Ҫ��ʾ���ַ�
	mov	bl, 0Fh								  ; �ڵװ���
	int	10h									  ; ��ʾ�ж�

	
	; �����ļ�����һ������
	pop bx				                      ; ȡ��װ�س���ƫ�Ƶ�ַ
	pop	ax				                      ; ȡ����������FAT�е����
	
	push ax
	mov ax, word ptr[UserBaseAddress]		;-------------------------------------------------------------------------------------
	mov word ptr[GetFATEntryAddr], ax		;GetFATEntry�����жԻ���ַ��Ҫ����UserBaseAddress
	pop ax
	call GetFATEntry		                  ; ��ȡFAT���е���һ�غ�
	mov word ptr[GetFATEntryAddr], 0

	cmp	ax, 0FF8h		                      ; �Ƿ����ļ�����
	jae	LABEL_FILE_LOADED                     ; ��FF8hʱ��ת���������һ����
	push ax				                      ; ����������FAT�е����
	mov	dx, RootDirSectors	                  ; DX = ��Ŀ¼������ = 14
	add	ax, dx			                      ; ������� + ��Ŀ¼������
	add	ax, DeltaSectorNo		              ; AX = Ҫ��������������ַ
	add	bx, word ptr [BPB_BytsPerSec]	      ; BX+512ָ��װ�س���������һ��������ַ
	jmp	LABEL_GOON_LOADING_FILE
	
LABEL_FILE_LOADED:                            ; ��ɼ���
	pop di
	pop si
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop bp
	mov ax, 1
	ret
	
LABEL_NO_USERFILE:	
	call errorloaded
    pop di
	pop si
	pop ax
	mov es, ax
	pop dx
	pop cx
	pop bx
	pop bp
	mov ax, 0
    ret                                       ; û���ҵ� �ļ��������ﷵ��

_loadUserFile endp


;=============================================================================================================
;   int _ChangeDictionry(char dictionaryName, int infatherDirsEntry);
;	AX����ֵ��-1��ʾû�����Ŀ¼
;=============================================================================================================
dictionaryName dw 0					;Ҫ�ҵ���Ŀ¼������
infatherDirsEntry dw 0				;��ǰĿ¼
subdirbase equ 1000h
subdiroff equ 0a000h
public _ChangeDictionry
_ChangeDictionry proc
    push bp
	mov bp,sp
	push bx
	push cx
	push dx
    push es
	push si
	push di

	mov ax,[bp+4]                     	  ; �Ѵ��ݽ������ļ���ָ��ŵ� dictionaryName
	mov word ptr[dictionaryName],ax   
	mov ax,[bp+6] 
	mov word ptr[infatherDirsEntry],ax 
	
	push word ptr[infatherDirsEntry]
	push word ptr[dictionaryName]
	call _searchFile
	pop word ptr[dictionaryName]
	pop word ptr[infatherDirsEntry]
	
	cmp ax, -1
	jnz CD_FILENAME_FOUND
	
;===============================================================================================================
CD_NO_USERFILE:						;����ֵ -1 ��ʾû�ҵ�
    pop di
	pop si
	pop bx
	mov es, bx
	pop dx
	pop cx
	pop bx
	pop bp
    ret                                 ; û���ҵ� �ļ��������ﷵ��

CD_FILENAME_FOUND:	                      ; �ҵ� �ļ� ��������������
	; �����ļ�����ʼ������
	mov di, ax
	mov	ax, RootDirSectors	                  ; AX=��Ŀ¼ռ�õ�������
	and	di, 0FFE0h	                          ; DI -> ��ǰ��Ŀ�Ŀ�ʼ��ַ
CD_CHECK_IF_IS_SUBDICTIONARY:	
	push di
	add	di, 0Bh
	cmp byte ptr es:[di], 10h					;�ļ������Ƿ�����Ŀ¼-----------------------------------------
	jnz CD_IS_NOT_SUBDICTIONARY
	pop di
	
	add	di, 1Ah			                      ; DI -> �ļ���������������Ŀ�е�ƫ�Ƶ�ַ
	mov cx, word ptr es:[di]	              ; CX=�ļ�����������
	push cx				                      ; �����������FAT�е����
	pop ax		                          	  ; AX <- ��������FAT�е����------����ֵ
	jmp END_CD
CD_IS_NOT_SUBDICTIONARY:
	pop di
	mov ax, -1
END_CD:	
	pop di
	pop si
	pop bx
	mov es,bx
	pop dx
	pop cx
	pop bx
	pop bp
	ret
_ChangeDictionry endp

;=============================================================================================================
;   int _deleteFile(char dictionaryName, int infatherDirsEntry);
;	AX����ֵ��-1��ʾû�����Ŀ¼
;=============================================================================================================
public _deleteFile 
_deleteFile proc 
	push bp
	mov bp,sp
	push bx
	push cx
	push dx
    push es
	push si
	push di
	
	mov ax,[bp+4]                     	  ; �Ѵ��ݽ������ļ���ָ��ŵ� dictionaryName
	mov word ptr[dictionaryName],ax   
	mov ax,[bp+6] 
	mov word ptr[infatherDirsEntry],ax 
	
	push word ptr[infatherDirsEntry]
	push word ptr[dictionaryName]
	call _searchFile
	pop word ptr[dictionaryName]
	pop word ptr[infatherDirsEntry]
	
	cmp ax, -1
	jz DEL_NOT_FOUND
DEL_FOUND:
	mov di, ax
	and	di, 0FFE0h	                          ; DI -> ��ǰ��Ŀ�Ŀ�ʼ��ַ
	mov byte ptr es:[di], 0e5h				  ;ɾ���ĵı�־��Ŀ¼����һ���ֽ�Ϊe5h	
	
	;��ʱ��es:bx��_searchFile֮��û��
	mov cl, 1 ;Ҫд1������
	call WriteSector
	mov ax, di
	
DEL_NOT_FOUND:
	pop di
	pop si
	pop bx
	mov es, bx
	pop dx
	pop cx
	pop bx
	pop bp
    ret   
_deleteFile endp

;=============================================================================================================
;   void _listFileInfo(int firstSector);
;=============================================================================================================
; ���س����ڴ�
extrn _asc2char:near
firstSector dw 0
public _listFileInfo
_listFileInfo proc
    push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
    push es
	push si
	push di
	
	mov ax,[bp+4]                     	  ; �Ѵ��ݽ������ļ���ָ��ŵ� dictionaryName
	mov word ptr[firstSector],ax 
; ������λ
	xor	ah, ah                       	  ; ���ܺ�ah=0����λ������������
	xor	dl, dl                      	  ; dl=0��������Ӳ�̺�U��Ϊ80h��
	int	13h		                    	  ; �����ж�
	
	cmp word ptr[firstSector], 0		;��ǰ��Ŀ¼�Ƿ��Ǹ�Ŀ¼
	jnz LIST_SEARCH_IN_SUB_DIR_BEGIN0
	
	mov	word ptr [wSectorNo], SectorNoOfRootDirectory 	; ����ʾ��ǰ�����ŵı���wSectorNo����ֵΪ��Ŀ¼�����������ţ�=19��
	mov word ptr[wRootDirSizeForLoop], RootDirSectors

LIST_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word ptr [wRootDirSizeForLoop], 0	; �жϸ�Ŀ¼���Ƿ��Ѷ���
	jz	LIST_FINISH_DIR	             	; ���������ʾδ�ҵ�UserFileName
	dec	word ptr [wRootDirSizeForLoop]	    ; �ݼ�����wRootDirSizeForLoop��ֵ
	; ���ö�������������һ����Ŀ¼������װ����
	mov	ax, BaseOfRootDictionary
	mov	es, ax			                    ; ES <- BaseOfRootDictionary
	mov	bx, OffsetOfRootDictionary	        ; BX <- OffsetOfRootDictionary
	mov	ax, word ptr [wSectorNo]	        ; AX <- ��Ŀ¼�еĵ�ǰ������
	mov	cl, 1				                ; ֻ��һ������
	call	ReadSector		                ; ���ö���������
	
	mov	di, OffsetOfRootDictionary	        ; ES:DI -> BaseOfRootDictionary:0100
	cmp	word ptr [wRootDirSizeForLoop], 13	;�Ƿ��ǵ�һ�����������Ծ��
	jnz FIRST_IGNORE_VOL
	add	di, 20h  							;���ü��MYOS SYSTEM���
FIRST_IGNORE_VOL:
	cld					                    ; ���DF��־λ DF=0��ʱ��, SI = SI + 1 , DI = DI + 1 
						                    ; �ñȽ��ַ���ʱ�ķ���Ϊ��/��[��������]
	mov	dx, 10h			                    ; ѭ������=16��ÿ��������16���ļ���Ŀ��512/32=16��
LIST_SEARCH_FOR_USERFILE:					;-------------------------------------------------------------------------------------
	mov bx, 0
	cmp	dx, 0			                    ; ѭ����������
	jz LIST_GOTO_NEXT_SECTOR_IN_ROOT_DIR    ; ���Ѷ���һ����
	dec	dx				                    ; �ݼ�ѭ������ֵ��������һ����
LIST_CMP_DELETED:
	cmp byte ptr es:[di], 0e5h				;��1�ֽ���0E5h��ʾ���ļ��Ѿ�ɾ��
	jz LIST_NEXT_FILE_MAP2
	mov	cx, 11			                    ; ��ʼѭ������Ϊ11��Ϊ�ļ����ֽ���
LIST_CMP_FILENAME:
	cmp byte ptr es:[di], 0					;�Ƚ���Ŀ�Ƿ���0��Ҳ����˵��Ŀ�Ƿ���null
	jnz LIST_GOON_LOOP_CMP					;�����Ŀǰ11���ֽڶ���0����ô���ﲻ���ļ�
ADD_NULLNAME:
	inc bx									;
LIST_GOON_LOOP_CMP:
	inc di
	loop LIST_CMP_FILENAME
	cmp	bx, 11								;�����Ŀǰ11���ֽڶ���0����ô���ﲻ���ļ�
	jz	LIST_NEXT_FILE_MAP		        ; ����Ƚ���11���ֽ�������ôһ������0����ʾ���ļ��ڵ�ǰ��Ŀ
LIST_PRINT_OUT_DIR_INFO0:
	call LIST_PRINT_OUT_DIR_INFO
LIST_NEXT_FILE_MAP:
	and	di, 0FFE0h		                    ; DI &= E0Ϊ������ָ����Ŀ��ͷ����5λ���㣩
LIST_NEXT_FILE_MAP2:				        ; FFE0h = 1111111111100000����5λ=32=Ŀ¼��Ŀ��С��
	add	di, 20h		                    	; DI += 20h ��һ��Ŀ¼��Ŀ
	jmp	LIST_SEARCH_FOR_USERFILE            ;-------------------------------------------------------------------------------------

LIST_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word ptr [wSectorNo], 1             ; ������ǰ������
	jmp	LIST_SEARCH_IN_ROOT_DIR_BEGIN
	
LIST_FINISH_DIR:
    pop di
	pop si
	pop ax
	mov es, ax
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
    ret                                       ; û���ҵ� �ļ��������ﷵ��
;=============================================================================================================
;=============================================================================================================
LIST_SEARCH_IN_SUB_DIR_BEGIN0:
	mov	ax, RootDirSectors	                  ; AX=��Ŀ¼ռ�õ�������
	mov cx, word ptr [firstSector]	              ; CX=�ļ�����������
	push cx				                      ; �����������FAT�е����
	add	cx, ax			                      ; CX=�ļ��������ʼ������+��Ŀ¼ռ�õ�������
	add	cx, DeltaSectorNo	                  ; CL <- UserFileName����ʼ������(0-based)
	mov ax,subdirbase		         		 ; ȡ����ַ
	mov	es, ax			                      ; ES <- BaseOfRootDictionary��װ�س����ַ=9000h��
	mov bx,subdiroff	         			 ; ȡƫ�Ƶ�ַ
	mov	ax, cx		                          ; AX <- ��ʼ������
LIST_SEARCH_IN_SUB_DIR_BEGIN:
	push bx				                      ; ����װ�س���ƫ�Ƶ�ַ
	mov	cl, 1				                  ; 1������
	call	ReadSector		                  ; ������
;=============================================================================================================
	push cx
	push dx
	push si
	push di
	
	mov	di, bx	        			; ES:DI -> BaseOfRootDictionary:0100
	cmp	di, subdiroff						;�Ƿ��ǵ�һ�����������Ծ��
	jnz NOT_FIRST_VOL_INSUB_INSUB
FIRST_IGNORE_VOL_INSUB_INSUB:
	cld					                    ; ���DF��־λ DF=0��ʱ��, SI = SI + 1 , DI = DI + 1 
						                    ; �ñȽ��ַ���ʱ�ķ���Ϊ��/��[��������]
	add	di, 40h  							;���ü����Ŀ¼ǰ64���ֽ�
	mov	dx, 0eh		                    ; ѭ������=16��ÿ��������16���ļ���Ŀ��512/32=16��
	jmp LIST_SEARCH_FOR_USERFILE_INSUB
NOT_FIRST_VOL_INSUB_INSUB:
	cld					                    ; ���DF��־λ DF=0��ʱ��, SI = SI + 1 , DI = DI + 1 
						                    ; �ñȽ��ַ���ʱ�ķ���Ϊ��/��[��������]
	mov	dx, 10h		                    ; ѭ������=16��ÿ��������16���ļ���Ŀ��512/32=16��
LIST_SEARCH_FOR_USERFILE_INSUB:					;-------------------------------------------------------------------------------------
	mov bx, 0
	cmp	dx, 0			                    ; ѭ����������
	jz LIST_END_SEARCH_INSUB   				; ���Ѷ���һ����
	dec	dx				                    ; �ݼ�ѭ������ֵ��������һ����
LIST_CMP_DELETED_INSUB:
	cmp byte ptr es:[di], 0e5h				;��1�ֽ���0E5h��ʾ���ļ��Ѿ�ɾ��
	jz LIST_NEXT_FILE_MAP2_INSUB
	mov	cx, 11			                    ; ��ʼѭ������Ϊ11��Ϊ�ļ����ֽ���
LIST_CMP_FILENAME_INSUB:
	cmp byte ptr es:[di], 0					;�Ƚ���Ŀ�Ƿ���0��Ҳ����˵��Ŀ�Ƿ���null
	jnz LIST_GOON_LOOP_CMP_INSUB					;�����Ŀǰ11���ֽڶ���0����ô���ﲻ���ļ�
ADD_NULLNAME_INSUB_INSUB:
	inc bx									;
LIST_GOON_LOOP_CMP_INSUB:
	inc di
	loop LIST_CMP_FILENAME_INSUB
	
	cmp	bx, 11								;�����Ŀǰ11���ֽڶ���0����ô���ﲻ���ļ�
	jz	LIST_NEXT_FILE_MAP_INSUB		        ; ����Ƚ���11���ֽ�������ôһ������0����ʾ���ļ��ڵ�ǰ��Ŀ
LIST_PRINT_OUT_DIR_INFO1:
	call LIST_PRINT_OUT_DIR_INFO
LIST_NEXT_FILE_MAP_INSUB:
	and	di, 0FFE0h		                    ; DI &= E0Ϊ������ָ����Ŀ��ͷ����5λ���㣩
LIST_NEXT_FILE_MAP2_INSUB:				        ; FFE0h = 1111111111100000����5λ=32=Ŀ¼��Ŀ��С��
	add	di, 20h		                    	; DI += 20h ��һ��Ŀ¼��Ŀ
	jmp	LIST_SEARCH_FOR_USERFILE_INSUB            ;-------------------------------------------------------------------------------------
	
LIST_END_SEARCH_INSUB:
	pop di
	pop si
	pop dx
	pop cx
;=============================================================================================================
; �����ļ�����һ������
	pop bx				                      ; ȡ��װ�س���ƫ�Ƶ�ַ
	pop	ax				                      ; ȡ����������FAT�е����
	
	push ax
	mov ax, subdirbase						;-------------------------------------------------------------------------------------
	mov word ptr[GetFATEntryAddr], ax		;GetFATEntry�����жԻ���ַ��Ҫ����UserBaseAddress
	pop ax
	call GetFATEntry		                  ; ��ȡFAT���е���һ�غ�
	mov word ptr[GetFATEntryAddr], 0

	cmp	ax, 0FF8h		                      ; �Ƿ����ļ�����
	jae	LIST_NO_USERFILE                     ; ��FF8hʱ��ת���������һ����
	push ax				                      ; ����������FAT�е����
	mov	dx, RootDirSectors	                  ; DX = ��Ŀ¼������ = 14
	add	ax, dx			                      ; ������� + ��Ŀ¼������
	add	ax, DeltaSectorNo		              ; AX = Ҫ��������������ַ
	add	bx, word ptr [BPB_BytsPerSec]	      ; BX+512ָ��װ�س���������һ��������ַ
	jmp	LIST_SEARCH_IN_SUB_DIR_BEGIN
	
LIST_NO_USERFILE:
    pop di
	pop si
	pop bx
	mov es, bx
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
    ret      
	
LIST_PRINT_OUT_DIR_INFO:
	push ax
    push cx
    push dx
	push di
	
	and	di, 0FFE0h

	xor dx, dx
	mov dx,di			;ASCII�룬Ҫת��ASC�ַ�
	mov cx, 11
	
	push cx;����
	push dx;�ַ���ַ
	call near ptr _asc2char
	pop dx
	pop cx

	pop di
	pop dx
	pop cx
	pop ax
	ret
_listFileInfo endp

;----------------------------------------------------------------------------

errorloaded:
	; ��ӡ������Ϣ
	push ax
    push bx
    push cx
    push dx
	push es
	push bp
	
    mov ah,13h 	                    ; ���ܺ�
	mov al,0                 		; ���ŵ���β
	mov bl, 71h
	mov bh,0 	                	; ��0ҳ
	mov dh,0				 	    ; ��
	mov dl,2					    ; ��
	mov bp, offset errorLoad        ; BP=����ַ
	mov cx, 61 	                	; ����
	int 10h 
	
	pop bp
	pop ax
	mov es, ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret 
errorLoad:
		db 0ah,0dh
		db"              ---------Error loading !-----------            "
		db 0ah,0dh,'$'

