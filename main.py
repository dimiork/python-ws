from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import json
import asyncio
from typing import List

app = FastAPI()

# Add CORS middleware for Windows compatibility
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Store active connections
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        print(f"Client connected. Total connections: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        print(f"Client disconnected. Total connections: {len(self.active_connections)}")

    async def send_personal_message(self, message: str, websocket: WebSocket):
        try:
            await websocket.send_text(message)
        except:
            self.disconnect(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections.copy():
            try:
                await connection.send_text(message)
            except:
                self.disconnect(connection)

manager = ConnectionManager()

# Serve static files (HTML, CSS, JS)
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
async def get():
    return FileResponse("static/index.html")

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    try:
        await manager.connect(websocket)
        print(f"WebSocket connection established from {websocket.client}")
    except Exception as e:
        print(f"Failed to accept WebSocket connection: {e}")
        return
    
    try:
        while True:
            # Receive message from client
            data = await websocket.receive_text()
            print(f"Received message: {data}")
            
            try:
                message_data = json.loads(data)
            except json.JSONDecodeError as e:
                print(f"Invalid JSON received: {e}")
                error_response = {
                    "type": "error",
                    "message": "Invalid JSON format",
                    "timestamp": ""
                }
                await manager.send_personal_message(json.dumps(error_response), websocket)
                continue
            
            # Echo the message back to the client
            response = {
                "type": "echo",
                "message": f"Server received: {message_data.get('message', '')}",
                "timestamp": message_data.get('timestamp', '')
            }
            await manager.send_personal_message(json.dumps(response), websocket)
            
            # Broadcast to all connected clients
            broadcast_response = {
                "type": "broadcast",
                "message": f"Broadcast: {message_data.get('message', '')}",
                "timestamp": message_data.get('timestamp', '')
            }
            await manager.broadcast(json.dumps(broadcast_response))
            
    except WebSocketDisconnect:
        print("WebSocket disconnected")
        manager.disconnect(websocket)
    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(websocket)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
