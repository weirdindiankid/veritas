Rails.application.routes.draw do
  root "home#index"

  resources :companies do
    member do
      patch :rearchive
    end
    resources :documents, only: [ :index, :show ]
  end

  resources :documents, only: [ :index, :show ] do
    resources :archives, only: [ :index, :show ]
  end

  # API routes
  namespace :api do
    namespace :v1 do
      resources :companies, only: [ :index, :show ] do
        resources :documents, only: [ :index, :show ]
      end
      resources :documents, only: [ :index, :show ]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
