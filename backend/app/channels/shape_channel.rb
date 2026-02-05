# frozen_string_literal: true

# ShapeChannel handles real-time shape synchronization.
#
# WHY THIS CHANNEL?
# When a user draws/moves/deletes a shape, we need to:
# 1. Receive the action from that user
# 2. Broadcast it to ALL other users in the same room
#
# STREAM NAME: "shapes_room_#{room_id}"
# This ensures shapes only go to users in the same room.
#
class ShapeChannel < ApplicationCable::Channel
  # Called when client subscribes to this channel
  # Client sends: { channel: "ShapeChannel", room_id: "abc123" }
  def subscribed
    @room_id = params[:room_id]
    
    if @room_id.blank?
      reject
      return
    end

    # Subscribe to room-specific stream
    stream_from stream_name
    logger.info "User #{current_user_id} joined shapes for room: #{@room_id}"
  end

  def unsubscribed
    logger.info "User #{current_user_id} left shapes for room: #{@room_id}"
  end

  # Called when client sends: { action: "create", shape: {...} }
  def create(data)
    shape = data["shape"].merge(
      "user_id" => current_user_id,
      "user_name" => current_user_name
    )
    
    broadcast_to_room({
      action: "shape_created",
      shape: shape
    })
  end

  # Called when client sends: { action: "update", shape: {...} }
  def update(data)
    broadcast_to_room({
      action: "shape_updated",
      shape: data["shape"],
      user_id: current_user_id
    })
  end

  # Called when client sends: { action: "delete", shape_id: "..." }
  def delete(data)
    broadcast_to_room({
      action: "shape_deleted",
      shape_id: data["shape_id"],
      user_id: current_user_id
    })
  end

  private

  def stream_name
    "shapes_room_#{@room_id}"
  end

  def broadcast_to_room(message)
    ActionCable.server.broadcast(stream_name, message)
  end
end
