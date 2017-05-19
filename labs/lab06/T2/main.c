#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    int fd[2];
    pid_t childpid, childpid2;
    pipe(fd);

    if ((childpid = fork()) == -1) {
        perror("fork");
        exit(1);
    }

    if (childpid == 0) {
        close(STDOUT_FILENO);
        int duplicate = dup(fd[1]);
        close(fd[1]);
        char * args[] = {"/bin/ls", "-l", NULL};
        int result = execvp(args[0], args);
        if (result < 0)
        {
            perror("execv() error");
        }
        exit(0);
    } else {
        /* Parent process closes up output side of pipe */
        close(fd[1]);
        childpid2 = fork();

        if (childpid2 == 0) {
            close(STDIN_FILENO);
            int duplicate = dup(fd[0]);
            close(fd[0]);
            char *args[] = {"tail", "-n","2", NULL};
            execvp("tail", args);
            exit(0);
        }
        close(fd[0]);
    }
    int status;
    waitpid(childpid, &status, WUNTRACED);
    waitpid(childpid2, &status, WUNTRACED);
    return (0);
}