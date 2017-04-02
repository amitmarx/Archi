#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct virus virus;
virus * initVirus(unsigned short length, char* name);
void PrintHex(char *buffer, int length);
void PrintVirus(virus * v);
struct virus
{
    unsigned short length;
    char name[16];
    char signature[];
};

int main(int argc, char **argv)
{
    FILE *f = fopen("signatures", "r");
    char encoding[2];
    fread(encoding, 1, 2, f);
    bool isBigEndian;
    isBigEndian = encoding[0] == '1';
    int index=0;
    virus * v;
    while (1)
    {
        char len[2];
        if (fread(len, 1, 2, f) != 2)
            break;
        
        unsigned short length = (int)len[0] * 16 + (int)len[1] - 18;;
        v= malloc(sizeof(virus)+length*sizeof(char));
        v->length = length;
        fread(v->name, 1, length + 16, f);
        PrintVirus(v);
        free(v);
        index++;
    }
    fclose(f);
}
void PrintVirus(virus * v){
    printf("Virus name: %s\nVirus size: %d\nsignature:\n",v->name,v->length);
    PrintHex(v->signature,v->length);
}
virus * initVirus(unsigned short length, char* name){
    virus * v= malloc(sizeof(virus)+length*sizeof(char));
    v->length = length;
    int i;
    for(i=0;i<16;i++){
        (v->name)[i] = *(name+i);
    }
    return v;
}

void PrintHex(char * buffer, int length)
{
    int i;
    for (i = 0; i < length; i++){
        printf("%02hhX ", (unsigned char)(*(buffer+i)));
        if ((i+1) % 20 == 0){
            printf("\n");
        }
    }
}
