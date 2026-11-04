require "rails_helper"

RSpec.describe "Posts", type: :request do
  let(:admin) { create(:user) }

  describe "public pages" do
    it "lists posts newest first" do
      create(:post, title: "Older", created_at: 2.days.ago)
      create(:post, title: "Newer", created_at: 1.day.ago)

      get "/blog"

      expect(response).to have_http_status(:ok)
      expect(response.body.index("Newer")).to be < response.body.index("Older")
    end

    it "shows a post by slug and renders Textile" do
      create(:post, title: "Hello World", content: "Some *bold* text")

      get "/blog/hello-world"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<strong>bold</strong>")
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

    it "previews Textile as HTML" do
      post "/blog/preview", params: { title: "T", content: "_hi_" }, as: :json
      expect(response.parsed_body).to eq("preview_title" => "T", "preview_content" => "<p><em>hi</em></p>")
    end
  end
end
