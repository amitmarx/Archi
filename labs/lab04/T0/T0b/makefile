#format is target-name: target dependencies
#{-tab-}actions
CC = gcc
CC_FLAGS = -m32 -g -Wall -ansi 

EXEC = app
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)

# All Targets
all: clean $(EXEC)

$(EXEC): $(OBJECTS)
	$(CC) $(CC_FLAGS) -o $(EXEC) $(OBJECTS)

%.o: %.c
	 $(CC) -c $(CC_FLAGS) -o $@ $< 
 

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o $(EXEC)