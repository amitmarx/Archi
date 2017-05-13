section .rodata
TEMPLATE: DB	"%.*s", 10, 0	; Format string
MOVE_LINE:		DB	10, 0
PRINT_INT_TEMPLATE: 		DB	"%d" ,0,0
MSG: 	db "Read number",10,0 
section .data
	element_size equ 5
	stack_index:	dd	0
	printing_tmp:		dd	0 
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
carry_flag:
	RESB	4
shift_left_flag
 	RESB	4
shift_left_counter
 	RESB	4


section .text 
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

%macro print_reg 1
push %1
	mov tem_reg, %1
	print_msg tem_reg, 4
pop %1
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
	cmp byte [ecx], 'l'
	je handleShiftLeft
	; cmp byte [ecx], 'r'
	; je handleShiftRight
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
	
	.read_node
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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ref code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
handle_print:

	mov	ebx, 0
	mov	eax, 0
	mov	ecx, 0			;Setting to null all the registers for the print functions	
	mov	eax, [stack_index]
	dec eax
	mov	ebx, dword [stack + 4*eax]	
	cmp	ebx, 0
	jmp	printLoop


printLoop:					
	cmp	ebx, 0
	je	print_the_number
	mov	eax, 0
	mov	al, byte [ebx]        
	mov	byte [array + ecx], al
	inc	ecx
	mov	ebx, dword [ebx+1]
	jmp	printLoop
;We copy the elements in the array from the end

print_the_number:
	mov	byte [array + ecx], 0
	dec	ecx
	mov	edx, 0
	
	print_first_number:
	mov	dl, byte [array + ecx]
	and	dl, 11110000b
	shr	dl, 4
	cmp 	byte dl, 0
	je	continue_first_number
	push	ecx
	push	edx
	call	hex_number_print_value
	add	esp, 4
	pop	ecx

continue_first_number:
	mov	dl, byte [array + ecx]
	and	dl, 00001111b
	push	ecx
	push	edx
	call	hex_number_print_value ;Calling the function that print the value
	add	esp, 4
	pop	ecx
	
hex_number_print_loop:
	dec	ecx
	mov	edx, 0
	cmp	ecx, 0
	jl	end_of_printing
	mov	dl, byte [array + ecx]
	and	dl, 11110000b
	shr	dl, 4
	push	ecx
	push	edx
	call	hex_number_print_value
	add	esp, 4
	pop	ecx
	mov	dl, byte [array + ecx]
	and	dl, 00001111b
	push	ecx
	push	edx
	call	hex_number_print_value ;Calling the function that print the value
	add	esp, 4
	pop	ecx
	jmp	hex_number_print_loop ; keep looping until printing all the elements


end_of_printing:
	pusha
	push	MOVE_LINE
	call	printf
	add	esp, 4
	popa
	dec	dword [stack_index]			
	inc	dword [operations_counter]
	jmp	get_operand

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
				
	computing:
	mov dword [carry_flag], 0
	clc									; flag reset	
	popf
	mov al, 0 							; al initialization
	mov byte al, [edx] 					; mov second element data to al 
	adc byte al, [ebx]					; add first element data to al 
	daa  								; BCD format
	pushf
	
	jnc continue_no_carry_to_save 		; check if there is a carry after adc operation
	inc dword [carry_flag] 				; in case there is carry- inc the flag
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
	mov dword ebx, [ebx+1]				; update ebx (pointer of first element) to the its next node
	mov dword [edx+1], ebx 				; last node of second element (edx) point to the remaining nodes of first element

	check_carry:						; check the carry after done computing
	cmp dword [carry_flag], 0 			; check if there is carry (0- no carry)
	je update_the_stack

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
	popf
	mov byte al, 0 						 
	adc byte al, 0						
	daa  								
	pushf

	update_the_stack: 
	mov dword [carry_flag], 0			; reset the carry_flag 				
	dec dword [stack_index] 			; after the operation- dec the stack_index (run over the first element in stack)
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
 mov esi, [stack_index]					; eax has the stack index
 dec esi  								; dec stack index twice to get the second element 								
 dec esi 					   		 
 mov edx, dword [stack + 4*esi] 		; edx has the second stack pointer

 check_exponent:						; **NEED TO BE ADDED** (exponent should be one byte)
 
 exponent_counter: 						; count the second element data (k)
 cmp byte [edx], 0 						
 je reset_second_element
 inc dword [shift_left_counter] 		; inc the shift_left_counter (=k)
 dec byte [edx]
 jmp exponent_counter

 reset_second_element: 					; reset second element in stack to node with 0 as data
 mov byte bl, 0 						; bl stores 0 data
 create_new_node_in_eax bl 				; create new node with bl as data
 mov dword [stack + 4*esi], eax 		; update the second element in stack to the new node
 jmp handlePlus  						; add the first element to zero- it moves the first number one element down in stack 
 continue_sl_first_plus: 
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ref code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
handleQuit:
cleanup:
    mov esp, ebp
    pop ebp
    ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ref code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hex_number_print_value:        	               
	push    ebp              	
	mov     ebp, esp         	
	pushad
	mov	eax, dword [ebp+8] ; Putting the input number in EAX
	
	jmp print_it

;Printing according to the input: letter or number
print_it:
	mov	dword [printing_tmp], eax
	mov	eax, printing_tmp
	push	dword[printing_tmp]
	push 	PRINT_INT_TEMPLATE
	call	printf
	add	esp, 8

	popad     	             	; restore all previously used registers
	mov     esp, ebp
	pop     dword ebp
	ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ref code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;