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

  it "serves the favicons" do
    %w[/favicon.ico /icon.svg /apple-touch-icon.png].each do |path|
      expect(Rails.public_path.join(path.delete_prefix("/"))).to exist
    end
  end
end
