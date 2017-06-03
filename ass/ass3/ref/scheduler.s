Function:
	push dword 1
	push dword [CORS]
	push dword [CURR]
	push dword FMT2
	call printf
	add ESP, 16
	mov EBX, [CORS] ; resume CO1
	call resume
	push dword 2
	push dword [CORS]
	push dword [CURR]
	push dword FMT2
	call printf
	add ESP, 16
	mov EBX, [CORS+4] ; resume CO2
	call resume
	push dword 3
	push dword [CORS+4]
	push dword [CURR]
	push dword FMT2
	call printf
	add ESP, 16
	mov EBX, [CORS] ; resume CO1
	call resume
	push dword 4
	push dword [CORS]
	push dword [CURR]
	push dword FMT2
	call printf
	add ESP, 16
	mov EBX, [CORS+4] ; resume CO2
	call resume
	jmp end_co ; resume main 