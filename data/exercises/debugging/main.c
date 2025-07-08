#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void faulty_function() {
    char buffer[256];
    strcpy(buffer, "This is a string that is too long for the buffer.");
}

int main() {
    printf("Starting the application...\n");

    faulty_function();
    
    printf("Application finished successfully.\n");
    return 0;
}