#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include "LineParser.h"
#include "JobControl.h"

char * process;
void sig_handler(int signo)
{
    if (signo == SIGQUIT)
        printf("%s: received and ignored SIGQUIT\n",process);
    else if (signo == SIGCHLD)
        printf("%s: received and ignored SIGCHLD\n",process);
    else if (signo == SIGTSTP)
        printf("%s: received and ignored SIGTSTP\n", process);
    else
        printf("%s: unknown signal\n",process);
}
void registerOwnSignals(){
    process = "shell";
    signal(SIGTTIN,SIG_IGN);
    signal(SIGTTOU,SIG_IGN);
    signal(SIGTSTP,sig_handler);
    signal(SIGQUIT,sig_handler);
    signal(SIGCHLD,sig_handler);
}
void registerDefaultSignals(){
    process = "child";
    signal(SIGTTIN,SIG_DFL);
    signal(SIGTTOU,SIG_DFL);
    signal(SIGTSTP,SIG_DFL);
    signal(SIGQUIT,SIG_DFL);
    signal(SIGCHLD,SIG_DFL);
}

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
int execute(cmdLine* cmd,job** job_list){
    if(strcmp(cmd->arguments[0],"cd")==0){
        if(chdir(cmd->arguments[1])!=0){
            perror("cd failed");
        }
        free(cmd);
        return 0;
    }
    else if(strcmp(cmd->arguments[0],"jobs")==0){
        printJobs(job_list);
        return 0;
    }
    else if(strcmp(cmd->arguments[0],"fg")==0){
        struct termios* shell_tmodes = malloc(sizeof(struct termios));
        tcgetattr(STDIN_FILENO,shell_tmodes);
        job* jobToHandle = findJobByIndex((*job_list),atoi(cmd->arguments[1]));
        runJobInForeground(job_list,jobToHandle,1,shell_tmodes,getpid());
        return 0;
    }
    else if(strcmp(cmd->arguments[0],"bg")==0){
        struct termios* shell_tmodes = malloc(sizeof(struct termios));
        tcgetattr(STDIN_FILENO,shell_tmodes);
        job* jobToHandle = findJobByIndex((*job_list),atoi(cmd->arguments[1]));
        runJobInBackground(jobToHandle,1);
        return 0;
    }
    else if(strcmp(cmd->arguments[0],"quit")==0){
        return 1;
    }

    int pid = fork();
    //chile process
    if(pid==0){
        registerDefaultSignals();
        int result = execvp(cmd->arguments[0], cmd->arguments);
        if (result < 0)
        {
            perror("execv() error");
        }
        free(cmd);
        exit(0);
    }
    else{
        setpgid(pid,pid);

        job* childCommand = addJob(job_list, cmd->arguments[0]);

        childCommand->status = RUNNING;
        childCommand->pgid = pid;
        if(cmd->blocking == 1){
            struct termios* shell_tmodes = malloc(sizeof(struct termios));
            tcgetattr(STDIN_FILENO,shell_tmodes);
            runJobInForeground(job_list,childCommand,0,shell_tmodes,getpid());
        }
    }
    return 0;
    
}



int main(int argc, char **argv){
    //set the shell group id
    setpgid(getpid(),getpid());
    registerOwnSignals();
    job** job_list = malloc(sizeof(job*));;
    *job_list = NULL;
    int shouldExit = 0;
    while(shouldExit==0){
        printCwd();
        cmdLine *cmd = readCommand();
        shouldExit=execute(cmd,job_list);
    }
    freeJobList(job_list);
}