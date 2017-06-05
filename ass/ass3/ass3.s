        global _start, STATE,WorldLength,WorldWidth
        extern init_co, start_co, resume,cell
        extern scheduler, printer, stdout,fprintf, init_scheduler


        ;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1
schedulerId: equ 0
printerId: equ 1


section .data
PRINT_INT_TEMPLATE: 		DB	"%d" ,10,0
TEMPLATE: DB	"%s",10,0	; Format string
FILE_NAME: DB "inputExample.txt",0
section .bss
print_int_storage:
	RESB	4
; FILE_NAME:
; 	RESB	50
WorldLength:
	RESB	4
WorldWidth:
	RESB	4
INT_STORAGE:
	RESB	4
BOARD_SIZE:
        RESB	4
T:
	RESB	4
K:
	RESB	4
STATE:
        RESB 10002
section .text
%macro print_msg 1
	pushad
	push %1
	push TEMPLATE
	push dword [stdout]
	call fprintf
	add esp, 12
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
%macro put_row_in_eax_column_in_ecx 1
push edx
        mov eax, %1
        mov ebx, [WorldWidth]
        xor edx,edx
        idiv ebx
        mov ecx, edx
pop edx

%endmacro
_start:
        enter 0, 0
        mov dword [WorldLength],4
        mov dword [WorldWidth],6
        mov dword [T],10
        mov dword [K],1
        ;============================================================================================
        ;calculate BOARD_SIZE (WorldLength*WorldWidth)
        ;============================================================================================
        mov ebx, dword [WorldLength]
        mov eax, dword [WorldWidth]
        mul ebx
        mov dword[BOARD_SIZE], eax
        ;============================================================================================
        ;Read File
        ;============================================================================================
        mov    eax, 5
        mov    ebx, FILE_NAME
	mov    ecx, 0 ; Read only
	mov    edx, 0700 ; permission
	int    0x80 ; EAX has now the file descriptor

        push eax
        mov esi,0
        mov ecx, dword [WorldLength] ; ecx is the 
        .read_file:
        pop ebx; ebx now have the file descriptor
        push ecx
        push ebx
  
        mov eax ,3
        mov ecx, STATE
        add ecx,esi ; offset in order to do not override what we already read
        mov edx , dword[WorldWidth]
        int    0x80 ; EAX has number of file read
        add esi,dword[WorldWidth]
        
        pop ebx
        push ebx

        mov eax, 19 ;lseek
        mov ecx,1 ;offset
        mov edx, 1; from current position
        int 0x80
        pop ebx
        pop ecx
        push ebx
        loop .read_file
        
        mov eax,6 ; close file
        pop ebx ; ebx have the file descriptor
        int 0x80

        ;============================================================================================
        ;Put '0' instead of ''
        ;============================================================================================
        mov ecx,[BOARD_SIZE]
        mov esi,0 ; offset
        .convert_space_to_zeros:
        cmp byte [STATE +esi],'9'
        jg .set_zero
        cmp byte [STATE +esi],'1'
        jl .set_zero
        jmp .continue_convert_space_to_zeros
        .set_zero:
        mov byte [STATE+esi],'0'
        .continue_convert_space_to_zeros:
        inc esi
        loop .convert_space_to_zeros
        
        
        ;============================================================================================
        ;Initialize all cells
        ;============================================================================================
        mov dword ecx,[BOARD_SIZE] 
        mov esi,0
        .initialize_cells:
        push ecx
        put_row_in_eax_column_in_ecx esi
        mov ebx , esi ; set id to be the counter
        add ebx,2 ; inc the counter because scheduler in in position 0 and printer 1
        mov edx, cell_routine
        call init_co
        pop ecx
        inc esi
        loop .initialize_cells
        ;============================================================================================
        ;Initialize scheduler and printer
        ;============================================================================================
        mov ebx, schedulerId            
        mov edx, scheduler
        mov dword eax,[K]
        mov dword ecx,[T]
        call init_scheduler            ; initialize scheduler state

        mov ebx,printerId           
        mov edx, printer
        call init_co            ; initialize printer state

        mov ebx, schedulerId
        call start_co
        ;xor ebx, ebx            ; starting co-routine = scheduler
        ;call start_co           ; start co-routines


        ;; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h

        ;============================================================================================
        ;cell func:
        ;eax - row
        ;ebx - this cell id
        ;ecx - column
        ;esi - flag to know if needed to update or call cell(x,y)
        ;edi - next status
        ;============================================================================================
        cell_routine: 
        mov esi,0
        sub ebx,2
        .execute:
        cmp esi,0
        je .call_cell_func
        pop edi
        mov [STATE+ebx], edi
        jmp .call_sceduler
        .call_cell_func
        push eax; push row(y)
        push ecx; push column(x)
        call cell
        mov edi,eax 
        pop ecx
        pop eax
        push edi
        .call_sceduler:
        xor esi,1; toggle esi
        push ebx
        mov ebx, schedulerId
        call resume
        pop ebx
        jmp .execute