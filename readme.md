# Collaborative Whiteboard - Minimal Learning Version

A **super simple** real-time whiteboard to learn WebSockets with Vue + Rails.

## 📁 Project Structure (Minimal!)

```
collabrative-whiteboard/
├── backend/                          # Rails API (minimal)
│   ├── app/
│   │   ├── channels/
│   │   │   ├── application_cable/
│   │   │   │   ├── connection.rb     # ← WebSocket connection
│   │   │   │   └── channel.rb
│   │   │   └── whiteboard_channel.rb # ← ALL sync logic here!
│   │   └── controllers/
│   └── config/
│       ├── cable.yml                 # ActionCable config
│       └── initializers/cors.rb      # CORS for Vue
│
├── frontend/                         # Vue 3 (minimal)
│   ├── src/
│   │   ├── App.vue                   # ← EVERYTHING in one file!
│   │   └── main.js
│   └── package.json
│
└── readme.md
```

**Key files to study:**

1. `backend/app/channels/whiteboard_channel.rb` - Server-side WebSocket
2. `frontend/src/App.vue` - Client-side everything

## 🚀 Quick Start

### Terminal 1: Start Rails

```bash
cd backend
bundle exec rails server -p 3000
```

### Terminal 2: Start Vue

```bash
cd frontend
npm run dev
```

### Open Browser

- Go to http://localhost:5173
- Open another browser window to same URL
- Draw in one → appears in the other! 🎉

## 🔑 Key Concepts

### WebSocket Flow

```
Browser A                    Rails Server                    Browser B
    │                             │                              │
    │──── subscribe ─────────────►│                              │
    │                             │◄──── subscribe ──────────────│
    │                             │                              │
    │──── draw shape ────────────►│                              │
    │                             │──── broadcast shape ────────►│
    │◄──── broadcast shape ───────│                              │
```

### ActionCable Structure

- **Connection** = One per browser tab
- **Channel** = Like a "chat room" for messages
- **Subscription** = Browser joins a channel
- **Broadcast** = Send to everyone in channel

## 📚 Files Explained

### `whiteboard_channel.rb` (Server)

```ruby
# When user draws a shape:
def shape(data)
  broadcast({ type: "shape", action: data["action"], shape: data["shape"] })
end
```

### `App.vue` (Client)

```javascript
// Connect to WebSocket
const consumer = createConsumer("ws://localhost:3000/cable");
subscription = consumer.subscriptions.create(
  { channel: "WhiteboardChannel", room: "demo" },
  {
    received(data) {
      handleMessage(data);
    },
  },
);

// Send shape to server
function sendShape(action, shape) {
  subscription.perform("shape", { action, shape });
}
```

## ✅ Features

- Draw rectangles
- Select and delete shapes
- Real-time sync
- See who's online

## ❌ Intentionally Excluded

- No routing (one room)
- No persistence
- No authentication
- No complex patterns
