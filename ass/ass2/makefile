
# All Targets
all: calc1

calc1: calc.o
	gcc -m32 -Wall -g calc.o -o calc1

# Depends on the source and header files
calc.o: calc.s
	nasm -f elf calc.s -o calc.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o calc1