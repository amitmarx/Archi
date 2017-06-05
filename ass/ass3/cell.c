#include <stdio.h>


extern int WorldWidth; 
extern int WorldLength;
extern char STATE[];
char cell(int x, int y);
int getSingleIndex(int x, int y);
void findNeighbors(int x, int y, int *result);

char cell(int x, int y) {
    int neighbors[8];
    findNeighbors(x, y, neighbors);
    int liveNeighbors = 0;
    int i;
    for (i = 0; i < 8; i++) {
        if (STATE[neighbors[i]] > '0') {
            liveNeighbors++;
        }
    }
    char currentState = STATE[getSingleIndex(x, y)];
    if (currentState > '0') {
        if (liveNeighbors == 3 || liveNeighbors == 2) {
            currentState = currentState < '9' ? currentState + 1 : currentState;
        } else{
            currentState = '0';
        }
    } else {
        if (liveNeighbors == 3) {
            currentState = '1';
        }
    }
    return currentState;
}

int getSingleIndex(int x, int y) {
    return y * WorldWidth + x;
}

void findNeighbors(int x, int y, int *result) {
    int index = 0;
    int j,i;
    for (j = y - 1; j < y + 2; j++) {
        for (i = x - 1; i < x + 2; i++) {
            if (j != y || i != x) {
                int roundI = i % WorldWidth;
                int roundJ = j %  WorldLength;
                if (roundI < 0) {
                    roundI += WorldWidth;
                }
                if (roundJ < 0) {
                    roundJ += WorldLength;
                }
                result[index] = getSingleIndex(roundI, roundJ);
                index++;
            }
        }
    }
}

