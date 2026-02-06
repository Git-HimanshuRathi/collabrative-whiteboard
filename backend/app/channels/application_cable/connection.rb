# WebSocket Connection Handler
# Each browser connection gets a unique user ID and color
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id, :user_name, :user_color

    def connect
      self.user_id = SecureRandom.uuid
      self.user_name = "User #{user_id[0..3]}"
      self.user_color = %w[#ef4444 #22c55e #3b82f6 #eab308 #8b5cf6].sample
      logger.info "Connected: #{user_name}"
    end
  end
end
