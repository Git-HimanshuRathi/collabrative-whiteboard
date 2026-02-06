Rails.application.routes.draw do
  # Mount ActionCable at /cable
  mount ActionCable.server => "/cable"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end

