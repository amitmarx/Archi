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
	cmp %1, 0
		je %3
	cmp %1, '0'
		jl %%endmacro
	cmp %1, '9'
		jg %%endmacro
		sub %1, '0'
		jmp %2
	%%endmacro:
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
	cmp [ecx], 0
	je end_loop
	inc ecx
	jmp point_ecx_to_last_pos
	end_loop:
	dec ecx
	cmp byte [ecx], 10
	je handleEnter
	cmp byte [ecx], '+'
	je handlePlus
	cmp byte [ecx], 'l'
	je handleShiftLeft
	cmp byte [ecx], 'r'
	je handleShiftRight
	cmp byte [ecx], 'p'
	je handlePrint
	cmp byte [ecx], 'd'
	je handleDouble
	cmp byte [ecx], 'q'
	je handleQuit:

	read_number:
	handle_if_number cl, .second_number, finish_read_number ; continue to compute or jump to end of loop
	.second_number:
	handle_if_number ch, .compute, allocated_new_node ; compute or skip computation

	.compute:
	shl cl, 4
	add cl, ch ; cl has the data byte

	allocated_new_node:
	pushad
	push element_size
	call malloc ; eax has the a poiter to allocated memory
	add esp, 4 ; remove element_size
	popad
	mov byte [eax], cl ; the new node has the data
	mov [eax+1], 0 ; initialize the next to 0
	
	cmp ebx, 0 ; ebx represent the previous node
	je set_first_element
	jmp append_to_previous

	set_first_element:
	mov ecx, stack
	mov dword edx, [stack_index]
	mov [ecx+ edx*4], eax ; set the first link address to current pos in stack
	jmp set_previous_to_ebx

	append_to_previous:
	mov dword [ebx+1], eax

	set_previous_to_ebx:
	mov ebx, eax

	dec ecx
	dec ecx
	jmp read_number ; continue to read more bytes

	finish_read_number:
	inc dword [stack_index]
	jmp get_operand
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	read_next_bytes:
	mov dx, [ecx]           ; 2 bytes from stack into dx
	cmp dx,10              ;check if dx is \n
	je print_list
	;je .get_operand

	mov al, dl
	handle_if_number al, .second_number
	;;;; Handle all other inputs options;;;;
	;MAYBE ERROR
	.second_number:
	mov ah, dh
	handle_if_number ah, .compute
	;MAYBE ERROR
	


	add_new_node:
	push eax
	pushad
	push element_size
	call malloc ; eax has the a poiter to allocated memory
	add esp, 4 ; remove element_size
	popad
	pop edx ; edx has now the data computed
	;;;;;TODO: check if should be [al];;;;;;;
	mov byte [eax],dl ; copy one byte as data to new node
	mov dword [eax+1], ebx ; copy address of previous node to the current node
	push ebx
	mov ebx, MSG
	print ebx
	pop ebx
	mov ebx , eax ; update ebx to store the new created node
	add ecx, 2 
	jmp read_next_bytes

	print_list:
	;cmp dword [ebx+1],0
	;je cleanup
	; print ebx
	; mov ebx, [ebx+1]
	;jmp print_list

; 	cmp byte [eax], 10
; 	je handleEnter
; 	cmp byte [eax], '+'
; 	je handlePlus
; 	cmp byte [eax], 'l'
; 	je handleShiftLeft
; 	cmp byte [eax], 'r'
; 	je handleShiftRight
; 	cmp byte [eax], 'p'
; 	je handlePrint
; 	cmp byte [eax], 'd'
; 	je handleDouble
; 	cmp byte [eax], 'q'
; 	je handleQuit:
	; handle_if_number [eax], .handle_number

handle_number:

; handle_Enter:
; handle_Plus:
; handle_ShiftLeft:
; handle_ShiftRight:
; handle_Print:
; handle_Double:
; handle_Quit:

handleQuit:
cleanup:
    mov esp, ebp
    pop ebp
    ret 

