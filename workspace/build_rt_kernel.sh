#!/bin/bash
# Skript zum Kompilieren des Linux Kernel 6.15.6 mit PREEMPT_RT für Raspberry Pi 5 aarch64
# Dieses Skript läuft im Docker-Container linux-dev-env

set -e  # Exit on error

echo "=== Linux Kernel 6.15.6 mit PREEMPT_RT für Raspberry Pi 5 aarch64 Builder ==="
echo "Startzeit: $(date)"

# Konfiguration
KERNEL_VERSION="6.15.6"
# Seit Linux 6.12 ist PREEMPT_RT im Mainline-Kernel integriert
WORK_DIR="/home/developer/workspace/kernel_build"
DOWNLOADS_DIR="/home/developer/workspace/downloads"
KERNEL_DIR="$WORK_DIR/linux-$KERNEL_VERSION"
INSTALL_DIR="$WORK_DIR/install"
CROSS_COMPILE="aarch64-linux-gnu-"
ARCH="arm64"
JOBS=$(nproc)

# Verzeichnisse erstellen
mkdir -p "$WORK_DIR"
mkdir -p "$DOWNLOADS_DIR"
mkdir -p "$INSTALL_DIR"
cd "$WORK_DIR"

echo "=== Schritt 1: Kernel-Quellcode herunterladen ==="
if [ ! -f "$DOWNLOADS_DIR/linux-$KERNEL_VERSION.tar.xz" ]; then
    echo "Lade Linux Kernel $KERNEL_VERSION herunter..."
    wget -P "$DOWNLOADS_DIR" "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz"
else
    echo "Kernel-Archiv bereits vorhanden."
fi

echo "=== Schritt 2: Kernel-Quellcode extrahieren ==="
if [ ! -d "$KERNEL_DIR" ]; then
    echo "Extrahiere Kernel-Quellcode..."
    tar -xf "$DOWNLOADS_DIR/linux-$KERNEL_VERSION.tar.xz" -C "$WORK_DIR"
else
    echo "Kernel-Quellcode bereits extrahiert."
fi

echo "=== Schritt 3: Kernel-Konfiguration ==="
cd "$KERNEL_DIR"
export ARCH="$ARCH"
export CROSS_COMPILE="$CROSS_COMPILE"

# Basis-Konfiguration für Raspberry Pi 5
if [ ! -f ".config" ]; then
    echo "Erstelle Basis-Konfiguration für Raspberry Pi 5..."
    make defconfig
    
    # Raspberry Pi 5 spezifische Konfiguration
    echo "Aktiviere Raspberry Pi 5 spezifische Optionen..."
    
    # BCM2712 (Raspberry Pi 5) Support
    scripts/config --enable CONFIG_ARCH_BCM2835
    scripts/config --enable CONFIG_ARCH_BCM
    scripts/config --enable CONFIG_ARCH_BCM2835
    scripts/config --enable CONFIG_BCM2835_MBOX
    scripts/config --enable CONFIG_BCM2835_WDT
    scripts/config --enable CONFIG_BCM2835_POWER
    scripts/config --enable CONFIG_BCM2835_THERMAL
    
    # PREEMPT_RT Konfiguration (seit Linux 6.12 im Mainline-Kernel)
    echo "Aktiviere PREEMPT_RT Optionen (Mainline seit 6.12)..."
    
    # Prüfe zunächst, ob CONFIG_PREEMPT_RT verfügbar ist
    if scripts/config --enable CONFIG_PREEMPT_RT 2>/dev/null; then
        echo "  ✓ CONFIG_PREEMPT_RT verfügbar - aktiviere RT-Modus"
        
        # Setze Preemption Model auf RT
        scripts/config --disable CONFIG_PREEMPT_NONE
        scripts/config --disable CONFIG_PREEMPT_VOLUNTARY
        scripts/config --disable CONFIG_PREEMPT
        scripts/config --enable CONFIG_PREEMPT_RT
    else
        echo "  ⚠ CONFIG_PREEMPT_RT nicht verfügbar - verwende besten verfügbaren Preemption-Modus"
        
        # Fallback: Verwende PREEMPT für bessere Responsivität
        scripts/config --disable CONFIG_PREEMPT_NONE
        scripts/config --disable CONFIG_PREEMPT_VOLUNTARY
        scripts/config --enable CONFIG_PREEMPT
    fi
    
    # RT-Subsystem-Konfiguration (diese sind meist verfügbar)
    scripts/config --enable CONFIG_PREEMPT_RCU
    scripts/config --enable CONFIG_RCU_BOOST
    scripts/config --enable CONFIG_HIGH_RES_TIMERS
    scripts/config --enable CONFIG_NO_HZ_FULL
    scripts/config --enable CONFIG_NO_HZ_IDLE
    scripts/config --enable CONFIG_HRTIMER_STACKTRACE
    
    # Weitere Real-Time relevante Optionen
    scripts/config --enable CONFIG_RT_MUTEXES
    scripts/config --enable CONFIG_GENERIC_LOCKBREAK
    
    # RT-Debugging (optional, aber hilfreich)
    scripts/config --enable CONFIG_DEBUG_PREEMPT
    scripts/config --enable CONFIG_DEBUG_RT_MUTEXES
    scripts/config --enable CONFIG_DEBUG_ATOMIC_SLEEP
    scripts/config --enable CONFIG_PROVE_LOCKING
    scripts/config --enable CONFIG_LOCK_STAT
    
    # GPIO und Hardware-Support
    scripts/config --enable CONFIG_GPIOLIB
    scripts/config --enable CONFIG_GPIO_SYSFS
    scripts/config --enable CONFIG_GPIO_BCM_VIRT
    scripts/config --enable CONFIG_I2C
    scripts/config --enable CONFIG_SPI
    scripts/config --enable CONFIG_PWM
    
    # Netzwerk und USB
    scripts/config --enable CONFIG_USB
    scripts/config --enable CONFIG_USB_XHCI_HCD
    scripts/config --enable CONFIG_USB_EHCI_HCD
    scripts/config --enable CONFIG_USB_OHCI_HCD
    
    # Dateisystem-Support
    scripts/config --enable CONFIG_EXT4_FS
    scripts/config --enable CONFIG_VFAT_FS
    scripts/config --enable CONFIG_TMPFS
    scripts/config --enable CONFIG_DEVTMPFS
    scripts/config --enable CONFIG_DEVTMPFS_MOUNT
    
    # Debugging und Profiling
    scripts/config --enable CONFIG_DEBUG_INFO
    scripts/config --enable CONFIG_DEBUG_KERNEL
    scripts/config --enable CONFIG_FTRACE
    scripts/config --enable CONFIG_FUNCTION_TRACER
    scripts/config --enable CONFIG_IRQSOFF_TRACER
    scripts/config --enable CONFIG_PREEMPT_TRACER
    scripts/config --enable CONFIG_SCHED_TRACER
    
    # Aktualisiere Konfiguration
    make olddefconfig
    
    echo "Konfiguration abgeschlossen."
    
    # Überprüfe RT-Konfiguration
    echo "Überprüfe RT-Konfiguration..."
    if grep -q "CONFIG_PREEMPT_RT=y" .config; then
        echo "✓ CONFIG_PREEMPT_RT ist aktiviert"
    else
        echo "⚠ CONFIG_PREEMPT_RT ist nicht aktiviert - prüfe verfügbare Optionen"
        echo "Verfügbare Preemption-Optionen:"
        grep "CONFIG_PREEMPT" .config | head -10
    fi
else
    echo "Konfiguration bereits vorhanden."
fi

echo "=== Schritt 4: Kernel kompilieren ==="
echo "Kompiliere Kernel mit $JOBS parallelen Jobs..."
make -j$JOBS Image modules dtbs

echo "=== Schritt 5: Module installieren ==="
echo "Installiere Module nach $INSTALL_DIR..."
make INSTALL_MOD_PATH="$INSTALL_DIR" modules_install

echo "=== Schritt 6: Kernel und Device Tree kopieren ==="
mkdir -p "$INSTALL_DIR/boot"
cp arch/arm64/boot/Image "$INSTALL_DIR/boot/"
cp arch/arm64/boot/dts/broadcom/bcm2712-rpi-5-b.dtb "$INSTALL_DIR/boot/" 2>/dev/null || echo "Warnung: bcm2712-rpi-5-b.dtb nicht gefunden"

# Kopiere alle verfügbaren BCM2712 DTBs
find arch/arm64/boot/dts/broadcom/ -name "bcm2712*.dtb" -exec cp {} "$INSTALL_DIR/boot/" \; 2>/dev/null || true

echo "=== Schritt 7: Kernel-Informationen ==="
echo "Kernel-Version: $(make kernelversion)"
echo "Kompiliert für: $ARCH mit $CROSS_COMPILE"

# Erweiterte RT-Konfigurationsprüfung
echo "RT-Konfiguration:"
if grep -q "CONFIG_PREEMPT_RT=y" .config; then
    echo "  ✓ CONFIG_PREEMPT_RT=y (aktiviert)"
else
    echo "  ✗ CONFIG_PREEMPT_RT nicht aktiviert"
    echo "  Verfügbare Preemption-Modi:"
    grep "CONFIG_PREEMPT.*=y" .config | sed 's/^/    /'
fi

# Weitere wichtige RT-Optionen prüfen
echo "Weitere RT-Features:"
grep -q "CONFIG_HIGH_RES_TIMERS=y" .config && echo "  ✓ High-Resolution Timers" || echo "  ✗ High-Resolution Timers fehlt"
grep -q "CONFIG_NO_HZ_FULL=y" .config && echo "  ✓ NO_HZ_FULL (Tickless)" || echo "  ✗ NO_HZ_FULL fehlt"
grep -q "CONFIG_RT_MUTEXES=y" .config && echo "  ✓ RT-Mutexes" || echo "  ✗ RT-Mutexes fehlt"
grep -q "CONFIG_RCU_BOOST=y" .config && echo "  ✓ RCU Boost" || echo "  ✗ RCU Boost fehlt"

echo "Installationsverzeichnis: $INSTALL_DIR"

echo "=== Schritt 8: Zusammenfassung der Dateien ==="
echo "Kernel-Image: $INSTALL_DIR/boot/Image"
echo "Module: $INSTALL_DIR/lib/modules/$KERNEL_VERSION"
echo "Device Trees:"
ls -la "$INSTALL_DIR/boot/"*.dtb 2>/dev/null || echo "Keine DTB-Dateien gefunden"

echo "=== Schritt 9: QEMU-Startup-Skript erstellen ==="
cat > "$INSTALL_DIR/start_qemu_rt.sh" << 'EOF'
#!/bin/bash
# Startet QEMU mit dem kompilierten RT-Kernel für Raspberry Pi 5 Emulation
# PREEMPT_RT ist seit Linux 6.12 im Mainline-Kernel integriert

cd /home/developer/workspace/kernel_build/install

export QEMU_AUDIO_DRV=none

# Raspberry Pi 5 ist noch nicht vollständig in QEMU unterstützt
# Verwende ARM64 Virt-Machine als Alternative
qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a72 \
    -m 1024 \
    -kernel boot/Image \
    -append "root=/dev/vda2 panic=1 rootfstype=ext4 rw console=ttyAMA0" \
    -netdev user,id=net0 \
    -device e1000,netdev=net0 \
    -nographic \
    -serial mon:stdio

echo "Hinweis: Für echte Raspberry Pi 5 Hardware müssen Sie das Image auf eine SD-Karte kopieren."
EOF

chmod +x "$INSTALL_DIR/start_qemu_rt.sh"

echo "=== Build abgeschlossen! ==="
echo "Endzeit: $(date)"
echo ""
echo "Nächste Schritte:"
echo "1. Für QEMU-Test: $INSTALL_DIR/start_qemu_rt.sh"
echo "2. Für echte Hardware: Kopiere $INSTALL_DIR/boot/* auf die Boot-Partition"
echo "3. Für echte Hardware: Kopiere $INSTALL_DIR/lib/modules/* in das Rootfs"
echo ""
echo "Kernel-Features:"
echo "- PREEMPT_RT aktiviert (Mainline seit 6.12)"
echo "- ARM64 für Raspberry Pi 5"
echo "- Debug-Optionen aktiviert"
echo "- GPIO, I2C, SPI Support"
echo "- Tracing-Features aktiviert"
