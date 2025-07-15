# Aufgabe: Entwicklung und Cross-Kompilierung eines C-Programms für ARM

## Ziel
In dieser Übungsaufgabe sollst du ein einfaches C-Programm für eine ARM-Architektur entwickeln, es auf deinem Host-System kompilieren und dann auf einer ARM-Plattform ausführen. Ziel ist es, die Schritte zur Cross-Kompilierung und Ausführung eines Programms auf einer anderen Architektur zu verstehen.

## Schritte:
1. Erstellen eines einfachen C-Programms
2. Cross-Kompilieren des C-Programms für ARM
3. Einrichten einer ARM-Emulationsumgebung
4. Ausführen des kompilierten Programms auf der ARM-Emulationsumgebung
5. Überprüfung der Ausgabe

## Vorgegebene Dateien:
Keine, du wirst das C-Programm selbst erstellen. 

## Schritt 1: Erstellen eines einfachen C-Programms

Erstelle eine Datei namens `hello_arm.c` mit folgendem Inhalt:

```c
#include <stdio.h>

int main() {
    printf("Hello, ARM World!\n");
    return 0;
}
```

## Schritt 2: Cross-Kompilieren des C-Programms für ARM

Öffne das Terminal im Docker-Container und wechsle in das Arbeitsverzeichnis. Führe den folgenden Befehl aus, um das C-Programm für die ARM-Architektur zu kompilieren:

```bash
arm-linux-gnueabi-gcc hello_arm.c -o hello_arm
```

## Schritt 3: Einrichten einer ARM-Emulationsumgebung

Nutze QEMU, um eine ARM-Emulationsumgebung einzurichten. Erstelle zunächst ein einfaches Root-Dateisystem für die Emulation. Du kannst ein minimales Debian-Root-Dateisystem verwenden, das du mit dem folgenden Befehl herunterladen und entpacken kannst:

```bash
wget http://ftp.debian.org/debian/dists/stable/main/installer-armhf/current/images/netboot/netboot.tar.gz
tar -xzvf netboot.tar.gz
```

Erstelle eine Start-Skript-Datei namens `start_qemu.sh` mit folgendem Inhalt:

```bash
#!/bin/bash
qemu-system-arm -M versatilepb -kernel vmlinuz-*-armhf -initrd initrd.gz -append "root=/dev/ram0" -serial stdio -no-reboot
```

## Schritt 4: Ausführen des kompilierten Programms auf der ARM-Emulationsumgebung

Mache das Skript ausführbar und starte die Emulation:

```bash
chmod +x start_qemu.sh
./start_qemu.sh
```

Sobald das Emulationssystem hochgefahren ist, öffne ein neues Terminal und kopiere das kompilierten Programm `hello_arm` in die Emulationsumgebung:

```bash
scp hello_arm user@localhost:/tmp
```

Melde dich bei der Emulationsumgebung an (das Passwort wird während der Emulation angezeigt) und führe das Programm aus:

```bash
cd /tmp
chmod +x hello_arm
./hello_arm
```

## Schritt 5: Überprüfung der Ausgabe

Überprüfe die Ausgabe des Programms. Es sollte die folgende Zeile angezeigt werden:

```
Hello, ARM World!
```