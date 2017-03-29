#include <stdio.h>
#include <string.h>
 
struct fun_desc {
  char *name;
  char (*fun)(char);
};

char quit(char c){
  exit(0);
}

char encrypt(char c) /* Gets a char c and returns its encrypted form by adding 3 to its value. 
          If c is not between 0x20 and 0x7E it is returned unchanged */
{
  if(c>=0x20 && c<=0x7E){
    c = c+3;
  }
  return c;
}
char decrypt(char c) /* Gets a char c and returns its decrypted form by reducing 3 to its value. 
            If c is not between 0x20 and 0x7E it is returned unchanged */
 {           
  if(c>=0x20 && c<=0x7E){
    c = c-3;
  }
  return c;
}
char xprt(char c) /* xprt prints the value of c in a hexadecimal representation followed by a 
           new line, and returns c unchanged. */
{
  printf("%X\n",c);
  return c;
}
char cprt(char c) /* If c is a number between 0x20 and 0x7E, cprt prints the character of ASCII value c followed by a new line. 
                    Otherwise, cprt prints the dot ('.') character. After printing, cprt returns the value of c unchanged. */
{
  if(c>=0x20 && c<=0x7E){
    printf("%c\n",c);
  }
  else{
    printf(".",c);
  }
  return c;
}

char my_get(char c) /* Ignores c, reads and returns a character from stdin using fgetc. */
{
  return fgetc(stdin);
}

char censor(char c) {
  if(c == '!')
    return '.';
  else
    return c;
}
 
char* map(char *array, int array_length, char (*f) (char)){
  char* mapped_array = (char*)(malloc(array_length*sizeof(char)));
  int i;
  for(i=0; i<array_length;i++){
      mapped_array[i] = f(array[i]);
  }
  return mapped_array;
}
 
int main(int argc, char **argv){
int base_len = 5;
char* carry =(char*)(malloc(base_len*sizeof(char)));
struct fun_desc funs[] = {
  {.name ="Censor", .fun=censor},
  {.name ="Encrypt", .fun=encrypt},
  {.name ="Decrypt", .fun=decrypt},
  {.name ="Print hex", .fun=xprt},
  {.name ="Print string", .fun=cprt},
  {.name ="Get string", .fun=my_get},
  {.name ="Quit", .fun=quit},  
  {NULL,NULL}
  };
  while(1)
  {
    int i=0;
    while(funs[i].name!=NULL){
      printf("%d) %s\n",i, funs[i].name);
      i++;
    }
    int option;
    printf("Option:");
    scanf ("%d",&option);
    if(option<i&&option>=0){
      printf("Within bounds\n");
      carry = map(carry,base_len,funs[option].fun);
      printf("Done.\n");
    }
    else{
      printf("Not within bounds");
      exit(0);
    }
  }
}
