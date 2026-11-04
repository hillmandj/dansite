require "rails_helper"

RSpec.describe "Pages", type: :request do
  it "renders the about page at the root" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Staff Software Engineer")
  end

  it "renders the contact page" do
    get "/contact"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("hillmandj@gmail.com")
  end

  it "lists projects in position order on the work page" do
    create(:project, name: "Second", position: 1)
    create(:project, name: "First", position: 0)

    get "/work"

    expect(response).to have_http_status(:ok)
    expect(response.body.index("First")).to be < response.body.index("Second")
  end

  it "redirects www to the bare domain, keeping the path" do
    host! "www.example.com"
    get "/work"
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("http://example.com/work")
  end

  it "responds to the health check" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end
end
