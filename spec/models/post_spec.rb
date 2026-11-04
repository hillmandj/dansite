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
end
