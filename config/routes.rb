Rails.application.routes.draw do
  resources :tasks
  get "up" => "rails/health#show", as: :rails_health_check
  root "tasks#index"
end
