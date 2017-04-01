#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct virus virus;
void initVirus(virus* v, unsigned short length, char* name, char* sig);
void PrintHex(char *buffer, int length);
void PrintVirus(virus * v);
struct virus
{
    unsigned short length;
    char name[16];
    char * signature;
};

int main(int argc, char **argv)
{
    FILE *f = fopen("signatures", "r");
    virus* viruses=(virus *)malloc(100);
    char encoding[2];
    fread(encoding, 1, 2, f);
    bool isBigEndian;
    isBigEndian = encoding[0] == '1';
    int index=0;
    while (1)
    {
        char len[2];
        if (fread(len, 1, 2, f) != 2)
            break;
        
        unsigned short length = (int)len[0] * 16 + (int)len[1] - 18;;
        char name [16];
        
        fread(name, 1, 16, f);
        
        char * signature = ( char *)malloc(length);
        fread(signature, 1, length, f);

        initVirus(&viruses[index],length,name,signature);
        index++;
    }
    virus * virusesPtr = viruses;
    for(int i=0; i< index; i++){
        PrintVirus(virusesPtr+i);
        printf("\n");
    }
}
void PrintVirus(virus * v){
    printf("Virus name: %s\nVirus size: %d\nsignature:\n",v->name,v->length);
    PrintHex(v->signature,v->length);
}
void initVirus(virus * v, unsigned short length, char* name, char* sig){
    v->length = length;
    int i;
    for(i=0;i<16;i++){
        (v->name)[i] = *(name+i);
    }
    v->signature = sig;
}

void PrintHex(char *buffer, int length)
{
    int i;
    for (i = 0; i < length; i++){
        unsigned char * tmp = (unsigned char *) (buffer+i);
        printf("%x ", *tmp);
        if ((i+1) % 20 == 0){
            printf("\n");
        }
    }
}
