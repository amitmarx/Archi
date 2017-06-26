
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/fcntl.h>
#include <unistd.h>
#include <string.h>

#define printDebug if(debug) printf

//
// Created by Amit Marx on 08/06/2017.
//
int debug = 0;
int unitSize = 2;
char fileName[100] = "/Users/amitm/dev/archi/labs/lab07/T0/a.out";
char *menu[];
char *data_pointer = NULL;

typedef void *(*func)(void);

void writeDebug(char *message);

void writeIntDebug(int message);

int getMenuSelection() {
    int i = 0;
    fprintf(stdout, "Choose action:\n");
    while (menu[i] != NULL) {
        fprintf(stdout, "%d-%s\n", i, menu[i]);
        i++;
    }

    int result;
    char reader[100];
    fgets(reader, sizeof(reader), stdin);
    reader[strlen(reader) - 1] = 0;
    sscanf(reader, "%d", &result);
    return result;
}

void writeDebug(char *message) {
    if (debug)
        fprintf(stderr, "%s\n", message);
}

void writeIntDebug(int message) {
    if (debug)
        fprintf(stderr, "%d\n", message);
}

void setFileName() {
    char reader[100];
    fgets(reader, sizeof(reader), stdin);
    reader[strlen(reader) - 1] = 0;
    sscanf(reader, "%s", &fileName);
    printDebug("Set Name:%s\n", fileName);
}

void toggleDebug() {
    debug = debug ^ 1;
}

void setSize() {
    while (scanf("%d", &unitSize) <= 0 || (unitSize != 1 && unitSize != 2 && unitSize != 4));
    writeDebug("Debug: set size to");
    writeIntDebug(unitSize);
}

void quit() {
    writeDebug("quitting");
    exit(0);
}

void loadIntoMemory() {
    FILE *file = fopen(&fileName, "r");
    if (fileName == NULL) {
        return;
    }
    printf("Please enter <mem-address> <location> <length>\n");
    int length, offset, memory;
    char reader[100];
    fgets(reader, sizeof(reader), stdin);
    reader[strlen(reader) - 1] = 0;
    sscanf(reader, "%d %x %d", &memory, &offset, &length);
    printDebug("Debug: location- %x length- %d\n", offset, length);

    if (data_pointer != NULL) {
        free(data_pointer);
    }
    data_pointer = (char *) malloc(length);
    fseek(file, offset, SEEK_SET);
    fread(data_pointer, unitSize, length, file);

    fprintf(stdout, "Loaded %d bytes into 0x%x\n", length, (unsigned int) (&data_pointer));
    printf("\n");
    fclose(file);
}

void fileDisplay() {
    FILE *file = fopen(&fileName, "r");
    fprintf(stdout, "Please enter <location> <length>\n");
    int location, length;

    char reader[100];
    fgets(reader, sizeof(reader), stdin);
    reader[strlen(reader) - 1] = 0;
    sscanf(reader, "%x %d", &location, &length);

    int y = fseek(file, location, SEEK_SET);
    int size = unitSize * length;
    unsigned char buf[size];
    fread(buf, unitSize, length, file);
    fclose(file);
    int i;
    for (i = 0; i < size - 1; i += 2) {
        buf[i + 1] += buf[i];
        buf[i] = buf[i + 1] - buf[i];
        buf[i + 1] -= buf[i];
    }

    for (i = 0; i < size; i++) {
        printf("%02x", buf[i]);
        if ((i + 1) % unitSize == 0) {
            printf(" ");
        }
    }
    int decimal = 0;
    printf("\nDecimal\n");
    for (i = 0; i < size; i++) {
        for (int pow = 0; pow < unitSize; pow++) {
            decimal *= 16;
        }
        decimal += (int) buf[i];
        if ((i + 1) % unitSize == 0) {
            fprintf(stdout, "%d ",decimal);
            decimal = 0;
        }
    }
    printf("\n");
}

void saveIntoFile() {
    FILE *file;
    file = fopen(fileName, "r+");
    if (file == NULL) {
        printf("%s\n", fileName);
        printf("error: could not open file.\n");
        return;
    }
    int target, length;
    char *source;
    printf("Please enter <source-address> <target-location> <length>\n");
    char reader[100];
    fgets(reader, sizeof(reader), stdin);
    reader[strlen(reader) - 1] = 0;
    sscanf(reader, "%p %x %d", &source, &target, &length);
    printDebug("source -%x , target- %x length- %d\n", source, target, length);

    if (target > fileSize(file)) {
        fprintf(stdout, "Error:<target-location> is greater than the size of <filename>\n");
        return;
    }
    fseek(file, target, SEEK_SET);
    fwrite(source == 0 ? data_pointer : source, unitSize, length, file);

    fclose(file);
}

void fileModify() {
    FILE *file;
    file = fopen(fileName, "r+");
    if (file == NULL) {
        printf("%s\n", fileName);
        printf("error: could not open file.\n");
        return;
    }
    printf("Please enter <location> <val>\n");
    char reader[100];
    fgets(reader, sizeof(reader), stdin);
    reader[strlen(reader) - 1] = 0;
    int location;
    char *val;
    sscanf(reader, "%x %s", &location, &val);
    fseek(file, location, SEEK_SET);
    int x = fwrite(&val, unitSize, 1, file);
    fclose(file);
}

char *menu[] = {"Toggle Debug Mode", "Set File Name", "Set Unit Size", "file display", "Load into Memory",
                "Save Into File", "File Modify",
                "Quit", NULL};

func funcs[] = {&toggleDebug, &setFileName, &setSize, &fileDisplay, &loadIntoMemory,
                &saveIntoFile, &fileModify,
                &quit};

int main(int argc, char **argv) {
    while (1) {
        int menuSelection = getMenuSelection();
        (*(funcs[menuSelection]))();
    }
}

int fileSize(FILE *file) {
    fseek(file, 0L, SEEK_END);
    int sz = ftell(file);
    fseek(file, 0L, SEEK_SET);
    return sz;
}

int getDecimalValue(int hex, int level) {
    if (hex == 0) return 0;
    int pow = 1;
    int i;
    for (i = 0; i < pow; i++) {
        pow *= 16;
    }
    return (i % 10) * pow + getDecimalValue(hex / 10, level + 1);

}
