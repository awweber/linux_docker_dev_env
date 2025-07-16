#!/bin/bash
# Schnellstart-Skript für RT-Kernel-Build

echo "=== RT-Kernel Build für Raspberry Pi 5 ==="
echo "Linux Kernel 6.15.6 mit PREEMPT_RT"
echo ""

# Prüfe ob Docker läuft
if ! docker ps >/dev/null 2>&1; then
    echo "Fehler: Docker ist nicht verfügbar oder läuft nicht."
    exit 1
fi

# Erstelle Container falls nicht vorhanden
if ! docker images | grep -q linux-dev-env; then
    echo "Docker-Image nicht gefunden. Erstelle Image..."
    docker build -t linux-dev-env .
fi

echo "=== Verfügbare Aktionen ==="
echo "1. Container starten (interaktiv)"
echo "2. Kernel kompilieren"
echo "3. Kernel testen (QEMU)"
echo "4. Status prüfen"
echo "5. Dokumentation anzeigen"
echo "6. Alle Skripte ausführbar machen"
echo ""
read -p "Wählen Sie eine Option (1-6): " choice

case $choice in
    1)
        echo "Starte interaktiven Container..."
        docker run -it --rm -v "$(pwd)/workspace:/home/developer/workspace" linux-dev-env /bin/bash
        ;;
    2)
        echo "Kompiliere RT-Kernel..."
        docker run -it --rm -v "$(pwd)/workspace:/home/developer/workspace" linux-dev-env /bin/bash -c "cd /home/developer/workspace && ./build_rt_kernel.sh"
        ;;
    3)
        echo "Teste RT-Kernel in QEMU..."
        docker run -it --rm -v "$(pwd)/workspace:/home/developer/workspace" linux-dev-env /bin/bash -c "cd /home/developer/workspace && ./start_qemu_rt.sh"
        ;;
    4)
        echo "Prüfe Build-Status..."
        docker run -it --rm -v "$(pwd)/workspace:/home/developer/workspace" linux-dev-env /bin/bash -c "cd /home/developer/workspace && make status"
        ;;
    5)
        echo "Zeige Dokumentation..."
        if command -v less >/dev/null 2>&1; then
            less README.md
        else
            cat README.md
        fi
        ;;
    6)
        echo "Mache alle Skripte ausführbar..."
        chmod +x workspace/*.sh
        echo "Skripte sind jetzt ausführbar."
        ;;
    *)
        echo "Ungültige Auswahl."
        exit 1
        ;;
esac
