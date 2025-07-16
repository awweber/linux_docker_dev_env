# Aufgabe: Implementierung eines Echtzeit-Threads in Embedded Linux


## Ziel der Aufgabe

In dieser Aufgabe lernst du, wie man Echtzeitfähigkeiten in Embedded Linux durch den Einsatz des PREEMPT-RT Patches implementiert. Du erweiterst den gegebenen Code, um Echtzeitfähigkeiten hinzuzufügen und die erfassten Daten periodisch zu veröffentlichen.

## Gegebener Code
Du erhältst den folgenden Basiscode, der eine einfache Funktion zur Ausgabe einer Nachricht implementiert:

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

// Beispiel-Thread-Funktion
void *simple_task(void *arg) {
    while (1) {
        printf("Einfacher Task wird
ausgeführt\n");
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
```

## Aufgabenstellung
Erweitere den gegebenen Code, um einen Echtzeit-Thread zu implementieren, der periodisch eine Aufgabe ausführt. Füge dazu den PREEMPT-RT Patch hinzu und konfiguriere den Kernel entsprechend. Ersetze den einfachen Task durch eine Echtzeit-Task-Funktion, die eine präzisere Timing-Genauigkeit bietet.