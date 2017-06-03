 extern SPMAIN 
 extern CORS
 extern CURR  
 extern SPP
start_co_from_c:
	push ebp
	mov ebp, esp
	pushad
	mov [SPMAIN], esp ; save ESP of main ()
	mov ebx, [ebp+8] ; gets ID number of a scheduler
	mov ebx, [ebx*4 + CORS] ; gets a pointer to a scheduler structure
	jmp do_resume ; resume a scheduler co-routine

end_co:
	mov esp, [SPMAIN] ; restore state of main code
	popad
	pop ebp
	ret

resume: ; save state of caller
	pushfd
	pushad
	mov edx, [CURR]
	mov [edx+SPP],esp ; save current SP

do_resume: ; load SP for resumed co-routine
	mov esp, [ebx+SPP]
	mov [CURR], ebx
	popad ; restore resumed co-routine state
	popfd
	ret ; "return" to resumed co-routine! 