#!/bin/bash
# QEMU-Starter für Linux Kernel 6.15.6 mit PREEMPT_RT
# Raspberry Pi 5 Emulation mit ARM64 Virt-Machine

set -e

KERNEL_BUILD_DIR="/home/dev/data/kernel_build"
INSTALL_DIR="$KERNEL_BUILD_DIR/install"
KERNEL_IMAGE="$INSTALL_DIR/boot/Image"
ROOTFS_IMAGE="/home/dev/data/images/raspios-lite.img"

# Überprüfe ob Kernel vorhanden ist
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "Fehler: Kernel-Image nicht gefunden: $KERNEL_IMAGE"
    echo "Führe zuerst das Build-Skript aus: ./build_rt_kernel.sh"
    exit 1
fi

echo "=== Starte QEMU mit RT-Kernel ==="
echo "Kernel: $KERNEL_IMAGE"
echo "Rootfs: $ROOTFS_IMAGE"

cd /home/dev/data

# QEMU Audio-Umgebung konfigurieren
export QEMU_AUDIO_DRV=none

# Parameter für QEMU
QEMU_ARGS=(
    -M virt                                     # ARM64 Virt-Machine (beste Pi 5 Alternative)
    -cpu cortex-a72                            # ARM Cortex-A72 (ähnlich Pi 5)
    -smp 4                                     # 4 CPU-Kerne
    -m 2048                                    # 2GB RAM
    -kernel "$KERNEL_IMAGE"                    # Unser RT-Kernel
    -append "root=/dev/vda2 panic=1 rootfstype=ext4 rw console=ttyAMA0,115200 earlycon=pl011,0x9000000 loglevel=7 preempt=rt"
    -netdev user,id=net0,hostfwd=tcp::2222-:22 # SSH-Weiterleitung
    -device e1000 netdev=net0                  # Netzwerk-Device
    -nographic                                 # Keine grafische Ausgabe
    -serial mon:stdio                          # Serieller Monitor
)

# Wenn Rootfs-Image vorhanden, verwende es
if [ -f "$ROOTFS_IMAGE" ]; then
    QEMU_ARGS+=(-drive "file=$ROOTFS_IMAGE,format=raw,if=virtio")
else
    echo "Warnung: Rootfs-Image nicht gefunden: $ROOTFS_IMAGE"
    echo "Erstelle minimales Initramfs..."
    
    # Erstelle minimales Initramfs für Test
    INITRAMFS_DIR="/tmp/initramfs"
    mkdir -p "$INITRAMFS_DIR"/{bin,sbin,etc,proc,sys,dev,lib,usr/{bin,sbin,lib}}
    
    # Kopiere busybox (falls vorhanden)
    if command -v busybox >/dev/null 2>&1; then
        cp "$(which busybox)" "$INITRAMFS_DIR/bin/"
        chroot "$INITRAMFS_DIR" /bin/busybox --install -s
    fi
    
    # Erstelle init-Skript
    cat > "$INITRAMFS_DIR/init" << 'EOF'
#!/bin/sh
echo "=== RT-Kernel Test-Umgebung ==="
echo "Kernel: $(uname -a)"
echo "RT-Features:"
echo "  - /sys/kernel/realtime: $(cat /sys/kernel/realtime 2>/dev/null || echo 'nicht gefunden')"
echo "  - /proc/sys/kernel/sched_rt_runtime_us: $(cat /proc/sys/kernel/sched_rt_runtime_us 2>/dev/null || echo 'nicht gefunden')"
echo "  - /proc/sys/kernel/sched_rt_period_us: $(cat /proc/sys/kernel/sched_rt_period_us 2>/dev/null || echo 'nicht gefunden')"

# Mount virtueller Dateisysteme
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

echo "Verfügbare RT-Features:"
ls -la /sys/kernel/ | grep -i rt || echo "Keine RT-Features in /sys/kernel/ gefunden"

echo "Starte Shell..."
exec /bin/sh
EOF
    chmod +x "$INITRAMFS_DIR/init"
    
    # Erstelle Initramfs
    cd "$INITRAMFS_DIR"
    find . | cpio -o -H newc | gzip > /tmp/initramfs.cpio.gz
    cd - > /dev/null
    
    QEMU_ARGS+=(-initrd /tmp/initramfs.cpio.gz)
fi

echo "=== QEMU-Kommando ==="
echo "qemu-system-aarch64 ${QEMU_ARGS[*]}"
echo ""
echo "=== Hilfe ==="
echo "- Zum Beenden: Ctrl+A, dann X"
echo "- Zum Monitor: Ctrl+A, dann C"
echo "- SSH (falls Rootfs): ssh -p 2222 pi@localhost"
echo ""
echo "=== RT-Kernel Tests ==="
echo "Im Kernel können Sie folgende Tests ausführen:"
echo "- cat /sys/kernel/realtime"
echo "- cat /proc/sys/kernel/sched_rt_runtime_us"
echo "- cyclictest -t1 -p 80 -n -i 10000 -l 10000"
echo "- hwlatdetect --duration=30"
echo ""

# Starte QEMU
echo "Starte QEMU..."
exec qemu-system-aarch64 "${QEMU_ARGS[@]}"
