Klar, Alexander! Ich zeig dir Schritt für Schritt, wie du QEMU in Visual Studio Code einrichtest, um Embedded-Linux- oder FreeRTOS-Projekte zu testen – ganz ohne echte Hardware.

---

### 🛠️ Voraussetzungen

Bevor wir loslegen, brauchst du:

- **Visual Studio Code** (VS Code)
- **QEMU** (z. B. `qemu-system-arm`)
- **GNU Arm Toolchain** (`arm-none-eabi-gcc`, `gdb`, etc.)
- **CMake** und **Make**
- **Python 3** (für Build-Tools wie `west`, falls du mit Zephyr arbeitest)
- Optional: **Zephyr SDK** oder dein eigenes Embedded-Projekt

---

### ⚙️ Schritt-für-Schritt-Anleitung

#### 1. QEMU installieren

Unter Linux:
```bash
sudo apt install qemu-system-arm
```

Unter Windows:
- Lade QEMU von der [offiziellen Seite](https://www.qemu.org/download/) herunter und füge es zu deiner `PATH`-Umgebungsvariable hinzu.

#### 2. VS Code Extensions installieren

- **C/C++** von Microsoft
- **Cortex-Debug** (für ARM-Debugging)
- Optional: **Python**, **CMake Tools**

#### 3. Projektstruktur anlegen

Erstelle ein Projektverzeichnis mit folgendem Aufbau:

```
MyProject/
├── src/
│   └── main.c
├── CMakeLists.txt
├── prj.conf (optional, z. B. für Zephyr)
└── .vscode/
    └── launch.json
```

#### 4. Buildsystem einrichten

Wenn du z. B. mit Zephyr arbeitest:
```bash
west init myproject
cd myproject
west update
west build -b qemu_cortex_m3
```

Oder mit CMake:
```bash
mkdir build && cd build
cmake ..
make
```

#### 5. QEMU starten

```bash
qemu-system-arm -M lm3s6965evb -nographic -kernel build/myproject.elf
```

#### 6. Debugging in VS Code einrichten

In `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug QEMU",
      "type": "cortex-debug",
      "request": "launch",
      "servertype": "qemu",
      "machine": "lm3s6965evb",
      "executable": "${workspaceFolder}/build/myproject.elf"
    }
  ]
}
```

---

Wenn du magst, kann ich dir auch ein Beispielprojekt mit GRUB-Konfiguration und FreeRTOS/Linux-Dualboot für QEMU zusammenstellen – oder dir zeigen, wie du `freertos.bin` und `vmlinuz-embedded` in einem GRUB-Menü auswählbar machst. Wäre das hilfreich?