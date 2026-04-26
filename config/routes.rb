Rails.application.routes.draw do
  # PWA routes (must be public, before auth)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token
  resources :tasks, except: [ :index ] do
    resources :time_entries, only: [ :create, :destroy ]
  end
  resources :inbox, only: [ :index ]
  resources :dashboard, only: [ :index ]
  resources :history, only: [ :index ]
  resources :metrics, only: [ :index ]
  get "settings", to: "settings#index"
  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboard#index"
end
