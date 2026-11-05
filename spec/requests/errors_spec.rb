require "rails_helper"

RSpec.describe "Not found", type: :request do
  it "renders the 404 page for unknown URLs", inertia: true do
    get "/some/old-link"

    expect(response).to have_http_status(:not_found)
    expect(inertia).to render_component("errors/not_found")
    expect(inertia.props[:path]).to eq("/some/old-link")
    expect(response.body).to include('name="robots" content="noindex"')
  end

  it "answers non-HTML requests with a bare 404" do
    get "/nope.json"
    expect(response).to have_http_status(:not_found)
    expect(response.body).to be_empty
  end

  describe "other errors", type: :request do
    before do
      # Exercise the production error handling (exceptions_app) in this spec.
      allow(Rails.application).to receive(:env_config).and_wrap_original do |original|
        original.call.merge("action_dispatch.show_exceptions" => :all, "action_dispatch.show_detailed_exceptions" => false)
      end
    end

    it "keeps the real status for a rejected security token instead of calling it a 404" do
      ActionController::Base.allow_forgery_protection = true
      sign_in create(:user)

      post "/admin/preview", params: { content: "hi" }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    ensure
      ActionController::Base.allow_forgery_protection = false
    end

    it "accepts the XSRF-TOKEN cookie value sent as X-XSRF-TOKEN" do
      ActionController::Base.allow_forgery_protection = true
      sign_in create(:user)
      get "/admin"
      token = cookies["XSRF-TOKEN"]
      expect(token).to be_present

      post "/admin/preview", params: { content: "*hi*" }, as: :json, headers: { "X-XSRF-TOKEN" => CGI.unescape(token) }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["html"]).to eq("<p><em>hi</em></p>\n")
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end

  it "serves the favicons" do
    %w[/favicon.ico /icon.svg /apple-touch-icon.png].each do |path|
      expect(Rails.public_path.join(path.delete_prefix("/"))).to exist
    end
  end
end
