section .rodata
TEMPLATE: DB	"%.*s", 10, 0	; Format string
MOVE_LINE:		DB	10, 0
PRINT_INT_TEMPLATE: 		DB	"%d" ,0
MSG: 	db "Read number",10,0
NEW_LINE: 	db 10,0 
section .data
	element_size equ 5
	stack_index:	dd	0
	operations_counter:	dd	0
	

section .bss
stack:
	RESB	20
input_buffer:
	RESB	80
array:
	RESB	81
letter_counter:
	RESB	4
print_int_storage:
	RESB	4

section .text 

%macro delete_from_node 1
pushad
mov ecx, %1
%%delete_loop:
cmp ecx, 0
je %%end_delete_loop

push dword [ecx+1] ; store the next node pointer
delete_node ecx
pop ecx
jmp %%delete_loop

%%end_delete_loop:
popad

%endmacro

%macro delete_node 1
pushad
push %1 ; push pointer to node we want to clean
call free
add esp, 4
popad
%endmacro
%macro expand_number_to_edx 1
	push ecx
	mov cl, %1
	mov edx, 0
	mov	dl, cl 
	and	dl, 11110000b
	shr	dl, 4
	mov dh, dl ; dh has now the first number
	mov dl,cl
	and	dl, 00001111b ; dl has now the second number
	pop ecx
%endmacro
%macro print_msg 2
	pushad
	push 	%1
	call 	printf
	add		esp, %2
	popad
%endmacro
%macro print_int 1
	pushad
	mov eax, %1
	push 	dword [eax]
	push 	PRINT_INT_TEMPLATE
	call 	printf
	add		esp, 8
	popad
%endmacro


%macro round_even 1
	pushad
	mov eax, %1
	shr dword[eax],1
	jc %%add_two
	shl dword [eax],1
	jmp %%end_round_even
		
	%%add_two:
	shl dword [eax],1
	add dword [eax],2
	%%end_round_even
	popad
%endmacro
	%macro handle_if_number 2
	cmp dword [letter_counter], 0
	je .finish_read_number
	sub %1, '0'
	%%endmacro:
	dec dword [letter_counter]
	jmp %2
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
%macro create_new_node_in_eax 1
	push ebx
	push ecx
	push edx
	push element_size
	call malloc ; eax has a poiter to allocated memory
	add esp, 4 ; remove element_size
	pop edx
	pop ecx
	pop ebx
	mov byte [eax], %1 ; the new node has the data
	mov dword [eax+1], 0 ; initialize the next to 0
	
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
	mov dword [letter_counter],0; reset counter
	
	; cmp byte [ecx], '+'
	; je handlePlus
	cmp byte [ecx], '+'
	je handlePlus
	; cmp byte [ecx], 'l'
	; je handleShiftLeft
	cmp byte [ecx], 'r'
	je handle_Shift_Right
	cmp byte [ecx], 'p'
	je handle_print
	cmp byte [ecx], 'd'
	je handle_Double
	cmp byte [ecx], 'q'
	je handleQuit
	
	point_ecx_to_last_pos:
	cmp byte [ecx], 0
	je end_loop
	inc dword [letter_counter]
	inc ecx
	jmp point_ecx_to_last_pos
	end_loop:
	sub ecx,2

	round_even letter_counter ; make counter even(round up), inorder to read two bytes each time
	
	;============================================================================================
	;READ_NUMBER
	; eax - store the current node (when created)
	; ecx - pointer to input text (uses as itertable)
	; edx - store the converted value of the data(after compute)
	; ebx - store the previous node
	; letter_counter - store hove many letters from input we have more to read
	;============================================================================================
	read_number:
	mov edx,0
	mov dx, [ecx]
	
	handle_if_number dl, .second_number  ; continue to compute or jump to end of loop
	.second_number:
	handle_if_number dh, .compute ; compute or skip computation
	
	.compute:
	shl dl, 4
	add dl, dh ; dl has the data byte
	
	create_new_node_in_eax dl
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

	;============================================================================================
	; handle_Shift_Right
	; eax - carry flag
	; ecx - pointer to node
	; edx - temp register
	; ebx - pointer to previous node
	;============================================================================================
	handle_Shift_Right:
	
	.make_shift:
	mov edx,[stack_index] ; edx has the counter to next index
	dec edx ; edx has the index that should be shifted
	mov dword ecx, [stack+ edx * 4] ; ecx has the pointer to first node in stack
	mov ebx, 0 ; init previous node
	.find_last_node:
	cmp ecx, 0
	je .ebx_has_last_node
	mov edx, [ecx+1] ; read the next node
	mov dword [ecx+1],ebx ; set current node to point his parent node
	mov ebx, ecx ; ebx has now the current node pointer for furture use
	mov ecx, edx ; ecx has the next node we should handle
	jmp .find_last_node
	
	.ebx_has_last_node:
	mov al, 0 ; will be used to store if there is any carry
	mov ecx, 0
	mov esi, 0 ; will indicate to say if number started
	.compute_shift_right:
	cmp ebx,0
	je .finish_shift_right
	expand_number_to_edx byte [ebx]
	add dh, al ; add 10 if there was carry
	mov al, 0 ; carry was used
	shr dh,1
	jnc .no_carry_for_shifting_first
	mov al, 10
	.no_carry_for_shifting_first:
	add dl, al ; add 10 if there was carry
	mov al, 0 ; carry was used
	shr dl,1
	jnc .no_carry_for_shifting_second
	mov al, 10
	.no_carry_for_shifting_second:
	shl dh, 4
	add dh, dl ; dh has now the data

	cmp esi,0
	jne .update_node_data
	cmp dh,0
	jne .update_node_data
	mov edx, [ebx+1] ; edx will have the next node to iterate
	delete_node ebx
	mov ecx, 0
	mov ebx, edx ; copy edx pointer
	jmp .compute_shift_right

	.update_node_data:
	mov esi,1 ; will indicate that the number has started(do not ignore zero's)
	mov [ebx], dh ; update data value
	mov edx, [ebx+1] ; edx will have the next node to iterate
	mov [ebx+1], ecx ; make node to point ahead
	mov ecx, ebx
	mov ebx, edx ; copy edx pointer
	jmp .compute_shift_right
	
	.finish_shift_right:
	jmp get_operand


	;============================================================================================
	;HANDLE_DOUBLE
	; eax - new allocated node
	; ecx - pointer to copied element
	; edx - holds the stack counter
	; ebx - previous new node
	;============================================================================================
	handle_Double:
	mov edx,[stack_index] ; edx has the counter to next index
	dec edx ; edx has the index that should be copy
	mov dword ecx, [stack+ edx * 4] ; ecx has the pointer to first node in stack
	mov ebx, stack
	inc edx; use edx to hold the position of next stack position 
	shl edx,2 ; edx = edx*4 - in order to make the add, chage the offset to byes
	add ebx, edx ; ebx has the pointer that should be update
	
	.read_node:
	cmp ecx,0 
	je finish_copy ; Break operation if we finish copy
	mov dl, [ecx] ; dl now holds the node data(the one we copy)
	create_new_node_in_eax dl
	mov [ebx], eax ; update previous to point the new node
	mov ebx, eax ; set previous to current
	inc ebx ; point to 'next' field
	mov ecx, [ecx+1] ; continue to next copied element
	jmp .read_node
	finish_copy:
	inc dword [stack_index]
	jmp get_operand

handlePlus:
	mov eax, [stack_index]			; eax has the stack index
	dec eax 
	mov ebx, dword [stack + 4*eax]   ; ebx has the pointer of last number
	dec eax 					   	; inc the stack index
	mov edx, dword [stack + 4*eax] ;edx has the second stack pointer
	;mov cl,0
	computing:
	

	mov al, 0
	mov byte al, [edx] 	; add second to al
	popf
	adc byte al, [ebx]		; add first to al
	
	;add byte al, cl
	;mov cl,0
	;jnc no_carry
	print_msg MSG, 4
	;mov cl, 1
	;no_carry:
	;add byte al, cf 	; add carry****** need to be fixed
	;push ecx
	daa  				; BCD format
	pushf
	;pop ecx
	mov byte [edx],al
	cmp dword [ebx+1], 0 ; check if first number ended 
	je check_carry
	cmp dword [edx+1], 0 ; check if second number ended
	je second_number_ended

	mov dword ebx, [ebx+1]
	mov dword edx, [edx+1]
	jmp computing 

	second_number_ended:
	mov dword ebx, [ebx+1]
	mov dword [edx+1], ebx

	check_carry:
	jnc update_the_stack


	jmp check_carry

	update_the_stack:
	dec dword [stack_index]
	;mov eax, [stack_index]
	;mov byte [stack+ 4*eax], al    ; move the result to edx- second number in stack
	jmp	get_operand

	;============================================================================================
	; Handle_Print
	; eax - carry flag
	; ecx - pointer to node
	; edx - temp register
	; ebx - pointer to previous node
	;============================================================================================
	handle_print:
	mov edx,[stack_index] ; edx has the counter to next index
	dec edx ; edx has the index that should be printed
	mov dword ecx, [stack+ edx * 4] ; ecx has the pointer to first node in stack
	mov ebx, 0 ; init previous node
	.find_last_node:
	cmp ecx, 0
	je .ebx_has_last_node
	mov edx, [ecx+1] ; read the next node
	mov dword [ecx+1],ebx ; set current node to point his parent node
	mov ebx, ecx ; ebx has now the current node pointer for furture use
	mov ecx, edx ; ecx has the next node we should handle
	jmp .find_last_node
	
	.ebx_has_last_node:
	mov ecx, 0
	mov esi, 0 ; will indicate to say if number started(to ignore zero at beggining)
	.iterate_and_print:
	cmp ebx,0
	je .finish_print
	expand_number_to_edx byte [ebx] ; will put for [ebx]= 0001|0010  :  dl=2, dh=1 

	.handle_zero_at_beggining
	cmp esi,0 ; a flage telling if number has already started
	jne .print_values_from_first
	cmp dh,0 
	jne .print_values_from_first
	cmp dl,0 
	jne .print_values_from_second
	jmp .continue_print_iterate

	.print_values_from_first:
	mov byte [print_int_storage], dh
	print_int print_int_storage
	.print_values_from_second:
	mov esi,1 ; telling that the number has started in order to do not ignore zeros anymore
	mov byte [print_int_storage], dl
	print_int print_int_storage 
	
	;this section will fix the next fields to point ahead
	.continue_print_iterate:
	mov edx, [ebx+1] ; edx will have the next node to iterate
	mov [ebx+1], ecx ; make node to point ahead
	mov ecx, ebx; make ecx to point the current node(for next iteration)
	mov ebx, edx ; copy edx pointer, to continue iterate ebx
	jmp .iterate_and_print
	
	.finish_print:
	print_msg NEW_LINE, 4
	mov edx,[stack_index] ; edx has the counter to next index
	dec edx ; edx has the index that should be deleted
	mov dword ecx, [stack+ edx * 4] ; ecx has the pointer to first node in stack
	delete_from_node ecx
	mov [stack_index], edx ; decrease stack_index by one
	jmp get_operand

	handleQuit:
	.cleanup:
    	mov esp, ebp
    	pop ebp
    	ret 