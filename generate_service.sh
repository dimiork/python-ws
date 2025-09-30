#!/bin/bash

# Script to generate systemd service file with correct paths
# Usage: ./generate_service.sh [app_directory]

set -e

# Get the application directory
if [ -n "$1" ]; then
    APP_DIR="$1"
else
    APP_DIR=$(pwd)
fi

# Validate the directory
if [ ! -d "$APP_DIR" ]; then
    echo "Error: Directory $APP_DIR does not exist"
    exit 1
fi

if [ ! -f "$APP_DIR/main.py" ]; then
    echo "Error: $APP_DIR does not appear to be the WebSocket application directory"
    echo "Make sure you're in the correct directory or provide the full path"
    exit 1
fi

echo "Generating systemd service file for: $APP_DIR"

# Generate the service file
cat > websocket-app-generated.service << EOF
[Unit]
Description=WebSocket Chat Application
After=network.target

[Service]
Type=exec
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR
Environment=PATH=$APP_DIR/venv/bin
ExecStart=$APP_DIR/venv/bin/python run_linux.py
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=3
StandardOutput=journal
StandardError=journal
SyslogIdentifier=websocket-app

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$APP_DIR

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

echo "Generated: websocket-app-generated.service"
echo ""
echo "To install the service:"
echo "  sudo cp websocket-app-generated.service /etc/systemd/system/websocket-app.service"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable websocket-app"
echo "  sudo systemctl start websocket-app"
echo ""
echo "To check status:"
echo "  sudo systemctl status websocket-app"
echo "  sudo journalctl -u websocket-app -f"
