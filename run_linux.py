#!/usr/bin/env python3
"""
Linux-optimized runner for the WebSocket application.
This script includes Linux-specific optimizations and configurations.
"""

import uvicorn
import sys
import os
import multiprocessing
import signal
import logging

# Try to import optional Linux optimizations
try:
    import uvloop
    UVLOOP_AVAILABLE = True
    print("uvloop available - using high-performance event loop")
except ImportError:
    UVLOOP_AVAILABLE = False
    print("uvloop not available - using standard asyncio")

try:
    import httptools
    HTTPTOOLS_AVAILABLE = True
    print("httptools available - using fast HTTP parsing")
except ImportError:
    HTTPTOOLS_AVAILABLE = False
    print("httptools not available - using standard HTTP parsing")

def setup_logging():
    """Configure logging for Linux deployment"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('websocket_app.log')
        ]
    )

def signal_handler(signum, frame):
    """Handle shutdown signals gracefully"""
    logging.info(f"Received signal {signum}, shutting down gracefully...")
    sys.exit(0)

def main():
    # Ensure we're in the right directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # Setup logging
    setup_logging()
    logger = logging.getLogger(__name__)
    
    # Register signal handlers for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Get optimal number of workers (CPU cores * 2 + 1)
    cpu_count = multiprocessing.cpu_count()
    workers = min(cpu_count * 2 + 1, 8)  # Cap at 8 workers
    
    logger.info("Starting WebSocket server for Linux...")
    logger.info(f"CPU cores: {cpu_count}, Workers: {workers}")
    logger.info("Server will be available at: http://localhost:8000")
    logger.info("WebSocket endpoint: ws://localhost:8000/ws")
    logger.info("Press Ctrl+C to stop the server")
    
    try:
        # Configure uvicorn with available optimizations
        uvicorn_config = {
            "app": "main:app",
            "host": "0.0.0.0",
            "port": 8000,
            "workers": 1,  # Use 1 worker for WebSocket (they don't work well with multiple workers)
            "reload": False,  # Disable reload for production
            "log_level": "info",
            "access_log": True,
            # WebSocket-specific settings
            "ws_ping_interval": 20,  # Ping interval for WebSocket connections
            "ws_ping_timeout": 10,   # Ping timeout
            # Linux networking optimizations
            "backlog": 2048,  # Increase backlog for better connection handling
            "limit_concurrency": 1000,  # Limit concurrent connections
            "limit_max_requests": 10000,  # Limit requests per worker
        }
        
        # Add optimizations if available
        if UVLOOP_AVAILABLE:
            uvicorn_config["loop"] = "uvloop"
            logger.info("Using uvloop for high-performance event loop")
        else:
            logger.info("Using standard asyncio event loop")
            
        if HTTPTOOLS_AVAILABLE:
            uvicorn_config["http"] = "httptools"
            logger.info("Using httptools for fast HTTP parsing")
        else:
            logger.info("Using standard HTTP parsing")
        
        # Start the server
        uvicorn.run(**uvicorn_config)
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
