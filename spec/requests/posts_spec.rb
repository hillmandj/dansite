require "rails_helper"

RSpec.describe "Posts", type: :request do
  let(:admin) { create(:user) }

  describe "public pages", inertia: true do
    it "lists published posts newest first" do
      create(:post, title: "Older", published_at: 2.days.ago)
      create(:post, title: "Newer", published_at: 1.day.ago)
      create(:post, :draft, title: "Unfinished")

      get "/blog"

      expect(response).to have_http_status(:ok)
      expect(inertia).to render_component("posts/index")
      expect(inertia.props[:posts].map { |p| p[:title] }).to eq(%w[Newer Older])
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

    it "hides drafts from visitors" do
      create(:post, :draft, title: "Secret")
      get "/blog/secret"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for an unknown slug" do
      get "/blog/does-not-exist"
      expect(response).to have_http_status(:not_found)
    end

    it "requires login to create a post" do
      get "/blog/new"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "as the admin" do
    before { sign_in admin }

    it "can preview a draft", inertia: true do
      create(:post, :draft, title: "Secret")
      get "/blog/secret"
      expect(inertia.props[:post]).to include(draft: true)
    end

    it "publishes new posts immediately" do
      post "/blog", params: { post: { title: "Brand New", content: "Body" } }
      expect(Post.find_by(slug: "brand-new")).to be_published
    end

    it "creates a post" do
      expect {
        post "/blog", params: { post: { title: "Brand New", content: "Body" } }
      }.to change(Post, :count).by(1)
      expect(response).to redirect_to("/blog/brand-new")
    end

    it "re-renders the form when invalid" do
      post "/blog", params: { post: { title: "", content: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "updates a post" do
      record = create(:post)
      patch "/blog/#{record.slug}", params: { post: { title: "Edited" } }
      expect(record.reload.title).to eq("Edited")
    end

    it "deletes a post" do
      record = create(:post)
      expect { delete "/blog/#{record.slug}" }.to change(Post, :count).by(-1)
    end

    it "previews Markdown as HTML" do
      post "/blog/preview", params: { title: "T", content: "_hi_" }, as: :json
      expect(response.parsed_body).to eq("preview_title" => "T", "preview_content" => "<p><em>hi</em></p>\n")
    end
  end
end
