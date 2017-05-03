section .rodata
	element_size equ 5 

section .bss
stack:
	RESB	20

section .text 
	 extern printf 
     extern fprintf 
     extern malloc 
     extern free
     extern fgets 
     extern stderr 
     extern stdin 
     extern stdout
	 global main
 main:
	mov ebx, stack			; pointer to the stack 
	get_operand:
	push element_size
	call malloc ; eax has the a poiter to allocated memory
	pushad ; save registers content
	;push dword [stdin] ; pointer to stdin
	;push 1 ; number of bytes to read
	;push eax ; pointer to new node		
	;call fgets ; read 1 byte from stdin
	;popad ; restore registers content

;	cmp byte [eax], 10
;	je handleEnter
;	cmp byte [eax], '+'
;	je handlePlus
;	cmp byte [eax], 'l'
;	je handleShiftLeft
;	cmp byte [eax], 'r'
;	je handleShiftRight
;	cmp byte [eax], 'p'
;	je handlePrint
;	cmp byte [eax], 'd'
;	je handleDouble
;	cmp byte [eax], 'q'
;	je handleQuit

;handleEnter:
;handlePlus:
;handleShiftLeft:
;handleShiftRight:
;handlePrint:
;handleDouble:
;handleQuit:

