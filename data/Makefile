# Makefile für Linux Kernel 6.15.6 mit PREEMPT_RT für Raspberry Pi 5
# Verwendung: make <target>

KERNEL_VERSION = 6.15.6
RT_PATCH_VERSION = 6.15.6-rt5
WORK_DIR = /home/dev/data/kernel_build
DOWNLOADS_DIR = /home/dev/data/downloads
KERNEL_DIR = $(WORK_DIR)/linux-$(KERNEL_VERSION)
INSTALL_DIR = $(WORK_DIR)/install
CROSS_COMPILE = aarch64-linux-gnu-
ARCH = arm64
JOBS = $(shell nproc)

# Export für Kernel-Build
export ARCH CROSS_COMPILE

.PHONY: all clean download patch configure compile install test help

all: download patch configure compile install

help:
	@echo "Verfügbare Targets:"
	@echo "  all        - Kompletter Build-Prozess"
	@echo "  download   - Lade Kernel und RT-Patch herunter"
	@echo "  patch      - Wende PREEMPT_RT Patch an"
	@echo "  configure  - Konfiguriere Kernel"
	@echo "  menuconfig - Interaktive Konfiguration"
	@echo "  compile    - Kompiliere Kernel"
	@echo "  install    - Installiere Module und kopiere Dateien"
	@echo "  test       - Teste Kernel-Konfiguration"
	@echo "  clean      - Räume Build-Verzeichnis auf"
	@echo "  distclean  - Komplette Bereinigung"

download:
	@echo "=== Lade Kernel und RT-Patch herunter ==="
	mkdir -p $(DOWNLOADS_DIR)
	[ -f $(DOWNLOADS_DIR)/linux-$(KERNEL_VERSION).tar.xz ] || \
		wget -P $(DOWNLOADS_DIR) "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$(KERNEL_VERSION).tar.xz"
	[ -f $(DOWNLOADS_DIR)/patch-$(RT_PATCH_VERSION).patch.xz ] || \
		wget -P $(DOWNLOADS_DIR) "https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.15/patch-$(RT_PATCH_VERSION).patch.xz"

extract: download
	@echo "=== Extrahiere Kernel-Quellcode ==="
	mkdir -p $(WORK_DIR)
	[ -d $(KERNEL_DIR) ] || tar -xf $(DOWNLOADS_DIR)/linux-$(KERNEL_VERSION).tar.xz -C $(WORK_DIR)

patch: extract
	@echo "=== Wende PREEMPT_RT Patch an ==="
	cd $(KERNEL_DIR) && \
	if [ ! -f .rt_patch_applied ]; then \
		xzcat $(DOWNLOADS_DIR)/patch-$(RT_PATCH_VERSION).patch.xz | patch -p1 && \
		touch .rt_patch_applied; \
	fi

configure: patch
	@echo "=== Konfiguriere Kernel ==="
	cd $(KERNEL_DIR) && \
	if [ ! -f .config ]; then \
		make defconfig && \
		scripts/config --enable CONFIG_PREEMPT_RT && \
		scripts/config --enable CONFIG_PREEMPT_RT_FULL && \
		scripts/config --disable CONFIG_PREEMPT_VOLUNTARY && \
		scripts/config --disable CONFIG_PREEMPT && \
		scripts/config --enable CONFIG_PREEMPT_RCU && \
		scripts/config --enable CONFIG_RCU_BOOST && \
		scripts/config --enable CONFIG_HIGH_RES_TIMERS && \
		scripts/config --enable CONFIG_NO_HZ_FULL && \
		scripts/config --enable CONFIG_RT_MUTEXES && \
		scripts/config --enable CONFIG_DEBUG_PREEMPT && \
		scripts/config --enable CONFIG_DEBUG_RT_MUTEXES && \
		scripts/config --enable CONFIG_ARCH_BCM2835 && \
		scripts/config --enable CONFIG_GPIOLIB && \
		scripts/config --enable CONFIG_GPIO_SYSFS && \
		scripts/config --enable CONFIG_I2C && \
		scripts/config --enable CONFIG_SPI && \
		scripts/config --enable CONFIG_EXT4_FS && \
		scripts/config --enable CONFIG_VFAT_FS && \
		scripts/config --enable CONFIG_FTRACE && \
		scripts/config --enable CONFIG_FUNCTION_TRACER && \
		scripts/config --enable CONFIG_IRQSOFF_TRACER && \
		scripts/config --enable CONFIG_PREEMPT_TRACER && \
		make olddefconfig; \
	fi

menuconfig: patch
	@echo "=== Interaktive Kernel-Konfiguration ==="
	cd $(KERNEL_DIR) && make menuconfig

compile: configure
	@echo "=== Kompiliere Kernel ==="
	cd $(KERNEL_DIR) && make -j$(JOBS) Image modules dtbs

install: compile
	@echo "=== Installiere Module und kopiere Dateien ==="
	mkdir -p $(INSTALL_DIR)/boot
	cd $(KERNEL_DIR) && \
	make INSTALL_MOD_PATH=$(INSTALL_DIR) modules_install && \
	cp arch/arm64/boot/Image $(INSTALL_DIR)/boot/ && \
	find arch/arm64/boot/dts/broadcom/ -name "bcm2712*.dtb" -exec cp {} $(INSTALL_DIR)/boot/ \; 2>/dev/null || true

test: configure
	@echo "=== Teste Kernel-Konfiguration ==="
	cd $(KERNEL_DIR) && \
	echo "Checking PREEMPT_RT configuration..." && \
	grep -q "CONFIG_PREEMPT_RT=y" .config && echo "✓ PREEMPT_RT aktiviert" || echo "✗ PREEMPT_RT nicht aktiviert" && \
	grep -q "CONFIG_PREEMPT_RT_FULL=y" .config && echo "✓ PREEMPT_RT_FULL aktiviert" || echo "✗ PREEMPT_RT_FULL nicht aktiviert" && \
	grep -q "CONFIG_HIGH_RES_TIMERS=y" .config && echo "✓ High-Resolution Timers aktiviert" || echo "✗ High-Resolution Timers nicht aktiviert" && \
	grep -q "CONFIG_NO_HZ_FULL=y" .config && echo "✓ NO_HZ_FULL aktiviert" || echo "✗ NO_HZ_FULL nicht aktiviert"

clean:
	@echo "=== Räume Build-Verzeichnis auf ==="
	cd $(KERNEL_DIR) && make clean

distclean:
	@echo "=== Komplette Bereinigung ==="
	rm -rf $(WORK_DIR)

info:
	@echo "=== Build-Informationen ==="
	@echo "Kernel Version: $(KERNEL_VERSION)"
	@echo "RT Patch Version: $(RT_PATCH_VERSION)"
	@echo "Architektur: $(ARCH)"
	@echo "Cross Compiler: $(CROSS_COMPILE)"
	@echo "Jobs: $(JOBS)"
	@echo "Arbeitsverzeichnis: $(WORK_DIR)"
	@echo "Installationsverzeichnis: $(INSTALL_DIR)"
	@echo "Kernel-Verzeichnis: $(KERNEL_DIR)"

status:
	@echo "=== Status ==="
	@[ -f $(DOWNLOADS_DIR)/linux-$(KERNEL_VERSION).tar.xz ] && echo "✓ Kernel-Archiv vorhanden" || echo "✗ Kernel-Archiv fehlt"
	@[ -f $(DOWNLOADS_DIR)/patch-$(RT_PATCH_VERSION).patch.xz ] && echo "✓ RT-Patch vorhanden" || echo "✗ RT-Patch fehlt"
	@[ -d $(KERNEL_DIR) ] && echo "✓ Kernel-Quellcode extrahiert" || echo "✗ Kernel-Quellcode nicht extrahiert"
	@[ -f $(KERNEL_DIR)/.rt_patch_applied ] && echo "✓ RT-Patch angewendet" || echo "✗ RT-Patch nicht angewendet"
	@[ -f $(KERNEL_DIR)/.config ] && echo "✓ Kernel konfiguriert" || echo "✗ Kernel nicht konfiguriert"
	@[ -f $(KERNEL_DIR)/arch/arm64/boot/Image ] && echo "✓ Kernel kompiliert" || echo "✗ Kernel nicht kompiliert"
	@[ -d $(INSTALL_DIR) ] && echo "✓ Installation vorhanden" || echo "✗ Installation fehlt"
