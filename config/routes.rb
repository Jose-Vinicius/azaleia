Rails.application.routes.draw do
  resources :tasks
  resources :inbox
  resources :dashboard
  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboard#index"
end
