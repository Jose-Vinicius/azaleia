Rails.application.routes.draw do
  # PWA routes (must be public, before auth)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resource :session

  # Integrations (OAuth)
  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"
  delete "/integrations/:provider", to: "integrations#destroy", as: :integration
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token
  resources :tasks, except: [ :index ] do
    collection do
      get :upcoming
    end
    member do
      delete "purge_image/:image_id", action: :purge_image, as: :purge_image
    end
    resources :time_entries, only: [ :create, :destroy ]
  end
  resources :recurrent_tasks, only: [ :index ]
  resources :notifications, only: [ :index, :create, :update ] do
    collection do
      patch :mark_all_as_read
    end
  end
  resources :inbox, only: [ :index ]
  resources :dashboard, only: [ :index ]
  resources :history, only: [ :index ]
  resources :notes
  resources :projects
  resources :goals
  resources :okrs do
    resources :key_results, only: [ :create, :update, :destroy ]
  end
  get "psychometrics", to: "psychometrics#show", as: :psychometrics
  post "psychometrics/import_eqi", to: "psychometrics#import_eqi", as: :import_eqi_psychometrics
  post "psychometrics/import_mbti", to: "psychometrics#import_mbti", as: :import_mbti_psychometrics
  resources :metrics, only: [ :index ]

  # Assistente IA (Google Gemini)
  get "ai", to: "ai#index", as: :ai_dashboard
  post "ai/analyze_tasks", to: "ai#analyze_tasks", as: :analyze_tasks_ai
  post "ai/suggest_goals", to: "ai#suggest_goals", as: :suggest_goals_ai
  post "ai/generate_smart_fields", to: "ai#generate_smart_fields", as: :generate_smart_fields_ai
  post "ai/accept_goal", to: "ai#accept_goal", as: :accept_goal_ai
  post "ai/decompose_goal", to: "ai#decompose_goal", as: :decompose_goal_ai
  post "ai/decompose_okr", to: "ai#decompose_okr", as: :decompose_okr_ai
  post "ai/decompose_key_result", to: "ai#decompose_key_result", as: :decompose_key_result_ai
  post "ai/schedule_open_tasks", to: "ai#schedule_open_tasks", as: :schedule_open_tasks_ai
  post "ai/apply_open_tasks_schedule", to: "ai#apply_open_tasks_schedule", as: :apply_open_tasks_schedule_ai
  get "ai/logs", to: "ai#logs", as: :logs_ai
  get "ai/logs/:id", to: "ai#show_log", as: :show_log_ai
  delete "ai/logs/clear", to: "ai#clear_logs", as: :clear_logs_ai

  get "settings", to: "settings#index"
  patch "settings", to: "settings#update", as: :update_settings
  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboard#index"
end
