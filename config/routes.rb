Rails.application.routes.draw do
  root "dashboard#index"

  get "dashboard/earnings_detail", to: "dashboard#earnings_detail", as: :dashboard_earnings_detail

  resources :trips, only: [:new, :create]
  resources :expenses, only: [:new, :create]
  
  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
