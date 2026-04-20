Rails.application.routes.draw do
  resources :tasks, except: [ :index ]
  resources :inbox, only: [ :index ]
  resources :dashboard, only: [ :index ]
  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboard#index"
end
