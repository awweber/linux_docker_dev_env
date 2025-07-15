#!/bin/bash
# Simple ARM QEMU with existing kernel
echo "Starting ARM QEMU emulation with existing kernel..."
echo "Use Ctrl+A then X to exit QEMU"
qemu-system-arm \
    -M versatilepb \
    -cpu arm1176 \
    -m 256 \
    -kernel ../kernels/kernel-qemu-4.19.50-buster \
    -dtb ../kernels/versatile-pb.dtb \
    -drive file=../images/raspios-lite.img,format=raw \
    -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
    -netdev user,id=net0 \
    -device rtl8139,netdev=net0 \
    -serial stdio \
    -no-reboot
