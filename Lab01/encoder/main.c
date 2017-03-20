#include <stdio.h>

int main()
{
    int letter = 0;
    
    while(letter != EOF){
       letter = fgetc(stdin);
       if(letter != EOF){
            if ((letter >= 65) && (letter <= 90))
                letter = letter + 32; 
        fputc(letter,stdout);
       }
    }
}