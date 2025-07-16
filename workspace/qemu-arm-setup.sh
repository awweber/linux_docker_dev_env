#!/bin/bash
# Dieses Skript richtet die QEMU-Umgebung für ARM-Emulation ein und startet
# ein Raspberry Pi OS Lite Image.
cd /home/developer/workspace || exit
export QEMU_AUDIO_DRV=none

# QEMU mit Init-Parameter starten
qemu-system-arm \
    -M versatilepb \
    -cpu arm1176 \
    -m 256 \
    -kernel kernels/kernel-qemu-4.19.50-buster \
    -dtb kernels/versatile-pb.dtb \
    -drive file=images/raspios-lite.img,format=raw \
    -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
    -netdev user,id=net0 \
    -device e1000,netdev=net0 \
    -nographic