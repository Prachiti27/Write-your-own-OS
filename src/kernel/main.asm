org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

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

	mov si, msg_hello
	call puts
	
	hlt

.halt:
	jmp .halt

msg_hello: db 'Hello world!',ENDL, 0

times 510-($-$$) db 0 
dw 0AA55h
