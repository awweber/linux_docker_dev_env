#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

// Beispiel-Thread-Funktion
void *simple_task(void *arg) {
    while (1) {
        printf("Einfacher Task wird ausgeführt\n");
        sleep(1); // 1 Sekunde warten
    }
    return NULL;
}

int main() {
    pthread_t
thread;
    if (pthread_create(&thread, NULL, simple_task, NULL) != 0) {
        perror("pthread_create");
        return EXIT_FAILURE;
    }

    pthread_join(thread, NULL);
    return EXIT_SUCCESS;
}