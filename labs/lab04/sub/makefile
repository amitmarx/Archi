#format is target-name: target dependencies
#{-tab-}actions
CC = gcc
CC_FLAGS = -m32 -g -Wall -ansi 

EXEC = app
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)

# All Targets
all: clean $(EXEC)

app:
	nasm -f elf start.s -o start.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector utils.c -o utils.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector task2b.c -o task2b.o
	ld -melf_i386 start.o utils.o task2b.o -o $(EXEC) 

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o $(EXEC)