Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :users, only: :create do
        get "members/dashboard", to: "users/members/dashboard#show", on: :collection
        get "librarians/dashboard", to: "users/librarians/dashboard#show", on: :collection
      end
      resources :auth, only: :create
      resources :books do
        resources :reservations, only: %i[ create update ], controller: "books/reservations"
      end
    end
  end
end
