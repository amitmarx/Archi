all: ass3

ass3:
	nasm -g -f elf coroutines.s -o coroutines.o
	nasm -g -f elf printer.s -o printer.o
	nasm -g -f elf scheduler.s -o scheduler.o
	gcc -m32 -Wall -g ass3.c coroutines.o printer.o scheduler.o -o ass3
	
#Clean the build directory
clean: 
	rm -f *.o ass3