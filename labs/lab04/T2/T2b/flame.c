#define _GNU_SOURCE
#include <dirent.h> /* Defines DT_* constants */
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/syscall.h>

#define handle_error(msg) \
    do { system_call(1,0x55,0,0);} while (0)

struct linux_dirent
{
    unsigned d_ino;
    unsigned d_off;
    unsigned short d_reclen;
    char d_name[];
};

#define BUF_SIZE 8192
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

void writeFile(struct linux_dirent * row, char *suffix, char type)
{
    if (type == DT_REG)
    {
        int nameLen = row->d_reclen - 2 - 2*sizeof(unsigned long) -sizeof(unsigned short);
        int lastCharPos = row->d_reclen - sizeof(struct linux_dirent)-3;
        if (suffix ==0 || suffix[0] == row->d_name[nameLen-1])
        {
            system_call(4,2, row->d_name, row->d_reclen - sizeof(struct linux_dirent));
            system_call(4,2, "\n", 1);
        }
    }
}
int main(int argc, char *argv[])
{
    int fd, nread;
    char buf[BUF_SIZE];
    struct linux_dirent *d;
    int bpos;
    char *suffix = 0;
    char * dir = 0;
    int i=0;
    for (i = 0; i < argc; i++)
    {
        if (compareString(argv[i], "-s") == 0)
        {
            suffix = argv[i+1];
        }
        else if (compareString(argv[i], "-i") == 0)
        {
            dir = argv[i+1];
        }
    }
    fd = system_call(5, dir == 0 ? "." : dir, O_RDONLY | O_DIRECTORY);
    if (fd == -1)
        handle_error("open");
    while (1)
    {
        nread = system_call(141, fd, buf, BUF_SIZE);
        if (nread == -1)
            handle_error("getdents");

        if (nread == 0)
            break;

        for (bpos = 0; bpos < nread;)
        {
            d = (struct linux_dirent *)(buf + bpos);
            char d_type;
            d_type = *(buf + bpos + d->d_reclen - 1);
            /*writeFile(d, suffix, d_type);*/
            char* loc = buf + bpos + d->d_reclen - 2 - 2*sizeof(unsigned long) -sizeof(unsigned short);
            if (suffix == 0 || suffix[0] == *(loc))
            {
                system_call(4, 2, d->d_name, d->d_reclen - sizeof(struct linux_dirent));
                system_call(4, 2, "\n", 1);
            }
            bpos += d->d_reclen;
        }
    }
}