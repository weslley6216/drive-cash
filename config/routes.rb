Rails.application.routes.draw do
  root "dashboard#index"

  get "dashboard/earnings_detail", to: "dashboard#earnings_detail", as: :dashboard_earnings_detail
  get "dashboard/expenses_detail", to: "dashboard#expenses_detail", as: :dashboard_expenses_detail

  resources :expenses, only: %i[new create edit update destroy]
  resources :earnings, only: %i[new create edit update destroy]
  
  # AI Chat
  scope '/chat', module: nil, as: :chat do
    root to: 'chat#index'
    post 'message', to: 'chat#message', as: :message
    post 'confirm', to: 'chat#confirm', as: :confirm
    delete 'clear', to: 'chat#clear',   as: :clear
  end

  get '/analysis',     to: 'application#coming_soon', as: :analysis
  get '/work_session', to: 'application#coming_soon', as: :work_session
  get '/history',      to: 'history#index',           as: :history
  get '/settings',     to: 'application#coming_soon', as: :settings
  get '/goals',        to: 'application#coming_soon', as: :goals
  get '/vehicle',      to: 'application#coming_soon', as: :vehicle

  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
