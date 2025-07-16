#!/bin/bash
# Überprüft RT-Verfügbarkeit im Linux Kernel 6.15.6
# Testet welche RT-Optionen in der defconfig verfügbar sind

set -e

KERNEL_VERSION="6.15.6"
WORK_DIR="/home/developer/workspace/kernel_build"
KERNEL_DIR="$WORK_DIR/linux-$KERNEL_VERSION"

echo "=== RT-Verfügbarkeitscheck für Linux Kernel $KERNEL_VERSION ==="

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Fehler: Kernel-Verzeichnis nicht gefunden: $KERNEL_DIR"
    echo "Führe zuerst build_rt_kernel.sh aus oder:"
    echo "  cd /home/developer/workspace && ./build_rt_kernel.sh"
    exit 1
fi

cd "$KERNEL_DIR"

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

echo "Erstelle temporäre defconfig..."
make defconfig > /dev/null 2>&1

echo ""
echo "=== Verfügbare RT-Optionen in defconfig ==="

# Prüfe welche RT-Optionen verfügbar sind
echo "Verfügbare PREEMPT-Optionen:"
grep "CONFIG_PREEMPT" .config | while read line; do
    echo "  $line"
done

echo ""
echo "=== Teste RT-Konfiguration ==="

# Teste verschiedene RT-Einstellungen
echo "Teste CONFIG_PREEMPT_RT..."
if scripts/config --enable CONFIG_PREEMPT_RT 2>/dev/null; then
    echo "  ✓ CONFIG_PREEMPT_RT kann aktiviert werden"
else
    echo "  ✗ CONFIG_PREEMPT_RT ist nicht verfügbar"
fi

echo ""
echo "Teste andere RT-Optionen..."
test_config() {
    local config_name="$1"
    local description="$2"
    
    if scripts/config --enable "CONFIG_${config_name}" 2>/dev/null; then
        echo "  ✓ CONFIG_$config_name verfügbar - $description"
    else
        echo "  ✗ CONFIG_$config_name nicht verfügbar - $description"
    fi
}

test_config "HIGH_RES_TIMERS" "High-Resolution Timers"
test_config "NO_HZ_FULL" "Tickless System (Full)"
test_config "RT_MUTEXES" "RT-Mutexes"
test_config "RCU_BOOST" "RCU Priority Boosting"
test_config "PREEMPT_RCU" "Preemptible RCU"

echo ""
echo "=== Kernel-Version-Check ==="
echo "Kernel-Version: $(make kernelversion)"
echo "Erwartete RT-Unterstützung: Ja (seit 6.12)"

# Aktualisiere Konfiguration
echo ""
echo "Aktualisiere Konfiguration..."
make olddefconfig > /dev/null 2>&1

echo ""
echo "=== Finale Konfiguration ==="
echo "Nach olddefconfig verfügbare RT-Optionen:"
grep "CONFIG_PREEMPT.*=y" .config | while read line; do
    echo "  ✓ $line"
done

echo ""
echo "=== Empfehlung ==="
if grep -q "CONFIG_PREEMPT_RT=y" .config; then
    echo "✅ CONFIG_PREEMPT_RT ist verfügbar und aktiviert!"
    echo "Der Kernel sollte RT-Funktionalität unterstützen."
else
    echo "❌ CONFIG_PREEMPT_RT ist nicht aktiviert."
    echo ""
    echo "Mögliche Ursachen:"
    echo "1. CONFIG_PREEMPT_RT ist in dieser Kernel-Version nicht verfügbar"
    echo "2. Abhängigkeiten sind nicht erfüllt"
    echo "3. Architektur-spezifische Einschränkungen"
    echo ""
    echo "Lösungsansätze:"
    echo "1. Verwende 'make menuconfig' für manuelle Konfiguration"
    echo "2. Prüfe Kernel-Dokumentation für RT-Unterstützung"
    echo "3. Verwende einen anderen Kernel-Build (z.B. bcm2711_defconfig)"
fi

echo ""
echo "=== Manuelle Konfiguration ==="
echo "Für interaktive Konfiguration verwende:"
echo "  cd $KERNEL_DIR"
echo "  make menuconfig"
echo "  # Navigiere zu: General setup → Preemption Model"
echo "  # Wähle: Fully Preemptible Kernel (Real-Time)"

# Cleanup
rm -f .config.old
