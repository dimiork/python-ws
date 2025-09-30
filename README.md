# WebSocket Chat Application

A simple web application built with FastAPI and JavaScript that demonstrates WebSocket communication.

## Features

- FastAPI backend with WebSocket endpoint at `/ws`
- HTML frontend with real-time WebSocket connection
- Echo messages back to sender
- Broadcast messages to all connected clients
- Modern, responsive UI
- **Windows deployment compatibility**

## Installation

### Linux (Recommended):
```bash
# Easy method - use the startup script (handles optional dependencies gracefully)
./start_linux.sh

# For maximum performance (requires build tools):
./install_linux_optimizations.sh
./start_linux.sh

# Manual method (basic installation)
pip install -r requirements.txt
```

### Mac:
```bash
pip install -r requirements.txt
```

### Windows:
```bash
# Option 1: Use the batch file (recommended)
start_windows.bat

# Option 2: Manual installation
pip install -r requirements.txt
```

## Running the Application

### Linux (Optimized):
```bash
# Option 1: Use the Linux-optimized runner (recommended)
./start_linux.sh

# Option 2: Direct Python execution
python run_linux.py

# Option 3: Standard method
python main.py
```

### Mac:
```bash
python main.py
```

### Windows:
```bash
# Option 1: Use the Windows-specific runner
python run_windows.py

# Option 2: Use the batch file
start_windows.bat

# Option 3: Standard method (may have issues)
python main.py
```

## Production Deployment (Linux)

### Quick Production Setup:
```bash
# Run as root for systemd service setup
sudo ./deploy_linux.sh
```

### Manual Production Setup:

#### Option 1: Generate service file with correct paths
```bash
# 1. Generate service file with your actual directory
./generate_service.sh

# 2. Install the generated service
sudo cp websocket-app-generated.service /etc/systemd/system/websocket-app.service
sudo systemctl daemon-reload
sudo systemctl enable websocket-app
sudo systemctl start websocket-app
```

#### Option 2: Manual service setup
```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Update the service file with your actual directory
sudo sed "s|__APP_DIR__|$(pwd)|g" websocket-app.service > /etc/systemd/system/websocket-app.service
sudo systemctl daemon-reload
sudo systemctl enable websocket-app
sudo systemctl start websocket-app

# 3. Configure nginx (optional)
sudo cp nginx.conf /etc/nginx/sites-available/websocket-app
sudo ln -s /etc/nginx/sites-available/websocket-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Production Management:
```bash
# Check service status
sudo systemctl status websocket-app

# View logs
sudo journalctl -u websocket-app -f

# Restart service
sudo systemctl restart websocket-app

# Stop service
sudo systemctl stop websocket-app
```

## Windows Deployment Troubleshooting

If you encounter WebSocket connection issues on Windows:

1. **Check Windows Firewall**: Ensure port 8000 is allowed
2. **Use the Windows runner**: `python run_windows.py` instead of `python main.py`
3. **Check browser console**: Look for specific error messages
4. **Try different browsers**: Chrome, Firefox, Edge
5. **Check antivirus software**: Some antivirus programs block WebSocket connections

### Common Windows Issues:

- **CORS errors**: Fixed with CORS middleware
- **WebSocket protocol issues**: Fixed with improved URL handling
- **Port binding issues**: Fixed with Windows-specific uvicorn configuration
- **Network adapter issues**: Try using `127.0.0.1` instead of `localhost`

## Usage

- The page will automatically connect to the WebSocket server
- Type a message and press Enter or click Send
- Messages are echoed back to you and broadcast to all connected clients
- You can open multiple browser tabs to see the broadcast functionality
- Check browser console (F12) for detailed connection logs

## API Endpoints

- `GET /` - Serves the HTML page
- `WebSocket /ws` - WebSocket endpoint for real-time communication

## Project Structure

```
.
├── main.py                  # FastAPI application
├── run_windows.py           # Windows-specific runner
├── run_linux.py             # Linux-optimized runner
├── start_windows.bat         # Windows batch file for easy startup
├── start_linux.sh            # Linux startup script
├── deploy_linux.sh           # Linux production deployment script
├── generate_service.sh       # Generate systemd service with correct paths
├── websocket-app.service     # Systemd service template
├── nginx.conf                # Nginx configuration for production
├── requirements.txt          # Python dependencies
├── requirements-linux.txt    # Optional Linux optimizations
├── static/
│   └── index.html           # Frontend HTML page
└── README.md               # This file
```

## Linux-Specific Features

### Performance Optimizations:
- **uvloop**: High-performance event loop (Linux only)
- **httptools**: Fast HTTP parsing
- **Optimized worker configuration**: CPU-aware settings
- **Connection limits**: Prevents resource exhaustion
- **Graceful shutdown**: Proper signal handling

### Production Features:
- **Systemd service**: Auto-start on boot
- **Nginx integration**: Reverse proxy with WebSocket support
- **Security hardening**: Restricted permissions and security headers
- **Logging**: Structured logging with rotation
- **Resource limits**: Prevents system overload

## Troubleshooting

### Linux Dependency Issues

If you encounter errors like "Failed building wheel for uvloop" or "Failed to build httptools":

**This is normal!** These packages are optional optimizations. The application will work fine without them.

#### Quick Fix (Recommended):
```bash
# Just use the basic installation - this includes all necessary dependencies
pip install -r requirements.txt
python main.py
```

**Note:** The `uvicorn[standard]` package already includes `httptools` and `uvloop`, so you get the optimizations automatically!

#### For Maximum Performance:
```bash
# Install build dependencies first
./install_linux_optimizations.sh

# Then run with optimizations
./start_linux.sh
```

#### Manual Build Dependencies:
```bash
# Ubuntu/Debian
sudo apt install build-essential python3-dev libffi-dev

# CentOS/RHEL/Fedora
sudo yum groupinstall "Development Tools"
sudo yum install python3-devel libffi-devel

# Arch Linux
sudo pacman -S base-devel python
```

### Performance Levels:

| Installation Method | Performance | Dependencies |
|-------------------|-------------|--------------|
| `pip install -r requirements.txt` | ✅ **Optimized** | Includes uvloop + httptools via uvicorn[standard] |
| `./start_linux.sh` | ✅ **Optimized** | Same as above with smart detection |
| `./install_linux_optimizations.sh` | ✅ **Maximum** | Additional production tools (gunicorn) |
