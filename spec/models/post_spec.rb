require "rails_helper"

RSpec.describe Post, type: :model do
  it "is valid with a title and content" do
    expect(build(:post)).to be_valid
  end

  it "requires a title" do
    expect(build(:post, title: "")).not_to be_valid
  end

  it "requires content" do
    expect(build(:post, content: "")).not_to be_valid
  end

  it "generates a slug from the title and uses it as the URL param" do
    post = create(:post, title: "Hello World!")
    expect(post.slug).to eq("hello-world")
    expect(post.to_param).to eq("hello-world")
  end

  it "requires a unique slug" do
    create(:post, title: "Same Title")
    expect(build(:post, title: "Same Title")).not_to be_valid
  end

  describe "publishing" do
    it "treats posts without published_at, or scheduled in the future, as unpublished" do
      live = create(:post, published_at: 1.hour.ago)
      draft = create(:post, :draft)
      scheduled = create(:post, published_at: 1.day.from_now)

      expect(described_class.published).to contain_exactly(live)
      expect(described_class.drafts).to contain_exactly(draft)
      expect([ live, draft, scheduled ].map(&:published?)).to eq([ true, false, false ])
    end
  end

  it "estimates reading time, at least one minute" do
    expect(build(:post, content: "word " * 10).reading_minutes).to eq(1)
    expect(build(:post, content: "word " * 500).reading_minutes).to eq(3)
  end

  it "builds a plain-text excerpt" do
    post = build(:post, content: "First **paragraph** here.\n\n" + ("more " * 100))
    expect(post.excerpt).to start_with("First paragraph here. more")
    expect(post.excerpt.length).to be <= 160
  end
end
