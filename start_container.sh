#!/bin/bash

# Linux Docker Development Environment Startup Script
# This script starts the container with privileged access for QEMU emulation

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
CONTAINER_NAME="linux-dev-env"
IMAGE_NAME="linux-dev-env"
WORKSPACE_DIR="$(pwd)"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running or you don't have permissions"
        print_info "Try: sudo systemctl start docker"
        print_info "Or add your user to docker group: sudo usermod -aG docker \$USER"
        exit 1
    fi
}

# Function to check if image exists
check_image() {
    if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
        print_error "Docker image '$IMAGE_NAME' not found"
        print_info "Please build the image first: docker build -t $IMAGE_NAME ."
        exit 1
    fi
}

# Function to create workspace directory if it doesn't exist
create_workspace_dir() {
    if [ ! -d "$WORKSPACE_DIR/workspace" ]; then
        print_warning "Workspace directory '$WORKSPACE_DIR/workspace' does not exist"
        print_info "Creating workspace directory..."
        mkdir -p "$WORKSPACE_DIR/workspace"
        print_success "Created workspace directory: $WORKSPACE_DIR/workspace"
    fi
}

# Function to stop existing container
stop_existing_container() {
    if docker ps -a --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
        print_info "Stopping existing container '$CONTAINER_NAME'..."
        docker stop "$CONTAINER_NAME" &> /dev/null
        docker rm "$CONTAINER_NAME" &> /dev/null
        print_success "Removed existing container"
    fi
}

# Function to display usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -n, --network       Use host network (--network host)"
    echo "  -p, --persistent    Use persistent container name (not --rm)"
    echo "  -d, --detach        Run container in background"
    echo "  -v, --verbose       Show verbose Docker output"
    echo "  --no-workspace      Don't mount workspace directory"
    echo "  --custom-name NAME  Use custom container name"
    echo ""
    echo "Examples:"
    echo "  $0                  # Start interactive container with workspace volume"
    echo "  $0 -n               # Start with host networking"
    echo "  $0 -p               # Start persistent container"
    echo "  $0 -d               # Start in background"
}

# Parse command line arguments
NETWORK_MODE="default"
PERSISTENT=false
DETACH=false
VERBOSE=false
MOUNT_WORKSPACE=true
CUSTOM_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -n|--network)
            NETWORK_MODE="host"
            shift
            ;;
        -p|--persistent)
            PERSISTENT=true
            shift
            ;;
        -d|--detach)
            DETACH=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --no-workspace)
            MOUNT_WORKSPACE=false
            shift
            ;;
        --no-data)
            MOUNT_WORKSPACE=false
            shift
            ;;
        --custom-name)
            CUSTOM_NAME="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Use custom name if provided
if [ -n "$CUSTOM_NAME" ]; then
    CONTAINER_NAME="$CUSTOM_NAME"
fi

# Main execution
print_info "Starting Linux Docker Development Environment..."

# Pre-flight checks
check_docker
check_image
create_workspace_dir

# Stop existing container if persistent mode
if [ "$PERSISTENT" = true ]; then
    stop_existing_container
fi

# Build Docker command
DOCKER_CMD="docker run"

# Add interactive/TTY flags if not detached
if [ "$DETACH" = false ]; then
    DOCKER_CMD="$DOCKER_CMD -it"
fi

# Add removal flag if not persistent
if [ "$PERSISTENT" = false ]; then
    DOCKER_CMD="$DOCKER_CMD --rm"
else
    DOCKER_CMD="$DOCKER_CMD --name $CONTAINER_NAME"
fi

# Add detach flag if requested
if [ "$DETACH" = true ]; then
    DOCKER_CMD="$DOCKER_CMD -d"
fi

# Add privileged access for QEMU
DOCKER_CMD="$DOCKER_CMD --privileged"

# Add network configuration
if [ "$NETWORK_MODE" = "host" ]; then
    DOCKER_CMD="$DOCKER_CMD --network host"
fi

# Add volume mounts
if [ "$MOUNT_WORKSPACE" = true ]; then
    DOCKER_CMD="$DOCKER_CMD -v $WORKSPACE_DIR/workspace:/home/developer/workspace"
fi

# Add image name
DOCKER_CMD="$DOCKER_CMD $IMAGE_NAME"

# Display configuration
print_info "Container configuration:"
echo "  Image: $IMAGE_NAME"
echo "  Container name: $CONTAINER_NAME"
echo "  Network mode: $NETWORK_MODE"
echo "  Persistent: $PERSISTENT"
echo "  Background: $DETACH"
echo "  Workspace directory: $WORKSPACE_DIR/workspace"
echo "  Project directory: $WORKSPACE_DIR"
echo ""

# Show command if verbose
if [ "$VERBOSE" = true ]; then
    print_info "Docker command: $DOCKER_CMD"
    echo ""
fi

# Execute Docker command
print_info "Starting container..."
if [ "$VERBOSE" = true ]; then
    eval "$DOCKER_CMD"
else
    eval "$DOCKER_CMD" 2>/dev/null
fi

# Check if container started successfully
if [ $? -eq 0 ]; then
    if [ "$DETACH" = true ]; then
        print_success "Container started in background"
        print_info "To attach to container: docker exec -it $CONTAINER_NAME /bin/bash"
        print_info "To stop container: docker stop $CONTAINER_NAME"
    else
        print_success "Container session ended"
    fi
else
    print_error "Failed to start container"
    exit 1
fi
