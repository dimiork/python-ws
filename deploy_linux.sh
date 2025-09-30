#!/bin/bash

# Production deployment script for Linux
# This script sets up the application as a systemd service

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

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Get the current directory
APP_DIR=$(pwd)
APP_USER="www-data"
SERVICE_NAME="websocket-app"

print_status "Deploying WebSocket application to production..."
print_status "Application directory: $APP_DIR"

# Create application user if it doesn't exist
if ! id "$APP_USER" &>/dev/null; then
    print_status "Creating user $APP_USER..."
    useradd --system --no-create-home --shell /bin/false $APP_USER
fi

# Set proper permissions
print_status "Setting up permissions..."
chown -R $APP_USER:$APP_USER $APP_DIR
chmod +x $APP_DIR/start_linux.sh
chmod +x $APP_DIR/run_linux.py

# Update systemd service file with correct paths
print_status "Configuring systemd service..."
sed "s|/path/to/your/websocket-app|$APP_DIR|g" websocket-app.service > /etc/systemd/system/$SERVICE_NAME.service

# Reload systemd and enable service
print_status "Enabling systemd service..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME

print_success "Deployment completed!"
print_status "To start the service: sudo systemctl start $SERVICE_NAME"
print_status "To check status: sudo systemctl status $SERVICE_NAME"
print_status "To view logs: sudo journalctl -u $SERVICE_NAME -f"
print_status "To stop the service: sudo systemctl stop $SERVICE_NAME"

# Ask if user wants to start the service now
read -p "Do you want to start the service now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting service..."
    systemctl start $SERVICE_NAME
    sleep 2
    systemctl status $SERVICE_NAME --no-pager
    print_success "Service started! Application is available at http://localhost:8000"
fi
