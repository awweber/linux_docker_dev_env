Die Installation des Zephyr SDK ist ziemlich unkompliziert – ich zeig dir, wie’s geht! 🛠️

---

### 💻 Schritt-für-Schritt: Zephyr SDK unter Linux installieren

#### 1. **SDK herunterladen**
Lade das aktuelle SDK von der offiziellen GitHub-Seite herunter:
```bash
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.2/zephyr-sdk-0.17.2_linux-x86_64.tar.xz
```

#### 2. **Archiv entpacken**
```bash
tar xvf zephyr-sdk-0.17.2_linux-x86_64.tar.xz
cd zephyr-sdk-0.17.2
```

#### 3. **Setup-Skript ausführen**
```bash
./setup.sh
```
Das Skript installiert Toolchains, QEMU, OpenOCD und registriert das SDK für CMake.

#### 4. **udev-Regeln installieren (optional, aber empfohlen)**
Damit du Boards ohne `sudo` flashen kannst:
```bash
sudo cp sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
sudo udevadm control --reload
```

---

### 🪟 Unter Windows?

1. Lade das `.7z`-Archiv von [GitHub](https://github.com/zephyrproject-rtos/sdk-ng/releases) herunter.
2. Entpacke es z. B. nach `C:\zephyr-sdk-0.17.2`
3. Öffne `cmd.exe`, wechsle ins SDK-Verzeichnis und führe aus:
   ```cmd
   setup.cmd
   ```

---

### 🧭 Nach der Installation

Damit Zephyr das SDK erkennt, setze die Umgebungsvariable:
```bash
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR=$HOME/zephyr-sdk-0.17.2
```
Du kannst das auch in deine `.bashrc` oder `.zshrc` eintragen.

---

Wenn du willst, kann ich dir auch gleich ein kleines Zephyr-Projekt zeigen, das du mit dem SDK bauen und in QEMU starten kannst. Lust drauf?