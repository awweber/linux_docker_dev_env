Aufgabe: Entwicklung einer einfachen Steuerungslogik für ein industrielles Steuerungssystem mit Embedded Linux

In dieser Übungsaufgabe sollst du eine einfache Steuerungslogik für ein industrielles Steuerungssystem implementieren und erweitern. Dabei sollst du eine Steuerung für ein fiktives Industriegerät entwickeln, das auf Sensordaten reagiert und Aktuatoren steuert. Ziel ist es, die grundlegenden Schritte zur Entwicklung und Erweiterung einer Steuerungslogik zu verstehen und anzuwenden. 

Schritte: 

Erstellen eines einfachen Steuerungsprogramms in C 

Erweiterung des Programms zur Simulation von Sensordaten 

Erweiterung des Programms zur Steuerung eines Aktuators basierend auf Sensordaten 

Testen der Steuerungslogik 

Vorgegebene Dateien: 

controller.c - Datei mit dem Grundgerüst des Steuerungsprogramms 



Schritt 1: Erstellen eines einfachen Steuerungsprogramms in C 

#include <stdio.h> 
#include <unistd.h> 
 
#define SENSOR_PIN 4 
#define ACTUATOR_PIN 7 
 
void setup() { 
    // Initialisierung der Pins (Simulation) 
    printf("Initialisiere Sensor-Pin %d und Aktuator-Pin %d\n", SENSOR_PIN, ACTUATOR_PIN); 
} 
 
void loop() { 
    // Simulierte Leseoperation vom Sensor 
    int sensorValue = readSensor(); 
    if (sensorValue > 50) { 
        activateActuator(); 
    } else { 
        deactivateActuator(); 
    } 
    sleep(1); 
} 
 
int readSensor() { 
    // Simulierter Sensorwert (Zufallswert zwischen 0 und 100) 
    return rand() % 101; 
} 
 
void activateActuator() { 
    printf("Aktiviere Aktuator\n"); 
} 
 
void deactivateActuator() { 
    printf("Deaktiviere Aktuator\n"); 
} 
 
int main() { 
    setup(); 
    while (1) { 
        loop(); 
    } 
    return 0; 
} 


Schritt 2: Erweiterung des Programms zur Simulation von Sensordaten 

Erweitere das Programm controller.c, um die Simulation von Sensordaten zu verbessern. Füge folgende Funktionen hinzu: 

generateSensorData(): Simuliert realistischere Sensordaten 

Aktualisiere controller.c wie folgt: 


#include <stdio.h> 
#include <unistd.h> 
#include <stdlib.h> 
#include <time.h> 
 
#define SENSOR_PIN 4 
#define ACTUATOR_PIN 7 
 
void setup() { 
    // Initialisierung der Pins (Simulation) 
    printf("Initialisiere Sensor-Pin %d und Aktuator-Pin %d\n", SENSOR_PIN, ACTUATOR_PIN); 
    srand(time(NULL)); 
} 
 
void loop() { 
    // Simulierte Leseoperation vom Sensor 
    int sensorValue = generateSensorData(); 
    printf("Sensorwert: %d\n", sensorValue); 
    if (sensorValue > 50) { 
        activateActuator(); 
    } else { 
        deactivateActuator(); 
    } 
    sleep(1); 
} 
 
int generateSensorData() { 
    // Simulierter Sensorwert (Zufallswert zwischen 0 und 100) 
    return rand() % 101; 
} 
 
void activateActuator() { 
    printf("Aktiviere Aktuator\n"); 
} 
 
void deactivateActuator() { 
    printf("Deaktiviere Aktuator\n"); 
} 
 
int main() { 
    setup(); 
    while (1) { 
        loop(); 
    } 
    return 0; 
} 


Schritt 3: Erweiterung des Programms zur Steuerung eines Aktuators basierend auf Sensordaten 

Erweitere das Programm, um die Steuerung des Aktuators basierend auf komplexeren Bedingungen zu gestalten. Füge eine Hysterese-Funktionalität hinzu, um das Ein- und Ausschalten des Aktuators zu glätten. 

Aktualisiere controller.c wie folgt: 

#include <stdio.h> 
#include <unistd.h> 
#include <stdlib.h> 
#include <time.h> 
 
#define SENSOR_PIN 4 
#define ACTUATOR_PIN 7 
#define UPPER_THRESHOLD 60 
#define LOWER_THRESHOLD 40 
 
void setup() { 
    // Initialisierung der Pins (Simulation) 
    printf("Initialisiere Sensor-Pin %d und Aktuator-Pin %d\n", SENSOR_PIN, ACTUATOR_PIN); 
    srand(time(NULL)); 
} 
 
void loop() { 
    // Simulierte Leseoperation vom Sensor 
    int sensorValue = generateSensorData(); 
    printf("Sensorwert: %d\n", sensorValue); 
    controlActuator(sensorValue); 
    sleep(1); 
} 
 
int generateSensorData() { 
    // Simulierter Sensorwert (Zufallswert zwischen 0 und 100) 
    return rand() % 101; 
} 
 
void controlActuator(int sensorValue) { 
    static int actuatorState = 0; // 0 = aus, 1 = an 
    if (sensorValue > UPPER_THRESHOLD && !actuatorState) { 
        activateActuator(); 
        actuatorState = 1; 
    } else if (sensorValue < LOWER_THRESHOLD && actuatorState) { 
        deactivateActuator(); 
        actuatorState = 0; 
    } 
} 
 
void activateActuator() { 
    printf("Aktiviere Aktuator\n"); 
} 
 
void deactivateActuator() { 
    printf("Deaktiviere Aktuator\n"); 
} 
 
int main() { 
    setup(); 
    while (1) { 
        loop(); 
    } 
    return 0; 
} 

Schritt 4: Testen der Steuerungslogik 

Kompiliere und teste das Programm: 

Kompilieren des Programms: 

gcc controller.c -o controller 

Ausführen des Programms: 

./controller 

Überprüfe die Ausgabe des Programms, um sicherzustellen, dass der Aktuator basierend auf den Sensordaten korrekt aktiviert und deaktiviert wird. 