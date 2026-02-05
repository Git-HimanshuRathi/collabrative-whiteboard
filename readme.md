# Collaborative Whiteboard with Presence

A real-time collaborative whiteboard where multiple users can draw, move, and delete shapes together. Built as a proof-of-concept for CircuitVerse real-time collaboration.

## 🎯 Features

- **Draw rectangles** on a shared canvas
- **Move & delete shapes** with selection tool
- **Real-time sync** via WebSockets (ActionCable)
- **See who's online** with user list and colored cursors
- **URL-based rooms** — share a link to collaborate

## 🏗️ Project Structure

```
collabrative-whiteboard/
├── backend/                    # Ruby on Rails API
│   ├── app/
│   │   └── channels/
│   │       ├── application_cable/
│   │       │   ├── connection.rb    # WebSocket connection handler
│   │       │   └── channel.rb       # Base channel class
│   │       ├── shape_channel.rb     # Shape CRUD sync
│   │       └── presence_channel.rb  # User tracking & cursors
│   └── config/
│       ├── cable.yml               # ActionCable config
│       └── initializers/cors.rb    # CORS for Vue frontend
│
├── frontend/                   # Vue 3 + Vite
│   ├── src/
│   │   ├── components/
│   │   │   └── WhiteboardCanvas.vue  # Main canvas component
│   │   ├── composables/
│   │   │   ├── useActionCable.js     # WebSocket wrapper
│   │   │   ├── useShapes.js          # Shape state management
│   │   │   └── usePresence.js        # User presence tracking
│   │   ├── views/
│   │   │   ├── HomeView.vue          # Landing page
│   │   │   └── RoomView.vue          # Room wrapper
│   │   ├── router.js                 # Vue Router config
│   │   ├── App.vue
│   │   └── main.js
│   └── package.json
│
└── readme.md
```

## 🚀 Quick Start

### Prerequisites

- Ruby 3.2+
- Node.js 18+
- Xcode Command Line Tools (macOS)

### 1. Start Backend (Rails)

```bash
cd backend
bundle install
rails server -p 3000
```

### 2. Start Frontend (Vue)

```bash
cd frontend
npm install
npm run dev
```

### 3. Open in Browser

- Visit: http://localhost:5173
- Create or join a room
- Open the same room URL in another browser window to test collaboration

## 🧠 Architecture

```
┌─────────────────┐          WebSocket           ┌─────────────────┐
│   Vue Frontend  │ ◄──────────────────────────► │  Rails Backend  │
│   (port 5173)   │        ActionCable           │   (port 3000)   │
└─────────────────┘                              └─────────────────┘
        │                                                │
        ├── WhiteboardCanvas.vue                        ├── ShapeChannel
        ├── useShapes.js                                │   └── create/update/delete
        └── usePresence.js                              └── PresenceChannel
                                                            └── join/leave/cursor
```

## 📡 WebSocket Channels

### ShapeChannel

Syncs shape operations across all users in a room:

- `create` → broadcasts `shape_created`
- `update` → broadcasts `shape_updated`
- `delete` → broadcasts `shape_deleted`

### PresenceChannel

Tracks users and cursors:

- Auto-broadcasts `user_joined` / `user_left`
- `cursor` → broadcasts `cursor_moved`
- Sends `user_list` to new joiners

## 🎨 What This Teaches

| Skill                    | Relevance to CircuitVerse          |
| ------------------------ | ---------------------------------- |
| WebSockets (ActionCable) | Real-time sync backbone            |
| Canvas API               | CircuitVerse simulator uses canvas |
| Operation-based updates  | Same as circuit edits              |
| Presence system          | Avatars, names, cursors            |
| URL-based rooms          | Circuit sessions                   |

## ❌ Intentionally Not Included

- No CRDTs (simple broadcast model)
- No persistence (memory only)
- No authentication
- No permissions
