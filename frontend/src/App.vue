<!--
  COLLABORATIVE WHITEBOARD - Clean CircuitVerse-inspired UI
  Only includes working features
-->
<template>
  <div id="app">
    <!-- Top Navbar -->
    <nav class="navbar">
      <div class="navbar-left">
        <span class="logo">⚡ Whiteboard</span>
      </div>
      <div class="navbar-center">
        <span class="project-title">Room: {{ roomId }}</span>
      </div>
      <div class="navbar-right">
        <span class="user-count">👥 {{ users.length }} online</span>
      </div>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Left Sidebar - Tools -->
      <aside class="sidebar-left">
        <div class="panel">
          <div class="panel-header">TOOLS</div>
          <div class="panel-content">
            <div
              class="tool"
              :class="{ active: mode === 'draw' }"
              @click="mode = 'draw'"
            >
              ▢ Draw Rectangle
            </div>
            <div
              class="tool"
              :class="{ active: mode === 'select' }"
              @click="mode = 'select'"
            >
              ↖ Select
            </div>
            <div
              class="tool"
              :class="{ disabled: !selectedId }"
              @click="deleteSelected"
            >
              🗑 Delete Selected
            </div>

            <div class="color-row">
              <span>Color:</span>
              <input type="color" v-model="color" />
            </div>
          </div>
        </div>
      </aside>

      <!-- Center - Canvas -->
      <div class="canvas-container">
        <canvas
          ref="canvas"
          @mousedown="onMouseDown"
          @mousemove="onMouseMove"
          @mouseup="onMouseUp"
        />
      </div>

      <!-- Right Sidebar - Properties -->
      <aside class="sidebar-right">
        <div class="panel">
          <div class="panel-header">PROPERTIES</div>
          <div class="panel-content">
            <div class="prop-row">
              <span class="label">Shapes:</span>
              <span class="value">{{ shapes.length }}</span>
            </div>
            <div class="prop-row">
              <span class="label">Selected:</span>
              <span class="value">{{ selectedId ? "Yes" : "None" }}</span>
            </div>
          </div>
        </div>

        <div class="panel">
          <div class="panel-header">ONLINE USERS</div>
          <div class="panel-content">
            <div v-for="user in users" :key="user.id" class="user-item">
              <span class="dot" :style="{ background: user.color }"></span>
              {{ user.name }}
            </div>
            <div v-if="users.length === 0" class="empty">No users yet</div>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";
import { createConsumer } from "@rails/actioncable";

const roomId = "demo";
const canvas = ref(null);
const mode = ref("draw");
const color = ref("#3b82f6");
const shapes = ref([]);
const users = ref([]);
const selectedId = ref(null);

let ctx = null;
let isDrawing = false;
let startX = 0,
  startY = 0;
let subscription = null;

onMounted(() => {
  ctx = canvas.value.getContext("2d");
  resizeCanvas();
  window.addEventListener("resize", resizeCanvas);

  const consumer = createConsumer("ws://localhost:3000/cable");
  subscription = consumer.subscriptions.create(
    { channel: "WhiteboardChannel", room: roomId },
    {
      received(data) {
        handleMessage(data);
      },
    },
  );
});

function resizeCanvas() {
  const container = canvas.value.parentElement;
  canvas.value.width = container.clientWidth;
  canvas.value.height = container.clientHeight;
  render();
}

function handleMessage(data) {
  if (data.type === "users") users.value = data.users;
  else if (
    data.type === "user_joined" &&
    !users.value.find((u) => u.id === data.user.id)
  ) {
    users.value.push(data.user);
  } else if (data.type === "user_left")
    users.value = users.value.filter((u) => u.id !== data.user_id);
  else if (data.type === "shape") {
    if (
      data.op === "create" &&
      !shapes.value.find((s) => s.id === data.shape.id)
    ) {
      shapes.value.push(data.shape);
    } else if (data.op === "delete") {
      shapes.value = shapes.value.filter((s) => s.id !== data.shape.id);
    }
    render();
  }
}

function sendShape(op, shape) {
  subscription.perform("shape", { op, shape });
}

function onMouseDown(e) {
  const { x, y } = getPos(e);
  if (mode.value === "draw") {
    isDrawing = true;
    startX = x;
    startY = y;
  } else {
    selectedId.value = findShapeAt(x, y)?.id || null;
    render();
  }
}

function onMouseMove(e) {
  if (!isDrawing) return;
  const { x, y } = getPos(e);
  render();
  ctx.strokeStyle = color.value;
  ctx.lineWidth = 2;
  ctx.strokeRect(startX, startY, x - startX, y - startY);
}

function onMouseUp(e) {
  if (!isDrawing) return;
  isDrawing = false;
  const { x, y } = getPos(e);
  const w = x - startX,
    h = y - startY;
  if (Math.abs(w) > 10 && Math.abs(h) > 10) {
    const shape = {
      id: crypto.randomUUID(),
      x: Math.min(startX, x),
      y: Math.min(startY, y),
      width: Math.abs(w),
      height: Math.abs(h),
      color: color.value,
    };
    shapes.value.push(shape);
    sendShape("create", shape);
  }
  render();
}

function deleteSelected() {
  if (!selectedId.value) return;
  sendShape("delete", { id: selectedId.value });
  shapes.value = shapes.value.filter((s) => s.id !== selectedId.value);
  selectedId.value = null;
  render();
}

function getPos(e) {
  const rect = canvas.value.getBoundingClientRect();
  return { x: e.clientX - rect.left, y: e.clientY - rect.top };
}

function findShapeAt(x, y) {
  return shapes.value
    .slice()
    .reverse()
    .find(
      (s) => x >= s.x && x <= s.x + s.width && y >= s.y && y <= s.y + s.height,
    );
}

function render() {
  if (!ctx) return;
  const c = canvas.value;
  ctx.fillStyle = "#e8e8e8";
  ctx.fillRect(0, 0, c.width, c.height);

  // Grid dots
  ctx.fillStyle = "#ccc";
  for (let x = 0; x < c.width; x += 15) {
    for (let y = 0; y < c.height; y += 15) {
      ctx.fillRect(x, y, 1, 1);
    }
  }

  shapes.value.forEach((s) => {
    ctx.fillStyle = s.color + "30";
    ctx.fillRect(s.x, s.y, s.width, s.height);
    ctx.strokeStyle = s.color;
    ctx.lineWidth = s.id === selectedId.value ? 3 : 2;
    ctx.strokeRect(s.x, s.y, s.width, s.height);
  });
}

watch(shapes, render, { deep: true });
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
body {
  font-family: -apple-system, sans-serif;
}
#app {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 40px;
  background: #333;
  color: #fff;
  padding: 0 15px;
}
.logo {
  font-weight: bold;
}
.project-title {
  background: #444;
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 13px;
}
.user-count {
  color: #4ade80;
  font-size: 13px;
}

.main-content {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.sidebar-left,
.sidebar-right {
  width: 180px;
  background: #f5f5f5;
  border: 1px solid #ddd;
}
.panel-header {
  background: #555;
  color: #fff;
  padding: 8px 12px;
  font-size: 11px;
  font-weight: bold;
}
.panel-content {
  padding: 12px;
}

.tool {
  padding: 10px;
  cursor: pointer;
  border-radius: 4px;
  margin-bottom: 5px;
  font-size: 13px;
}
.tool:hover {
  background: #e0e0e0;
}
.tool.active {
  background: #c8e0ff;
}
.tool.disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.color-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 15px;
  font-size: 13px;
}
.color-row input {
  width: 40px;
  height: 30px;
  border: none;
  cursor: pointer;
}

.canvas-container {
  flex: 1;
  background: #e8e8e8;
}
canvas {
  width: 100%;
  height: 100%;
  cursor: crosshair;
}

.prop-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 12px;
}
.label {
  color: #666;
}
.value {
  font-weight: bold;
}

.user-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px 0;
  font-size: 12px;
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.empty {
  color: #999;
  font-size: 12px;
  font-style: italic;
}
</style>
