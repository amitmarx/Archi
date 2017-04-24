all: encoder

encoder: encoder.o
	gcc -m32 -g -Wall -o encoder encoder.o
encoder.o: encoder.c
	gcc -m32 -g -Wall -ansi -c -o encoder.o encoder.c
.PHONEY: clean
clean:
	rm -f *.o encoder
