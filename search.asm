
;����
BaseOfRootDictionary	equ	1000h	    ; ��Ŀ¼ ----  �ε�ַ
OffsetOfRootDictionary	equ	9000h	    ; ��Ŀ¼ ---- ƫ�Ƶ�ַ
RootDirSectors	        equ	14		    ; ��Ŀ¼ռ�õ�������
SectorNoOfRootDirectory	equ	19	        ; ��Ŀ¼������������
SectorNoOfFAT1	        equ	1		    ; FAT#1���������� = BPB_RsvdSecCnt
DeltaSectorNo		    equ	17		    ; DeltaSectorNo = BPB_RsvdSecCnt + 
							            ; (BPB_NumFATs * FATSz) - 2 = 1 + (2*9) -2 = 17
					            		; �ļ��Ŀ�ʼ������ = Ŀ¼��Ŀ�еĿ�ʼ������ 
						            	; + ��Ŀ¼ռ��������Ŀ + DeltaSectorNo

wRootDirSizeForLoop	    dw	RootDirSectors	; ��Ŀ¼��ʣ��������
										; ��ʼ��Ϊ14����ѭ���л�ݼ�����
wSectorNo	         	dw	0           ; ��ǰ�����ţ���ʼ��Ϊ0����ѭ���л����
bOdd         			db	0          	; ��������ż��FAT��

BPB_BytsPerSec       	dw 512          ; ÿ�����ֽ���
BPB_SecPerTrk	        dw 18	        ; ÿ�ŵ�������
BS_DrvNum		        db 0	        ; �ж� 13 ���������ţ�����

GetFATEntryAddr			dw 0			;GetFATEntry����ַ
;=============================================================================================================
;   int _searchFile(char filename, int currentdir);
; AX��Ϊ����ֵΪ��file���ڵ�������,-1��ʾû�ҵ�,
; es��Ϊ�ε�ַҲ���ظ���bx��Ϊƫ�Ƶ�ַҲ���ظ�
;=============================================================================================================
filename dw 0	;Ҫ�ҵ��ļ�������
currentdir dw 0	;��ǰ��Ŀ¼��·����
public _searchFile
_searchFile proc
	push bp
	mov bp,sp
	push cx
	push dx
	push si
	push di
	
	mov ax,[bp+4]                     	  ; �Ѵ��ݽ������ļ���ָ��ŵ� filename
	mov word ptr[filename],ax   
	mov ax,[bp+6] 
	mov word ptr[currentdir],ax 

; ������λ
	xor	ah, ah                       	  ; ���ܺ�ah=0����λ������������
	xor	dl, dl                      	  ; dl=0��������Ӳ�̺�U��Ϊ80h��
	int	13h		                    	  ; �����ж�

	cmp word ptr[currentdir], 0		;��ǰ��Ŀ¼�Ƿ��Ǹ�Ŀ¼
	jnz SEARCH_IN_SUB_DIR_BEGIN0
	
SEARCH_IN_ROOT_DIR_BEGIN0:
	mov	word ptr [wSectorNo], SectorNoOfRootDirectory 	; ����ʾ��ǰ�����ŵı���wSectorNo����ֵΪ��Ŀ¼�����������ţ�=19��
	mov word ptr[wRootDirSizeForLoop], RootDirSectors

SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word ptr [wRootDirSizeForLoop], 0	; �жϸ�Ŀ¼���Ƿ��Ѷ���
	jz	NO_USERFILE0	             	; ���������ʾδ�ҵ�UserFileName
	dec	word ptr [wRootDirSizeForLoop]	    ; �ݼ�����wRootDirSizeForLoop��ֵ
	; ���ö�������������һ����Ŀ¼������װ����
	mov	ax, BaseOfRootDictionary
	mov	es, ax			                    ; ES <- BaseOfRootDictionary
	mov	bx, OffsetOfRootDictionary	                ; BX <- OffsetOfRootDictionary
	mov	ax, word ptr [wSectorNo]	        ; AX <- ��Ŀ¼�еĵ�ǰ������
	mov	cl, 1				                ; ֻ��һ������
	call	ReadSector		                ; ���ö���������
	
SEARCH_FOR_USERFILE0:
	mov	ax,word ptr[filename]	        ; DS:SI -> "FILENAME  BIN"
	mov si,ax
	mov	di, OffsetOfRootDictionary	        ; ES:DI -> BaseOfRootDictionary:0100
	cld					                    ; ���DF��־λ
						                    ; �ñȽ��ַ���ʱ�ķ���Ϊ��/��[��������]										
	mov	dx, 10h			                    ; ѭ������=16��ÿ��������16���ļ���Ŀ��512/32=16��
SEARCH_FOR_USERFILE:
	cmp	dx, 0			                    ; ѭ����������
	jz GOTO_NEXT_SECTOR_IN_ROOT_DIR   	; ���Ѷ���һ����
	dec	dx				                    ; �ݼ�ѭ������ֵ��������һ����
	mov	cx, 11			                    ; ��ʼѭ������Ϊ11��Ϊ�ļ����ֽ���
CMP_FILENAME:
	repe cmpsb			                    ; �ظ��Ƚ��ַ����е��ַ���CX--��ֱ������Ȼ�CX=0
	cmp	cx, 0
	jz	GET_USERFILE0	           		 ; ����Ƚ���11���ַ�����ȣ���ʾ�ҵ�
DIFFERENT:
	and	di, 0FFE0h		                    ; DI &= E0Ϊ������ָ����Ŀ��ͷ����5λ���㣩
					                        ; FFE0h = 1111111111100000����5λ=32=Ŀ¼��Ŀ��С��
	add	di, 20h		                    	; DI += 20h ��һ��Ŀ¼��Ŀ
	mov	ax,word ptr [filename]          	; SIָ��װ���ļ���������ʼ��ַ
	mov si,ax
	jmp	SEARCH_FOR_USERFILE           	; ת��ѭ����ʼ��

GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word ptr [wSectorNo], 1             ; ������ǰ������
	jmp	SEARCH_IN_ROOT_DIR_BEGIN
	
NO_USERFILE0: jmp NO_USERFILE
GET_USERFILE0: jmp GET_USERFILE
;=============================================================================================================
;=============================================================================================================
SEARCH_IN_SUB_DIR_BEGIN0:
	mov	ax, RootDirSectors	                  ; AX=��Ŀ¼ռ�õ�������
	mov cx, word ptr [currentdir]	              ; CX=�ļ�����������
	push cx				                      ; �����������FAT�е����
	add	cx, ax			                      ; CX=�ļ��������ʼ������+��Ŀ¼ռ�õ�������
	add	cx, DeltaSectorNo	                  ; CL <- UserFileName����ʼ������(0-based)
	mov ax,subdirbase		          ; ȡ����ַ
	mov	es, ax			                      ; ES <- BaseOfRootDictionary��װ�س����ַ=9000h��
	mov bx,subdiroff	          ; ȡƫ�Ƶ�ַ
	mov	ax, cx		                          ; AX <- ��ʼ������
SEARCH_IN_SUB_DIR_BEGIN:
	push bx				                      ; ����װ�س���ƫ�Ƶ�ַ
	mov	cl, 1				                  ; 1������
	call	ReadSector		                  ; ������
	
;=============================================================================================================
	push cx
	push dx
	push si
	push di
	
	mov	ax,word ptr[filename]	        ; DS:SI -> "FILENAME  BIN"
	mov si,ax
	mov	di, bx	       						; ES:DI -> BaseOfRootDictionary:0100-----------------------------------------------------------------------------
	cld					                    ; ���DF��־λ
	mov	dx, 10h			                    ; ѭ������=16��ÿ��������16���ļ���Ŀ��512/32=16��
SEARCH_FOR_USERFILE_INCURRENTDIR:
	cmp	dx, 0			                    ; ѭ����������
	jz END_SUB_SEARCH   					; ���Ѷ���һ����
	dec	dx				                    ; �ݼ�ѭ������ֵ��������һ����
	mov	cx, 11			                    ; ��ʼѭ������Ϊ11��Ϊ�ļ����ֽ���
CMP_FILENAME_INCURRENTDIR:
	repe cmpsb			                    ; �ظ��Ƚ��ַ����е��ַ���CX--��ֱ������Ȼ�CX=0
	cmp	cx, 0
	jz	FILENAME_FOUND_INCURRENTDIR	           		 ; ����Ƚ���11���ַ�����ȣ���ʾ�ҵ�
DIFFERENT_INCURRENTDIR:
	and	di, 0FFE0h		                    ; DI &= E0Ϊ������ָ����Ŀ��ͷ����5λ���㣩
					                        ; FFE0h = 1111111111100000����5λ=32=Ŀ¼��Ŀ��С��
	add	di, 20h		                    	; DI += 20h ��һ��Ŀ¼��Ŀ
	mov	ax,word ptr [filename]          	; SIָ��װ���ļ���������ʼ��ַ
	mov si,ax
	jmp	SEARCH_FOR_USERFILE_INCURRENTDIR           	; ת��ѭ����ʼ��
	
END_SUB_SEARCH:
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
	jae	NO_USERFILE                     	  ; ��FF8hʱ��ת���������һ����
	push ax				                      ; ����������FAT�е����
	mov	dx, RootDirSectors	                  ; DX = ��Ŀ¼������ = 14
	add	ax, dx			                      ; ������� + ��Ŀ¼������
	add	ax, DeltaSectorNo		              ; AX = Ҫ��������������ַ
	add	bx, word ptr [BPB_BytsPerSec]	      ; BX+512ָ��װ�س���������һ��������ַ
	jmp	SEARCH_IN_SUB_DIR_BEGIN
	
FILENAME_FOUND_INCURRENTDIR:
	pop ax								;�ҵ��ˣ�di���ûظ�
	pop si
	pop dx
	pop cx
	
	pop bx								; ; ȡ��װ�س���ƫ�Ƶ�ַ
	pop ax								;; ȡ����������FAT�е����
GET_USERFILE:
	mov ax, di							;ax��Ϊ����ֵ���di������
	jmp SEARCH_FILE_END
	
NO_USERFILE:
	mov ax, -1
SEARCH_FILE_END:
	pop di
	pop si
	pop dx
	pop cx
	pop bp
	ret
_searchFile endp

;----------------------------------------------------------------------------
; ��������ReadSector
;----------------------------------------------------------------------------
; ���ã��ӵ� AX��������ʼ����CL����������ES:BX��
ReadSector:
	; -----------------------------------------------------------------------
	; �������������������ڴ����е�λ�� (������->����š���ʼ��������ͷ��)
	; -----------------------------------------------------------------------
	; ��������Ϊ x
	;                             �� ����� = y >> 1
	;       x              �� �� y ��
	;   -------------- 	=> ��      �� ��ͷ�� = y & 1
	;  ÿ�ŵ�������        ��
	;                      �� �� z => ��ʼ������ = z + 1
	push bp		                    ; ����BP
	mov bp, sp	                    ; ��BP=SP
	sub	sp, 2 	                    ; �ٳ������ֽڵĶ�ջ���򱣴�Ҫ����������: byte [bp-2]
	mov	byte [bp-2], cl	            ; ѹCL��ջ�������ʾ�����������Ĵ��ݲ�����
	push bx			                ; ����BX
	mov	bl, byte ptr [BPB_SecPerTrk]; BL=18���ŵ���������Ϊ����
	div	bl			                ; AX/BL����y��AL�С�����z��AH��
	inc	ah	                		; z ++������̵���ʼ������Ϊ1��
	mov	cl, ah	                	; CL <- ��ʼ������
	mov	dh, al	                	; DH <- y
	shr	al, 1		                ; y >> 1 ���ȼ���y/BPB_NumHeads��������2����ͷ��
	mov	ch, al	                	; CH <- �����
	and	dh, 1	                	; DH & 1 = ��ͷ��
	pop	bx		                	; �ָ�BX
									; ���ˣ�"����š���ʼ��������ͷ��"��ȫ���õ�
	mov	dl, byte ptr [BS_DrvNum]	; �������ţ�0��ʾ����A��
.GoOnReading:					    ; ʹ�ô����ж϶�������
	mov	ah, 2			        	; ���ܺţ���������
	mov	al, byte [bp-2]		        ; ��AL������
	int	13h			             	; �����ж�
	jc	.GoOnReading                ; �����ȡ����CF�ᱻ��Ϊ1��
					              	; ��ʱ�Ͳ�ͣ�ض���ֱ����ȷΪֹ
	add	sp, 2				        ; ջָ��+2
	pop	bp				            ; �ָ�BP

	ret

;----------------------------------------------------------------------------
; ��������WriteSector
;----------------------------------------------------------------------------
; ���ã��ӵ� AX��������ʼ����cl������д��ES:BX
WriteSector:
	; -----------------------------------------------------------------------
	; �������������������ڴ����е�λ�� (������->����š���ʼ��������ͷ��)
	; -----------------------------------------------------------------------
	; ��������Ϊ x
	;                             �� ����� = y >> 1
	;       x              �� �� y ��
	;   -------------- 	=> ��      �� ��ͷ�� = y & 1
	;  ÿ�ŵ�������        ��
	;                      �� �� z => ��ʼ������ = z + 1
	push bp		                    ; ����BP
	mov bp, sp	                    ; ��BP=SP
	sub	sp, 2 	                    ; �ٳ������ֽڵĶ�ջ���򱣴�Ҫ����������: byte [bp-2]
	mov	byte [bp-2], cl	            ; ѹCL��ջ�������ʾ�����������Ĵ��ݲ�����
	push bx			                ; ����BX
	mov	bl, byte ptr [BPB_SecPerTrk]; BL=18���ŵ���������Ϊ����
	div	bl			                ; AX/BL����y��AL�С�����z��AH��
	inc	ah	                		; z ++������̵���ʼ������Ϊ1��
	mov	cl, ah	                	; CL <- ��ʼ������
	mov	dh, al	                	; DH <- y
	shr	al, 1		                ; y >> 1 ���ȼ���y/BPB_NumHeads��������2����ͷ��
	mov	ch, al	                	; CH <- �����
	and	dh, 1	                	; DH & 1 = ��ͷ��
	pop	bx		                	; �ָ�BX
									; ���ˣ�"����š���ʼ��������ͷ��"��ȫ���õ�
	mov	dl, byte ptr [BS_DrvNum]	; �������ţ�0��ʾ����A��
.GoOnWriting:					    ; ʹ�ô����ж϶�������
	mov	ah, 3			        	; ���ܺţ�д������
	mov	al, byte [bp-2]		        ; дAL������
	int	13h			             	; �����ж�
	call setint21
	mov ax,4c00h
	int 21h
	call resetint21
	jc	.GoOnWriting                ; �����ȡ����CF�ᱻ��Ϊ1��
					              	; ��ʱ�Ͳ�ͣ�ض���ֱ����ȷΪֹ
	add	sp, 2				        ; ջָ��+2
	pop	bp				            ; �ָ�BP

	ret

;----------------------------------------------------------------------------
; ��������GetFATEntry
;----------------------------------------------------------------------------
; ���ã��ҵ����ΪAX��������FAT�е���Ŀ���������AX�С���Ҫע���
;     �ǣ��м���Ҫ��FAT��������ES:BX�������Ժ���һ��ʼ������ES��BX
;  ����ֵax:��һ���غ�,��Ҫע��غŴ��ڵ���0xFF8��ʾ�ļ������һ����,Ϊ0xFF7��
GetFATEntry:
	push bx
	push es			            ; ����ES��BX��AX����ջ��
	push bp
	push ax
; ���ö����FAT����д��Ļ���ַ
	mov ax,word ptr[GetFATEntryAddr]
	sub	ax, 100h	          	; ��BaseOfRootDictionary��������4K�ռ����ڴ��FAT
	mov	es, ax		            ; ES=8F00h
; �ж�FAT�����ż
	pop	ax	            		; ȡ��FAT����ţ���ջ��
	mov	byte ptr [bOdd], 0 		; ��ʼ����ż����ֵΪ0��ż��
	mov	bx, 3            		; AX*1.5 = (AX*3)/2
	mul	bx		            	; DX:AX = AX * 3��AX*BX �Ľ��ֵ����DX:AX�У�
	mov	bx, 2	            	; BX = 2��������
	xor	dx, dx	            	; DX=0	
	div	bx		            	; DX:AX / 2 => AX <- �̡�DX <- ����
	cmp	dx, 0	            	; ���� = 0��ż������
	jz LABEL_EVEN            	; ż����ת
	mov	byte ptr [bOdd], 1    	; ����
LABEL_EVEN:	                	; ż��
	; ����AX����FAT����FAT�е�ƫ������������
	; ����FAT�����ĸ�������(FATռ�ò�ֹһ������)
	xor	dx, dx	            	; DX=0	
	mov	bx, [BPB_BytsPerSec]	; BX=512
	div	bx		            	; DX:AX / 512
		  		            	; AX <- �� (FAT�����ڵ����������FAT��������)
		  		            	; DX <- ���� (FAT���������ڵ�ƫ��)
	push dx		            	; ������������ջ��
	mov bx, 0 	            	; BX <- 0 ���ǣ�ES:BX = 8F00h:0
	add	ax, SectorNoOfFAT1      ; �˾�֮���AX����FAT�����ڵ�������
	mov	cl, 2			        ; ��ȡFAT�����ڵ�������һ�ζ������������ڱ߽�
	call ReadSector            	; ��������, ��Ϊһ�� FAT����ܿ�Խ��������
	pop	dx		            	; DX= FAT���������ڵ�ƫ�ƣ���ջ��
	add	bx, dx	            	; BX= FAT���������ڵ�ƫ��
	mov bp,bx
	mov	ax, word ptr es:[bx]	; AX= FAT��ֵ
	cmp	byte ptr [bOdd], 1	    ; �Ƿ�Ϊ�����
	jnz	LABEL_EVEN_2         	; ż����ת
	shr	ax, 4			        ; ����������4λ��ȡ��12λ��
LABEL_EVEN_2:	            	; ż��
	and	ax, 0FFFh            	; ȡ��12λ
LABEL_GET_FAT_ENRY_OK:
    pop bp
	pop	bx		            	; �ָ�ES��BX����ջ��
	mov es,bx					;-----------------------------------------------------------------��������Ϊbx�����������Ķ�û��Ҫ
	pop bx
	ret