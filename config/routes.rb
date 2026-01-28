Rails.application.routes.draw do
  resource :session
  resource :registration
  get "/auth/:provider/callback", to: "sessions#omniauth"
  get "/auth/failure", to: "sessions#oauth_failure"
  get "/login", to: "sessions#new"
  resources :passwords, param: :token
  get "about", to: "pages#about"
  resources :user_profiles, only: [ :edit, :update ]
  resources :calendars do
    resources :slots do
      member do
        post "confirm", to: "slots#confirm"
      end
    end
    resource :schedule, only: [ :show ]
    post "release_all_slots", to: "slots#release_all_slots"
  end
  resources :appointments
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Sidekiq Web UI (protect this route in production!)
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"


  root "home#show"
end
