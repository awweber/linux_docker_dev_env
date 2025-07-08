#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void create_memory_leak() {
    char *buffer = (char *)malloc(100);
    if (buffer == NULL) {
        fprintf(stderr, "Failed to allocate memory.\n");
        exit(1);
    }
    strcpy(buffer, "This is a string stored in dynamically allocated memory.");
    printf("Buffer contains: %s\n", buffer);
    // Memory is not freed, causing a memory leak
    free(buffer); // Uncomment this line to fix the memory leak
}
int main() {
    printf("Starting the application...\n");
    for (int i = 0; i < 10; i++) {
        create_memory_leak();
    }
    printf("Application finished.\n");
    return 0;
}