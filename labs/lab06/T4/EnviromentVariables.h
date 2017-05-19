//
// Created by Amit Marx on 19/05/2017.
//


#include "LineParser.h"

typedef struct EnvVar
{
    char *name;
    char *value;
    struct EnvVar *next;	/* next job in chain */
} EnvVar;



void addEnvVar(struct EnvVar** list, char* name,char* value);
void putEnvVarInCmd( cmdLine *cmd,EnvVar** var_list );
void *replace_str(char **str, char *orig, char *rep);
struct EnvVar* createNode(char* name, char* value);

