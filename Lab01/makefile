all: addApp

addApp: add.o numbers.o
	gcc -m32 -g -Wall -o addApp add.o numbers.o

add.o: add.s
	nasm -g -f elf -w+add -o add.o add.s

numbers.o: numbers.c


