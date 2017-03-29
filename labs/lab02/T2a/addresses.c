#include <stdio.h>
#include <string.h>
 
char censor(char c) {
  if(c == '!')
    return '.';
  else
    return c;
}
 
char* map(char *array, int array_length, char (*f) (char)){
  char* mapped_array = (char*)(malloc(array_length*sizeof(char)));
  for(int i=0; i<array_length;i++){
      mapped_array[i] = f(array[i]);
  }
  return mapped_array;
}
 
int main(int argc, char **argv){
char arr1[] = {'H','E','Y','!', 0};
char* arr2 = map(arr1, 5, censor);
printf("%s\n", arr2); /* HEY. */
free(arr2);
}