require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "home", inertia: true do
    it "renders the home page with posts, newest first" do
      create(:post, title: "Older", published_at: 2.years.ago)
      create(:post, title: "Newer", published_at: 1.year.ago)
      create(:post, :draft, title: "Unfinished")

      get "/"

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("home/index")
      expect(inertia.props[:posts].map { |p| p[:title] }).to eq(%w[Newer Older])
      expect(inertia.props[:settings]).to eq("show_heatmap" => true, "show_writing" => true)
    end

    it "includes contribution data when available" do
      allow(GithubContributions).to receive(:current).and_return("days" => [], "total" => 5, "active_days" => 2)

      get "/"

      expect(inertia.props[:contributions]).to include(total: 5)
    end

    it "still renders when GitHub data is unavailable" do
      get "/"

      expect(response).to have_http_status(:ok)
      expect(inertia.props[:contributions]).to be_nil
    end
  end

  it "redirects the old standalone pages to sections of the home page" do
    { "/about" => "/", "/work" => "/#work", "/contact" => "/#contact" }.each do |from, to|
      get from
      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to eq("http://example.com#{to}")
    end
  end

  it "redirects www to the bare domain, keeping the path" do
    host! "www.example.com"
    get "/blog"
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("http://example.com/blog")
  end

  it "responds to the health check" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end
end
