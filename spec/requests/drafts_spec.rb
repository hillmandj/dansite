require "rails_helper"

RSpec.describe "Drafts", type: :request do
  it "requires login" do
    get "/drafts"
    expect(response).to redirect_to(new_user_session_path)
  end

  context "as the admin" do
    before { sign_in create(:user) }

    it "lists drafts" do
      create(:draft, title: "Work in progress")
      get "/drafts"
      expect(response.body).to include("Work in progress")
    end

    it "saves a new draft" do
      expect {
        post "/drafts", params: { draft: { title: "Idea", content: "Notes" } }
      }.to change(Draft, :count).by(1)
    end

    it "publishes a new draft straight to a post" do
      expect {
        post "/drafts", params: { create_post: "1", draft: { title: "Ship It", content: "Done" } }
      }.to change(Post, :count).by(1).and change(Draft, :count).by(0)
    end

    it "updates a draft" do
      draft = create(:draft)
      patch "/drafts/#{draft.id}", params: { update_draft: "1", draft: { title: "Renamed" } }
      expect(draft.reload.title).to eq("Renamed")
      expect(response).to redirect_to(drafts_path)
    end

    it "publishes an existing draft and removes it" do
      draft = create(:draft, title: "Ready")
      expect {
        patch "/drafts/#{draft.id}", params: { create_post: "1", draft: { title: "Ready", content: "Final" } }
      }.to change(Post, :count).by(1).and change(Draft, :count).by(-1)
    end

    it "keeps the draft when publishing fails" do
      create(:post, title: "Taken")
      draft = create(:draft, title: "Taken")
      patch "/drafts/#{draft.id}", params: { create_post: "1", draft: { title: "Taken", content: "x" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(Draft.exists?(draft.id)).to be(true)
    end

    it "returns the draft count" do
      create_list(:draft, 2)
      get "/draft_count"
      expect(response.parsed_body).to eq("draft_count" => 2)
    end
  end
end
