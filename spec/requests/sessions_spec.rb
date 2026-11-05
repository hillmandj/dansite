require "rails_helper"

RSpec.describe "Admin login", type: :request do
  let!(:admin) { create(:user, email: "admin@example.com", password: "password123") }

  it "signs in and out" do
    post "/users/sign_in", params: { user: { email: "admin@example.com", password: "password123" } }
    expect(response).to redirect_to(posts_path)

    get "/blog/new"
    expect(response).to have_http_status(:ok)

    delete "/users/sign_out"
    expect(response).to redirect_to(posts_path)

    get "/blog/new"
    expect(response).to redirect_to(new_user_session_path)
  end

  it "rejects a bad password" do
    post "/users/sign_in", params: { user: { email: "admin@example.com", password: "wrong" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "accepts a password hashed by the old Devise 3 / Rails 4 app" do
    # bcrypt cost-10 hash of "password123", the format stored in the legacy production DB.
    legacy_hash = BCrypt::Password.create("password123", cost: 10)
    admin.update_column(:encrypted_password, legacy_hash)

    post "/users/sign_in", params: { user: { email: "admin@example.com", password: "password123" } }
    expect(response).to redirect_to(posts_path)
  end
end
