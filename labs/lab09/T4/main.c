#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
typedef struct virus virus;
typedef struct link link;
virus *initVirus(unsigned short length, char *name);
void PrintHex(char *buffer, int length);
void PrintVirus(virus *v);
void list_print(link *virus_list);
link *list_append(link *virus_list, virus *data);
void list_free(link *virus_list);
link *createNewLink(virus *data);
link *readViruses();
void detect_virus(char *buffer, link *virus_list, unsigned int size, bool isFirstOnly);

struct virus
{
    unsigned short length;
    char name[16];
    char signature[];
};

struct link
{
    virus *v;
    link *next;
};

int main(int argc, char **argv)
{
    FILE *f;
    bool isFirstOnly = false;
    int i;
    for(i=1; i<argc; i++){
        if(strcmp(argv[i],"-r")==0)
            f=fopen(argv[++i],"r");
        else if(strcmp(argv[i],"-f")==0)
            isFirstOnly=true;
        else{
            printf("invalid parameter - %s\n",argv[i]);
            return 1;
        }
    }
    link *viruses = readViruses();
    int length = sizeof(char) * 10000;
    char *file = (char *)malloc(length);
    int size;
    size = fread(file, 1, length, f);
    detect_virus(file, viruses, size, isFirstOnly);
}
void detect_virus(char *buffer, link *virus_list, unsigned int size, bool isFirstOnly)
{
    int i;
    for (i = 0; i < size; i++)
    {
        link *currentLink;
        currentLink = virus_list;
        while (currentLink != NULL)
        {
            virus *v = currentLink->v;
            if(v->length + i <size)
            {
                if(memcmp(buffer+i,v->signature, v->length)==0){
                    printf("Starting:%d virus name: %s Virus size: %d\n",i, v->name, v->length);
                    if(isFirstOnly)
                        return;
                        
                } 
            }
            currentLink = currentLink->next;
        }
    }
}

link *readViruses()
{
    FILE *f = fopen("signatures", "r");
    char encoding[1];
    fread(encoding, 1, 1, f);
    bool isBigEndian;
    isBigEndian = (unsigned char)encoding[0] == '\x01';
    virus *v;
    link *virusList = NULL;
    while (1)
    {
        char len[2];
        if (fread(len, 1, 2, f) != 2)
            break;

        unsigned short length;
        if (isBigEndian)
        {
            /*unsupported;*/
            exit(0);
        }
        else
        {
            length = (int)len[1] * 16 + (int)len[0] - 18;
        }
        v = malloc(sizeof(virus) + length * sizeof(char));
        v->length = length;
        fread(v->name, 1, length + 16, f);
        virusList = list_append(virusList, v);
    }
    fclose(f);
    return virusList;
}
void PrintVirus(virus *v)
{
    printf("Virus name: %s\nVirus size: %d\nsignature:\n", v->name, v->length);
    PrintHex(v->signature, v->length);
    printf("\n");
}
virus *initVirus(unsigned short length, char *name)
{
    virus *v = malloc(sizeof(virus) + length * sizeof(char));
    v->length = length;
    int i;
    for (i = 0; i < 16; i++)
    {
        (v->name)[i] = *(name + i);
    }
    return v;
}

void PrintHex(char *buffer, int length)
{
    int i;
    for (i = 0; i < length; i++)
    {
        printf("%02hhX ", (unsigned char)(*(buffer + i)));
        if ((i + 1) % 20 == 0)
        {
            printf("\n");
        }
    }
}

/* Print the data of every link in list. Each item followed by a newline character. */
void list_print(link *virus_list)
{
    if (virus_list != NULL)
    {
        PrintVirus(virus_list->v);
        list_print(virus_list->next);
    }
}
/* Add a new link with the given data to the list 
        (either at the end or the beginning, depending on what your TA tells you),
        and return a pointer to the list (i.e., the first link in the list).
        If the list is null - create a new entry and return a pointer to the entry. */
link *list_append(link *virus_list, virus *data)
{
    bool isAtEnd = true;
    if (isAtEnd)
    {
        if (virus_list == NULL)
        {
            return createNewLink(data);
        }
        if (virus_list->next == NULL)
        {
            virus_list->next = createNewLink(data);
        }
        else
        {
            list_append(virus_list->next, data);
        }
        return virus_list;
    }
    else
    {
        link *newLink = createNewLink(data);
        newLink->next = virus_list;
        return newLink;
    }
}
link *createNewLink(virus *data)
{
    link *newLink = (link *)malloc(sizeof(link));
    newLink->v = data;
    return newLink;
}

/* Free the memory allocated by the list. */
void list_free(link *virus_list)
{
    if (virus_list != NULL)
    {
        list_free(virus_list->next);
        free(virus_list->v);
        free(virus_list);
    }
}
