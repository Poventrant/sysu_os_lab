;=============================================================================================================
;   void _loadUserFile(char* UserFileName,int UserBaseAddress,int UserOffsetAddress, int userloadtoSec);
;=============================================================================================================
; 加载程序到内存,返回值是AX,1表示找到并加载成功，0表示没加载成功
UserFileName            dw  0           ; 文件名指针
UserBaseAddress         dw  0           ; 文件加载段地址
UserOffsetAddress       dw  0           ; 文件加载偏移地址
userloadtoSec 			dw  0            ; 当前的目录
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

	mov ax,[bp+4]                     	  ; 把传递进来的文件名指针放到 UserFileName
	mov word ptr[UserFileName],ax
	mov ax,[bp+6]
	mov word ptr[UserBaseAddress],ax      ; 把传递进来的基地址放到 UserBaseAddress
	mov ax,[bp+8]
	mov word ptr[UserOffsetAddress],ax    ; 把传递进来的偏移地址放到 UserOffsetAddress
	mov ax,[bp+10]
	mov word ptr[userloadtoSec],ax   	 ; 把传递进来的偏移地址放到 UserOffsetAddress
	
	push word ptr[userloadtoSec]
	push word ptr[UserFileName]
	call _searchFile
	pop word ptr[UserFileName]
	pop word ptr[userloadtoSec]
	
	cmp ax, -1
	jz LABEL_NO_USERFILE
	
	mov di, ax
LABEL_FILENAME_FOUND:	                      ; 找到 文件 后便来到这里继续
	; 计算文件的起始扇区号
	mov	ax, RootDirSectors	                  ; AX=根目录占用的扇区数
	and	di, 0FFE0h	                          ; DI -> 当前条目的开始地址
	add	di, 1Ah			                      ; DI -> 文件的首扇区号在条目中的偏移地址
	mov cx, word ptr es:[di]	              ; CX=文件的首扇区号
	push cx				                      ; 保存此扇区在FAT中的序号
	add	cx, ax			                      ; CX=文件的相对起始扇区号+根目录占用的扇区数
	add	cx, DeltaSectorNo	                  ; CL <- UserFileName的起始扇区号(0-based)
	mov ax,word ptr[UserBaseAddress]          ; 取基地址
	mov	es, ax			                      ; ES <- BaseOfRootDictionary（装载程序基址=9000h）
	mov bx,word ptr[UserOffsetAddress]        ; 取偏移地址
	mov	ax, cx		                          ; AX <- 起始扇区号

LABEL_GOON_LOADING_FILE:
	push bx				                      ; 保存装载程序偏移地址
	mov	cl, 1				                  ; 1个扇区------------------------------------------------------------------------------------
	call	ReadSector		                  ; 读扇区

	; 每读一个簇就在 "Booting  " 后面打一个点, 形成这样的效果：Booting ......
	mov	ah, 0Eh								  ; 功能号（以电传方式显示单个字符）
	mov	al, '.'							      ; 要显示的字符
	mov	bl, 0Fh								  ; 黑底白字
	int	10h									  ; 显示中断

	
	; 计算文件的下一扇区号
	pop bx				                      ; 取出装载程序偏移地址
	pop	ax				                      ; 取出此扇区在FAT中的序号
	
	push ax
	mov ax, word ptr[UserBaseAddress]		;-------------------------------------------------------------------------------------
	mov word ptr[GetFATEntryAddr], ax		;GetFATEntry里面有对基地址的要求是UserBaseAddress
	pop ax
	call GetFATEntry		                  ; 获取FAT项中的下一簇号
	mov word ptr[GetFATEntryAddr], 0

	cmp	ax, 0FF8h		                      ; 是否是文件最后簇
	jae	LABEL_FILE_LOADED                     ; ≥FF8h时跳转，否则读下一个簇
	push ax				                      ; 保存扇区在FAT中的序号
	mov	dx, RootDirSectors	                  ; DX = 根目录扇区数 = 14
	add	ax, dx			                      ; 扇区序号 + 根目录扇区数
	add	ax, DeltaSectorNo		              ; AX = 要读的数据扇区地址
	add	bx, word ptr [BPB_BytsPerSec]	      ; BX+512指向装载程序区的下一个扇区地址
	jmp	LABEL_GOON_LOADING_FILE
	
LABEL_FILE_LOADED:                            ; 完成加载
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
    ret                                       ; 没有找到 文件，在这里返回

_loadUserFile endp


;=============================================================================================================
;   int _ChangeDictionry(char dictionaryName, int infatherDirsEntry);
;	AX返回值，-1表示没这个子目录
;=============================================================================================================
dictionaryName dw 0					;要找的子目录的名字
infatherDirsEntry dw 0				;当前目录
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

	mov ax,[bp+4]                     	  ; 把传递进来的文件名指针放到 dictionaryName
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
CD_NO_USERFILE:						;返回值 -1 表示没找到
    pop di
	pop si
	pop bx
	mov es, bx
	pop dx
	pop cx
	pop bx
	pop bp
    ret                                 ; 没有找到 文件，在这里返回

CD_FILENAME_FOUND:	                      ; 找到 文件 后便来到这里继续
	; 计算文件的起始扇区号
	mov di, ax
	mov	ax, RootDirSectors	                  ; AX=根目录占用的扇区数
	and	di, 0FFE0h	                          ; DI -> 当前条目的开始地址
CD_CHECK_IF_IS_SUBDICTIONARY:	
	push di
	add	di, 0Bh
	cmp byte ptr es:[di], 10h					;文件属性是否是子目录-----------------------------------------
	jnz CD_IS_NOT_SUBDICTIONARY
	pop di
	
	add	di, 1Ah			                      ; DI -> 文件的首扇区号在条目中的偏移地址
	mov cx, word ptr es:[di]	              ; CX=文件的首扇区号
	push cx				                      ; 保存此扇区在FAT中的序号
	pop ax		                          	  ; AX <- 此扇区在FAT中的序号------返回值
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
;	AX返回值，-1表示没这个子目录
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
	
	mov ax,[bp+4]                     	  ; 把传递进来的文件名指针放到 dictionaryName
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
	and	di, 0FFE0h	                          ; DI -> 当前条目的开始地址
	mov byte ptr es:[di], 0e5h				  ;删除的的标志是目录条第一个字节为e5h	
	
	;这时候es:bx在_searchFile之后都没变
	mov cl, 1 ;要写1个扇区
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
; 加载程序到内存
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
	
	mov ax,[bp+4]                     	  ; 把传递进来的文件名指针放到 dictionaryName
	mov word ptr[firstSector],ax 
; 软驱复位
	xor	ah, ah                       	  ; 功能号ah=0（复位磁盘驱动器）
	xor	dl, dl                      	  ; dl=0（软驱，硬盘和U盘为80h）
	int	13h		                    	  ; 磁盘中断
	
	cmp word ptr[firstSector], 0		;当前的目录是否是根目录
	jnz LIST_SEARCH_IN_SUB_DIR_BEGIN0
	
	mov	word ptr [wSectorNo], SectorNoOfRootDirectory 	; 给表示当前扇区号的变量wSectorNo赋初值为根目录区的首扇区号（=19）
	mov word ptr[wRootDirSizeForLoop], RootDirSectors

LIST_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word ptr [wRootDirSizeForLoop], 0	; 判断根目录区是否已读完
	jz	LIST_FINISH_DIR	             	; 若读完则表示未找到UserFileName
	dec	word ptr [wRootDirSizeForLoop]	    ; 递减变量wRootDirSizeForLoop的值
	; 调用读扇区函数读入一个根目录扇区到装载区
	mov	ax, BaseOfRootDictionary
	mov	es, ax			                    ; ES <- BaseOfRootDictionary
	mov	bx, OffsetOfRootDictionary	        ; BX <- OffsetOfRootDictionary
	mov	ax, word ptr [wSectorNo]	        ; AX <- 根目录中的当前扇区号
	mov	cl, 1				                ; 只读一个扇区
	call	ReadSector		                ; 调用读扇区函数
	
	mov	di, OffsetOfRootDictionary	        ; ES:DI -> BaseOfRootDictionary:0100
	cmp	word ptr [wRootDirSizeForLoop], 13	;是否是第一个扇区，忽略卷标
	jnz FIRST_IGNORE_VOL
	add	di, 20h  							;不用检查MYOS SYSTEM卷标
FIRST_IGNORE_VOL:
	cld					                    ; 清除DF标志位 DF=0的时候, SI = SI + 1 , DI = DI + 1 
						                    ; 置比较字符串时的方向为左/上[索引增加]
	mov	dx, 10h			                    ; 循环次数=16（每个扇区有16个文件条目：512/32=16）
LIST_SEARCH_FOR_USERFILE:					;-------------------------------------------------------------------------------------
	mov bx, 0
	cmp	dx, 0			                    ; 循环次数控制
	jz LIST_GOTO_NEXT_SECTOR_IN_ROOT_DIR    ; 若已读完一扇区
	dec	dx				                    ; 递减循环次数值，跳到下一扇区
LIST_CMP_DELETED:
	cmp byte ptr es:[di], 0e5h				;第1字节是0E5h表示此文件已经删除
	jz LIST_NEXT_FILE_MAP2
	mov	cx, 11			                    ; 初始循环次数为11，为文件名字节数
LIST_CMP_FILENAME:
	cmp byte ptr es:[di], 0					;比较条目是否都是0，也就是说条目是否是null
	jnz LIST_GOON_LOOP_CMP					;如果条目前11个字节都是0，那么这里不有文件
ADD_NULLNAME:
	inc bx									;
LIST_GOON_LOOP_CMP:
	inc di
	loop LIST_CMP_FILENAME
	cmp	bx, 11								;如果条目前11个字节都是0，那么这里不有文件
	jz	LIST_NEXT_FILE_MAP		        ; 如果比较了11个字节中有那么一个不是0，表示有文件在当前条目
LIST_PRINT_OUT_DIR_INFO0:
	call LIST_PRINT_OUT_DIR_INFO
LIST_NEXT_FILE_MAP:
	and	di, 0FFE0h		                    ; DI &= E0为了让它指向本条目开头（低5位清零）
LIST_NEXT_FILE_MAP2:				        ; FFE0h = 1111111111100000（低5位=32=目录条目大小）
	add	di, 20h		                    	; DI += 20h 下一个目录条目
	jmp	LIST_SEARCH_FOR_USERFILE            ;-------------------------------------------------------------------------------------

LIST_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word ptr [wSectorNo], 1             ; 递增当前扇区号
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
    ret                                       ; 没有找到 文件，在这里返回
;=============================================================================================================
;=============================================================================================================
LIST_SEARCH_IN_SUB_DIR_BEGIN0:
	mov	ax, RootDirSectors	                  ; AX=根目录占用的扇区数
	mov cx, word ptr [firstSector]	              ; CX=文件的首扇区号
	push cx				                      ; 保存此扇区在FAT中的序号
	add	cx, ax			                      ; CX=文件的相对起始扇区号+根目录占用的扇区数
	add	cx, DeltaSectorNo	                  ; CL <- UserFileName的起始扇区号(0-based)
	mov ax,subdirbase		         		 ; 取基地址
	mov	es, ax			                      ; ES <- BaseOfRootDictionary（装载程序基址=9000h）
	mov bx,subdiroff	         			 ; 取偏移地址
	mov	ax, cx		                          ; AX <- 起始扇区号
LIST_SEARCH_IN_SUB_DIR_BEGIN:
	push bx				                      ; 保存装载程序偏移地址
	mov	cl, 1				                  ; 1个扇区
	call	ReadSector		                  ; 读扇区
;=============================================================================================================
	push cx
	push dx
	push si
	push di
	
	mov	di, bx	        			; ES:DI -> BaseOfRootDictionary:0100
	cmp	di, subdiroff						;是否是第一个扇区，忽略卷标
	jnz NOT_FIRST_VOL_INSUB_INSUB
FIRST_IGNORE_VOL_INSUB_INSUB:
	cld					                    ; 清除DF标志位 DF=0的时候, SI = SI + 1 , DI = DI + 1 
						                    ; 置比较字符串时的方向为左/上[索引增加]
	add	di, 40h  							;不用检查子目录前64个字节
	mov	dx, 0eh		                    ; 循环次数=16（每个扇区有16个文件条目：512/32=16）
	jmp LIST_SEARCH_FOR_USERFILE_INSUB
NOT_FIRST_VOL_INSUB_INSUB:
	cld					                    ; 清除DF标志位 DF=0的时候, SI = SI + 1 , DI = DI + 1 
						                    ; 置比较字符串时的方向为左/上[索引增加]
	mov	dx, 10h		                    ; 循环次数=16（每个扇区有16个文件条目：512/32=16）
LIST_SEARCH_FOR_USERFILE_INSUB:					;-------------------------------------------------------------------------------------
	mov bx, 0
	cmp	dx, 0			                    ; 循环次数控制
	jz LIST_END_SEARCH_INSUB   				; 若已读完一扇区
	dec	dx				                    ; 递减循环次数值，跳到下一扇区
LIST_CMP_DELETED_INSUB:
	cmp byte ptr es:[di], 0e5h				;第1字节是0E5h表示此文件已经删除
	jz LIST_NEXT_FILE_MAP2_INSUB
	mov	cx, 11			                    ; 初始循环次数为11，为文件名字节数
LIST_CMP_FILENAME_INSUB:
	cmp byte ptr es:[di], 0					;比较条目是否都是0，也就是说条目是否是null
	jnz LIST_GOON_LOOP_CMP_INSUB					;如果条目前11个字节都是0，那么这里不有文件
ADD_NULLNAME_INSUB_INSUB:
	inc bx									;
LIST_GOON_LOOP_CMP_INSUB:
	inc di
	loop LIST_CMP_FILENAME_INSUB
	
	cmp	bx, 11								;如果条目前11个字节都是0，那么这里不有文件
	jz	LIST_NEXT_FILE_MAP_INSUB		        ; 如果比较了11个字节中有那么一个不是0，表示有文件在当前条目
LIST_PRINT_OUT_DIR_INFO1:
	call LIST_PRINT_OUT_DIR_INFO
LIST_NEXT_FILE_MAP_INSUB:
	and	di, 0FFE0h		                    ; DI &= E0为了让它指向本条目开头（低5位清零）
LIST_NEXT_FILE_MAP2_INSUB:				        ; FFE0h = 1111111111100000（低5位=32=目录条目大小）
	add	di, 20h		                    	; DI += 20h 下一个目录条目
	jmp	LIST_SEARCH_FOR_USERFILE_INSUB            ;-------------------------------------------------------------------------------------
	
LIST_END_SEARCH_INSUB:
	pop di
	pop si
	pop dx
	pop cx
;=============================================================================================================
; 计算文件的下一扇区号
	pop bx				                      ; 取出装载程序偏移地址
	pop	ax				                      ; 取出此扇区在FAT中的序号
	
	push ax
	mov ax, subdirbase						;-------------------------------------------------------------------------------------
	mov word ptr[GetFATEntryAddr], ax		;GetFATEntry里面有对基地址的要求是UserBaseAddress
	pop ax
	call GetFATEntry		                  ; 获取FAT项中的下一簇号
	mov word ptr[GetFATEntryAddr], 0

	cmp	ax, 0FF8h		                      ; 是否是文件最后簇
	jae	LIST_NO_USERFILE                     ; ≥FF8h时跳转，否则读下一个簇
	push ax				                      ; 保存扇区在FAT中的序号
	mov	dx, RootDirSectors	                  ; DX = 根目录扇区数 = 14
	add	ax, dx			                      ; 扇区序号 + 根目录扇区数
	add	ax, DeltaSectorNo		              ; AX = 要读的数据扇区地址
	add	bx, word ptr [BPB_BytsPerSec]	      ; BX+512指向装载程序区的下一个扇区地址
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
	mov dx,di			;ASCII码，要转成ASC字符
	mov cx, 11
	
	push cx;长度
	push dx;字符地址
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
	; 打印错误信息
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
	mov bp, offset errorLoad        ; BP=串地址
	mov cx, 61 	                	; 串长
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

