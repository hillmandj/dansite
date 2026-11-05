Rails.application.routes.draw do
  # Health check used by Kamal to decide whether a new container is ready.
  get "up" => "rails/health#show", as: :rails_health_check

  # Send www.daniel-hillman.com to the bare domain, keeping the path.
  constraints(host: /\Awww\./) do
    get "(*path)", to: redirect(status: 301) { |_params, request|
      "#{request.protocol}#{request.host.delete_prefix('www.')}#{request.fullpath}"
    }
  end

  devise_for :users, skip: :registrations, controllers: { sessions: "users/sessions" }
  devise_scope :user do
    get "login", to: "users/sessions#new"
  end

  root "pages#home"

  # Old standalone pages now live as sections of the home page.
  get "about", to: redirect("/", status: 301)
  get "work", to: redirect("/#work", status: 301)
  get "contact", to: redirect("/#contact", status: 301)

  resources :posts, path: "blog", only: %i[index show]

  namespace :admin do
    root "posts#index"
    resources :posts, except: :show
    post "preview", to: "posts#preview"
    resources :images, only: :create
    resource :settings, only: :update
    resource :account, only: %i[edit update]
  end

  # Error pages (config.exceptions_app sends errors here by status code).
  match "404", to: "errors#not_found", via: :all
  match ":code", to: "errors#show", via: :all, constraints: { code: /[45]\d\d/ }

  # Any other URL is a 404.
  match "*path", to: "errors#not_found", via: :all
end
