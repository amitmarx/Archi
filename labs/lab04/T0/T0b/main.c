#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
void overrideName(char *newFile, char *newName);
int isNameMatch(char *stream, char *name);
int main(int argc, char **argv)
{
    char * filename = "greeting";
    int f;
    f = open(filename, O_RDWR, 0777);
    int size = lseek(f, 0L, SEEK_END);
    char *buff = (char *)malloc(size);
    close(f);
    f = open(filename, O_RDWR, 0777);
    read(f, buff, size);
    close(f);
    char nameToReplace[] = "Shira";
    char *newName = argv[1];
    int newSize = size + strlen(newName) - strlen(nameToReplace);
    char *newFile = (char *)malloc(newSize);
    int i, j;
    for (i = 0, j = 0; i < size; i++, j++)
    {
        if (isNameMatch(buff + i, nameToReplace) == 1)
        {
            overrideName(newFile + j, newName);
            i += strlen(nameToReplace);
            j += strlen(newName);
        }
        else
        {
            newFile[j] = buff[i];
        }
    }
    f = open(filename, O_RDWR, 0777);
    write(f, newFile, newSize);
    close(f);
    free(newFile);
    free(buff);

}
void overrideName(char *newFile, char *newName)
{
    int i;
    for (i = 0; i < strlen(newName); i++)
    {
        newFile[i] = newName[i];
    }
}
int isNameMatch(char *stream, char *name)
{
    int i;
    int length = strlen(name);
    for (i = 0; i < length; i++)
    {
        if (*(name + i) != *(stream + i))
        {
            return 0;
        }
    }
    return 1;
}
