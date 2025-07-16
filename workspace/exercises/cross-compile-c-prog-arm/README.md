# ARM Cross-Compilation Aufgabe - Lösung

## Übersicht
Diese Aufgabe demonstriert die Cross-Compilation eines C-Programms für ARM-Architektur und dessen Ausführung.

## Dateien
- `hello_arm.c` - Das C-Quellcodeprogramm
- `hello_arm` - Kompilierte ARM-Binärdatei (dynamisch gelinkt)
- `hello_arm_static` - Kompilierte ARM-Binärdatei (statisch gelinkt)
- `test_cross_compile.sh` - Test-Script für die Cross-Compilation
- `start_qemu.sh` - Script zum Starten der QEMU ARM-Emulation
- `start_qemu_kernel.sh` - Script zum Starten der QEMU ARM-Emulation mit vorhandenem Kernel

## Verwendete Tools
- **arm-linux-gnueabi-gcc** - ARM Cross-Compiler
- **qemu-system-arm** - QEMU ARM System-Emulator  
- **qemu-arm-static** - QEMU ARM User-Mode-Emulator

## Durchgeführte Schritte

### 1. Installation der benötigten Pakete
```bash
sudo apt update
sudo apt install -y gcc-arm-linux-gnueabi qemu-system-arm qemu-user-static
```

### 2. Erstellung des C-Programms
```c
#include <stdio.h>

int main() {
    printf("Hello, ARM World!\n");
    return 0;
}
```

### 3. Cross-Compilation
```bash
# Dynamische Kompilierung
arm-linux-gnueabi-gcc hello_arm.c -o hello_arm

# Statische Kompilierung (für einfache Ausführung)
arm-linux-gnueabi-gcc -static hello_arm.c -o hello_arm_static
```

### 4. Verifikation der Architektur
```bash
file hello_arm
# Output: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked
```

### 5. Ausführung mit QEMU User Mode
```bash
qemu-arm-static hello_arm_static
# Output: Hello, ARM World!
```

## Testergebnisse
✓ ARM Cross-Compiler erfolgreich installiert
✓ C-Programm erfolgreich kompiliert
✓ ARM-Binärdatei erstellt
✓ Programm erfolgreich mit QEMU ausgeführt
✓ Ausgabe: "Hello, ARM World!"

## Verwendung

### Schneller Test
```bash
./test_cross_compile.sh
```

### Vollständige QEMU-System-Emulation
```bash
./start_qemu_kernel.sh
```

## Aufgabenstatus
✅ **Komplett erfolgreich gelöst**

Alle Schritte der ursprünglichen Aufgabe wurden erfolgreich durchgeführt:
1. ✅ C-Programm erstellt
2. ✅ Cross-Compilation für ARM
3. ✅ ARM-Emulationsumgebung eingerichtet
4. ✅ Programm erfolgreich auf ARM-Emulation ausgeführt
5. ✅ Korrekte Ausgabe verifiziert
