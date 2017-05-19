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

carry_flag:
	RESB	4
shift_left_flag
 	RESB	4
shift_left_counter
 	RESB	4



section .text 
%macro pop_and_free 0
	pushad
	mov edx,[stack_index] ; edx has the counter to next index
	dec edx ; edx has the index that should be deleted
	mov dword ecx, [stack+ edx * 4] ; ecx has the pointer to first node in stack
	delete_from_node ecx
	mov [stack_index], edx ; decrease stack_index by one
	popad
%endmacro
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
	
	
	cmp byte [ecx], '+'
	je handlePlus
	cmp byte [ecx], 'r'
	je handle_Shift_Right
	cmp byte [ecx], 'l'
	je handleShiftLeft
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
	; edi - holds the amount needed to be shifted
	;============================================================================================
	handle_Shift_Right:
	mov edx,[stack_index] ; edx has the counter to next index
	dec edx ; edx has the index that to amount of shifts
	mov dword ecx, [stack+ edx * 4] ; ecx has the pointer to amount of shifts
	cmp dword [ecx+1],0
	;;;;;;;;;;;;TODO:WRITE AN ERROR;;;;;;;;;;;;;;
	jne get_operand
	mov al, [ecx] ; al has the amount in BCD
	expand_number_to_edx al
	mov eax,0
	mov al, dh
	mov bl, 10
	mul bl ; ax has now dh*10
	mov edi,0
	add al, dl
	add edi,eax 
	pop_and_free

	.make_shift:
	
	cmp edi, 0
	je .finish_shift_right
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
	je .finish_one_shift_right_iteration
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
	
	.finish_one_shift_right_iteration:
	dec edi
	jmp .make_shift

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
	cmp dword [shift_left_flag], 0
	je get_operand
	jmp continue_sl_double
	

	;============================================================================================
	;HANDLE_PLUS
	; eax - stack index
	; ebx - pointer to last element in stack
	; edx - pointer to second element in stack
	; al  - the result of plus operation between two parallel nodes
	;============================================================================================

;**NEED TO BE ADDED**- FREE THE FIRST ELEMENT
handlePlus:
	mov eax, [stack_index]				; eax has the stack index
	dec eax 							; dec the stack index to point the first element in stack
	mov ebx, dword [stack + 4*eax]   	; ebx has the pointer of last number
	dec eax 					   		; dec the stack index to point the second element in stack
	mov edx, dword [stack + 4*eax] 		; edx has the second stack pointer
	clc									; flag reset	
	pushf
	computing:
	mov al, 0 							; al initialization
	mov byte al, [edx] 					; mov second element data to al 
	popf
	adc byte al, [ebx]					; add first element data to al 
	daa  								; BCD format
	pushf
	
	jnc continue_no_carry_to_save 		; check if there is a carry after adc operation
	;inc dword [carry_flag] 				; in case there is carry- inc the flag
	continue_no_carry_to_save:

	mov byte [edx],al 					; update the result into second element data
	cmp dword [ebx+1], 0 				; check if first element list ended 
	je check_carry
	cmp dword [edx+1], 0 				; check if second element list ended	
	je second_number_ended
	mov dword ebx, [ebx+1] 				; move on to next node of first element list
	mov dword edx, [edx+1]				; move on to next node of second element list
	jmp computing 						; continue computing with next nodes

	second_number_ended:				; in case second element list ended, but first one not
	mov dword ecx, [ebx+1]				; update ebx (pointer of first element) to the its next node
	mov dword [ebx+1],0					; Set to zero so when we delete, we will not delete further then here.
	mov dword [edx+1], ecx 				; last node of second element (edx) point to the remaining nodes of first element
	
	check_carry:						; check the carry after done computing
	popf
	jnc update_the_stack
	
	cmp dword [edx+1], 0
	je add_carry
	mov edx, [edx+1]
	mov byte al, [edx] 					; mov second element data to al 
	add byte al, 1					; add first element data to al 
	daa  								; BCD format
	pushf
	mov byte [edx],al 					; update the result into second element data
	jmp check_carry

	add_carry:							; only in case there is carry
	mov byte bl, 1 						; bl sotres the carry
	create_new_node_in_eax bl			; create new node with bl as data


	check_second_number_ended: 			; check if second element ended to add the new carry node 			
	cmp dword [edx+1], 0 
	je add_carry_node
	mov dword edx, [edx+1] 				; in case the second element not ended- move on until its last node
	jmp check_second_number_ended
	add_carry_node:
	mov dword [edx+1], eax  			; add last node of the carry to second element

	;*MAYBE THERE IS A BETTER SOLUTION*
	;*RESET CARRY FOR THE NEXT ADC*
	; popf
	; mov byte al, 0 						 
	; adc byte al, 0						
	; daa  								
	; pushf

	update_the_stack: 
	;mov dword [carry_flag], 0			; reset the carry_flag 				
	;dec dword [stack_indexx] 			; after the operation- dec the stack_index (run over the first element in stack)
	pop_and_free
	cmp dword [shift_left_flag], 0 		; check if the operation in shift left- first call
	je get_operand
	cmp dword [shift_left_flag], 1 		; check if the operation in shift left- second call
	je continue_sl_first_plus
	jmp continue_sl_plus

	;============================================================================================
	;HANDLE_SHIFT_LEFT
	;esi - stack index
	;edx - second element pointer in stack
	;ebx - (bl) data zero 
	;eax - new node with data 0 (bl) to reset the second element in stack
	;============================================================================================

;**NEED TO BE ADDED**- FREE THE SECOND ELEMENT
handleShiftLeft:
 inc dword [shift_left_flag] 			; inc shift_left_flag for first call

 check_exponent:						; **NEED TO BE ADDED** (exponent should be one byte)
 
 exponent_counter: 						; count the second element data (k)
 	pushad
 	mov edx,[stack_index] ; edx has the counter to next index
	dec edx ; edx has the index that to amount of shifts
	mov dword ecx, [stack+ edx * 4] ; ecx has the pointer to amount of shifts
	cmp dword [ecx+1],0
	;;;;;;;;;;;;TODO:WRITE AN ERROR;;;;;;;;;;;;;;
	jne get_operand
	mov al, [ecx] ; al has the amount in BCD
	expand_number_to_edx al
	mov eax,0
	mov al, dh
	mov bl, 10
	mul bl ; ax has now dh*10
	mov edi,0
	add al, dl
	add edi,eax 
	pop_and_free
	mov dword [shift_left_counter],edi
	popad

 
;  cmp byte [edx], 0 						
;  je reset_second_element
;  inc dword [shift_left_counter] 		; inc the shift_left_counter (=k)
;  dec byte [edx]
;  jmp exponent_counter

 reset_second_element: 					; reset second element in stack to node with 0 as data
 mov byte bl, 0 						; bl stores 0 data
 create_new_node_in_eax bl 				; create new node with bl as data
 mov esi, [stack_index]					; esi has the stack index
 mov edx, dword [stack + 4*esi] 		; edx has the second stack pointer(the one should be multiplied)
 mov dword [stack + 4*esi], eax 		; update the second element in stack to the new node
 inc dword [stack_index]
 jmp handlePlus  						; add the first element to zero- it moves the first number one element down in stack 
 continue_sl_first_plus: 
 print_msg MSG,4
 inc dword [shift_left_flag] 			; inc shift_left_flag for second call

 shift_left_compute: 					; computing operation loop
 cmp dword [shift_left_counter], 0 		; loop for shift_left_counter (=k)
 je end_shift_left 
 jmp handle_Double 						; call handle_Double
 continue_sl_double: 
 jmp handlePlus 						; call handlePlus
 continue_sl_plus:
 dec dword [shift_left_counter] 		; dec shift_left_counter (=k)
 jmp shift_left_compute 				; return loop

 end_shift_left:
 mov dword [shift_left_flag], 0 		; reset shift_left_flag
 mov dword [shift_left_counter], 0 		; reset shift_left_counter
 jmp get_operand

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
	pop_and_free
	jmp get_operand

	handleQuit:
	.cleanup:
    	mov esp, ebp
    	pop ebp
    	ret 