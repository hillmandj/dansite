require "rails_helper"

RSpec.describe "Google Analytics tag", type: :request do
  before { allow(Rails.env).to receive(:production?).and_return(true) }

  it "is included for visitors in production" do
    get root_path
    expect(response.body).to include("G-RT6CVXVLSZ")
  end

  it "is skipped for the signed-in admin" do
    sign_in create(:user)
    get posts_path
    expect(response.body).not_to include("G-RT6CVXVLSZ")
  end
end
