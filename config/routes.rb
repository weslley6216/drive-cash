Rails.application.routes.draw do
  root "dashboard#index"

  resources :deliveries, only: [:new, :create]
  
  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
