#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int iarray[3];
char carray[3];

int main (int argc, char** argv){

    printf("&iarray: %p\n",iarray);
    printf("&iarray+1: %p\n",iarray+1);

    printf("&carray: %p\n",carray);
    printf("&carray+1: %p\n",carray+1);
    return 0;
}


