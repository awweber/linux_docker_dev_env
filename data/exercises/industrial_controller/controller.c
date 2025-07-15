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

// Hauptfunktion
int main() {
    setup();
    while (1) {
        loop();
    }
    return 0;
}