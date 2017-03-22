section .data                    	; data section, read-write
        an:    DD 0              	; this is a temporary var

section .text                    	; our code is always in the .text section
        global do_Str          	; makes the function appear in global scope
        extern printf            	; tell linker that printf is defined elsewhere 							; (not used in the program)

do_Str:                        	; functions are defined as labels
        push    ebp              	; save Base Pointer (bp) original value
        mov     ebp, esp         	; use base pointer to access stack contents
        pushad                   	; push all variables onto stack
        mov ecx, dword [ebp+8]	; get function argument

;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE STARTS HERE ;;;;;;;;;;;;;;;; 

	mov	dword [an], 0		; initialize answer
	label_here:
		cmp byte [ecx], 0x41               ; compare al with "A"
        jl not_a_letter               ; jump to next character if less
        cmp byte [ecx], 0x5A               ; compare al with "Z"
        jle next_char           ; if al is >= "A" && <= "Z" -> found a letter
        cmp byte [ecx], 0x61               ; compare al with "a"
        jl not_a_letter               ; jump to next character if less (since it's between "Z" & "a")
        cmp byte [ecx], 0x7A               ; compare al with "z"
        jg not_a_letter               ; above "Z" -> not a character
        jmp found_letter
        
        not_a_letter:
            inc dword [an] ; increase if not an english letter
			cmp byte [ecx], 40
			je change_left
			cmp byte [ecx], 41
			je change_right
			jmp next_char
			
        change_left:
			add byte [ecx], 20
			jmp next_char
			
		change_right:
			add byte [ecx], 21
			jmp next_char
			
        found_letter:
        ; make a capital latter
        sub byte [ecx], 32
        
    next_char:
		inc ecx      	    ; increment pointer
		cmp byte [ecx], 0   ; check if byte pointed to is zero
		jnz label_here      ; keep looping until it is null terminated

;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE ENDS HERE ;;;;;;;;;;;;;;;; 

         popad                    ; restore all previously used registers
         mov     eax,[an]         ; return an (returned values are in eax)
         mov     esp, ebp
         pop     ebp
         ret 
		 