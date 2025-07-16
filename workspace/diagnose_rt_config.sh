#!/bin/bash
# Diagnoseskript für PREEMPT_RT-Konfiguration
# Überprüft die RT-Konfiguration im Linux Kernel 6.15.6

set -e

KERNEL_VERSION="6.15.6"
WORK_DIR="/home/developer/workspace/kernel_build"
KERNEL_DIR="$WORK_DIR/linux-$KERNEL_VERSION"

echo "=== PREEMPT_RT Konfigurationsdiagnose ==="
echo "Kernel-Version: $KERNEL_VERSION"
echo "Datum: $(date)"

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Fehler: Kernel-Verzeichnis nicht gefunden: $KERNEL_DIR"
    echo "Führe zuerst build_rt_kernel.sh aus."
    exit 1
fi

cd "$KERNEL_DIR"

if [ ! -f ".config" ]; then
    echo "Fehler: Keine Kernel-Konfiguration gefunden."
    echo "Führe zuerst die Kernel-Konfiguration aus."
    exit 1
fi

echo ""
echo "=== Preemption-Modell ==="
echo "Aktuelle Preemption-Konfiguration:"
grep "CONFIG_PREEMPT" .config | grep "=y" | while read line; do
    echo "  ✓ $line"
done

echo ""
echo "=== RT-Features Status ==="

# Hauptfeatures
check_config() {
    local config_name="$1"
    local description="$2"
    
    if grep -q "CONFIG_${config_name}=y" .config; then
        echo "  ✓ CONFIG_$config_name - $description"
    else
        echo "  ✗ CONFIG_$config_name - $description (nicht aktiviert)"
    fi
}

check_config "PREEMPT_RT" "Real-Time Preemption"
check_config "HIGH_RES_TIMERS" "High-Resolution Timers"
check_config "NO_HZ_FULL" "Tickless System (Full)"
check_config "NO_HZ_IDLE" "Tickless System (Idle)"
check_config "RT_MUTEXES" "RT-Mutexes"
check_config "RCU_BOOST" "RCU Priority Boosting"
check_config "PREEMPT_RCU" "Preemptible RCU"

echo ""
echo "=== Debugging-Features ==="
check_config "DEBUG_PREEMPT" "Preemption Debugging"
check_config "DEBUG_RT_MUTEXES" "RT-Mutex Debugging"
check_config "DEBUG_ATOMIC_SLEEP" "Atomic Sleep Debugging"
check_config "PROVE_LOCKING" "Lock Dependency Checking"
check_config "LOCK_STAT" "Lock Statistics"

echo ""
echo "=== Tracing-Features ==="
check_config "FTRACE" "Function Tracer"
check_config "FUNCTION_TRACER" "Function Tracer"
check_config "IRQSOFF_TRACER" "IRQ-off Tracer"
check_config "PREEMPT_TRACER" "Preemption Tracer"
check_config "SCHED_TRACER" "Scheduler Tracer"

echo ""
echo "=== Hardware-spezifische Features ==="
check_config "ARCH_BCM2835" "BCM2835/2712 Architecture"
check_config "GPIOLIB" "GPIO Library"
check_config "I2C" "I2C Bus Support"
check_config "SPI" "SPI Bus Support"

echo ""
echo "=== Kernel-Optionen verfügbar in menuconfig ==="
echo "Für interaktive Konfiguration:"
echo "  cd $KERNEL_DIR"
echo "  make menuconfig"
echo ""
echo "Wichtige Menüpunkte:"
echo "  General setup → Preemption Model"
echo "  General setup → Timers subsystem"
echo "  General setup → RCU Subsystem"
echo "  Kernel hacking → Lock Debugging"
echo "  Kernel hacking → Tracers"

echo ""
echo "=== RT-Kernel-Informationen ==="
if grep -q "CONFIG_PREEMPT_RT=y" .config; then
    echo "✓ Dieser Kernel ist für Real-Time konfiguriert!"
    echo ""
    echo "Nach dem Kompilieren können Sie RT-Features testen mit:"
    echo "  - cat /sys/kernel/realtime (sollte '1' zeigen)"
    echo "  - cat /proc/sys/kernel/sched_rt_runtime_us"
    echo "  - cat /proc/sys/kernel/sched_rt_period_us"
else
    echo "⚠ Dieser Kernel ist NICHT für Real-Time konfiguriert."
    echo ""
    echo "Mögliche Lösungen:"
    echo "1. Prüfe ob CONFIG_PREEMPT_RT in der Kernel-Version verfügbar ist"
    echo "2. Verwende 'make menuconfig' für manuelle Konfiguration"
    echo "3. Prüfe Kernel-Dokumentation für RT-Unterstützung"
fi

echo ""
echo "=== Konfigurationsdatei-Auszug ==="
echo "Alle PREEMPT-bezogenen Optionen:"
grep "CONFIG_PREEMPT" .config | head -20
