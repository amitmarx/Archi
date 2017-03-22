all: addApp

addApp: main.o add.o numbers.o
	gcc -m32 -g -Wall -o addApp main.o add.o numbers.o

main.o: main.c
	gcc -m32 -g -Wall -ansi -c -o main.o main.c

add.o: add.s
	nasm -g -f elf -w+all -o add.o add.s

numbers.o: numbers.c
	gcc -m32 -g -Wall -ansi -c -o numbers.o numbers.c