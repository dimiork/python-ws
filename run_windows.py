#!/usr/bin/env python3
"""
Windows-specific runner for the WebSocket application.
This script addresses common Windows deployment issues.
"""

import uvicorn
import sys
import os

def main():
    # Ensure we're in the right directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    print("Starting WebSocket server for Windows...")
    print("Server will be available at: http://localhost:8000")
    print("WebSocket endpoint: ws://localhost:8000/ws")
    print("Press Ctrl+C to stop the server")
    
    try:
        # Windows-specific uvicorn configuration
        uvicorn.run(
            "main:app",
            host="0.0.0.0",
            port=8000,
            reload=False,  # Disable reload for Windows stability
            log_level="info",
            access_log=True,
            # Windows-specific settings
            loop="asyncio",
            http="httptools" if sys.platform == "win32" else "auto"
        )
    except KeyboardInterrupt:
        print("\nServer stopped by user")
    except Exception as e:
        print(f"Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
