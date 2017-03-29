#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main (int argc, char** argv){

int iarray[] = {1,2,3};
char carray[] = {'a','b','c'};
int* iarrayPtr;
char* carrayPtr;
iarrayPtr = iarray;
printf("iarrayPtr - %p\n",iarrayPtr);
printf("iarray - %p\n",iarray);
carrayPtr = carray;
for(int i=0; i<3; i++){
    printf("iarray[%d] = %d, carray[%d] = %c\n",i, *(iarrayPtr+i), i, *(carrayPtr+i));
}
int* p;
for(i=0; i<3; i++){
    printf("iarray[%d] = %p, carray[%d] = %p\n",i, (iarrayPtr+i), i, (carrayPtr+i));
}
printf("p - %p\n",p);

}


