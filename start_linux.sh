#!/bin/bash

# Linux startup script for WebSocket application
# This script handles virtual environment, dependencies, and server startup

set -e  # Exit on any error

echo "Starting WebSocket Application for Linux..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed or not in PATH"
    print_error "Please install Python 3:"
    print_error "  Ubuntu/Debian: sudo apt install python3 python3-pip python3-venv"
    print_error "  CentOS/RHEL: sudo yum install python3 python3-pip"
    print_error "  Arch: sudo pacman -S python python-pip"
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
print_status "Python version: $PYTHON_VERSION"

if [[ $(echo "$PYTHON_VERSION < 3.8" | bc -l) -eq 1 ]]; then
    print_warning "Python 3.8+ is recommended for optimal performance"
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install core dependencies
print_status "Installing core dependencies..."
pip install -r requirements.txt

# Try to install Linux-specific optimizations (optional)
print_status "Installing Linux-specific optimizations (optional)..."
if pip install -r requirements-linux.txt 2>/dev/null; then
    print_success "Linux optimizations installed successfully"
else
    print_warning "Some Linux optimizations failed to install"
    print_warning "The application will still work with standard dependencies"
    print_warning "For better performance, you may need to install build tools:"
    print_warning "  Ubuntu/Debian: sudo apt install build-essential python3-dev"
    print_warning "  CentOS/RHEL: sudo yum groupinstall 'Development Tools' && sudo yum install python3-devel"
fi

print_success "All dependencies installed"

# Check if port 8000 is available
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    print_warning "Port 8000 is already in use"
    print_warning "You may need to stop the existing service or use a different port"
fi

# Set environment variables for optimal performance
export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1

# Start the application
print_status "Starting WebSocket server..."
print_success "Server will be available at: http://localhost:8000"
print_success "WebSocket endpoint: ws://localhost:8000/ws"
print_status "Press Ctrl+C to stop the server"
echo ""

# Run the Linux-optimized server
python run_linux.py
