#!/bin/bash

# Script to install build dependencies and Linux optimizations
# Run this if you want the maximum performance optimizations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
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

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    print_error "Cannot detect Linux distribution"
    exit 1
fi

print_status "Detected OS: $OS"

# Install build dependencies based on distribution
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    print_status "Installing build dependencies for Ubuntu/Debian..."
    sudo apt update
    sudo apt install -y build-essential python3-dev libffi-dev
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
    print_status "Installing build dependencies for CentOS/RHEL/Fedora..."
    sudo yum groupinstall -y "Development Tools"
    sudo yum install -y python3-devel libffi-devel
elif [[ "$OS" == *"Arch"* ]]; then
    print_status "Installing build dependencies for Arch Linux..."
    sudo pacman -S --noconfirm base-devel python
else
    print_warning "Unknown distribution. You may need to install build tools manually."
    print_warning "Required packages: build-essential, python3-dev, libffi-dev"
fi

# Install Python optimizations
print_status "Installing Python performance optimizations..."
if pip install -r requirements-linux.txt; then
    print_success "Linux optimizations installed successfully!"
    print_success "Your application will now use high-performance event loops and HTTP parsing."
else
    print_error "Failed to install optimizations. Check the error messages above."
    exit 1
fi

print_success "Installation complete! You can now run ./start_linux.sh for optimal performance."
