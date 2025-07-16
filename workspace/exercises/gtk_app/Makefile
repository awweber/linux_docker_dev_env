# Makefile for GTK Application

# Compiler
CC = gcc

# Application name
TARGET = gtk_app

# Source files
SOURCES = main.c

# Object files
OBJECTS = $(SOURCES:.c=.o)

# GTK flags
CFLAGS = `pkg-config --cflags gtk+-3.0`
LIBS = `pkg-config --libs gtk+-3.0`

# Additional compiler flags
CFLAGS += -Wall -Wextra -std=c99

# Additional linker flags
LDFLAGS = -Wl,--disable-new-dtags -Wl,-rpath=/usr/lib/x86_64-linux-gnu

# Default target
all: $(TARGET)

# Build the application
$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(TARGET) $(LIBS)

# Compile source files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build files
clean:
	rm -f $(OBJECTS) $(TARGET)

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt update
	sudo apt install libgtk-3-dev gcc pkg-config

# Run the application
run: $(TARGET)
	./$(TARGET)

# Run with clean environment
run-clean: $(TARGET)
	env -i DISPLAY=$$DISPLAY WAYLAND_DISPLAY=$$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$$XDG_RUNTIME_DIR PATH=/usr/bin:/bin ./$(TARGET)

# Run with system libraries
run-system: $(TARGET)
	LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu ./$(TARGET)

# Check if running in snap environment
check-env:
	@echo "Checking environment:"
	@echo "SNAP: $${SNAP:-'not set'}"
	@echo "DISPLAY: $${DISPLAY:-'not set'}"
	@echo "WAYLAND_DISPLAY: $${WAYLAND_DISPLAY:-'not set'}"
	@echo "XDG_RUNTIME_DIR: $${XDG_RUNTIME_DIR:-'not set'}"
	@ldd $(TARGET) | grep -E "(libgtk|libpthread)" || echo "Binary not found"

# Build with alternative linker flags
$(TARGET)-alt: $(OBJECTS)
	$(CC) $(OBJECTS) -o $(TARGET)-alt $(LIBS) $(LDFLAGS)

# Debug build
debug: CFLAGS += -g -DDEBUG
debug: $(TARGET)

# Release build
release: CFLAGS += -O2 -DNDEBUG
release: $(TARGET)

# Help
help:
	@echo "Available targets:"
	@echo "  all         - Build the application (default)"
	@echo "  clean       - Remove build files"
	@echo "  run         - Build and run the application"
	@echo "  run-clean   - Run with clean environment (recommended)"
	@echo "  run-system  - Run with system libraries"
	@echo "  check-env   - Check environment and dependencies"
	@echo "  debug       - Build with debug information"
	@echo "  release     - Build optimized release version"
	@echo "  install-deps- Install required dependencies"
	@echo ""
	@echo "Raspberry Pi deployment targets:"
	@echo "  deploy          - Deploy binary and source to Raspberry Pi"
	@echo "  deploy-run      - Deploy and run on Raspberry Pi"
	@echo "  deploy-compile  - Deploy source and compile on Raspberry Pi"
	@echo "  install-deps-rpi- Install GTK dependencies on Raspberry Pi"
	@echo "  check-rpi       - Check Raspberry Pi environment"
	@echo "  run-rpi         - Run application on Raspberry Pi"
	@echo "  stop-rpi        - Stop application on Raspberry Pi"
	@echo "  clean-rpi       - Clean build files on Raspberry Pi"
	@echo "  help            - Show this help message"

# Deployment configuration
DEPLOY_USER = zaschali
DEPLOY_HOST = 192.168.178.49
DEPLOY_PATH = /home/zaschali/Code/velptec/gtk_app

# Cross-compilation for Raspberry Pi (ARM64)
RPI_CC = gcc
RPI_CFLAGS = $(CFLAGS)
RPI_LIBS = $(LIBS)

# Deploy to Raspberry Pi
deploy: $(TARGET)
	@echo "Deploying to Raspberry Pi..."
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "mkdir -p $(DEPLOY_PATH)"
	scp $(TARGET) $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp main.c $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp Makefile $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	@echo "Deployment completed!"

# Deploy and run on Raspberry Pi
deploy-run: deploy
	@echo "Running application on Raspberry Pi..."
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "cd $(DEPLOY_PATH) && make run-clean"

# Deploy source and compile on Raspberry Pi
deploy-compile: 
	@echo "Deploying source code to Raspberry Pi..."
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "mkdir -p $(DEPLOY_PATH)"
	scp main.c $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp Makefile $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	@echo "Compiling on Raspberry Pi..."
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "cd $(DEPLOY_PATH) && make clean && make"
	@echo "Compilation completed on Raspberry Pi!"

# Deploy including run script
deploy-full: $(TARGET)
	@echo "Deploying full application to Raspberry Pi..."
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "mkdir -p $(DEPLOY_PATH)"
	scp $(TARGET) $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp main.c $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp Makefile $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp run_local.sh $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "chmod +x $(DEPLOY_PATH)/run_local.sh"
	@echo "Full deployment completed!"

# Deploy source and compile with run script
deploy-compile-full: 
	@echo "Deploying source code to Raspberry Pi..."
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "mkdir -p $(DEPLOY_PATH)"
	scp main.c $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp Makefile $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	scp run_local.sh $(DEPLOY_USER)@$(DEPLOY_HOST):$(DEPLOY_PATH)/
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "chmod +x $(DEPLOY_PATH)/run_local.sh"
	@echo "Compiling on Raspberry Pi..."
	ssh $(DEPLOY_USER)@$(DEPLOY_HOST) "cd $(DEPLOY_PATH) && make clean && make"
	@echo "Full compilation completed on Raspberry Pi!"

# Run with X11 forwarding (requires X11 forwarding enabled)
run-rpi-x11:
	@echo "Running application on Raspberry Pi with X11 forwarding..."
	ssh -X $(DEPLOY_USER)@$(DEPLOY_HOST) "cd $(DEPLOY_PATH) && DISPLAY=localhost:10.0 ./gtk_app"

# Instructions for running locally on Pi
show-local-instructions:
	@echo "To run the application locally on your Raspberry Pi:"
	@echo "1. Connect keyboard and monitor to your Raspberry Pi"
	@echo "2. Log in to the desktop environment"
	@echo "3. Open a terminal and run:"
	@echo "   cd $(DEPLOY_PATH)"
	@echo "   ./run_local.sh"
	@echo ""
	@echo "OR run directly:"
	@echo "   ./gtk_app"

# Phony targets
.PHONY: all clean run run-clean run-system check-env debug release install-deps help deploy deploy-run deploy-compile install-deps-rpi check-rpi run-rpi stop-rpi clean-rpi deploy deploy-run deploy-compile install-deps-rpi check-rpi run-rpi stop-rpi clean-rpi
