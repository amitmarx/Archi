section .text
global _start
global system_call
global infector
extern main
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

code_start:    
    infection:
        push	ebp
	    mov	ebp, esp	; Entry code - set up ebp and esp
        pushad			; Save registers
        ;;;;;;;;;;;;;;;;;;;;
        mov     eax, 4          ; Copy function args to registers: leftmost...        
        mov     ebx, 2   ; Next argument...
        mov     ecx, msg   ; Next argument...
        mov     edx, 21   ; Next argument...
        int     0x80            ; Transfer control to operating system
        ;;;;;;;;;;;;;;;;;;;;
        popad			; Restore registers
	    mov	esp, ebp	; Function exit code
	    pop	ebp
	    ret
        msg:
            db  'Hello, Infected File'; Init string 
            db 10
    infector:
    push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	sub    esp, 4
	pushad			; Save registers
    
    mov    eax,5                 ; open file
	mov    ebx, dword [ebp+8]    ; First argument 
	mov    ecx, 2
	int    0x80                  ; Transfer control to operating system


	mov eax, 19					;seek syscall
    mov ebx, [ebp-4]				;in the file
    mov ecx, 0					; offset
    mov edx, 2					;SET_END
    int 0x80					 ; Transfer control to operating system

    ;write to file the messege;
	mov    eax, 4
	mov    ecx, infection             ;address of code start
	mov    edx, infector               ;adress of code end
	sub    edx, infection             ; get edx = codestart-codeend.
	int    0x80
    
    ;close file
    mov    ebx, [ebp-4]              ; pointer to file from ebp-4 to ebx
	mov    eax, 6
	int    0x80
    

	popad			; Restore registers
	mov     eax, [ebp-26]
	add esp ,4
	pop	ebp
	ret

code_end: