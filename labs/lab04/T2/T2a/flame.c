#define _GNU_SOURCE
#include <dirent.h> /* Defines DT_* constants */
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/syscall.h>

#define handle_error(msg) \
    do { perror(msg); exit(0x55);} while (0)

struct linux_dirent
{
    long d_ino;
    off_t d_off;
    unsigned short d_reclen;
    char d_name[];
};

#define BUF_SIZE 8192

int main(int argc, char *argv[])
{
    int fd, nread;
    char buf[BUF_SIZE];
    struct linux_dirent *d;
    int bpos;
    char d_type;

    fd = open(argc > 1 ? argv[1] : ".", O_RDONLY | O_DIRECTORY);
    if (fd == -1)
        handle_error("open");
    while (1)
    {
        nread = syscall(SYS_getdents, fd, buf, BUF_SIZE);
        if (nread == -1)
            handle_error("getdents");

        if (nread == 0)
            break;

        for (bpos = 0; bpos < nread;)
        {
            d = (struct linux_dirent *)(buf + bpos);
            d_type = *(buf + bpos + d->d_reclen - 1);
            if (d_type == DT_REG)
            {
                write(2, d->d_name, d->d_reclen - sizeof(struct linux_dirent));
                write(2, "\n", 1);
            }
            bpos += d->d_reclen;
        }
    }
}