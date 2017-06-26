#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "../elf.h"
#include <sys/mman.h>
#include <unistd.h>


int main(int argc, char **argv) {
    int fd;
    //void *map_start; /* will point to the start of the memory mapped file */
    struct stat fd_stat; /* this is needed to  the size of the file */
    int num_of_section_headers;
    char *map_start;
    char *file = argv[1];
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
    Elf32_Ehdr *header = (Elf32_Ehdr *) map_start;
    Elf32_Phdr *programHeader = (Elf32_Phdr *) (((char *) map_start) + header->e_phoff);
    int i;
    fprintf(stdout, "Type\t\tOffset\t\tVirtAddr\t\tPhysAddr\t\tFileSiz\t\tMemSiz\t\tFlg\t\tAlign\n");
    for (i = 0; i < header->e_phnum; i++) {
        fprintf(stdout, "%d\t\t\t%x\t\t\t%x\t\t\t%x\t\t\t%x\t\t\t%x\t\t\t%d\t\t\t%x\n",
                programHeader->p_type, programHeader->p_offset, programHeader->p_vaddr, programHeader->p_paddr,
                programHeader->p_filesz, programHeader->p_memsz, programHeader->p_flags, programHeader->p_align
        );
        programHeader++;
    }

}