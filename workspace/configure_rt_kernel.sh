#!/bin/bash
# Erweiterte Kernel-Konfiguration für PREEMPT_RT auf Raspberry Pi 5
# Dieses Skript konfiguriert den Kernel mit menuconfig für manuelle Anpassungen
# Hinweis: Seit Linux 6.12 ist PREEMPT_RT im Mainline-Kernel integriert

set -e

KERNEL_VERSION="6.15.6"
WORK_DIR="/home/developer/workspace/kernel_build"
KERNEL_DIR="$WORK_DIR/linux-$KERNEL_VERSION"
CROSS_COMPILE="aarch64-linux-gnu-"
ARCH="arm64"

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Fehler: Kernel-Quellcode nicht gefunden. Führe zuerst build_rt_kernel.sh aus."
    exit 1
fi

cd "$KERNEL_DIR"

export ARCH="$ARCH"
export CROSS_COMPILE="$CROSS_COMPILE"

echo "=== Kernel-Konfiguration mit menuconfig ==="
echo "Wichtige Bereiche für PREEMPT_RT (Mainline seit 6.12):"
echo "- General setup → Preemption Model → Fully Preemptible Kernel (Real-Time)"
echo "- General setup → RCU Subsystem → Make RCU boost kthreads real-time priority"
echo "- Kernel hacking → Lock Debugging → RT Mutex debugging"
echo "- Kernel hacking → Tracers → Preemption-off Latency Tracer"
echo ""
echo "Drücke Enter zum Fortfahren..."
read

make menuconfig

echo "=== Konfiguration gespeichert ==="
echo "Zum Kompilieren führe aus: cd $KERNEL_DIR && make -j$(nproc) Image modules dtbs"
