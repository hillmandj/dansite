require "rails_helper"

RSpec.describe "Admin login", type: :request do
  let!(:admin) { create(:user, email: "admin@example.com", password: "password123") }

  it "renders the React login page, also at /login", inertia: true do
    get "/login"
    expect(inertia).to render_component("auth/login")
  end

  it "signs in to the admin and out to the home page" do
    post "/users/sign_in", params: { user: { email: "admin@example.com", password: "password123" } }
    expect(response).to redirect_to(admin_root_path)

    get "/admin"
    expect(response).to have_http_status(:ok)

    delete "/users/sign_out"
    expect(response).to redirect_to(root_path)

    get "/admin"
    expect(response).to redirect_to(new_user_session_path)
  end

  it "sends a bad password back to the form with an error" do
    post "/users/sign_in", params: { user: { email: "admin@example.com", password: "wrong" } }

    expect(response).to redirect_to(new_user_session_path)
    expect(session[:inertia_errors]).to eq(email: "Invalid email or password.")
  end

  it "accepts a password hashed by the old Devise 3 / Rails 4 app" do
    # bcrypt cost-10 hash of "password123", the format stored in the legacy production DB.
    admin.update_column(:encrypted_password, BCrypt::Password.create("password123", cost: 10))

    post "/users/sign_in", params: { user: { email: "admin@example.com", password: "password123" } }
    expect(response).to redirect_to(admin_root_path)
  end
end
