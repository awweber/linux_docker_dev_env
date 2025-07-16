#!/bin/bash

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Simple Char Device Driver Test ===${NC}"

# Überprüfen, ob das Skript als Root ausgeführt wird
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Bitte als Root ausführen (sudo ./test_driver.sh)${NC}"
    exit 1
fi

# Schritt 1: Treiber kompilieren
echo -e "${YELLOW}Schritt 1: Treiber kompilieren${NC}"
make clean
make
if [ $? -ne 0 ]; then
    echo -e "${RED}Kompilierung fehlgeschlagen!${NC}"
    exit 1
fi
echo -e "${GREEN}Kompilierung erfolgreich!${NC}"

# Schritt 2: Treiber laden
echo -e "${YELLOW}Schritt 2: Treiber laden${NC}"
insmod simple_char_device.ko
if [ $? -ne 0 ]; then
    echo -e "${RED}Treiber konnte nicht geladen werden!${NC}"
    exit 1
fi
echo -e "${GREEN}Treiber erfolgreich geladen!${NC}"

# Major-Nummer aus dmesg extrahieren
MAJOR=$(dmesg | grep "Simple Char Device: Registered with major number" | tail -1 | grep -o '[0-9]\+')
if [ -z "$MAJOR" ]; then
    echo -e "${RED}Konnte Major-Nummer nicht ermitteln!${NC}"
    rmmod simple_char_device
    exit 1
fi
echo -e "${GREEN}Major-Nummer: $MAJOR${NC}"

# Schritt 3: Device-Datei erstellen
echo -e "${YELLOW}Schritt 3: Device-Datei erstellen${NC}"
mknod /dev/simple_char_device c $MAJOR 0
chmod 666 /dev/simple_char_device
if [ ! -e /dev/simple_char_device ]; then
    echo -e "${RED}Device-Datei konnte nicht erstellt werden!${NC}"
    rmmod simple_char_device
    exit 1
fi
echo -e "${GREEN}Device-Datei erfolgreich erstellt!${NC}"

# Schritt 4: Schreibtest
echo -e "${YELLOW}Schritt 4: Schreibtest${NC}"
TEST_STRING="Hello, Linux Kernel Module!"
echo "$TEST_STRING" > /dev/simple_char_device
if [ $? -ne 0 ]; then
    echo -e "${RED}Schreibtest fehlgeschlagen!${NC}"
    rm -f /dev/simple_char_device
    rmmod simple_char_device
    exit 1
fi
echo -e "${GREEN}Schreibtest erfolgreich!${NC}"

# Schritt 5: Lesetest
echo -e "${YELLOW}Schritt 5: Lesetest${NC}"
READ_STRING=$(cat /dev/simple_char_device)
if [ "$READ_STRING" = "$TEST_STRING" ]; then
    echo -e "${GREEN}Lesetest erfolgreich!${NC}"
    echo -e "${GREEN}Geschrieben: '$TEST_STRING'${NC}"
    echo -e "${GREEN}Gelesen: '$READ_STRING'${NC}"
else
    echo -e "${RED}Lesetest fehlgeschlagen!${NC}"
    echo -e "${RED}Erwartet: '$TEST_STRING'${NC}"
    echo -e "${RED}Erhalten: '$READ_STRING'${NC}"
fi

# Schritt 6: Mehrfache Lese-/Schreibtests
echo -e "${YELLOW}Schritt 6: Mehrfache Tests${NC}"
for i in {1..3}; do
    echo "Test $i" > /dev/simple_char_device
    RESULT=$(cat /dev/simple_char_device)
    if [ "$RESULT" = "Test $i" ]; then
        echo -e "${GREEN}Test $i: OK${NC}"
    else
        echo -e "${RED}Test $i: FEHLER${NC}"
    fi
done

# Schritt 7: Kernel-Logs anzeigen
echo -e "${YELLOW}Schritt 7: Kernel-Logs (letzte 10 Zeilen)${NC}"
dmesg | grep "Simple Char Device" | tail -10

# Schritt 8: Aufräumen
echo -e "${YELLOW}Schritt 8: Aufräumen${NC}"
rm -f /dev/simple_char_device
rmmod simple_char_device
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Treiber erfolgreich entladen!${NC}"
else
    echo -e "${RED}Fehler beim Entladen des Treibers!${NC}"
fi

echo -e "${YELLOW}=== Test abgeschlossen ===${NC}"

# Aufräumen der kompilierten Dateien
make clean

echo -e "${GREEN}Alle Tests erfolgreich durchgeführt!${NC}"