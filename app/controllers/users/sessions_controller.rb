module Users
  # Devise login with a React page. Failed logins redirect back with an error
  # (the Inertia way) instead of re-rendering a server template.
  class SessionsController < Devise::SessionsController
    layout "inertia"
    inertia_share admin: -> { user_signed_in? }

    def new
      inertia_meta.add(title: "Log in · Daniel Hillman")
      render inertia: "auth/login"
    end

    def create
      self.resource = warden.authenticate(auth_options)
      if resource
        sign_in(resource_name, resource)
        redirect_to after_sign_in_path_for(resource)
      else
        redirect_to new_user_session_path, inertia: { errors: { email: "Invalid email or password." } }
      end
    end
  end
end
