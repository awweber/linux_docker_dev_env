#!/bin/bash
# Start ARM QEMU with Raspberry Pi OS
echo "Starting ARM QEMU emulation..."
echo "Use Ctrl+A then X to exit QEMU"
qemu-system-arm \
    -M versatilepb \
    -cpu arm1176 \
    -m 256 \
    -drive file=../images/raspios-lite.img,format=raw \
    -netdev user,id=net0 \
    -device rtl8139,netdev=net0 \
    -serial stdio \
    -no-reboot
