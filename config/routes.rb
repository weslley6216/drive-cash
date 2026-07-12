Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :registrations, only: %i[new create]
  get '/account', to: 'account#show', as: :account
  resource :profile, only: %i[edit update]
  get '/coming_soon', to: 'application#coming_soon', as: :coming_soon
  get '/auth/:provider/callback', to: 'sessions#oauth_callback'
  get '/auth/failure',            to: 'sessions#oauth_failure'
  root "dashboard#index"

  get "dashboard/earnings_detail", to: "dashboard#earnings_detail", as: :dashboard_earnings_detail
  get "dashboard/expenses_detail", to: "dashboard#expenses_detail", as: :dashboard_expenses_detail

  resources :expenses, only: %i[new create edit update destroy]
  resources :earnings, only: %i[new create edit update destroy]

  get  '/records/new', to: 'records#new',    as: :new_record
  post '/records',     to: 'records#create', as: :records

  scope '/chat', module: nil, as: :chat do
    root to: 'chat#index'
    post 'message', to: 'chat#message', as: :message
    post 'confirm', to: 'chat#confirm', as: :confirm
    post 'cancel',  to: 'chat#cancel_preview', as: :cancel_preview
    delete 'clear', to: 'chat#clear',   as: :clear
  end

  resource :analysis, only: :show, controller: 'analysis'
  get '/history',      to: 'history#index',           as: :history
  resources :goals, only: %i[index new create edit update destroy]
  resources :exports, only: %i[index create show] do
    collection { get :preview }
    member { get :row }
  end
  resource :vehicle, only: %i[show edit update]
  resources :maintenances, only: %i[new create edit update destroy] do
    member { patch :mark_done }
  end
  resources :refuelings, only: %i[index new create edit update destroy]

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "up" => "rails/health#show", as: :rails_health_check
end
