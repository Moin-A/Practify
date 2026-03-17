Rails.application.routes.draw do
  resource :session
  resource :registration
  get "/auth/:provider/callback", to: "sessions#omniauth"
  get "/auth/failure", to: "sessions#oauth_failure"
  get "/login", to: "sessions#new"
  resources :passwords, param: :token
  get "about", to: "pages#about"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"
  resources :user_profiles, only: [ :edit, :update, :index, :show ]
  resources :calendars do
    resources :slots do
      resources :slot_credits, as: :credits
      member do
        post "confirm", to: "slots#confirm"
      end
      resource :checkout, only: [ :new ] do
        post :verify, on: :collection
      end
    end
    resource :schedule, only: [ :show ]
    post "release_all_slots", to: "slots#release_all_slots"
  end
  resources :appointments do
    resources :call_rooms, only: [ :new, :create, :show ]
    member do
      post "has_joined", to: "appointments#has_joined"
      post "reshedule", to: "appointments#reshedule"
      post "reset_modal", to: "appointments#reset_modal"
    end
    collection do
       post "require_payment"
    end
  end

  resources :users do
    resources :private_client_notes, path: "private_client_notes", as: "private_client_notes", controller: "notes" do
      member do
        post "mark_as_read", to: "notes#mark_as_read"
      end
    end
    resources :therapist_observations, path: "therapist_observations", as: "therapist_observations", controller: "notes"
    resources :shared_resources, path: "shared_resources", as: "shared_resources", controller: "client_resources"
  end



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Sidekiq Web UI (protect this route in production!)
  # require "sidekiq/web"
  # mount Sidekiq::Web => "/sidekiq"

  mount MissionControl::Jobs::Engine => "/jobs"
  # Checkout / payment

  root "home#show"
end
