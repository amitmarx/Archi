all: app

app: count-words.o
	gcc -m32 -g -Wall -o app count-words.o

count-words.o: count-words.c
	gcc -m32 -g -Wall -ansi -c -o count-words.o count-words.c

clean:
	rm -fr *.o app
