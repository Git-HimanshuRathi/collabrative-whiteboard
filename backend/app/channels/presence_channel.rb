# frozen_string_literal: true

# PresenceChannel tracks who is online in each room.
#
# WHY THIS CHANNEL?
# Users want to see:
# 1. Who else is in their room
# 2. Where other users' cursors are
#
# We use an in-memory store (@@rooms) because:
# - No persistence needed (per requirements)
# - Simple and fast
# - Clears when server restarts (that's fine for POC)
#
class PresenceChannel < ApplicationCable::Channel
  # In-memory storage for room presence
  # Format: { "room_id" => { "user_id" => { name:, color:, cursor: } } }
  @@rooms = {}
  @@mutex = Mutex.new

  def subscribed
    @room_id = params[:room_id]
    
    if @room_id.blank?
      reject
      return
    end

    stream_from stream_name
    
    # Add user to room
    add_user_to_room
    
    # Notify others that user joined
    broadcast_to_room({
      action: "user_joined",
      user: user_data
    })
    
    # Send current user list to the new user
    transmit({
      action: "user_list",
      users: room_users
    })
    
    logger.info "User #{current_user_id} joined presence for room: #{@room_id}"
  end

  def unsubscribed
    return if @room_id.blank?
    
    # Remove user from room
    remove_user_from_room
    
    # Notify others that user left
    broadcast_to_room({
      action: "user_left",
      user_id: current_user_id
    })
    
    logger.info "User #{current_user_id} left presence for room: #{@room_id}"
  end

  # Called when client sends cursor position updates
  def cursor(data)
    update_user_cursor(data["x"], data["y"])
    
    broadcast_to_room({
      action: "cursor_moved",
      user_id: current_user_id,
      cursor: { x: data["x"], y: data["y"] }
    })
  end

  private

  def stream_name
    "presence_room_#{@room_id}"
  end

  def broadcast_to_room(message)
    ActionCable.server.broadcast(stream_name, message)
  end

  def user_data
    {
      id: current_user_id,
      name: current_user_name,
      color: current_user_color,
      cursor: { x: 0, y: 0 }
    }
  end

  def add_user_to_room
    @@mutex.synchronize do
      @@rooms[@room_id] ||= {}
      @@rooms[@room_id][current_user_id] = user_data
    end
  end

  def remove_user_from_room
    @@mutex.synchronize do
      @@rooms[@room_id]&.delete(current_user_id)
      @@rooms.delete(@room_id) if @@rooms[@room_id]&.empty?
    end
  end

  def update_user_cursor(x, y)
    @@mutex.synchronize do
      if @@rooms[@room_id] && @@rooms[@room_id][current_user_id]
        @@rooms[@room_id][current_user_id][:cursor] = { x: x, y: y }
      end
    end
  end

  def room_users
    @@mutex.synchronize do
      (@@rooms[@room_id] || {}).values
    end
  end
end
