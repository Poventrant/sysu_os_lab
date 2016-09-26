;%define	_BOOT_DEBUG_	; ��������.COM�ļ����ڵ���
;���������ڼ����ں�

%ifdef	_BOOT_DEBUG_
	org  100h			; ����״̬������ .COM �ļ�, �ɵ���
%else
	org  7c00h			; BIOS���������������ص�0:7C00��������ʼִ��
%endif

;==============================================================
%ifdef	_BOOT_DEBUG_
BaseOfStack		equ	100h	; ��ջ����ַ(ջ��, �����λ����͵�ַ����)
%else
BaseOfStack		equ	7c00h	; ��ջ����ַ(ջ��, �����λ����͵�ַ����)
%endif

BaseOfLoader		equ	1000h	; OS.COM �����ص���λ�� ----  �ε�ַ
OffsetOfLoader	equ	100h	; OS.COM �����ص���λ�� ---- ƫ�Ƶ�ַ
RootDirSectors	equ	14		; ��Ŀ¼ռ�õ�������
SectorNoOfRootDirectory	equ	19	; ��Ŀ¼������������
SectorNoOfFAT1	equ	1		; FAT#1���������� = BPB_RsvdSecCnt
DeltaSectorNo		equ	17		; DeltaSectorNo = BPB_RsvdSecCnt + 
							; (BPB_NumFATs * FATSz) - 2 = 1 + (2*9) -2 = 17
							; �ļ��Ŀ�ʼ������ = Ŀ¼��Ŀ�еĿ�ʼ������ 
							; + ��Ŀ¼ռ��������Ŀ + DeltaSectorNo
;==============================================================

	jmp short LABEL_START		; ������ʼ����תָ��
	nop							; ��� nop �����٣��޲�����ռ�ֽ�λ

	; ������ FAT12 ���̵�ͷ
	BS_OEMName	DB 'OS9.0-PWQ'	; OEM��������8���ֽڣ����㲹�ո�
	BPB_BytsPerSec	DW 512		; ÿ�����ֽ���
	BPB_SecPerClus	DB 1		; ÿ��������
	BPB_RsvdSecCnt	DW 1		; Boot��¼ռ��������
	BPB_NumFATs	DB 2		; FAT����
	BPB_RootEntCnt	DW 224		; ��Ŀ¼�ļ������ֵ
	BPB_TotSec16	DW 2880		; �߼���������
	BPB_Media		DB 0F0h		; ����������
	BPB_FATSz16	DW 9		; ÿFAT������
	BPB_SecPerTrk	DW 18		; ÿ�ŵ�������
	BPB_NumHeads	DW 2		; ��ͷ��(����)
	BPB_HiddSec	DD 	0			; ����������
	BPB_TotSec32	DD 0		; BPB_TotSec16Ϊ0ʱ�ɴ�ֵ��¼��������
	BS_DrvNum		DB 0		; �ж� 13 ���������ţ����̣�
	BS_Reserved1		DB 0		; δʹ��
	BS_BootSig		DB 29h		; ��չ������� (29h)
	BS_VolID		DD 0		; �����к�
	BS_VolLab		DB 'MyOS System'; ��꣬����11���ֽڣ����㲹�ո�
	BS_FileSysType	DB 'FAT12   '	; �ļ�ϵͳ���ͣ�����8���ֽڣ����㲹�ո�

LABEL_START:
	mov	ax, cs	; �������μĴ���ֵ��CS��ͬ
	mov	ds, ax	; ���ݶ�
	mov	es, ax	; ���Ӷ�
	mov	ss, ax	; ��ջ��
	mov	sp, BaseOfStack ; ��ջ��ַ

; ����
	mov	ax, 600h		; AH = 6�����ܺţ���AL = 0�������ı�������0Ϊ�������ڣ�
	mov	bh, 7		; �ڵװ���
	mov	cx, 0			; ���Ͻǣ�(0, 0)
	mov	dx, 184fh		; ���½ǣ�(24, 79)
	int	10h			; ��ʾ�ж�

	mov	dh, 0		; "Booting  "
	call	DispStr		; ��ʾ�ַ���

; ������λ
	xor	ah, ah	; ���ܺ�ah=0����λ������������
	xor	dl, dl	; dl=0��������Ӳ�̺�U��Ϊ80h��
	int	13h		; �����ж�
	
; ������A�̸�Ŀ¼��Ѱ�� OS.COM
	mov	word [wSectorNo], SectorNoOfRootDirectory 	; ����ʾ��ǰ�����ŵ�
						; ����wSectorNo����ֵΪ��Ŀ¼�����������ţ�=19��
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word [wRootDirSizeForLoop], 0	; �жϸ�Ŀ¼���Ƿ��Ѷ���
	jz	LABEL_NO_LOADERBIN		; ���������ʾδ�ҵ�OS.COM
	dec	word [wRootDirSizeForLoop]	; �ݼ�����wRootDirSizeForLoop��ֵ
	; ���ö�������������һ����Ŀ¼������װ����
	mov	ax, BaseOfLoader
	mov	es, ax			; ES <- BaseOfLoader��9000h��
	mov	bx, OffsetOfLoader	; BX <- OffsetOfLoader��100h��
	mov	ax, [wSectorNo]	; AX <- ��Ŀ¼�еĵ�ǰ������
	mov	cl, 1				; ֻ��һ������
	call	ReadSector		; ���ö���������

	mov	si, LoaderFileName	; DS:SI -> "OS      COM"
	mov	di, OffsetOfLoader	; ES:DI -> BaseOfLoader:0100
	cld					; ���DF��־λ
						; �ñȽ��ַ���ʱ�ķ���Ϊ��/��[��������]
	mov	dx, 10h			; ѭ������=16��ÿ��������16���ļ���Ŀ��512/32=16��
LABEL_SEARCH_FOR_LOADERBIN:
	cmp	dx, 0			; ѭ����������
	jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR ; ���Ѷ���һ����
	dec	dx				; �ݼ�ѭ������ֵ			  ��������һ����
	mov	cx, 11			; ��ʼѭ������Ϊ11
LABEL_CMP_FILENAME:
	repe cmpsb			; �ظ��Ƚ��ַ����е��ַ���CX--��ֱ������Ȼ�CX=0
	cmp	cx, 0
	jz	LABEL_FILENAME_FOUND	; ����Ƚ���11���ַ�����ȣ���ʾ�ҵ�
LABEL_DIFFERENT:
	and	di, 0FFE0h		; DI &= E0Ϊ������ָ����Ŀ��ͷ����5λ���㣩
					; FFE0h = 1111111111100000����5λ=32=Ŀ¼��Ŀ��С��
	add	di, 20h			; DI += 20h ��һ��Ŀ¼��Ŀ
	mov	si, LoaderFileName	; SIָ��װ���ļ���������ʼ��ַ
	jmp	LABEL_SEARCH_FOR_LOADERBIN; ת��ѭ����ʼ��

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word [wSectorNo], 1 ; ������ǰ������
	jmp	LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
	mov	dh, 2		; "No LOADER"
	call	DispStr		; ��ʾ�ַ���
%ifdef	_BOOT_DEBUG_ ; û���ҵ�OS.COM�ͻص� DOS
	mov	ax, 4c00h		; AH=4Ch�����ܺţ���ֹ���̣���AL=0�����ش��룩
	int	21h			; DOS���ж�
%else
	jmp	$			; û���ҵ� OS.COM�������������ѭ��
%endif

LABEL_FILENAME_FOUND:	; �ҵ� OS.COM ��������������
	; �����ļ�����ʼ������
	mov	ax, RootDirSectors	; AX=��Ŀ¼ռ�õ�������
	and	di, 0FFE0h		; DI -> ��ǰ��Ŀ�Ŀ�ʼ��ַ
	add	di, 1Ah			; DI -> �ļ���������������Ŀ�е�ƫ�Ƶ�ַ
	mov cx, word [es:di]	; CX=�ļ�����������
	push cx				; �����������FAT�е����
	add	cx, ax			; CX=�ļ��������ʼ������+��Ŀ¼ռ�õ�������
	add	cx, DeltaSectorNo	; CL <- OS.COM����ʼ������(0-based)
	mov	ax, BaseOfLoader
	mov	es, ax			; ES <- BaseOfLoader��װ�س����ַ=9000h��
	mov	bx, OffsetOfLoader	; BX <- OffsetOfLoader��װ�س���ƫ�Ƶ�ַ=100h��
	mov	ax, cx			; AX <- ��ʼ������

LABEL_GOON_LOADING_FILE:
	push bx				; ����װ�س���ƫ�Ƶ�ַ
	mov	cl, 1				; 1������
	call	ReadSector		; ������

; ÿ��һ���������� "Booting  " �����һ����, �γ�������Ч����Booting ......
	mov	ah, 0Eh		; ���ܺţ��Ե紫��ʽ��ʾ�����ַ���
	mov	al, '.'			; Ҫ��ʾ���ַ�
	mov	bl, 0Fh		; �ڵװ���
	int	10h			; ��ʾ�ж�

	; �����ļ�����һ������
	pop bx				; ȡ��װ�س���ƫ�Ƶ�ַ
	pop	ax				; ȡ����������FAT�е����
	call	GetFATEntry		; ��ȡFAT���е���һ�غ�
	cmp	ax, 0FF8h		; �Ƿ����ļ�����
	jae	LABEL_FILE_LOADED	; ��FF8hʱ��ת���������һ����
	push ax				; ����������FAT�е����
	mov	dx, RootDirSectors	; DX = ��Ŀ¼������ = 14
	add	ax, dx			; ������� + ��Ŀ¼������
	add	ax, DeltaSectorNo		; AX = Ҫ��������������ַ
	add	bx, [BPB_BytsPerSec]	; BX+512ָ��װ�س���������һ��������ַ
	jmp	LABEL_GOON_LOADING_FILE
LABEL_FILE_LOADED:
	mov	dh, 1			; "Ready."
	call	DispStr			; ��ʾ�ַ���

; **********************************************************************
	jmp	BaseOfLoader:OffsetOfLoader	; ��һ����ʽ��ת���Ѽ��ص���
						; ���е� OS.COM �Ŀ�ʼ����
						; ��ʼִ�� OS.COM �Ĵ��롣
						; Boot Sector ��ʹ�����˽���
; **********************************************************************

;==============================================================
;����
wRootDirSizeForLoop	dw	RootDirSectors	; ��Ŀ¼��ʣ��������
										; ��ʼ��Ϊ14����ѭ���л�ݼ�����
wSectorNo		dw	0	; ��ǰ�����ţ���ʼ��Ϊ0����ѭ���л����
bOdd			db	0	; ��������ż��FAT��

;�ַ���
LoaderFileName	db	"OS      COM", 0 ; OS.COM֮�ļ���
; Ϊ�򻯴��룬����ÿ���ַ����ĳ��Ⱦ�ΪMessageLength��=9�����ƴ�����
MessageLength	equ	10
BootMessage:		db	"loading..." 	; 9�ֽڣ��������ÿո��롣���0
Message1			db	"ready....." 	; 9�ֽڣ��������ÿո��롣���1
Message2			db	"load error" ; 9�ֽڣ��������ÿո��롣���2
;==============================================================

;----------------------------------------------------------------------------
; ��������DispStr
;----------------------------------------------------------------------------
; ���ã���ʾһ���ַ�����������ʼʱDH����Ϊ�����(0-based)
DispStr:
	mov	ax, MessageLength ; ����->AX����AL=9��
	mul	dh				; AL*DH������ţ�->AX��=��ǰ������Ե�ַ��
	add	ax, BootMessage	; AX+���������ʼ��ַ
	mov	bp, ax			; BP=��ǰ����ƫ�Ƶ�ַ
	mov	ax, ds			; ES:BP = ����ַ
	mov	es, ax			; ��ES=DS
	mov	cx, MessageLength	; CX = ������=9��
	mov	ax, 1301h			; AH = 13h�����ܺţ���AL = 01h��������ڴ�β��
	mov	bx, 0007h		; ҳ��Ϊ0(BH = 0) �ڵװ���(BL = 07h)
	mov	dl, 0				; �к�=0
	int	10h				; ��ʾ�ж�
	ret					; ��������
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; ��������ReadSector
;----------------------------------------------------------------------------
; ���ã��ӵ� AX��������ʼ����CL����������ES:BX��
ReadSector:
	; -----------------------------------------------------------------------
	; �������������������ڴ����е�λ�� (������->����š���ʼ��������ͷ��)
	; -----------------------------------------------------------------------
	; ��������Ϊ x
	;                           �� ����� = y >> 1
	;       x           �� �� y ��
	;   -------------- 	=> ��      �� ��ͷ�� = y & 1
	;  ÿ�ŵ�������     ��
	;                   �� �� z => ��ʼ������ = z + 1
	push bp		; ����BP
	mov bp, sp	; ��BP=SP
	sub	sp, 2 	; �ٳ������ֽڵĶ�ջ���򱣴�Ҫ����������: byte [bp-2]
	mov	byte [bp-2], cl	; ѹCL��ջ�������ʾ�����������Ĵ��ݲ�����
	push bx			; ����BX
	mov	bl, [BPB_SecPerTrk]	; BL=18���ŵ���������Ϊ����
	div	bl			; AX/BL����y��AL�С�����z��AH��
	inc	ah			; z ++������̵���ʼ������Ϊ1��
	mov	cl, ah		; CL <- ��ʼ������
	mov	dh, al		; DH <- y
	shr	al, 1			; y >> 1 ���ȼ���y/BPB_NumHeads��������2����ͷ��
	mov	ch, al		; CH <- �����
	and	dh, 1		; DH & 1 = ��ͷ��
	pop	bx			; �ָ�BX
	; ���ˣ�"����š���ʼ��������ͷ��"��ȫ���õ�
	mov	dl, [BS_DrvNum]	; �������ţ�0��ʾ����A��
.GoOnReading: ; ʹ�ô����ж϶�������
	mov	ah, 2				; ���ܺţ���������
	mov	al, byte [bp-2]		; ��AL������
	int	13h				; �����ж�
	jc	.GoOnReading	; �����ȡ����CF�ᱻ��Ϊ1��
						; ��ʱ�Ͳ�ͣ�ض���ֱ����ȷΪֹ
	add	sp, 2				; ջָ��+2
	pop	bp				; �ָ�BP

	ret
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; ��������GetFATEntry
;----------------------------------------------------------------------------
; ���ã��ҵ����ΪAX��������FAT�е���Ŀ���������AX�С���Ҫע���
;     �ǣ��м���Ҫ��FAT��������ES:BX�������Ժ���һ��ʼ������ES��BX
GetFATEntry:
	push es			; ����ES��BX��AX����ջ��
	push bx
	push ax
; ���ö����FAT����д��Ļ���ַ
	mov ax, BaseOfLoader	; AX=9000h
	sub	ax, 100h		; ��BaseOfLoader��������4K�ռ����ڴ��FAT
	mov	es, ax		; ES=8F00h
; �ж�FAT�����ż
	pop	ax			; ȡ��FAT����ţ���ջ��
	mov	byte [bOdd], 0 ; ��ʼ����ż����ֵΪ0��ż��
	mov	bx, 3		; AX*1.5 = (AX*3)/2
	mul	bx			; DX:AX = AX * 3��AX*BX �Ľ��ֵ����DX:AX�У�
	mov	bx, 2		; BX = 2��������
	xor	dx, dx		; DX=0	
	div	bx			; DX:AX / 2 => AX <- �̡�DX <- ����
	cmp	dx, 0		; ���� = 0��ż������
	jz LABEL_EVEN	; ż����ת
	mov	byte [bOdd], 1	; ����
LABEL_EVEN:		; ż��
	; ����AX����FAT����FAT�е�ƫ������������
	; ����FAT�����ĸ�������(FATռ�ò�ֹһ������)
	xor	dx, dx		; DX=0	
	mov	bx, [BPB_BytsPerSec]	; BX=512
	div	bx			; DX:AX / 512
		  			; AX <- �� (FAT�����ڵ����������FAT��������)
		  			; DX <- ���� (FAT���������ڵ�ƫ��)
	push dx			; ������������ջ��
	mov bx, 0 		; BX <- 0 ���ǣ�ES:BX = 8F00h:0
	add	ax, SectorNoOfFAT1 ; �˾�֮���AX����FAT�����ڵ�������
	mov	cl, 2			; ��ȡFAT�����ڵ�������һ�ζ������������ڱ߽�
	call	ReadSector	; ��������, ��Ϊһ�� FAT����ܿ�Խ��������
	pop	dx			; DX= FAT���������ڵ�ƫ�ƣ���ջ��
	add	bx, dx		; BX= FAT���������ڵ�ƫ��
	mov	ax, [es:bx]	; AX= FAT��ֵ
	cmp	byte [bOdd], 1	; �Ƿ�Ϊ�����
	jnz	LABEL_EVEN_2	; ż����ת
	shr	ax, 4			; ����������4λ��ȡ��12λ��
LABEL_EVEN_2:		; ż��
	and	ax, 0FFFh	; ȡ��12λ
LABEL_GET_FAT_ENRY_OK:
	pop	bx			; �ָ�ES��BX����ջ��
	pop	es
	ret
;----------------------------------------------------------------------------

	times 510-($-$$)	db	0	; ��0�����������ʣ�µĿռ�
	db 	55h, 0aah				; ��������������־
