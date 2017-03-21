#include <stdio.h>
int getOffset(int argc, char **argv){
    int offset = 0;
    char* enc = NULL;
    int j;
    for(j=0;j<argc;j++){
        if((strcmp(argv[j],"-i")!=0 && argv[j][0]=='-')||argv[j][0]=='+')
            enc = argv[j];
    }
    if(enc!=NULL){
        int i=1;
            while(enc[i]!='\0'){
               offset*=10;
               offset+=enc[i]-'0';
               i++;
            }
            if(enc[0]=='-'){
                offset*=-1;
            }
        }
    return offset;
}

FILE* getStream(int argc, char **argv){
    int i;
    char* path = NULL; 
    for(i=0;i<argc;i++){
        if(strcmp(argv[i],"-i")==0)
            path = argv[i+1];
    }
    FILE* stream;
    if(path!=NULL)
        stream = fopen(path,"r");
    else
        stream = stdin;
    return stream;
}

int main(int argc, char **argv)
{
    FILE* stream =NULL;
    stream = getStream(argc,argv);
    int letter = 0;
    int offset = getOffset(argc,argv);
    while(letter != EOF){
       letter = fgetc(stream);
       if(letter != EOF){
            if ((letter >= 65) && (letter <= 90))
                letter = letter + 32;
            if(letter >= 97 && letter<= 122){
                letter+=offset;
                if(letter<97)
                    letter= 123 - (97-letter);
                if(letter>122)
                    letter = 97 + (123-letter);
            }
        fputc(letter,stdout);
       }
    }
}