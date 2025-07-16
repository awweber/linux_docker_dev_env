/* Aufgabe: Implementierung einer Echtzeit-Anwendung in Embedded Linux

Erstelle ein C-Programm, das die Echtzeitfähigkeiten von Linux nutzt, 
um eine einfache Echtzeit-Aufgabe zu implementieren. 

Dein Programm soll folgende Funktionen erfüllen:
- Erstelle eine Echtzeit-Aufgabe mit hoher Priorität.
- Implementiere eine Funktion, die periodisch eine Ausgabe auf die Konsole schreibt.
- Verwende geeignete Synchronisationsmechanismen, um sicherzustellen, dass die Echtzeit-Aufgabe 
  deterministisch ausgeführt wird.

Anforderung:
- Vervollständige den bereitgestellten Code für die Echtzeit-Anwendung (realtime_task.c), 
    indem du die Funktionen zur Erstellung und Verwaltung der Echtzeit-Aufgabe hinzufügst.
- Stelle sicher, dass der Code korrekt kompiliert und ausgeführt werden kann.
*/

#define _POSIX_C_SOURCE 199309L

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h> // Für pthreads
#include <sched.h> // Für SCHED_FIFO und SCHED_RR
#include <unistd.h> // Für sleep
#include <time.h> // Für clock_gettime und clock_nanosleep
#ifndef TIMER_ABSTIME
#define TIMER_ABSTIME 1
#endif

#define PERIOD_SEC 1
#define PERIOD_NSEC 0

void *realtime_task(void *arg) {
    struct timespec next_activation;
    clock_gettime(CLOCK_MONOTONIC, &next_activation);
    while (1) {
        // Periodische Ausgabe auf die Konsole
        printf("Echtzeit-Aufgabe läuft\n");
        fflush(stdout);
        // Nächste Aktivierungszeit berechnen
        next_activation.tv_sec += PERIOD_SEC;
        next_activation.tv_nsec += PERIOD_NSEC;
        if (next_activation.tv_nsec >= 1000000000) {
            next_activation.tv_sec += 1;
            next_activation.tv_nsec -= 1000000000;
        }
        // Warten bis zur nächsten Aktivierung (deterministisch)
        clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next_activation, NULL);
    }
    return NULL;
}

int main() {
    pthread_t thread;
    struct sched_param param;
    pthread_attr_t attr;

    // Echtzeit-Thread-Attribute initialisieren
    pthread_attr_init(&attr);
    pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
    pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
    param.sched_priority = 80; // Hohe Priorität
    pthread_attr_setschedparam(&attr, &param);

    // Echtzeit-Thread erstellen
    if (pthread_create(&thread, &attr, realtime_task, NULL) != 0) {
        perror("Fehler beim Erstellen des Echtzeit-Threads");
        fprintf(stderr, "Hinweis: Für SCHED_FIFO ist Root-Rechte nötig (sudo).\n");
        return 1;
    }
    // Haupt-Thread schlafen lassen, um Echtzeit-Thread laufen zu lassen
    while (1) {
        sleep(1);
    }

    // Haupt-Thread wartet auf Beenden (optional: Signal-Handling für sauberes Beenden)
    pthread_join(thread, NULL);
    pthread_attr_destroy(&attr);
    return 0;
}
