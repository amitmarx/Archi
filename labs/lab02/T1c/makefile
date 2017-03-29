all: app

app: addresses.o
	gcc -m32 -g -Wall -o app addresses.o

addresses.o: addresses.c
	gcc -m32 -g -Wall -ansi -c -o addresses.o addresses.c

clean:
	rm -fr *.o app
