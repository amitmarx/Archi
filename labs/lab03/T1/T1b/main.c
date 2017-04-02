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
    FILE *f = fopen("signatures", "r");
    char encoding[2];
    fread(encoding, 1, 2, f);
    bool isBigEndian;
    isBigEndian = (unsigned char)encoding[0] == '\x01';
    virus *v;
    link * virusList = NULL;
    while (1)
    {
        char len[2];
        if (fread(len, 1, 2, f) != 2)
            break;

        unsigned short length;
        if (isBigEndian)
        {
            length = (int)len[0] * 16 + (int)len[1] - 18;
        }
        else
        {
            length = (int)len[1] * 16 + (int)len[0] - 18;
        }
        v = malloc(sizeof(virus) + length * sizeof(char));
        v->length = length;
        fread(v->name, 1, length + 16, f);
        virusList = list_append(virusList,v);
    }
    list_print(virusList);
    list_free(virusList);
    fclose(f);
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
        if(virus_list==NULL){
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
