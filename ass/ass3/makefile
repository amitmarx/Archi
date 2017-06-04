
# All Targets
all: ass3

ass3: ass3.o printer.o scheduler.o coroutines.o cell.o
	gcc -m32 -Wall -g -nostartfiles ass3.o printer.o scheduler.o coroutines.o cell.o -o ass3

# Depends on the source and header files
ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o

printer.o: printer.s
	nasm -f elf printer.s -o printer.o

scheduler.o: scheduler.s
	nasm -f elf scheduler.s -o scheduler.o

coroutines.o: coroutines.s
	nasm -f elf coroutines.s -o coroutines.o
cell.o: cell.c
	gcc -g -Wall -m32 -ansi -c -o cell.o cell.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass3