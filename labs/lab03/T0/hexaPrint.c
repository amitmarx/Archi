#include <stdio.h>
#include <stdlib.h>
void PrintHex(char* buffer, int length);
int main(int argc, char **argv) {
    int i;
    for(i=0;i<argc; i++){
        FILE * f;
        f = fopen(argv[i],"rb");
        char string[4];
        int j;
        j=0;
        while(fread(string, sizeof(char), 4, f)==4&& j<10){
            PrintHex(string,4);
            j++;
        }
        fclose(f);
    }
    return 0;
}
void PrintHex(char* buffer, int length){
    int i;
    for(i=0; i<length;i++){
        printf("%x",*(buffer+i));
    }
    printf("\n");
}
