require "rails_helper"

RSpec.describe "Admin posts", type: :request, inertia: true do
  let(:admin) { create(:user) }

  it "requires login" do
    get "/admin"
    expect(response).to redirect_to(new_user_session_path)

    post "/admin/posts", params: { post: { title: "x", content: "y" } }
    expect(response).to redirect_to(new_user_session_path)
    expect(Post.count).to eq(0)
  end

  describe "signed in" do
    before { sign_in admin }

    it "lists drafts and published posts with the site settings" do
      create(:post, title: "Live", published_at: 1.day.ago)
      create(:post, :draft, title: "Draft one")

      get "/admin"

      expect(inertia).to render_component("admin/posts/index")
      expect(inertia.props[:posts].map { |p| [ p[:title], p[:published] ] })
        .to contain_exactly([ "Live", true ], [ "Draft one", false ])
      expect(inertia.props[:settings]).to eq("show_heatmap" => true, "show_writing" => true)
    end

    it "creates a draft" do
      post "/admin/posts", params: { post: { title: "Brand New", content: "Body", published: "false" } }

      created = Post.find_by!(slug: "brand-new")
      expect(created).not_to be_published
      expect(response).to redirect_to("/admin/posts/brand-new/edit")
    end

    it "creates a published post" do
      post "/admin/posts", params: { post: { title: "Live Now", content: "Body", published: "true" } }
      expect(Post.find_by!(slug: "live-now")).to be_published
    end

    it "sends validation errors back to the form" do
      post "/admin/posts", params: { post: { title: "", content: "", published: "false" } }

      expect(response).to redirect_to("/admin/posts/new")
      expect(session[:inertia_errors]).to include(title: "Title can't be blank")
    end

    it "keeps the original publish date when re-saving a published post" do
      record = create(:post, published_at: Time.zone.local(2016, 1, 16))

      patch "/admin/posts/#{record.slug}", params: { post: { title: "Edited", content: "New", published: "true" } }

      expect(record.reload).to have_attributes(title: "Edited", published_at: Time.zone.local(2016, 1, 16))
    end

    it "unpublishes a post back to a draft" do
      record = create(:post)
      patch "/admin/posts/#{record.slug}", params: { post: { title: record.title, content: "x", published: "false" } }
      expect(record.reload).not_to be_published
    end

    it "deletes a post" do
      record = create(:post)
      expect { delete "/admin/posts/#{record.slug}" }.to change(Post, :count).by(-1)
      expect(response).to redirect_to(admin_root_path)
    end

    it "previews Markdown as sanitized HTML" do
      post "/admin/preview", params: { content: "_hi_ <script>x</script>" }, as: :json
      expect(response.parsed_body["html"]).to eq("<p><em>hi</em> x</p>\n")
    end

    it "toggles the home page sections" do
      patch "/admin/settings", params: { settings: { show_heatmap: "false" } }

      expect(SiteSetting.current.show_heatmap).to be(false)
      expect(flash[:notice]).to eq("GitHub activity hidden on the home page")

      get "/"
      expect(inertia.props[:settings]).to include("show_heatmap" => false)
      expect(inertia.props[:contributions]).to be_nil
    end
  end
end
