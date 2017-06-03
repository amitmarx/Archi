        global _start
        extern init_co, start_co, resume
        extern scheduler, printer, stdout,fprintf


        ;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1


section .data
PRINT_INT_TEMPLATE: 		DB	"%d" ,10,0
TEMPLATE: DB	"%s",10,0	; Format string
section .bss
print_int_storage:
	RESB	4
FILE_NAME:
	RESB	50
LENGTH:
	RESB	4
WIDTH:
	RESB	4
T:
	RESB	4
K:
	RESB	4
section .text
%macro print_msg 1
	pushad
	push %1
	push TEMPLATE
	push dword [stdout]
	call fprintf
	add	        	esp, 12
	popad
%endmacro
%macro print_int 1

	pushad
	mov eax, %1
	push 	dword [eax]
	push PRINT_INT_TEMPLATE
	push dword [stdout]
	call fprintf
	add		esp, 12
	popad
%endmacro
%macro parse_numeric_value 2
        pushad
        mov eax,0
        %%iterate:
        inc %2
        cmp byte [%2], ' '
        je %%endmacro
        
        mov edx,0
        mov byte dl, [%2]
        sub byte dl,'0' ; dl has now the real numeric value
        
        push ebx 
	mov bl, 10
	mul bl ; ax has now ax*10
        pop ebx
        add al, dl
        mov dword %1, eax
        jmp %%iterate
        
	%%endmacro:
	popad
%endmacro
_start:
        enter 0, 0

        mov ecx, [ebp + 4]      ; ecx = argc
        mov ebx, [ebp+8]   ; ebx has the pointer to argv
        add ebx, 5 ; skip ass3
        mov edx,0
        .read_filename:
        cmp byte [ebx], ' '
        je .read_length
        mov byte al,[ebx]
        mov byte [FILE_NAME + edx],al 
        inc ebx
        inc edx
        jmp .read_filename
        .read_length:
        ;parse_numeric_value [LENGTH], ebx
        ; parse_numeric_value [WIDTH], ebx
        ; parse_numeric_value [T], ebx
        ; parse_numeric_value [K], ebx

        mov dword [LENGTH], 0
        iterate:
        inc ebx
        cmp byte [ebx], ' '
        je endmacro
        mov [LENGTH], eax
        
        mov edx,0
        mov byte dl, [ebx]
        sub byte dl,'0' ; dl has now the real numeric value
        
        push ebx 
	mov bl, 10
	mul bl ; ax has now al*10
        pop ebx
        add al, dl
        mov [LENGTH], eax
        jmp iterate
        endmacro:

        print_msg FILE_NAME
        print_int LENGTH
        ; print_int WIDTH
        ; print_int T
        ; print_int K


        


        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler

        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state


        xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines


        ;; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h