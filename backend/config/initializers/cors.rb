# frozen_string_literal: true

# CORS Configuration
#
# WHY THIS FILE?
# The Vue frontend runs on http://localhost:5173
# The Rails backend runs on http://localhost:3000
# Browsers block cross-origin requests by default (security).
# This file tells Rails to allow requests from our Vue app.
#
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from Vue dev server
    origins "http://localhost:5173", "http://127.0.0.1:5173"
    
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
