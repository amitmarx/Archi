#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER_SIZE 120 /*max width is 60, so it is 120 with spaces*/

int WorldWidth, WorldLength, row=0, column=0;
double currGen = 0; /*should be 1?*/
int** stateArray;
int*  cors; /*change to pointers to co-routines (stack pointers)*/
char inputBuffer[MAX_BUFFER_SIZE];

void readInput(char* inputFile){
	int i,j, offset=1;
	FILE* file;
	printf("array size=%d\n", WorldLength*WorldWidth);
	stateArray = (int**)malloc(sizeof(int*)*WorldLength);
	for (i=0; i<WorldLength; i++){
		stateArray[i] = (int*)malloc(sizeof(int)*WorldWidth);
	}

	file = fopen(inputFile, "r");

	for (i=0; i<WorldLength; i++){
		fgets(inputBuffer, MAX_BUFFER_SIZE, file);
		offset = !offset;
		for (j=0; j<WorldWidth; j++){
			stateArray[i][j] = (inputBuffer[offset+j*2]-0x30); /* *2 to skip spaces */
		}
	}

	/*for (i=0; i<WorldLength; i++){
		for (j=0; j<WorldWidth; j++){
			printf("%d ", stateArray[i][j]);
		}
		printf("\n");
	}*/

	fclose(file);
}

int main(int argc, char** argv){
	int totalGens, printFreq, totalCors, printerCoi, schedulerCoi, debug=0, i, j;

	if (strcmp(argv[1],"-d") == 0){
		debug = 1;
	}
	WorldLength = atoi(argv[2+debug]);
  	WorldWidth = atoi(argv[3+debug]);
  	totalGens = atoi(argv[4+debug]);
  	printFreq =  atoi(argv[5+debug]);
  	readInput(argv[1+debug]);
  	if (debug){
  		printf("length=%d\n", WorldLength);
  		printf("width=%d\n", WorldWidth);
  		printf("number of generations=%d\n", totalGens);
  		printf("print frequency=%d\n", printFreq);
  	}

  	/*---------------------*/

  	totalCors = WorldWidth*WorldLength+2;
  	schedulerCoi = totalCors-1;
  	printerCoi = totalCors-2;

  	/* initialize co-routines */
	for(i=0; i < WorldLength; i++){
		for (j=0; j < WorldWidth; j++){
		init_cell_from_c(i,j);
	}
	init_scheduler_from_c(totalGens, printFreq, WorldLength, WorldWidth);
	init_printer_from_c(WorldLength, WorldWidth);

	cors = malloc(sizeof(POINTERtoSTACK?)*totalCors);

	/* initialize cors array */
	for (i=0; i<totalCors; i++){
		cors[i] = pointers?...;
	}

	/* start a scheduler co-routine*/
	start_co_from_c (schedulerCoi);

	while (currGen < totalGen){ /*game loop*/
		resume(cors[row,column]);
		if (currGen+1 % printFreq == 0){ /*TODO: leave +1?*/
			resume(printer);
		}
		column = (column+1) % WorldWidth;
		if (column == 0){
			row = (row+1) % WorldLength;
		}
		if (row==0 && column==0){
			currGen += 0.5;
		}
	}
	

  	return 0;
}
