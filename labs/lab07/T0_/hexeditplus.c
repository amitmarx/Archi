
#include <stdio.h>
#include <stdlib.h>

//
// Created by Amit Marx on 08/06/2017.
//
int debug = 0;
int unitSize=1;
char fileName[100];
void writeDebug(char *message);
void writeIntDebug(int message);
char* menu[]= {"Toggle Debug Mode","Set File Name","Set Unit Size","Quit",NULL};

int getMenuSelection() {
    int i=0;
    fprintf(stdout,"Choose action:\n");
    while(menu[i]!=NULL){
        fprintf(stdout, "%d-%s\n",i,menu[i]);
        i++;
    }

    int result;
    fscanf(stdin, "%d\n", &result);
    return result;
}
void writeDebug(char *message){
    if(debug)
    fprintf(stderr,"%s\n", message);
}
void writeIntDebug(int message){
    if(debug)
        fprintf(stderr,"%d\n", message);
}
int main(int argc, char **argv) {
    while (1) {
        int menuSelection = getMenuSelection();
        switch (menuSelection) {
            case 0:
                debug = debug ^ 1;
                break;
            case 1:
                fscanf(stdin, "%s", &fileName);
                writeDebug("Set Name:");
                writeDebug(fileName);
                break;
            case 2:
                while(scanf("%d", &unitSize) <=0 || (unitSize!=1&&unitSize!=2&&unitSize!=4));
                writeDebug("Debug: set size to");
                writeIntDebug(unitSize);
                break;
            case 3:
                writeDebug("quitting");
                exit(0);
        }
    }
}