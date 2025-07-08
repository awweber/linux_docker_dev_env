Basierend auf deinem Dockerfile hast du bereits eine sehr gute Grundlage für die QEMU-Nutzung geschaffen. Hier ist eine Schritt-für-Schritt-Anleitung:

## 1. Container bauen und starten

```bash
# Container bauen
docker build -t my-dev-env .

# Container mit privilegierten Rechten starten (wichtig für QEMU)
docker run -it --privileged -v $(pwd)/data:/home/dev/data my-dev-env
```

## 2. QEMU-Installation überprüfen

Im Container angekommen, prüfe die verfügbaren QEMU-Emulatoren:

```bash
# Verfügbare QEMU-Systeme anzeigen
ls /usr/bin/qemu-system-*

# Beispiel für ARM-Emulation
qemu-system-arm --version
qemu-system-aarch64 --version
```

## 3. Erstes QEMU-Beispiel: ARM-System emulieren

```bash
# Einfacher Test ohne Betriebssystem
qemu-system-arm -M help  # Verfügbare Maschinen anzeigen

# Minimales ARM-System starten (nur zu Testzwecken)
qemu-system-arm -M versatilepb -nographic -serial stdio
```

## 4. Mit eigenem Kernel/Image arbeiten

```bash
# Verzeichnis für Images erstellen
mkdir -p /home/dev/data/images
cd /home/dev/data/images

# Beispiel: Raspberry Pi Image emulieren
# (Du müsstest ein Raspberry Pi OS Image herunterladen)
qemu-system-arm \
    -M versatilepb \
    -cpu arm1176 \
    -m 256 \
    -drive file=raspios-lite.img,format=raw \
    -netdev user,id=net0 \
    -device rtl8139,netdev=net0 \
    -nographic
```

## 5. Cross-Compilation nutzen

Da du Cross-Compiler installiert hast, kannst du eigene Programme kompilieren:

```bash
# Beispiel: Einfaches C-Programm für ARM kompilieren
cat > hello.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello from ARM!\n");
    return 0;
}
EOF

# Für ARM kompilieren
arm-linux-gnueabi-gcc -o hello_arm hello.c

# Für AArch64 kompilieren
aarch64-linux-gnu-gcc -o hello_aarch64 hello.c
```

## 6. User-Mode-Emulation (für einzelne Programme)

```bash
# ARM-Programm mit QEMU-User ausführen
qemu-arm-static hello_arm

# AArch64-Programm ausführen
qemu-aarch64-static hello_aarch64
```

## 7. Netzwerk-Setup für QEMU

```bash
# QEMU mit Netzwerk-Weiterleitung
qemu-system-arm \
    -M versatilepb \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device rtl8139,netdev=net0 \
    -nographic
```

## 8. Debugging mit GDB

```bash
# QEMU mit GDB-Server starten
qemu-system-arm \
    -M versatilepb \
    -s -S \
    -nographic

# In einem anderen Terminal:
gdb-multiarch
(gdb) target remote :1234
(gdb) continue
```

## 9. Nützliche QEMU-Optionen

```bash
# Wichtige Parameter:
-M          # Maschinen-Typ
-cpu        # CPU-Typ
-m          # RAM-Größe
-drive      # Festplatten-Image
-netdev     # Netzwerk-Konfiguration
-nographic  # Kein grafisches Display
-serial     # Serielle Konsole
-s          # GDB-Server auf Port 1234
-S          # Bei Start pausieren
```

## 10. Persistente Daten

Nutze das Volume `/home/dev/data` für:
- Kernel-Images
- Rootfs-Images
- Deine kompilierten Programme
- Konfigurationsdateien

## Tipps:

1. **Privilegierte Rechte**: QEMU benötigt oft `--privileged` beim Docker-Start
2. **KVM-Support**: Für bessere Performance kannst du `--device /dev/kvm` hinzufügen (falls auf dem Host verfügbar)
3. **Display**: Für grafische Ausgabe füge `-X` zum Docker-Befehl hinzu und verwende `-display gtk`

Welche spezifische QEMU-Anwendung schwebt dir vor? Dann kann ich dir gezielteren Code dafür geben!