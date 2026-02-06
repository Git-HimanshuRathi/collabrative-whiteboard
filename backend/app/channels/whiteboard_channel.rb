# WhiteboardChannel - Single channel for all whiteboard messages
# Handles: shapes (create/update/delete) + presence (join/leave/cursor)
class WhiteboardChannel < ApplicationCable::Channel
  @@users = {} # { room_id => { user_id => user_data } }

  def subscribed
    @room = params[:room]
    stream_from "whiteboard_#{@room}"
    
    # Add user to room
    @@users[@room] ||= {}
    @@users[@room][user_id] = { id: user_id, name: user_name, color: user_color }
    
    # Tell everyone about new user
    broadcast({ type: "user_joined", user: @@users[@room][user_id] })
    
    # Send current users to new joiner
    transmit({ type: "users", users: @@users[@room].values })
  end

  def unsubscribed
    return unless @room
    @@users[@room]&.delete(user_id)
    broadcast({ type: "user_left", user_id: user_id })
  end

  # Handle shape operations
  def shape(data)
    broadcast({ type: "shape", op: data["op"], shape: data["shape"], user_id: user_id })
  end

  # Handle cursor updates
  def cursor(data)
    broadcast({ type: "cursor", user_id: user_id, x: data["x"], y: data["y"] })
  end

  private

  def broadcast(message)
    ActionCable.server.broadcast("whiteboard_#{@room}", message)
  end
end
