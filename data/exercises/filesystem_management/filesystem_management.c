/*
Aufgabe: Fallstudie: Implementierung eines robusten Dateisystemmanagements für ein eingebettetes Linux-System

Einführung:
In dieser Fallstudie sollst du ein robustes Dateisystemmanagement für ein eingebettetes Linux-System implementieren. 
Du wirst ein C-Programm entwickeln, das verschiedene fortgeschrittene Operationen zur Verwaltung von Dateien und 
Verzeichnissen durchführt, einschließlich der Überwachung von Speicherplatznutzung, der Protokollierung von 
Dateioperationen und der Implementierung eines einfachen Journaling-Mechanismus, um die Datenintegrität zu gewährleisten.

Ziele
- Verstehen der fortgeschrittenen Datei- und Verzeichnisoperationen in einem eingebetteten Linux-System.
- Implementierung von Mechanismen zur Überwachung und Protokollierung der Speicherplatznutzung. 
- Entwicklung eines einfachen Journaling-Mechanismus zur Sicherstellung der Datenintegrität.

Anforderungen:
- Erstelle ein Verzeichnis und mehrere Dateien darin.
- Überwache die Speicherplatznutzung des Verzeichnisses und der Dateien.
- Protokolliere alle Dateioperationen (Erstellen, Lesen, Schreiben, Löschen) in einer Log-Datei.
- Implementiere einen einfachen Journaling-Mechanismus, der die Integrität der Daten bei plötzlichen Ausfällen sicherstellt.
- Führe Tests durch, um die Robustheit und Zuverlässigkeit des Systems zu überprüfen.

Aufgabe:
1. Verzeichnis erstellen und Dateien verwalten:
- Implementiere die Funktion create_directory, um ein Verzeichnis mit dem angegebenen Namen zu erstellen.
- Implementiere die Funktion create_files, um mehrere Dateien in dem erstellten Verzeichnis zu erstellen und Daten in diese Dateien zu schreiben.
- Implementiere die Funktion list_files, um die Dateien im erstellten Verzeichnis aufzulisten.
- Implementiere die Funktion delete_files, um die Dateien im erstellten Verzeichnis zu löschen.
- Implementiere die Funktion delete_directory, um das erstellte Verzeichnis zu löschen.
2. Speicherplatzüberwachung:
- Überwache die Speicherplatznutzung des Verzeichnisses und der Dateien. Implementiere eine Funktion, die die Größe des Verzeichnisses und der 
    Dateien berechnet und diese Informationen ausgibt.
3. Protokollierung:
- Implementiere die Funktion log_operation, um alle Dateioperationen (Erstellen, Lesen, Schreiben, Löschen) in einer Log-Datei zu protokollieren.
4. Journaling-Mechanismus:
- Implementiere einen einfachen Journaling-Mechanismus, um die Integrität der Daten bei plötzlichen Ausfällen sicherzustellen.
- Implementiere die Funktion update_journal, um jede Operation im Journal zu aktualisieren.
- Implementiere die Funktion apply_journal, um das Journal anzuwenden und alle Operationen in der Log-Datei zu protokollieren.
5. Tests:
- Führe Tests durch, um die Robustheit und Zuverlässigkeit des Systems zu überprüfen. Simuliere plötzliche Ausfälle und stelle sicher, dass das 
    System die Datenintegrität aufrechterhält.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <fcntl.h>
#include <time.h>

// Konstanten
#define DIRNAME "testdir"
#define FILENAME_PREFIX "file"
#define LOGFILE "operation_log.txt"
#define NUM_FILES 3
#define DATA "Das ist ein nicht ganz so langer Test."
#define JOURNAL_FILE "journal.txt"

// Funktionen
void log_operation(const char *operation) {
    FILE *logfile = fopen(LOGFILE, "a");
    if (logfile == NULL) {
        perror("Fehler beim Öffnen der Log-Datei");
        return;
    }
    time_t now = time(NULL); // Aktuelle Zeit abrufen
    fprintf(logfile, "%s: %s\n", ctime(&now), operation); // Zeitstempel hinzufügen
    fclose(logfile);
}
void log_operation_with_size(const char *operation, long size) {
    FILE *logfile = fopen(LOGFILE, "a");
    if (logfile == NULL) {
        perror("Fehler beim Öffnen der Log-Datei");
        return;
    }
    time_t now = time(NULL);
    fprintf(logfile, "%s: %s (Dateigröße: %ld Bytes)\n", ctime(&now), operation, size);
    fclose(logfile);
}
int create_directory(const char *dirname) {
    // Verzeichnis erstellen
    if (mkdir(dirname, 0755) != 0) {
        perror("Fehler beim Erstellen des Verzeichnisses");
        return 1;
    }
    log_operation("Verzeichnis erstellt");
    return 0;
}
int create_files(const char *dirname, int num_files, const char *data) {
    char filename[256];
    FILE *file;
    for (int i = 0; i < num_files; ++i) {
        snprintf(filename, sizeof(filename), "%s/%s%d.txt", dirname, FILENAME_PREFIX, i + 1);
        // Datei erstellen und öffnen
        file = fopen(filename, "w");
        if (file == NULL) {
            perror("Fehler beim Erstellen der Datei");
            return 1;
        }
        // Daten in die Datei schreiben
        if (fprintf(file, "%s\n", data) < 0) {
            perror("Fehler beim Schreiben in die Datei");
            fclose(file);
            return 1;
        }
        // Datei schließen
        fclose(file);
        // Dateigröße ermitteln
        struct stat st;
        long size = 0;
        if (stat(filename, &st) == 0) {
            size = st.st_size;
        }
        char operation[256];
        snprintf(operation, sizeof(operation), "Datei erstellt: %s", filename);
        log_operation_with_size(operation, size);
    }
    return 0;
}
int list_files(const char *dirname) {
    DIR *dir;
    struct dirent *entry;
    // Verzeichnis öffnen
    dir = opendir(dirname);
    if (dir == NULL) {
        perror("Fehler beim Öffnen des Verzeichnisses");
        return 1;
    }
    // Dateien im Verzeichnis auflisten
    printf("Dateien im Verzeichnis %s:\n", dirname);
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_REG) {
            printf("%s\n", entry->d_name);
        }
    }
    // Verzeichnis schließen
    closedir(dir);
    log_operation("Dateien aufgelistet");
    return 0;
}
int delete_files(const char *dirname) {
    char filepath[256];
    DIR *dir;
    struct dirent *entry;
    // Verzeichnis öffnen
    dir = opendir(dirname);
    if (dir == NULL) {
        perror("Fehler beim Öffnen des Verzeichnisses");
        return 1;
    }
    // Dateien im Verzeichnis löschen
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_REG) {
            snprintf(filepath, sizeof(filepath), "%s/%s", dirname, entry->d_name);
            // Dateigröße vor dem Löschen ermitteln
            struct stat st;
            long size = 0;
            if (stat(filepath, &st) == 0) {
                size = st.st_size;
            }
            if (remove(filepath) != 0) {
                perror("Fehler beim Löschen der Datei");
                closedir(dir);
                return 1;
            }
            char operation[256];
            snprintf(operation, sizeof(operation), "Datei gelöscht: %s", filepath);
            log_operation_with_size(operation, size);
        }
    }
    // Verzeichnis schließen
    closedir(dir);
    return 0;
}
int delete_directory(const char *dirname) {
    // Verzeichnis löschen
    if (rmdir(dirname) != 0) {
        perror("Fehler beim Löschen des Verzeichnisses");
        return 1;
    }
    log_operation("Verzeichnis gelöscht");
    return 0;
}
void update_journal(const char *operation) {
    FILE *journal = fopen(JOURNAL_FILE, "a");
    if (journal == NULL) {
        perror("Fehler beim Öffnen der Journal-Datei");
        return;
    }
    fprintf(journal, "%s\n", operation);
    fclose(journal);
}
void apply_journal() {
    FILE *journal = fopen(JOURNAL_FILE, "r");
    if (journal == NULL) {
        perror("Fehler beim Öffnen der Journal-Datei");
        return;
    }
    char operation[256];
    while (fgets(operation, sizeof(operation), journal)) {
        operation[strcspn(operation, "\n")] = 0; // Newline entfernen
        log_operation(operation);
    }
    fclose(journal);
}
// Speicherplatzüberwachung: Berechnet die Gesamtgröße aller Dateien im Verzeichnis
long get_directory_size(const char *dirname) {
    DIR *dir = opendir(dirname);
    if (!dir) {
        perror("Fehler beim Öffnen des Verzeichnisses zur Größenberechnung");
        return -1;
    }
    struct dirent *entry;
    struct stat st;
    char filepath[256];
    long total_size = 0;
    while ((entry = readdir(dir)) != NULL) {
        snprintf(filepath, sizeof(filepath), "%s/%s", dirname, entry->d_name);
        if (stat(filepath, &st) == 0 && S_ISREG(st.st_mode)) {
            total_size += st.st_size;
        }
    }
    closedir(dir);
    return total_size;
}
int main() {
    // Journal anwenden
    apply_journal();
    // Verzeichnis erstellen
    if (create_directory(DIRNAME) != 0) {
        return 1;
    }
    update_journal("Verzeichnis erstellt");
    // Dateien im Verzeichnis erstellen
    if (create_files(DIRNAME, NUM_FILES, DATA) != 0) {
        return 1;
    }
    update_journal("Dateien erstellt");
    // Speicherplatzüberwachung nach dem Erstellen
    long dir_size = get_directory_size(DIRNAME);
    if (dir_size >= 0) {
        printf("Speicherplatznutzung nach dem Erstellen: %ld Bytes\n", dir_size);
    }
    // Dateien im Verzeichnis auflisten
    if (list_files(DIRNAME) != 0) {
        return 1;
    }
    update_journal("Dateien aufgelistet");
    // Dateien im Verzeichnis löschen
    if (delete_files(DIRNAME) != 0) {
        return 1;
    }
    update_journal("Dateien gelöscht");
    // Speicherplatzüberwachung nach dem Löschen
    dir_size = get_directory_size(DIRNAME);
    if (dir_size >= 0) {
        printf("Speicherplatznutzung nach dem Löschen: %ld Bytes\n", dir_size);
    }
    // Verzeichnis löschen
    if (delete_directory(DIRNAME) != 0) {
        return 1;
    }
    update_journal("Verzeichnis gelöscht");
    printf("Alle Operationen erfolgreich abgeschlossen.\n");
    return 0;
}
