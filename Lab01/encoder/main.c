#include <stdio.h>

int main(int argc, char **argv)
{
    int letter = 0;
    int offset = getOffset(argc,argv);
    while(letter != EOF){
       letter = fgetc(stdin);
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
int getOffset(int argc, char **argv){
    int offset = 0;
    if(argc==2){
    char* enc = argv[1]; 
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
