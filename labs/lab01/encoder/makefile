all: encoder

encoder: encoder.o
	gcc -m32 -g -Wall -o encoder encoder.o
encoder.o: main.c
	gcc -m32 -g -Wall -ansi -c -o encoder.o main.c
.PHONEY: clean
clean:
	rm -f *.o encoder
