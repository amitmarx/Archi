#include <stdio.h>
int getOffset(int argc, char **argv){
    int offset = 0;
    char* enc = NULL;
    int j;
    for(j=0;j<argc;j++){
        if((strcmp(argv[j],"-o")!=0 && strcmp(argv[j],"-i")!=0 && argv[j][0]=='-')||argv[j][0]=='+')
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

FILE* getInputStream(int argc, char **argv){
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

FILE* getOutputStream(int argc, char **argv){
    int i;
    char* path = NULL; 
    for(i=0;i<argc;i++){
        if(strcmp(argv[i],"-o")==0)
            path = argv[i+1];
    }
    FILE* stream;
    if(path!=NULL)
        stream = fopen(path,"w+");
    else
        stream = stdout;
    return stream;
}

int main(int argc, char **argv)
{
    FILE* inputStream =NULL;
    inputStream = getInputStream(argc,argv);
    if(inputStream==NULL){
        fputs("Could not read input file.",stderr);
        return -1;
    }
    FILE* outStream =NULL;
    outStream = getOutputStream(argc,argv);
    if(outStream==NULL){
        fputs("Could not open output file.",stderr);
        fclose(inputStream);
        return -1;
    }
    
    int letter = 0;
    int offset = getOffset(argc,argv);
    while(letter != EOF){
       letter = fgetc(inputStream);
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
        fputc(letter,outStream);
       }
    }
    fclose(outStream);
    fclose(inputStream);
    return 0;
}