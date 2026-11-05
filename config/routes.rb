Rails.application.routes.draw do
  # Health check used by Kamal to decide whether a new container is ready.
  get "up" => "rails/health#show", as: :rails_health_check

  # Send www.daniel-hillman.com to the bare domain, keeping the path.
  constraints(host: /\Awww\./) do
    get "(*path)", to: redirect(status: 301) { |_params, request|
      "#{request.protocol}#{request.host.delete_prefix('www.')}#{request.fullpath}"
    }
  end

  devise_for :users, skip: :registration
  as :user do
    get "users/edit" => "devise/registrations#edit", as: :edit_user_registration
    put "users" => "devise/registrations#update", as: :user_registration
  end

  root "pages#home"

  # Old standalone pages now live as sections of the home page.
  get "about", to: redirect("/", status: 301)
  get "work", to: redirect("/#work", status: 301)
  get "contact", to: redirect("/#contact", status: 301)
  get "draft_count" => "drafts#draft_count"

  resources :posts, path: "blog" do
    collection { post "preview" }
    member { post "preview" }
  end

  resources :drafts do
    collection { post "preview" }
    member { post "preview" }
  end
end
