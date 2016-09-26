
;变量
BaseOfRootDictionary	equ	1000h	    ; 根目录 ----  段地址
OffsetOfRootDictionary	equ	9000h	    ; 根目录 ---- 偏移地址
RootDirSectors	        equ	14		    ; 根目录占用的扇区数
SectorNoOfRootDirectory	equ	19	        ; 根目录区的首扇区号
SectorNoOfFAT1	        equ	1		    ; FAT#1的首扇区号 = BPB_RsvdSecCnt
DeltaSectorNo		    equ	17		    ; DeltaSectorNo = BPB_RsvdSecCnt + 
							            ; (BPB_NumFATs * FATSz) - 2 = 1 + (2*9) -2 = 17
					            		; 文件的开始扇区号 = 目录条目中的开始扇区号 
						            	; + 根目录占用扇区数目 + DeltaSectorNo

wRootDirSizeForLoop	    dw	RootDirSectors	; 根目录区剩余扇区数
										; 初始化为14，在循环中会递减至零
wSectorNo	         	dw	0           ; 当前扇区号，初始化为0，在循环中会递增
bOdd         			db	0          	; 奇数还是偶数FAT项

BPB_BytsPerSec       	dw 512          ; 每扇区字节数
BPB_SecPerTrk	        dw 18	        ; 每磁道扇区数
BS_DrvNum		        db 0	        ; 中断 13 的驱动器号（软盘

GetFATEntryAddr			dw 0			;GetFATEntry基地址
;=============================================================================================================
;   int _searchFile(char filename, int currentdir);
; AX作为返回值为该file所在的扇区号,-1表示没找到,
; es作为段地址也不回复，bx作为偏移地址也不回复
;=============================================================================================================
filename dw 0	;要找的文件的名字
currentdir dw 0	;当前的目录（路径）
public _searchFile
_searchFile proc
	push bp
	mov bp,sp
	push cx
	push dx
	push si
	push di
	
	mov ax,[bp+4]                     	  ; 把传递进来的文件名指针放到 filename
	mov word ptr[filename],ax   
	mov ax,[bp+6] 
	mov word ptr[currentdir],ax 

; 软驱复位
	xor	ah, ah                       	  ; 功能号ah=0（复位磁盘驱动器）
	xor	dl, dl                      	  ; dl=0（软驱，硬盘和U盘为80h）
	int	13h		                    	  ; 磁盘中断

	cmp word ptr[currentdir], 0		;当前的目录是否是根目录
	jnz SEARCH_IN_SUB_DIR_BEGIN0
	
SEARCH_IN_ROOT_DIR_BEGIN0:
	mov	word ptr [wSectorNo], SectorNoOfRootDirectory 	; 给表示当前扇区号的变量wSectorNo赋初值为根目录区的首扇区号（=19）
	mov word ptr[wRootDirSizeForLoop], RootDirSectors

SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word ptr [wRootDirSizeForLoop], 0	; 判断根目录区是否已读完
	jz	NO_USERFILE0	             	; 若读完则表示未找到UserFileName
	dec	word ptr [wRootDirSizeForLoop]	    ; 递减变量wRootDirSizeForLoop的值
	; 调用读扇区函数读入一个根目录扇区到装载区
	mov	ax, BaseOfRootDictionary
	mov	es, ax			                    ; ES <- BaseOfRootDictionary
	mov	bx, OffsetOfRootDictionary	                ; BX <- OffsetOfRootDictionary
	mov	ax, word ptr [wSectorNo]	        ; AX <- 根目录中的当前扇区号
	mov	cl, 1				                ; 只读一个扇区
	call	ReadSector		                ; 调用读扇区函数
	
SEARCH_FOR_USERFILE0:
	mov	ax,word ptr[filename]	        ; DS:SI -> "FILENAME  BIN"
	mov si,ax
	mov	di, OffsetOfRootDictionary	        ; ES:DI -> BaseOfRootDictionary:0100
	cld					                    ; 清除DF标志位
						                    ; 置比较字符串时的方向为左/上[索引增加]										
	mov	dx, 10h			                    ; 循环次数=16（每个扇区有16个文件条目：512/32=16）
SEARCH_FOR_USERFILE:
	cmp	dx, 0			                    ; 循环次数控制
	jz GOTO_NEXT_SECTOR_IN_ROOT_DIR   	; 若已读完一扇区
	dec	dx				                    ; 递减循环次数值，跳到下一扇区
	mov	cx, 11			                    ; 初始循环次数为11，为文件名字节数
CMP_FILENAME:
	repe cmpsb			                    ; 重复比较字符串中的字符，CX--，直到不相等或CX=0
	cmp	cx, 0
	jz	GET_USERFILE0	           		 ; 如果比较了11个字符都相等，表示找到
DIFFERENT:
	and	di, 0FFE0h		                    ; DI &= E0为了让它指向本条目开头（低5位清零）
					                        ; FFE0h = 1111111111100000（低5位=32=目录条目大小）
	add	di, 20h		                    	; DI += 20h 下一个目录条目
	mov	ax,word ptr [filename]          	; SI指向装载文件名串的起始地址
	mov si,ax
	jmp	SEARCH_FOR_USERFILE           	; 转到循环开始处

GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word ptr [wSectorNo], 1             ; 递增当前扇区号
	jmp	SEARCH_IN_ROOT_DIR_BEGIN
	
NO_USERFILE0: jmp NO_USERFILE
GET_USERFILE0: jmp GET_USERFILE
;=============================================================================================================
;=============================================================================================================
SEARCH_IN_SUB_DIR_BEGIN0:
	mov	ax, RootDirSectors	                  ; AX=根目录占用的扇区数
	mov cx, word ptr [currentdir]	              ; CX=文件的首扇区号
	push cx				                      ; 保存此扇区在FAT中的序号
	add	cx, ax			                      ; CX=文件的相对起始扇区号+根目录占用的扇区数
	add	cx, DeltaSectorNo	                  ; CL <- UserFileName的起始扇区号(0-based)
	mov ax,subdirbase		          ; 取基地址
	mov	es, ax			                      ; ES <- BaseOfRootDictionary（装载程序基址=9000h）
	mov bx,subdiroff	          ; 取偏移地址
	mov	ax, cx		                          ; AX <- 起始扇区号
SEARCH_IN_SUB_DIR_BEGIN:
	push bx				                      ; 保存装载程序偏移地址
	mov	cl, 1				                  ; 1个扇区
	call	ReadSector		                  ; 读扇区
	
;=============================================================================================================
	push cx
	push dx
	push si
	push di
	
	mov	ax,word ptr[filename]	        ; DS:SI -> "FILENAME  BIN"
	mov si,ax
	mov	di, bx	       						; ES:DI -> BaseOfRootDictionary:0100-----------------------------------------------------------------------------
	cld					                    ; 清除DF标志位
	mov	dx, 10h			                    ; 循环次数=16（每个扇区有16个文件条目：512/32=16）
SEARCH_FOR_USERFILE_INCURRENTDIR:
	cmp	dx, 0			                    ; 循环次数控制
	jz END_SUB_SEARCH   					; 若已读完一扇区
	dec	dx				                    ; 递减循环次数值，跳到下一扇区
	mov	cx, 11			                    ; 初始循环次数为11，为文件名字节数
CMP_FILENAME_INCURRENTDIR:
	repe cmpsb			                    ; 重复比较字符串中的字符，CX--，直到不相等或CX=0
	cmp	cx, 0
	jz	FILENAME_FOUND_INCURRENTDIR	           		 ; 如果比较了11个字符都相等，表示找到
DIFFERENT_INCURRENTDIR:
	and	di, 0FFE0h		                    ; DI &= E0为了让它指向本条目开头（低5位清零）
					                        ; FFE0h = 1111111111100000（低5位=32=目录条目大小）
	add	di, 20h		                    	; DI += 20h 下一个目录条目
	mov	ax,word ptr [filename]          	; SI指向装载文件名串的起始地址
	mov si,ax
	jmp	SEARCH_FOR_USERFILE_INCURRENTDIR           	; 转到循环开始处
	
END_SUB_SEARCH:
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
	jae	NO_USERFILE                     	  ; ≥FF8h时跳转，否则读下一个簇
	push ax				                      ; 保存扇区在FAT中的序号
	mov	dx, RootDirSectors	                  ; DX = 根目录扇区数 = 14
	add	ax, dx			                      ; 扇区序号 + 根目录扇区数
	add	ax, DeltaSectorNo		              ; AX = 要读的数据扇区地址
	add	bx, word ptr [BPB_BytsPerSec]	      ; BX+512指向装载程序区的下一个扇区地址
	jmp	SEARCH_IN_SUB_DIR_BEGIN
	
FILENAME_FOUND_INCURRENTDIR:
	pop ax								;找到了，di不用回复
	pop si
	pop dx
	pop cx
	
	pop bx								; ; 取出装载程序偏移地址
	pop ax								;; 取出此扇区在FAT中的序号
GET_USERFILE:
	mov ax, di							;ax作为返回值获得di的数据
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
; 函数名：ReadSector
;----------------------------------------------------------------------------
; 作用：从第 AX个扇区开始，将CL个扇区读入ES:BX中
ReadSector:
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号->柱面号、起始扇区、磁头号)
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                             ┌ 柱面号 = y >> 1
	;       x              ┌ 商 y ┤
	;   -------------- 	=> ┤      └ 磁头号 = y & 1
	;  每磁道扇区数        │
	;                      └ 余 z => 起始扇区号 = z + 1
	push bp		                    ; 保存BP
	mov bp, sp	                    ; 让BP=SP
	sub	sp, 2 	                    ; 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]
	mov	byte [bp-2], cl	            ; 压CL入栈（保存表示读入扇区数的传递参数）
	push bx			                ; 保存BX
	mov	bl, byte ptr [BPB_SecPerTrk]; BL=18（磁道扇区数）为除数
	div	bl			                ; AX/BL，商y在AL中、余数z在AH中
	inc	ah	                		; z ++（因磁盘的起始扇区号为1）
	mov	cl, ah	                	; CL <- 起始扇区号
	mov	dh, al	                	; DH <- y
	shr	al, 1		                ; y >> 1 （等价于y/BPB_NumHeads，软盘有2个磁头）
	mov	ch, al	                	; CH <- 柱面号
	and	dh, 1	                	; DH & 1 = 磁头号
	pop	bx		                	; 恢复BX
									; 至此，"柱面号、起始扇区、磁头号"已全部得到
	mov	dl, byte ptr [BS_DrvNum]	; 驱动器号（0表示软盘A）
.GoOnReading:					    ; 使用磁盘中断读入扇区
	mov	ah, 2			        	; 功能号（读扇区）
	mov	al, byte [bp-2]		        ; 读AL个扇区
	int	13h			             	; 磁盘中断
	jc	.GoOnReading                ; 如果读取错误，CF会被置为1，
					              	; 这时就不停地读，直到正确为止
	add	sp, 2				        ; 栈指针+2
	pop	bp				            ; 恢复BP

	ret

;----------------------------------------------------------------------------
; 函数名：WriteSector
;----------------------------------------------------------------------------
; 作用：从第 AX个扇区开始，将cl个扇区写入ES:BX
WriteSector:
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号->柱面号、起始扇区、磁头号)
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                             ┌ 柱面号 = y >> 1
	;       x              ┌ 商 y ┤
	;   -------------- 	=> ┤      └ 磁头号 = y & 1
	;  每磁道扇区数        │
	;                      └ 余 z => 起始扇区号 = z + 1
	push bp		                    ; 保存BP
	mov bp, sp	                    ; 让BP=SP
	sub	sp, 2 	                    ; 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]
	mov	byte [bp-2], cl	            ; 压CL入栈（保存表示读入扇区数的传递参数）
	push bx			                ; 保存BX
	mov	bl, byte ptr [BPB_SecPerTrk]; BL=18（磁道扇区数）为除数
	div	bl			                ; AX/BL，商y在AL中、余数z在AH中
	inc	ah	                		; z ++（因磁盘的起始扇区号为1）
	mov	cl, ah	                	; CL <- 起始扇区号
	mov	dh, al	                	; DH <- y
	shr	al, 1		                ; y >> 1 （等价于y/BPB_NumHeads，软盘有2个磁头）
	mov	ch, al	                	; CH <- 柱面号
	and	dh, 1	                	; DH & 1 = 磁头号
	pop	bx		                	; 恢复BX
									; 至此，"柱面号、起始扇区、磁头号"已全部得到
	mov	dl, byte ptr [BS_DrvNum]	; 驱动器号（0表示软盘A）
.GoOnWriting:					    ; 使用磁盘中断读入扇区
	mov	ah, 3			        	; 功能号（写扇区）
	mov	al, byte [bp-2]		        ; 写AL个扇区
	int	13h			             	; 磁盘中断
	call setint21
	mov ax,4c00h
	int 21h
	call resetint21
	jc	.GoOnWriting                ; 如果读取错误，CF会被置为1，
					              	; 这时就不停地读，直到正确为止
	add	sp, 2				        ; 栈指针+2
	pop	bp				            ; 恢复BP

	ret

;----------------------------------------------------------------------------
; 函数名：GetFATEntry
;----------------------------------------------------------------------------
; 作用：找到序号为AX的扇区在FAT中的条目，结果放在AX中。需要注意的
;     是，中间需要读FAT的扇区到ES:BX处，所以函数一开始保存了ES和BX
;  返回值ax:下一个簇号,需要注意簇号大于等于0xFF8表示文件的最后一个簇,为0xFF7表
GetFATEntry:
	push bx
	push es			            ; 保存ES、BX和AX（入栈）
	push bp
	push ax
; 设置读入的FAT扇区写入的基地址
	mov ax,word ptr[GetFATEntryAddr]
	sub	ax, 100h	          	; 在BaseOfRootDictionary后面留出4K空间用于存放FAT
	mov	es, ax		            ; ES=8F00h
; 判断FAT项的奇偶
	pop	ax	            		; 取出FAT项序号（出栈）
	mov	byte ptr [bOdd], 0 		; 初始化奇偶变量值为0（偶）
	mov	bx, 3            		; AX*1.5 = (AX*3)/2
	mul	bx		            	; DX:AX = AX * 3（AX*BX 的结果值放入DX:AX中）
	mov	bx, 2	            	; BX = 2（除数）
	xor	dx, dx	            	; DX=0	
	div	bx		            	; DX:AX / 2 => AX <- 商、DX <- 余数
	cmp	dx, 0	            	; 余数 = 0（偶数）？
	jz LABEL_EVEN            	; 偶数跳转
	mov	byte ptr [bOdd], 1    	; 奇数
LABEL_EVEN:	                	; 偶数
	; 现在AX中是FAT项在FAT中的偏移量，下面来
	; 计算FAT项在哪个扇区中(FAT占用不止一个扇区)
	xor	dx, dx	            	; DX=0	
	mov	bx, [BPB_BytsPerSec]	; BX=512
	div	bx		            	; DX:AX / 512
		  		            	; AX <- 商 (FAT项所在的扇区相对于FAT的扇区号)
		  		            	; DX <- 余数 (FAT项在扇区内的偏移)
	push dx		            	; 保存余数（入栈）
	mov bx, 0 	            	; BX <- 0 于是，ES:BX = 8F00h:0
	add	ax, SectorNoOfFAT1      ; 此句之后的AX就是FAT项所在的扇区号
	mov	cl, 2			        ; 读取FAT项所在的扇区，一次读两个，避免在边界
	call ReadSector            	; 发生错误, 因为一个 FAT项可能跨越两个扇区
	pop	dx		            	; DX= FAT项在扇区内的偏移（出栈）
	add	bx, dx	            	; BX= FAT项在扇区内的偏移
	mov bp,bx
	mov	ax, word ptr es:[bx]	; AX= FAT项值
	cmp	byte ptr [bOdd], 1	    ; 是否为奇数项？
	jnz	LABEL_EVEN_2         	; 偶数跳转
	shr	ax, 4			        ; 奇数：右移4位（取高12位）
LABEL_EVEN_2:	            	; 偶数
	and	ax, 0FFFh            	; 取低12位
LABEL_GET_FAT_ENRY_OK:
    pop bp
	pop	bx		            	; 恢复ES、BX（出栈）
	mov es,bx					;-----------------------------------------------------------------这里是因为bx在这个函数里改动没必要
	pop bx
	ret