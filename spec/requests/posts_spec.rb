require "rails_helper"

RSpec.describe "Posts", type: :request, inertia: true do
  it "lists published posts newest first" do
    create(:post, title: "Older", published_at: 2.days.ago)
    create(:post, title: "Newer", published_at: 1.day.ago)
    create(:post, :draft, title: "Unfinished")

    get "/blog"

    expect(response).to have_http_status(:ok)
    expect(inertia).to render_component("posts/index")
    expect(inertia.props[:posts].map { |p| p[:title] }).to eq(%w[Newer Older])
  end

  it "paginates the list, newest first" do
    stub_const("PostsController::PER_PAGE", 2)
    5.times { |i| create(:post, title: "Post #{i}", published_at: (10 - i).days.ago) }

    get "/blog", params: { page: 2 }
    expect(inertia.props[:posts].map { |p| p[:title] }).to eq([ "Post 2", "Post 1" ])
    expect(inertia.props).to include(page: 2, total_pages: 3)

    get "/blog", params: { page: 99 }
    expect(inertia.props[:page]).to eq(3)
    expect(inertia.props[:posts].map { |p| p[:title] }).to eq([ "Post 0" ])
  end

  it "shows a post rendered from Markdown, with its neighbors" do
    create(:post, title: "Before", published_at: 3.days.ago)
    create(:post, title: "Hello World", content: "Some **bold** text", published_at: 2.days.ago)
    create(:post, title: "After", published_at: 1.day.ago)

    get "/blog/hello-world"

    expect(response).to have_http_status(:ok)
    expect(inertia).to render_component("posts/show")
    expect(inertia.props[:post]).to include(title: "Hello World", html: "<p>Some <strong>bold</strong> text</p>\n", draft: false)
    expect(inertia.props[:older]).to eq("title" => "Before", "slug" => "before")
    expect(inertia.props[:newer]).to eq("title" => "After", "slug" => "after")
  end

  it "puts the title and description in the server-rendered head for link previews" do
    create(:post, title: "Hello World", content: "A short first paragraph.")

    get "/blog/hello-world"

    expect(response.body).to include("<title data-inertia=\"title\">Hello World · Daniel Hillman</title>")
    expect(response.body).to include('content="A short first paragraph."')
    expect(response.body).to include('property="og:title" content="Hello World"')
  end

  it "hides drafts from visitors but shows them to the admin" do
    create(:post, :draft, title: "Secret")

    get "/blog/secret"
    expect(response).to have_http_status(:not_found)

    sign_in create(:user)
    get "/blog/secret"
    expect(inertia.props[:post]).to include(draft: true)
    expect(inertia.props[:admin]).to be(true)
  end

  it "returns 404 for an unknown slug" do
    get "/blog/does-not-exist"
    expect(response).to have_http_status(:not_found)
  end
end
