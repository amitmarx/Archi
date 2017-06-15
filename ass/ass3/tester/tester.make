all: ass3

ass3: ass3.o printer.o scheduler.o coroutines.o 
	gcc -m32 -Wall -g -nostartfiles coroutinesC.c ass3.o printer.o scheduler.o coroutines.o -o ass3

ass3_start: ass3.o printer.o scheduler.o coroutines.o 
	gcc -m32 -Wall -g coroutinesC.c ass3.o printer.o scheduler.o coroutines.o -o ass3

ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o

printer.o: printer.s
	nasm -f elf printer.s -o printer.o

scheduler.o: scheduler.s
	nasm -f elf scheduler.s -o scheduler.o
	
coroutines.o: coroutines.s
	nasm -f elf coroutines.s -o coroutines.o
	
	
.PHONY: clean
clean:
	rm -f *.o ass3 
