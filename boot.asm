	org  7c00h					; ���ص� 0:7C00 ��
	jmp short LABEL_START		; ��ת��������ʼ��
	nop							; ���nop���޲���ָ������٣�ռλ�ֽڣ�

	; ������ FAT12 ���̵�ͷ��BPB+EBPB��ռ51B��
	BS_OEMName	DB 'MyOS 1.0' ; OEM String, ���� 8 ���ֽڣ����㲹�ո�
	BPB_BytsPerSec	DW 512		; ÿ�����ֽ���
	BPB_SecPerClus	DB 1		; ÿ�ض�������
	BPB_RsvdSecCnt	DW 1		; Boot��¼ռ�ö�������
	BPB_NumFATs	DB 2		; ���ж��� FAT ��
	BPB_RootEntCnt	DW 224		; ��Ŀ¼�ļ������ֵ
	BPB_TotSec16	DW 2880		; �߼���������
	BPB_Media		DB 0xF0		; ����������
	BPB_FATSz16	DW 9		; ÿFAT������
	BPB_SecPerTrk	DW 18		; ÿ�ŵ�������
	BPB_NumHeads	DW 2		; ��ͷ��(����)
	BPB_HiddSec		DD 0		; ����������
	BPB_TotSec32	DD 0		; BPB_TotSec16Ϊ0ʱ���ֵ��¼������
	BS_DrvNum		DB 0		; �ж� 13h ����������
	BS_Reserved1		DB 0		; δʹ��
	BS_BootSig		DB 29h		; ��չ������� (29h)
	BS_VolID		DD 12345678h; �����к�
	BS_VolLab		DB 'MyOS System'; ���, ���� 11 ���ֽڣ����㲹�ո�
	BS_FileSysType	DB 'FAT12   '	; �ļ�ϵͳ����, ���� 8���ֽڣ����㲹�ո�  

LABEL_START:
	mov	ax, cs		; ��DS��ES=CS
	mov	ds, ax
	mov	es, ax
	call	ScrollPg		; ���Ϲ�����ʾҳ
	call	DispStr		; ������ʾ�ַ�������
	jmp	$			; ����ѭ��

ScrollPg: ; ��������
	mov	ah, 6			; ���ܺ�
	mov	al, 0			; �������ı�������0=�������ڣ�
	mov bh,0fh		; ���ò�����е��ַ���ɫΪ�ڵ�������
	mov cx, 0			; �������Ͻǵ��к�=CH���к�=CL
	mov dh, 24		; �������½ǵ��к�
	mov dl, 79		; �������½ǵ��к�
	int 10h			; ��ʾ�ж�
	ret
	
DispStr:
	mov ah,13h 		; BIOS�жϵĹ��ܺţ���ʾ�ַ�����
	mov al,1 			; ���ŵ���β
	mov bh,0 		; ҳ��=0
	mov bl,0ch 		; �ַ���ɫ=�ڵ�������
	mov cx,16 		; ����=16
	mov dx,0 		; ��ʾ������ʼλ�ã�0��0����DH=�кš�DL=�к�
	mov bp,BootMsg	; ES:BP=����ַ
	int 10h 			; ����10H����ʾ�ж�
	ret				; �����̷���

BootMsg:  
    db  "Hello, OS world!" ; ��ʾ���ַ���
	times 510-($-$$) db 0	; ��0���ʣ�µ������ռ䣨�����޷�����
	db 	55h, 0aah			; ��������������־

; �������FAT���ͷ�����ÿ��FATռ9��������
	db 0f0h, 0ffh, 0ffh			; ������������F0h����Fh�������ر�־��FFFh
	times 512*9-3		db	0	; ��0���FAT#1ʣ�µĿռ�
	db 0f0h, 0ffh, 0ffh			; ������������F0h����Fh�������ر�־��FFFh
	times 512*9-3		db	0	; ��0���FAT#2ʣ�µĿռ�
; ��Ŀ¼�еľ����Ŀ
	db 'MyOS System' 			; ���, ���� 11 ���ֽڣ����㲹�ո�
	db 8						; �ļ�����ֵ�������Ŀ��Ϊ08h��
	dw 0,0,0,0,0				; 10�������ֽ�
	dw 0,426Eh				; ����ʱ�䣬��Ϊ2013��3��14��0ʱ0��0��
	dw 0						; ��ʼ�غţ������Ŀ�ı���Ϊ0��
	dd 0						; �ļ���С��Ҳ��Ϊ0��