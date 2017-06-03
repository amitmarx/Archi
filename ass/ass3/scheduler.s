        global scheduler
        extern resume, end_co, stdout,fprintf

section .data
MSG: 	db "SOME MESSAGE",10,0
TEMPLATE: DB	"%s", 0	; Format string

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
        print_msg MSG
        mov ebx, 1
.next:
        call resume             ; resume printer
        loop .next

        call end_co             ; stop co-routines