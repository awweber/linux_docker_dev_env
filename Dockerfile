FROM debian:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install basic tools
RUN apt-get update && apt-get upgrade -y

# Install development tools and utilities
RUN apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    nano \
    sudo \
    locales \
    ccache \
    cmake \
    gdb \
    socat \
    rsync \
    unzip \
    bc \
    fakeroot \
    debhelper \
    quilt

# Install compiler tools and dependencies
RUN apt-get install -y \
    bison \
    flex \
    libncurses5-dev \
    libssl-dev \
    u-boot-tools \
    device-tree-compiler

# Install Python and related packages
RUN apt-get install -y \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-venv

# Install QEMU and cross-compilation tools
RUN apt-get install -y \
    qemu-system \
    qemu-system-arm \
    qemu-efi \
    qemu-user-static \
    binfmt-support \
    crossbuild-essential-arm64 \
    crossbuild-essential-armhf \
    gcc-arm-linux-gnueabi \
    g++-arm-linux-gnueabi \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu

# Install Clang and LLVM
RUN apt-get install -y \
    clang \
    lld \
    llvm

# Configure locale settings
RUN sed -i '/^# *de_DE.UTF-8 /s/^# *//' /etc/locale.gen && \
    locale-gen
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_ALL=de_DE.UTF-8
# QEMU Audio-Umgebung konfigurieren
ENV QEMU_AUDIO_DRV=none

# Create development user
RUN useradd -m -s /bin/bash dev && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Configure development environment
RUN echo 'echo "GCC Version:" && gcc --version' >> /home/dev/.bashrc && \
    echo 'echo "G++ Version:" && g++ --version' >> /home/dev/.bashrc && \
    echo 'echo "Clang Version:" && clang --version' >> /home/dev/.bashrc && \
    echo 'echo "LLD Version:" && lld --version' >> /home/dev/.bashrc && \
    echo 'echo "LLVM Version:" && llvm-config --version' >> /home/dev/.bashrc && \
    echo 'echo "Python Version:" && python3 --version' >> /home/dev/.bashrc && \
    echo 'echo "CMake Version:" && cmake --version' >> /home/dev/.bashrc && \
    echo 'echo "GDB Version:" && gdb --version' >> /home/dev/.bashrc && \
    echo 'echo "QEMU Version:" && qemu-system-arm --version' >> /home/dev/.bashrc

# Set working directory
WORKDIR /home/dev

# Switch to development user
USER dev

# Set default shell
SHELL ["/bin/bash", "-c"]

# Define persistent data volume
VOLUME ["/home/dev/data"]

# Default command
CMD ["/bin/bash"]