        global _start, STATE,WorldLength,WorldWidth
        extern init_co, start_co, resume,cell
        extern scheduler, printer, init_scheduler


        ;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1
schedulerId: equ 0
printerId: equ 1
sys_write:      equ   4
stderr:         equ   2


section .data
ten: DD	        10
FILE_NAME:
 	DD      0
IS_DEBUD:
        DB      0
LENGTH_LABEL: DB "length="
WIDTH_LABEL: DB "width="
GENERATIONS_LABEL: DB "number of generations="
PRINT_FREQUENCY_LABEL: DB "print frequency="
NEW_LINE: DB 10

section .bss
print_int_storage:
	RESB	4
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

LENGTH_INPUT_POINTER: 
        RESB	4
WIDTH_INPUT_POINTER: 
        RESB	4
T_INPUT_POINTER:
	RESB	4
K_INPUT_POINTER:
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
%macro print_debug 2
        pushad
        mov ecx, %1
        mov edx, %2
        mov eax, sys_write
        mov ebx, stderr
        int 80h
        popad
%endmacro

%macro put_strlen_in_eax 1  
    push ecx
    push edx
    mov ecx, %1
    xor eax, eax        ; loop counter
%%startLoop:
    xor edx, edx
    mov dl, [ecx+eax]
    inc eax
    cmp dl, 0 ; null byte    
    jne %%startLoop
%%end:
        dec eax
        pop edx
        pop ecx
%endmacro
_start:
        enter 0, 0
        mov eax, [ebp + 4]      ; eax = argc
        mov esi,0
        cmp eax,7               ;number of args in case -d is on.
        jl .reading_args
        .debug_mode:
        mov esi,4
        mov byte[IS_DEBUD],1
        ;debug_print_info debug_length, 7
        ; mov ecx, 16
        ; add ecx,ebp
        ; mov ebx, [ebp+20]
        ; mov   dword [store_arg], ebx
        ; debug_print_info store_arg,4


        ;============================================================================================
        ;filename - ebp+12
        ;length - ebp+16
        ;width - ebp+20
        ;T - ebp+24
        ;K - ebp+28
        ;============================================================================================
        .reading_args:
        mov eax, dword [ebp+12+esi] 
        mov dword [FILE_NAME], eax

        mov eax, dword [ebp+16+esi] 
        mov [LENGTH_INPUT_POINTER], eax
        call atoi
        mov dword [WorldLength], eax

        mov eax, dword [ebp+20+esi] 
        mov [WIDTH_INPUT_POINTER], eax
        call atoi
        mov dword [WorldWidth], eax
        
        mov eax, dword [ebp+24+esi]
        mov [T_INPUT_POINTER], eax 
        call atoi
        mov dword [T], eax

        mov eax, dword [ebp+28+esi] 
        mov [K_INPUT_POINTER], eax 
        call atoi
        mov dword [K], eax



        ; mov dword [WorldLength],4
        ; mov dword [WorldWidth],6
        ; mov dword [T],10
        ; mov dword [K],1
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
        mov    ebx, [FILE_NAME]
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
        ;Print debug if needed
        ;============================================================================================
        .debug_label:
        cmp byte [IS_DEBUD],0
        je .skip_debug
        
        print_debug LENGTH_LABEL,7
        put_strlen_in_eax [LENGTH_INPUT_POINTER]
        print_debug [LENGTH_INPUT_POINTER],eax
        print_debug NEW_LINE,1

        print_debug WIDTH_LABEL,6
        put_strlen_in_eax [WIDTH_INPUT_POINTER]
        print_debug [WIDTH_INPUT_POINTER],eax
        print_debug NEW_LINE,1

        print_debug GENERATIONS_LABEL,22
        put_strlen_in_eax [T_INPUT_POINTER]
        print_debug [T_INPUT_POINTER],eax
        print_debug NEW_LINE,1

        print_debug PRINT_FREQUENCY_LABEL,16
        put_strlen_in_eax [K_INPUT_POINTER]
        print_debug [K_INPUT_POINTER],eax
        print_debug NEW_LINE,1
        
        pushad
        mov esi,STATE
        mov ecx, [WorldLength]
        .print_row:
        print_debug esi,[WorldWidth]
        add esi, [WorldWidth]
        print_debug NEW_LINE,1
        loop .print_row
        popad
        print_debug NEW_LINE,1
        .skip_debug:
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
        pop edi ; edi has 4 bytes of char
        push eax ; save eax
        mov eax, edi ; use eax in order to write to STATE only 1 byte
        mov byte [STATE+ebx], al ; write 1 byte (al)
        pop eax ; restore eax
        jmp .call_sceduler
        .call_cell_func:
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

;============================================================================================
;atoi - string to int
;============================================================================================
atoi:
        push    ebp
        mov     ebp, esp        ; Entry code - set up ebp and esp
        push ecx
        push edx
        push ebx
        mov ecx, eax  ; Get argument (located in eax)
        xor eax,eax
        xor ebx,ebx
atoi_loop:
        xor edx,edx
        cmp byte[ecx],0
        jz  atoi_end
        imul dword[ten]
        mov bl,byte[ecx]
        sub bl,'0'
        add eax,ebx
        inc ecx
        jmp atoi_loop
atoi_end:
        pop ebx                 ; Restore registers
        pop edx
        pop ecx
        mov     esp, ebp        ; Function exit code
        pop     ebp
        ret