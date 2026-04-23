Rails.application.routes.draw do
  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token
  resources :tasks, except: [ :index ] do
    resources :time_entries, only: [ :create, :destroy ]
  end
  resources :inbox, only: [ :index ]
  resources :dashboard, only: [ :index ]
  get "settings", to: "settings#index"
  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboard#index"
end
