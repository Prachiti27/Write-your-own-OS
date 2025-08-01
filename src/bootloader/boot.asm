org 0x7C00	;starting address
bits 16		;16-bit relamode code

%define ENDL 0x0D, 0x0A

;FAT12 header

jmp short start
nop

bdb_oem:			  		db 'MSWIN4.1' ;8bytes
bdb_bytes_per_Sector: 		dw 512
bdb_sectors_per_Cluster:	db 1
bdb_reserved_sectors:		dw 1
bdb_fat_count:				db 2
bdb_dir_entires_count:		dw 0E0h
bdb_total_sectors: 			dw 2880		;80 cylinders*2heads*18sectors = 2880
bdb_media_descriptor_type:  db 0F0h
bdb_sectors_per_fat: 		dw 9
bdb_sectors_per_track: 		dw 18
bdb_heads: 					dw 2
bdb_hidden_sectors: 		dd 0
bdb_large_sector_count:		dd 0

ebr_drive_number:			db 0
							db 0
ebr_signature:				db 12h
ebr_volume_id:				db 12h, 34h, 56h, 78h
ebr_volume_label: 			db 'PK OS'
ebr_system_id:				db	'FAT12'		;8 bytes

start:
	jmp main

;Prints a string to the scree
;Params : 
;		ds:si points to string
puts:
	push si
	push ax

.loop:
	lodsb            ;loads next char in al
	or al,al		 ; verfiy if next character is null	
	jz .done

	mov ah, 0x0e
	int 0x10

	jmp .loop

.done:
	pop ax
	pop si
	ret
	

main:

	mov ax,0
	mov ds, ax
	mov es, ax

	mov ss, ax
	mov sp, 0x7C00

	mov [ebr_drive_number], dl
	mov ax, 1
	mov cl, 1
	mov bx, 0x7E00
	call disk_read

	mov si, msg_hello
	call puts
	
	cli
	hlt

floppy_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot

wait_key_and_reboot:
	mov ah, 0
	int 16h
	jmp 0FFFFFh:0


.halt:
	cli 
	hlt

lba_to_chs:

	push ax
	push dx

	xor dx, dx
	div word[bdb_sectors_per_track]

	inc dx
	mov cx,dx
	xor dx, dx
	div word[bdb_heads]

	mov dh, dl
	mov ch, al
	shl ah, 6
	or cl , ah

	pop ax
	mov dl, al
	pop ax
	ret

;reads from disk
disk_read:

	push ax
	push bx
	push cx
	push dx
	push di

	push cx
	call lba_to_chs
	pop ax

	mov ah, 02h
	mov di, 3

.retry:
	pusha
	stc
	int 13h
	jnc .done

	popa
	call disk_reset

	dec di
	test di,di
	jnz .retry

.fail
	jmp floppy_error

.done:
	popa

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret

disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc floppy_error
	popa
	ret

msg_hello: 			db 'Hello world!',ENDL, 0
msg_read_failed:	db 'Read from disl failed!', ENDL,0

times 510-($-$$) db 0 
dw 0AA55h
