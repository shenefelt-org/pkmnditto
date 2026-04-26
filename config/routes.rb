Rails.application.routes.draw do
  resources :types
  resources :items
  resources :pokemons

  # Replit Auth (OpenID Connect) routes — OmniAuth middleware handles POST /auth/replit
  match "/auth/replit/callback", to: "sessions#create",  via: [:get, :post], as: :auth_replit_callback
  get   "/auth/failure",         to: "sessions#failure", as: :auth_failure
  get   "/signout",              to: "sessions#destroy", as: :signout

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "items#index"
end
