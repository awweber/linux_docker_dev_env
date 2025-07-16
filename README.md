# Linux Docker Development Environment

This project provides a comprehensive Docker-based development environment for embedded Linux development, cross-compilation, QEMU virtualization, and **Real-Time Linux Kernel development with PREEMPT_RT**.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Docker Setup](#docker-setup)
- [Building the Container](#building-the-container)
- [Running the Container](#running-the-container)
- [RT-Kernel Development](#rt-kernel-development)
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
- **🚀 RT-Kernel Build System**: Complete toolchain for Linux Kernel 6.15.6 with PREEMPT_RT for Raspberry Pi 5 aarch64

### Real-Time Linux Kernel Features

This environment now includes specialized tools for building and testing Real-Time Linux kernels:

- **Linux Kernel 6.15.6** with PREEMPT_RT patch 6.15.6-rt5
- **Raspberry Pi 5 aarch64** support with BCM2712 chipset
- **Automated build system** with Makefile and shell scripts
- **QEMU testing environment** for RT-kernel validation
- **RT-features test suite** for performance analysis
- **Complete documentation** and troubleshooting guides

## Prerequisites

Before using this project, ensure you have:
- Docker installed and running
- Sufficient disk space (container image ~2GB, kernel build ~4GB additional)
- Basic knowledge of Linux commands
- For RT-Kernel development: stable internet connection for downloads

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

### Quick Start with Helper Script

The project includes a convenient bash script to start the container with optimal settings for QEMU development:

```bash
# Make the script executable (first time only)
chmod +x start_container.sh

# Start container with default settings (privileged access, data volume)
./start_container.sh

# Start with host networking
./start_container.sh -n

# Start in background
./start_container.sh -d

# Start persistent container (not removed on exit)
./start_container.sh -p

# Show all options
./start_container.sh --help
```

**Script features:**
- Automatically checks Docker installation and permissions
- Creates data directory if it doesn't exist
- Includes privileged access for QEMU by default
- Supports various networking and persistence options
- Provides colored output and error handling
- Mounts both data and workspace directories

### Manual Container Commands

#### Basic Container Start

```bash
docker run -it --rm linux-dev-env
```

#### Container with Persistent Data

```bash
docker run -it --rm -v $(pwd)/workspace:/home/developer/workspace linux-dev-env
```

#### Container with Privileged Access (for QEMU)

```bash
docker run -it --rm --privileged -v $(pwd)/workspace:/home/developer/workspace linux-dev-env
```

#### Container with Network Access

```bash
docker run -it --rm --privileged --network host -v $(pwd)/workspace:/home/developer/workspace linux-dev-env
```

## RT-Kernel Development

### 🚀 Quick Start: Real-Time Linux Kernel 6.15.6 with PREEMPT_RT

This section covers building and testing a Real-Time Linux Kernel for Raspberry Pi 5 aarch64.

#### Quick Start RT-Kernel

```bash
# Use the quick start script
./rt_kernel_quickstart.sh

# Or manually:
# 1. Start container
./start_container.sh

# 2. Build RT-Kernel
cd /home/developer/workspace
./build_rt_kernel.sh

# 3. Test in QEMU
./start_qemu_rt.sh

# 4. Test RT-Features
./test_rt_features.sh
```

#### RT-Kernel Features

The RT-Kernel build system provides:

**🔧 Automated Build Process:**
- Downloads Linux Kernel 6.15.6 (PREEMPT_RT integrated since 6.12)
- Cross-compiles for Raspberry Pi 5 aarch64 (BCM2712)
- Configures RT-specific kernel options automatically
- Creates bootable kernel image and modules

**⚡ PREEMPT_RT Configuration:**
- `CONFIG_PREEMPT_RT=y` - Full RT-Preemption
- `CONFIG_HIGH_RES_TIMERS=y` - High-Resolution Timers
- `CONFIG_NO_HZ_FULL=y` - Tickless System
- `CONFIG_RCU_BOOST=y` - RCU Priority Boosting
- `CONFIG_RT_MUTEXES=y` - RT-Mutexes
- Complete debug and tracing support

**🎯 Raspberry Pi 5 Support:**
- BCM2712 chipset support
- GPIO, I2C, SPI hardware support
- Device Tree Blobs for Pi 5
- Optimized for aarch64 architecture

#### RT-Kernel Build Scripts

The environment includes several specialized scripts:

```bash
# Main build script - complete RT-kernel build
./build_rt_kernel.sh

# Interactive kernel configuration
./configure_rt_kernel.sh

# QEMU startup with RT-kernel
./start_qemu_rt.sh

# RT-features test suite
./test_rt_features.sh

# Diagnostic tools
./diagnose_rt_config.sh      # Analyze RT configuration
./check_rt_availability.sh   # Check RT availability
./test_kernel_configs.sh     # Test different kernel configs

# Build automation with Makefile
make help          # Show all available targets
make all           # Complete build process
make status        # Check build status
make clean         # Clean build directory
```

#### RT-Kernel Directory Structure

```
data/
├── build_rt_kernel.sh          # Main build script
├── configure_rt_kernel.sh      # Interactive configuration
├── start_qemu_rt.sh           # QEMU RT-kernel starter
├── test_rt_features.sh        # RT-features test suite
├── Makefile                   # Build automation
├── rt_kernel_quickstart.sh    # Quick start script
├── downloads/                 # Downloaded files
│   └── linux-6.15.6.tar.xz   # Kernel source (RT integrated)
└── kernel_build/              # Build directory
    ├── linux-6.15.6/         # Kernel source
    └── install/               # Installation files
        ├── boot/              # Kernel images & DTBs
        └── lib/modules/       # Kernel modules
```

#### RT-Kernel Testing

**QEMU Testing:**
```bash
# Start RT-kernel in QEMU
./start_qemu_rt.sh

# In QEMU, test RT-features
./test_rt_features.sh

# Manual RT-tests
cat /sys/kernel/realtime        # Check RT-status
cat /proc/sys/kernel/sched_rt_runtime_us  # RT-scheduler settings
```

**Advanced RT-Testing:**
```bash
# Latency testing (if available)
cyclictest -t1 -p 80 -n -i 10000 -l 10000

# Hardware latency detection
hwlatdetect --duration=30

# RT-evaluation suite
rteval --duration=300
```

#### Hardware Installation (Raspberry Pi 5)

**SD-Card Preparation:**
```bash
# Mount SD-card partitions
sudo mount /dev/sdX1 /mnt/boot    # Boot partition
sudo mount /dev/sdX2 /mnt/rootfs  # Root filesystem

# Copy kernel and device trees
sudo cp /home/developer/workspace/kernel_build/install/boot/Image /mnt/boot/kernel_2712.img
sudo cp /home/developer/workspace/kernel_build/install/boot/bcm2712-rpi-5-b.dtb /mnt/boot/

# Install modules
sudo cp -r /home/developer/workspace/kernel_build/install/lib/modules/* /mnt/rootfs/lib/modules/
```

**Boot Configuration:**
```bash
# Edit /mnt/boot/config.txt
kernel=kernel_2712.img
device_tree=bcm2712-rpi-5-b.dtb

# Edit /mnt/boot/cmdline.txt (RT-optimized)
console=serial0,115200 console=tty1 root=PARTUUID=... rootfstype=ext4 elevator=noop rootwait preempt=rt isolcpus=1,2,3 nohz_full=1,2,3 rcu_nocbs=1,2,3
```

#### RT-Kernel Performance Optimization

**CPU Isolation:**
```bash
# Isolate CPUs for RT-tasks
isolcpus=1,2,3 nohz_full=1,2,3 rcu_nocbs=1,2,3
```

**RT-Scheduler Tuning:**
```bash
# Adjust RT-scheduler parameters
echo 950000 > /proc/sys/kernel/sched_rt_runtime_us
echo 1000000 > /proc/sys/kernel/sched_rt_period_us
```

**Memory Locking:**
```bash
# For RT-applications
mlockall(MCL_CURRENT | MCL_FUTURE)
```

### RT-Kernel Troubleshooting

**Build Issues:**
```bash
# Clean build environment
make distclean

# Check cross-compiler
aarch64-linux-gnu-gcc --version

# Verify patch application
grep CONFIG_PREEMPT_RT /home/developer/workspace/kernel_build/linux-6.15.6/.config
```

**QEMU Issues:**
```bash
# Check kernel image
file /home/developer/workspace/kernel_build/install/boot/Image

# Verify RT-features
cat /sys/kernel/realtime  # Should show "1"
```

**Hardware Issues:**
```bash
# Check device tree
dtc -I dtb -O dts /mnt/boot/bcm2712-rpi-5-b.dtb

# Verify modules
ls /lib/modules/6.15.6-rt/
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
├── README.md                   # This file (combined documentation)
├── rt_kernel_quickstart.sh     # Quick start script for RT-kernel
├── start_container.sh          # Container startup script
├── data/                       # Persistent data directory
│   ├── build_rt_kernel.sh      # RT-kernel build script
│   ├── configure_rt_kernel.sh  # Interactive kernel configuration
│   ├── start_qemu_rt.sh        # QEMU RT-kernel starter
│   ├── test_rt_features.sh     # RT-features test suite
│   ├── Makefile                # RT-kernel build automation
│   ├── downloads/              # Downloaded files
│   │   └── linux-6.15.6.tar.xz        # Linux kernel source (RT integrated)
│   ├── kernel_build/           # RT-kernel build directory
│   │   ├── linux-6.15.6/      # Kernel source tree
│   │   └── install/            # Compiled kernel & modules
│   │       ├── boot/           # Kernel images & DTBs
│   │       └── lib/modules/    # Kernel modules
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
│   ├── kernels/                # Legacy kernel files
│   │   ├── kernel-qemu-4.19.50-buster
│   │   └── versatile-pb.dtb
│   └── rootfs/                 # Root filesystem
└── manuals/                    # Documentation
    ├── Install_zephyr-sdk.md
    ├── KernelModule.md
    ├── QEMU Docker Container Setup.md
    └── qemu.md
```

## Command Reference and Explanations

This section provides detailed explanations of the key commands used in this development environment.

### Docker Commands Explained

#### Basic Container Commands

```bash
docker run -it --rm linux-dev-env
```
- `docker run`: Creates and starts a new container
- `-it`: Combines two flags:
  - `-i`: Interactive mode (keeps STDIN open)
  - `-t`: Allocates a pseudo-TTY (terminal)
- `--rm`: Automatically removes the container when it exits
- `linux-dev-env`: The name of the Docker image to run

#### Container with Volume Mounting

```bash
docker run -it --rm -v $(pwd)/workspace:/home/developer/workspace linux-dev-env
```
- `-v $(pwd)/workspace:/home/developer/workspace`: Volume mount
  - `$(pwd)/workspace`: Source directory on host (current directory + /workspace)
  - `:/home/developer/workspace`: Target directory inside container
  - This makes the host's workspace folder accessible inside the container

#### Container with Privileged Access

```bash
docker run -it --rm --privileged -v $(pwd)/workspace:/home/developer/workspace linux-dev-env
```
- `--privileged`: Gives the container extended privileges
  - Required for QEMU system emulation
  - Allows access to host devices and kernel features

#### Container with Network Access

```bash
docker run -it --rm --privileged --network host -v $(pwd)/workspace:/home/developer/workspace linux-dev-env
```
- `--network host`: Uses the host's network stack
  - Container shares the host's network interface
  - Useful for network-intensive applications

### QEMU Commands Explained

#### ARM System Emulation

```bash
qemu-system-arm -M versatilepb \
    -kernel data/kernels/kernel-qemu-4.19.50-buster \
    -dtb data/kernels/versatile-pb.dtb \
    -drive file=data/images/raspios-lite.img,format=raw \
    -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
    -netdev user,id=net0 -device rtl8139,netdev=net0 \
    -nographic
```

**Command breakdown:**
- `qemu-system-arm`: ARM 32-bit system emulator
- `-M versatilepb`: Machine type (Versatile Platform Board)
- `-kernel data/kernels/kernel-qemu-4.19.50-buster`: Kernel file to boot
- `-dtb data/kernels/versatile-pb.dtb`: Device Tree Blob (hardware description)
- `-drive file=data/images/raspios-lite.img,format=raw`: 
  - `file=`: Disk image file path
  - `format=raw`: Disk image format (raw binary)
- `-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw"`: Kernel command line parameters:
  - `root=/dev/sda2`: Root filesystem location
  - `panic=1`: Reboot after 1 second on kernel panic
  - `rootfstype=ext4`: Root filesystem type
  - `rw`: Mount root filesystem as read-write
- `-netdev user,id=net0`: Network backend configuration:
  - `user`: User-mode networking (NAT)
  - `id=net0`: Network device identifier
- `-device rtl8139,netdev=net0`: Network device:
  - `rtl8139`: Realtek RTL8139 network card emulation
  - `netdev=net0`: Connect to network backend net0
- `-nographic`: Run without graphics (console only)

#### ARM64 System Emulation

```bash
qemu-system-aarch64 -M virt \
    -cpu cortex-a57 \
    -kernel /path/to/arm64/kernel \
    -initrd /path/to/arm64/initrd \
    -append "console=ttyAMA0 root=/dev/ram rdinit=/sbin/init" \
    -nographic
```

**Command breakdown:**
- `qemu-system-aarch64`: ARM 64-bit system emulator
- `-M virt`: Virtual machine type (generic ARM64 platform)
- `-cpu cortex-a57`: CPU model to emulate
- `-kernel /path/to/arm64/kernel`: ARM64 kernel file
- `-initrd /path/to/arm64/initrd`: Initial ramdisk
- `-append "console=ttyAMA0 root=/dev/ram rdinit=/sbin/init"`: Kernel parameters:
  - `console=ttyAMA0`: Console device (ARM PrimeCell UART)
  - `root=/dev/ram`: Root filesystem is in RAM
  - `rdinit=/sbin/init`: Init program in ramdisk

### Cross-Compilation Commands Explained

#### ARM 32-bit Compilation

```bash
arm-linux-gnueabi-gcc -o hello_arm hello.c
```
- `arm-linux-gnueabi-gcc`: ARM EABI cross-compiler
  - `arm`: Target architecture
  - `linux`: Target OS
  - `gnueabi`: GNU EABI (Embedded Application Binary Interface)
- `-o hello_arm`: Output file name
- `hello.c`: Source file

#### Static Linking

```bash
arm-linux-gnueabi-gcc -static -o hello_arm_static hello.c
```
- `-static`: Static linking (includes all libraries in the executable)
  - Larger file size but no external dependencies
  - Useful for embedded systems

#### Debug Compilation

```bash
arm-linux-gnueabi-gcc -g -o hello_arm_debug hello.c
```
- `-g`: Include debugging information
  - Adds symbol table and debug info
  - Required for debugging with GDB

### Testing Commands Explained

#### QEMU User Emulation

```bash
qemu-arm-static hello_arm
```
- `qemu-arm-static`: ARM user-space emulator
- `hello_arm`: ARM binary to execute
- Runs ARM binaries on x86 host without full system emulation

#### File Architecture Check

```bash
file hello_arm
```
- `file`: Command to determine file type
- Shows architecture, format, and other binary information
- Example output: "ELF 32-bit LSB executable, ARM, EABI5"

### GDB Debugging Commands Explained

```bash
gdb-multiarch hello_arm_debug
```
- `gdb-multiarch`: GDB with multi-architecture support
- Can debug binaries for different architectures

#### Inside GDB:

```bash
(gdb) set architecture arm
```
- Sets target architecture to ARM

```bash
(gdb) target remote localhost:1234
```
- Connects to remote debugging target
- `localhost:1234`: QEMU's default GDB server port

### Docker Build Command Explained

```bash
docker build -t linux-dev-env .
```
- `docker build`: Build Docker image from Dockerfile
- `-t linux-dev-env`: Tag (name) the image
- `.`: Build context (current directory)

## Examples

### Example 1: RT-Kernel Development Workflow

```bash
# Complete RT-kernel development workflow
./rt_kernel_quickstart.sh

# Or step by step:
# 1. Start container
./start_container.sh

# 2. Navigate to workspace directory
cd /home/developer/workspace

# 3. Build RT-kernel
./build_rt_kernel.sh

# 4. Test in QEMU
./start_qemu_rt.sh

# 5. In QEMU, test RT-features
./test_rt_features.sh

# 6. Manual RT-tests
cat /sys/kernel/realtime
cyclictest -t1 -p 80 -n -i 10000 -l 1000
```

### Example 2: RT-Kernel Configuration and Build

```bash
# Enter container
docker run -it --rm --privileged -v $(pwd)/workspace:/home/developer/workspace linux-dev-env

# Use Makefile for build management
cd /home/developer/workspace

# Check status
make status

# Interactive configuration
make menuconfig

# Build kernel
make compile

# Install modules
make install
```

### Example 3: Cross-Compile and Run ARM Program

```bash
# Enter container
docker run -it --rm --privileged -v $(pwd)/workspace:/home/developer/workspace linux-dev-env

# Navigate to exercise directory
cd workspace/exercises/cross-compile-c-prog-arm

# Compile for ARM
arm-linux-gnueabi-gcc -o hello_arm hello_arm.c

# Test with QEMU user emulation
qemu-arm-static hello_arm

# Run in full system emulation
./start_qemu.sh
```

### Example 4: Kernel Module Development

```bash
# Enter container
docker run -it --rm --privileged -v $(pwd)/workspace:/home/developer/workspace linux-dev-env

# Navigate to kernel module directory
cd workspace/exercises/hello_kernel

# Build kernel module
make

# Load module in QEMU environment
# (requires running QEMU system)
```

### Example 5: Debug ARM Program

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

#### 2. RT-Kernel Build Issues

**Problem**: PREEMPT_RT patch fails to apply
```bash
# Hinweis: Seit Linux 6.12 ist PREEMPT_RT im Mainline-Kernel integriert
# Kein separater Patch erforderlich!

# Lösung: Verwende die neueste Version des Build-Skripts
cd /home/developer/workspace
./build_rt_kernel.sh
```

**Problem**: Cross-compiler not found
```bash
# Solution: Verify cross-compiler installation
aarch64-linux-gnu-gcc --version
# Should show: aarch64-linux-gnu-gcc (Debian...) 
```

**Problem**: Kernel compilation fails
```bash
# Solution: Check for missing dependencies
apt-get update
apt-get install -y build-essential libncurses5-dev libssl-dev

# Check available disk space
df -h /home/developer/workspace
```

#### 3. RT-Kernel QEMU Issues

**Problem**: RT-kernel doesn't boot in QEMU
```bash
# Solution: Check kernel image format
file /home/dev/data/kernel_build/install/boot/Image
# Should show: Linux kernel ARM64 boot executable image

# Check QEMU command
./start_qemu_rt.sh
```

**Problem**: RT-features not available in QEMU
```bash
# Solution: Verify RT-configuration
grep CONFIG_PREEMPT_RT /home/dev/data/kernel_build/linux-6.15.6/.config
# Should show: CONFIG_PREEMPT_RT=y

# Check RT-status in running system
cat /sys/kernel/realtime
# Should show: 1
```

#### 4. Hardware Installation Issues

**Problem**: Raspberry Pi 5 won't boot with RT-kernel
```bash
# Solution: Check boot configuration
# Ensure config.txt has:
kernel=kernel_2712.img
device_tree=bcm2712-rpi-5-b.dtb

# Check cmdline.txt for RT-optimizations
console=serial0,115200 root=PARTUUID=... preempt=rt
```

**Problem**: RT-features not working on hardware
```bash
# Solution: Verify module installation
ls /lib/modules/6.15.6-rt/
# Should show kernel modules

# Check RT-scheduler parameters
cat /proc/sys/kernel/sched_rt_runtime_us
cat /proc/sys/kernel/sched_rt_period_us
```

#### 5. QEMU Audio Warnings
The container sets `QEMU_AUDIO_DRV=none` to suppress audio warnings. If you need audio:
```bash
export QEMU_AUDIO_DRV=pa  # for PulseAudio
export QEMU_AUDIO_DRV=alsa  # for ALSA
```

#### 6. Container Won't Start
```bash
# Check Docker service status
sudo systemctl status docker

# Check available disk space (RT-kernel builds need ~4GB)
df -h

# Remove unused containers
docker system prune
```

#### 7. QEMU Networking Issues
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
   - Docker Desktop: Settings → Resources → Memory (recommend 4GB+ for RT-kernel builds)
   - Linux: No specific limit by default

3. **RT-Kernel build optimization**:
   ```bash
   # Use all available CPU cores
   make -j$(nproc)
   
   # Use faster linker
   export LDFLAGS="-fuse-ld=gold"
   ```

4. **Use specific base images**:
   - Consider using `debian:bookworm` for specific Debian version
   - Use multi-stage builds for smaller images

## Additional Resources

### RT-Kernel Development
- [PREEMPT_RT Wiki](https://wiki.linuxfoundation.org/realtime/start)
- [RT-Tests Tools](https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests)
- [Raspberry Pi Kernel Building](https://www.raspberrypi.org/documentation/linux/kernel/building.md)
- [Linux Real-Time Documentation](https://www.kernel.org/doc/html/latest/locking/rt-mutex.html)

### QEMU Documentation
- [QEMU ARM System Emulation](https://qemu.readthedocs.io/en/latest/system/arm/virt.html)
- [QEMU AArch64 Support](https://qemu.readthedocs.io/en/latest/system/target-arm.html)

### Cross-Compilation
- [ARM64 Cross-Compilation Guide](https://wiki.debian.org/CrossCompiling)
- [Buildroot for Embedded Systems](https://buildroot.org/downloads/manual/manual.html)

## License

This project is provided as-is for educational and development purposes. Individual components follow their respective licenses:
- Linux Kernel: GPL-2.0
- PREEMPT_RT Patch: GPL-2.0
- Docker Scripts: MIT License (see individual files)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly (especially RT-kernel builds)
5. Submit a pull request

### RT-Kernel Contribution Guidelines
- Test RT-kernel builds on both QEMU and hardware
- Verify RT-features work correctly
- Update documentation for any configuration changes
- Include performance benchmarks for RT-improvements

For questions or issues, please open an issue in the repository.
