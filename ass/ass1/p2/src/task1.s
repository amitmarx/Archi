section	.rodata
LC0:
	DB	"%s", 10, 0	; Format string

section .bss
LC1:
	RESB	256

section .text
	align 16
	global my_func
	extern printf
%macro handle_if_number 2
cmp %1, '0'
	jl %%endmacro
cmp %1, '9'
	jg %%endmacro
	sub %1, '0'
	jmp %2
%%endmacro:
%endmacro
%macro handle_if_uppercase 2
cmp %1, 'A'
	jl %%endmacro
cmp %1, 'Z'
jg %%endmacro
	sub %1, ('A'-10)
	jmp %2
%%endmacro:
%endmacro
%macro handle_if_lowwercase 2
cmp %1, 'a'
	jl %%endmacro
cmp %1, 'z'
jg %%endmacro
	sub %1, ('a'-10)
	jmp %2
%%endmacro:
%endmacro


my_func:
	push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	pushad			; Save registers

	mov ecx, dword [ebp+8]	; Get argument (pointer to string)
	mov ebx, LC1
.read:
 	mov dx, [ecx]           ; 2 bytes from stack into dx; check why 2 bytes.
	cmp dx,10               ;check if dx is \n
	je .finish

	mov al, dl
	handle_if_number al, .second_number
	handle_if_uppercase al, .second_number
	handle_if_lowwercase al, .second_number

	.second_number:
	mov ah, dh
	handle_if_number ah, .compute
	handle_if_uppercase ah, .compute
	handle_if_lowwercase ah, .compute
	
	.compute:
	shl al, 4
	add al, ah
	
	mov byte [ebx], al
	inc ebx
	add ecx, 2
	
  	jmp .read
	
	.finish:
	push	LC1		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call

	popad			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret

