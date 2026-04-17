Rails.application.routes.draw do
  root "dashboard#index"

  get "dashboard/earnings_detail", to: "dashboard#earnings_detail", as: :dashboard_earnings_detail
  get "dashboard/expenses_detail", to: "dashboard#expenses_detail", as: :dashboard_expenses_detail

  resources :expenses, only: %i[new create edit update]
  resources :earnings, only: %i[new create edit update]
  
  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
