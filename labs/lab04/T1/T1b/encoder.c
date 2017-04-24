#include <fcntl.h>
#include <sys/types.h>
char flipChar(char x)
{
    if (x >= 'a' && x <= 'z')
    {
        x -= 32;
    }
    else if (x >= 'A' && x <= 'Z')
    {
        x += 32;
    }
    return x;
}

char encodeCharWithOffset(char letter, int offset)
{
    if (letter >= 'a' && letter <= 'z')
    {
        letter += offset;
        if (letter < 'a')
            letter = 'z' - ('a' - letter) + 1;
        if (letter > 'z')
            letter = 'a' + ('z' - letter) + 1;
    }
    else if (letter >= 'A' && letter <= 'Z')
    {
        letter += offset;
        if (letter < 'A')
            letter = 'Z' - ('A' - letter) + 1;
        if (letter > 'Z')
            letter = 'A' + ('Z' - letter) + 1;
    }
    return letter;
}
int compareString(char *first, char *second)
{
    while (*first != 0 && *second != 0)
    {
        if (*first != *second)
            return -1;
        second++;
        first++;
    }
    if (*first == *second)
        return 0;
    else
        return -1;
}

int filter(char letter, char *filters)
{
    while (*filters != 0)
    {
        if (letter == (char)(*filters))
            return -1;
        filters += 1;
    }
    return 0;
}
void writeDebug(char *input, int shouldWrite)
{
    if (shouldWrite < 0)
    {
        return;
    }
    while (*input != 0)
    {
        write(2, input, 1);
        input++;
    }
}

int main(int argc, char **argv)
{
    int inputStream = 0;
    int outStream = 1;
    char *inFileName = 0;
    char *outFileName = 0;
    int shouldDebug = -1;
    int offset = 0;
    char filters[] = {'h', 'H'};
    int i;
    for (i = 0; i < argc; i++)
    {
        if (compareString(argv[i], "-d") == 0)
        {
            shouldDebug = 0;
        }
        else if (compareString(argv[i], "-i") == 0)
        {
            inFileName = argv[i + 1];
            inputStream = open(inFileName, O_RDWR, 0777);
        }
        else if (compareString(argv[i], "-o") == 0)
        {
            outFileName = argv[i + 1];
            outStream = open(outFileName, O_RDWR | O_CREAT, 0777);
        }
        else if (argv[i][0] == '-' || argv[i][0] == '+')
        {
            offset = argv[i][1] - '0';
            if (argv[i][0] == '-')
            {
                offset *= -1;
            }
        }
    }
    writeDebug("Commandline Args:\n", shouldDebug);
    writeDebug(argv[1], shouldDebug);
    writeDebug("\nfilters:\n", shouldDebug);
    writeDebug(filters, shouldDebug);
    writeDebug("\nread content from: ", shouldDebug);
    if (inFileName == 0){
        writeDebug("stdin", shouldDebug);
    }
    else{
        writeDebug(inFileName, shouldDebug);
    }
    writeDebug("\nwrite content to: ", shouldDebug);
    if (outFileName == 0){
        writeDebug("stdout", shouldDebug);
    }
    else
    {
        writeDebug(outFileName, shouldDebug);
    }
    writeDebug("\n", shouldDebug);
    int wasFiltered = -1;
    int data = 1;
    while (data == 1)
    {
        char *letter = (char *)malloc(1);
        data = read(inputStream, letter, 1);
        if (data == 1)
        {
            if (filter(*letter, filters) == 0)
            {
                *letter = flipChar(*letter);
                *letter = encodeCharWithOffset(*letter, offset);
                write(outStream, letter, 1);
            }
            else
            {
                wasFiltered = 1;
            }
            if (*letter == '\n')
            {
                if (wasFiltered > 0)
                {
                    writeDebug("-was filtered.\n", shouldDebug);
                }
                wasFiltered = -1;
            }
        }
        free(letter);
    }
    writeDebug("was exit propaly", shouldDebug);
    close(outStream);
    close(inputStream);
    return 0;
}
