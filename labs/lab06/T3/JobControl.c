#include "JobControl.h"

/**
* Receive a pointer to a job list and a new command to add to the job list and adds it to it.
* Create a new job list if none exists.
**/
job *addJob(job **job_list, char *cmd) {
    job *job_to_add = initializeJob(cmd);
    if (*job_list == NULL) {
        *job_list = job_to_add;
        job_to_add->idx = 1;
    } else {
        int counter = 2;
        job *list = *job_list;
        while (list->next != NULL) {
            printf("adding %d\n", list->idx);
            list = list->next;
            counter++;
        }
        job_to_add->idx = counter;
        list->next = job_to_add;
    }

    return job_to_add;
}


/**
* Receive a pointer to a job list and a pointer to a job and removes the job from the job list 
* freeing its memory.
**/
void removeJob(job **job_list, job *tmp) {
    if (*job_list == NULL)
        return;
    job *tmp_list = *job_list;
    if (tmp_list == tmp) {
        *job_list = tmp_list->next;
        freeJob(tmp);
        return;
    }

    while (tmp_list->next != tmp) {
        tmp_list = tmp_list->next;
    }
    tmp_list->next = tmp->next;
    freeJob(tmp);

}

/**
* receives a status and prints the string it represents.
**/
char *statusToStr(int status) {
    static char *strs[] = {"Done", "Suspended", "Running"};
    return strs[status + 1];
}


/**
*   Receive a job list, and print it in the following format:<code>[idx] \t status \t\t cmd</code>, where:
    cmd: the full command as typed by the user.
    status: Running, Suspended, Done (for jobs that have completed but are not yet removed from the list).
  
**/
void printJobs(job **job_list) {

    job *tmp = *job_list;
    updateJobList(job_list, FALSE);
    while (tmp != NULL) {
        printf("[%d]\t %s \t\t %s", tmp->idx, statusToStr(tmp->status), tmp->cmd);

        if (tmp->cmd[strlen(tmp->cmd) - 1] != '\n')
            printf("\n");
        job *job_to_remove = tmp;
        tmp = tmp->next;
        if (job_to_remove->status == DONE)
            removeJob(job_list, job_to_remove);

    }

}


/**
* Receive a pointer to a list of jobs, and delete all of its nodes and the memory allocated for each of them.
*/
void freeJobList(job **job_list) {
    job *current_node = *job_list;
    while (current_node != NULL) {
        job *tmp = current_node;
        current_node = current_node->next;
        freeJob(tmp);
    }

}


/**
* receives a pointer to a job, and frees it along with all memory allocated for its fields.
**/
void freeJob(job *job_to_remove) {
    free(job_to_remove->cmd);
    if (job_to_remove->tmodes != 0) {
        free(job_to_remove->tmodes);
    }
    free(job_to_remove);
}


/**
* Receive a command (string) and return a job pointer. 
* The function needs to allocate all required memory for: job, cmd, tmodes
* to copy cmd, and to initialize the rest of the fields to NULL: next, pigd, status 
**/

job *initializeJob(char *cmd) {
    job *newJob = malloc(sizeof(struct job));
    newJob->cmd = cmd;
    newJob->idx = 0;
    newJob->pgid = 0;
    newJob->status = 0;
    newJob->tmodes = malloc(sizeof(struct termios));;
    newJob->next = 0;
    return newJob;
}


/**
* Receive a job list and and index and return a pointer to a job with the given index, according to the idx field.
* Print an error message if no job with such an index exists.
**/
job *findJobByIndex(job *job_list, int idx) {
    while (job_list != NULL) {
        if (job_list->idx == idx)
            return job_list;
        job_list = job_list->next;
    }
    perror("no job was found with this index");
    return NULL;
}


/**
* Receive a pointer to a job list, and a boolean to decide whether to remove done
* jobs from the job list or not. 
**/
void updateJobList(job **job_list, int remove_done_jobs) {
    job *current_node = *job_list;
    while (current_node != NULL) {
        int status;
        int result = waitpid((current_node)->pgid, &status, WNOHANG);
        if (result == -1 || WIFEXITED(status)) {
            (current_node)->status = DONE;
        }
        current_node = (current_node)->next;
    }
}


/** 
* Put job j in the foreground.  If cont is nonzero, restore the saved terminal modes and send the process group a
* SIGCONT signal to wake it up before we block.  Run updateJobList to print DONE jobs.
**/

void runJobInForeground(job **job_list, job *j, int cont, struct termios *shell_tmodes, pid_t shell_pgid) {
    int status;
    int result;
    while ((result = waitpid(j->pgid,&status,WNOHANG))>0);
    if (result == -1) {
        j->status = DONE;
        printf("[%d]\t %s \t\t %s", j->idx, statusToStr(j->status), j->cmd);
        return;
    }

    tcsetpgrp(STDIN_FILENO, j->pgid);
    if (cont == 1 && j->status == SUSPENDED) {
        tcsetattr(STDIN_FILENO, TCSADRAIN, j->tmodes);
    }
    kill(j->pgid, SIGCONT);

    status=-1;

    waitpid(j->pgid, &status, WUNTRACED);
    if (WIFSTOPPED(status)) {
        fprintf(stdout,"got here!!!!!");
        j->status = SUSPENDED;
    } else if(WIFEXITED(status)) {
        j->status = DONE;
    }
    tcsetpgrp(STDIN_FILENO, shell_pgid);
    tcgetattr(STDIN_FILENO, j->tmodes);
    tcsetattr(STDIN_FILENO, TCSADRAIN, shell_tmodes);
    updateJobList(job_list,1);
}


/** 
* Put a job in the background.  If the cont argument is nonzero, send
* the process group a SIGCONT signal to wake it up.  
**/

void runJobInBackground(job *j, int cont) {
    j->status=RUNNING;
    kill(j->pgid, SIGCONT);
}
