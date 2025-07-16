/* Aufgabe:
In dieser Übungsaufgabe sollst du die Dynamic Voltage and Frequency Scaling (DVFS) auf einem 
Embedded Linux-System implementieren und überwachen. Ziel ist es, die Energieeffizienz des Systems 
zu optimieren, indem du die CPU-Spannung und -Frequenz dynamisch an die aktuelle Arbeitslast anpasst.

Der folgende C-Code für eine einfache Anwendung enthält Platzhalter für die Implementierung der 
DVFS-Maßnahmen. Ihre Aufgabe besteht darin, diese Maßnahmen zu implementieren und den Energieverbrauch 
des Systems zu reduzieren.

Anforderung:
1. Implementiere die Funktion set_cpu_dvfs, um die CPU-Frequenz und -Spannung dynamisch anzupassen.
2. Erstelle ein Skript, das die aktuelle CPU-Auslastung überwacht und die CPU-Frequenz 
    und -Spannung basierend auf der Arbeitslast dynamisch anpasst.
3. Kompiliere die Anwendung und führe sie auf deinem Embedded Linux-System aus.
4. Überprüfe den Energieverbrauch vor und nach der Implementierung von DVFS, um die 
    Auswirkungen deiner Änderungen zu bewerten.
----------------------------------------------------------------------------------------------*/
// Code:

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

// Funktion zur Anpassung der CPU-Frequenz und -Spannung
void set_cpu_dvfs(const char *freq, const char *voltage) {
    int fd;
    
    // Setzen der CPU-Frequenz
    fd = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed", O_WRONLY);
    if (fd == -1) {
        perror("Failed to open scaling_setspeed");
        exit(EXIT_FAILURE);
    }
    
    if (write(fd, freq, strlen(freq)) == -1) {
        perror("Failed to write to scaling_setspeed");
        close(fd);
        exit(EXIT_FAILURE);
    }
    
    close(fd);
    
    // Setzen der CPU-Spannung (Beispielpfad, je nach Plattform anpassen)
    fd = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_setvoltage", O_WRONLY);
    if (fd == -1) {
        perror("Failed to open scaling_setvoltage");
        exit(EXIT_FAILURE);
    }
    
    if (write(fd, voltage, strlen(voltage)) == -1) {
        perror("Failed to write to scaling_setvoltage");
        close(fd);
        exit(EXIT_FAILURE);
    }
    
    close(fd);
}

// Funktion zum Lesen der aktuellen CPU-Frequenz
void get_cpu_frequency() {
    int fd;
    char buffer[256];
    ssize_t bytes_read;
    
    // Lesen der aktuellen CPU-Frequenz
    fd = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq", O_RDONLY);
    if (fd == -1) {
        perror("Failed to open scaling_cur_freq");
        return;
    }
    
    bytes_read = read(fd, buffer, sizeof(buffer) - 1);
    if (bytes_read == -1) {
        perror("Failed to read scaling_cur_freq");
        close(fd);
        return;
    }
    
    buffer[bytes_read] = '\0'; // Null-Terminierung des Strings
    printf("Aktuelle CPU-Frequenz: %s Hz\n", buffer);
    close(fd);
}

// Funktion zum Lesen der aktuellen CPU-Spannung
void get_cpu_voltage() {
    int fd;
    char buffer[256];
    ssize_t bytes_read;
    
    // Versuch, die aktuelle CPU-Spannung zu lesen (Pfad kann je nach Plattform variieren)
    fd = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_voltage", O_RDONLY);
    if (fd == -1) {
        // Alternativer Pfad für einige Systeme
        fd = open("/sys/class/regulator/regulator.0/microvolts", O_RDONLY);
        if (fd == -1) {
            printf("CPU-Spannungsinformationen sind auf diesem System nicht verfügbar\n");
            return;
        }
    }
    
    bytes_read = read(fd, buffer, sizeof(buffer) - 1);
    if (bytes_read == -1) {
        perror("Failed to read voltage");
        close(fd);
        return;
    }
    
    buffer[bytes_read] = '\0'; // Null-Terminierung des Strings
    printf("Aktuelle CPU-Spannung: %s mV\n", buffer);
    close(fd);
}

// Funktion zur Anzeige der verfügbaren CPU-Frequenzen
void get_available_frequencies() {
    int fd;
    char buffer[1024];
    ssize_t bytes_read;
    
    fd = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies", O_RDONLY);
    if (fd == -1) {
        perror("Failed to open scaling_available_frequencies");
        return;
    }
    
    bytes_read = read(fd, buffer, sizeof(buffer) - 1);
    if (bytes_read == -1) {
        perror("Failed to read scaling_available_frequencies");
        close(fd);
        return;
    }
    
    buffer[bytes_read] = '\0';
    printf("Verfügbare CPU-Frequenzen: %s", buffer);
    close(fd);
}

// Funktion zur Anzeige des aktuellen CPU-Governors
void get_cpu_governor() {
    int fd;
    char buffer[256];
    ssize_t bytes_read;
    
    fd = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor", O_RDONLY);
    if (fd == -1) {
        perror("Failed to open scaling_governor");
        return;
    }
    
    bytes_read = read(fd, buffer, sizeof(buffer) - 1);
    if (bytes_read == -1) {
        perror("Failed to read scaling_governor");
        close(fd);
        return;
    }
    
    buffer[bytes_read] = '\0';
    printf("Aktueller CPU-Governor: %s", buffer);
    close(fd);
}

int main() {
    printf("=== DVFS System Information ===\n");
    
    // Display current system state before any changes
    printf("\n--- Initial System State ---\n");
    get_cpu_frequency();
    get_cpu_voltage();
    get_cpu_governor();
    
    printf("\n--- Available Options ---\n");
    get_available_frequencies();
    
    printf("\n=== Starting DVFS Optimization ===\n");

    // Example: Set low frequency and voltage
    printf("\nSetting low power mode (800MHz)...\n");
    set_cpu_dvfs("800000", "800000");
    
    // Check current state after change
    printf("After setting low power mode:\n");
    get_cpu_frequency();
    get_cpu_voltage();

    // Example: Set high frequency and voltage
    printf("\nSetting high performance mode (1.6GHz)...\n");
    set_cpu_dvfs("1600000", "1200000");
    
    // Check current state after change
    printf("After setting high performance mode:\n");
    get_cpu_frequency();
    get_cpu_voltage();

    printf("\nDVFS optimization complete.\n");
    return 0;
}
