; Procedure: append
; Appends an element at the end of a linked list
; If the linked list is empty, initialize the list
; Params (in order of pushing on the stack):
; dword element - data to be added
; dword prim - first element in the list
; Return: none
; Modifies the value of prim if it is null

append:
    push ebp            ; Save the stack
    mov ebp, esp

    push eax            ; Save the registers
    push ebx

    push len            ; Size to get from the heap and pass the size to the malloc function
    call malloc         ; Call the malloc function - now eax has the address of the allocated memory

    mov ebx, [ebp + 12]
    mov [eax + info], ebx    ; Add the element to the node data field
    mov dword [eax + next], 0   ; Address of the next element is NULL, because it is the last element in the list

    mov ebx, [ebp + 8]  ; Retrieve the address to the first element
    cmp dword [ebx], 0
    je null_pointer

    mov ebx, [ebx]      ; This parameter was the address of the address
                        ; Now it is the address of the first element, in this case, not null
    ; If it is not NULL, find the address of the last element
next_element:
    cmp dword [ebx + next], 0
    je found_last
    mov ebx, [ebx + next]
    jmp next_element

found_last:
    push eax
    push addMes
    call puts
    add esp, 4              ; Restore the stack
    pop eax

    mov [ebx + next], eax   ; Last element is this one from the newly allocated memory block

go_out:
    pop ebx             ; Restore registers
    pop eax

    mov esp, ebp
    pop ebp
    ret 8               ; Return to the caller function and cleaning the stack

null_pointer:
    push eax
    push nullMes
    call puts
    add esp, 4
    pop eax

    mov [ebx], eax      ; Point the address of the first element to the allocated memory

    jmp go_out