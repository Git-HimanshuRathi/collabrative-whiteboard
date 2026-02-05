# frozen_string_literal: true

module ApplicationCable
  # Connection handles the WebSocket connection lifecycle.
  # 
  # WHY THIS FILE?
  # When a browser opens a WebSocket, this class:
  # 1. Creates the connection
  # 2. Identifies the user (we generate anonymous IDs)
  # 3. Provides access to user identity across channels
  #
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id, :current_user_name, :current_user_color

    def connect
      # Generate anonymous identity for this connection
      self.current_user_id = SecureRandom.uuid
      self.current_user_name = "User #{current_user_id[0..3]}"
      self.current_user_color = generate_color
      
      logger.info "WebSocket connected: #{current_user_id}"
    end

    def disconnect
      logger.info "WebSocket disconnected: #{current_user_id}"
    end

    private

    def generate_color
      # Generate a nice random color for the user
      colors = %w[#ef4444 #f97316 #eab308 #22c55e #14b8a6 #3b82f6 #8b5cf6 #ec4899]
      colors.sample
    end
  end
end
