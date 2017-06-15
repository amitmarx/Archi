printerId: equ 1
        global scheduler
        extern WorldLength,WorldWidth,resume, end_co, stdout,fprintf

section .data
MSG: 	db "SOME MESSAGE",10,0
TEMPLATE: DB	"%s", 0	; Format string

section .bss
BOARD_SIZE:
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
	add		esp, 12
	popad
%endmacro

scheduler:
        ;;;;;;;;;;;;;;;;;;Calc BOARD_SIZE;;;;;;;;;;;;;;;;;;
        mov ebx, dword [WorldLength]
        mov eax, dword [WorldWidth]
        mul ebx
        mov dword[BOARD_SIZE], eax

        add dword[BOARD_SIZE],2 ; we inc the board size because we start from 2 and not 0
        pop ecx ; will store 'T'
        pop eax ; will store 'K'
        shl ecx,1 ; double in order to support half-generation
        mov dword [K], eax
        mov ebx,2 ; first cell to run
        .run_generation:
        cmp ebx,[BOARD_SIZE]
        je .finish_generation
        call resume
        dec eax ; decreace k
        cmp eax,0
        jne .skip_printing
        push ebx
        mov ebx, printerId
        call resume ; give time to printer
        pop ebx
        mov eax,[K]
        .skip_printing:
        inc ebx ; move to next cell
        jmp .run_generation
        .finish_generation:
        mov ebx, 2
        loop .run_generation
        ;;;;one last time slice to printer
        mov ebx, printerId
        call resume
        ;;;;finish program
        call end_co
