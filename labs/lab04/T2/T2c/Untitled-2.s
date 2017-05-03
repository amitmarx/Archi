section	.rodata
LC0:	DB	"next call", 10, 0	; Format string
LC2:	DB	"element %d", 10, 0	; Format string

section .bss
element: resd 1 
cols:	 resd 1 
row:	 resd 1 
arr:	 resd 1 	

section .text
	align 16
	global my_func
	extern printf

my_func:
	push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	pusha			; Save registers

start:	mov ecx, dword [ebp+12]	; Get row
	mov	dword [row], ecx
	mov ecx, dword [ebp+16]	; Get columns
	mov	dword [cols], ecx	
	mov ecx, dword [ebp+8]	; Get array pointer
	mov	dword [arr], ecx	

	push	LC0		; call printf for next call
	call	printf
	add 	esp, 4		; Clean up stack after call
;
; find first element to print
;
	mov 	eax,[row]
	mov		ebx, [cols]
	mul		ebx
	mov		ebx,eax
	mov		edx,[arr]
	mov		edx, dword [ebx*4+edx]	; edx is the next element to print
	mov		ecx, dword [cols]
print_loop:
	mov		dword [element],edx
next: push 	ecx ; printf might change it
	push	dword [element]		; Call printf with 2 arguments: pointer to array element
	push	LC2		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call		;       Your code should be here...
	pop 	ecx
	inc		ebx
	mov		edx,[arr]
	mov		edx, dword [ebx*4+edx]	; edx is the next element to print
	loop	print_loop
	
	popa			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret
