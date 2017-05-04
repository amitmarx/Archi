section .rodata
TEMPLATE: DB	"%.*s", 10, 0	; Format string
MSG : DB "bla"

section .data
	element_size equ 5
	stack_index:	dd	0 

section .bss
stack:
	RESB	20
input_buffer:
	RESB	80

section .text 
	%macro handle_if_number 3
	cmp %1, '0'
		jl %%endmacro
	cmp %1, '9'
		jg %%endmacro
		sub %1, '0'
	jmp %2
	%%endmacro:
	cmp %1, 0
		je %3
	%endmacro
	%macro print 1
	push %1
	push 1
	push TEMPLATE
	push dword [stdout]
	call fprintf
	add esp, 4*2 ; clean stacks call params
	pop %1
	%%endmacro:
	%endmacro
	 extern printf 
     extern fprintf 
     extern malloc 
     extern free
     extern gets 
     extern stderr 
     extern stdin 
     extern stdout
	 global main
 main:
 	
  	push ebp            ; Save the stack
    mov ebp, esp
	get_operand:
	mov ecx, input_buffer 
	push dword [stdin] ; pointer to stdin
	push ecx ; pointer to input		
	call gets ; read line from stdin
	pop ecx ; pointer to input
	add esp, 4 ; clean stacks call params
	mov ebx, 0 ; ebx will store the previous node
	
	point_ecx_to_last_pos:
	cmp byte [ecx], 0
	je end_loop
	inc ecx
	jmp point_ecx_to_last_pos
	end_loop:
	dec ecx
	; cmp byte [ecx], 10
	; je handleEnter
	; cmp byte [ecx], '+'
	; je handlePlus
	; cmp byte [ecx], 'l'
	; je handleShiftLeft
	; cmp byte [ecx], 'r'
	; je handleShiftRight
	; cmp byte [ecx], 'p'
	; je handlePrint
	; cmp byte [ecx], 'd'
	; je handleDouble
	cmp byte [ecx], 'q'
	je handleQuit

	read_number:
	mov dx, [ecx]

	handle_if_number dl, .second_number, .finish_read_number ; continue to compute or jump to end of loop
	.second_number:
	handle_if_number dh, .compute, .allocated_new_node ; compute or skip computation

	.compute:
	shl dl, 4
	add dl, dh ; dl has the data byte

	.allocated_new_node:
	pushad
	push element_size
	call malloc ; eax has the a poiter to allocated memory
	add esp, 4 ; remove element_size
	popad
	mov byte [eax], dl ; the new node has the data
	mov dword [eax+1], 0 ; initialize the next to 0
	
	cmp ebx, 0 ; ebx represent the previous node
	je .set_first_element
	jmp .append_to_previous

	.set_first_element:
	mov dword edx, [stack_index]
	mov [stack+ edx*4], eax ; set the first link address to current pos in stack
	jmp .set_previous_to_ebx

	.append_to_previous:
	mov dword [ebx+1], eax

	.set_previous_to_ebx:
	mov ebx, eax

	dec ecx
	dec ecx
	jmp read_number ; continue to read more bytes

	.finish_read_number:
	inc dword [stack_index]
	jmp get_operand

handleQuit:
cleanup:
    mov esp, ebp
    pop ebp
    ret 

