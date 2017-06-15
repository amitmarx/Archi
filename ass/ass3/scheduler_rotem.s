        global scheduler
        extern resume, end_co,  cors,  stacks
        ;extern  num_of_cells
        ;extern num_of_generations, printing_frequency
        extern WorldWidth, WorldLength

section .data
	;digit:                  db "0123456789"
	maxcors:        equ 100*100+2         ; maximum number of co-routines
	stacksz:        equ 16*1024     ; per-co-routine stack size
	num_of_generations: dd 0
	printing_frequency: dd 0
	num_of_cells: 		dd 0
section .text

scheduler:
		;one iteration - number of generations(t).
		;  another iteration - go twice over all the cells.
		;	another iteration inside - how often to print (k).
		
		push ebx
		;---start of our code -----;
		mov eax,0
        mov ebx,0
        mov byte al, [WorldLength]
        mov byte bl, [WorldWidth]
        mul bl                  ;now eax stores the amount of cells;

        mov [num_of_cells], eax 
        pop ebx

		mov eax,stacksz
        imul ebx			    ; eax = co-routines stack offset in stacks
        
		add eax, stacks + stacksz ; eax = top of (empty) co-routines stack
		mov esi,0
		mov dword esi, [eax-4] 				;this is the place where num of generations was pushed in init_co
		mov [num_of_generations], esi
		mov dword esi, [eax-8] 				; ;this is the place where print frequency was pushed in init_co
		mov [printing_frequency], esi
       	mov ebx,2
       	mov edi,0
       	mov edi, [num_of_generations]

       	generation_loop:


       	;---------------;
       	;cmp edi, 0
       	;je end_of_generation_loop
		;push edi
		;mov edx, [num_of_cells]
		;shl edx,1 ;visit AND update


       	mov esi, [printing_frequency]
       	handle_cell_loop:
       	; edi - num of generations left. 
       	; esi - num of cell funcs until printer calling
       	; edx - num of cells to complete a generation.
       	mov dword ecx,[num_of_cells]
       	add ecx , 2 
       	cmp  dword ebx,ecx
       	jl .keep_regular
       	mov ebx,2
       	.keep_regular:
       	
       	cmp esi, 0
       	je end_of_handle_cell_loop   ; go to printer.
       	cmp edx, 0 	
       	jg .no_changes 
       	dec edi							; means it is end of generation
       	cmp edi,0 						
       	jl end_of_generation_loop
       	
       	mov edx, [num_of_cells] 
		shl edx,1 ;visit AND update 	;new generation begins.

       	.no_changes:

       	push ebx
       	push edx
       	call resume
       	pop edx
       	pop ebx
       	inc ebx	
       	
       	dec edx  						;one less cell
       	dec esi 						;one less stop intil going to printer.
       	jmp handle_cell_loop
       	end_of_handle_cell_loop:
      


       	go_to_print: 					;maybe we got one spare print.
       	push ebx
       	push edx
       	mov ebx, 1
       	call resume             ; resume printer
       	pop edx
       	pop ebx


		;.take_generation_down:
		;dec edi
		;mov edx, [num_of_cells]
		;shl edx,1 ;visit AND update

		;.not_finished_generation:

       	;---------------; 	
       	jmp generation_loop
       	end_of_generation_loop:
       	mov ebx, 1 										;make one last print
       	call resume             ; resume printer


        

        call end_co             ; stop co-routines