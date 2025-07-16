#!/bin/bash
# Testet verschiedene Kernel-Konfigurationen für optimale RT-Performance
# Für Raspberry Pi 5 aarch64

set -e

KERNEL_VERSION="6.15.6"
WORK_DIR="/home/developer/workspace/kernel_build"
KERNEL_DIR="$WORK_DIR/linux-$KERNEL_VERSION"

echo "=== Kernel-Konfigurationstester für RT-Performance ==="

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Fehler: Kernel-Verzeichnis nicht gefunden: $KERNEL_DIR"
    exit 1
fi

cd "$KERNEL_DIR"

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

echo "Teste verschiedene Basis-Konfigurationen..."

# Teste verschiedene defconfigs
test_defconfig() {
    local config_name="$1"
    local description="$2"
    
    echo ""
    echo "=== Teste $config_name ==="
    echo "Beschreibung: $description"
    
    if make $config_name > /dev/null 2>&1; then
        echo "  ✓ $config_name erfolgreich geladen"
        
        # Teste RT-Optionen
        if scripts/config --enable CONFIG_PREEMPT_RT 2>/dev/null; then
            make olddefconfig > /dev/null 2>&1
            if grep -q "CONFIG_PREEMPT_RT=y" .config; then
                echo "  ✓ CONFIG_PREEMPT_RT verfügbar und aktiviert"
                return 0
            else
                echo "  ⚠ CONFIG_PREEMPT_RT verfügbar aber nicht aktiviert"
                return 1
            fi
        else
            echo "  ✗ CONFIG_PREEMPT_RT nicht verfügbar"
            return 1
        fi
    else
        echo "  ✗ $config_name nicht verfügbar"
        return 1
    fi
}

# Teste verschiedene Konfigurationen
configs_to_test=(
    "defconfig:Standard ARM64 Konfiguration"
    "bcm2711_defconfig:Raspberry Pi 4 Konfiguration"
    "bcmrpi3_defconfig:Raspberry Pi 3 Konfiguration"
)

best_config=""
for config_entry in "${configs_to_test[@]}"; do
    config_name="${config_entry%:*}"
    description="${config_entry#*:}"
    
    if test_defconfig "$config_name" "$description"; then
        if [ -z "$best_config" ]; then
            best_config="$config_name"
        fi
    fi
done

echo ""
echo "=== Ergebnis ==="
if [ -n "$best_config" ]; then
    echo "✅ Beste Konfiguration gefunden: $best_config"
    echo ""
    echo "Aktualisiere Build-Skript..."
    
    # Backup des ursprünglichen Skripts
    cp /home/developer/workspace/build_rt_kernel.sh /home/developer/workspace/build_rt_kernel.sh.backup
    
    # Aktualisiere das Build-Skript
    sed -i "s/make defconfig/make $best_config/" /home/developer/workspace/build_rt_kernel.sh
    
    echo "✓ Build-Skript aktualisiert für optimale RT-Konfiguration"
    echo "✓ Backup erstellt: build_rt_kernel.sh.backup"
else
    echo "❌ Keine Konfiguration mit RT-Unterstützung gefunden"
    echo ""
    echo "Empfohlene Alternativen:"
    echo "1. Verwende einen neueren Kernel (> 6.12)"
    echo "2. Aktiviere CONFIG_PREEMPT für bessere Responsivität"
    echo "3. Nutze manuelle Konfiguration mit 'make menuconfig'"
fi

echo ""
echo "=== Manuelle Konfiguration ==="
echo "Für erweiterte Konfiguration:"
echo "  cd $KERNEL_DIR"
echo "  make menuconfig"
echo "  # Navigiere zu: General setup → Preemption Model"

echo ""
echo "=== Aktuelle Konfiguration ==="
echo "Aktuelle Preemption-Einstellungen:"
grep "CONFIG_PREEMPT" .config | grep "=y" | head -5
