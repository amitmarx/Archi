
# All Targets
all: hello

hello: main.o myasm.o
	gcc -m32 -g -Wall -o hello main.o myasm.o

# Depends on the source and header files
main.o: main.c
	gcc -g -Wall -m32 -ansi -c -o main.o main.c 
 
myasm.o: myasm.s
	nasm -g -f elf -w+all -o myasm.o myasm.s


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o hello