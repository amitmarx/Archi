#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "../elf.h"
#include <sys/mman.h>
#include <unistd.h>

typedef void *(*func)(void);

int debug = 0;
char *menu[];
const void *map_start;

void writeDebug(char *message) {
    if (debug)
        fprintf(stderr, "%s\n", message);
}

void quit() {
    writeDebug("quitting");
    exit(0);
}

void toggleDebug() {
    debug = debug ^ 1;
}

void printSectionInfo();

void printSectionInfo();
void printRelocation(Elf32_Rel * rel, Elf32_Sym *symbol, char* symbolTable);

void examineElfFile() {

    Elf32_Ehdr *header; /* this will point to the header structure */
    /* now, the file is mapped starting at map_start.
     * all we need to do is tell *header to point at the same address:
     */

    header = (Elf32_Ehdr *) map_start;
    /* now we can do whatever we want with header!!!!
     * for example, the number of section header can be obtained like this:
     */

    fprintf(stdout, "Magic Number: %c, %c,%c\n", header->e_ident[1], header->e_ident[2], header->e_ident[3]);
    fprintf(stdout, "Data Encoding:\n");
    fprintf(stdout, "Etry Point: %x\n", header->e_entry);
    fprintf(stdout, "Section header offset: %d\n", header->e_shoff);
    fprintf(stdout, "Number of section header: %x\n", header->e_shnum);
    fprintf(stdout, "Sections Size: \n");
    Elf32_Shdr *sectionHeader = (Elf32_Shdr *) (((char *) map_start) + header->e_shoff);
    for (int i = 0; i < header->e_shnum; ++i) {
        printf("%2d: %d Bytes \n", i, sectionHeader[i].sh_size);
    }
    fprintf(stdout, "Program header offset: %d\n", header->e_phoff);
    int phnum = header->e_phnum;
    fprintf(stdout, "Number of section header: %x\n", phnum);
    fprintf(stdout, "Programs Size:\n");
    Elf32_Phdr *programHeader = (Elf32_Phdr *) (((char *) map_start) + header->e_phoff);
    for (int i = 0; i < phnum; ++i) {
        printf("%2d: %d Bytes \n", i, programHeader[i].p_filesz);
    }


    /* now, we unmap the file */
    //munmap(map_start, fd_stat.st_size);
}

void printSectionInfo() {
    const Elf32_Ehdr *header = (Elf32_Ehdr *) map_start;
    Elf32_Shdr *sectionHeader = (Elf32_Shdr *) (((char *) map_start) + header->e_shoff);
    int shnum = header->e_shnum;

    Elf32_Shdr *sh_strtab = &sectionHeader[header->e_shstrndx];
    const char *const sh_strtab_p = ((char *) map_start) + sh_strtab->sh_offset;

    for (int i = 0; i < shnum; ++i) {
        printf("%2d: name:%s address:%x offset:%d size:%d type:%x\n",
               i, (sh_strtab_p + sectionHeader[i].sh_name), sectionHeader[i].sh_offset,
               sectionHeader[i].sh_size, sectionHeader[i].sh_type
        );
    }
}

void printSymbols() {
    char *sectionStringTable;
    Elf32_Ehdr *header; /* this will point to the header structure */


    header = (Elf32_Ehdr *) map_start;
    Elf32_Shdr *sections = (Elf32_Shdr *) (map_start + header->e_shoff);
    Elf32_Sym *symbols;
    int symbols_length;
    char *symbolStringTable;

    int i = 0;
    for (i = 0; i < header->e_shnum; i++) {
        if (sections[i].sh_type == SHT_DYNSYM) { //find symbol table entry in sections
            symbols = (Elf32_Sym *) ((char *) map_start + sections[i].sh_offset);
            symbols_length = sections[i].sh_size / sections[i].sh_entsize;
        }
        if (sections[i].sh_type == SHT_DYNSYM) { // find symbol table string table
            symbolStringTable = (char *) map_start + sections[sections[i].sh_link].sh_offset;
        }
    }

    sectionStringTable = (((char *) map_start) + sections[header->e_shstrndx].sh_offset);

    for (i = 0; i < symbols_length; i++) {

        if (symbols[i].st_shndx == 65521) {
            printf("[%d] Value: %08x Section_index: %s      Section_name: %s         Symbol_name: %s\n",
                   i, symbols[i].st_value, "ABS", "", symbolStringTable + symbols[i].st_name);
        } else if (symbols[i].st_shndx == 0) {
            int sectionIndex = symbols[i].st_shndx;
            printf("[%d] Value: %08x Section_index: %s      Section_name: %s         Symbol_name: %s\n",
                   i, symbols[i].st_value, "UND", sectionStringTable + symbols[i].st_shndx,
                   sectionStringTable + sections[sectionIndex].sh_name,
                   symbolStringTable + symbols[i].st_name);

        } else {
            int sectionIndex = symbols[i].st_shndx;
            printf("[%d] Value: %08x Section_index: %d      Section_name: %s         Symbol_name: %s\n",
                   i, symbols[i].st_value, sectionIndex, sectionStringTable + sections[sectionIndex].sh_name,
                   symbolStringTable + symbols[i].st_name);
        }
    }

}
void relocationTableInfo(){
    Elf32_Ehdr *header; /* this will point to the header structure */
    header = (Elf32_Ehdr *) map_start;
    Elf32_Shdr *sections = (Elf32_Shdr *) (map_start + header->e_shoff);
    Elf32_Sym *symbols;
    int symbolsLength;
    int index =0;
    Elf32_Rela* rela;
    Elf32_Rel* rel;



    char *sectionStringTable;

    int symbols_length;
    char *symbolStringTable;

    int i = 0;
    for (i = 0; i < header->e_shnum; i++) {
        if (sections[i].sh_type == SHT_DYNSYM) { //find symbol table entry in sections
            symbols = (Elf32_Sym *) ((char *) map_start + sections[i].sh_offset);
            symbols_length = sections[i].sh_size / sections[i].sh_entsize;
        }
        if (sections[i].sh_type == SHT_DYNSYM) { // find symbol table string table
            symbolStringTable = (char *) map_start + sections[sections[i].sh_link].sh_offset;
        }
    }

    for (i = 0; i < header->e_shnum; i++) {
        if (sections[i].sh_type == SHT_REL) { // find relocation table
            rel =(Elf32_Rel*) (((char*)map_start )+ sections[i].sh_offset);
            int size = sections[i].sh_size / sections[i].sh_entsize;
            int j;
            for(j=0;j<size;j++){
                int symbolTableIndex = ELF32_R_SYM(rel->r_info);
                printRelocation(rel, &symbols[symbolTableIndex], symbolStringTable);
                rel++;
            }
        }
        if (sections[i].sh_type == SHT_RELA) { // find relocation table
            rela=(Elf32_Rela*) map_start + sections[i].sh_offset;
            int symbolTableIndex = ELF32_R_SYM(rela->r_info);
            printRelocation(rela,&symbols[symbolTableIndex],symbolStringTable);
        }
    }
//    char * sectionStringTable = (((char *) map_start) + sections[header->e_shstrndx].sh_offset);
//    for(i=0; i<index ; i++){
//    }
}

void printRelocation(Elf32_Rel * rel, Elf32_Sym *symbol, char* symbolTable){
    fprintf(stdout, "offset: %x  info %x  Type: %d  Sym.Value: %x  Sym. Name: %s\n",
    rel->r_offset, rel->r_info, ELF32_R_TYPE(rel->r_info),symbol->st_value, symbolTable+symbol->st_name);
}


void linkCheck(){
    Elf32_Ehdr *header; /* this will point to the header structure */
    header = (Elf32_Ehdr *) map_start;
    Elf32_Shdr *sections = (Elf32_Shdr *) (map_start + header->e_shoff);
    Elf32_Sym *symbols;
    int symbolsLength;
    char *symbolStringTable;
    Elf32_Rel *relocationTable;

    int i = 0;
    for (i = 0; i < header->e_shnum; i++) {
        if (sections[i].sh_type == SHT_SYMTAB) { //find symbol table entry in sections
            symbols = (Elf32_Sym *) ((char *) map_start + sections[i].sh_offset);
            symbolsLength = sections[i].sh_size / sections[i].sh_entsize;
        }
        if (sections[i].sh_type == SHT_SYMTAB) { // find symbol table string table
            symbolStringTable = (char *) map_start + sections[sections[i].sh_link].sh_offset;
        }
        if (sections[i].sh_type == SHT_REL) { // find relocation table
            relocationTable = (Elf32_Rel *) map_start + sections[sections[i].sh_link].sh_offset;
        }
    }

    for(i=0; i<symbolsLength ; i++){
        if(strcmp(symbolStringTable+symbols[i].st_name,"_start")==0) break;
    }
    fprintf(stdout,"_start check: %s\n", i<symbolsLength? "PASSED" : "FAILED");
    if(i>=symbolsLength) return;

    fprintf(stdout,"relocation check: %s\n", relocationTable!=0? "PASSED" : "FAILED");
    if(relocationTable==0) return;

}

int getMenuSelection() {
    int i = 0;
    fprintf(stdout, "Choose action:\n");
    while (menu[i] != NULL) {
        fprintf(stdout, "%d-%s\n", i, menu[i]);
        i++;
    }

    int result;
    char reader[100];
    fgets(reader, sizeof(reader), stdin);
    reader[strlen(reader) - 1] = 0;
    sscanf(reader, "%d", &result);
    return result;
}

char *menu[] = {"Toggle Debug Mode", "Examine ELF File", "Print Section Names", "Print Symbols",
                "Link check","Relocation Tables - Raw",
                "Quit", NULL};

func funcs[] = {&toggleDebug, &examineElfFile, &printSectionInfo, &printSymbols,&linkCheck, &relocationTableInfo,
                &quit};

int main(int argc, char **argv) {
    int fd;
    //void *map_start; /* will point to the start of the memory mapped file */
    struct stat fd_stat; /* this is needed to  the size of the file */
    int num_of_section_headers;

    char *file = "/Users/amitm/dev/archi/labs/lab08/a.out";
    if ((fd = open(file, O_RDWR)) < 0) {
        perror("error in open");
        exit(-1);
    }

    if (fstat(fd, &fd_stat) != 0) {
        perror("stat failed");
        exit(-1);
    }

    if ((map_start = mmap(0, fd_stat.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)) == MAP_FAILED) {
        perror("mmap failed");
        exit(-4);
    }
    while (1) {
        int menuSelection = getMenuSelection();
        (*(funcs[menuSelection]))();
    }
}

