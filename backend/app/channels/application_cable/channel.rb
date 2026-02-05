# frozen_string_literal: true

module ApplicationCable
  # Base channel class that all channels inherit from.
  # This is like a base controller for WebSockets.
  class Channel < ActionCable::Channel::Base
  end
end
