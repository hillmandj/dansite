require "rails_helper"

RSpec.describe "Admin account", type: :request do
  let(:admin) { create(:user, password: "password123") }

  before { sign_in admin }

  it "changes the password with the current one" do
    patch "/admin/account", params: { account: { current_password: "password123", password: "newpass456", password_confirmation: "newpass456" } }

    expect(response).to redirect_to(admin_root_path)
    expect(admin.reload.valid_password?("newpass456")).to be(true)
  end

  it "rejects a wrong current password" do
    patch "/admin/account", params: { account: { current_password: "nope", password: "newpass456", password_confirmation: "newpass456" } }

    expect(response).to redirect_to(edit_admin_account_path)
    expect(admin.reload.valid_password?("password123")).to be(true)
  end
end
