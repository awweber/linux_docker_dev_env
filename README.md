# Linux Docker Development Environment

This project provides a comprehensive Docker-based development environment for embedded Linux development, cross-compilation, and QEMU virtualization.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Docker Setup](#docker-setup)
- [Building the Container](#building-the-container)
- [Running the Container](#running-the-container)
- [QEMU Usage](#qemu-usage)
- [Cross-Compilation](#cross-compilation)
- [Available Tools](#available-tools)
- [Directory Structure](#directory-structure)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Overview

This Docker container includes:
- **Development tools**: GCC, G++, Clang, LLVM, GDB, CMake
- **Cross-compilation toolchains**: ARM64, ARMHF, ARM EABI
- **QEMU emulation**: ARM and x86 system emulation
- **Kernel development tools**: Device tree compiler, U-Boot tools
- **Python development environment**: Python 3 with pip and virtual environments

## Prerequisites

Before using this project, ensure you have:
- Docker installed and running
- Sufficient disk space (container image ~2GB)
- Basic knowledge of Linux commands

### Installing Docker

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**After installation, log out and log back in to apply group changes.**

## Docker Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd dev_env
```

### 2. Build the Docker Image

```bash
docker build -t linux-dev-env .
```

This will create a Docker image named `linux-dev-env` with all necessary tools installed.

### 3. Verify the Build

```bash
docker images | grep linux-dev-env
```

## Building the Container

The Dockerfile includes several stages:

1. **Base system setup** (Debian latest)
2. **Development tools installation**
3. **Cross-compilation toolchains**
4. **QEMU and virtualization tools**
5. **User environment configuration**

Build process typically takes 10-15 minutes depending on your internet connection.

## Running the Container

### Basic Container Start

```bash
docker run -it --rm linux-dev-env
```

### Container with Persistent Data

```bash
docker run -it --rm -v $(pwd)/data:/home/dev/data linux-dev-env
```

### Container with Privileged Access (for QEMU)

```bash
docker run -it --rm --privileged -v $(pwd)/data:/home/dev/data linux-dev-env
```

### Container with Network Access

```bash
docker run -it --rm --privileged --network host -v $(pwd)/data:/home/dev/data linux-dev-env
```

## QEMU Usage

### Available QEMU Systems

The container includes several QEMU system emulators:
- `qemu-system-arm` - ARM 32-bit systems
- `qemu-system-aarch64` - ARM 64-bit systems
- `qemu-system-x86_64` - x86 64-bit systems
- `qemu-system-i386` - x86 32-bit systems

### Running ARM Linux with QEMU

#### 1. Using Versatile Platform Board

```bash
# Start QEMU with Versatile PB
qemu-system-arm -M versatilepb \
    -kernel data/kernels/kernel-qemu-4.19.50-buster \
    -dtb data/kernels/versatile-pb.dtb \
    -drive file=data/images/raspios-lite.img,format=raw \
    -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
    -netdev user,id=net0 -device rtl8139,netdev=net0 \
    -nographic
```

#### 2. Using Custom Kernel

```bash
# Boot with custom kernel
qemu-system-arm -M versatilepb \
    -kernel /path/to/your/kernel \
    -initrd /path/to/your/initrd \
    -append "console=ttyAMA0 root=/dev/ram rdinit=/sbin/init" \
    -nographic
```

#### 3. ARM64 System Emulation

```bash
# Boot ARM64 system
qemu-system-aarch64 -M virt \
    -cpu cortex-a57 \
    -kernel /path/to/arm64/kernel \
    -initrd /path/to/arm64/initrd \
    -append "console=ttyAMA0 root=/dev/ram rdinit=/sbin/init" \
    -nographic
```

### QEMU Scripts

The project includes several helper scripts:

#### `data/exercises/cross-compile-c-prog-arm/start_qemu.sh`
```bash
cd data/exercises/cross-compile-c-prog-arm
./start_qemu.sh
```

#### `data/exercises/cross-compile-c-prog-arm/start_qemu_kernel.sh`
```bash
cd data/exercises/cross-compile-c-prog-arm
./start_qemu_kernel.sh
```

## Cross-Compilation

### Available Cross-Compilers

The container includes several cross-compilation toolchains:

#### ARM 32-bit (EABI)
```bash
arm-linux-gnueabi-gcc --version
arm-linux-gnueabi-g++ --version
```

#### ARM 64-bit (AArch64)
```bash
aarch64-linux-gnu-gcc --version
aarch64-linux-gnu-g++ --version
```

#### ARM Hard Float (ARMHF)
```bash
arm-linux-gnueabihf-gcc --version
arm-linux-gnueabihf-g++ --version
```

### Cross-Compilation Examples

#### Compile for ARM 32-bit

```bash
# Compile C program for ARM
arm-linux-gnueabi-gcc -o hello_arm hello.c

# Compile with static linking
arm-linux-gnueabi-gcc -static -o hello_arm_static hello.c

# Check binary architecture
file hello_arm
```

#### Compile for ARM 64-bit

```bash
# Compile C program for ARM64
aarch64-linux-gnu-gcc -o hello_arm64 hello.c

# Compile C++ program for ARM64
aarch64-linux-gnu-g++ -o hello_arm64_cpp hello.cpp
```

### Test Cross-Compiled Programs

```bash
# Test with QEMU user emulation
qemu-arm-static hello_arm
qemu-aarch64-static hello_arm64
```

## Available Tools

### Development Tools
- **GCC**: GNU Compiler Collection
- **G++**: GNU C++ Compiler
- **Clang**: LLVM C/C++ Compiler
- **GDB**: GNU Debugger
- **CMake**: Build system generator

### System Tools
- **Git**: Version control
- **Vim/Nano**: Text editors
- **curl/wget**: Download tools
- **rsync**: File synchronization
- **socat**: Socket utilities

### Kernel Development
- **Device Tree Compiler**: `dtc`
- **U-Boot Tools**: `mkimage`
- **Bison/Flex**: Parser generators
- **bc**: Calculator for kernel builds

### Python Environment
- **Python 3**: Latest Python interpreter
- **pip**: Package manager
- **venv**: Virtual environment support

## Directory Structure

```
dev_env/
├── Dockerfile                   # Container definition
├── README.md                   # This file
├── data/                       # Persistent data directory
│   ├── downloads/              # Downloaded files
│   ├── exercises/              # Programming exercises
│   │   ├── cross-compile-c-prog-arm/
│   │   ├── debugging/
│   │   ├── dvfs/
│   │   ├── energy_efficiency/
│   │   ├── filesystem_management/
│   │   ├── gpio_module/
│   │   ├── gtk_app/
│   │   ├── hello_kernel/
│   │   ├── helloc/
│   │   ├── industrial_controller/
│   │   ├── memory_leak/
│   │   ├── read_gpio/
│   │   ├── realtime_task/
│   │   └── simple_char_device/
│   ├── images/                 # System images
│   │   └── raspios-lite.img
│   ├── kernels/                # Kernel files
│   │   ├── kernel-qemu-4.19.50-buster
│   │   └── versatile-pb.dtb
│   └── rootfs/                 # Root filesystem
└── manuals/                    # Documentation
    ├── Install_zephyr-sdk.md
    ├── KernelModule.md
    ├── QEMU Docker Container Setup.md
    └── qemu.md
```

## Examples

### Example 1: Cross-Compile and Run ARM Program

```bash
# Enter container
docker run -it --rm --privileged -v $(pwd)/data:/home/dev/data linux-dev-env

# Navigate to exercise directory
cd data/exercises/cross-compile-c-prog-arm

# Compile for ARM
arm-linux-gnueabi-gcc -o hello_arm hello_arm.c

# Test with QEMU user emulation
qemu-arm-static hello_arm

# Run in full system emulation
./start_qemu.sh
```

### Example 2: Kernel Module Development

```bash
# Enter container
docker run -it --rm --privileged -v $(pwd)/data:/home/dev/data linux-dev-env

# Navigate to kernel module directory
cd data/exercises/hello_kernel

# Build kernel module
make

# Load module in QEMU environment
# (requires running QEMU system)
```

### Example 3: Debug ARM Program

```bash
# Compile with debug symbols
arm-linux-gnueabi-gcc -g -o hello_arm_debug hello.c

# Debug with GDB
gdb-multiarch hello_arm_debug

# In GDB, set architecture
(gdb) set architecture arm
(gdb) file hello_arm_debug
(gdb) target remote localhost:1234
```

## Troubleshooting

### Common Issues

#### 1. Permission Denied Errors
```bash
# Ensure Docker daemon is running
sudo systemctl start docker

# Check user permissions
sudo usermod -aG docker $USER
# Log out and log back in
```

#### 2. QEMU Audio Warnings
The container sets `QEMU_AUDIO_DRV=none` to suppress audio warnings. If you need audio:
```bash
export QEMU_AUDIO_DRV=pa  # for PulseAudio
export QEMU_AUDIO_DRV=alsa  # for ALSA
```

#### 3. Container Won't Start
```bash
# Check Docker service status
sudo systemctl status docker

# Check available disk space
df -h

# Remove unused containers
docker system prune
```

#### 4. QEMU Networking Issues
```bash
# Run container with network access
docker run -it --rm --privileged --network host linux-dev-env

# Or use specific networking
docker run -it --rm --privileged -p 5555:5555 linux-dev-env
```

### Getting Help

1. **Check container logs**:
   ```bash
   docker logs <container-id>
   ```

2. **Inspect running container**:
   ```bash
   docker exec -it <container-id> /bin/bash
   ```

3. **View system information**:
   ```bash
   # Inside container
   uname -a
   gcc --version
   qemu-system-arm --version
   ```

### Performance Tips

1. **Use ccache for faster compilation**:
   ```bash
   export CC="ccache gcc"
   export CXX="ccache g++"
   ```

2. **Allocate more memory to Docker**:
   - Docker Desktop: Settings → Resources → Memory
   - Linux: No specific limit by default

3. **Use specific base images**:
   - Consider using `debian:bookworm` for specific Debian version
   - Use multi-stage builds for smaller images

## License

This project is provided as-is for educational and development purposes. Check individual tool licenses for specific restrictions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

For questions or issues, please open an issue in the repository.
