//
// Created by Amit Marx on 19/05/2017.
//

#include <MacTypes.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "EnviromentVariables.h"

void addEnvVar(struct EnvVar **list, char *name, char *value) {
    if (*list == NULL) {
        *list = createNode(name, value);
    } else {
        EnvVar *current = *list;
        while (true) {
            if (strcmp(current->name, name) == 0) {
                free(current->value);
                current->value = value;
                return;
            }
            if (current->next == NULL) {
                break;
            }
            current = current->next;
        }
        current->next = createNode(name, value);
    }
}

struct EnvVar *createNode(char *name, char *value) {
    struct EnvVar *newNode = malloc(sizeof(struct EnvVar));
    newNode->name = name;
    newNode->value = value;
    newNode->next = NULL;
    return newNode;
}

void printEnvList(EnvVar **var_list) {
    if (*var_list == NULL) {
        return;
    } else {
        EnvVar *current = *var_list;
        while (current != NULL) {
            printf("key:%s    value:%s\n", current->name, current->value);
            current = current->next;
        }
    }
}

void putEnvVarInCmd(cmdLine *cmd, EnvVar **var_list) {
    if (*var_list == NULL) {
        return;
    }
    EnvVar *current = *var_list;
    while (current != NULL) {
        for (int i = 0; i < cmd->argCount; i++) {
            char *varName = malloc(1 + sizeof(current->name));
            varName[0] = '$';
            strcpy(varName + 1, current->name);
            replace_str(&cmd->arguments[i], varName, current->value);
        }
        current = current->next;
    }
    int areThereDollars =-1;
    for (int i = 0; i < cmd->argCount; i++) {
        const char *ptr = strchr(cmd->arguments[i], '$');
        if (ptr) {
            areThereDollars=1;
            break;
        }
    }
    if(areThereDollars==1){
        perror("couldn't find environment variable for that command.");
    }

    if(cmd->next!=NULL)
        putEnvVarInCmd(cmd->next,var_list);
}

void *replace_str(char **pStr, char *orig, char *rep) {
    char *str = *pStr;
    char *p;
    if (!(p = strstr(str, orig)))  // Is 'orig' even in 'str'?
        return str;

    char *buffer = malloc(sizeof(str) - strlen(orig) + strlen(rep));
    strncpy(buffer, str, p - str); // Copy characters from 'str' start to 'orig' st$
    buffer[p - str] = '\0';

    sprintf(buffer + (p - str), "%s%s", rep, p + strlen(orig));
    free(str);
    *pStr = buffer;
}

