section	.rodata
LC0:
	DB	"%d", 10, 0	; Format string
ERROR:
	DB "X or K or both are off range",10, 0

section .bss
LC1:
	RESB	256

section .text
	align 16
	global calc_div
	extern printf
	extern check

calc_div:
	push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	pushad			; Save registers

	mov ebx, dword [ebp+8]	; get x to ebx
	mov edx, dword [ebp+12] ; get k to edx 
	pushad
	push edx
	push ebx
	call check
	add esp, 8  ;delete from stack
	cmp eax, 1
	popad
	jne .printError
	mov eax, ebx ; move to divide
	mov ebx, 1
	mov ecx, edx 
	shl ebx, cl ; now we have 2^k in ecx
	mov edx , 0 
	idiv ebx

	push	eax		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	
	jmp .finish
	.printError:
	push	ERROR		; and pointer to format string.
	call	printf
	jmp .finish
	
	.finish:
	add 	esp, 8		; Clean up stack after call

	popad			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret

