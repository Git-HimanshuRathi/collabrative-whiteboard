# Collaborative Whiteboard

A **super simple** real-time whiteboard to learn WebSockets with Vue + Rails.

## 📁 Project Structure

```
collabrative-whiteboard/
├── backend/                          # Rails API
│   ├── app/channels/
│   │   ├── application_cable/
│   │   │   ├── connection.rb         # ← WebSocket connection
│   │   │   └── channel.rb
│   │   └── whiteboard_channel.rb     # ← ALL sync logic here!
│   └── config/
│       ├── cable.yml                 # ActionCable config
│       └── initializers/cors.rb      # CORS for Vue
│
├── frontend/                         # Vue 3
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

---

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

---

## 👤 User Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER OPENS APP                           │
└─────────────────────────────┬───────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. Browser connects to WebSocket (ws://localhost:3000/cable)   │
│  2. Server assigns: User ID, Name, Color                        │
│  3. User joins room "demo" → sees online users                  │
└─────────────────────────────┬───────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DRAW RECTANGLE                             │
│  ─────────────────────────────────────────────────────────────  │
│  1. Click & drag on canvas                                      │
│  2. Shape created locally (instant feedback)                    │
│  3. Shape sent to server via WebSocket                          │
│  4. Server broadcasts to ALL users in room                      │
│  5. Other users receive & render the shape                      │
└─────────────────────────────┬───────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SELECT & DELETE                            │
│  ─────────────────────────────────────────────────────────────  │
│  1. Click "Select" tool                                         │
│  2. Click on a shape → highlights it                            │
│  3. Click "Delete" → removes locally                            │
│  4. Delete action sent to server                                │
│  5. Server broadcasts delete → shape removed for everyone       │
└─────────────────────────────┬───────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      USER LEAVES                                │
│  ─────────────────────────────────────────────────────────────  │
│  1. Browser closes or navigates away                            │
│  2. WebSocket disconnects                                       │
│  3. Server removes user from room                               │
│  4. Server broadcasts "user_left" to remaining users            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔌 WebSocket Flow

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

### ActionCable Concepts

- **Connection** = One per browser tab
- **Channel** = Like a "chat room" for messages
- **Subscription** = Browser joins a channel
- **Broadcast** = Send to everyone in channel
