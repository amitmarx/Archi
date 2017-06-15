        global printer
        extern resume
        extern STATE,WorldLength,WorldWidth

        ;; /usr/include/asm/unistd_32.h
sys_write:      equ   4
stdout:         equ   1


section .data

hello:  db 'hello', 10
NEW_LINE:  db 10,0


section .text
%macro print 2
        pushad
        mov eax, sys_write
        mov ebx, stdout
        mov ecx, %1
        mov edx, %2
        int 80h
        popad
%endmacro
printer:
        mov esi,STATE
        mov ecx, [WorldLength]
        .print_row:
        print esi,[WorldWidth]
        add esi, [WorldWidth]
        print NEW_LINE,1
        loop .print_row


        xor ebx, ebx
        call resume             ; resume scheduler
        jmp printer