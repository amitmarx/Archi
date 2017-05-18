#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include "LineParser.h"
#include "JobControl.h"
void printCwd(){
    char cwd[1024];
    if (getcwd(cwd, sizeof(cwd)))
        fprintf(stdout, "%s: ", cwd);
    else
    {
        perror("getcwd() error");
    }
}
cmdLine* readCommand(){
    char userInput[2048];
    fgets(userInput, sizeof(userInput), stdin);
    return parseCmdLines(userInput);
}
void execute(cmdLine* cmd){
    if(strcmp(cmd->arguments[0],"cd")==0){
        if(chdir(cmd->arguments[1])!=0){
            perror("cd failed");
        }
        free(cmd);
        return;
    }

    int pid = fork();
    if(pid==0){
        int result = execvp(cmd->arguments[0], cmd->arguments);
        if (result < 0)
        {
            perror("execv() error");
        }
        free(cmd);
        exit(0);
    }
    else{
        if(cmd->blocking == 0){
            int status;
            waitpid(pid,&status,0);
        }
    }

}

int main(int argc, char **argv){
    job* job_list = NULL;
    for(int i=0; i<100;i++){
        printCwd();
        char cmd[2048];
        fgets(cmd, sizeof(cmd), stdin);
        printf("%s",cmd);
        if(strcmp(cmd,"jobs")==0){
            printf("blblblbllb");
            printJobs(&job_list);
            continue;
        }
        addJob(&job_list, cmd)->status = RUNNING;
    }
}